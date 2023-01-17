# MACPU-FPGA
let's Make A CPU
---

Verilog implementation of MACPU

![VIVADO](https://img.shields.io/badge/Vivado-2019.2-green.svg) ![FPGA](https://img.shields.io/badge/FPGA-ARTIX7100TCSG324-yellow.svg)

## About

This is a personal contact project. Continuously updating.

## Some coding rules

1.When naming the variable that type is "wire", the bus must starts with "b_", and all interfaces connected to the bus must end with "_bus". In each module, the interface connected to the bus should be set with tri-state gates for IO control, and provide corresponding effective control signals for this interface.
