/* Modulo de leitura do sinal de teclado PS2.
 * Recebe os pacotes de dados do teclado de forma serial.
 * Produz uma saida paralela de um registrador com o scan code lido. */
 
module leitorPS2(clk_ps2, data, scan_code, end_scan, count);
	// sinais de clock e dados da conexao PS2
	input clk_ps2, data;
	
	// sinal de controle que indica fim do recebimento de um pacote
	output end_scan;
	
	// saida do contador de ciclos (utilizar apenas para testes em waveform)
	output [7:0] count;
	
	// scan code do pacote lido (hexadecimal)
	output [7:0] scan_code;
	
	// conta o numero de bits recebidos
	reg [7:0] counter = 7'b0;
	
	// indica se o valor lido deve ser armazenaod no pacote
	reg write = 1'b0;
	
	// indica se a transmissao terminou
	reg end_scan_reg = 1'b0;
	
	// registrador de deslocamento
	registradorDesloc regDesloc(
		.clk(!clk_ps2),
		.enable(write),
		.reset(1'b0),
		.sr_in(data),
		.sr_out(scan_code)
	);
	
	// inicia uma transmissao na descida do clock
	always @(negedge clk_ps2) begin
	
		// incrementa o contador
		counter <= counter + 8'b1;
		
		// zera o contador ao terminar um pacote (11 bits)
		if(counter == 8'd10) begin
			counter <= 8'b0;
		end
		
		// bit de fim
		if(counter == 8'd9) begin
			end_scan_reg <= 1'b1;
		end
		else begin
			end_scan_reg = 1'b0;
		end
		
		// bit de escrita fica ativo somente para os bits de dados
		if(counter < 8'd8) begin
			write <= 1'b1;
		end
		else begin
			write <= 1'b0;
		end
	end

	// atribuicao das saidas
	assign count = counter;
	assign end_scan = end_scan_reg;
	
endmodule
