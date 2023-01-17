module ddr3 (
    input       i_write_data
);

    `ifdef SKIP_CALIB
        wire    calib_tap_req;
        wire    calib_tap_load;
        wire    calib_tap_addr;
        wire    calib_tap_val;
        wire    calib_tap_load_done;
    `endif

    mig_7series_0_mig u_ddr3_controller (
        .ddr3_addr                      (ddr3_addr),
        .ddr3_ba                        (ddr3_ba),
        .ddr3_cas_n                     (ddr3_cas_n),
        .ddr3_ck_n                      (ddr3_ck_n),
        .ddr3_ck_p                      (ddr3_ck_p),
        .ddr3_cke                       (ddr3_cke),
        .ddr3_ras_n                     (ddr3_ras_n),
        .ddr3_reset_n                   (ddr3_reset_n),
        .ddr3_we_n                      (ddr3_we_n),
        .ddr3_dq                        (ddr3_dq),
        .ddr3_dqs_n                     (ddr3_dqs_n),
        .ddr3_dqs_p                     (ddr3_dqs_p),
        .init_calib_complete            (init_calib_complete),
        .ddr3_cs_n                      (ddr3_cs_n),
        .ddr3_dm                        (ddr3_dm),
        .ddr3_odt                       (ddr3_odt),
        // Application interface ports
        .app_addr                       (app_addr),
        .app_cmd                        (app_cmd),
        .app_en                         (app_en),
        .app_wdf_data                   (app_wdf_data),
        .app_wdf_end                    (app_wdf_end),
        .app_wdf_wren                   (app_wdf_wren),
        .app_rd_data                    (app_rd_data),
        .app_rd_data_end                (app_rd_data_end),
        .app_rd_data_valid              (app_rd_data_valid),
        .app_rdy                        (app_rdy),
        .app_wdf_rdy                    (app_wdf_rdy),
        .app_sr_req                     (app_sr_req),
        .app_ref_req                    (app_ref_req),
        .app_zq_req                     (app_zq_req),
        .app_sr_active                  (app_sr_active),
        .app_ref_ack                    (app_ref_ack),
        .app_zq_ack                     (app_zq_ack),
        .ui_clk                         (ui_clk),
        .ui_clk_sync_rst                (ui_clk_sync_rst),
        .app_wdf_mask                   (app_wdf_mask),
        // System Clock Ports
        .sys_clk_i                      (sys_clk_i),
        // Reference Clock Ports
        .clk_ref_i                      (clk_ref_i),
        .device_temp                    (device_temp),
        `ifdef SKIP_CALIB
            .calib_tap_req              (calib_tap_req),
            .calib_tap_load             (calib_tap_load),
            .calib_tap_addr             (calib_tap_addr),
            .calib_tap_val              (calib_tap_val),
            .calib_tap_load_done        (calib_tap_load_done),
        `endif
        .sys_rst                        (sys_rst)
        );
endmodule