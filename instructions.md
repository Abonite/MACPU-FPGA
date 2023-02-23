# MACPU ISA

## Registers

In MACPU ISA, we have 42 registers, they are:

| Register name | Bit width | Label | Attributes                                                   | general purpose                                              |
| ------------- | --------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| %PC           | 32        | 10 1001 | Program counter. It can only be assigned when a branch instruction is triggered, but it can be read at any time. | Indicates the address currently being read                   |
| %ZERO | 32 | 00 0000 | Hardware zero. | Same as RISCV |
| %A1           | 32        | 00 0001 | General purpose register.                                    |                                                              |
| %A2           | 32        | 00 0010 | General purpose register.                                    |                                                              |
| %A3           | 32        | 00 0011 | General purpose register.                                    |                                                              |
| %A4           | 32        | 00 0100 | General purpose register.                                    |                                                              |
| %AR1          | 32        | 00 0101 | General purpose register.                                    | Can be used to store return values                           |
| %AR2          | 32        | 00 0110 | General purpose register.                                    | Can be used to store return values                           |
| %AR3          | 32        | 00 0111 | General purpose register.                                    | Can be used to store return values                           |
| %ASS          | 32        | 00 1000 | General purpose register.                                    | Can be used to indicate the current stack segment base address |
| %ASP          | 32        | 00 1001 | General purpose register.                                    | Can be used to indicate the current stack pointer            |
| %ADS          | 32        | 00 1010 | General purpose register.                                    | Can be used to indicate the current address segment base address |
| %B1           | 32        | 00 1011 | General purpose register.                                    |                                                              |
| %B2           | 32        | 00 1100 | General purpose register.                                    |                                                              |
| %B3           | 32        | 00 1101 | General purpose register.                                    |                                                              |
| %B4           | 32        | 00 1110 | General purpose register.                                    |                                                              |
| %BR1          | 32        | 00 1111 | General purpose register.                                    | Can be used to store return values                           |
| %BR2          | 32        | 01 0000 | General purpose register.                                    | Can be used to store return values                           |
| %BR3          | 32        | 01 0001 | General purpose register.                                    | Can be used to store return values                           |
| %BSS          | 32        | 01 0010 | General purpose register.                                    | Can be used to indicate the current stack segment base address |
| %BSP          | 32        | 01 0011 | General purpose register.                                    | Can be used to indicate the current stack pointer            |
| %BDS          | 32        | 01 0100 | General purpose register.                                    | Can be used to indicate the current address segment base address |
| %C1           | 32        | 01 0101 | General purpose register.                                    |                                                              |
| %C2           | 32        | 01 0110 | General purpose register.                                    |                                                              |
| %C3           | 32        | 01 0111 | General purpose register.                                    |                                                              |
| %C4           | 32        | 01 1000 | General purpose register.                                    |                                                              |
| %CR1          | 32        | 01 1001 | General purpose register.                                    | Can be used to store return values                           |
| %CR2          | 32        | 01 1010 | General purpose register.                                    | Can be used to store return values                           |
| %CR3          | 32        | 01 1011 | General purpose register.                                    | Can be used to store return values                           |
| %CSS          | 32        | 01 1100 | General purpose register.                                    | Can be used to indicate the current stack segment base address |
| %CSP          | 32        | 01 1101 | General purpose register.                                    | Can be used to indicate the current stack pointer            |
| %CDS          | 32        | 01 1110 | General purpose register.                                    | Can be used to indicate the current address segment base address |
| %D1          | 32        | 01 1111 | General purpose register.                                    |                                                              |
| %D2          | 32        | 10 0000 | General purpose register.                                    |                                                              |
| %D3          | 32        | 10 0001 | General purpose register.                                    |                                                              |
| %D4          | 32        | 10 0010 | General purpose register.                                    |                                                              |
| %DR1         | 32        | 10 0011 | General purpose register.                                    | Can be used to store return values                           |
| %DR2         | 32        | 10 0100 | General purpose register.                                    | Can be used to store return values                           |
| %DR3         | 32        | 10 0101 | General purpose register.                                    | Can be used to store return values                           |
| %DSS         | 32        | 10 0110 | General purpose register.                                    | Can be used to indicate the current stack segment base address |
| %DSP         | 32        | 10 0111 | General purpose register.                                    | Can be used to indicate the current stack pointer            |
| %DDS         | 32        | 10 1000 | General purpose register.                                    | Can be used to indicate the current address segment base address |



