//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_invalidate.sv
// Description: Test for check the write invalidate conditon
// Designers: Team-16
//=====================================================================

class write_invalidate extends base_test;

    //component macro
    `uvm_component_utils(write_invalidate)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_invalidate_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_invalidate test" , UVM_LOW)
    endtask: run_phase

endclass : write_invalidate



class write_invalidate_seq extends base_vseq;
    //object macro
    `uvm_object_utils(write_invalidate_seq)

    cpu_transaction_c trans;
    bit [31:0] same_address;
	rand bit [13:0] index; 
	rand bit [15:0] tag[4:0]; 
	rand bit [1:0] core[1:0];
	constraint unique_core {unique{core}; core[0] <= 2'b11; core[1] <= 2'b11;}
	
    //constructor
    function new (string name="write_invalidate_seq");
        super.new(name);
    endfunction : new

    virtual task body();
		
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
		same_address=trans.address;
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[1]], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == same_address;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == same_address;})
        repeat(20)
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
    endtask

endclass : write_invalidate_seq

