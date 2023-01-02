`timescale 1ns / 1ps

module program_counter(
    input   wire            rst,
    input   wire            clk,

    input   wire    [15:0]  i_set_address,
    input   wire            i_set_en,

    input   wire            i_lock,

    input   wire            i_address_en,
    output  wire    [15:0]  o_address
    );

    reg     [15:0]      pc;

    wire    [15:0]      pc_curr_value;

    always@(posedge clk or negedge rst) begin
        if (!rst)
            pc <= 16'h0000;
        else if (!i_set_en && !i_lock)
            pc <= pc + 16'h0001;
        else if (i_set_en)
            pc <= i_set_address;
        else if (i_lock)
            pc <= pc;
        else
            // if i_set and i_lock are enabled at same time
            // lock pc
            pc <= pc;
    end

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif1 pc_o_controller (pc_curr_value[i], pc[i], i_address_en);
        end
    endgenerate

    assign o_address = pc_curr_value;
endmodule
