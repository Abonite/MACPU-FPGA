module controller (
    input           n_rst,

    input           i_rw,

    input           i_decoder_address_enable,
    input           i_decoder_data_enable,
    input           i_decoder_data_io,

    input           i_pc_set_enable,
    input           i_pc_address_enable,
    input           i_pc_lock,

    input           i_reg_data_enable,
    input           i_reg_data_io,
    input   [7:0]   i_reg_selector,
    input           i_reg_store,
    input           i_reg_op_enable,
    input   [7:0]   i_reg_op,

    input   [63:0]  i_reg_data,
    input   [15:0]  i_flag,

    output          o_decoder_data_enable,
    output          o_decoder_data_io,
    output          o_decoder_lock,

    output          o_pc_set_enable,
    output          o_pc_address_enable,
    output          o_pc_lock
    );

    // decoder control
    reg             decoder_data_enable;
    reg             decoder_data_io;
    task decoder_input;
        begin
            decoder_data_enable = 1'b1;
            decoder_data_io = 1'b0;
        end
    endtask
    task decoder_output;
        begin
            decoder_data_enable = 1'b1;
            decoder_data_io = 1'b1;
        end
    endtask
    task decoder_unable;
        begin
            decoder_data_enable = 1'b0;
            decoder_data_io = 1'b0;
        end
    endtask

    reg             decoder_lock;
    task lock_decoder;
        decoder_lock = 1'b1;
    endtask
    task unlock_decoder;
        decoder_lock = 1'b0;
    endtask

    // programm counter control
    reg             pc_set_enable;
    reg             pc_address_enable;
    reg             pc_lock;
    task pc_output_enable__unset__unlock;
        begin
            pc_set_enable = 1'b0;
            pc_address_enable = 1'b1;
            pc_lock = 1'b0;
        end
    endtask
    task pc_set_enable__output_enable__unlock;
        begin
            pc_set_enable = 1'b1;
            pc_address_enable = 1'b1;
            pc_lock = 1'b0;
        end
    endtask
    task pc_lock__unset__no_output;
        begin
            pc_set_enable = 1'b0;
            pc_address_enable = 1'b0;
            pc_lock = 1'b1;
        end
    endtask
    task pc_lock__output_enable__unset;
        begin
            pc_set_enable = 1'b0;
            pc_address_enable = 1'b1;
            pc_lock = 1'b1;
        end
    endtask
    // io control
    reg             lock_pin_io;
    reg             data_pin_io;
    reg             rw_pin_io;

    always @(*) begin
        if (!n_rst) begin
            decoder_unable;
            unlock_decoder;
            pc_output_enable__unset__unlock;
        end else begin
            decoder_input;
            unlock_decoder;
            pc_output_enable__unset__unlock;
        end
    end
endmodule