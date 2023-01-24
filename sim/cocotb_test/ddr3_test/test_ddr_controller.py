from cocotb.clock import Clock
from cocotb import test as cocotest
from cocotb import start_soon
from cocotb.triggers import RisingEdge


@cocotest()
async def test_ddr_controller(dut):
    clock_333M = Clock(dut.clk_333M, 3, units="ns")
    clock_166M66 = Clock(dut.clk_166M66, 6, units="ns")
    clock_200M = Clock(dut.clk_200M, 5, units="ns")

    start_soon(clock_333M)
    start_soon(clock_166M66)
    start_soon(clock_200M)

    for _ in range(100):
        dut.i_psc_rw = 1
        dut.i_psc_request = 1
        await RisingEdge(dut.clk_166M66)
        assert dut.o_psc_bus_available == 1
