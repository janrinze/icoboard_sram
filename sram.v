/*
 *  SRAM access module for ICOBOARD
 *
 *   write cycle:
 *            ____       ____
 *      _____|    |_____|    |____  clk
 *
 *            __________      
 *      _____/          \_________  address
 *            __________      
 *      _____/____/     \_________  write_enable
 *      __________       _________
 *                \_____/           SRAM_nWE
 *                 _____      
 *      __________/     \_________  Data to SRAM
 *      
 *
 *   read cycle :
 *            ____       ____
 *      _____|    |_____|    |____  clk
 *
 *            __________      
 *      _____/          \_________  address
 *
 *      __________________________  write_enable
 *      __________       _________
 *                \_____/           SRAM_nOE
 *                 _____      
 *      __________/     \_________  Data from SRAM
 *                      ^ 
 *                      |           latch data on rising clk.
 */
module icoboard_sram(
    // clock for access cycle.
    // write only during low
    // max 100 MHz (10ns)
	input clk,
	
	// pin interface to 1MB SRAM icoboard
	output [18:0] SRAM_A,
	inout [15:0] SRAM_D,
	output SRAM_nCE,
	output SRAM_nWE,
	output SRAM_nOE,
	output SRAM_nLB,
	output SRAM_nUB,
	


	// upperbyte/lowerbyte select for write access
    input lower_byte,
    input upper_byte,
    // write_enable 
	input write_enable,
    
    // 19 address lines for 512kx16 SRAM
    input  [18:0] address,
    
    // 16 bit I/O
    output [15:0] read_data,
    input  [15:0] write_data,
);
	
	// setup pins to SRAM data read/write
    SB_IO #(
        .PIN_TYPE(6'b 1010_01),
        .PULLUP(1'b 0)
    ) sram_io [15:0] (
        .PACKAGE_PIN(SRAM_D),
        // output data during phi2 only.
        .OUTPUT_ENABLE(write_enable & (~clk)),
        .D_OUT_0(write_data),
        .D_IN_0(read_data)
    );
    

    wire phi2_nWE,write_lower_byte,write_upper_byte;
	
	// address needs to settle before we write.
    assign phi2_nWE = ~write_enable & ~clk;

    assign write_lower_byte = lower_byte & write_enable;
    assign write_upper_byte = upper_byte & write_enable;
    
    // connect wires to SRAM chip
    assign SRAM_A   = address;
    assign SRAM_nCE = 0;
    assign SRAM_nWE = phi2_nWE;
    assign SRAM_nOE = phi2_nWE;
    assign SRAM_nLB = ~write_lower_byte;
    assign SRAM_nUB = ~write_upper_byte;

endmodule
