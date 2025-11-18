module digits(input [31:0] r, input s, output reg [47:0] d);
	integer i;

	wire [23:0] w = s ? r[31:8] : r[23:0];

	reg [7:0] map [0:15];

	initial begin 
		map[4'h0] = 8'hC0;	map[4'h1] = 8'hF9;
		map[4'h2] = 8'hA4;	map[4'h3] = 8'hB0;
		map[4'h4] = 8'h99;	map[4'h5] = 8'h92;
		map[4'h6] = 8'h82;	map[4'h7] = 8'hF8;
		map[4'h8] = 8'h80;	map[4'h9] = 8'h98;
		map[4'hA] = 8'h88;	map[4'hB] = 8'h83;
		map[4'hC] = 8'hC6;	map[4'hD] = 8'hA1;
		map[4'hE] = 8'h86;	map[4'hF] = 8'h8E;
	end


	always@(*) begin
		for(i = 0; i < 6; i = i + 1)
			d[8*i +: 8] = map[w[4*i +: 4]];

		d[7] = s;
	end


endmodule

/*
	initial begin //H76543210---------------H76543210
		map[4'h0] = 8'b11000000;	map[4'h1] = 8'b11111001;
		map[4'h2] = 8'b10100100;	map[4'h3] = 8'b10110000;
		map[4'h4] = 8'b10011001;	map[4'h5] = 8'b10010010;
		map[4'h6] = 8'b10000010;	map[4'h7] = 8'b11111000;
		map[4'h8] = 8'b10000000;	map[4'h9] = 8'b10011000;
		map[4'hA] = 8'b10001000;	map[4'hB] = 8'b10000011;
		map[4'hC] = 8'b11000110;	map[4'hD] = 8'b10100001;
		map[4'hE] = 8'b10000110;	map[4'hF] = 8'b10001110;
	end
*/