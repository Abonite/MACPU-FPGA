module vpc (
    input           clk,
    input           n_rst,

    // address to mcu is connect to a bus
    output  [31:0]  o_address_to_mcu,
    output          o_address_valid,

    input   [7:0]   i_address_from_mcu,
    input           i_mcu_set_enable,

    input           i_address_output_enable,
    input           i_lock_vpc
);

    reg     [7:0]   vpc;
    wire    [7:0]   vpc_out;

    assign vpc_out = vpc;

    always @(posedge clk or negedge n_rst) begin
        if (!n_rst)
            vpc <= 32'h0;
        else if (i_lock_vpc)
            vpc <= vpc;
        else if (i_mcu_set_enable)
            vpc <= i_address_from_mcu;
        else
            vpc <= 32'b1;
    end

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif1  vpc_out_buf (o_address_to_mcu[i], vpc_out[i], i_address_output_enable);
        end
    endgenerate

endmodule