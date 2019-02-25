# Stop Crying Over Your Cache Miss Rate: Handling Efficiently Thousands of Outstanding Misses in FPGAs

This repository contains the full Chisel source code of a highly flexible, FPGA-optimized, multi-banked non-blocking cache. The block RAM-based MSHRs (miss status holding registers) can support tens of thousands of outstanding misses, minimizing pipeline stalls due to the memory system and increasing the performance of bandwidth-bound, latency insensitive accelerators.

Full details are provided in the [wiki](https://github.com/m-asiatici/MSHR-rich/wiki) and in our paper:

[Mikhail Asiatici and Paolo Ienne. 2019. Stop Crying Over Your Cache Miss
Rate:, Handling Efficiently Thousands of Outstanding Misses in FPGAs. In
The 2019 ACM/SIGDA International Symposium on Field-Programmable Gate
Arrays (FPGA ’19), February 24–26, 2019, Seaside, CA, USA.](https://doi.org/10.1145/3289602.3293901)

Please cite that paper when using this hardware module.

## Overview
![System block diagram](doc/system.svg)

The full pipeline is as follows:
1) **Validation and generation of the configuration file**. Use our System Configurator GUI to generate a valid configuration for the non-blocking cache. Refer to the Wiki for the full documentation on the parameters.
2) **Chisel build**, which generates a set of Verilog and `.hex` files (for BRAM initialization).
3) **IP-XACT packaging**. Based on [Jens Korinth's scripts](https://github.com/jkorinth/chisel-packaging) which use Vivado to automatically infer the AXI4 interfaces.
4) **Vivado project generation.** A `.tcl` script creates a Vivado project which integrates the non-blocking cache with four simple sparse matrix-vector multiplication accelerators.

The full pipeline has been tested with **Vivado 2017.4** and on a **Zynq ZC706** board. However, step 1) and 2) should be device- and vendor-agnostic -- please open an issue if you find an incompatibility

## Requirements

The flow has been tested on Ubuntu 18.04.

### [Chisel 3](https://github.com/freechipsproject/chisel3)
1) Install Java:
```
sudo apt-get install default-jdk
```
2) Install [sbt](https://www.scala-sbt.org/release/docs/Installing-sbt-on-Linux.html):
```
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
sudo apt-get update
sudo apt-get install sbt
```
3) Verilator is NOT required.

### Vivado
Make sure that Vivado is properly configured and that the `vivado` executable is in `PATH`. An easy way to achieve this is to source `settings64.sh` in the Vivado installation folder.

### Python
Ubuntu 18.04 should already have at least Python 2, but just in case:
`sudo apt-get install python3 python`

## Chisel build (GUI)
1) Launch `MSHR_configurator`
2) Either create a new configuration file (File -> New) or open an existing one (File -> Open)
3) Once you completed your configuration, click on Check under Configuration Status to verify its validity
4) If the configuration is valid, click on Generate Vivado IP to generate the memory system as an IP-XACT compatible with the Vivado IP integrator. The IP will be in `output/ip`.
5) If you get `[error] (run-main-0) java.lang.RuntimeException: Nonzero exit value: 1`, make sure that `vivado` is in `PATH` and that its license is properly set up. We recommend to run the `MSHR_configurator` from a terminal after configuring Vivado as described in **Requirements/Vivado** instead of double clicking on it from the Linux GUI.

## Chisel build (manual)
1) Create a configuration file, either with the `MSHR_configurator` or fully manually (not recommended unless you really know what you are doing). configuration. If you don't validate the configuration with the `MSHR_configurator`, be prepared to go through the source code in case one of the Chisel `require()` that validate the parameters fails.
2) From the root of the repository, run:
   - `sbt "test:runMain fpgamshr.main.FPGAMSHRIpBuilder [path to the configuration file]"` to generate Verilog, `.hex` and package them in an IP-XACT compatible with the Vivado IP Integrator.
   - `sbt "test:runMain fpgamshr.main.FPGAMSHRVerilog [path to the configuration file]"` to only generate the Verilog and `.hex` files.

## Replication of the results from the [FPGA'19 paper](https://doi.org/10.1145/3289602.3293901)
We provide scripts to generate a sample Vivado project that replicates the results discussed in our [FPGA'19 paper](https://doi.org/10.1145/3289602.3293901). The system contains a non-blocking cache with four input ports, connected to four sparse matrix-vector accelerators. The ARM processor:
1) reads the input data -- sparse matrices and dense vectors -- from the SD card
2) writes it to the DDR (vector to the PL DDR, all the rest to the PS DDR)
3) manages the DMAs
4) starts the accelerators
5) polls the accelerators and the DMAs
6) collects data from the profiling registers of the non-blocking cache

