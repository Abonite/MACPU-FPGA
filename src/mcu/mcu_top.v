module mcu_top (
    input           clk,
    input           n_rst,

    input           i_rw,

    // address is a bus
    input   [31:0]  i_address_from_core,
    // 0 - virtual address
    // 1 - real address
    input           i_address_selector,

    output          o_lock_core,

    output  [7:0]   o_address_to_vpc,
    output          o_set_vpc_enable,

    inout   [31:0]  io_core_data
);

    // ROM:                                 0x0000_0000 -> 0x0000_0FFF,         4k x 16bit
    // program cache for program segments(pcps):    dram    256 x 48bit
    // data segment cache(dsc):                     dram    128 x 16bit
    // L2 cache:                                    bram    4096 x 16bit
    // DDR:                                 0x1000_0000 -> 0x1800_0000,         128M x 16bit

    // Currently, the real address offset read by the cpu core
    reg [31:0]  curr_core_read_offset_addr;

    // Currently, the starting offset of the data stored in each
    // cache in the real address
    reg [31:0]  curr_pcps_offset_addr;
    reg [31:0]  curr_dsc_offset_addr;

    // How much data has been read from the memory this time (16bit)
    reg [8:0]   cache_data_amount;

    always @(posedge clk) begin
        if (i_address_selector && (i_address_from_core == 32'hFF))
            curr_core_read_offset_addr <= curr_core_read_offset_addr + {13'h0, cache_data_amount};
    end

endmodule