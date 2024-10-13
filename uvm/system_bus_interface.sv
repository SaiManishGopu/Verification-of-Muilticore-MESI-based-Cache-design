//=====================================================================
// Project: 4 core MESI cache design
// File Name: system_bus_interface.sv
// Description: Basic system bus interface including arbiter
// Designers: Venky & Suru
//=====================================================================

interface system_bus_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1        = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1        = `ADDR_WID_LV1       ;
    parameter NO_OF_CORE            = 4;

    wire [DATA_WID_LV1 - 1 : 0] data_bus_lv1_lv2     ;
    wire [ADDR_WID_LV1 - 1 : 0] addr_bus_lv1_lv2     ;
    wire                        bus_rd               ;
    wire                        bus_rdx              ;
    wire                        lv2_rd               ;
    wire                        lv2_wr               ;
    wire                        lv2_wr_done          ;
    wire                        cp_in_cache          ;
    wire                        data_in_bus_lv1_lv2  ;

    wire                        shared               ;
    wire                        all_invalidation_done;
    wire                        invalidate           ;

    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_gnt_proc ;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_req_proc ;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_gnt_snoop;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_req_snoop;
    logic                       bus_lv1_lv2_gnt_lv2  ;
    logic                       bus_lv1_lv2_req_lv2  ;

//Assertions
//property that checks that signal_1 is asserted in the previous cycle of signal_2 assertion
    property prop_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> $past(signal_1);
    endproperty
	// Property which describes that When signal-2 asserted, signal-1 asserted in previous cycle as well as current cycle
	property prop_sig1_before_and_during_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> ($past(signal_1) && signal_1); 
    endproperty

//ASSERTION 1: lv2_wr_done should not be asserted without lv2_wr being asserted in previous cycle
    assert_lv2_wr_done: assert property (prop_sig1_before_sig2(lv2_wr,lv2_wr_done))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-1 assert_lv2_wr_done Failed: lv2_wr not asserted before lv2_wr_done goes high"))

//TODO: Add assertions at this interface
//There are atleast 20 such assertions. Add as many as you can!!

//ASSERTION 2: data_in_bus_lv1_lv2 and cp_in_cache should not be asserted without lv2_rd being asserted in previous cycle
	assert_lv2_rd: assert property (prop_sig1_before_sig2(bus_lv1_lv2_gnt_proc, (lv2_rd)&&(bus_rd)))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-2 assert_lv2_rd Failed: lv2_rd is asserted before bus_lv1_lv2_gnt_proc goes high"))

//ASSERTION 3: lv2_wr_done signal is made high after lv2_wr is done
     assert_lv2_wr_done_signal: assert property (prop_sig1_before_sig2(lv2_wr,lv2_wr_done))
     else
     `uvm_error("system_bus_interface",$sformatf("Assertion-3 assert_lv2_wr_done_signal Failed: lv2_wr_done is asserted before lv2_wr goes high"))

//ASSERTION 4: shared signal is made high after bus_lv1_lv2_gnt_snoop signal is made high 
     assert_shared_signal: assert property (prop_sig1_before_sig2(bus_lv1_lv2_gnt_proc,shared))
     else
     `uvm_error("system_bus_interface",$sformatf("Assertion-4 assert_shared_signal Failed: bus_lv1_lv2_gnt_proc is asserted before shared goes high"))

//ASSERTION 5: Address in address bus should have valid value before data_in_bus_lv1_lv2 is asserted
     property prop_valid_addr_check_before_data_in;
        @(posedge clk)
          (data_in_bus_lv1_lv2) |-> ((addr_bus_lv1_lv2[31:0]!==32'bx)||(addr_bus_lv1_lv2[31:0]!==32'bz));
    endproperty

    assert_valid_addr_check_before_data_in: assert property (prop_valid_addr_check_before_data_in)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-5 assert_valid_addr_check_before_data_in Failed: addr_bus_lv1_lv2 does not have valid address when data_in_bus_lv1_lv2 is asserted"))

//ASSERTION 6: If data_in_bus_lv1_lv2 is asserted, lv2_rd should be high
    property valid_data_in_lv2_bus_rd;
        @(posedge clk)
        (data_in_bus_lv1_lv2===1'bz) ##1 (data_in_bus_lv1_lv2==1'b1) |-> lv2_rd;
    endproperty

    assert_valid_data_in_lv2_bus_rd: assert property (valid_data_in_lv2_bus_rd)
    else
        `uvm_error("system_bus_interface", "Assertion-6 assert_valid_data_in_lv2_bus_rd failed: lv2_rd not high when data_in_bus_lv1_lv2 asserted")

