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
    wire    [15:0]  io_data_bus;
    wire    [15:0]  dc_data_dcalu;
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
    wire            pc_int_en;
    wire    [15:0]  pc_int_addr;
    wire            pc_lock;

    wire            alu_reg_io;
    wire            alu_reg_io_en;
    wire            alu_reg_dc_en;
    wire    [4:0]   alu_1st_reg;
    wire    [4:0]   alu_2nd_reg;
    wire    [7:0]   alu_op;

    wire    [15:0]  flag;

    wire            i_lock;

    wire    [1:0]   io_control_code;
    wire    [2:0]   pc_control_code;
    wire    [3:0]   dc_control_code;
    wire    [11:0]  ct_control_code;
    wire    [18:0]  alu_control_code;

    program_counter u_pc (
        .clk                        (clk),
        .n_rst                      (n_rst),

        .i_set_en                   (pc_set_en),
        .i_set_address              (io_data_bus),

        .i_interrupt_enable         (pc_int_en),
        .i_interrupt_address        (pc_int_addr),

        .i_lock                     (i_lock || pc_lock),

        .i_address_en               (pc_addr_en),
        .o_address                  (pc_addr)
    );

    decoder u_decoder (
        .clk                            (clk),
        .n_rst                          (n_rst),

        .i_interrupt                    (dc_int),

        .io_data_bus                    (io_data_bus),
        .o_data_alu                     (dc_data_dcalu),
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

    alu u_alu (
        .clk                    (clk),
        .n_rst                  (n_rst),

        .io_data                (io_data_bus),
        .i_data_dc              (dc_data_dcalu),
        .o_addr                 (addr_bus),

        .i_reg_io               (alu_reg_io),
        .i_reg_io_enable        (alu_reg_io_en),
        .i_reg_dc_enable        (alu_reg_dc_en),
        .i_1st_alu_reg_selector (alu_1st_reg),
        .i_2nd_alu_reg_selector (alu_2nd_reg),
        .i_alu_operate          (alu_op),

        .o_flag                 (flag)
    );

    controller u_controller (
        .clk                            (clk),
        .n_rst                          (n_rst),

        .i_data_bus                     (io_data_bus),
        .o_interrupt_address            (pc_int_addr),

        .i_inta                         (i_inta),
        .i_intb                         (i_intb),

        .i_flag                         (flag),

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
        .o_pc_interrupt_enable          (pc_int_en),
        .o_pc_lock                      (pc_lock),

        .o_alu_reg_io                   (alu_reg_io),
        .o_alu_reg_io_enable            (alu_reg_io_en),
        .o_alu_reg_dc_enable            (alu_reg_dc_en),
        .o_1st_alu_reg_selector         (alu_1st_reg),
        .o_2nd_alu_reg_selector         (alu_2nd_reg),
        .o_alu_operate                  (alu_op)
    );

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin: gen_buf
            bufif0 bufr     (io_data_bus[i], io_data[i], o_rw);
            bufif1 bufw     (io_data[i], io_data_bus[i], o_rw);
            pulldown(io_data_bus[i]);
            pulldown(addr_bus[i]);
            // addr bus output need bufif
            bufif1 buf_addr_pc  (o_addr[i], pc_addr[i], pc_addr_en);
            bufif0 buf_addr_bus (o_addr[i], addr_bus[i], pc_addr_en);
        end
    endgenerate

    bufif0 bufrlock (i_lock, io_lock, lock_io);
    bufif1 bufwlock (io_lock, 1'b1, lock_io);
    pulldown(i_lock);
endmodule