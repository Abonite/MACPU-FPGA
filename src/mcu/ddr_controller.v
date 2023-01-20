module ddr3 #(
    parameter BURST_LENTH = 8,

    parameter DDR_PHY_ADDRBUS_WIDTH = 14,
    parameter DDR_PHY_DATABUS_WIDTH = 16,
    parameter DDR_PHY_BANKBUS_WIDTH = 3
)
(
    input                                       clk_333M,
    input                                       clk_166M66,
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

    output                                      o_init_calib_complete,

    // USER INTERFACE
    input   [27:0]                              i_address_bus,
    input                                       i_rw,
    inout   [127:0]                             io_data_bus
);

    wire [127:0]    app_rd_data;
    wire [127:0]    app_wdf_data;
    wire            ddr_rdfifo_full;
    wire            ddr_rdfifo_empty;

    // TODO: How to determine the clock frequency about din and dout
    // Does MCU and DDR need to work at the same frequency?
    // Does the CPU need to work at the same frequency as the MCU?

    // TODO: May be we can use this fifo as a cache
    // if the fifo is empty, or almost empty, send a signal to mcu
    // then mcu will judge weather read ddr data into fifo
    // when fifo is not empty, if mcu need to refresh fifo now
    // then reset fifo and read data from new address

    fifo_bram_128x16to16x128 u_ddr_read_fifo (
        rst         (reset_fifo),
        wr_clk      (clk_166M66),
        rd_clk      (),
        din         (app_rd_data),
        wr_en       (app_rd_data_valid & (~ddr_rd_fifo_full)),
        rd_en       (),
        dout        (),
        full        (ddr_rdfifo_full),
        wr_ack      (),
        empty       (ddr_rdfifo_empty),
        valid       ()
    );

    mig_7series_0 u_ddr3_controller (
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

        // Application interface ports
        // BRC 28bit, input
        .app_addr                       (i_addr_bus),
        // 0: write; 1: read. 3bit, input
        .app_cmd                        ({2'b0, ~i_rw}),
        // cmd is enable, input
        .app_en                         (app_en),
        // write data, 16 x 8 = 128bit, input
        .app_wdf_data                   (app_wdf_data),
        .app_wdf_end                    (app_wdf_end),
        .app_wdf_wren                   (app_wdf_wren),
        // write data mask, 2bit, input
        .app_wdf_mask                   (app_wdf_mask),
        // read data, 16 x 8 = 128bit, output
        .app_rd_data                    (app_rd_data),
        .app_rd_data_end                (app_rd_data_end),
        .app_rd_data_valid              (app_rd_data_valid),
        // DDR controller is ready to read or write data
        .app_rdy                        (app_rdy),
        // write fifo is ready to get data, output
        .app_wdf_rdy                    (app_wdf_rdy),
        // request an immediate refresh operation, input
        .app_ref_req                    (),
        // refresh operation has been sent to the DDR chip, output
        .app_ref_ack                    (),
        // request an immediate ZQ calibration operation, input
        .app_zq_req                     (),
        // ZQ calibration operation sent to DDR chip, output
        .app_zq_ack                     (),
        // 166.6MHz
        .ui_clk                         (clk_166M66),
        .ui_clk_sync_rst                (mcu_sys_rst_n),
        // System Clock Ports
        .sys_clk_i                      (clk_333M),
        .sys_rst                        (mcu_sys_rst_n),
        // Reference Clock Ports
        .clk_ref_i                      (clk_200M),
        // temperature
        .device_temp_i                  (),
        .app_sr_req                     (),
        .app_sr_active                  ()
    );

endmodule