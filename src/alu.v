module alu (
    input   wire            n_rst,

    input   wire            io_data,

    input   wire            i_reg_io,
    input   wire            i_reg_io_enable,
    input   wire            i_input_type,
    input   wire    [4:0]   i_1st_alu_reg_selector,
    input   wire    [4:0]   i_2nd_alu_reg_selector,
    input   wire    [7:0]   i_alu_operate,

    output  wire    [63:0]  o_reg_data,
    output  wire    [15:0]  o_flag
    );

    wire    data_in_temp;

    reg     data;
    wire    data_out;
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin

        end
    endgenerate

    reg [15:0]  A, B, C, D, E, F, SS, SP;

    parameter
        LOAD    = 8'h0,
        ADD     = 8'h1,
        SUB     = 8'h2,
        AND     = 8'h3,
        OR      = 8'h4,
        NOT     = 8'h5,
        XOR     = 8'h6,
        RAND    = 8'h7,
        ROR     = 8'h8,
        RXOR    = 8'h9,
        LSL     = 8'hA,
        LSR     = 8'hB,
        ASL     = 8'hC,
        ASR     = 8'hD,
        CSL     = 8'hE,
        CSR     = 8'hF,
        INC     = 8'h10,
        DEC     = 8'h11,
        MOV_RR  = 8'hFF;

    parameter
        RA = 4'h0,
        RB = 4'h1,
        RC = 4'h2,
        RD = 4'h3,
        RE = 4'h4,
        RF = 4'h5,
        RSS = 4'h6,
        RSP = 4'h7;

    wire oa, ob, oc, od, oe, of;

    always @(negedge n_rst) begin
        if (!n_rst) begin
            A <= 16'b0;
            B <= 16'b0;
            C <= 16'b0;
            D <= 16'b0;
            E <= 16'b0;
            F <= 16'b0;
            SS <= 16'b0;
            SP <= 16'b0;
        end
    end

    always @(*) begin
        case (i_alu_operate)
            LOAD: begin
                
            end
        endcase
    end

    assign o_reg_data = {D, C, B, A};

endmodule