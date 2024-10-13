//=====================================================================
// Project: 4 core MESI cache design
// File Name: modified_to_modified.sv
// Description: Modified to Modified MESI state transition
// Designers: Shobith
//=====================================================================

class modified_to_modified extends base_test;

    //component macro
    `uvm_component_utils(modified_to_modified)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", modified_to_modified_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing modified_to_modified test" , UVM_LOW)
    endtask: run_phase

endclass : modified_to_modified



class modified_to_modified_seq extends base_vseq;
    //object macro
    `uvm_object_utils(modified_to_modified_seq)

    cpu_transaction_c trans;
	bit [31:0] access_address;

    //constructor
    function new (string name="modified_to_modified_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
		access_address = trans.address;
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==access_address;})

    endtask

endclass : modified_to_modified_seq