module controller (
    input   wire            clk,
    input   wire            n_rst,

    input   wire    [15:0]  i_data_bus,
    output  wire    [15:0]  o_interrupt_address,

    input   wire            i_inta,
    input   wire            i_intb,

    input   wire    [15:0]  i_flag,

    input   wire    [1:0]   i_io_control_code,
    input   wire    [2:0]   i_pc_control_code,
    input   wire    [3:0]   i_dc_control_code,
    input   wire    [12:0]  i_ct_control_code,
    input   wire    [18:0]  i_alu_control_code,

    output  wire            o_rw,
    output  wire            o_lock_io,
    // TODO: inta and intb enable need output?
    //  - I think no
    //  - deleted

    output  wire            o_decoder_data_enable,
    output  wire            o_decoder_data_io,
    output  wire            o_decoder_address_output,
    output  wire            o_decoder_lock,
    output  wire            o_decoder_interrupt,

    output  wire            o_pc_set_enable,
    output  wire            o_pc_address_enable,
    output  wire            o_pc_lock,

    output  wire            o_alu_reg_io,
    output  wire            o_alu_reg_io_enable,
    output  wire            o_alu_reg_dc_enable,
    output  wire    [4:0]   o_1st_alu_reg_selector,
    output  wire    [4:0]   o_2nd_alu_reg_selector,
    output  wire    [7:0]   o_alu_operate,

    output  wire            o_interrupt_enable,
    output  wire            o_recovery_enable
    );

    reg [15:0]  inta_address    =   16'hFDA9;
    reg [15:0]  intb_address    =   16'hFB53;

    reg [15:0]  soft_int_address    =   16'h0000;

    wire    [15:0]  inta_address_o;
    wire    [15:0]  intb_address_o;

    assign inta_address_o = inta_address;
    assign intb_address_o = intb_address;

    reg         inta_enable     =   1'b1;
    reg         intb_enable     =   1'b1;
    reg         int_priority    =   1'b0;

    reg [1:0]   privilege_level =   2'b00;

    reg [1:0]   inta_dl;
    reg [1:0]   intb_dl;
    wire        inta;
    wire        intb;

    always @(*) begin
        inta_dl[0] = i_inta & inta_enable;
        intb_dl[0] = i_intb & intb_enable;
    end

    always @(posedge clk) begin
        inta_dl[1] <= inta_dl[0];
        intb_dl[1] <= intb_dl[0];
    end

    assign inta = inta_dl[0] && !inta_dl[1];
    assign intb = intb_dl[0] && !intb_dl[1];

    always @(negedge n_rst) begin
        if (!n_rst) begin
            inta_address    =   16'hFDA9;
            intb_address    =   16'hFB53;
            inta_enable     =   1'b1;
            intb_enable     =   1'b1;
            int_priority    =   1'b0;
            inta_dl         =   2'b0;
            intb_dl         =   2'b0;
        end
    end

    // io control
    reg             rw;
    reg             lock_io;

    // programm counter control
    reg             pc_set_enable;
    reg             pc_address_enable;
    reg             pc_recovery_enable;
    reg             pc_lock;

    // decoder control
    reg             decoder_data_enable;
    reg             decoder_data_io;
    reg             decoder_lock;
    reg             decoder_address_output;

    // alu control
    reg             alu_reg_io;
    reg             alu_reg_io_enable;
    reg             alu_reg_dc_enable;
    reg [4:0]       alu_1st_reg_selector;
    reg [4:0]       alu_2nd_reg_selector;
    reg [7:0]       alu_operate;

    reg             interrupt_enable;
    reg             recovery_enable;

    always @(*) begin
        rw = i_io_control_code[0];
        lock_io = i_io_control_code[1];
    end

    always @(*) begin
        pc_set_enable = i_pc_control_code[0];
        pc_address_enable = i_pc_control_code[1];
        pc_lock = i_pc_control_code[2];
    end

    always @(*) begin
        decoder_data_io = i_dc_control_code[0];
        decoder_data_enable = i_dc_control_code[1];
        decoder_address_output = i_dc_control_code[2];
        decoder_lock = i_dc_control_code[3];
    end

    always @(*) begin
        if (i_ct_control_code[3]) begin
            inta_enable = i_ct_control_code[0];
            intb_enable = i_ct_control_code[1];
            int_priority = i_ct_control_code[2];
        end else begin
            inta_enable = inta_enable;
            intb_enable = intb_enable;
            int_priority = int_priority;
        end
    end

    always @(*) begin
        if (i_ct_control_code[5:4] == 2'b00) begin
            inta_address = inta_address;
            intb_address = intb_address;
        end else if (i_ct_control_code[5:4] == 2'b01) begin
            inta_address = i_data_bus;
            intb_address = intb_address;
        end else if (i_ct_control_code[5:4] == 2'b10) begin
            inta_address = inta_address;
            intb_address = i_data_bus;
        end else begin
            inta_address = 16'hFDA9;
            intb_address = 16'hFB53;
        end
    end

    always @(*) begin
        if (i_ct_control_code[6]) begin
            case (i_ct_control_code[11:7])
                5'h0:   soft_int_address = 16'd29;
            endcase
        end else begin
            soft_int_address = 16'h0000;
        end
    end

    always @(*) begin
        recovery_enable = i_ct_control_code[12];
    end

    always @(*) begin
        alu_reg_io = i_alu_control_code[0];
        alu_reg_io_enable = i_alu_control_code[1];
        alu_reg_dc_enable = i_alu_control_code[2];
        alu_1st_reg_selector = i_alu_control_code[6:3];
        alu_2nd_reg_selector = i_alu_control_code[10:7];
        alu_operate = i_alu_control_code[18:11];
    end

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif1  inta_addr_buf       (o_interrupt_address[i], inta_address[i], ((~int_priority & inta) | (inta & ~intb)));
            bufif1  intb_addr_buf       (o_interrupt_address[i], intb_address[i], ((~inta & intb) | (int_priority & intb)));
            bufif1  soft_int_addr_buf   (o_interrupt_address[i], soft_int_address[i], !((~int_priority & inta) | (inta & ~intb)) && !((~inta & intb) | (int_priority & intb)) && i_ct_control_code[6]);
            bufif1  noint_addr_buf      (o_interrupt_address[i], 1'b0, !((~int_priority & inta) | (inta & ~intb)) && !((~inta & intb) | (int_priority & intb)) && !i_ct_control_code[6]);
        end
    endgenerate

    always @(*) begin
        if ((~int_priority & inta) | (inta & ~intb))
            interrupt_enable = 1'b1;
        else if ((~inta & intb) | (int_priority & intb))
            interrupt_enable = 1'b1;
        else if (i_ct_control_code[6])
            interrupt_enable = 1'b1;
        else
            interrupt_enable = 1'b0;
    end

    assign o_rw = rw;
    assign o_lock_io = lock_io;

    assign o_decoder_data_enable = decoder_data_enable;
    assign o_decoder_data_io = decoder_data_io;
    assign o_decoder_address_output = decoder_address_output;
    assign o_decoder_lock = decoder_lock;
    assign o_decoder_interrupt = (!inta && !intb) ? 1'b0 : 1'b1;

    assign o_pc_set_enable = pc_set_enable || ((!inta && !intb) ? 1'b0 : 1'b1);
    assign o_pc_address_enable = pc_address_enable;
    assign o_pc_lock = pc_lock;

    assign o_alu_reg_io = alu_reg_io;
    assign o_alu_reg_io_enable = alu_reg_io_enable;
    assign o_alu_reg_dc_enable = alu_reg_dc_enable;
    assign o_1st_alu_reg_selector = alu_1st_reg_selector;
    assign o_2nd_alu_reg_selector = alu_2nd_reg_selector;
    assign o_alu_operate = alu_operate;

    assign o_interrupt_enable = interrupt_enable;
    assign o_recovery_enable = recovery_enable;
endmodule