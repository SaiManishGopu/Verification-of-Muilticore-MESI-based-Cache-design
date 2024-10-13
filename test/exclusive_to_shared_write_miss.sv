//=====================================================================
// Project: 4 core MESI cache design
// File Name: exclusive_to_shared_write_miss.sv
// Description: Exclusive to Shared MESI state transition
// Designers: Team-16
//=====================================================================

class exclusive_to_shared_write_miss extends base_test;

    //component macro
    `uvm_component_utils(exclusive_to_shared_write_miss)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", exclusive_to_shared_write_miss_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing exclusive_to_shared_write_miss test" , UVM_LOW)
    endtask: run_phase

endclass : exclusive_to_shared_write_miss



class exclusive_to_shared_write_miss_seq extends base_vseq;
    //object macro
    `uvm_object_utils(exclusive_to_shared_write_miss_seq)

    cpu_transaction_c trans;
	bit [31:0] access_address;
	rand bit [2:0] core[3:0];
	constraint unique_core {unique{core}; core[0] <= 2'b11; core[1] <= 2'b11; core[2] <= 2'b11; core[3] <= 2'b11;}

    //constructor
    function new (string name="exclusive_to_shared_write_miss_seq");
        super.new(name);
    endfunction : new

    virtual task body();
	
	//DCACHE
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
		access_address = trans.address;
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==access_address;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[1]], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==access_address;})
		//`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[3]], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==access_address;})
	
	//ICACHE
	    // `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == READ_REQ; access_cache_type == ICACHE_ACC;})
		// access_address = trans.address;
        // `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[1]], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address==access_address;})
        // `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[2]], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address==access_address;})
		// `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[3]], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address==access_address;})
    endtask

endclass : exclusive_to_shared_write_miss_seq