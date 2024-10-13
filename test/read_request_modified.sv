//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_request_modified.sv
// Description: If the D-cache data is in modified state in one CPU during read request by another CPU
// Designers: Team-16
//=====================================================================

class read_request_modified extends base_test;

    //component macro
    `uvm_component_utils(read_request_modified)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", read_request_modified_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing read_request_modified test" , UVM_LOW)
    endtask: run_phase
	
endclass : read_request_modified


// Sequence for generating a Read request when a block is in modified state.
class read_request_modified_seq extends base_vseq;
    //object macro
    `uvm_object_utils(read_request_modified_seq)

    cpu_transaction_c trans;
	bit [31:0] access_address;
	rand bit [2:0] core[1:0];
	constraint unique_core {unique{core}; core[0] <= 2'b11; core[1] <= 2'b11;}

    //constructor
    function new (string name="read_request_modified_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
		access_address = trans.address;
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==access_address;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[1]], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==access_address;})

    endtask

endclass : read_request_modified_seq