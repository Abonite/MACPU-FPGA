`include "instructions.vh"

module decoder (
    input   wire            clk,
    input   wire            rst,

    input   wire    [15:0]  i_data_bus,
    output  wire    [15:0]  o_data_bus,
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
    // 0: dc data io:       0, input; 1, output
    // 1: dc data enable:   0, disable; 1, enable

    // ----------controller control code----------

    // ----------alu control code----------


    output  wire            o_rw_bus,

    // when need read or write data, the following signals will be change
    // 因为立即数仅产生于解码器，且解码器不需要输入地址，因此没有i_addr_bus和o_imd_address_io
    // this signal is used to control whether the decoder receives or outputs data
    // at next time
    output  wire            o_decoder_data_io,
    output  wire            o_decoder_address_enable,
    output  wire            o_decoder_data_enable,
    output  wire            o_decoder_lock,

    // when jump, the following signals will be change
    output  wire            o_set_pc_enable,
    output  wire            o_pc_address_enable,
    output  wire            o_pc_lock,

    // when load data in to registers or need alu operate
    // the following signals will be change
    output  wire            o_reg_data_enable,
    output  wire            o_reg_data_io,
    output  wire    [7:0]   o_reg_selector,
    output  wire            o_reg_op_enable,
    output  wire    [7:0]   o_reg_op
    );

    // output register
    reg [15:0]  data_bus;
    task set_data(input  [15:0]  data);
        data_bus = data;
    endtask
    task unset_data;
        data_bus = 16'h0;
    endtask

    reg [15:0]  addr_bus;
    task set_addr(input  [15:0]  addr);
        addr_bus = addr;
    endtask
    task unset_addr;
        addr_bus = 16'h0;
    endtask

    reg             rw;
    task read;
        rw = 1'b0;
    endtask
    task write;
        rw = 1'b1;
    endtask

    reg             decoder_data_io;
    reg             decoder_address_enable;
    reg             decoder_data_enable;
    reg             decoder_lock;
    task decoder_output_address;
        decoder_address_enable = 1'b1;
    endtask
    task decoder_address_idle;
        decoder_address_enable = 1'b0;
    endtask
    task decoder_input_data;
        begin
            decoder_data_io = 1'b0;
            decoder_data_enable = 1'b1;
        end
    endtask
    task decoder_output_data;
        begin
            decoder_data_io = 1'b1;
            decoder_data_enable = 1'b1;
        end
    endtask
    task decoder_data_unable;
        begin
            decoder_data_io = 1'b0;
            decoder_data_enable = 1'b0;
        end
    endtask
    task lock_decoder;
        decoder_lock = 1'b1;
    endtask
    task unlock_decoder;
        decoder_lock = 1'b0;
    endtask

    reg             set_pc_enable;
    reg             pc_address_enable;
    reg             pc_lock;
    task pc_output_enable__unset__unlock;
        begin
            set_pc_enable = 1'b0;
            pc_address_enable = 1'b1;
            pc_lock = 1'b0;
        end
    endtask
    task pc_set_enable__output_enable__unlock;
        begin
            set_pc_enable = 1'b1;
            pc_address_enable = 1'b1;
            pc_lock = 1'b0;
        end
    endtask
    task pc_lock__unset__no_output;
        begin
            set_pc_enable = 1'b0;
            pc_address_enable = 1'b0;
            pc_lock = 1'b1;
        end
    endtask
    task pc_lock__output_enable__unset;
        begin
            set_pc_enable = 1'b0;
            pc_address_enable = 1'b1;
            pc_lock = 1'b1;
        end
    endtask

    reg             reg_data_enable;
    reg             reg_data_io;
    reg    [7:0]    reg_selector;
    reg             reg_op_enable;
    reg    [7:0]    reg_op;
    task reg_input_data_no_op(input   [3:0]   register);
        begin
            reg_selector = {register, 4'b0};
            reg_data_io = 1'b0;
            reg_data_enable = 1'b1;
            reg_op_enable = 1'b0;
            reg_op = 8'h0;
        end
    endtask
    task reg_output_data_no_op(input  [3:0]   register);
        begin
            reg_selector = {register, 4'b0};
            reg_data_io = 1'b1;
            reg_data_enable = 1'b1;
            reg_op_enable = 1'b0;
            reg_op = 8'h0;
        end
    endtask
    task reg_operate_no_io(
        input   [3:0]   reg_a,
        input   [3:0]   reg_b,
        input   [7:0]   opcode
    );
        begin
            reg_op_enable = 1'b1;
            reg_op = opcode;
            reg_selector = {reg_a, reg_b};
            reg_data_io = 1'b0;
            reg_data_enable = 1'b0;
        end
    endtask
    task reg_unable;
        begin
            reg_selector = 8'b0;
            reg_data_io = 1'b0;
            reg_data_enable = 1'b0;
            reg_op_enable = 1'b0;
            reg_op = 8'h0;
        end
    endtask

    // control register
    reg [15:0]  dl_data;

    reg [15:0]  inst;
    reg [15:0]  arg_a;
    reg [15:0]  arg_b;

    reg [2:0]   curr_state;
    reg [2:0]   next_state;

    parameter
        INST         = 3'h0,
        ONE_ARG      = 3'h1,
        TWO_ARGA     = 3'h2,
        TWO_ARGB     = 3'h3,
        WB_ARGA      = 3'h4,
        WB_ARGB      = 3'h5,
        WRITE_BACK   = 3'h6;

    wire    [15:0]  datamux;
    wire    [15:0]  datatemp;

    always @(posedge clk or negedge rst) begin
        dl_data <= !rst ? 16'b0 : i_data_bus;
    end

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif0 bufdatar (datatemp[i], i_data_bus, i_data_io);
        end
    endgenerate

    assign datamux = (i_lock || i_data_enable) ? datatemp : dl_data;

    always @(posedge clk or negedge rst) begin
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
                unset_addr;
                unset_addr;
                read;
                pc_output_enable__unset__unlock;
                unlock_decoder;
                decoder_address_idle;
                decoder_input_data;
                reg_unable;
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

    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1) begin
            bufif1  bufdatao (o_data_bus[j], data_bus[j], i_data_io);
            bufif1  bufaddr (o_addr_bus[j], addr_bus[j], i_data_io);
        end
    endgenerate

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