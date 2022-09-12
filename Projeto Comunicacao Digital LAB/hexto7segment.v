/* Decodificador hexadecimal para display sete sgmentos.
 * Recebe uma entrada binaria de 4 bits.
 * Produz uma saida hexadecimal para display sete segmentos. */
 
module hexto7segment(bin, hex);
	// valor binario de entrada 0000 - 1111
	input [17:0] bin;
	// valor hexadecimal de saida 0 - F
	output [6:0] hex;
	
	reg [6:0] segmentos;
		 
	always @(bin) begin
		case (bin[3:0])
			// leds tipo anodo comun
			// 0 = ligado
			// 1 = desligado
			4'b0000: segmentos = 7'b1000000;	// 0
			4'b0001: segmentos = 7'b1111001;	// 1
			4'b0010: segmentos = 7'b0100100;	// 2
			4'b0011: segmentos = 7'b0110000;	// 3
			4'b0100: segmentos = 7'b0011001;	// 4
			4'b0101: segmentos = 7'b0010010;	// 5
			4'b0110: segmentos = 7'b0000010;	// 6
			4'b0111: segmentos = 7'b1111000;	// 7
			4'b1000: segmentos = 7'b0000000;	// 8
			4'b1001: segmentos = 7'b0010000;	// 9
			4'b1010: segmentos = 7'b0001000;	// A
			4'b1011: segmentos = 7'b0000011;	// B
			4'b1100: segmentos = 7'b0100111;	// C
			4'b1101: segmentos = 7'b0100001;	// D
			4'b1110: segmentos = 7'b0000110;	// E
			4'b1111: segmentos = 7'b0001110;	// F
			default: segmentos = 7'b1111111;
		endcase
	end

	assign hex = segmentos;

endmodule
