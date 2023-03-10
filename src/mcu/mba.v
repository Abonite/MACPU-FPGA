/// In any case, it should be guaranteed that the request received by the arbiter
/// has been kept for at least two clock cycles. After two clock cycles, the
/// request signal can be released and the request will be recorded.

`define DEBUG 1

///memory bus arbiter
module mba (
    input   clk_166M66,
    input   mcu_sys_rst_n,

    output  o_data_bus_rw,
    output  o_data_bus_enable,

    input   i_status_bus_transmitting,

    input   i_l2_requesting,
    input   i_l2_rw,
    output  o_l2_allow,

    input   i_dsc_requesting,
    input   i_dsc_rw,
    output  o_dsc_allow
);

    reg l2_allow;
    reg dsc_allow;

    reg rw;
    reg io_en;

    reg [1:0]   counter;
    reg         counting;

    always @(posedge clk_166M66 or negedge mcu_sys_rst_n) begin
        if (!mcu_sys_rst_n || !counting)
            counter <= 2'h0;
        else if (counting)
            counter <= counter + 2'h1;
        else
            counter <= counter;
    end

    reg [3:0]   curr_state;
    reg [3:0]   next_state;

    parameter
        IDLE           = 4'h0,
        L2_READING     = 4'h1,
        L2_WRITING     = 4'h2,
        DSC_READING    = 4'h3,
        DSC_WRITING    = 4'h4,
        NR_L2_READING  = 4'h5,
        NR_L2_WRITING  = 4'h6,
        NR_DSC_READING = 4'h7,
        NR_DSC_WRITING = 4'h8,
        NR_IDLE        = 4'h9;

    always @(posedge clk_166M66 or mcu_sys_rst_n) begin
        if (!mcu_sys_rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    always @(*) begin
        case (curr_state)
            IDLE: begin
                if (i_dsc_requesting && i_l2_requesting && !i_dsc_rw)
                    next_state = DSC_READING;
                else if (i_dsc_requesting && i_l2_requesting && i_dsc_rw)
                    next_state = DSC_WRITING;
                else if (i_dsc_requesting && !i_l2_requesting && !i_dsc_rw)
                    next_state = DSC_READING;
                else if (i_dsc_requesting && !i_l2_requesting && i_dsc_rw)
                    next_state = DSC_WRITING;
                else if (!i_dsc_requesting && i_l2_requesting && !i_l2_rw)
                    next_state = L2_READING;
                else if (!i_dsc_requesting && i_l2_requesting && i_l2_rw)
                    next_state = L2_WRITING;
                else
                    next_state = IDLE;
            end
            L2_READING: begin
                if (i_dsc_requesting && i_l2_requesting && !i_dsc_rw)
                    next_state = NR_DSC_READING;
                else if (i_dsc_requesting && i_l2_requesting && i_dsc_rw)
                    next_state = NR_DSC_WRITING;
                else if (i_dsc_requesting && !i_l2_requesting && !i_dsc_rw)
                    next_state = NR_DSC_READING;
                else if (i_dsc_requesting && !i_l2_requesting && i_dsc_rw)
                    next_state = NR_DSC_WRITING;
                else if (!i_dsc_requesting && i_l2_requesting && !i_l2_rw)
                    next_state = L2_READING;
                else if (!i_dsc_requesting && i_l2_requesting && i_l2_rw)
                    next_state = NR_L2_WRITING;
                else
                    next_state = NR_IDLE;
            end
            L2_WRITING: begin
                if (i_dsc_requesting && i_l2_requesting && !i_dsc_rw)
                    next_state = NR_DSC_READING;
                else if (i_dsc_requesting && i_l2_requesting && i_dsc_rw)
                    next_state = NR_DSC_WRITING;
                else if (i_dsc_requesting && !i_l2_requesting && !i_dsc_rw)
                    next_state = NR_DSC_READING;
                else if (i_dsc_requesting && !i_l2_requesting && i_dsc_rw)
                    next_state = NR_DSC_WRITING;
                else if (!i_dsc_requesting && i_l2_requesting && !i_l2_rw)
                    next_state = NR_L2_READING;
                else if (!i_dsc_requesting && i_l2_requesting && i_l2_rw)
                    next_state = L2_WRITING;
                else
                    next_state = NR_IDLE;
            end
            DSC_READING: begin
                if (i_dsc_requesting && i_l2_requesting && !i_dsc_rw)
                    next_state = DSC_READING;
                else if (i_dsc_requesting && i_l2_requesting && i_dsc_rw)
                    next_state = NR_DSC_WRITING;
                else if (i_dsc_requesting && !i_l2_requesting && !i_dsc_rw)
                    next_state = DSC_READING;
                else if (i_dsc_requesting && !i_l2_requesting && i_dsc_rw)
                    next_state = NR_DSC_WRITING;
                else if (!i_dsc_requesting && i_l2_requesting && !i_l2_rw)
                    next_state = NR_L2_READING;
                else if (!i_dsc_requesting && i_l2_requesting && i_l2_rw)
                    next_state = NR_L2_WRITING;
                else
                    next_state = NR_IDLE;
            end
            DSC_WRITING: begin
                if (i_dsc_requesting && i_l2_requesting && !i_dsc_rw)
                    next_state = NR_DSC_READING;
                else if (i_dsc_requesting && i_l2_requesting && i_dsc_rw)
                    next_state = DSC_WRITING;
                else if (i_dsc_requesting && !i_l2_requesting && !i_dsc_rw)
                    next_state = NR_DSC_READING;
                else if (i_dsc_requesting && !i_l2_requesting && i_dsc_rw)
                    next_state = DSC_WRITING;
                else if (!i_dsc_requesting && i_l2_requesting && !i_l2_rw)
                    next_state = NR_L2_READING;
                else if (!i_dsc_requesting && i_l2_requesting && i_l2_rw)
                    next_state = NR_L2_WRITING;
                else
                    next_state = NR_IDLE;
            end
            NR_DSC_READING: begin
                if (counter == 2'h3)
                    next_state = DSC_READING;
                else if(!i_status_bus_transmitting)
                    next_state = DSC_READING;
                else
                    next_state = NR_DSC_READING;
            end
            NR_DSC_WRITING: begin
                if (counter == 2'h3)
                    next_state = DSC_WRITING;
                else if(!i_status_bus_transmitting)
                    next_state = DSC_WRITING;
                else
                    next_state = NR_DSC_WRITING;
            end
            NR_L2_READING: begin
                if (counter == 2'h3)
                    next_state = L2_READING;
                else if(!i_status_bus_transmitting)
                    next_state = L2_READING;
                else
                    next_state = NR_L2_READING;
            end
            NR_L2_WRITING: begin
                if (counter == 2'h3)
                    next_state = L2_WRITING;
                else if(!i_status_bus_transmitting)
                    next_state = L2_WRITING;
                else
                    next_state = NR_L2_WRITING;
            end
            NR_IDLE: begin
                if (counter == 2'h3)
                    next_state = IDLE;
                else if(!i_status_bus_transmitting)
                    next_state = IDLE;
                else
                    next_state = NR_IDLE;
            end
            default: next_state = IDLE; // error
        endcase
    end

    always @(*) begin
        case (curr_state)
            IDLE: begin
                l2_allow = 1'b0;
                dsc_allow = 1'b0;
                rw = 1'b0;
                io_en = 1'b0;
                counting = 1'b0;
            end
            L2_READING: begin
                l2_allow = 1'b1;
                dsc_allow = 1'b0;
                rw = 1'b0;
                io_en = 1'b1;
                counting = 1'b0;
            end
            L2_WRITING: begin
                l2_allow = 1'b1;
                dsc_allow = 1'b0;
                rw = 1'b1;
                io_en = 1'b1;
                counting = 1'b0;
            end
            DSC_READING: begin
                l2_allow = 1'b0;
                dsc_allow = 1'b1;
                rw = 1'b0;
                io_en = 1'b1;
                counting = 1'b0;
            end
            DSC_WRITING: begin
                l2_allow = 1'b0;
                dsc_allow = 1'b1;
                rw = 1'b1;
                io_en = 1'b1;
                counting = 1'b0;
            end
            NR_L2_READING: begin
                l2_allow = l2_allow;
                dsc_allow = dsc_allow;
                rw = rw;
                io_en = 1'b0;
                counting = 1'b1;
            end
            NR_L2_WRITING: begin
                l2_allow = l2_allow;
                dsc_allow = dsc_allow;
                rw = rw;
                io_en = 1'b0;
                counting = 1'b1;
            end
            NR_DSC_READING: begin
                l2_allow = l2_allow;
                dsc_allow = dsc_allow;
                rw = rw;
                io_en = 1'b0;
                counting = 1'b1;
            end
            NR_DSC_WRITING: begin
                l2_allow = l2_allow;
                dsc_allow = dsc_allow;
                rw = rw;
                io_en = 1'b0;
                counting = 1'b1;
            end
            NR_IDLE: begin
                l2_allow = l2_allow;
                dsc_allow = dsc_allow;
                rw = rw;
                io_en = io_en;
                counting = counting;
            end
        endcase
    end

    `ifdef DEBUG
        reg [119:0]   dbg_curr_state;
        reg [119:0]   dbg_next_state;

        always @(*) begin
            case (curr_state)
                IDLE: dbg_curr_state = "IDLE";
                L2_READING: dbg_curr_state = "L2_READING";
                L2_WRITING: dbg_curr_state = "L2_WRITING";
                DSC_READING: dbg_curr_state = "DSC_READING";
                DSC_WRITING: dbg_curr_state = "DSC_WRITING";
                NR_L2_READING: dbg_curr_state = "NR_L2_READING";
                NR_L2_WRITING: dbg_curr_state = "NR_L2_WRITING";
                NR_DSC_READING: dbg_curr_state = "NR_DSC_READING";
                NR_DSC_WRITING: dbg_curr_state = "NR_DSC_WRITING";
                NR_IDLE: dbg_curr_state = "NR_IDLE";
            endcase
        end

        always @(*) begin
            case (next_state)
                IDLE: dbg_next_state = "IDLE";
                L2_READING: dbg_next_state = "L2_READING";
                L2_WRITING: dbg_next_state = "L2_WRITING";
                DSC_READING: dbg_next_state = "DSC_READING";
                DSC_WRITING: dbg_next_state = "DSC_WRITING";
                NR_L2_READING: dbg_next_state = "NR_L2_READING";
                NR_L2_WRITING: dbg_next_state = "NR_L2_WRITING";
                NR_DSC_READING: dbg_next_state = "NR_DSC_READING";
                NR_DSC_WRITING: dbg_next_state = "NR_DSC_WRITING";
                NR_IDLE: dbg_next_state = "NR_IDLE";
            endcase
        end

        initial begin
            $dumpfile ("mba.vcd");
            $dumpvars (0, mba);
        end
    `endif


    assign o_data_bus_rw = rw;
    assign o_l2_allow = l2_allow;
    assign o_dsc_allow = dsc_allow;
    assign o_data_bus_enable = io_en;
endmodule
