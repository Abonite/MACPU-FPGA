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
    wire    [15:0]  data_bus;
    // ----------------------------------------------
    // for all io(rw) signals, it is specified here
    // that 0 is input or read, 1 is output or write
    // ----------------------------------------------
    wire            rw_bus;

    wire    [15:0]  i_data;
    wire    [15:0]  o_data;

    wire            i_lock;
    wire            o_lock;

    // Any line with the name beginning with "d2c_"
    // indicates that this line is a control signal
    // output from the decoder to the controller
    wire            d2c_decoder_addr_en;
    wire            d2c_decoder_data_en;
    wire            d2c_decoder_data_io;
    wire            d2c_decoder_lock;

    wire            d2c_set_pc_en;
    wire            d2c_pc_address_en;
    wire            d2c_pc_lock;

    wire            d2c_reg_data_en;
    wire            d2c_reg_data_io;
    wire    [7:0]   d2c_reg_selector;
    wire            d2c_reg_op_en;
    wire            d2c_reg_store;
    wire    [7:0]   d2c_reg_op;

    wire            lock_pc;
    wire            set_pc_en;
    wire            pc_address_en;
    wire            lock_decoder;
    wire            decoder_address_en;
    wire            decoder_data_en;
    wire            decoder_data_io;
    wire            lock_pin_io;
    wire            data_pin_io;
    wire            rw_pin_io;

    wire    [63:0]  reg_data;
    wire    [15:0]  flag;


    program_counter u_pc (
        .clk                        (clk),
        .rst                        (n_rst),

        .i_set_en                   (set_pc_en),
        .i_set_address              (addr_bus),

        .i_lock                     (i_lock || lock_pc),

        .i_address_en               (pc_address_en),
        .o_address                  (addr_bus)
    );

    decoder u_decoder (
        .clk                        (clk),
        .rst                        (n_rst),

        .i_data_enable              (decoder_data_en),
        .i_data_io                  (decoder_data_io),
        .i_data_bus                 (data_bus),
        .o_data_bus                 (data_bus),
        .o_addr_bus                 (addr_bus),

        .i_lock                     (i_lock || lock_decoder),

        .o_rw_bus                   (rw_bus),

        // control signals
        .o_decoder_data_io          (d2c_decoder_data_io),
        .o_decoder_address_enable   (d2c_decoder_addr_en),
        .o_decoder_data_enable      (d2c_decoder_data_io),
        .o_decoder_lock             (d2c_decoder_lock),

        .o_set_pc_enable            (d2c_set_pc_en),
        .o_pc_address_enable        (),
        .o_pc_lock                  (),

        .o_reg_data_enable          (d2c_reg_data_en),
        .o_reg_data_io              (d2c_reg_data_io),
        .o_reg_selector             (d2c_reg_selector),
        .o_reg_op_enable            (d2c_reg_op_en),
        .o_reg_op                   (d2c_reg_op)
    );

    alu u_alu (
        .n_rst              (n_rst),
        .i_reg_selector     (reg_selector),

        .i_regop            (regop),
        .i_store_in_reg     (store_in_reg),

        .i_data             (o_data),

        .i_option           (option),

        .o_reg_data         (reg_data),

        .o_flag             (flag)
    );

    // controller u_controller (
    //     .n_rst                          (n_rst),

    //     .i_lock                         (i_lock),

    //     .i_rw_bus                       (rw_bus),

    //     // cotrol signals from decoder
    //     .i_decoder_address_enable       (d2c_decoder_addr_en),
    //     .i_decoder_data_enable          (d2c_decoder_data_en),
    //     .i_decoder_data_io              (d2c_decoder_data_io),
    //     .i_reg_data_enable              (d2c_reg_data_en),
    //     .i_reg_data_io                  (d2c_reg_data_io),
    //     .i_set_pc_enable                (d2c_set_pc_en),
    //     .i_reg_selector                 (d2c_reg_selector),
    //     .i_reg_store                    (d2c_reg_store),
    //     .i_reg_op_enable                (d2c_reg_op_en),
    //     .i_reg_op                       (d2c_reg_op),
    //     // control signals from alu
    //     .i_reg_data                     (reg_data),
    //     .i_flag                         (flag),

    //     .o_lock_pc                      (lock_pc),
    //     .o_set_pc_en                    (set_pc_en),
    //     .o_pc_address_en                (pc_address_en),

    //     .o_lock_decoder                 (lock_decoder),
    //     .o_decoder_address_enable       (decoder_addr_bus_en),
    //     .o_decoder_data_enable          (decoder_data_bus_en),
    //     .o_decoder_data_io              (decoder_data_bus_io),

    //     .o_lock_pin_io                  (lock_pin_io),
    //     .o_data_pin_io                  (data_pin_io),
    //     .o_rw_pin_io                    (rw_pin_io)
    // );

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin: gen_buf
            bufif0 bufr     (i_data[i], io_data[i], rw_bus);
            bufif1 bufw     (io_data[i], o_data[i], rw_bus);
            pulldown(o_data[i]);
            pulldown(i_data[i]);
        end
    endgenerate

    bufif0 bufrlock (i_lock, io_lock, rw_bus);
    bufif1 bufwlock (io_lock, o_lock, rw_bus);
    pulldown(i_lock);
endmodule