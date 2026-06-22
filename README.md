# Simple Processor FPGA

A 9-bit simple processor implemented in SystemVerilog, simulated, synthesized, and tested on an Intel FPGA board.

This project demonstrates how a basic processor executes instructions step by step using registers, a shared bus, an ALU, and a finite state machine control unit.

---

## Project Overview

The processor receives 9-bit input through `DIN[8:0]`.

This input can represent either:

- an instruction
- immediate data

depending on the current execution state of the processor.

The processor includes:

- 8 general-purpose registers: `R0` to `R7`
- Instruction register: `IR`
- Internal register: `A`
- Result register: `G`
- Shared 9-bit bus
- Multiplexer for selecting the bus source
- ALU for arithmetic and custom operations
- Control unit implemented as a finite state machine
- `Run` signal to start execution
- `Done` signal to indicate that the instruction is finished

The FPGA implementation allows the user to enter instructions manually using switches and step through the processor execution using a pushbutton clock.

---

## Instruction Format

Each instruction is 9 bits wide:

```text
III XXX YYY
```

Where:

```text
III = opcode
XXX = Rx register
YYY = Ry register
```

Register encoding:

```text
R0 = 000
R1 = 001
R2 = 010
R3 = 011
R4 = 100
R5 = 101
R6 = 110
R7 = 111
```

---

## Supported Instructions

| Instruction | Opcode | Operation |
|---|---|---|
| `mv Rx, Ry` | `000` | `Rx <- Ry` |
| `mvi Rx, #D` | `001` | `Rx <- D` |
| `add Rx, Ry` | `010` | `Rx <- Rx + Ry` |
| `sub Rx, Ry` | `011` | `Rx <- Rx - Ry` |
| `ones Rx, Ry` | `100` | `Ry <- number of 1 bits in Rx` |
| `specialMult Rx, Ry` | `101` | `Ry <- Rx * 3.5` |

---

## Main Processor Operations

### `mv Rx, Ry`

Copies the value from register `Ry` into register `Rx`.

Example:

```text
mv R1, R0
```

Meaning:

```text
R1 <- R0
```

Instruction encoding:

```text
000 001 000
```

---

### `mvi Rx, #D`

Loads an immediate value from `DIN` into register `Rx`.

Example:

```text
mvi R0, #3
```

First input the instruction:

```text
001 000 000
```

Then input the immediate data:

```text
000 000 011
```

Final result:

```text
R0 = 3
```

---

### `add Rx, Ry`

Adds two registers and stores the result back into `Rx`.

Example:

```text
add R0, R1
```

Meaning:

```text
R0 <- R0 + R1
```

Instruction encoding:

```text
010 000 001
```

---

### `sub Rx, Ry`

Subtracts `Ry` from `Rx` and stores the result back into `Rx`.

Example:

```text
sub R0, R1
```

Meaning:

```text
R0 <- R0 - R1
```

Instruction encoding:

```text
011 000 001
```

---

## Custom Instructions

### `ones Rx, Ry`

The `ones` instruction counts how many bits with value `1` exist in register `Rx`.

The result is stored in register `Ry`.

Example:

```text
Rx = 000110011
```

There are four bits equal to `1`, so:

```text
Ry = 000000100
```

Example instruction:

```text
ones R0, R2
```

Instruction encoding:

```text
100 000 010
```

---

### `specialMult Rx, Ry`

The `specialMult` instruction multiplies the value in `Rx` by `3.5` and stores the result in `Ry`.

The implementation avoids using an explicit multiplier.

Since:

```text
Rx * 3.5 = Rx * 2 + Rx + Rx / 2
```

the operation can be implemented using shifts and addition:

```text
Ry = (Rx << 1) + Rx + (Rx >> 1)
```

This instruction assumes that `Rx` contains an even number.

Example:

```text
specialMult R0, R3
```

If:

```text
R0 = 6
```

Then:

```text
R3 = 21
```

Instruction encoding:

```text
101 000 011
```

---

## FPGA Board Mapping

| FPGA Component | Processor Signal | Function |
|---|---|---|
| `SW[8:0]` | `DIN[8:0]` | Instruction/data input |
| `SW[9]` | `Run` | Start instruction execution |
| `KEY[0]` | `Resetn` | Active-low reset |
| `KEY[1]` | `Clock` | Manual clock input |
| `LEDR[8:0]` | `Bus[8:0]` | Shows current bus value |
| `LEDR[9]` | `Done` | Instruction finished indicator |

