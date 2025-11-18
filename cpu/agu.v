module agu(input [6:0] opcode, input [31:0] m_addr, r1, pc, input [19:0] imm_j,
		input [11:0] imm_i, imm_s, imm_b, input br, input[3:1] stall,
		output reg[31:0] addr_o, pc_o, output reg set_rd, jump, ls_o);
	
	localparam [5:0] JALX = 6'b110111;
	localparam [5:0] LS   = 6'b000011;

	wire jalx  = {opcode[6:4], opcode[2:0]} == JALX;
	wire jal   = jalx &  opcode[3];
	wire jalr  = jalx & ~opcode[3];

	wire ls    = {opcode[6], opcode[4:0]} == LS;
	wire st    = ls &  opcode[5];
	wire ld    = ls & ~opcode[5];

	wire h = |stall;
	wire ls0 = ls & ~h;
	wire ls1 = ls & stall[1];

	wire[11:0] immis = (jalr | ld) ? imm_i : st ? imm_s : 0;							

	wire [31:0] a1 = (jalr | ls0) ? r1 : 
                     (jal  | ls1 | br) ? pc : m_addr;
	
	wire [31:0] a2 = jalr | ls0 ? {{20{immis[11]}}, immis} : 
						     br ? {{19{imm_b[11]}}, imm_b, 1'b0} :	
						    jal ? {{12{imm_j[19]}}, imm_j, 1'b0} : 4;

	always @(*) begin
		set_rd = jalx;
		jump   = jalx | br;
		ls_o   = ls;
		addr_o = a1 + a2;
		pc_o   = h | jump | ls? pc : (pc + 4);
	end
endmodule