## Instructions

All instructions supported by the MACPU are listed below.

---

### Memory Operations

A total of six instructions

---

#### LOAD8

**LOAD8 immediate number, %r / LOAD8 [%r1 (+ %r2)], %r**

Read 8bit immediate value and load it into the specified register

| OP code (10bit) | Target register (%r, 6bit) | (16bit)                                        | Code                       | Example                                  |
| --------------- | -------------------------- | ---------------------------------------------- | -------------------------- | ---------------------------------------- |
| 00 0000 0001    | 00 0001 - 10 1000          | 0000 0000 {immediate number [7-0]}             | LOAD8 immediate number, %r | LOAD8 8, %A1                             |
| 00 0000 0010    | 00 0001 - 10 1000          | 0000 {register 1 [5 - 0]} {register 2 [5 - 0]} | LOAD8 [%r1 (+ %r2)], %r    | LOAD8 [%A1], %A2; LOAD8 [%A1 + %A2], %A3 |

#### LOAD16

**LOAD16 immediate number, %r / LOAD16 [%r1 (+ %r2)], %r**

Read 16bit immediate value and load it into the specified register

| OP code (10bit) | Target register (%r, 6bit) | (16bit)                                        | Code                        | Example                                   |
| --------------- | -------------------------- | ---------------------------------------------- | --------------------------- | ----------------------------------------- |
| 00 0000 0011    | 00 0001 - 10 1000          | {immediate number [15 - 0]}                    | LOAD16 immediate number, %r | LOAD16 33, %A1                            |
| 00 0000 0100    | 00 0001 - 10 1000          | 0000 {register 1 [5 - 0]} {register 2 [5 - 0]} | LOAD16 [%r1 (+ %r2)], %r    | LOAD16 [%A1], %A2; LOAD8 [%A1 + %A2], %A3 |

#### LOAD32

**LOAD32 [%r1 (+ %r2)], %r**

Read 16bit immediate value and load it into the specified register

| OP code (10bit) | Target register (%r, 6bit) | (16bit)                                        | Code                        | Example                                    |
| --------------- | -------------------------- | ---------------------------------------------- | --------------------------- | ------------------------------------------ |
| 00 0000 0101    | 00 0001 - 10 1000          | 0000 {register 1 [5 - 0]} {register 2 [5 - 0]} | LOAD32 immediate number, %r | LOAD32 [%PC + %A1], %A1; LOAD32 [%A2], %A2 |

#### STORE8

**STORE8 %r, [%r1 (+ %r2)]**

Save the lowest 8bit data of the register to the specified address

| OP code (10bit) | Source register (%r, 6bit) | Zero (4bit) | Target register 1 (%r1, 6bit) | Target register 2 (%r, 6bit) | Code                     | Example                                    |
| --------------- | -------------------------- | ----------- | ----------------------------- | ---------------------------- | ------------------------ | ------------------------------------------ |
| 00 0000 0110    | 00 0001 - 10 1000          | 0000        | 00 0001 - 10 1001             | 00 0000 - 10 1000            | STORE8 %r, [%r1 (+ %r2)] | STORE8 %A1, [%A2]; STORE8 %A1, [%A2 + %A3] |

#### STORE16

**STORE16 %r, [%r1 (+ %r2)]**

Save the lowest 16bit data of the register to the specified address

| OP code (10bit) | Source register (%r, 6bit) | (16bit)                                        | Code                      | Example                                      |
| --------------- | -------------------------- | ---------------------------------------------- | ------------------------- | -------------------------------------------- |
| 00 0000 0111    | 00 0001 - 10 1000          | 0000 {register 1 [5 - 0]} {register 2 [5 - 0]} | STORE16 %r, [%r1 (+ %r2)] | STORE16 %A1, [%A2]; STORE16 %A1, [%A2 + %A3] |



