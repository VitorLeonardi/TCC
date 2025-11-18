`timescale 1ns/1ns
module tb_cpu();
	reg clk;
	reg reset = 1;
	reg [3:0] rin = 0;
	reg sft = 0;
	wire[47:0] rout;

	cpu riscv(clk, reset, rin, sft, rout);

  initial begin
      clk = 0;
      forever #1 clk = ~clk;
  end
	
	initial begin
        #100
				$stop;
	end
endmodule
