//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_miss_dcache_replace.sv
// Description: Test for write-miss on D-cache with replacement
// Designers: Team-16
//=====================================================================

class write_miss_dcache_replace extends base_test;

    //component macro
    `uvm_component_utils(write_miss_dcache_replace)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_miss_dcache_replace_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_miss_dcache_replace test" , UVM_LOW)
    endtask: run_phase

endclass : write_miss_dcache_replace


// Sequence for a write-miss-replace on dcache
class write_miss_dcache_replace_seq extends base_vseq;
    //object macro
    `uvm_object_utils(write_miss_dcache_replace_seq)

    cpu_transaction_c trans;

	rand bit [13:0] index;
	rand bit [15:0] tag[4:0]; 
	
	constraint unique_tag {unique {tag}; tag[0] >= 16'h4000; tag[1] >= 16'h4000; tag[2] >= 16'h4000; tag[3] >= 16'h4000; tag[4] >= 16'h4000;}
	
    //constructor
    function new (string name="write_miss_dcache_replace_seq");
        super.new(name);
    endfunction : new

    virtual task body();
		for(int i = 0; i < 5; i++) begin
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address[31:16] == tag[i]; address[15:2] == index;})
		end
 endtask

endclass : write_miss_dcache_replace_seq

