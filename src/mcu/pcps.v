module pcps (
    input       clk_170M,
    input       clk_166M66
);

blk_mem_l1cache_48x256 u_l1_cache (
    clka        (clk_170M),
    ena         (),
    wea         (),
    addra       (),
    dina        (),
    douta       (),
    clkb        (),
    enb         (),
    web         (),
    addrb       (),
    dinb        (),
    doutb       ()
);

endmodule
