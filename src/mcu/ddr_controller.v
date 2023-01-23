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
    input                                       i_address_enable,

    inout   [127:0]                             io_data_bus,

    input                                       i_psc_rw,
    input                                       i_psc_request,
    output                                      o_psc_bus_available,
    input                                       i_dsc_rw,
    input                                       i_dsc_request,
    output                                      o_dsc_bus_available,
    input                                       i_l2_rw,
    input                                       i_l2_request,
    output                                      o_l2_bus_available,

    output                                      o_busy
);

    wire [127:0]    app_rd_data;
    wire [127:0]    app_wdf_data;
    wire            ddr_rdfifo_full;
    wire            ddr_rdfifo_empty;

    reg         psc_rw;
    reg         dsc_rw;
    reg         l2_rw;

    parameter
        NONE = 2'h0,
        PSC = 2'h1,
        DSC = 2'h2,
        L2 = 2'h3;

    reg [1:0]   requestting;

    always @(*) begin
        if (i_psc_request) begin
            psc_rw = i_psc_rw;
            requestting = PSC;
        end else if (i_dsc_request) begin
            dsc_rw = i_dsc_rw;
            requestting = DSC;
        end else if (i_l2_request) begin
            l2_rw = i_l2_rw;
            requestting = L2;
        end
    end

    reg [2:0]   rw_counter;

    reg         busy;

    parameter
        DDR_SM_IDLE         = 3'h0,
        DDR_SM_PSC_READ     = 3'h1,
        DDR_SM_PSC_WRITE    = 3'h2,
        DDR_SM_DSC_READ     = 3'h3,
        DDR_SM_DSC_WRITE    = 3'h4,
        DDR_SM_L2_READ      = 3'h5,
        DDR_SM_L2_WRITE     = 3'h6,
        DDR_SM_NEW_REQUEST  = 3'h7;

    reg [1:0]   ddr_curr_state;
    reg [1:0]   ddr_next_state;

    always @(posedge clk_166M66) begin
        if (!mcu_sys_rst_n) begin
            ddr_curr_state <= DDR_SM_IDLE;
            ddr_next_state <= DDR_SM_IDLE;
        end else
            ddr_curr_state <= ddr_next_state;
    end

    always @(*) begin
        case (ddr_curr_state)
            DDR_SM_IDLE: begin
                if (i_psc_request && !i_psc_rw)
                    ddr_next_state = DDR_SM_PSC_READ;
                else if (i_psc_request && i_psc_rw)
                    ddr_next_state = DDR_SM_PSC_WRITE;
                else if (i_dsc_request && !i_dsc_rw)
                    ddr_next_state = DDR_SM_DSC_READ;
                else if (i_dsc_request && i_dsc_rw)
                    ddr_next_state = DDR_SM_DSC_WRITE;
                else if (i_l2_request && !i_l2_rw)
                    ddr_next_state = DDR_SM_L2_WRITE;
                else if (i_l2_request && i_l2_rw)
                    ddr_next_state = DDR_SM_L2_WRITE;
                else
                    ddr_next_state = DDR_SM_IDLE;
            end
            DDR_SM_PSC_READ: begin
                if (i_psc_request && !i_dsc_rw)
                    ddr_next_state = DDR_SM_PSC_READ;
                else if (!i_psc_request && !i_dsc_request && !i_l2_request)
                    ddr_next_state = DDR_SM_PSC_READ;
                else
                    ddr_next_state = DDR_SM_NEW_REQUEST;
            end
            DDR_SM_PSC_WRITE: begin
                if (i_psc_request && i_dsc_rw)
                    ddr_next_state = DDR_SM_PSC_READ;
                else if (!i_psc_request && !i_dsc_request && !i_l2_request)
                    ddr_next_state = DDR_SM_PSC_READ;
                else
                    ddr_next_state = DDR_SM_NEW_REQUEST;
            end
            DDR_SM_NEW_REQUEST: begin
                if (rw_counter != 3'h4)
                    rw_counter = rw_counter + 3'h1;
                else if (requestting == NONE)
                    ddr_next_state = DDR_SM_IDLE;
                else if ((requestting == PSC) && (!psc_rw))
                    ddr_next_state = DDR_SM_PSC_READ;
                else if ((requestting == PSC) && (psc_rw))
                    ddr_next_state = DDR_SM_PSC_WRITE;
                else if ((requestting == DSC) && (!dsc_rw))
                    ddr_next_state = DDR_SM_DSC_READ;
                else if ((requestting == DSC) && (dsc_rw))
                    ddr_next_state = DDR_SM_DSC_WRITE;
                else if ((requestting == L2) && (!l2_rw))
                    ddr_next_state = DDR_SM_L2_READ;
                else if ((requestting == L2) && (l2_rw))
                    ddr_next_state = DDR_SM_L2_WRITE;
                else
                    ddr_next_state = DDR_SM_IDLE;
            end
        endcase
    end

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