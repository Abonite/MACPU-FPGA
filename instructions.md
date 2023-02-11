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



## Memory Operations

### LOAD8

**LOAD8 immediate number, %r / LOAD8 [address], %r**

Read 8bit immediate value and load it into the specified register

---

### LOAD16

**LOAD16 immediate number, %r / LOAD16 [address], %r**

Read 16bit immediate value and load it into the specified register

---

### LOAD32

**LOAD32 immediate number, %r / LOAD32 [address], %r**

Read 16bit immediate value and load it into the specified register

----

### STORE8

**STORE8 %r, [address]**

Write 8bit immediate value and load it into the specified register

---

### STORE16

**STORE16 %r, [address]**

Write 16bit immediate value and load it into the specified register

---

### STORE32

**STOR32 %r, [address]**

Write32bit immediate value and load it into the specified register

---



## Register Operations

### MOVE

**MOVE %r1, %r2**

Move the value of one register to another register

---



## Integer Operations

### USADD

**USADD %r1, %r2, %rrslt**

****

### SADD

**SADD %r1, %r2, %rrslt**

---



## Branch Operations





## Jump Operations





## Logic Operations





## Interrupt Operations

