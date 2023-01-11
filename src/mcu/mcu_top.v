module mcu_top (
    input           clk,
    input           n_rst,

    input           rw,
    output          lock,

    input   [31:0]  jmp_req_address,
    input   [7:0]   virtual_address,
    input           address_select,

    inout   [31:0]  data
);

endmodule