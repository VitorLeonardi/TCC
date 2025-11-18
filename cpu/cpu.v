module cpu(input clk_in, input reset, input [3:0] rin, input sft, output [47:0] d);

	wire clk;
	wire pll_locked;
	
	pll	pll_inst (clk_in, clk, pll_locked);


	reg [31:0] m_addr = 0;
	reg [31:0] to_ram = 0;
	reg [03:0] byteena = 0;
	reg we = 0;    
	wire [31:0] to_cpu;
	
    ram ram_inst (m_addr[14:2], byteena, clk, to_ram, we, to_cpu);
	
	reg [31:0] instr = 0;
	reg [31:0] pc    = 0;
	reg [31:0] regfile [0:15];

	digits display_reg(regfile[rin], sft, d);
	
	//memory latency stall
	reg [3:1]  stall = 1;
	
	integer i;
	initial begin
		for(i = 0; i < 16; i = i + 1) 
			regfile[i] = 0;
	end
	
	wire [06:0] opcode = instr[6:0];
	wire [02:0] funct3 = instr[14:12];
	wire [03:0] rs1    = instr[18:15];
	wire [03:0] rs2    = instr[23:20];
	wire [03:0] rd     = instr[10:7];
	wire [11:0] imm_i  = instr[31:20];
	wire [11:0] imm_s  = {instr[31:25], instr[11:7]};
	wire [19:0] imm_u  = instr[31:12];
	wire [12:1] imm_b  = {instr[31], instr[7], instr[30:25], instr[11:8]};
	wire [20:1] imm_j  = {instr[31], instr[19:12], instr[20], instr[30:21]};	
	
	wire [31:0] r1 = regfile[rs1];
	wire [31:0] r2 = regfile[rs2];

	wire [31:0] alu_out, agu_out, addr_out;
	wire rd_alu, rd_agu, br, ls, jump;
	wire store = opcode[5];

	alu alu_inst(opcode, funct3, r1, r2, pc, imm_i, imm_u, 
				alu_out, rd_alu, br);
	
	agu agu_inst(opcode, m_addr, r1, pc, imm_j, imm_i, imm_s, imm_b, br, stall, 
				addr_out, agu_out, rd_agu, jump, ls);
	
	wire [03:0] ben;
	wire [31:0] ls_data;
	wire h = |stall;
	wire ls0 = ls & ~h;
	wire ls3 = ls & stall[3];
	wire rd_ld = ls3 & ~store;
	wire [1:0] s_adr = addr_out[1:0];
	reg  [1:0] l_adr = 0;
	
	ls_bytes bytes_inst(funct3, to_cpu, r2, l_adr, s_adr, ls, store, 
						ls_data, ben);

	always @ (posedge clk) begin
		if (reset) begin		
			m_addr <= addr_out;			
			pc <= jump ? addr_out : agu_out;

			if(rd_alu) 
				regfile[rd] <= alu_out;
			else if(rd_agu) 
				regfile[rd] <= agu_out;
			else if(rd_ld)
				regfile[rd] <= ls_data;

			if ((~ls & jump) | ls3) 
				instr <= 0;
			else if (~ls & ~(|stall[2:1]))
				instr <= to_cpu;
			
			stall <= {stall[2:1], ls0 | jump};
			
			{we, byteena, to_ram} <= ls0 & store ? {1'b1, ben, ls_data} : 37'b0;

			if(ls0) l_adr <= addr_out[1:0]; 

	    end else begin
	    	pc <= 0; instr <= 0; m_addr <= 0; 
	    	we <= 0; stall <= 1; to_ram <= 0;
	    	
	    	for(i = 0; i < 16; i = i + 1)  
	    		regfile[i] <= 0;
	    end
	end
endmodule