| OP code (10bit) | Source register (%r, 6bit) | Zero (4bit) | Target register 1 (%r1, 6bit) | Target register 2 (%r, 6bit) | Code                     | Example                                    |
| --------------- | -------------------------- | ----------- | ----------------------------- | ---------------------------- | ------------------------ | ------------------------------------------ |
| 00 0000 0110    | 00 0001 - 10 1000          | 0000        | 00 0001 - 10 1001             | 00 0000 - 10 1000            | STORE8 %r, [%r1 (+ %r2)] | STORE8 %A1, [%A2]; STORE8 %A1, [%A2 + %A3] |

#### STORE32

**STORE32 %r, [%r1 (+ %r2)]**

Save the 32bit data of the register to the specified address

| OP code (10bit) | Source register (%r, 6bit) | (16bit)                                        | Code                      | Example                                      |
| --------------- | -------------------------- | ---------------------------------------------- | ------------------------- | -------------------------------------------- |
| 00 0000 1000    | 00 0001 - 10 1000          | 0000 {register 1 [5 - 0]} {register 2 [5 - 0]} | STORE32 %r, [%r1 (+ %r2)] | STORE32 %A1, [%A2]; STORE32 %A1, [%A2 + %A3] |

| OP code (10bit) | Source register (%r, 6bit) | Zero (4bit) | Target register 1 (%r1, 6bit) | Target register 2 (%r, 6bit) | Code                     | Example                                    |
| --------------- | -------------------------- | ----------- | ----------------------------- | ---------------------------- | ------------------------ | ------------------------------------------ |
| 00 0000 0110    | 00 0001 - 10 1000          | 0000        | 00 0001 - 10 1001             | 00 0000 - 10 1000            | STORE8 %r, [%r1 (+ %r2)] | STORE8 %A1, [%A2]; STORE8 %A1, [%A2 + %A3] |

---

### Register Operations

A total of one instruction

---

#### MOVE

**MOVE %r1, %r2**

Move the value of one register to another register

| OP code (10bit) | Target register (%r1, 6bit) | Zero (10bit) | Source register (%r2, 6bit) | Code                      | Example                                      |
| --------------- | --------------------------- | ------------ | --------------------------- | ------------------------- | -------------------------------------------- |
| 00 0000 1001    | 00 0001 - 10 1000           | 00 0000 0000 | 00 0000 - 10 1001           | STORE32 %r, [%r1 (+ %r2)] | STORE32 %A1, [%A2]; STORE32 %A1, [%A2 + %A3] |

---

### Integer Operations

Subject to the specific logic implementation required for the execution of each instruction, although the following arithmetic instructions are classified as integer operations, they will be assigned to different arithmetic unit implementations

A total of fifteen instructions

---

#### ADD

**ADD %r, %r1, %rrslt / ADD %r, immediate number, %rrslt**

Integer add, if an immediate value is used in an instruction, some computational precision may be lost

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                             | Example            |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | -------------------------------- | ------------------ |
| 10 0000 0000    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | ADD %r, %r1, %rrslt              | ADD %A1, %A2, %A3  |
| 10 0000 0001    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | ADD %r, immediate number, %rrslt | ADD %A1, 0x3F, %A2 |

#### SUB

**SUB %r, %r1, %rrslt / SUB %r, immediate number, %rrslt / SUB immediate number, %r, %rrslt**

Integer subtraction, if an immediate value is used in an instruction, some computational precision may be lost

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                             | Example            |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | -------------------------------- | ------------------ |
| 10 0000 0010    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | SUB %r, %r1, %rrslt              | SUB %A1, %A2, %A3  |
| 10 0000 0011    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | SUB %r, immediate number, %rrslt | SUB %A1, 0x3F, %A2 |
| 10 0000 0100    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | SUB immediate number, %r, %rrslt | SUB 0b11, %A1, %A2 |

