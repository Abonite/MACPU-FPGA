`include "instructions.vh"

module decoder (
    input   wire            clk,
    input   wire            n_rst,

    inout   wire    [15:0]  io_data_bus,
    output  wire    [15:0]  o_addr_bus,

    //decoder control signals
    input   wire            i_data_enable,
    input   wire            i_data_io,
    input   wire            i_address_enable,

    input   wire            i_lock,

    // ----------io control code----------
    // 0: rw io:        0, in; 1, out
    // 1: data io:      0, in; 1, out
    // 2: lock io:      0, in; 1, out(when out lock must be 1)
    // 3: inta enable:  0, disable; 1, enable
    // 4: intb enable:  0, disable; 1, enable
    output  wire    [4:0]   o_io_control_code,
    // ----------pc control code----------
    // 0: pc set:       0, unset; 1, set enable
    // 1: pc output:    0, output disable; 1, output enable;
    // 2: pc lock:      0, unlock pc; lock pc;
    output  wire    [2:0]   o_pc_control_code,
    // ----------decoder control code----------
    // 0: dc data io:           0, input; 1, output
    // 1: dc data enable:       0, disable; 1, enable
    // 2: dc address output:    0, disable; 1, output
    // 3: dc lock:              0, unlock; 1, lock
    output  wire    [2:0]   o_dc_control_code,
    // ----------controller control code----------
    // ----------alu control code----------
    // 0:       alu reg io:             0, input; 1, output
    // 1:       alu reg io enable:      0, disable; 1, enable
    // 2:       alu input type:         0, load to reg; 1, immediate number
    // [6:3]:   alu 1st reg selector:   0 - 5, reg A - reg F; F, immediate number;
    // [10:7]:  alu 2nd reg selector:   0 - 5, reg A - reg F; 6, SS; 7, SP;
    // [18:11]: alu operate:
    //      0, load to the resigiter selected by "1st reg selector";
    //      1, add; 2, sub; 3, and; 4, or; 5, not; 6, xor; 7, rand;
    //      8, ror; ...
    //      more instructions code in instructions.toml
    output  wire    [18:0]  o_alu_control_code
    );

    reg     [4:0]       io_control_code;
    reg     [2:0]       pc_control_code;
    reg     [2:0]       dc_control_code;
    reg     [18:0]      alu_control_code;

    wire    [15:0]  datatemp;

    wire    [15:0]  data_bus_out;
    reg     [15:0]  data;

    assign data_bus_out = data;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif0  bufdatar    (datatemp[i], io_data_bus[i], i_data_io);
            bufif1  bufdataw    (io_data_bus[i], data_bus_out[i], i_data_io);
        end
    endgenerate

    reg     [15:0]  data_in_dl;
    always @(posedge clk or negedge n_rst) begin
        if (!n_rst)
            data_in_dl <= 16'h0;
        else
            data_in_dl <= datatemp;
    end

    assign datamux = (i_lock || i_data_enable) ? datatemp : dl_data;

    parameter
        INST        = 3'h0,
        ONE_ARG     = 3'h1,
        TWO_ARGA    = 3'h2,
        TWO_ARGB    = 3'h3,
        WB_ARGA     = 3'h4,
        WB_ARGB     = 3'h5,
        WRITE_BACK  = 3'h6;

    always @(posedge clk or negedge n_rst) begin
        if (!rst || i_lock || !i_data_enable) begin
            curr_state <= INST;
            next_state <= INST;
        end else begin
            curr_state <= next_state;
        end
    end

    always @(*) begin
        case (curr_state)
            INST: begin
                case (datamux)
                    // *INST_INFO_START*
                    `NOP: next_state = INST;
                    `LOAD: next_state = TWO_ARGA;
                    `MOV_RR: next_state = TWO_ARGA;
                    `MOV_RA: next_state = WB_ARGA;
                    `ADD: next_state = TWO_ARGA;
                    `JMP: next_state = ONE_ARG;
                    // *INST_INFO_END*
                endcase
            end
            ONE_ARG: next_state = INST;
            TWO_ARGA: next_state = TWO_ARGB;
            TWO_ARGB: next_state = INST;
            WB_ARGA: next_state = WB_ARGB;
            WB_ARGB: next_state = WRITE_BACK;
            WRITE_BACK: next_state = INST;
        endcase
    end

    always @(*) begin
        case (curr_state)
            INST: begin
            end
            ONE_ARG: begin
                case (inst)
                    `JMP: begin
                        unset_data;
                        set_addr(datamux);
                        read;
                        pc_set_enable__output_enable__unlock;
                        unlock_decoder;
                        decoder_output_address;
                        decoder_data_unable;
                        reg_unable;
                    end
                endcase
            end
            TWO_ARGA: begin
                unset_addr;
                unset_addr;
                read;
                pc_output_enable__unset__unlock;
                unlock_decoder;
                decoder_address_idle;
                decoder_input_data;
                reg_unable;
            end
            TWO_ARGB: begin
                case (inst)
                    `LOAD: begin
                        unset_addr;
                        set_data(arg_a);
                        read;
                        pc_output_enable__unset__unlock;
                        unlock_decoder;
                        decoder_address_idle;
                        decoder_output_data;
                        reg_input_data_no_op(datamux[3:0]);
                    end
                    `ADD: begin
                        unset_addr;
                        unset_data;
                        read;
                        pc_output_enable__unset__unlock;
                        unlock_decoder;
                        decoder_address_idle;
                        decoder_output_data;
                        reg_operate_no_io(arg_a[3:0], datamux[3:0], 8'h00);
                    end
                    `MOV_RR: begin
                        unset_addr;
                        unset_data;
                        read;
                        pc_output_enable__unset__unlock;
                        unlock_decoder;
                        decoder_address_idle;
                        decoder_output_data;
                        reg_operate_no_io(arg_a[3:0], datamux[3:0], 8'hFF);
                    end
                endcase
            end
            WB_ARGA: begin
                unset_addr;
                unset_addr;
                read;
                pc_output_enable__unset__unlock;
                unlock_decoder;
                decoder_address_idle;
                decoder_input_data;
                reg_unable;
            end
            WB_ARGB: begin
                unset_addr;
                unset_addr;
                read;
                pc_output_enable__unset__unlock;
                unlock_decoder;
                decoder_address_idle;
                decoder_input_data;
                reg_unable;
            end
            WRITE_BACK: begin
                case (inst)
                    `MOV_RA: begin
                        unset_addr;
                        set_data(arg_b);
                        write;
                        pc_lock__unset__no_output;
                        unlock_decoder;
                        decoder_output_data;
                        decoder_data_unable;
                        reg_output_data_no_op(arg_a[3:0]);
                    end
                endcase
            end
        endcase
    end



    assign o_rw_bus = rw;

    assign o_decoder_data_io = decoder_data_enable;
    assign o_decoder_address_enable = decoder_address_enable;
    assign o_decoder_data_enable = decoder_data_enable;
    assign o_decoder_lock = decoder_lock;

    assign o_set_pc_enable = set_pc_enable;
    assign o_pc_address_enable = pc_address_enable;
    assign o_pc_lock = pc_lock;

    assign o_reg_data_enable = reg_data_enable;
    assign o_reg_data_io = reg_data_io;
    assign o_reg_op_enable = reg_op_enable;
    assign o_reg_op = reg_op;
endmodule