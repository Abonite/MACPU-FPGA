`include "instructions.vh"

module decoder (
    input   wire            clk,
    input   wire            n_rst,

    input   wire            i_interrupt,

    inout   wire    [15:0]  io_data_bus,
    output  wire    [15:0]  o_data_alu,
    output  wire    [15:0]  o_addr_bus,

    //decoder control signals
    input   wire            i_data_enable,
    input   wire            i_data_io,
    input   wire            i_address_enable,

    input   wire            i_lock,

    // ----------io control code----------
    // 0: rw io:        0, in; 1, out
    // 1: lock io:      0, in; 1, out(when out lock must be 1)
    // TODO: is this int wire need be controled by dc?
    //      - I think they should be in controller
    output  wire    [1:0]   o_io_control_code,
    // ----------program counter control code----------
    // 0: pc set:       0, unset; 1, set enable
    // 1: pc output:    0, output disable; 1, output enable;
    // 2: pc lock:      0, unlock pc; 1, lock pc;
    output  wire    [2:0]   o_pc_control_code,
    // ----------decoder control code----------
    // 0: dc data io:           0, input; 1, output
    // 1: dc data enable:       0, disable; 1, enable
    // 2: dc address output:    0, disable; 1, output
    // 3: dc lock:              0, unlock; 1, lock
    output  wire    [3:0]   o_dc_control_code,
    // ----------controller control code----------
    // 0:       ct inta enable:             0, disable; 1, enable
    // 1:       ct intb enable:             0, disable; 1, enable
    // 2:       ct interrupt priority:      0, a > b; 1, b > a
    // 3:       ct set int info enable:     0, disable; 1, enable
    // [5:4]:   ct int address set enable:
    //      0, disable;
    //      1, set inta address enable;
    //      2, set intb address enable;
    //      3, reset ints address
    // 6:       ct soft int effective;
    // [11:7]   ct soft int number;
    // 12:      ct recover pc enable;
    output  wire    [12:0]   o_ct_control_code,
    // ----------alu control code----------
    // 0:       alu reg io:             0, input; 1, output
    // 1:       alu reg io enable:      0, disable; 1, enable
    // 2:       alu reg dc enable:      0, disable; 1, enable
    // [6:3]:   alu 1st reg selector:   1 - 6, reg A - reg F; 7, R; 8, immediate number, 0, null
    // [10:7]:  alu 2nd reg selector:   1 - 6, reg A - reg F; 7, SS; 8, SP; 0, null
    // [18:11]: alu operate:
    //      0, non op;
    //      1, add; 2, sub; 3, and; 4, or; 5, not; 6, xor; 7, rand;
    //      8, ror; ...
    //      ff, load, mov or output the resigiter;
    //      more instructions code in instructions.toml
    output  wire    [18:0]  o_alu_control_code
    );

    reg     [1:0]       io_control_code;
    reg     [2:0]       pc_control_code;
    reg     [3:0]       dc_control_code;
    reg     [12:0]      ct_control_code;
    reg     [18:0]      alu_control_code;

    reg     [15:0]      inst, arga, argb;
    reg     [15:0]      inst_int_save, arga_int_save, argb_int_save;

    wire    [15:0]      datatemp;
    wire    [15:0]      datamux;

    reg     [15:0]      addr;

    reg     [15:0]      data_alu;

    wire    [15:0]      data_bus_out;
    reg     [15:0]      data;

    assign data_bus_out = data;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif1  bufdatar    (datatemp[i], io_data_bus[i], (!i_data_io && i_data_enable));
            bufif1  bufdataw    (io_data_bus[i], data_bus_out[i], (i_data_io && i_data_enable));
            bufif1  bufaddro    (o_addr_bus[i], addr[i], i_address_enable);
            pulldown(datatemp[i]);
        end
    endgenerate

    reg     [15:0]  data_in_dl;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst)
            data_in_dl <= 16'h0;
        else
            data_in_dl <= datatemp;
    end

    assign datamux = i_lock ? data_in_dl : datatemp;

    task sm_next_state (
        input   [16:0]  input_data,
        output  [15:0]  next_state
        );
        begin
            case (datamux)
                `NOP:     next_state    =    INST;
                `MOV_AR:  next_state    =    IO_ARGA;
                `MOV_RR:  next_state    =    TWO_ARGA;
                `MOV_RA:  next_state    =    IO_ARGA;
                `LOAD:    next_state    =    TWO_ARGA;
                `ADD_RR:  next_state    =    TWO_ARGA;
                `ADD_RI:  next_state    =    TWO_ARGA;
                `SUB_RR:  next_state    =    TWO_ARGA;
                `SUB_RI:  next_state    =    TWO_ARGA;
                `AND_RR:  next_state    =    TWO_ARGA;
                `AND_RI:  next_state    =    TWO_ARGA;
                `OR_RR:   next_state    =    TWO_ARGA;
                `OR_RI:   next_state    =    TWO_ARGA;
                `NOT_RR:  next_state    =    TWO_ARGA;
                `NOT_RI:  next_state    =    TWO_ARGA;
                `XOR_RR:  next_state    =    TWO_ARGA;
                `XOR_RI:  next_state    =    TWO_ARGA;
                `RAND_R:  next_state    =    TWO_ARGA;
                `RAND_I:  next_state    =    TWO_ARGA;
                `ROR_R:   next_state    =    TWO_ARGA;
                `ROR_I:   next_state    =    TWO_ARGA;
                `RXOR_R:  next_state    =    TWO_ARGA;
                `RXOR_I:  next_state    =    TWO_ARGA;
                `LSL_R:   next_state    =    ONE_ARG;
                `LSL_I:   next_state    =    TWO_ARGA;
                `LSR_R:   next_state    =    ONE_ARG;
                `LSR_I:   next_state    =    TWO_ARGA;
                `ASL_R:   next_state    =    ONE_ARG;
                `ASL_I:   next_state    =    TWO_ARGA;
                `ASR_R:   next_state    =    ONE_ARG;
                `ASR_I:   next_state    =    TWO_ARGA;
                `CSL_R:   next_state    =    ONE_ARG;
                `CSL_I:   next_state    =    TWO_ARGA;
                `CSR_R:   next_state    =    ONE_ARG;
                `CSR_I:   next_state    =    TWO_ARGA;
                `INC:     next_state    =    TWO_ARGA;
                `DEC:     next_state    =    TWO_ARGA;
                `JMP:     next_state    =    TWO_ARGA;
                `PUSH:    next_state    =    IO_ONE_ARG;
                `POP:     next_state    =    IO_ONE_ARG;
                `INT:     next_state    =    IO_OP;
                `SAVEPC:  next_state    =    INST;
                `RECOPC:  next_state    =    INST;
                default: next_state = 16'h0;
            endcase
        end
    endtask

    reg [15:0]  init_next_state;

    always @(*) begin
        sm_next_state(datamux, init_next_state);
    end

    wire    [15:0]  init_ns;

    assign  init_ns = init_next_state;

    reg [15:0]  prog_next_state;
    wire    [15:0]  prog_ns;

    assign  prog_ns = prog_next_state;

    wire    [15:0]  next_state_drive;

    reg     drive_control;
    wire    drive_control_signal;

    assign  drive_control_signal = drive_control;

    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin
            bufif0  next_state_init (next_state_drive[k], init_ns[k], drive_control_signal);
            bufif1  next_state_prog (next_state_drive[k], prog_ns[k], drive_control_signal);
        end
    endgenerate

    parameter
        INST        = 3'h0,
        ONE_ARG     = 3'h1,
        IO_ONE_ARG  = 3'h2,
        TWO_ARGA    = 3'h3,
        TWO_ARGB    = 3'h4,
        IO_ARGA     = 3'h5,
        IO_ARGB     = 3'h6,
        IO_OP       = 3'h7;

    reg [2:0]   curr_state, next_state;

    reg [2:0]   curr_state_int_save, next_state_int_save;

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst || (n_rst && i_interrupt)) begin
            drive_control <= 1'b0;
        end else begin
            drive_control <= 1'b1;
        end
    end

    always @(*) begin
        next_state = next_state_drive;
    end

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            curr_state <= INST;
        end else if (n_rst && i_interrupt) begin
            curr_state_int_save <= curr_state;
            next_state_int_save <= next_state;
            curr_state <= INST;
            inst_int_save <= inst;
            arga_int_save <= arga;
            argb_int_save <= argb;
        end else if (n_rst && !i_interrupt && i_lock) begin
            curr_state <= curr_state;
        end else begin
            curr_state <= next_state;
        end
    end

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            curr_state_int_save <= INST;
            next_state_int_save <= INST;
        end else if (n_rst && i_interrupt) begin
            curr_state_int_save <= curr_state;
            next_state_int_save <= next_state;
            inst_int_save <= inst;
            arga_int_save <= arga;
            argb_int_save <= argb;
        end else begin
            curr_state_int_save <= curr_state_int_save;
            next_state_int_save <= next_state_int_save;
        end
    end

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            inst_int_save <= 16'b0;
            arga_int_save <= 16'b0;
            argb_int_save <= 16'b0;
        end else if (n_rst && i_interrupt) begin
            inst_int_save <= inst;
            arga_int_save <= arga;
            argb_int_save <= argb;
        end else begin
            inst_int_save <= inst_int_save;
            arga_int_save <= arga_int_save;
            argb_int_save <= argb_int_save;
        end
    end

    always @(*) begin
        case (curr_state)
            INST: begin
                sm_next_state(datamux, prog_next_state);
            end
            ONE_ARG:    prog_next_state  = INST;
            IO_ONE_ARG: prog_next_state  = IO_OP;
            TWO_ARGA:   prog_next_state  = TWO_ARGB;
            TWO_ARGB:   prog_next_state  = INST;
            IO_ARGA:    prog_next_state  = IO_ARGB;
            IO_ARGB:    prog_next_state  = IO_OP;
            IO_OP:      prog_next_state  = INST;
        endcase
    end

    always @(*) begin
        case (curr_state)
            INST: begin
                io_control_code = 2'b00;
                pc_control_code = 3'b010;
                dc_control_code = 4'b0010;
                ct_control_code = 13'b0;
                alu_control_code = 19'b0;
                inst = datamux;
                data_alu = 16'h0;
                addr = 16'h0;
            end
            IO_ONE_ARG: begin
                io_control_code = 2'b00;
                pc_control_code = 3'b010;
                dc_control_code = 4'b0010;
                ct_control_code = 13'b0;
                alu_control_code = 19'b0;
                data_alu = 16'h0;
                arga = datamux;
                addr = 16'h0;
            end
            ONE_ARG: begin
                case (inst)
                    `JMP: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b011;
                        dc_control_code = 4'b0010;
                        ct_control_code = 13'b0;
                        alu_control_code = 19'b00;
                        data_alu = 16'h0;
                    end
                endcase
            end
            TWO_ARGA: begin
                io_control_code = 2'b00;
                pc_control_code = 3'b010;
                dc_control_code = 4'b0010;
                ct_control_code = 13'b0;
                alu_control_code = 19'b0;
                data_alu = 16'h0;
                arga = datamux;
            end
            TWO_ARGB: begin
                case (inst)
                    `MOV_RR: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], argb[3:0], arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `LOAD: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, datamux[3:0], 3'b010};
                        addr = 16'b0;
                        data_alu = arga;
                    end
                    `ADD_RR: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], datamux[3:0], arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `ADD_RI: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h8, arga[3:0], 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `SUB_RR: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], datamux[3:0], arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `SUB_RI: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h8, arga[3:0], 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `AND_RR: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], datamux[3:0], arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `AND_RI: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h8, arga[3:0], 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `OR_RR: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], datamux[3:0], arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `OR_RI: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h8, arga[3:0], 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `NOT_RR: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], datamux[3:0], arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `NOT_RI: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h8, arga[3:0], 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `XOR_RR: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], datamux[3:0], arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `XOR_RI: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h8, arga[3:0], 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `RAND_R: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `RAND_I: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, 4'h8, 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `ROR_R: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `ROR_I: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, 4'h8, 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `RXOR_R: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `RXOR_I: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, 4'h8, 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `LSL_I: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, 4'h8, 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `LSR_I: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, 4'h8, 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `ASL_I: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, 4'h8, 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `ASR_I: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, 4'h8, 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `CSL_I: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, 4'h8, 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `CSR_I: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, 4'h8, 3'b010};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `INC: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `DEC: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {inst[7:0], 4'h0, arga[3:0], 3'b000};
                        addr = 16'b0;
                        data_alu = 16'h0;
                    end
                    `JMP: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b001;
                        dc_control_code = 4'b0110;
                        ct_control_code = {1'b0, 5'b0, 1'b0, 2'b00, 4'b0000};
                        alu_control_code = {8'b0, 4'h0, 4'h0, 3'b000};
                        addr = datamux;
                        data_alu = 16'h0;
                    end
                endcase
            end
            IO_ARGA: begin
                io_control_code = 2'b00;
                pc_control_code = 3'b010;
                dc_control_code = 4'b0010;
                ct_control_code = 13'b0;
                alu_control_code = 19'b0;
                arga = datamux;
            end
            IO_ARGB: begin
                io_control_code = 2'b00;
                pc_control_code = 3'b010;
                dc_control_code = 4'b0010;
                ct_control_code = 13'b0;
                alu_control_code = 19'b0;
                argb = datamux;
            end
            IO_OP: begin
                case (inst)
                    `MOV_RA: begin
                        io_control_code = 2'b11;
                        pc_control_code = 3'b100;
                        dc_control_code = 4'b0110;
                        ct_control_code = 13'b0;
                        alu_control_code = {8'hfd, 4'h0000, arga[3:0], 3'b011};
                        addr = argb;
                    end
                    `PUSH: begin
                        io_control_code = 2'b11;
                        pc_control_code = 3'b100;
                        dc_control_code = 4'b0000;
                        ct_control_code = 13'b0;
                        alu_control_code = {8'hf9, 4'h0, arga[3:0], 3'b011};
                        data_alu = 16'h0;
                    end
                    `POP: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b100;
                        dc_control_code = 4'b0000;
                        ct_control_code = 13'b0;
                        alu_control_code = {8'hfa, 4'h0, arga[3:0], 3'b010};
                        data_alu = 16'h0;
                    end
                    `SAVEPC: begin
                        io_control_code = 2'b11;
                        pc_control_code = 3'b100;
                        dc_control_code = 4'b0000;
                        ct_control_code = 13'b0;
                        alu_control_code = {8'hfb, 4'h0, 4'h0, 3'b011};
                        data_alu = 16'h0;
                    end
                    `RECOPC: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b100;
                        dc_control_code = 4'b0000;
                        ct_control_code = {1'b1, 12'b0};
                        alu_control_code = {8'hfc, 4'h0, 4'h0, 3'b010};
                        data_alu = 16'h0;
                    end
                    `INT: begin
                        io_control_code = 2'b00;
                        pc_control_code = 3'b010;
                        dc_control_code = 4'b0010;
                        ct_control_code = {1'b0, datamux[4:0], 1'b1, 6'b0};
                        alu_control_code = 19'b00;
                        data_alu = 16'h0;
                    end
                endcase
            end
        endcase
    end

    assign o_io_control_code = io_control_code;
    assign o_pc_control_code = pc_control_code;
    assign o_dc_control_code = dc_control_code;
    assign o_ct_control_code = ct_control_code;
    assign o_alu_control_code = alu_control_code;
    assign o_data_alu = data_alu;
endmodule