#### BAND

**BAND %r, %r1, %rrslt / BAND %r, immediate number, %rrslt**

Bitwise AND, if an immediate value is used in an instruction, some computational precision may be lost

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                              | Example             |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | --------------------------------- | ------------------- |
| 10 0000 0101    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | BAND %r, %r1, %rrslt              | BAND %A1, %A2, %A3  |
| 10 0000 0110    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | BAND %r, immediate number, %rrslt | BAND %A1, 0x3F, %A2 |

#### BOR

**BOR %r, %r1, %rrslt / BOR %r, immediate number, %rrslt**

Bitwise OR, if an immediate value is used in an instruction, some computational precision may be lost

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                             | Example            |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | -------------------------------- | ------------------ |
| 10 0000 0110    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | BOR %r, %r1, %rrslt              | BOR %A1, %A2, %A3  |
| 10 0000 0111    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | BOR %r, immediate number, %rrslt | BOR %A1, 0x3F, %A2 |

#### BNOT

**BNOT %r, %rrslt / BNOT immediate number, %rrslt**

Bitwise NOT, if an immediate value is used in an instruction, some computational precision may be lost

| OP code (10bit) | Target register (%rrslt, 6bit) | (16bit)                                                      | Code                          | Example        |
| --------------- | ------------------------------ | ------------------------------------------------------------ | ----------------------------- | -------------- |
| 10 0000 1000    | 00 0001 - 10 1000              | 0000 0000 00 {Source register 1 [5 - 0]} (00 0000 - 10 1001) | BNOT %r, %rrslt               | BNOT %A1, %A2  |
| 10 0000 1001    | 00 0001 - 10 1000              | immediate number[15 - 0]                                     | BNOT immediate number, %rrslt | BNOT 0x3F, %A2 |

#### BXOR

**BXOR %r, %r1, %rrslt / BXOR %r, immediate number, %rrslt**

Bitwise XOR, if an immediate value is used in an instruction, some computational precision may be lost

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                              | Example             |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | --------------------------------- | ------------------- |
| 10 0000 1010    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | BXOR %r, %r1, %rrslt              | BXOR %A1, %A2, %A3  |
| 10 0000 1011    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | BXOR %r, immediate number, %rrslt | BXOR %A1, 0x3F, %A2 |

#### RAND

**RAND %r, %rrslt**

Reduced AND

| OP code (10bit) | Target register (%rrslt, 6bit) | (10bit)      | Source register (%r, 6bit) | Code            | Example       |
| --------------- | ------------------------------ | ------------ | -------------------------- | --------------- | ------------- |
| 10 0000 1100    | 00 0001 - 10 1000              | 00 0000 0000 | 00 0001 - 10 1001          | RAND %r, %rrslt | RAND %A1, %A2 |

#### ROR

**ROR %r, %rrslt**

Bitwise OR

| OP code (10bit) | Target register (%rrslt, 6bit) | (10bit)      | Source register (%r, 6bit) | Code           | Example      |
| --------------- | ------------------------------ | ------------ | -------------------------- | -------------- | ------------ |
| 10 0000 1101    | 00 0001 - 10 1000              | 00 0000 0000 | 00 0001 - 10 1001          | ROR %r, %rrslt | ROR %A1, %A2 |

#### RXOR

**RXOR %r, %rrslt**

Bitwise XOR

| OP code (10bit) | Target register (%rrslt, 6bit) | (10bit)      | Source register (%r, 6bit) | Code            | Example       |
| --------------- | ------------------------------ | ------------ | -------------------------- | --------------- | ------------- |
| 10 0000 1110    | 00 0001 - 10 1000              | 00 0000 0000 | 00 0001 - 10 1001          | RXOR %r, %rrslt | RXOR %A1, %A2 |

#### MUL

**MUL %r, %r1, %rrslt / MUL %r, immediate number, %rrslt**

