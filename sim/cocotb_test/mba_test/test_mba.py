from cocotb.triggers import ClockCycles
from cocotb.triggers import Timer
from cocotb import fork as cocofork
from cocotb import log as cocolog


class ClockResetDomain():
    def __init__(
        self,
        clk_signal,
        period,
        time_unit,
        reset_signal,
        reset_active_high=True
    ):
        self.clk_signal = clk_signal,
        self.period = period,
        self.time_unit = time_unit,
        self.reset_signal = reset_signal,
        self.reset_active_high = reset_active_high

    async def genRst(self):
        reset_signal_duration_time = ClockCycles(self.clk_signal, 10)

        if (self.reset_active_high):
            self.reset <= 1
        else:
            self.reset <= 0

        await reset_signal_duration_time

        if (self.reset_active_high):
            self.reset <= 0
        else:
            self.reset <= 1

    async def genClk(self):
        self.clk.setimmediatevalue(0)
        while True:
            await Timer(self.period / 2, self.time_unit)
            self.clk.setimmediatevalue(1)
            await Timer(self.period / 2, self.time_unit)
            self.clk.setimmediatevalue(0)

    async def start(self):
        clock = cocofork(self.genClk())
        reset = cocofork(self.genRst())

        await reset.join()
        return clock


class InputDrive():
    def __init__(
        self,
        sbt,
        l2req,
        l2rw,
        dscreq,
        dscrw
    ):
        self.status_bus_trans = sbt
        self.l2_req = l2req
        self.l2_rw = l2rw
        self.dsc_req = dscreq
        self.dsc_rw = dscrw

    async def testGen(self, transaction):
        """tansaction:
            0: sbt
            1: l2req
            2: l2rw
            3: dscreq
            4: dscrw"""
        cocolog.info("Get a transaction in Input Driver")

        self.status_bus_trans <= transaction[0]
        self.l2_req <= transaction[1]
        self.l2_rw <= transaction[2]
        self.dsc_req <= transaction[3]
        self.dsc_rw <= transaction[4]

        
