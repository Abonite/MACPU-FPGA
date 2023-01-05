module alu (
    input   wire            clk,
    input   wire            n_rst,

    inout   wire    [15:0]  io_data,
    input   wire    [15:0]  i_data_dc,
    output  wire    [15:0]  o_addr,

    input   wire            i_reg_io,
    input   wire            i_reg_io_enable,
    input   wire            i_reg_dc_enable,
    input   wire    [4:0]   i_1st_alu_reg_selector,
    input   wire    [4:0]   i_2nd_alu_reg_selector,
    input   wire    [7:0]   i_alu_operate,

    output  wire    [15:0]  o_flag
    );

    wire    [15:0]  inner_data_bus;

    wire    [15:0]  input_a;
    wire    [15:0]  input_b;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif1  bufioi    (inner_data_bus[i], io_data[i], (!i_reg_io && i_reg_io_enable));
            bufif1  bufioo    (io_data[i], inner_data_bus[i], (i_reg_io && i_reg_io_enable));
            bufif1  bufdci    (inner_data_bus[i], i_data_dc[i], i_reg_dc_enable);
        end
    endgenerate

    // A, B, C, D, E, F is general register
    // R, SS, SP is special register
    // A, B, C, D, E, F can be assigned directly and used for direct output
    // R is used to save the operation results, so it cannot be used as a direct input
    // but only as a direct output
    // All caclulation results will only be stored in R
    // SS and SP record the starting address of the stack and the current stack pointer
    // can be assigned directly but cannot be output directly
    reg [15:0]  A, B, C, D, E, F, SS, SP;
    reg [16:0]  R;

    reg [15:0]  stack_addr;

    // 0: overflow
    // 1: zero
    // 2: carry
    // 3: stack overflow
    reg [15:0]  flag = 16'h0;

    wire    [15:0]  A_o;
    wire    [15:0]  B_o;
    wire    [15:0]  C_o;
    wire    [15:0]  D_o;
    wire    [15:0]  E_o;
    wire    [15:0]  F_o;
    wire    [15:0]  R_o;

    wire    [15:0]  stack_addr_o;

    wire    reg_a_i, reg_a_o_db, reg_a_o_ia, reg_a_o_ib;
    wire    reg_b_i, reg_b_o_db, reg_b_o_ia, reg_b_o_ib;
    wire    reg_c_i, reg_c_o_db, reg_c_o_ia, reg_c_o_ib;
    wire    reg_d_i, reg_d_o_db, reg_d_o_ia, reg_d_o_ib;
    wire    reg_e_i, reg_e_o_db, reg_e_o_ia, reg_e_o_ib;
    wire    reg_f_i, reg_f_o_db, reg_f_o_ia, reg_f_o_ib;
    wire    reg_r_o_db;
    wire    reg_ss_i;
    wire    reg_sp_i;
    wire    reg_imdn_o_ia, reg_imdn_o_ib;

    reg     sp_inc;
    reg     sp_dec;

    task no_stack_op;
        begin
            sp_inc = 1'b0;
            sp_dec = 1'b0;
        end
    endtask
    task push_in;
        begin
            sp_inc = 1'b1;
            sp_dec = 1'b0;
        end
    endtask
    task pop_out;
        begin
            sp_inc = 1'b0;
            sp_dec = 1'b1;
        end
    endtask

    always @(*) begin
        if (sp_inc && !sp_dec)
            stack_addr = SS + SP;
        else if (!sp_inc && sp_dec)
            stack_addr = SS + SP - 16'b1;
    end

    assign stack_addr_o = stack_addr;

    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1) begin
            bufif1  bufstacko   (o_addr[j], stack_addr_o[j], (sp_inc || sp_dec));
        end
    endgenerate

    always @(posedge clk) begin
        if (sp_inc && !sp_dec && (SP < 16'hFFFF))
            SP <= SP + 16'b1;
        else if (sp_inc && !sp_dec && (SP == 16'hFFFF))
            SP <= 16'hFFFF;
        else if (!sp_inc && sp_dec && (SP > 16'h0001))
            SP <= SP - 16'b1;
        else if (!sp_inc && sp_dec && (SP == 16'h0001))
            SP <= 16'h0001;
        else
            SP <= SP;
    end

    always @(posedge clk) begin
        if (sp_inc && !sp_dec && (SP != 16'hFFFF))
            flag[3] <= 1'b0;
        else if (sp_inc && !sp_dec && (SP == 16'hFFFF))
            flag[3] <= 1'b1;
        else if (!sp_inc && sp_dec && (SP != 16'h0000))
            flag[3] <= 1'b0;
        else if (!sp_inc && sp_dec && (SP != 16'h0000))
            flag[3] <= 1'b1;
        else
            flag[3] <= flag[3];
    end

    reg [7:0]   reg_i;
    reg [6:0]   reg_o_db;
    reg [6:0]   reg_o_ia;
    reg [6:0]   reg_o_ib;

    assign reg_a_i = reg_i[0];
    assign reg_b_i = reg_i[1];
    assign reg_c_i = reg_i[2];
    assign reg_d_i = reg_i[3];
    assign reg_e_i = reg_i[4];
    assign reg_f_i = reg_i[5];
    assign reg_ss_i = reg_i[6];
    assign reg_sp_i = reg_i[7];

    task ri(input [3:0]   reg_select);
        case (reg_select)
            4'h0:   reg_i = 8'b00000000;
            4'h1:   reg_i = 8'b00000001;
            4'h2:   reg_i = 8'b00000010;
            4'h3:   reg_i = 8'b00000100;
            4'h4:   reg_i = 8'b00001000;
            4'h5:   reg_i = 8'b00010000;
            4'h6:   reg_i = 8'b00100000;
            4'h7:   reg_i = 8'b01000000;
            4'h8:   reg_i = 8'b10000000;
        endcase
    endtask

    assign reg_a_o_db = reg_o_db[0];
    assign reg_b_o_db = reg_o_db[1];
    assign reg_c_o_db = reg_o_db[2];
    assign reg_d_o_db = reg_o_db[3];
    assign reg_e_o_db = reg_o_db[4];
    assign reg_f_o_db = reg_o_db[5];
    assign reg_r_o_db = reg_o_db[6];

    task otdb(input [3:0]   reg_select);
        case (reg_select)
            4'h0:   reg_o_db = 7'b0000000;
            4'h1:   reg_o_db = 7'b0000001;
            4'h2:   reg_o_db = 7'b0000010;
            4'h3:   reg_o_db = 7'b0000100;
            4'h4:   reg_o_db = 7'b0001000;
            4'h5:   reg_o_db = 7'b0010000;
            4'h6:   reg_o_db = 7'b0100000;
            4'h7:   reg_o_db = 7'b1000000;
            4'h8:   reg_o_db = 7'b0000000;
        endcase
    endtask

    assign reg_a_o_ia = reg_o_ia[0];
    assign reg_b_o_ia = reg_o_ia[1];
    assign reg_c_o_ia = reg_o_ia[2];
    assign reg_d_o_ia = reg_o_ia[3];
    assign reg_e_o_ia = reg_o_ia[4];
    assign reg_f_o_ia = reg_o_ia[5];
    assign reg_imdn_o_ia = reg_o_ia[6];

    task otia(input [3:0]   reg_select);
        case (reg_select)
            4'h0:   reg_o_ia = 7'b0000000;
            4'h1:   reg_o_ia = 7'b0000001;
            4'h2:   reg_o_ia = 7'b0000010;
            4'h3:   reg_o_ia = 7'b0000100;
            4'h4:   reg_o_ia = 7'b0001000;
            4'h5:   reg_o_ia = 7'b0010000;
            4'h6:   reg_o_ia = 7'b0100000;
            4'h7:   reg_o_ia = 7'b0000000;
            4'h8:   reg_o_ia = 7'b1000000;
        endcase
    endtask

    assign reg_a_o_ib = reg_o_ib[0];
    assign reg_b_o_ib = reg_o_ib[1];
    assign reg_c_o_ib = reg_o_ib[2];
    assign reg_d_o_ib = reg_o_ib[3];
    assign reg_e_o_ib = reg_o_ib[4];
    assign reg_f_o_ib = reg_o_ib[5];
    assign reg_imdn_o_ib = reg_o_ib[6];

    task otib(input [3:0]   reg_select);
        case (reg_select)
            4'h0:   reg_o_ib = 7'b0000000;
            4'h1:   reg_o_ib = 7'b0000001;
            4'h2:   reg_o_ib = 7'b0000010;
            4'h3:   reg_o_ib = 7'b0000100;
            4'h4:   reg_o_ib = 7'b0001000;
            4'h5:   reg_o_ib = 7'b0010000;
            4'h6:   reg_o_ib = 7'b0100000;
            4'h7:   reg_o_ib = 7'b0000000;
            4'h8:   reg_o_ib = 7'b1000000;
        endcase
    endtask

    assign A_o = A;
    assign B_o = B;
    assign C_o = C;
    assign D_o = D;
    assign E_o = E;
    assign F_o = F;
    assign R_o = R[15:0];
    assign SS_o = SS;
    assign SP_o = SP;

    always @(posedge clk or negedge clk) begin
        A = reg_a_i ? inner_data_bus : A;
    end

    always @(posedge clk or negedge clk) begin
        B = reg_b_i ? inner_data_bus : B;
    end

    always @(posedge clk or negedge clk) begin
        C = reg_c_i ? inner_data_bus : C;
    end

    always @(posedge clk or negedge clk) begin
        D = reg_d_i ? inner_data_bus : D;
    end

    always @(posedge clk or negedge clk) begin
        E = reg_e_i ? inner_data_bus : E;
    end

    always @(posedge clk or negedge clk) begin
        F = reg_f_i ? inner_data_bus : F;
    end

    always @(posedge clk or negedge clk) begin
        SS = reg_ss_i ? inner_data_bus : SS;
    end

    always @(posedge clk or negedge clk) begin
        SP = reg_sp_i ? inner_data_bus : SP;
    end

    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin
            bufif1  bufAodb (inner_data_bus[k], A_o[k], reg_a_o_db);
            bufif1  bufBodb (inner_data_bus[k], B_o[k], reg_b_o_db);
            bufif1  bufCodb (inner_data_bus[k], C_o[k], reg_c_o_db);
            bufif1  bufDodb (inner_data_bus[k], D_o[k], reg_d_o_db);
            bufif1  bufEodb (inner_data_bus[k], E_o[k], reg_e_o_db);
            bufif1  bufFodb (inner_data_bus[k], F_o[k], reg_f_o_db);
            bufif1  bufRodb (inner_data_bus[k], R_o[k], reg_r_o_db);

            bufif1  bufAoia (input_a[k], A_o[k], reg_a_o_ia);
            bufif1  bufBoia (input_a[k], B_o[k], reg_b_o_ia);
            bufif1  bufCoia (input_a[k], C_o[k], reg_c_o_ia);
            bufif1  bufDoia (input_a[k], D_o[k], reg_d_o_ia);
            bufif1  bufEoia (input_a[k], E_o[k], reg_e_o_ia);
            bufif1  bufFoia (input_a[k], F_o[k], reg_f_o_ia);
            bufif1  bufImdnoia (input_a[k], inner_data_bus[k], reg_imdn_o_ia);

            bufif1  bufAoib (input_b[k], A_o[k], reg_a_o_ib);
            bufif1  bufBoib (input_b[k], B_o[k], reg_b_o_ib);
            bufif1  bufCoib (input_b[k], C_o[k], reg_c_o_ib);
            bufif1  bufDoib (input_b[k], D_o[k], reg_d_o_ib);
            bufif1  bufEoib (input_b[k], E_o[k], reg_e_o_ib);
            bufif1  bufFoib (input_b[k], F_o[k], reg_f_o_ib);
            bufif1  bufImdnoib (input_b[k], inner_data_bus[k], reg_imdn_o_ib);

            pulldown(inner_data_bus[k]);
            pulldown(input_a[k]);
            pulldown(input_b[k]);
        end
    endgenerate

    parameter
        NO_OP       = 8'h0,
        ADD         = 8'h1,
        SUB         = 8'h2,
        AND         = 8'h3,
        OR          = 8'h4,
        NOT         = 8'h5,
        XOR         = 8'h6,
        RAND        = 8'h7,
        ROR         = 8'h8,
        RXOR        = 8'h9,
        LSL         = 8'hA,
        LSR         = 8'hB,
        ASL         = 8'hC,
        ASR         = 8'hD,
        CSL         = 8'hE,
        CSR         = 8'hF,
        INC         = 8'h10,
        DEC         = 8'h11,
        PUSH        = 8'hfb,
        POP         = 8'hfc,
        MOV_RA      = 8'hfd,
        MOV_AR      = 8'hfe,
        LOAD_MOV_RR = 8'hff;

    always @(negedge n_rst) begin
        if (!n_rst) begin
            A <= 16'b0;
            B <= 16'b0;
            C <= 16'b0;
            D <= 16'b0;
            E <= 16'b0;
            F <= 16'b0;
            R <= 17'h0;
            SS <= 16'b0;
            SP <= 16'b0;

            reg_i <= 16'h0;
            reg_o_db <= 16'h0;
            reg_o_ia <= 16'h0;
            reg_o_ib <= 16'h0;
        end
    end

    always @(*) begin
        case (i_alu_operate)
            ADD: begin
                R = {1'b0, input_a} + {1'b0, input_b};
                if (((input_a > 0) && (input_b > 0) && (R[15:0] < 0)) || ((input_a < 0) && (input_b < 0) && (R[15:0] > 0)))
                    flag[0] = 1'b1;
                else
                    flag[0] = 1'b0;
            end
            SUB: begin
                R = {1'b0, input_a} - {1'b0, input_b};
                if (((input_a < 0) && (input_b > 0) && (R[15:0] > 0)) || ((input_a > 0) && (input_b < 0) && (R[15:0] < 0)))
                    flag[0] = 1'b1;
                else
                    flag[0] = 1'b0;
            end
            AND:    R = {1'b0, input_a & input_b};
            OR:     R = {1'b0, input_a | input_b};
            NOT:    R = {1'b0, ~input_a};
            XOR:    R = {1'b0, input_a ^ input_b};
            RAND:   R = {1'b0, & input_a};
            ROR:    R = {1'b0, | input_a};
            RXOR:   R = {1'b0, ^ input_a};
            // left shift can make carry flag change
            // right shift can not
            LSL:    R = {input_a[15:0], 1'b0};
            LSR:    R = {1'b0, input_a[16:1]};
            ASL:    R = {input_a[15:0], 1'b0};
            ASR:    R = {1'b0, input_a[15], input_a[14:1]};
            CSL:    R = {input_a[14], input_a[14:1], input_a[15]};
            CSR:    R = {input_a[0], input_a[0], input_a[14:1]};
            INC:    R = {1'b0, input_a + 16'b1};
            DEC:    R = {1'b0, input_a - 16'b1};
            default:    R = R;
        endcase
    end

    always @(*) begin
        if (R == 0)
            flag[1] = 1'b1;
        else
            flag[1] = 1'b0;
    end

    always @(*) begin
        flag[2] = R[16];
    end

    always @(*) begin
        case (i_alu_operate)
            NO_OP: begin
                reg_i <= 8'h0;
                reg_o_db <= 7'h0;
                reg_o_ia <= 7'h0;
                reg_o_ib <= 7'h0;
                no_stack_op;
            end
            ADD: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(i_2nd_alu_reg_selector);
                no_stack_op;
            end
            SUB: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(i_2nd_alu_reg_selector);
                no_stack_op;
            end
            AND: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(i_2nd_alu_reg_selector);
                no_stack_op;
            end
            OR: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(i_2nd_alu_reg_selector);
                no_stack_op;
            end
            NOT: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            XOR: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            RAND: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            ROR: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            RXOR: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            LSL: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            LSR: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            ASL: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            ASR: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            CSL: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            CSR: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            INC: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            DEC: begin
                ri(4'b0);
                otdb(4'b0);
                otia(i_1st_alu_reg_selector);
                otib(4'b0);
                no_stack_op;
            end
            PUSH: begin
                ri(4'b0);
                otdb(i_1st_alu_reg_selector);
                otia(4'b0);
                otib(4'b0);
                push_in;
            end
            POP: begin
                ri(i_1st_alu_reg_selector);
                otdb(4'b0);
                otia(4'b0);
                otib(4'b0);
                pop_out;
            end
            MOV_RA: begin
                ri(4'b0);
                otdb(i_1st_alu_reg_selector);
                otia(4'b0);
                otib(4'b0);
                no_stack_op;
            end
            MOV_AR: begin
                ri(i_2nd_alu_reg_selector);
                otdb(4'b0);
                otia(4'b0);
                otib(4'b0);
                no_stack_op;
            end
            LOAD_MOV_RR: begin
                ri(i_2nd_alu_reg_selector);
                otdb(i_1st_alu_reg_selector);
                otia(4'b0);
                otib(4'b0);
                no_stack_op;
            end
        endcase
    end

    assign o_flag = flag;
endmodule