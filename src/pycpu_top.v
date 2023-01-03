`timescale 1ns/1ps

module pycpu_top (
    input           wire    clk,
    input           wire    n_rst,

    input           wire    i_inta,
    input           wire    i_intb,

    output          wire    o_rw,

    output  wire    [15:0]  o_addr,
    inout   wire    [15:0]  io_data,

    inout   wire            io_lock
    );

    wire    [15:0]  addr_bus;
    wire    [15:0]  pc_addr;
    wire    [15:0]  data_bus;
    // ----------------------------------------------
    // for all io(rw) signals, it is specified here
    // that 0 is input or read, 1 is output or write
    // ----------------------------------------------
    wire            lock_io;

    wire            dc_data_en;
    wire            dc_data_io;
    wire            dc_addr_en;
    wire            dc_lock;
    wire            dc_reset;

    wire            pc_set_en;
    wire            pc_set_addr;
    wire            pc_lock;

    wire            i_lock;
    wire            o_lock;

    wire    [1:0]   io_control_code;
    wire    [2:0]   pc_control_code;
    wire    [3:0]   dc_control_code;
    wire    [2:0]   ct_control_code;
    wire    [18:0]  alu_control_code;

    program_counter u_pc (
        .clk                        (clk),
        .rst                        (n_rst),

        .i_set_en                   (pc_set_en),
        .i_set_address              (addr_bus),

        .i_lock                     (i_lock || pc_lock),

        .i_address_en               (pc_addr_en),
        .o_address                  (pc_addr)
    );

    decoder u_decoder (
        .clk                            (clk),
        .n_rst                          (n_rst),

        .i_interrupt                    (dc_int),

        .io_data_bus                    (data_bus),
        .o_addr_bus                     (addr_bus),

        .i_data_enable                  (dc_data_en),
        .i_data_io                      (dc_data_io),
        .i_address_enable               (dc_addr_en),
        .i_lock                         (i_lock || dc_lock),

        // control signals
        .o_io_control_code              (io_control_code),
        .o_pc_control_code              (pc_control_code),
        .o_dc_control_code              (dc_control_code),
        .o_ct_control_code              (ct_control_code),
        .o_alu_control_code             (alu_control_code)
    );

    // alu u_alu (
    //     .n_rst              (n_rst),
    //     .i_reg_selector     (reg_selector),

    //     .i_regop            (regop),
    //     .i_store_in_reg     (store_in_reg),

    //     .i_data             (o_data),

    //     .i_option           (option),

    //     .o_reg_data         (reg_data),

    //     .o_flag             (flag)
    // );

    controller u_controller (
        .clk                            (clk),
        .n_rst                          (n_rst),

        .i_data_bus                     (data_bus),
        .o_addr_bus                     (addr_bus),

        .i_inta                         (i_inta),
        .i_intb                         (i_intb),

        .i_io_control_code              (io_control_code),
        .i_pc_control_code              (pc_control_code),
        .i_dc_control_code              (dc_control_code),
        .i_ct_control_code              (ct_control_code),
        .i_alu_control_code             (alu_control_code),

        .o_rw                           (o_rw),
        .o_lock_io                      (lock_io),

        .o_decoder_data_enable          (dc_data_en),
        .o_decoder_data_io              (dc_data_io),
        .o_decoder_address_output       (dc_addr_en),
        .o_decoder_lock                 (dc_lock),
        .o_decoder_interrupt            (dc_int),

        .o_pc_set_enable                (pc_set_en),
        .o_pc_address_enable            (pc_addr_en),
        .o_pc_lock                      (pc_lock)
    );

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin: gen_buf
            bufif0 bufr     (data_bus[i], io_data[i], o_rw);
            bufif1 bufw     (io_data[i], data_bus[i], o_rw);
            pulldown(data_bus[i]);
            pulldown(addr_bus[i]);
            // addr bus output need bufif
            bufif1 buf_addr_pc    (o_addr[i], pc_addr[i], pc_addr_en);
            bufif0 buf_addr_bus    (o_addr[i], addr_bus[i], pc_addr_en);
        end
    endgenerate

    bufif0 bufrlock (i_lock, io_lock, lock_io);
    bufif1 bufwlock (io_lock, o_lock, lock_io);
    pulldown(i_lock);
endmodule