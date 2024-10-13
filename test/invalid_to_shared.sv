//=====================================================================
// Project: 4 core MESI cache design
// File Name: invalid_to_shared.sv
// Description: Invalid to Shared MESI state transition
// Designers: Team-16
//=====================================================================

class invalid_to_shared extends base_test;

    //component macro
    `uvm_component_utils(invalid_to_shared)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", invalid_to_shared_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing invalid_to_shared test" , UVM_LOW)
    endtask: run_phase

endclass : invalid_to_shared



class invalid_to_shared_seq extends base_vseq;
    //object macro
    `uvm_object_utils(invalid_to_shared_seq)

    cpu_transaction_c trans;
	bit [31:0] access_address;
	
	rand bit [2:0] core[1:0];
	constraint unique_core {unique{core}; core[0] <= 2'b11; core[1] <= 2'b11;}
    //constructor
    function new (string name="invalid_to_shared_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
		access_address = trans.address;
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[1]], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==access_address;})
    endtask

endclass : invalid_to_shared_seq