**Folder Structure of the project**:

_design_ - Contains the design files for the MESI design.

_gold_ - Contains the memory model

_sim_ - Contains the simulation and run files.

_uvm_ - Contains the testbench files(interfaces, monitor, sequencer, Driver, Scoreboard etc..,)

_test_ - Contains the directed and random test cases.

**About the design**:

The Design is targeted at developing a DUT comprising of L1 and L2 cache systems which can be utilized for undertaking functional verification. The DUT works in an environment which contains 4 processor stubs for each L1, a bus system to carry out transactions among L1 caches and also between L1 & L2, an arbiter to determine bus access, and a stub for main memory. The DUT implements functional aspects of L1 cache coherency protocols and hence may not contain performance upgrades/components. The basic block representation of the system is as shown below:

<img width="455" alt="image" src="https://github.com/user-attachments/assets/0a5f9318-4376-4606-b255-5f1815e86716">


The basic design specifications are based on following 
1. 32 bit 4 core processor system 
2. L1 cache for each processor with Shared L2 memory. 
3. Communication between L1 & L2 and among L1s happens through system bus. 
4. The Grant/Access of the Bus is decided by an Arbiter 
5. Memory is a stub which is assumed to serve all its requests
6. Physically Indexed Physically Tagged Cache system (PIPT) – no TLB 
7. Data and instruction caches are separated in L1. But L2 is a unified cache. 
8. N-way associative cache: 4-way in L1 and 8-way in L2. 
9. MESI based coherency protocol in L1. 
10. Pseudo LRU replacement policy. 
11. Write-back and write allocate scheme. 
12. No write buffers.


_Note_: The design contains several bugs. More details of the bugs can be found in the Bug Report.pdf in the sim directory.