//ASSERTION 7: lv2_rd should be followed by data_in_bus_lv1_lv2 and both should be deasserted acc to HAS
    property valid_lv2_rd_txn;
        @(posedge clk)
        lv2_rd |=> ##[0:$] data_in_bus_lv1_lv2 ##1 !lv2_rd ;
    endproperty

    assert_valid_lv2_rd_txn: assert property (valid_lv2_rd_txn)
    else
        `uvm_error("system_bus_interface", "Assertion-7 assert_valid_lv2_rd_txn failed: lv2_rd=>data_in_bus_lv1_lv2=>!lv2_rd sequence is not followed")

//ASSERTION 8: data_in_bus_lv1_lv2 and cp_in_cache should not be asserted without lv2_rd being asserted in previous cycle
    assert_data_in_bus_and_cp_in_cache: assert property (prop_sig1_before_sig2(lv2_rd,data_in_bus_lv1_lv2 && cp_in_cache))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-8 assert_data_in_bus_and_cp_in_cache Failed: lv2_rd not asserted before data_in_bus_lv1_lv2 and cp_in_cache goes high"))

//ASSERTION 9: Signal bus_lv1_lv2_gnt_snoop is one hot encoded signal
    property prop_onehot_gnt_signal;
        @(posedge clk)
            ($onehot0(bus_lv1_lv2_gnt_snoop));
    endproperty

    assert_onehot_gnt_signal: assert property (prop_onehot_gnt_signal)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-9 assert_onehot_gnt_signal Failed: multiple grant signals"))

//ASSERTION 10: data_in_bus_lv1_lv2 and cp_in_cache should not be asserted without lv2_rd being asserted in previous cycle
    assert_data_in_bus_lv1_lv2_cp_in_cache: assert property (prop_sig1_before_sig2(lv2_rd, data_in_bus_lv1_lv2 && cp_in_cache))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-10 assert_data_in_bus_lv1_lv2_cp_in_cache Failed: lv2_rd not asserted before data_in_bus_lv1_lv2 and cp_in_cache asserted"))
    
//ASSERTION 11: bus_lv1_lv2_gnt_proc must be asserted after bus_lv1_lv2_req_proc being asserted in previous cycle 
    property prop_gntsig_before_reqsig(core);
        @(posedge clk)
          bus_lv1_lv2_gnt_proc[core] |-> $past(bus_lv1_lv2_req_proc[core]);
    endproperty

    assert_gntsig_before_reqsig_0: assert property (prop_gntsig_before_reqsig(0))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-11 assert_gntsig_before_reqsig_0 Failed: gnt signal is asserted even before the request signal goes high"))
		
	assert_gntsig_before_reqsig_1: assert property (prop_gntsig_before_reqsig(1))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-11 assert_gntsig_before_reqsig_1 Failed: gnt signal is asserted even before the request signal goes high"))
		
	assert_gntsig_before_reqsig_2: assert property (prop_gntsig_before_reqsig(2))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-11 assert_gntsig_before_reqsig_2 Failed: gnt signal is asserted even before the request signal goes high"))
		
	assert_gntsig_before_reqsig_3: assert property (prop_gntsig_before_reqsig(3))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-11 assert_gntsig_before_reqsig_3 Failed: gnt signal is asserted even before the request signal goes high"))

//ASSERTION 12: bus_lv1_lv2_gnt_snoop must be asserted after bus_lv1_lv2_req_snoop being asserted in previous cycle
     property prop_gntsig_before_reqsig_snoop(core);
        @(posedge clk)
          bus_lv1_lv2_gnt_snoop[core]|-> $past(bus_lv1_lv2_req_snoop[core]);
    endproperty

    assert_gntsig_before_reqsig_snoop_0: assert property (prop_gntsig_before_reqsig_snoop(0))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-12 assert_gntsig_before_reqsig_snoop_0 Failed: gnt signal_snoop is asserted even before the request signal_snoop goes high"))
	
	assert_gntsig_before_reqsig_snoop_1: assert property (prop_gntsig_before_reqsig_snoop(1))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-12 assert_gntsig_before_reqsig_snoop_1 Failed: gnt signal_snoop is asserted even before the request signal_snoop goes high"))
	
	assert_gntsig_before_reqsig_snoop_2: assert property (prop_gntsig_before_reqsig_snoop(2))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-12 assert_gntsig_before_reqsig_snoop_2 Failed: gnt signal_snoop is asserted even before the request signal_snoop goes high"))

	assert_gntsig_before_reqsig_snoop_3: assert property (prop_gntsig_before_reqsig_snoop(3))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-12 assert_gntsig_before_reqsig_snoop_3 Failed: gnt signal_snoop is asserted even before the request signal_snoop goes high"))
		
// ASSERTION 13: bus_rd or bus_rdx must be asserted if lv2_rd is asserted
    assert_bus_rd_or_rdx_after_lv2_rd: assert property (@(posedge clk) ((lv2_rd) && (addr_bus_lv1_lv2[31:30] != 2'b0))|-> (bus_rd || bus_rdx))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-13 assert_bus_rd_or_rdx_after_lv2_rd Failed: bus_rd or bus_rdx not asserted when lv2_rd asserted"))

//ASSERTION 14: bus_lv1_lv2_req_lv2 should be asserted if lv2_rd or lv2_wr gets asserted previously
    assert_bus_lv1_lv2_req_if_lv2_rd_or_lv2_wr: assert property (prop_sig1_before_sig2((lv2_rd || lv2_wr), bus_lv1_lv2_req_lv2))
    else
    `uvm_error("system_bus_interface", $sformatf("Assertion-14 assert_bus_lv1_lv2_req_if_lv2_rd_or_lv2_wr Failed: No lv2_rd or lv2_wr assertion before bus_lv1_lv2_req_lv2"))