### Input data generation

All the matrices we used in the paper are on [SuiteSparse](https://sparse.tamu.edu/). The `util/mm_matrix_to_csr.py` Python script converts a matrix in MatrixMarket format to the binary format expected by the C code for the ARM processor.
Example invocation:
```
mkdir matrices
cd matrices
python3 ../util/mm_matrix_to_csr.py -a 1..4 -i matrix.mtx
```
The script generates a folder structure that should be copied as it is to an SD card formatted with FAT file system. In the example above, you should copy all the *content* of the `matrices` folder to the SD card, except for the `.mtx` and `.pickle` files. In other words, the root of the SD card should contain one folder per benchmark, each containing one folder per possible number of parallel accelerators (1 to 4 in the example above).

### Vivado project generation

1) Create an IP package as described in **Chisel build**. In the paper, we used the following parameters:
  - 4 inputs
  - input address width: 27
  - input data width: 32
  - input ROB depth: 8192
  - 4 banks
  - 4-way set-associative cache
  - last pointer cache size: 8
  - subentries per row: 3
  - external memory address width: 32
  - external memory address offset: 0x80000000
  - external memory data width: 512
  - external memory max outstanding requests: 64
  The other parameters have been swept depending on the design point.
2) Either click on Generate Script from the `MSHR_configurator`, or run `sbt "test:runMain fpgamshr.main.FPGAMSHRVivadoBuilder [path to configuration file]"`. This will also generate the orchestration software (see next section).
3) Generate and compile the system:
```
cd output/vivado
vivado -mode batch -source generator.tcl # Remove `-mode batch` to get Vivado to run in GUI mode during system generation and compilation
```

After compilation:
1) Open the Vivado project in `output/vivado/spmv_mult_design/spmv_mult_design.xpr`
2) File -> Export -> Export hardware -> OK
3) File -> Launch SDK -> OK

### Xilinx SDK project creation
From the Xilinx SDK:
1) File -> New -> Application Project
2) Choose a project name, use the default values for all the rest:
   - Check Use default location
   - OS Platform: standalone
   - Target Hardware Platform: design_1_wrapper_hw_platform_0,
   - Processor: ps7_cortexa9_0
   - Language: C
   - Create new Board Support Package
3) Click on Next
4) Select Empty Application, click on Finish
5) In the Project Explorer, normally on the left hand side of Xilinx SDK, right click on the BSP project (yourProjectName_bsp) -> Board Support Package Settings
6) Under Supported Libraries, check `xilffs`. We will use this library to read the input matrices and vectors from the SD card.
7) In the Project Explorer, expand your project and right click on the `src` folder -> Import... ->
8) General -> File System -> Next
9) Browse... -> Navigate to `output/sw` -> Select all files -> Check Overwrite existing resources without warning (we will overwrite the default loader script)
10) In `zynq_code.c`, add the benchmarks that you want to run to the `benchmarks` array and update `NUM_BENCHMARKS` accordingly. Use the same names as the respective folder in the SD card (see **Input data generation**)

### Running the ARM software
The software has a triple nested for loop for the experiments:
```
foreach benchmark in benchmarks:
    foreach num_acc in 1..4:
        foreach cache_size_divider in 0..CACHE_SIZE_REDUCTION_VALUES:
            execute benchmark on num_acc accelerators with a cache size of CACHE_SIZE/(2 ^ cache_size_divider)
        execute benchmark on num_acc accelerators with no cache
```
(check the wiki for additional information on CACHE_SIZE_REDUCTION_VALUES)
The ARM prints out debug and performance information via UART (8 data bits, no parity, no flow control, 1 stop bit, baud rate **921600** bps). By default, the code prints out the parameters of each run (benchmark, number of accelerators, cache size) as well as the performance measurements (runtime and a number of internal performance counters) in a table format that can be easily copy-pasted as it is for data analysis. Uncomment the call to `FPGAMSHR_Get_stats_pretty()` to print out a much more verbose dump of all internal performance registers after each run.

## License

- in general¸ `LICENSE` in the repository root applies
- `src/main/scala/packaging/LICENSE` applies to:
  - `src/main/resources/axi4.py`
  - `src/main/resources/package.py`
  - `src/main/scala/packaging`
- header of `src/main/scala/util/ResettableRRArbiter.scala` applies to the rest of the file

## Contact
If you find any bugs please open an issue. For all other questions, including getting access to the development branch, please contact Mikhail Asiatici (firstname dot lastname at epfl dot ch).
