//=====================================================================
// Project: 4 core MESI cache design
// File Name: continuous_write_read_dcache.sv
// Description: Test for random read and write requests on DCACHE
// Designers: Team-16
//=====================================================================

class continuous_write_read_dcache extends base_test;

    //component macro
    `uvm_component_utils(continuous_write_read_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", continuous_write_read_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing continuous_write_read_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : continuous_write_read_dcache


// 100 random writes followed by reads for verifying data
class continuous_write_read_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(continuous_write_read_dcache_seq)

    cpu_transaction_c trans;
	bit [31:0] access_address;
    //constructor
    function new (string name="continuous_write_read_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
		repeat(100) begin
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE;})
			access_address = trans.address;
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE; address == access_address;})
		end
	endtask

endclass : continuous_write_read_dcache_seq