//ASSERTION 15: After lv2_wr or lv2_rd is asserted then address should be present address bus 
    assert_lv2_rd_or_lv2_wr_address_bus: assert property (@(posedge clk) (lv2_rd || lv2_wr) |-> ((addr_bus_lv1_lv2[31:0] !== 32'hx) || (addr_bus_lv1_lv2[31:0] !== 32'hz)) )
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-15 assert_lv2_rd_or_lv2_wr_address_bus Failed:  NO address present in bus after lv2 rd or lv2 wr is asserted "))

//Assertion 16: Assert invalidate once bus_lv1_lv2_gnt_proc asserted in past and present cycle
    assert_invalidate_after_bus_lv1_lv2_gnt_proc: assert property (prop_sig1_before_and_during_sig2(bus_lv1_lv2_gnt_proc, invalidate))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion-16 assert_invalidate_after_bus_lv1_lv2_gnt_proc Failed: invalidate asserted without bus_lv1_lv2_gnt_proc being asserted "))  

//ASSERTION 17: bus_rd or bus_rdx or invalidate asserted in past if shared is asserted
    assert_shared: assert property (prop_sig1_before_sig2((bus_rd | bus_rdx | invalidate), shared))
    else
    `uvm_error("system_bus_interface", $sformatf("Assertion-17 assert_shared Failed: bus_rd or bus_rdx or invalidate is not asserted before shared is asserted"))

//ASSERTION 18: All_Invalidation is asserted, when invalidation is high in previous cycle
	assert_all_invalidation_done: assert property(prop_sig1_before_sig2(invalidate, all_invalidation_done))
	else
	`uvm_error("system_bus_interface",$sformatf("Assertion-18 assert_all_invalidation_done Failed: all_invalidation_done asserted before invalidate is not asserted"))

//ASSERTION 19: bus_rdx and bus_rd are not asserted together
	assert_bus_rdx_bus_rd_both: assert property( @(posedge clk) not(bus_rd && bus_rdx))
	else
	`uvm_error("system_bus_interface", $sformatf("Assertion-19 assert_bus_rdx_bus_rd_both Failed: Signals bus_rdx and bus_rd both are asserted together"))
	
//ASSERTION 20: when data_in_bus_lv1_lv2 is asserted then bus_rd and bus_rdx should not be asserted
	property data_in_bus_lv1_lv2_busrd_busrdx;
		@(posedge clk)
			data_in_bus_lv1_lv2 |=> (bus_rd!==1'b1 & bus_rdx!==1'b1); 
    endproperty
	assert_data_in_bus_lv1_lv2_busrd_busrdx : assert property(data_in_bus_lv1_lv2_busrd_busrdx)
	else
	`uvm_error("system_bus_interface",$sformatf("Assertion-20 assert_data_in_bus_lv1_lv2_busrd_busrdx Failed: bus_rd and/or bus_rdx asserted when data_in_bus_lv1_lv2 asserted"))
	
//ASSERTION 21: lv2_wr should deassert one cycle after lv2_wr_done assertion
	assert_lv2_wr_after_lv2_wr_done: assert property (@(posedge clk) $rose(lv2_wr_done) |-> ##1 $fell(lv2_wr))
	else
	`uvm_error("system_bus_interface",$sformatf("Assertion-21 assert_data_address_bus_after_lv2_wr_done Failed: lv2_wr did not deassert one cycle after lv2_wr assertion"))

endinterface
