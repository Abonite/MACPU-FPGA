# MACPU ISA

## Registers

In MACPU ISA, we have 41 registers, they are:

| Register name | Bit width | Attributes                                                   | general purpose                                              |
| ------------- | --------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| %PC           | 32        | Program counter. It can only be assigned when a branch instruction is triggered, but it can be read at any time. | Indicates the address currently being read                   |
| %A1           | 32        | General purpose register.                                    |                                                              |
| %A2           | 32        | General purpose register.                                    |                                                              |
| %A3           | 32        | General purpose register.                                    |                                                              |
| %A4           | 32        | General purpose register.                                    |                                                              |
| %AR1          | 32        | General purpose register.                                    | Can be used to store return values                           |
| %AR2          | 32        | General purpose register.                                    | Can be used to store return values                           |
| %AR3          | 32        | General purpose register.                                    | Can be used to store return values                           |
| %ASS          | 32        | General purpose register.                                    | Can be used to indicate the current stack segment base address |
| %ASP          | 32        | General purpose register.                                    | Can be used to indicate the current stack pointer            |
| %ADS          | 32        | General purpose register.                                    | Can be used to indicate the current address segment base address |
| %B1           | 32        | General purpose register.                                    |                                                              |
| %B2           | 32        | General purpose register.                                    |                                                              |
| %B3           | 32        | General purpose register.                                    |                                                              |
| %B4           | 32        | General purpose register.                                    |                                                              |
| %BR1          | 32        | General purpose register.                                    | Can be used to store return values                           |
| %BR2          | 32        | General purpose register.                                    | Can be used to store return values                           |
| %BR3          | 32        | General purpose register.                                    | Can be used to store return values                           |
| %BSS          | 32        | General purpose register.                                    | Can be used to indicate the current stack segment base address |
| %BSP          | 32        | General purpose register.                                    | Can be used to indicate the current stack pointer            |
| %BDS          | 32        | General purpose register.                                    | Can be used to indicate the current address segment base address |
| %C1           | 32        | General purpose register.                                    |                                                              |
| %C2           | 32        | General purpose register.                                    |                                                              |
| %C3           | 32        | General purpose register.                                    |                                                              |
| %C4           | 32        | General purpose register.                                    |                                                              |
| %CR1          | 32        | General purpose register.                                    | Can be used to store return values                           |
| %CR2          | 32        | General purpose register.                                    | Can be used to store return values                           |
| %CR3          | 32        | General purpose register.                                    | Can be used to store return values                           |
| %CSS          | 32        | General purpose register.                                    | Can be used to indicate the current stack segment base address |
| %CSP          | 32        | General purpose register.                                    | Can be used to indicate the current stack pointer            |
| %CDS          | 32        | General purpose register.                                    | Can be used to indicate the current address segment base address |
| %D1          | 32        | General purpose register.                                    |                                                              |
| %D2          | 32        | General purpose register.                                    |                                                              |
| %D3          | 32        | General purpose register.                                    |                                                              |
| %D4          | 32        | General purpose register.                                    |                                                              |
| %DR1         | 32        | General purpose register.                                    | Can be used to store return values                           |
| %DR2         | 32        | General purpose register.                                    | Can be used to store return values                           |
| %DR3         | 32        | General purpose register.                                    | Can be used to store return values                           |
| %DSS         | 32        | General purpose register.                                    | Can be used to indicate the current stack segment base address |
| %DSP         | 32        | General purpose register.                                    | Can be used to indicate the current stack pointer            |
| %DDS         | 32        | General purpose register.                                    | Can be used to indicate the current address segment base address |



## Instructions

All instructions supported by the MACPU are listed below.

### Memory Operations

---

#### LOAD8

**LOAD8 immediate number, %r / LOAD8 [immediate number address], %r / LOAD8 [%r1 (+ %r2)], %r**

Read 8bit immediate value and load it into the specified register

#### LOAD16

**LOAD16 immediate number, %r / LOAD16 [immediate number address], %r / LOAD16 [%r1 (+ %r2)], %r**

Read 16bit immediate value and load it into the specified register

#### LOAD32

**LOAD32 immediate number, %r / LOAD32 [immediate number address], %r / LOAD32 [%r1 (+ %r2)], %r**

Read 16bit immediate value and load it into the specified register

#### STORE8

**STORE8 %r, [immediate number address] / STORE8 %r, [%r1 (+ %r2)]**

Write 8bit immediate value and load it into the specified register

#### STORE16

**STORE16 %r, [immediate number address] / STORE16 %r, [%r1 (+ %r2)]**

Write 16bit immediate value and load it into the specified register

#### STORE32

