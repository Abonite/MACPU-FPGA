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

    input           i_l2_ddr_operate_lock,
    input           i_l2_ddr_force_loading,
    input           i_l2_ddr_bus_enable,
    output          o_l2_ddr_operate_enable,
    output          o_l2_ddr_rw,
    inout   [127:0] io_l2_ddr_data_bus,
    inout           io_l2_ddr_data_enable
);

    wire    [15:0]  l1cache_read_bus;
    wire    [15:0]  l1cache_write_bus;

    wire    [127:0] ddr_read_bus;
    wire    [127:0] ddr_write_bus;

    wire            read_ddr_data_en;
    wire            write_ddr_data_en;

    bufif1  readen  (io_l2_ddr_data_enable, read_ddr_data_en, o_l2_ddr_rw);
    bufif0  writeen (write_ddr_data_en, io_l2_ddr_data_enable, o_l2_ddr_rw);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif1  l1writel2   (l1cache_write_bus[i], io_l1_data_bus[i], i_l1_rw && i_l1_operate_enable);
            bufif1  l1readl2    (io_l1_data_bus[i], l1cache_read_bus[i], !i_l1_rw && i_l1_operate_enable);
        end
    endgenerate

    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1) begin
            bufif1  ddrwritel2  (io_l2_ddr_data_bus[j], ddr_write_bus[j], o_l2_ddr_rw && o_l2_ddr_operate_enable);
            bufif1  ddrreadl2  (ddr_read_bus[j], io_l2_ddr_data_bus[j], !o_l2_ddr_rw && o_l2_ddr_operate_enable);
        end
    endgenerate

    reg [11:0]  l2cache_unread_size         = 12'h0;
    reg [11:0]  l1cache_operating_address   = 12'h0;
    reg [8:0]   ddr_operating_address       = 9'h0;

    reg         l1ddr_rw_confilicts;

    reg [2:0]   l1cache_read_8addr_dl;
    reg         ddr_base_addr_inc;
    reg         ddr_base_addr_dec;

    reg         ddr_operate_enable;
    reg         ddr_rw;

    parameter
        L2_DDR_SM_IDLE          = 3'h0,
        L2_DDR_SM_REQUEST_READ  = 3'h1,
        L2_DDR_SM_READDING      = 3'h2,
        L2_DDR_SM_REQUEST_WRITE = 3'h3,
        L2_DDR_SM_WRITTING      = 3'h4;

    reg [2:0]   curr_state;
    reg [2:0]   next_state;

    always @(posedge clk_166M66 or negedge mcu_sys_rst_n) begin
        if (!mcu_sys_rst_n) begin
            curr_state <= L2_DDR_SM_IDLE;
            next_state <= L2_DDR_SM_IDLE;
        end else
            curr_state <= next_state;
    end

    always @(*) begin
        case (curr_state)
            L2_DDR_SM_IDLE: begin
                if (i_l2_ddr_operate_lock)
                    next_state = L2_DDR_SM_IDLE;
                else if (l2cache_unread_size[11:3] < 9'h1FF)
                    next_state = L2_DDR_SM_REQUEST_READ;
                else if (i_l2_ddr_force_loading)
                    next_state = L2_DDR_SM_REQUEST_READ;
                    // need read?
                else
                    next_state = L2_DDR_SM_IDLE;
            end
            L2_DDR_SM_REQUEST_READ: begin
                if (i_l2_ddr_bus_enable)
                    next_state = L2_DDR_SM_READDING;
                else
                    next_state = L2_DDR_SM_REQUEST_READ;
            end
            L2_DDR_SM_READDING: begin
                if (!i_l2_ddr_bus_enable)
                    next_state = L2_DDR_SM_IDLE;
                else
                    next_state = L2_DDR_SM_READDING;
            end
        endcase
    end

    always @(*) begin
        case (curr_state)
            L2_DDR_SM_IDLE: begin
                ddr_operate_enable = 1'b0;
                ddr_rw = 1'b0;
            end
            L2_DDR_SM_REQUEST_READ: begin
                ddr_operate_enable = 1'b1;
                ddr_rw = 1'b0;
            end
            L2_DDR_SM_READDING: begin
                ddr_operate_enable = 1'b1;
                ddr_rw = 1'b0;
            end
        endcase
    end

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
        if (l1cache_read_8addr_dl - l1cache_operating_address[5:3] == 3'h7) begin
            ddr_base_addr_dec = 1'b1;
            ddr_base_addr_inc = 1'b0;
        end else if (l1cache_operating_address[5:3] - l1cache_read_8addr_dl == 3'h7) begin
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
        if (i_l2_ddr_bus_enable && o_l2_ddr_operate_enable && write_ddr_data_en && !o_l2_ddr_rw)
            ddr_operating_address <= ddr_operating_address - 9'h1;
        if (i_l2_ddr_bus_enable && o_l2_ddr_operate_enable && o_l2_ddr_rw)
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
        enb         (o_l2_ddr_operate_enable && i_l2_ddr_bus_enable && write_ddr_data_en),
        web         (!o_l2_ddr_rw),
        addrb       (ddr_operating_address),
        dinb        (ddr_write_bus),
        doutb       (ddr_read_bus)
    );

    assign  o_l2_unread_size = l2cache_unread_size;
    assign  o_l1ddr_rw_confilicts = l1ddr_rw_confilicts;
    assign  o_l2_ddr_operate_enable = ddr_operate_enable;
    assign  o_l2_ddr_rw = ddr_rw;
endmodule