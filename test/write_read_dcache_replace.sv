//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_read_dcache_replace.sv
// Description: Test for read and then write on D-cache with replacement of the dirty block
// Designers: Team-16
//=====================================================================

class write_read_dcache_replace extends base_test;

    //component macro
    `uvm_component_utils(write_read_dcache_replace)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_read_dcache_replace_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_read_dcache_replace test" , UVM_LOW)
    endtask: run_phase

endclass : write_read_dcache_replace


// Sequence for a read-miss-replace on D-cache

class write_read_dcache_replace_seq extends base_vseq;
    //object macro
    `uvm_object_utils(write_read_dcache_replace_seq)

    cpu_transaction_c trans;
	bit [31:0] access_address;
	
	rand bit [13:0] index;
	rand bit [15:0] tag[7:0]; 
	rand bit [2:0] core[1:0];
	
	constraint unique_tag {unique {tag}; tag[0] >= 16'h4000; tag[1] >= 16'h4000; tag[2] >= 16'h4000; tag[3] >= 16'h4000; tag[4] >= 16'h4000; tag[5] >= 16'h4000; tag[6] >= 16'h4000; tag[7] >= 16'h4000;}
	constraint unique_core {unique{core}; core[0] <= 2'b11; core[1] <= 2'b11;}
	
    //constructor
    function new (string name="write_read_dcache_replace_seq");
        super.new(name);
    endfunction : new

    virtual task body();
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address[31:16] == tag[0]; address[15:2] == index;})
		//access_address = trans.address;
		//`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == access_address;})
		
		for(int i = 1; i < 7; i++) begin
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address[31:16] == tag[i]; address[15:2] == index;})			
		end
		// `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core[0]], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address[31:16] == tag[0]; address[15:2] == index;})
		//access_address = trans.address;
		
		// for(int i = 1; i < 4; i++) begin
			// `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address[31:16] == tag[i]; address[15:2] == index;})	
		// end
		
		// `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address[31:16] == tag[4]; address[15:2] == index;})
 endtask

endclass : write_read_dcache_replace_seq
