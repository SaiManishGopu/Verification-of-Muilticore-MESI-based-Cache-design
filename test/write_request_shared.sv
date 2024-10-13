//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_request_shared.sv
// Description: If the Cache data is in Shared condition during processor write request
// Designers: Team-16
//=====================================================================

class write_request_shared extends base_test;

    //component macro
    `uvm_component_utils(write_request_shared)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_request_shared_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_request_shared test" , UVM_LOW)
    endtask: run_phase

endclass : write_request_shared


// Sequence for generating a Write request when a block is in shared state.
class write_request_shared_seq extends base_vseq;
    //object macro
    `uvm_object_utils(write_request_shared_seq)

    cpu_transaction_c trans;
	bit [31:0] access_address;
	rand bit [2:0] core[1:0];
	constraint unique_core {unique{core}; core[0] <= 2'b11; core[1] <= 2'b11;}

    //constructor
    function new (string name="write_request_shared_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
		access_address = trans.address;
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[1]], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==access_address;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[1]], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==access_address;})

    endtask

endclass : write_request_shared_seq