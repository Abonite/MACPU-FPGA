`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/30 11:01:43
// Design Name: 
// Module Name: sim_pycpu_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_pycpu_top();
    reg clk;
    reg clk_en;
    reg n_rst;
    reg int_a;
    reg int_b;
    
    initial begin
        clk = 1'b0;
        clk_en =1'b0;
        n_rst = 1'b1;
        int_a = 1'b0;
        int_b = 1'b0;
    end
    
    initial begin
        forever #10 clk = (~clk) & clk_en;
    end
    
    initial begin
        #5;
        n_rst = 1'b0;
        #13;
        n_rst = 1'b1;
        #2;
        clk_en = 1'b1;
        #3702;
        int_a = 1'b1;
        #25;
        int_a = 1'b0;
        #4000;
        int_b = 1'b1;
        #25;
        int_b = 1'b0;
        #10000;
        $finish();
    end
    
    wire    [15:0]  addr;
    wire    [15:0]  data;
    wire    [15:0]  rom_data;
    wire    [15:0]  ram_i_data;
    wire    [15:0]  ram_o_data;
    
    wire            rw;
    wire            lock;

    pycpu_top u_sim_modue (
        .clk            (clk),
        .n_rst          (n_rst),
        
        .i_inta         (int_a),
        .i_intb         (int_b),
        .o_rw           (rw),
        
        .o_addr         (addr),
        .io_data        (data),
        
        .io_lock        (lock)
    );

    wire    o_lock;
    wire    i_lock;

    reg     i_lock_en = 1'b0;
    assign  i_lock = i_lock_en;

    bufif0  locki   (lock, i_lock, rw);
    bufif1  locko   (o_lock, lock, rw);
    pulldown(o_lock);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif1  romdataren   (data[i], rom_data[i], (!(| addr[15:8])));

            bufif1  ramdataren   (data[i], ram_o_data[i], (!(| addr[15:13]) && (addr[12] || addr[11]) && !rw));
            bufif1  ramdatawen   (ram_i_data[i], data[i], (!(| addr[15:13]) && (addr[12] || addr[11]) && rw));

            pulldown(data[i]);
        end
    endgenerate

    // rom address: 16'h0000 - 16'h0100
    dist_mem_gen_0 u_test_rom (
        .a              (addr),
        .spo            (rom_data)
    );

    // rom address: 16'h1000 - 16'h2000
    dist_mem_gen_1 u_test_ram (
        .a              (addr),
        .d              (ram_i_data),
        .clk            (clk),
        .we             (rw),
        .spo            (ram_o_data)
    );

endmodule
