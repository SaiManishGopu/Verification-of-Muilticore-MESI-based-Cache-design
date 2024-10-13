//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_lv1_interface.sv
// Description: Basic CPU-LV1 interface with assertions
// Designers: Venky & Suru
//=====================================================================


interface cpu_lv1_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;

    reg   [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_reg    ;

    wire  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1        ;
    logic [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1        ;
    logic                          cpu_rd                  ;
    logic                          cpu_wr                  ;
    logic                          cpu_wr_done             ;
    logic                          data_in_bus_cpu_lv1     ;

    assign data_bus_cpu_lv1 = data_bus_cpu_lv1_reg ;

//Assertions
//ASSERTION1: cpu_wr and cpu_rd should not be asserted at the same clock cycle
    property prop_simult_cpu_wr_rd;
        @(posedge clk)
          not(cpu_rd && cpu_wr);
    endproperty

    assert_simult_cpu_wr_rd: assert property (prop_simult_cpu_wr_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion-1 assert_simult_cpu_wr_rd Failed: cpu_wr and cpu_rd asserted simultaneously"))

//TODO: Add assertions at this interface

//ASSERTION2: cpu_wr cannot happen on address cache
    property prop_cpu_wr_to_addrcache;
        @(posedge clk)
          not(cpu_wr && addr_bus_cpu_lv1 < 32'h4000_0000);
    endproperty

    assert_cpu_wr_to_addrcache: assert property (prop_cpu_wr_to_addrcache)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion-2 assert_cpu_wr_to_addrcache Failed: cpu_wr is done on address cache"))

//ASSERTION3: data_bus_cpu_lv1 should have valid value when data_in_bus_cpu_lv1 is asserted  
    property prop_valid_data_check;
        @(posedge clk)
          (data_in_bus_cpu_lv1) |-> ((data_bus_cpu_lv1[31:0]!==32'bx)&&(data_bus_cpu_lv1[31:0]!==32'bz));
    endproperty

    assert_valid_data_check: assert property (prop_valid_data_check)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion-3 assert_valid_data_check Failed: data_bus_cpu_lv1 does not have valid data when data_in_bus_cpu_lv1 is asserted"))
		
//ASSERTION4: cpu_rd is asserted before data_in_bus_cpu_lv1 is asserted in the next cycle or next n cycles.
    property prop_cpu_rd_before_data;
      @(posedge clk)
         cpu_rd |-> ##[1:$] data_in_bus_cpu_lv1;
    endproperty

    assert_cpu_rd_before_data_in_bus: assert property (prop_cpu_rd_before_data)
    else
    `uvm_error("cpu_lv1_interface",$sformatf("Assertion-4 assert_cpu_rd_before_data_in_bus Failed: cpu_rd not asserted before data_in_bus_cpu_lv1"))

//ASSERTION5: Deassert the cpu write in next cycle as cpu_wr_done is asserted 
   property prop_cpu_wr_deassert;
        @(posedge clk)
          cpu_wr_done |=> (!cpu_wr);
    endproperty
    deassert_cpu_wr: assert property (prop_cpu_wr_deassert)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion-5 deassert_cpu_wr Failed: Deassert failed on the cpu write in next cycle as cpu_wr_done is asserted"))
	
//ASSERTION6: Address in address bus should have valid value when cpu_rd/cpu_wr is asserted
     property prop_valid_addr_check;
        @(posedge clk)
          (cpu_rd||cpu_wr) |-> ((addr_bus_cpu_lv1[31:0]!==32'bx)&&(addr_bus_cpu_lv1[31:0]!==32'bz));
    endproperty

    assert_valid_addr_check: assert property (prop_valid_addr_check)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion-6 assert_valid_addr_check Failed: addr_bus_cpu_lv1 does not have valid address when cpu_rd/cpu_wr is asserted"))
	
//ASSERTION7: cpu_rd and cpu_wr_done should not be asserted together
    property prop_cpu_wr_done_and_cpu_rd;
        @(posedge clk)
         not(cpu_rd && cpu_wr_done);
        endproperty
        assert_cpu_rd_cpu_wr_done: assert property (prop_cpu_wr_done_and_cpu_rd)
        else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion-7 assert_cpu_rd_cpu_wr_done Failed: cpu_rd and cpu_wr_done are asserted together"))
		
//ASSERTION8: During a read, when data is in data_bus_cpu_lv1, data_in_bus_cpu_lv1 is asserted 
    property prop_cpu_data_bus_cpu_lv1_and_data_in_bus_cpu_lv1;
        @(posedge clk)
			cpu_rd |-> ##[1:$](data_bus_cpu_lv1[31:0]!==32'bx)&&(data_bus_cpu_lv1[31:0]!==32'bz)&&(data_in_bus_cpu_lv1);
        endproperty
        assert_cpu_data_bus_cpu_lv1_and_data_in_bus_cpu_lv1: assert property (prop_cpu_data_bus_cpu_lv1_and_data_in_bus_cpu_lv1)
        else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion-8 assert_cpu_data_bus_cpu_lv1_and_data_in_bus_cpu_lv1 Failed: data_bus_cpu_lv1 and data_in_bus_cpu_lv1 not asserted together during cache read"))

//ASSERTION9: If data_in_bus_cpu_lv1 asserted then cpu_rd is deasserted next cycle
    property prop_cpu_rd_deassert;
        @(posedge clk)
            data_in_bus_cpu_lv1 |=> (!cpu_rd);
    endproperty
    assert_cpu_rd_deassert: assert property (prop_cpu_rd_deassert)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion-9 assert_cpu_rd_deassert has Failed: cpu_rd is not deasserted in next cycle after data_in_bus_cpu_lv1 is asserted"))

//ASSERTION10:cpu_wr_done must be asserted within time frame after cpu_wr
	property prop_cpu_wr_done_cpu_wr;
 	@(posedge clk)
 	  cpu_wr |-> ##[0:100] cpu_wr_done;
	endproperty
	assert_cpu_wr_done_cpu_wr : assert property(prop_cpu_wr_done_cpu_wr)
	else
		`uvm_error("cpu_lv1_interface",$sformatf("Assertion-10 assert_cpu_wr_done_cpu_wr Failed: cpu_wr_done not asserted within the defined time of 100 cycles"))
		
//Assertion11:data_in_bus_cpu_lv1 should deassert in the next cycle after cpu_rd deasserted 
	property prop_data_in_bus_cpu_rd;
		@(posedge clk)
			$rose(cpu_rd) |-> ##[1:$]$fell(cpu_rd) |=> $fell(data_in_bus_cpu_lv1);
	endproperty
	deassert_data_in_bus_cpu_rd: assert property(prop_data_in_bus_cpu_rd)
	else
		`uvm_error("cpu_lv1_interface",$sformatf("Assertion-11 deassert_data_in_bus_cpu_rd Failed: data_in_bus_cpu_lv1 not deasserted in the next cycle after cpu_rd deasserted"))

endinterface
