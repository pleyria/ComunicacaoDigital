/* Template de registrador de deslocamento de 8 bits do Quartus, com alteracoes.
 * Escrita sincrona com o sinal enable.
 * Bits deslocados da esquerda p/ direita.
 * Reset assincrono. */

module registradorDesloc(clk, enable, reset, sr_in, sr_out);
	parameter N = 8;
	
	input clk, enable, reset;
	input sr_in;
	output [N-1:0] sr_out;

	// Declare the shift register
	reg [N-1:0] sr;

	// Shift everything over, load the incoming bit
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1'b1) begin
			// Load N zeros 
			sr <= 8'b0;
		end
		else if (enable == 1'b1) begin
			sr[N-2:0] <= sr[N-1:1];
			sr[N-1] <= sr_in;
		end
	end

	// Catch the outgoing bit
	assign sr_out = sr;

endmodule
