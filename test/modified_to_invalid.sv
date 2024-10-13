//=====================================================================
// Project: 4 core MESI cache design
// File Name: modified_to_invalid.sv
// Description: Modified to Invalid MESI state transition
// Designers: Team-16
//=====================================================================

class modified_to_invalid extends base_test;

    //component macro
    `uvm_component_utils(modified_to_invalid)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", modified_to_invalid_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing modified_to_invalid test" , UVM_LOW)
    endtask: run_phase

endclass : modified_to_invalid



class modified_to_invalid_seq extends base_vseq;
    //object macro
    `uvm_object_utils(modified_to_invalid_seq)

    cpu_transaction_c trans;
	bit [31:0] access_address;
	rand bit [2:0] core[1:0];
	constraint unique_core {unique{core}; core[0] <= 2'b11; core[1] <= 2'b11;}

    //constructor
    function new (string name="modified_to_invalid_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
		access_address = trans.address;
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[1]], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==access_address;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[1]], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==access_address;})

    endtask

endclass : modified_to_invalid_seq