**STOR32 %r, [immediate number address] / STORE32 %r, [%r1 (+ %r2)]**

Write32bit immediate value and load it into the specified register

---

### Register Operations

---

#### MOVE

**MOVE %r1, %r2**

Move the value of one register to another register

---

### Integer Operations

Subject to the specific logic implementation required for the execution of each instruction, although the following arithmetic instructions are classified as integer operations, they will be assigned to different arithmetic unit implementations

---

#### ADD

**ADD %r1, %r2, %rrslt / ADD %r, immediate number, %rrslt**

Integer add, if an immediate value is used in an instruction, some computational precision may be lost

#### SUB

**SUB %r1, %r2, %rrslt / SUB %r, immediate number, %rrslt**

Integer subtraction, if an immediate value is used in an instruction, some computational precision may be lost

#### BAND

**BAND %r1, %r2, %rrslt / BAND %r, immediate number, %rrslt**

Bitwise AND, if an immediate value is used in an instruction, some computational precision may be lost

#### BOR

**BOR %r1, %r2, %rrslt / BOR %r, immediate number, %rrslt**

Bitwise OR, if an immediate value is used in an instruction, some computational precision may be lost

#### BNOT

**BNOT %r, %rrslt / BNOT immediate number, %rrslt**

Bitwise NOT, if an immediate value is used in an instruction, some computational precision may be lost

#### BXOR

**BXOR %r1, %r2, %rrslt / BXOR %r, immediate number, %rrslt**

Bitwise XOR, if an immediate value is used in an instruction, some computational precision may be lost

#### RAND

**RAND %r, %rrslt**

Reduced AND

#### ROR

**ROR %r, %rrslt**

Bitwise OR

#### RXOR

**RXOR %r, %rrslt**

Bitwise XOR

#### MUL

**MUL %r1, %r2, %rrslt / MUL %r, immediate number, %rrslt**

Integer multiplication, if an immediate value is used in an instruction, some computational precision may be lost

#### DIV

**DIV %r1, %r2, %rrslt / DIV %r, immediate number, %rrslt**

Integer division, if an immediate value is used in an instruction, some computational precision may be lost

#### LS

**SL %r1, %r2, %rrslt / SL %r, immediate number, %rrslt**

Left shift register %r1, the number of bits shifted is recorded in %r2, or directly pointed out by the immediate number, low bit fill zero

#### LRS

**LRS %r1, %r2, %rrslt / LRS %r, immediate number, %rrslt**

Logic right shift register %r1, the number of bits shifted is recorded in %r2, or directly pointed out by the immediate number, high bit fill zero

#### ARS

**ARS %r1, %r2, %rrslt / ARS %r, immediate number, %rrslt**

Algorithm right shift register %r1, the number of bits shifted is recorded in %r2, or directly pointed out by the immediate number, high bit complements the same number as the sign bit

#### LCS

**LCS %r1, %r2, %rrslt / LCS %r, immediate number, %rrslt**

Left circular shift register %r1, the number of bits shifted is recorded in %r2, or directly pointed out by the immediate number

---

### Branch Operations

---

#### GT

**GT %r1, %r2, %rrslt / GT %r, immediate number, %rrslt**

If %r1 is greater than %r2 or immediate number, the %rrslt will be set to 1, otherwise 0

#### EQ

**EQ %r1, %r2, %rrslt / EQ %r, immediate number, %rrslt**

If %r1 is equal to %r2 or immediate number, the %rrslt will be set to 1, otherwise 0

#### LT

**LT %r1, %r2, %rrslt / LT %r, immediate number, %rrslt**

If %r1 is less than %r2 or immediate number, the %rrskt will be set to 1, otherwise 0

#### GTE

**GTE %r1, %r2, %rrslt / GTE %r, immediate number, %rrslt**

If %r1 is greater or equal to %r2 or immediate number, the %rrslt will be set to 1, otherwise 0

#### LTE

**LTE %r1, %r2, %rrslt / LTE %r, immediate number, %rrslt**

If %r1 is less or equal to %r2 or immediate number, the %rrslt will be set to 1, otherwise 0

---

### Jump Operations

---

#### JMP

**JMP [immediate number address] / JMP [%r1 (+ %r2)]**

Unconditionally jump to the specified instruction

#### OJMP

**OJMP %r, [immediate number address] / OJMP %r, [%r1 (+ %r2)]**

Jump to the specified address when the value of the register %r is 1

#### ZJMP

**ZJMP %r, [immediate number address] / ZJMP %r, [%r1 (+ %r2)]**

Jump to the specified address when the value of the register %r is 0

---

### Interrupt Operations

---

#### INT

**INT immediate number**

Trigger the specified interrupt
