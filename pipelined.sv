// Pipelined CPU top level
`timescale 1ps/1ps

module pipelined (clk, reset);
   input logic clk, reset;
	
	// forwarding controls
	logic [1:0] forward_a, forward_b, forward_cbz, forward_br;
	// flag reg data
	logic [3:0] flag_reg_in, flag_reg_out;
	//if/id pipeline reg data
	logic [95:0] if_id_in;
	logic [95:0] if_id_out;
	// id/ex pipeline reg data
	logic [255:0] id_ex_in;
	logic [255:0] id_ex_out;
	// Various stages of ALU results
	logic [63:0] ALU_result, ex_mem_ALU_result;
	// hazard detect outputs that stall pipeline
	logic pc_write_en, if_id_write_en;
	//ex/mem pipeline reg data
	logic [255:0] ex_mem_in;
	logic [255:0] ex_mem_out;
	// mem/wb pipeline reg data
	logic [255:0] mem_wb_in;
	logic [255:0] mem_wb_out;
	// Data to write to regfile
	logic [63:0] WriteData;

	// pc and new pc
	logic [63:0] pc;
	logic [63:0] pc_update;
	
	// control signals from each pipeline reg
	logic [14:0] control_sigs, id_ex_control, ex_mem_control, mem_wb_control;
	
	assign id_ex_control = id_ex_out[255:241];
	assign ex_mem_control = ex_mem_out[255:241];
	assign mem_wb_control = mem_wb_out[255:241];
	 
    // IF STAGE LOGIC
	fetch if_stage (.pc_write_en, .pc, .pc_update, .if_id_in, .clk, .reset);
	
	// control hazard detection
	logic if_id_reset, if_id_flush, b_taken;
	or #(50) (if_id_reset, reset, if_id_flush);
	
	register_ninetysix if_id (.d(if_id_in), .q(if_id_out), .enable(if_id_write_en), .reset(if_id_reset), .clk);

	
	// Forwarding logic 
	forward forwarding_unit (.forward_cbz, .if_id_condbranch(control_sigs[0]), .id_ex_regwrite(id_ex_control[2]), 
		.id_ex_bl(id_ex_control[12]), .mem_wb_rd(mem_wb_out[4:0]), .id_ex_rn(id_ex_out[9:5]), 
		.id_ex_rm(id_ex_out[20:16]), .id_ex_memwrite(id_ex_control[3]), .ex_mem_rd(ex_mem_out[4:0]), 
		.if_id_rd(if_id_out[4:0]), .id_ex_rd(id_ex_out[4:0]), .mem_wb_regwrite(mem_wb_control[2]), 
		.ex_mem_regwrite(ex_mem_control[2]), .forward_a, .forward_b, .forward_br, .ex_mem_bl(ex_mem_control[12]), 
		.mem_wb_bl(mem_wb_control[12]));
	
	// Hazard Detect
	hazard hazard_det (.pc_write_en, .if_id_write_en, .mem_memread(ex_mem_control[14]), .if_id_rd(if_id_out[4:0]), 
		.mem_rd(ex_mem_out[4:0]), .if_id_flush, .b_taken, .ex_mem_rd(id_ex_out[4:0]), 
		.if_id_rm(if_id_out[20:16]), .if_id_rn(if_id_out[9:5]), .ex_memread(id_ex_control[14]));
	
	// ID STAGE
	id id_stage(.if_id_out, .pc, .forward_cbz, .forward_br, .WriteData, .ex_mem_ALU_result, .ALU_result, .mem_wb_out, 
		.flag_reg_in, .flag_reg_out, .id_ex_control, .pc_update, .control_sigs,
		.clk, .reset, .id_ex_in, .b_taken, .if_id_write_en); 
	
	// id/ex pipeline reg
	register_twofiftysix id_ex (.q(id_ex_out), .d(id_ex_in), .reset, .clk, .enable(1'b1));
		
	
	// EX STAGE
	ex ex_stage (.id_ex_out, .ex_mem_in, .forward_a, .forward_b, 
			.clk, .reset, .WriteData, .ex_mem_ALU_result, .flag_reg_in, .flag_reg_out, .ALU_result);
	
	// ex/mem pipeline reg
	register_twofiftysix ex_mem (.d(ex_mem_in), .q(ex_mem_out), .reset, .clk, .enable(1'b1));
	

	// MEM STAGE 
	mem mem_stage (.ex_mem_out, .mem_wb_in, .ex_mem_ALU_result, .clk, .reset);
	
	
	// mem/wb pipeline register
	register_twofiftysix mem_wb (.q(mem_wb_out), .d(mem_wb_in), .reset, .clk, .enable(1'b1));
	
	
	
	wb writeback_stage (.mem_wb_out, .WriteData);
    

endmodule // top level for single_cycle processor 
    
    
    
    
    
