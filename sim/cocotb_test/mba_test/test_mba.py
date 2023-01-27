from cocotb.clock import Clock, Timer
from cocotb import test as cocotest
from cocotb import start_soon
from cocotb.triggers import RisingEdge
from random import randint


@cocotest()
async def test_reset(dut):
    clock_166M66 = Clock(dut.clk_166M66, 6, units="ns")

    start_soon(clock_166M66.start())

    dut.i_l2_requesting.value = randint(0, 1)
    dut.i_l2_rw.value = randint(0, 1)
    dut.i_dsc_requesting.value = randint(0, 1)
    dut.i_dsc_rw.value = randint(0, 1)

    dut.mcu_sys_rst_n.value = 0
    await Timer(randint(0, 100), units="ns")
    dut.mcu_sys_rst_n.value = 1
    await Timer(1, units="ns")

    assert dut.o_data_bus_rw.value == 0
    assert dut.o_data_bus_enable.value == 0
    assert dut.o_l2_allow.value == 0
    assert dut.o_dsc_allow.value == 0


@cocotest()
async def test_first_request(dut):
    clock_166M66 = Clock(dut.clk_166M66, 6, units="ns")

    start_soon(clock_166M66.start())

    dut.i_l2_requesting.value = 0
    dut.i_l2_rw.value = 0
    dut.i_dsc_requesting.value = 0
    dut.i_dsc_rw.value = 0

    dut.mcu_sys_rst_n.value = 0
    await Timer(10, units="ns")
    dut.mcu_sys_rst_n.value = 1
    await Timer(10, units="ns")

    dut.i_l2_requesting.value = randint(0, 1)
    dut.i_l2_rw.value = randint(0, 1)
    dut.i_dsc_requesting.value = randint(0, 1)
    dut.i_dsc_rw.value = randint(0, 1)

    await Timer(6, "ns")
    await RisingEdge(dut.clk_166M66)
    await Timer(1, "ns")

    if dut.i_dsc_requesting.value == 1:
        assert dut.o_dsc_allow.value == 1
        assert dut.o_data_bus_rw.value == dut.i_dsc_rw.value
        assert dut.o_data_bus_enable.value == 1
        assert dut.o_l2_allow.value == 0
    elif dut.i_l2_requesting.value == 1:
        assert dut.o_dsc_allow.value == 0
        assert dut.o_data_bus_rw.value == dut.i_l2_rw.value
        assert dut.o_data_bus_enable.value == 1
        assert dut.o_dsc_allow.value == 0
    else:
        assert dut.o_data_bus_rw == 0
        assert dut.o_data_bus_enable == 0
        assert dut.o_l2_allow == 0
        assert dut.o_dsc_allow == 0


@cocotest()
async def test_multy_request(dut):
    clock_166M66 = Clock(dut.clk_166M66, 6, units="ns")

    start_soon(clock_166M66.start())

    dut.i_l2_requesting.value = 0
    dut.i_l2_rw.value = 0
    dut.i_dsc_requesting.value = 0
    dut.i_dsc_rw.value = 0

    dut.mcu_sys_rst_n.value = 0
    await Timer(10, units="ns")
    dut.mcu_sys_rst_n.value = 1
    await Timer(10, units="ns")

    first_request = [randint(0, 1) for _ in range(4)]
    second_request = [randint(0, 1) for _ in range(4)]

    dut.i_l2_requesting.value = first_request[0]
    dut.i_l2_rw.value = first_request[1]
    dut.i_dsc_requesting.value = first_request[2]
    dut.i_dsc_rw.value = first_request[3]

    dsc_allow = dut.o_dsc_allow.value
    data_rw = dut.o_data_bus_rw.value
    data_en = dut.o_data_bus_enable.value
    l2_allow = dut.o_l2_allow.value

    await Timer(6, "ns")
    await RisingEdge(dut.clk_166M66)

    dut.i_l2_requesting.value = second_request[0]
    dut.i_l2_rw.value = second_request[1]
    dut.i_dsc_requesting.value = second_request[2]
    dut.i_dsc_rw.value = second_request[3]

    if first_request != second_request:
        await Timer(1, "ns")
        if first_request[2] == 1:
            assert dut.o_dsc_allow.value == 1
            assert dut.o_data_bus_rw.value == first_request[3]
            assert dut.o_data_bus_enable.value == 1
            assert dut.o_l2_allow.value == 0
        elif first_request[0] == 1:
            assert dut.o_dsc_allow.value == 0
            assert dut.o_data_bus_rw.value == first_request[1]
            assert dut.o_data_bus_enable.value == 1
            assert dut.o_dsc_allow.value == 0
        else:
            assert dut.o_data_bus_rw == 0
            assert dut.o_data_bus_enable == 0
            assert dut.o_l2_allow == 0
            assert dut.o_dsc_allow == 0
        await Timer(36, "ns")
        await RisingEdge(dut.clk_166M66)
        await Timer(1, "ns")
        if second_request[2] == 1:
            assert dut.o_dsc_allow.value == 1
            assert dut.o_data_bus_rw.value == second_request[3]
            assert dut.o_data_bus_enable.value == 1
            assert dut.o_l2_allow.value == 0
        elif second_request[0] == 1:
            assert dut.o_dsc_allow.value == 0
            assert dut.o_data_bus_rw.value == second_request[1]
            assert dut.o_data_bus_enable.value == 1
            assert dut.o_dsc_allow.value == 0
        else:
            assert dut.o_data_bus_rw.value == 0
            assert dut.o_data_bus_enable.value == 0
            assert dut.o_l2_allow.value == 0
            assert dut.o_dsc_allow.value == 0
    else:
        assert dut.o_data_bus_rw == data_rw
        assert dut.o_data_bus_enable == data_en
        assert dut.o_l2_allow == l2_allow
        assert dut.o_dsc_allow == dsc_allow
