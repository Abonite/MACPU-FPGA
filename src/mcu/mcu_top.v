module mcu_top #(
    parameter BURST_LENTH = 8,

    parameter DDR_PHY_ADDRBUS_WIDTH = 14,
    parameter DDR_PHY_DATABUS_WIDTH = 16,
    parameter DDR_PHY_BANKBUS_WIDTH = 3
)
(
    input                                       clk_333M,
    input                                       clk_166M66,
    input                                       clk_170M,
    input                                       clk_200M,

    input                                       mcu_sys_rst_n,
    // DDR PHY INTERFACE
    output  [DDR_PHY_DATABUS_WIDTH - 1:0]       o_ddr3_addr,
    output  [DDR_PHY_BANKBUS_WIDTH:0]           o_ddr3_ba,
    output                                      o_ddr3_ras_n,
    output                                      o_ddr3_cas_n,
    output                                      o_ddr3_we_n,
    output                                      o_ddr3_ck_n,
    output                                      o_ddr3_ck_p,
    output                                      o_ddr3_cke,
    output                                      o_ddr3_reset_n,
    inout   [DDR_PHY_DATABUS_WIDTH:0]           io_ddr3_dq,
    inout   [(DDR_PHY_DATABUS_WIDTH / 8) - 1:0] io_ddr3_dqs_n,
    inout   [(DDR_PHY_DATABUS_WIDTH / 8) - 1:0] io_ddr3_dqs_p,
    output                                      o_ddr3_cs_n,
    output  [(DDR_PHY_DATABUS_WIDTH / 8) - 1:0] o_ddr3_dm,
    output                                      o_ddr3_odt,

    output                                      o_init_calib_complete
);

    // ROM:                         0x0000_0000 -> 0x0000_0FFF,         4k x 16bit
    // program segments cache(psc): bram    256 x 48bit
    // data segment cache(dsc):     dram    256 x 8bit 128 x 16bit
    // L2 cache:                    bram    4096 x 16bit 512 x 128bit
    // DDR:                         0x1000_0000 -> 0x1800_0000,         128M x 16bit

    // Currently, the real address offset read by the cpu core
    reg [31:0]  curr_core_read_offset_addr;

    // Currently, the starting offset of the data stored in each
    // cache in the real address
    reg [31:0]  curr_pcps_offset_addr;
    reg [31:0]  curr_dsc_offset_addr;

    // How much data has been read from the memory this time (16bit)
    reg     [8:0]   cache_data_amount;

    wire    [127:0] ddr_to_l2_data;
    wire    [127:0] l2_to_ddr_data;

    wire            ddr_rd_data_end;
    wire            ddr_rd_data_vld;

    wire    [11:0]  l2_unread_size;
    wire            l1ddr_rw_confilicts;
    wire            ddr_base_addr_inc;
    wire            ddr_base_addr_dec;

    reg             l2_ddr_op_en;
    reg             l2_ddr_rw;

    reg     [27:0]  ddr_op_addr;
    reg     [2:0]   ddr_op_cmd;
    reg             ddr_op_en;

    wire            ddr_ready;

    L2_cache u_l2_cache (
        .clk_166M66                 (clk_166M66),
        .mcu_sys_rst_n              (mcu_sys_rst_n),

        .o_l2_unread_size           (l2_unread_size),
        .o_l1ddr_rw_confilicts      (l1ddr_rw_confilicts),
        .o_ddr_base_addr_inc        (ddr_base_addr_inc),
        .o_ddr_base_addr_dec        (ddr_base_addr_dec),


        .i_l1_burst_address         (),
        .i_l1_burst_address_enable  (),
        .i_l1_operate_enable        (),
        .i_l1_rw                    (),
        .io_l1_data_bus             (),

        .i_l2_ddr_operate_lock      (),
        .i_l2_ddr_force_loading     (),
        .i_l2_ddr_bus_enable        (),
        .o_l2_ddr_operate_enable    (),
        .o_l2_ddr_rw                (),
        .io_l2_ddr_data_bus         ()
    );

    reg [2:0]   curr_state;
    reg [2:0]   next_state;

    reg [27:0]  ddr_base_addr;

    parameter
        IDLE                    = 3'h0,
        INIT_L2                 = 3'h1,
        INIT_L1DFC              = 3'h2,
        WAIT_SPACE_IN_L2_L1DFC  = 3'h3,
        LOAD_INTO_L2            = 3'h4,
        LOAD_INTO_DFC           = 3'h5,
        WRITE_L2_INTO_DDR       = 3'h6,
        WRITE_L1DFC_INTO_DDR    = 3'h7;

    // DDR STATE MACHEN
    always @(posedge clk_166M66 or negedge mcu_sys_rst_n) begin
        if (!mcu_sys_rst_n || !ddr_ready) begin
            curr_state <= IDLE;
            next_state <= IDLE;
        end else
            curr_state <= next_state;
    end

    ddr3_with_controller u_ddr3_w_c (
        .clk_333M                       (),
        .clk_166M66                     (),
        .clk_200M                       (),

        .mcu_sys_rst_n                  (),
    // DDR PHY INTERFACE
        // ddr3 physical address, output, 14bit
        .ddr3_addr                      (o_ddr3_addr),
        // ddr3 physical bank address, output, 3bit
        .ddr3_ba                        (o_ddr3_ba),
        // command lines, output
        .ddr3_ras_n                     (o_ddr3_ras_n),
        .ddr3_cas_n                     (o_ddr3_cas_n),
        .ddr3_we_n                      (o_ddr3_we_n),
        // clock, output
        .ddr3_ck_n                      (o_ddr3_ck_n),
        .ddr3_ck_p                      (o_ddr3_ck_p),
        // clock enable, output
        .ddr3_cke                       (o_ddr3_cke),
        // reset, output
        .ddr3_reset_n                   (o_ddr3_reset_n),
        // ddr3 physical data, inout, 16bit
        .ddr3_dq                        (io_ddr3_dq),
        // data strobe, inout, 2bit each
        .ddr3_dqs_n                     (io_ddr3_dqs_n),
        .ddr3_dqs_p                     (io_ddr3_dqs_p),
        //
        .init_calib_complete            (o_init_calib_complete),
        .ddr3_cs_n                      (o_ddr3_cs_n),
        // data mask
        .ddr3_dm                        (o_ddr3_dm),
        .ddr3_odt                       (o_ddr3_odt),
    // USER INTERFACE
        .i_address_bus                  (),
        .i_address_enable               (),

        .io_data_bus                    (),
        .i_data_enable                  (),

        .i_psc_rw                       (),
        .i_psc_request                  (),
        .o_psc_bus_available            (),

        .i_dsc_rw                       (),
        .i_dsc_request                  (),
        .o_dsc_bus_available            (),

        .i_l2_rw                        (),
        .i_l2_request                   (),
        .o_l2_bus_available             ()
    );

endmodule