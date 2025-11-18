module alu(input [6:0] opcode, input [2:0] funct3, input [31:0] r1, r2, pc, 
			input [11:0] imm_i, input [19:0] imm_u, output reg [31:0] out, output reg set_rd, br);
	
	localparam [2:0] ADD  = 3'b000, SLL  = 3'b001, SLT  = 3'b010, SLTU = 3'b011,
					 XOR  = 3'b100, SRLA = 3'b101, OR   = 3'b110, AND  = 3'b111,
					
					 BEQ  = 3'b000, BNE  = 3'b001, BLT  = 3'b100, BGE  = 3'b101,
					 BLTU = 3'b110, BGEU = 3'b111;

	localparam [6:0] BRANCH = 7'b1100011;
	localparam [5:0] INT    = 6'b010011;
	localparam [5:0] UI     = 6'b010111;
	
	wire [5:0] opcodex = {opcode[6], opcode[4:0]};

	wire b = opcode  == BRANCH;
	wire i = opcodex == INT;
	wire u = opcodex == UI;

	wire o5 = opcode[5];
	wire ir = i & o5;

	wire add_sub = ~(ir & imm_i[10]);
	wire sr_la   =  ~o5 & imm_i[10];

	wire [31:0] imm = i & ~o5 ? {{20{imm_i[11]}}, imm_i} : 
						    u ? {imm_u, 12'b0} : 0;
	
	wire [31:0] v1 = b | i  ? r1 : pc; 
	wire [31:0] v2 = b | ir ? r2 : imm;
	
	wire signed [31:0] s1 = v1;
	wire signed [31:0] s2 = v2;
	
	reg [31:0] add;	
	reg eq, ult, slt;

	always @(*) begin
		set_rd = i | u;	
		
		if ((i & (funct3 == ADD)) | (u & ~o5))
			add = v1 + (add_sub ? v2 : -v2);

		if(i | b) begin
			eq  = v1 == v2;
			ult = v1 <  v2;
			slt = s1 <  s2;
		end

		if(i)
			case(funct3)
	    		ADD : out = add;
				AND : out = v1 & v2; 
				OR  : out = v1 | v2;
				XOR : out = v1 ^ v2; 
				SLT : out = {31'b0, slt};
				SLTU: out = {31'b0, ult}; 
				SLL : out = v1 << v2[4:0];
				SRLA: out = sr_la ? v1 >> v2[4:0]: s1 >> v2[4:0]; 
			endcase  
		else if(u) 
			out = o5 ? v2 : add;
		else
			out = 0;	

		if(b)
			case(funct3)
				BEQ : br =  eq;
				BNE : br = ~eq;
				BLT : br =  slt;
				BGE : br = ~slt;
				BLTU: br =  ult;
				BGEU: br = ~ult;
				default: br = 1'b0;
			endcase
		else
			br = 1'b0;
	end
endmodule