
`include "sram.v"
/*
  example that copies 16 bit words downwards in the 1 MB SRAM.
  
  This is a good start for anyone wanting to use the SRAM with ICOboard.

  icetime -d hx8k -mtr example.rpt example.asc:
            Timing estimate: 5.04 ns (198.51 MHz)

*/
module top(
	// global clock
	input  pclk,

	// interface to 1MB SRAM icoboard
	output [18:0] SRAM_A,
	inout [15:0] SRAM_D,
	output SRAM_nCE,
	output SRAM_nWE,
	output SRAM_nOE,
	output SRAM_nLB,
	output SRAM_nUB
);

    // local bus for other modules
	reg lower_byte = 1;
	reg upper_byte = 1;
	reg write_enable;
	reg [18:0] address;
	wire [15:0] read_data;
	reg [15:0] write_data;
	
	icoboard_sram sram(
		.clk(pclk),
		
		// pin interface to 1MB SRAM icoboard
		.SRAM_A(SRAM_A),
		.SRAM_D(SRAM_D),
		.SRAM_nCE(SRAM_nCE),
		.SRAM_nWE(SRAM_nWE),
		.SRAM_nOE(SRAM_nOE),
		.SRAM_nLB(SRAM_nLB),
		.SRAM_nUB(SRAM_nUB),
		
		.lower_byte(lower_byte),
		.upper_byte(upper_byte),
		.write_enable(write_enable),
		.address(address),
		.read_data(read_data),
		.write_data(write_data)
	);

	// move memory around
	
	reg [15:0] to_move;
	
	always@(posedge pclk) begin
			if (write_enable) begin
				write_enable <=0;
				address <= address - 1;
			end else begin
				write_enable <=1;
				write_data <= to_move;
				to_move <= read_data;
			end
	end
endmodule

