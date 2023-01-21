module system_top (
    input           wire    sys_clk,
    input           wire    sys_n_rst,

    input           wire    i_pin_inta,
    input           wire    i_pin_intb,

    output          wire    o_pin_rw,

    output  wire    [15:0]  o_pin_addr,
    inout   wire    [15:0]  io_pin_data,

    inout   wire            io_pin_lock,

    output  wire            o_pin_mmcm_locked,

    output  wire            o_cpu_clk_170M,
    output  wire            o_ddr_ui_clk_166M66,
    output  wire            o_ddr_core_clk_333M,
    output  wire            o_ddr_ref_clk_200M
    );

    cpu_clk_generater u_ccg (
  // Clock out ports
        .cpu_core_clk   (o_cpu_clk_170M),
        .ddr_ui_clk     (o_ddr_ui_clk_166M66),
        .ddr_core_clk   (o_ddr_core_clk_333M),
        .ddr_ref_clk    (o_ddr_ref_clk_200M),
        // Status and control signals
        .resetn         (sys_n_rst),

        .locked         (o_pin_mmcm_locked),
        //Clock n ports
        .clk_in1        (sys_clk)
    );

    pycpu_top u_pycpu (
        .clk            (o_cpu_clk_170M),
        .n_rst          (sys_n_rst && o_pin_mmcm_locked),

        .i_inta         (i_pin_inta),
        .i_intb         (i_pin_intb),

        .o_rw           (o_pin_rw),

        .o_addr         (o_pin_addr),
        .io_data        (io_pin_data),

        .io_lock        (io_pin_lock),

        .o_mmcm_locked  (o_pin_mmcm_locked)
    );
endmodule