Integer multiplication, if an immediate value is used in an instruction, some computational precision may be lost

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                             | Example            |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | -------------------------------- | ------------------ |
| 10 0000 1111    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | MUL %r, %r1, %rrslt              | MUL %A1, %A2, %A3  |
| 10 0001 0000    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | MUL %r, immediate number, %rrslt | MUL %A1, 0x3F, %A2 |

#### DIV

**DIV %r, %r1, %rrslt / DIV %r, immediate number, %rrslt/ DIV immediate number, %r, %rrslt**

Integer division, if an immediate value is used in an instruction, some computational precision may be lost

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                             | Example            |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | -------------------------------- | ------------------ |
| 10 0001 0001    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | DIV %r, %r1, %rrslt              | DIV %A1, %A2, %A3  |
| 10 0001 0010    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | DIV %r, immediate number, %rrslt | DIV %A1, 0x3F, %A2 |
| 10 0001 0011    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | DIV immediate number, %r, %rrslt | DIV 0b11, %A1, %A2 |

#### LS

**SL %r, %r1, %rrslt / SL %r, immediate number, %rrslt / SL immediate number, %r, %rrslt / SL immediate number 1, immediate number 2, %rrslt**

Left shift register %r1, the number of bits shifted is recorded in %r2, or directly pointed out by the immediate number, low bit fill zero

| OP code (10bit) | Target register (%rrslt, 6bit) | (16bit)                                                      | Code                                              | Example           |
| --------------- | ------------------------------ | ------------------------------------------------------------ | ------------------------------------------------- | ----------------- |
| 10 0001 0100    | 00 0001 - 10 1000              | 0000 {Source register [5 - 0]} {Source register 1 [5 - 0]}   | SL %r, %r1, %rrslt                                | SL %A1, %A2, %A3  |
| 10 0001 0101    | 00 0001 - 10 1000              | immediate number[9-6] {Source register [5 - 0]} immediate number[5-0] | SL %r, immediate number, %rrslt                   | SL %A1, 0x3F, %A2 |
| 10 0001 0110    | 00 0001 - 10 1000              | immediate number[9-6] {Source register [5 - 0]} immediate number[5-0] | SL immediate number, %r, %rrslt                   | SL 0b11, %A1, %A2 |
| 10 0001 0111    | 00 0001 - 10 1000              | {immediate number 1 [9-0]}{immediate number 2 [5-0]}         | SL immediate number 1, immediate number 2, %rrslt | SL 1024, 3, %A1   |

#### LRS

**LRS %r, %r1, %rrslt / LRS %r, immediate number, %rrslt / LRS immediate number, %r, %rrslt / LRS immediate number 1, immediate number 2, %rrslt**

Logic right shift register %r1, the number of bits shifted is recorded in %r2, or directly pointed out by the immediate number, high bit fill zero

| OP code (10bit) | Target register (%rrslt, 6bit) | (16bit)                                                      | Code                                               | Example            |
| --------------- | ------------------------------ | ------------------------------------------------------------ | -------------------------------------------------- | ------------------ |
| 10 0001 1000    | 00 0001 - 10 1000              | 0000 {Source register [5 - 0]} {Source register 1 [5 - 0]}   | LRS %r, %r1, %rrslt                                | LRS %A1, %A2, %A3  |
| 10 0001 1001    | 00 0001 - 10 1000              | immediate number[9-6] {Source register [5 - 0]} immediate number[5-0] | LRS %r, immediate number, %rrslt                   | LRS %A1, 0x3F, %A2 |
| 10 0001 1010    | 00 0001 - 10 1000              | immediate number[9-6] {Source register [5 - 0]} immediate number[5-0] | LRS immediate number, %r, %rrslt                   | LRS 0b11, %A1, %A2 |
| 10 0001 1011    | 00 0001 - 10 1000              | {immediate number 1 [9-0]}{immediate number 2 [5-0]}         | LRS immediate number 1, immediate number 2, %rrslt | LRS 1024, 3, %A1   |

#### ARS

**ARS %r, %r1, %rrslt / ARS %r, immediate number, %rrslt / ARS immediate number, %r, %rrslt / ARS immediate number 1, immediate number 2, %rrslt**

