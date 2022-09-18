/* Integracao do leitor PS/2, conversor PS/2->LCD, display LCD e displays sete seg. */

module ProjetoTeclado(CLK50MHz, data_ps2, clk_ps2, hex1, hex0, end_scan, LCD_RS, LCD_E, LCD_RW, LCD_DATA,
 LCD_ON, LCD_BLON, espera);
 
	// clock 50 MHz do kit
	input CLK50MHz;
	
	// PS2
	input data_ps2, clk_ps2;
	output [6:0] hex1, hex0;
	output end_scan;
	
	// LCD
	output LCD_RS, LCD_E, LCD_RW, LCD_ON, LCD_BLON;
	output [7:0] LCD_DATA;
	output espera;
	
	assign LCD_BLON = 1'b1;
	assign LCD_ON = 1'b1;
	
	wire [7:0] scan;
	wire finish_ps2;

	wire [7:0] comando;
	wire num_comando;

	assign end_scan = finish_ps2;

	leitorPS2(.clk_ps2(clk_ps2), .data(data_ps2), .scan_code(scan), .end_scan(finish_ps2));

	PS2_to_LCD(.scancode(scan), .finish_ps2(finish_ps2), .comando(comando), .num_comando(num_comando));
	
	hexto7segment display1(.bin(scan[7:4]), .hex(hex1));
	hexto7segment display0(.bin(scan[3:0]), .hex(hex0));
	
	displayLCD(.CLK50MHz(CLK50MHz), .num_comando(num_comando), .comando(comando), .LCD_RS(LCD_RS), .LCD_E(LCD_E), .LCD_RW(LCD_RW), .LCD_DATA(LCD_DATA), .espera(espera));
	
endmodule
