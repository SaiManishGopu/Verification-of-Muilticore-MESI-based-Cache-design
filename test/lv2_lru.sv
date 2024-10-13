//=====================================================================
// Project: 4 core MESI cache design
// File Name: lv2_lru.sv
// Description: Test for LRU cache eviction on L2
// Designers: Team-16
//=====================================================================

class lv2_lru extends base_test;

    //component macro
    `uvm_component_utils(lv2_lru)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", lv2_lru_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing lv2_lru test" , UVM_LOW)
    endtask: run_phase

endclass : lv2_lru



class lv2_lru_seq extends base_vseq;
    //object macro
    `uvm_object_utils(lv2_lru_seq)

    cpu_transaction_c trans;

	rand bit [17:0] index[1:0];
	rand bit [11:0] tag[8:0]; 
	
	constraint unique_tag {unique {tag}; tag[0] >= 12'h400; tag[1] >= 12'h400; tag[2] >= 12'h400; tag[3] >= 12'h400; tag[4] >= 12'h400; tag[5] >= 12'h400; tag[6] >= 12'h400; tag[7] >= 12'h400; tag[8] >= 12'h400;}
	constraint unique_index { unique {index};}
    //constructor
    function new (string name="lv2_lru_seq");
        super.new(name);
    endfunction : new

	//READ REPLACEMENT
	virtual task body();
		for(int i = 0; i < 18; i++) begin
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; address[19:2] == index[0];})
		end

		for(int i = 0; i < 9; i++) begin
			`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address[31:20] == tag[i]; address[19:2] == index[1];})
		end
	endtask

endclass : lv2_lru_seq

