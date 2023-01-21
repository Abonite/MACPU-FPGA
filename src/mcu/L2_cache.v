module L2_cache (
    input           clk_166M66,
    input           mcu_sys_rst_n,

    output  [11:0]  o_l2_unread_size,
    output          o_l1ddr_rw_confilicts,
    output          o_ddr_base_addr_inc,
    output          o_ddr_base_addr_dec,

    input   [11:0]  i_l1_burst_address,
    input           i_l1_burst_address_enable,
    input           i_l1_operate_enable,
    input           i_l1_rw,
    inout   [15:0]  io_l1_data_bus,

    input           i_ddr_operate_enable,
    input           i_ddr_rw,
    input   [127:0] i_ddr_data_bus,
    output  [127:0] o_ddr_data_bus
);

    wire    [15:0]  l1cache_read_bus;
    wire    [15:0]  l1cache_write_bus;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif1  l1writel2   (l1cache_write_bus[i], io_l1_data_bus[i], i_l1_rw && i_l1_operate_enable);
            bufif1  l1readl2    (io_l1_data_bus[i], l1cache_read_bus[i], !i_l1_rw && i_l1_operate_enable);
        end
    endgenerate

    reg [11:0]  l2cache_unread_size         = 12'h0;
    reg [11:0]  l1cache_operating_address   = 12'h0;
    reg [8:0]   ddr_operating_address       = 9'h0;

    reg         l1ddr_rw_confilicts;

    reg [2:0]   l1cache_read_8addr_dl;
    reg         ddr_base_addr_inc;
    reg         ddr_base_addr_dec;

    always @(posedge clk_166M66 or negedge mcu_sys_rst_n) begin
        if (!mcu_sys_rst_n)
            l1cache_operating_address <= 12'h0;
        else if (i_l1_operate_enable && i_l1_rw)
            l1cache_operating_address <= l1cache_operating_address - 12'h1;
        else if (i_l1_operate_enable && !i_l1_rw)
            l1cache_operating_address <= l1cache_operating_address + 12'h1;
        else
            l1cache_operating_address <= l1cache_operating_address;
    end

    always @(posedge clk_166M66) begin
        l1cache_read_8addr_dl[2:0] <= l1cache_operating_address[5:3];
    end

    always @(*) begin
        if (l1cache_read_8addr_dl - l1cache_operating_address[5:3] == 3'h8) begin
            ddr_base_addr_dec = 1'b1;
            ddr_base_addr_inc = 1'b0;
        end else if (l1cache_operating_address[5:3] - l1cache_read_8addr_dl == 3'h8) begin
            ddr_base_addr_dec = 1'b0;
            ddr_base_addr_inc = 1'b1;
        end else begin
            ddr_base_addr_dec = 1'b0;
            ddr_base_addr_inc = 1'b0;
        end
    end

    assign o_ddr_base_addr_dec = ddr_base_addr_dec;
    assign o_ddr_base_addr_inc = ddr_base_addr_inc;

    always @(posedge clk_166M66 or negedge mcu_sys_rst_n) begin
        if (!mcu_sys_rst_n)
            ddr_operating_address <= 9'h0;
        if (i_ddr_operate_enable && i_ddr_rw)
            ddr_operating_address <= ddr_operating_address - 9'h1;
        else if (i_ddr_operate_enable && !i_ddr_rw)
            ddr_operating_address <= ddr_operating_address + 9'h1;
        else
            ddr_operating_address <= ddr_operating_address;
    end

    always @(*) begin
        if (!mcu_sys_rst_n)
            l1ddr_rw_confilicts = 1'b0;
        if (l1cache_operating_address[11:3] == ddr_operating_address)
            l1ddr_rw_confilicts = 1'b1;
        else if (i_l1_burst_address_enable && (i_l1_burst_address[11:3] == ddr_operating_address))
            l1ddr_rw_confilicts = 1'b1;
        else
            l1ddr_rw_confilicts = 1'b0;
    end

    always @(*) begin
        l2cache_unread_size = {ddr_operating_address, 3'b0} - l1cache_operating_address;
    end

    blk_mem_l2cache_16x4096_128x512 u_l2_cache (
        // port A 16bit, addr 12bit
        clka        (clk_166M66),
        ena         (i_l1_operate_enable),
        wea         (i_l1_rw),
        addra       (l1cache_operating_address),
        dina        (l1cache_write_bus),
        douta       (l1cache_read_bus),
        // port B 128bit, addr 9bit
        clkb        (clk_166M66),
        enb         (i_ddr_operate_enable),
        web         (i_ddr_rw),
        addrb       (ddr_operating_address),
        dinb        (i_ddr_data_bus),
        doutb       (o_ddr_data_bus)
    );

    assign  o_l2_unread_size = l2cache_unread_size;
    assign  o_l1ddr_rw_confilicts = l1ddr_rw_confilicts;
endmodule