Algorithm right shift register %r1, the number of bits shifted is recorded in %r2, or directly pointed out by the immediate number, high bit complements the same number as the sign bit

| OP code (10bit) | Target register (%rrslt, 6bit) | (16bit)                                                      | Code                                               | Example            |
| --------------- | ------------------------------ | ------------------------------------------------------------ | -------------------------------------------------- | ------------------ |
| 10 0001 1100    | 00 0001 - 10 1000              | 0000 {Source register [5 - 0]} {Source register 1 [5 - 0]}   | ARS %r, %r1, %rrslt                                | ARS %A1, %A2, %A3  |
| 10 0001 1101    | 00 0001 - 10 1000              | immediate number[9-6] {Source register [5 - 0]} immediate number[5-0] | ARS %r, immediate number, %rrslt                   | ARS %A1, 0x3F, %A2 |
| 10 0001 1110    | 00 0001 - 10 1000              | immediate number[9-6] {Source register [5 - 0]} immediate number[5-0] | ARS immediate number, %r, %rrslt                   | ARS 0b11, %A1, %A2 |
| 10 0001 1111    | 00 0001 - 10 1000              | {immediate number 1 [9-0]}{immediate number 2 [5-0]}         | ARS immediate number 1, immediate number 2, %rrslt | ARS 1024, 3, %A1   |

#### LCS

**LCS %r, %r1, %rrslt / LCS %r, immediate number, %rrslt / LCS immediate number, %r, %rrslt / LCS immediate number 1, immediate number 2, %rrslt**

Left circular shift register %r1, the number of bits shifted is recorded in %r2, or directly pointed out by the immediate number

| OP code (10bit) | Target register (%rrslt, 6bit) | (16bit)                                                      | Code                                               | Example            |
| --------------- | ------------------------------ | ------------------------------------------------------------ | -------------------------------------------------- | ------------------ |
| 10 0010 0000    | 00 0001 - 10 1000              | 0000 {Source register [5 - 0]} {Source register 1 [5 - 0]}   | LCS %r, %r1, %rrslt                                | LCS %A1, %A2, %A3  |
| 10 0010 0001    | 00 0001 - 10 1000              | immediate number[9-6] {Source register [5 - 0]} immediate number[5-0] | LCS %r, immediate number, %rrslt                   | LCS %A1, 0x3F, %A2 |
| 10 0010 0010    | 00 0001 - 10 1000              | immediate number[9-6] {Source register [5 - 0]} immediate number[5-0] | LCS immediate number, %r, %rrslt                   | LCS 0b11, %A1, %A2 |
| 10 0010 0011    | 00 0001 - 10 1000              | {immediate number 1 [9-0]}{immediate number 2 [5-0]}         | LCS immediate number 1, immediate number 2, %rrslt | LCS 1024, 3, %A1   |

---

### Branch Operations

A total of five instructions

---

#### GT

**GT %r, %r1, %rrslt / GT %r, immediate number, %rrslt**

If %r1 is greater than %r2 or immediate number, the %rrslt will be set to 1, otherwise 0

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                            | Example           |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | ------------------------------- | ----------------- |
| 10 0100 0000    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | GT %r, %r1, %rrslt              | GT %A1, %A2, %A3  |
| 10 0100 0001    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | GT %r, immediate number, %rrslt | GT %A1, 0x3F, %A2 |

#### EQ

**EQ %r, %r1, %rrslt / EQ %r, immediate number, %rrslt**

If %r1 is equal to %r2 or immediate number, the %rrslt will be set to 1, otherwise 0

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                            | Example           |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | ------------------------------- | ----------------- |
| 10 0100 0010    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | EQ %r, %r1, %rrslt              | EQ %A1, %A2, %A3  |
| 10 0100 0011    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | EQ %r, immediate number, %rrslt | EQ %A1, 0x3F, %A2 |

#### LT

**LT %r, %r1, %rrslt / LT %r, immediate number, %rrslt**

