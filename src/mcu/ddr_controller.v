module ddr3 (
    // DDR PHY INTERFACE
    output  [13:0]  o_ddr3_addr,
    output  [2:0]   o_ddr3_ba,
    output          o_ddr3_ras_n,
    output          o_ddr3_cas_n,
    output          o_ddr3_we_n,
    output          o_ddr3_ck_n,
    output          o_ddr3_ck_p,
    output          o_ddr3_cke,
    output          o_ddr3_reset_n,
    inout   [15:0]  io_ddr3_dq,
    inout   [1:0]   io_ddr3_dqs_n,
    inout   [1:0]   io_ddr3_dqs_p,
    output          o_ddr3_cs_n,
    output  [1:0]   o_ddr3_dm,
    output          o_ddr3_odt,

    output          o_init_calib_complete,

    input   [27:0]  i_request_address_bus,
    input           i_address_enable,

    input   [127:0] i_data_bus,
    output  [127:0] o_data_bus
);

    localparam BURST_LENTH = 8;

    localparam DDR_PHY_ADDRBUS_WIDTH = 14;
    localparam DDR_PHY_DATABUS_WIDTH = 16;
    localparam DDR_PHY_BANKBUS_WIDTH = 3;

    `ifdef SKIP_CALIB
        wire    calib_tap_req;
        wire    calib_tap_load;
        wire    calib_tap_addr;
        wire    calib_tap_val;
        wire    calib_tap_load_done;
    `endif

    fifo_generator_0 u_ddr3_read_fifo(
        clk,
        rst,
        din,
        wr_en,
        rd_en,
        dout,
        full,
        empty
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
        .app_addr                       (app_addr),
        // 0: write; 1: read. 3bit, input
        .app_cmd                        (app_cmd),
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
        .app_ref_req                    (app_ref_req),
        // refresh operation has been sent to the DDR chip, output
        .app_ref_ack                    (app_ref_ack),
        // request an immediate ZQ calibration operation, input
        .app_zq_req                     (app_zq_req),
        // ZQ calibration operation sent to DDR chip, output
        .app_zq_ack                     (app_zq_ack),
        // 166.6MHz
        .ui_clk                         (ui_clk),
        .ui_clk_sync_rst                (ui_clk_sync_rst),
        // System Clock Ports
        .sys_clk_i                      (sys_clk_i),
        .sys_rst                        (sys_rst),
        // Reference Clock Ports
        .clk_ref_i                      (clk_ref_i),
        // temperature
        .device_temp_i                  (device_temp),
        `ifdef SKIP_CALIB
            .calib_tap_req              (calib_tap_req),
            .calib_tap_load             (calib_tap_load),
            .calib_tap_addr             (calib_tap_addr),
            .calib_tap_val              (calib_tap_val),
            .calib_tap_load_done        (calib_tap_load_done),
        `endif
        .app_sr_req                     (app_sr_req),
        .app_sr_active                  (app_sr_active)
        );
endmodule