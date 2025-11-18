module ls_bytes(input [2:0] funct3, input [31:0] ram, input [31:0] r2, input[1:0] l_addr, input[1:0] s_addr, input ls, input s, 
	           output reg[31:0] out, output reg [3:0] byteena);
	
	localparam [2:0] B  = 3'b000, H  = 3'b001, W  = 3'b010, 
					 BU = 3'b100, HU = 3'b101;

	reg [07:0] rb = 0;
	reg [15:0] rh = 0;
	wire f = ~funct3[2];
	
	always @(*) begin
		out = 0;
		byteena = 0;
		if(ls) begin
			if(s) case(funct3)
				B: begin
					byteena = 4'b1  << s_addr;
					out[(s_addr * 8) +: 8] = r2[07:0];
				end 
				H: begin
					byteena = 4'b11 << s_addr[1];
					out[(s_addr[1] * 16) +: 16] = r2[15:0];
			    end
			    W: begin 
			    	byteena = 4'b1111;
			    	out = r2;
			    end
			endcase	
			else case(funct3)
				B, BU: begin
					rb  = ram[(l_addr * 8) +: 8];
				    out = {{24{f & rb[07]}}, rb};
				end 
				H, HU : begin
					rh  = ram[(l_addr[1] * 16) +: 16];
				    out = {{16{f & rh[15]}}, rh};
				end
				W : out = ram;    
			endcase	
		end
	end
endmodule