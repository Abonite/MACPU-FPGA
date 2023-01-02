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
    
    initial begin
        clk = 1'b0;
        clk_en =1'b0;
        n_rst = 1'b1;
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
        #1000000;
        $finish();
    end
    
    wire    [15:0]  addr;
    wire    [15:0]  data;
    wire    [15:0]  rom_data;
    wire    [15:0]  write_data;
    
    wire            rw;
    wire            lock;
    wire            lock_o;
    reg             lock_r;
    reg             data_r;

    pycpu_top u_sim_modue (
        .clk            (clk),
        .n_rst          (n_rst),
        
        .i_inta         (),
        .i_intb         (),
        .o_rw           (rw),
        
        .o_addr         (addr),
        .io_data        (data),
        
        .io_lock        (lock)
    );

    bufif0 bufr (lock, 1'b1, rw);
    bufif1 bufw (lock_o, lock, rw);
    always @(posedge clk ) begin
        lock_r <= lock_o;
        data_r <= write_data;
    end

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            bufif0  bufr    (data[i], rom_data[i], rw);
            bufif1  bufw    (write_data[i], data[i], rw);
            pulldown    (write_data[i]);
        end
    endgenerate

    pulldown(lock_o);

    dist_mem_gen_0 u_test_ram (
        .a            (addr),
        .spo          (rom_data)
    );

endmodule
