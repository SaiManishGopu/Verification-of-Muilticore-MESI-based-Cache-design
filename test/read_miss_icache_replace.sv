//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_icache_replace.sv
// Description: Test for read-miss on I-cache with replacement
// Designers: Team-16
//=====================================================================

class read_miss_icache_replace extends base_test;

    //component macro
    `uvm_component_utils(read_miss_icache_replace)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", read_miss_icache_replace_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing read_miss_icache_replace test" , UVM_LOW)
    endtask: run_phase

endclass : read_miss_icache_replace


// Sequence for a read-miss-replace on icache
class read_miss_icache_replace_seq extends base_vseq;
    //object macro
    `uvm_object_utils(read_miss_icache_replace_seq)

    cpu_transaction_c trans;

	rand bit [13:0] index;
	rand bit [15:0] tag[4:0]; 
	
	constraint unique_tag {unique {tag}; tag[0] < 16'h4000; tag[1] < 16'h4000; tag[2] < 16'h4000; tag[3] < 16'h4000; tag[4] <16'h4000;}
	
    //constructor
    function new (string name="read_miss_icache_replace_seq");
        super.new(name);
    endfunction : new

    virtual task body();
		for(int i = 0; i < 5; i++) begin
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address[31:16] == tag[i]; address[15:2] == index;})
		end
 endtask

endclass : read_miss_icache_replace_seq

