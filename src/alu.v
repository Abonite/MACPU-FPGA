module alu (
    input           n_rst,

    input   [7:0]   i_reg_selector,

    input           i_regop,
    input           i_store_in_reg,

    input   [15:0]  i_data,

    input   [7:0]   i_option,

    output  [63:0]  o_reg_data,

    output  [15:0]  o_flag
    );

    reg [15:0]  A, B, C, D, E, F, SS, SP;

    parameter
        ADD     = 8'h0,
        SUB     = 8'h1,
        AND     = 8'h2,
        OR      = 8'h3,
        NOT     = 8'h4,
        XOR     = 8'h5,
        RAND    = 8'h6,
        ROR     = 8'h7,
        RXOR    = 8'h8,
        LSL     = 8'h9,
        LSR     = 8'hA,
        ASL     = 8'hB,
        ASR     = 8'hC,
        CSL     = 8'hD,
        CSR     = 8'hE,
        INC     = 8'hF,
        DEC     = 8'h10,
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
        if (i_store_in_reg) begin
            case (i_reg_selector[3:0])
                RA: A = i_data;
                RB: B = i_data;
                RC: C = i_data;
                RD: D = i_data;
                RE: E = i_data;
                RF: F = i_data;
                RSS: SS = i_data;
                RSP: SP = i_data;
            endcase
        end else if (i_regop) begin
            case ({i_reg_selector, i_option})
                {RA, RB, ADD}: A = A + B;
                {RA, RC, ADD}: A = A + C;
                {RA, RD, ADD}: A = A + D;
                {RA, RE, ADD}: A = A + E;
                {RA, RF, ADD}: A = A + F;
                {RA, RB, SUB}: A = A - B;
                {RA, RC, SUB}: A = A - C;
                {RA, RD, SUB}: A = A - D;
                {RA, RE, SUB}: A = A - E;
                {RA, RF, SUB}: A = A - F;
                {RA, RB, MOV_RR}: B = A;
                {RB, RC, MOV_RR}: C = B;
                {RC, RA, MOV_RR}: A = C;
            endcase
        end
    end

    assign o_reg_data = {D, C, B, A};

endmodule