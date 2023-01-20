module L2_cache (
    input   clk_170M,
    input   clk_166M66,

    input   i_l1_operate_enable,
    input   i_l1_rw,
    inout   io_l1_data_bus,

    input   i_ddr_operate_enable,
    input   i_ddr_rw,
    input   io_ddr_data_bus
);

    reg [11:0]  l1cache_unread_size         = 12'h0;
    reg [11:0]  l1cache_operating_address   = 12'h0;
    reg [11:0]  ddr_operating_address       = 12'h0;

    reg         l2cache_full;
    reg         l2cache_empty;

    always @(*) begin
        if (l1cache_unread_size == 0) begin
            l2cache_empty = 1'b1;
            l2cache_full = 1'b0;
        end else if (l1cache_unread_size == 12'hFFF) begin
            l2cache_empty = 1'b0;
            l2cache_full = 1'b1;
        end else begin
            l2cache_empty = 1'b0;
            l2cache_full = 1'b0;
        end
    end

    // TODO: is it ok?
    always @(posedge clk_170M or posedge clk_166M66) begin
        if (i_l1_operate_enable && i_l1_rw)
            l1cache_operating_address <= l1cache_operating_address - 12'h1;
        else if (i_l1_operate_enable && !i_l1_rw)
            l1cache_operating_address <= l1cache_operating_address + 12'h1;
    end


    blk_mem_l2cache_16x4096_128x512 u_l2_cache (
        // port A 16bit, addr 12bit
        clka        (clk_170M),
        ena         (l1_en),
        wea         (l2_rw),
        addra       (),
        dina        (),
        douta       (),
        // port B 128bit, addr 9bit
        clkb        (clk_166M66),
        enb         (),
        web         (),
        addrb       (),
        dinb        (),
        doutb       ()
    );

endmodule