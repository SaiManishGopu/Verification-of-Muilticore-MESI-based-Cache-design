//=====================================================================
// Project: 4 core MESI cache design
// File Name: test_lib.svh
// Description: Base test class and list of tests
// Designers: Venky & Suru
//=====================================================================
//TODO: add your testcase files in here
`include "base_test.sv"
`include "read_miss_icache.sv"

`include "read_hit_icache.sv"
`include "read_miss_dcache.sv"
`include "read_hit_dcache.sv"

`include "write_miss_dcache.sv"
`include "write_hit_dcache.sv"

`include "read_miss_icache_replace.sv"
`include "read_miss_dcache_replace.sv"
`include "write_miss_dcache_replace.sv"
`include "read_write_dcache_replace.sv"
`include "write_read_dcache_replace.sv"

`include "write_request_shared.sv"
`include "write_request_modified.sv"

`include "read_request_modified.sv"

`include "write_invalidate.sv"

`include "modified_to_shared.sv"
`include "modified_to_invalid.sv"
`include "modified_to_modified.sv"

`include "shared_to_shared.sv"
`include "shared_to_invalid.sv"
`include "shared_to_modified.sv"

`include "exclusive_to_shared.sv"
`include "exclusive_to_invalid.sv"
`include "exclusive_to_modified.sv"
`include "exclusive_to_exclusive.sv"

`include "invalid_to_shared.sv"
`include "invalid_to_modified.sv"
`include "invalid_to_exclusive.sv"

`include "exclusive_to_shared_write_miss.sv"

`include "continuous_write_read_dcache.sv"
`include "lv2_lru.sv"