---

## How the Processor Works

The processor executes one instruction at a time.

The general flow is:

```text
1. The user places an instruction on SW[8:0]
2. The user turns Run on using SW[9]
3. On the clock edge, the instruction is loaded into IR
4. The control FSM decodes the instruction
5. The FSM activates the required control signals
6. Data moves through the shared bus
7. Registers are updated on clock edges
8. Done is asserted when the instruction is complete
```

The shared bus is used to move data between registers, the `DIN` input, and the ALU result register.

Only one source should drive the bus at a time.

---

## Manual FPGA Testing

For most instructions:

```text
1. Set SW[8:0] to the instruction
2. Turn SW[9] = 1
3. Press KEY[1] until Done turns on
4. Turn SW[9] = 0
5. Prepare the next instruction
```

For `mvi`, the instruction uses two inputs:

```text
1. Set SW[8:0] to the mvi instruction
2. Turn SW[9] = 1
3. Press KEY[1] once
4. Change SW[8:0] to the immediate data value
5. Press KEY[1] again
6. Wait for Done
7. Turn SW[9] = 0
```

---

## Example Test Run: 3 + 4 = 7

Goal:

```text
R0 = 3
R1 = 4
R0 = R0 + R1
Expected result: R0 = 7
```

### Step 1: Load 3 into R0

Instruction:

```text
mvi R0, #3
```

Enter:

```text
001000000
```

Then enter data:

```text
000000011
```

Expected result:

```text
R0 = 3
```

---

### Step 2: Load 4 into R1

Instruction:

```text
mvi R1, #4
```

Enter:

```text
001001000
```

Then enter data:

```text
000000100
```

Expected result:

```text
R1 = 4
```

---

### Step 3: Add R0 and R1

Instruction:

```text
add R0, R1
```

Enter:

```text
010000001
```

Expected result:

```text
R0 = 7
```

---

### Step 4: Check the Result

The LEDs show the bus, not the internal registers directly.

To check `R0`, execute:

```text
mv R0, R0
```

Instruction:

```text
000000000
```

Expected LED output:

```text
LEDR[8:0] = 000000111
```

This confirms that:

```text
R0 = 7
```

---

## Test Plan

| Test | Purpose | Instruction/Input | Expected Result |
|---|---|---|---|
| T1 | Reset test | Press `KEY[0]` | Processor returns to initial state |
| T2 | Load immediate into R0 | `mvi R0,#3` | `R0 = 3` |
| T3 | Load immediate into R1 | `mvi R1,#4` | `R1 = 4` |
| T4 | Move register value | `mv R2,R0` | `R2 = 3` |
| T5 | Addition | `add R0,R1` | `R0 = 7` |
| T6 | Subtraction | `sub R0,R1` | `R0 = 3` |
| T7 | Count ones | `ones R0,R3` | `R3 = number of 1 bits in R0` |
| T8 | Special multiplication | `specialMult R0,R4` | `R4 = R0 * 3.5` |
| T9 | Bus verification | `mv Rx,Rx` | Selected register value appears on LEDs |
| T10 | Full chained execution | Multiple instructions | Final register values match expected results |

---

## Simulation

Functional simulation was used to verify the processor before FPGA testing.

The simulation verifies:

- Instruction loading into `IR`
- Register transfers through the bus
- Immediate loading using `mvi`
- Addition and subtraction
- Custom instruction behavior
- FSM state transitions
- Correct assertion of `Done`

---

## Timing Analysis

After functional simulation, the design was synthesized and analyzed for timing.

Timing analysis was used to determine the maximum operating frequency of the processor and verify that the circuit meets timing requirements after synthesis.

---

## What We Learned

Through this project, we learned how a simple processor works at the hardware level.

Main concepts practiced:

- SystemVerilog hardware design
- Register-transfer level design
- Shared bus architecture
- Multiplexer-based data movement
- FSM-based control
- Instruction encoding and decoding
- ALU operation implementation
- FPGA pin assignment
- Functional simulation
- Timing simulation
- Manual FPGA testing using switches, pushbuttons, and LEDs
- Hardware debugging by stepping through clock cycles

---

## Conclusion

This project shows how a processor can be built from basic digital hardware blocks.

By manually entering instructions through FPGA switches and stepping through execution using a pushbutton clock, the internal operation of the processor becomes visible and easier to understand.

The final processor supports register movement, immediate loading, arithmetic operations, and two custom hardware instructions.