If %r1 is less than %r2 or immediate number, the %rrskt will be set to 1, otherwise 0

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                            | Example           |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | ------------------------------- | ----------------- |
| 10 0100 0100    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | LT %r, %r1, %rrslt              | LT %A1, %A2, %A3  |
| 10 0100 0101    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | LT %r, immediate number, %rrslt | LT %A1, 0x3F, %A2 |

#### GTE

**GTE %r, %r1, %rrslt / GTE %r, immediate number, %rrslt**

If %r1 is greater or equal to %r2 or immediate number, the %rrslt will be set to 1, otherwise 0

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                             | Example            |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | -------------------------------- | ------------------ |
| 10 0100 0110    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | GTE %r, %r1, %rrslt              | GTE %A1, %A2, %A3  |
| 10 0100 0111    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | GTE %r, immediate number, %rrslt | GTE %A1, 0x3F, %A2 |

#### LTE

**LTE %r, %r1, %rrslt / LTE %r, immediate number, %rrslt**

If %r1 is less or equal to %r2 or immediate number, the %rrslt will be set to 1, otherwise 0

| OP code (10bit) | Target register (%rrslt, 6bit) | (4bit)                | Source register (%r, 6bit) | (6bit)                                        | Code                             | Example            |
| --------------- | ------------------------------ | --------------------- | -------------------------- | --------------------------------------------- | -------------------------------- | ------------------ |
| 10 0100 1000    | 00 0001 - 10 1000              | 0000                  | 00 0000 - 10 1001          | Source register 1 [5 - 0] (00 0000 - 10 1001) | LTE %r, %r1, %rrslt              | LTE %A1, %A2, %A3  |
| 10 0100 1001    | 00 0001 - 10 1000              | immediate number[9-6] | 00 0000 - 10 1001          | immediate number[5-0]                         | LTE %r, immediate number, %rrslt | LTE %A1, 0x3F, %A2 |

---

### Jump Operations

A total of three instructions

---

#### JMP

**JMP [immediate number address] / JMP [%r1 (+ %r2)]**

Unconditionally jump to the specified instruction

| OP code (10bit) | (22bit)                                                | Code                           | Example                    |
| --------------- | ------------------------------------------------------ | ------------------------------ | -------------------------- |
| 11 0000 0000    | immediate number[21-0]                                 | JMP [immediate number address] | JMP [223]; JMP LABEL       |
| 11 0000 0001    | 00 0000 0000 {register 1 [5 - 0]} {register 2 [5 - 0]} | JMP [%r1 (+ %r2)]              | JMP [%PC + %A2]; JMP [%A1] |

#### OJMP

**OJMP %r, [immediate number address] / OJMP %r, [%r1 (+ %r2)]**

Jump to the specified address when the value of the register %r is 1

| OP code (10bit) | (22bit)                                                | Code                            | Example                     |
| --------------- | ------------------------------------------------------ | ------------------------------- | --------------------------- |
| 11 0000 0010    | immediate number[21-0]                                 | OJMP [immediate number address] | OJMP [223]; JMP LABEL       |
| 11 0000 0011    | 00 0000 0000 {register 1 [5 - 0]} {register 2 [5 - 0]} | OJMP [%r1 (+ %r2)]              | OJMP [%PC + %A2]; JMP [%A1] |

#### ZJMP

**ZJMP %r, [immediate number address] / ZJMP %r, [%r1 (+ %r2)]**

Jump to the specified address when the value of the register %r is 0

| OP code (10bit) | (22bit)                                                | Code                            | Example                     |
| --------------- | ------------------------------------------------------ | ------------------------------- | --------------------------- |
| 11 0000 0100    | immediate number[21-0]                                 | ZJMP [immediate number address] | ZJMP [223]; JMP LABEL       |
| 11 0000 0101    | 00 0000 0000 {register 1 [5 - 0]} {register 2 [5 - 0]} | ZJMP [%r1 (+ %r2)]              | ZJMP [%PC + %A2]; JMP [%A1] |

---

