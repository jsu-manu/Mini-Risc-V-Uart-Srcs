# Mini Risc-V with UART

This is an FPGA implementation of a RISC-V processor, reprogrammable via serial communication. <!-- Instructions and scripts for programming it can be found in my other repository [here](https://github.com/gbruner7607/Mini-Risc-V-gcc) -->
<br>
The original Mini-Risc-V Core was designed by Md Badruddoja Majumder. I've made some modifications including implementing a reprogrammable instruction memory (currently disabled), as well as restructuring the memory module to pave the way for a more complex and comprehensive memory hierarchy. The memory structure has been altered such that instructions and data are in a shared memory space. This is a work in progress.

<hr>

## Overview

![](overview.png)

<hr>

## Known Issues

* UART currently does not work with programs loaded onto the core with reprogram.py. You have to load the program directly in the block memory in order for UART to work. Do this by going into the IP core settings for `blk_mem_gen_0` and under `Other Options > Load init file`, load your program.coe. Then resynthesize.

<hr>

## Software Toolchain

Also included in the `gcc` folder is a python script, called `pycompile.py`, that allows you to compile c code into a coe file for use with the core.  This requires the riscv toolchain to be installed, targeted for rv32i. Additionally you'll need to use the included `boot.S` and `test.ld` files, but you may supply a bootloader or linker script of your own if you wish.

`./pycompile.py <options> files`

<hr>

### Installing the Software Toolchain

In order to compile c code, you must install the RISC-V toolchain. We use the one provided by UC-Berkely for their rocket chip, because it also includes the spike simulator.

**Note that this will take a long time**

*Installing the toolchain is as follows*

```bash
$ git clone https://github.com/freechipsproject/rocket-tools
$ git submodule update --init --recursive
$ export RISCV=path/to/where/you/want/toolchain/installed
```

Next, open `build-rv32ima.sh` and edit the two lines starting with `build_project`. Change the `--with-isa=rv32ima` parameter to `--with-isa=rv32ic`. Our core does not support the `m` or `a` extensions of RISC-V yet. Then just run that script.

```bash
$ ./build-rv32ima.sh
```

*You can also install just the toolchain without the simulator using just the toolchain repo*

```bash
$ git clone https://github.com/riscv/riscv-gnu-toolchain
$ cd riscv-gnu-toolchain
$ ./configure --prefix=/path/to/where/you/want/toolchain/installed --with-arch=rv32ic
$ make
```

Now that the toolchain is installed, make sure that it's in your PATH. Type the following line, or put it in your `~/.bashrc` to make the change permanent:

```bash
export PATH="path/to/toolchain/bin:$PATH"
```

<hr>

## IP Cores

A number of IP cores are used that must be included and configured as below:

```
Clocking Wizard

Clocking Options
  Primitive: MCMM
  Clocking Features: Frequency Synthesis
  Jitter Optimization: Balanced
  Input Clock Information:
    Input Clock:Primary
    Port Name: clk
    Input Frequency: 100
    Input Jitter 0.010
  Leave other options as default

Output Clocks
  clk_out1:
    port name: clk_50M
    output freq: 50 (25 if timing fails)
    Duty Cycle: 50
  clk_out2
    port name: clk_5M
    output freq: 5
    Duty Cycle: 50

  uncheck the "reset" and "locked" options under Enable Optional Inputs/Outputs for MMCM/PLL
```

<!-- ```
Block Memory Generator

Component name: blk_mem_gen_0

Basic
  Interface Type: Native
  Memory Type: True Dual Port RAM
  Check generate address interface with 32 bits
  ECC Type: No ECC
  Write Enable:
    Byte Write Enable: Checked
    Byte size: 8
  Algorithm Options:
    Minimum area

Port A Options:
  Write & Read Width: 32
  Write & Read Depth: 131072 (For Basys3: 50176)
  Operating Mode: Write First
  Enable Port Type: Use ENA pin
  Uncheck Primitves output register & RSTA pin

Port B Options:
  Set up identical to Port A

Other Options:
  Load init file: Check, and include a coe file of your choice
  Fill Remaining Memory Locations: 0
``` -->

```
Block RAM Cells

Component name: mem_cell_0/1/2/3 and imem_cell_0/1/2/3

Basic
  Interface Type: Native
  Memory Type: Single Port RAM
  ECC Type: No ECC
  Write Enable: Unchecked
  Algorithm Options: Minimum Area

Port A Options:
  Write & Read width: 8
  Write & Read depth: 16384
  Operating Mode: Write first
  Enable Port Type: Use ENA pin
  Uncheck Primitives output register and RSTA pin

Other Options:
  Check Fill Remaining Memory Locations
```

```
Fifo Generator

Basic
  Interface Type: Native
  Implementation: Common Clock Builtin FIFO

Native Ports
  Read Mode: Standard FIFO
  Data Port Parameters
    Write Width: 8
    Write Depth: 512
```

<!--```
Return Address Stack BlockRAM

Basic
  Interface Type: Native
  Implementation: Single Port RAM
  Generate Address with 32 bits: Checked
  No ECC

Port A Options
  Write & Read Width: 32
  Write & Read Depth: 4096
  Operating Mode: Write First
  Enable Port Type: Use ENA Pin
  Primitives Output Register: Unchecked
  RSTA Pin: Unchecked
```-->

<hr>

## Programming the Core

A c program may be compiled and loaded onto the core as a `.coe` file for the block memory. Within the `gcc` folder is a number of example and test programs, as well as a python script called `pycompile.py`. This script leverages the riscv toolchain to compile an ELF file, which is converted into a coe. It can also create a plain hex file for loading onto the core with the in-development kernel.

Example:

*Compile hex file*
```
./pycompile.py -s -x -o test.hex test.c uart.c utils.c
```

*Convert to coe files for memory cells & generate tcl script*
You'll want to change the first line of `hex2coe.py` to point to `<where this repo is installed>/gcc/`
```
python hex2coe.py test.hex
```

*In Vivado TCL console*
```
cd <where this repo is installed>/gcc
source loadcoe.tcl
```

#### Communication with the Core

Communication to and from the core is done using UART, with a baud rate of 115200. Source files for using uart are in the gcc folder, specifically `uart.c` and `uart.h`, which rely on `utils.c` for some key functions, as the core does not currently support the C standard library.

#### Some useful libraries

`uart.c` has the drivers for uart communication. `uart_init()` MUST be called before any serial communication can occur, as this function sets up the baud rate divisors.

`counter.c` can be used to set, reset, and check a built-in counter. This is useful for performance evaluations.

`CRAS.c` has the drivers for the Cryptographic Return Address Stack (CRAS). You can enable/disable it and change the encryption key.

`utils.c` has some functions such as implementing multiplication/division. You need to include it as well when using serial communication.

`spi.c` has the drivers for the SPI master interface.

<hr>

## Mini-RISC-V Program Kernel

This feature is currently in development. It is a software kernel that is loaded by default onto the core, that allows binaries to be loaded over a serial port and executed. The kernel is not currently supported for implementing the core on the basys3.

The kernel can be compiled using the `pycompile.py` script as so:
```
./pycompile.py -s -l kernel.ld -b kboot.S -o kernel kernel.c uart.c utils.c
```

Then programs can be compiled for use with the kernel using the `prog.ld` linker script, then loaded onto the core as such:
```
./pycompile.py -s -l prog.ld -o testprog.hex testprog.c uart.c utils.c
./reprogram.py -p <SERIAL PORT> testprog.hex
```

<hr>

## Steps summary:

Implementation on Nexys4:
Top module file: rv_uart_top.sv
Constraint file: riscvcore.xdc

Implementation on Basys3:
Top module file: rv_uart_top_basys3.sv
Constraint file: riscvcore_basys3.xdc
Note: disable contrandicting files from the project hierarchy: rv_uart_top.sv, risvcore.xdc



->Before synthesizing
	Load the resulting `kernel.coe` file into the Block RAM IP.
->Synthesize, Implement and generate bitstream
->Load the bit file to the FPGA using hardware manager
->After bitstream generation
	Compile the program you want to load using pycompile normally, then use `reprogram.py` to transmit the hex file to the board.
	see the help menu for reprogram.py for usage. The default port for usb is /dev/ttyUSB1 and default baudrate is 115200. You can also 		input the usb port and baud rate from the terminal while running the program. The required argument is the hex file of the program you 		want to load to the miniRISC-V core.

Testing print() on 7 seg display:
Function Mode:
debug switch (SW 15) -> OFF
Prog  switch (SW 14) -> OFF
Printed out integers can be seen on the 7 seg display. The debug_input[4:0] signal can be used to display printed value according to their order in the code e.g. debug_input=5'b00000 shows the most recent printed value, 5'b00001 shows the second most recent printed value and so on.

Register File Debug Mode:
debug switch (SW 15) -> ON
Prog  switch (SW 14) -> OFF
Registers can be seen on the 7 seg display. The debug_input[4:0] signal can be used to display a particular register file represented by the debug_input value e.g. debug_input=5'b00001 register x1, 5'b00002 shows the register x2 and so on.Register File Debug Mode:

Program Debug Mode:
debug switch (SW 15) -> OFF
Prog  switch (SW 14) -> ON
Loaded instructions can be seen on the 7 seg display. The debug_input[4:0] signal can be used to display the first 32 instructions loaded into the memory.




UART test:
For a quick test of the UART interface, there is a c code named uartTest.c and python application named pyterminal.py. The c code simply reads a byte from the uart receiver and writes back to the transmitter. You have to program the core with uartTest.hex using reprogram.py. On the PC end, run the pyterminal.py. It will asks user to input a character and then echo back the character sent by the uartTest.c program in the miniRISC-V core.
