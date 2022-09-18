/* Modulo de comunicacao com o display LCD.
 * Recebe um numero de 8 bits representando um comando novo.
 * Os comandos sao executados conforme a mudanca de estado logico do sinal num_comando.
 * Executa o comando no display por meio dos sinais de saida conectados a controladora LCD_RS, LCD_E, LCD_RW e LCD_DATA. */

module displayLCD(CLK50MHz, num_comando, comando, LCD_RS, LCD_E,
	LCD_RW, LCD_DATA, espera);
	
	// clock de 50 MHz do kit
	input CLK50MHz;
	
	// indicador de numero de comando recebido
	// funciona como um clock para a entrada
	input num_comando;
	
	// codigo do comando
	input [7:0] comando;

	// LCD_RS 	- seleciona dados (1) ou instrucoes (0)
	// LCD_E 	- Executado os comando ou recebe os dados na transicao 1->0
	// LCD_RW 	- seleciona leitura (1) ou escrita (0)
	// LCD_DATA - entrada de dados ou instrucoes
	output LCD_RS, LCD_E, LCD_RW;
	output [7:0] LCD_DATA;
	
	// para testes (nao precisa ser utilizado)
	output espera;
	
	// direcao de escrita
	parameter
	write_inc = 1'b0,
	write_dec = 1'b1;
	
	// tabelas de codificacao de comandos

	// letras minusculas
	parameter
	char_a = 8'd0,
	char_b = 8'd1,
	char_c = 8'd2,
	char_d = 8'd3,
	char_e = 8'd4,
	char_f = 8'd5,
	char_g = 8'd6,
	char_h = 8'd7,
	char_i = 8'd8,
	char_j = 8'd9,
	char_k = 8'd10,
	char_l = 8'd11,
	char_m = 8'd12,
	char_n = 8'd13,
	char_o = 8'd14,
	char_p = 8'd15,
	char_q = 8'd16,
	char_r = 8'd17,
	char_s = 8'd18,
	char_t = 8'd19,
	char_u = 8'd20,
	char_v = 8'd21,
	char_w = 8'd22,
	char_x = 8'd23,
	char_y = 8'd24,
	char_z = 8'd25;
	// letras maiusculas
	parameter
	char_A_maiusculo = 8'd26,
	char_B_maiusculo = 8'd27,
	char_C_maiusculo = 8'd28,
	char_D_maiusculo = 8'd29,
	char_E_maiusculo = 8'd30,
	char_F_maiusculo = 8'd31,
	char_G_maiusculo = 8'd32,
	char_H_maiusculo = 8'd33,
	char_I_maiusculo = 8'd34,
	char_J_maiusculo = 8'd35,
	char_K_maiusculo = 8'd36,
	char_L_maiusculo = 8'd37,
	char_M_maiusculo = 8'd38,
	char_N_maiusculo = 8'd39,
	char_O_maiusculo = 8'd40,
	char_P_maiusculo = 8'd41,
	char_Q_maiusculo = 8'd42,
	char_R_maiusculo = 8'd43,
	char_S_maiusculo = 8'd44,
	char_T_maiusculo = 8'd45,
	char_U_maiusculo = 8'd46,
	char_V_maiusculo = 8'd47,
	char_W_maiusculo = 8'd48,
	char_X_maiusculo = 8'd49,
	char_Y_maiusculo = 8'd50,
	char_Z_maiusculo = 8'd51;
	// numeros
	parameter
	char_1 = 8'd52,
	char_2 = 8'd53,
	char_3 = 8'd54,
	char_4 = 8'd55,
	char_5 = 8'd56,
	char_6 = 8'd57,
	char_7 = 8'd58,
	char_8 = 8'd59,
	char_9 = 8'd60,
	char_0 = 8'd61;
	// simbolos
	parameter
	char_exclamacao = 8'd62,
	char_hashtag = 8'd63,
	char_cifrao = 8'd64,
	char_porcentagem = 8'd65,
	char_e_comercial = 8'd66,
	char_asterisco = 8'd67,
	char_abre_parenteses = 8'd68,
	char_fecha_parenteses = 8'd69,
	char_menos = 8'd70,
	char_underline = 8'd71,
	char_igual = 8'd72,
	char_mais = 8'd73,
	char_abre_colchete = 8'd74,
	char_fecha_colchete = 8'd75,
	char_ponto = 8'd76,
	char_maior = 8'd77,
	char_virgula = 8'd78,
	char_menor = 8'd79,
	char_barra_direita = 8'd80,
	char_interrogacao = 8'd81,
	char_barra_veritcal = 8'd82,
	char_apostrofe = 8'd83,
	char_aspas = 8'd84,
	char_ponto_e_virgula = 8'd85,
	char_dois_pontos = 8'd86;
	// acoes
	parameter
	char_espaco = 8'd87,
	char_backspace = 8'd88,
	char_seta_dir = 8'd89,
	char_seta_esq = 8'd90,
	char_home = 8'd91,
	char_end = 8'd92,
	char_seta_baixo = 8'd93,
	char_seta_cima = 8'd94;

	// ESTADOS
	parameter
	RESET1 = 8'd0,
	RESET2 = 8'd1,
	RESET3 = 8'd2,
	FUNC_SET = 8'd3,
	DESLIGA_DISPLAY = 8'd4,
	LIMPA_DISPLAY = 8'd5,
	LIGA_DISPLAY = 8'd6,
	ESPERA_COMANDO = 8'd7,
	ESCREVE_INC = 8'd8,
	ESCREVE_DEC = 8'd9,
	ESCREVE_CHAR = 8'd10,
	ABAIXA_LCD_E = 8'd11,
	SEGURA = 8'd12,
	ANDA_DIR = 8'd13,
	ANDA_ESQ = 8'd14,
	LINHA2 = 8'd15,
	POSICAO_FIM = 8'd16,
	LINHA1 = 8'd17,
	POSICAO_COMECO = 8'd18,
	SETA_BAIXO = 8'd19,
	SETA_CIMA = 8'd20;

	// registradores de estado
	reg [7:0] estado, proximo_estado;
	// registradores para entrada do display
	reg [7:0] LCD_DATA_r;
	reg LCD_RS_r, LCD_E_r, LCD_RW_r;
	// registrador para sequencia dos comandos
	reg num_comando_r;
	// clock interno com menor frequencia
	reg [19:0] CLK_CLOUNT_400Hz;
	reg CLK400Hz;
	// saida para testes
	reg espera_r;
	// registrador para caractere
	reg [7:0] char;
	// registrador para posicao na tela
	reg [4:0] posicao;
	// direcao de escrita
	reg write_dir;
	
	assign espera = espera_r;
	assign LCD_RS = LCD_RS_r;
	assign LCD_E = LCD_E_r;
	assign LCD_RW = LCD_RW_r;
	assign LCD_DATA = LCD_DATA_r;

	initial begin
		estado = RESET1;
		CLK_CLOUNT_400Hz = 20'h00000;
		num_comando_r = 1'b0;
		posicao = 5'b0;
	end

	// sinal de clock 400Hz
	// frequencia conforme comando mais demorado da controladora do display
	always @(posedge CLK50MHz) begin
		if (CLK_CLOUNT_400Hz <= 20'h0F424) begin
			CLK_CLOUNT_400Hz <= CLK_CLOUNT_400Hz + 1'b1;
		end
		else begin
			CLK_CLOUNT_400Hz <= 20'h00000;
			CLK400Hz <= ~CLK400Hz;
		end
	end
	
	// indicador de espera de comando
	always @(*) begin
		if (estado == ESPERA_COMANDO) begin
			espera_r <= 1'b1;
		end
		else begin
			espera_r <= 1'b0;
		end
	end

	// maquina de estados para controlar o display
	always @(posedge CLK400Hz) begin
		case(estado)
			// passo de inicializacao 1 (ver datasheet)
			RESET1: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h38;
				estado <= ABAIXA_LCD_E;
				proximo_estado <= RESET2;
			end
			
			// passo de inicializacao 2 (ver datasheet)
			RESET2: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h38;
				estado <= ABAIXA_LCD_E;
				proximo_estado <= RESET3;
			end
			
			// passo de inicializacao 3 (ver datasheet)
			RESET3: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h38;
				estado <= ABAIXA_LCD_E;
				proximo_estado <= FUNC_SET;
			end
			
			// passo de inicializacao 4
			// prepara o painel no modo de 8 bits
			// usa o modo de duas linhas (2x16)
			// usa a fonte de 5x11 pontos
			FUNC_SET: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h38;
				estado <= ABAIXA_LCD_E;
				proximo_estado <= DESLIGA_DISPLAY;
			end
			
			// desliga display e cursor
			DESLIGA_DISPLAY: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h08;
				estado <= ABAIXA_LCD_E;
				proximo_estado <= LIMPA_DISPLAY;
			end

			// limpa display e desliga o cursor
			LIMPA_DISPLAY: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h01;	// limpa
				estado <= ABAIXA_LCD_E;
				proximo_estado <= LIGA_DISPLAY;
			end
			
			// liga o display e liga o cursor
			LIGA_DISPLAY: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h0F;
				estado <= ABAIXA_LCD_E;
				proximo_estado <= ESPERA_COMANDO;
			end
			
			// espera um novo comando
			ESPERA_COMANDO: begin
				LCD_E_r <= 1'b1;
				// prossegue se alternar o bit num_comando_r
				if (num_comando != num_comando_r) begin
					num_comando_r <= num_comando;
					case(comando)
						char_a:
							begin
								char <= 8'b01100001;
								estado <= ESCREVE_INC;
							end
						char_b:
							begin
								char <= 8'b01100010;
								estado <= ESCREVE_INC;
							end
						char_c:
							begin
								char <= 8'b01100011;
								estado <= ESCREVE_INC;
							end
						char_d:
							begin
								char <= 8'b01100100;
								estado <= ESCREVE_INC;
							end
						char_e:
							begin
								char <= 8'b01100101;
								estado <= ESCREVE_INC;
							end
						char_f:
							begin
								char <= 8'b01100110;
								estado <= ESCREVE_INC;
							end
						char_g:
							begin
								char <= 8'b01100111;
								estado <= ESCREVE_INC;
							end
						char_h:
							begin
								char <= 8'b01101000;
								estado <= ESCREVE_INC;
							end
						char_i:
							begin
								char <= 8'b01101001;
								estado <= ESCREVE_INC;
							end
						char_j:
							begin
								char <= 8'b01101010;
								estado <= ESCREVE_INC;
							end
						char_k:
							begin
								char <= 8'b01101011;
								estado <= ESCREVE_INC;
							end
						char_l:
							begin
								char <= 8'b01101100;
								estado <= ESCREVE_INC;
							end
						char_m:
							begin
								char <= 8'b01101101;
								estado <= ESCREVE_INC;
							end
						char_n:
							begin
								char <= 8'b01101110;
								estado <= ESCREVE_INC;
							end
						char_o:
							begin
								char <= 8'b01101111;
								estado <= ESCREVE_INC;
							end
						char_p:
							begin
								char <= 8'b01110000;
								estado <= ESCREVE_INC;
							end
						char_q:
							begin
								char <= 8'b01110001;
								estado <= ESCREVE_INC;
							end
						char_r:
							begin
								char <= 8'b01110010;
								estado <= ESCREVE_INC;
							end
						char_s:
							begin
								char <= 8'b01110011;
								estado <= ESCREVE_INC;
							end
						char_t:
							begin
								char <= 8'b01110100;
								estado <= ESCREVE_INC;
							end
						char_u:
							begin
								char <= 8'b01110101;
								estado <= ESCREVE_INC;
							end
						char_v:
							begin
								char <= 8'b01110110;
								estado <= ESCREVE_INC;
							end
						char_w:
							begin
								char <= 8'b01110111;
								estado <= ESCREVE_INC;
							end
						char_x:
							begin
								char <= 8'b01111000;
								estado <= ESCREVE_INC;
							end
						char_y:
							begin
								char <= 8'b01111001;
								estado <= ESCREVE_INC;
							end
						char_z:
							begin
								char <= 8'b01111010;
								estado <= ESCREVE_INC;
							end
						char_A_maiusculo:
							begin
								char <= 8'b01000001;
								estado <= ESCREVE_INC;
							end
						char_B_maiusculo:
							begin
								char <= 8'b01000010;
								estado <= ESCREVE_INC;
							end
						char_C_maiusculo:
							begin
								char <= 8'b01000011;
								estado <= ESCREVE_INC;
							end
						char_D_maiusculo:
							begin
								char <= 8'b01000100;
								estado <= ESCREVE_INC;
							end
						char_E_maiusculo:
							begin
								char <= 8'b01000101;
								estado <= ESCREVE_INC;
							end
						char_F_maiusculo:
							begin
								char <= 8'b01000110;
								estado <= ESCREVE_INC;
							end
						char_G_maiusculo:
							begin
								char <= 8'b01000111;
								estado <= ESCREVE_INC;
							end
						char_H_maiusculo:
							begin
								char <= 8'b01001000;
								estado <= ESCREVE_INC;
							end
						char_I_maiusculo:
							begin
								char <= 8'b01001001;
								estado <= ESCREVE_INC;
							end
						char_J_maiusculo:
							begin
								char <= 8'b01001010;
								estado <= ESCREVE_INC;
							end
						char_K_maiusculo:
							begin
								char <= 8'b01001011;
								estado <= ESCREVE_INC;
							end
						char_L_maiusculo:
							begin
								char <= 8'b01001100;
								estado <= ESCREVE_INC;
							end
						char_M_maiusculo:
							begin
								char <= 8'b01001101;
								estado <= ESCREVE_INC;
							end
						char_N_maiusculo:
							begin
								char <= 8'b01001110;
								estado <= ESCREVE_INC;
							end
						char_O_maiusculo:
							begin
								char <= 8'b01001111;
								estado <= ESCREVE_INC;
							end
						char_P_maiusculo:
							begin
								char <= 8'b01010000;
								estado <= ESCREVE_INC;
							end
						char_Q_maiusculo:
							begin
								char <= 8'b01010001;
								estado <= ESCREVE_INC;
							end
						char_R_maiusculo:
							begin
								char <= 8'b01010010;
								estado <= ESCREVE_INC;
							end
						char_S_maiusculo:
							begin
								char <= 8'b01010011;
								estado <= ESCREVE_INC;
							end
						char_T_maiusculo:
							begin
								char <= 8'b01010100;
								estado <= ESCREVE_INC;
							end
						char_U_maiusculo:
							begin
								char <= 8'b01010101;
								estado <= ESCREVE_INC;
							end
						char_V_maiusculo:
							begin
								char <= 8'b01010110;
								estado <= ESCREVE_INC;
							end
						char_W_maiusculo:
							begin
								char <= 8'b01010111;
								estado <= ESCREVE_INC;
							end
						char_X_maiusculo:
							begin
								char <= 8'b01011000;
								estado <= ESCREVE_INC;
							end
						char_Y_maiusculo:
							begin
								char <= 8'b01011001;
								estado <= ESCREVE_INC;
							end
						char_Z_maiusculo:
							begin
								char <= 8'b01011010;
								estado <= ESCREVE_INC;
							end
						char_0:
							begin
								char <= 8'b00110000;
								estado <= ESCREVE_INC;
							end
						char_1:
							begin
								char <= 8'b00110001;
								estado <= ESCREVE_INC;
							end
						char_2:
							begin
								char <= 8'b00110010;
								estado <= ESCREVE_INC;
							end
						char_3:
							begin
								char <= 8'b00110011;
								estado <= ESCREVE_INC;
							end
						char_4:
							begin
								char <= 8'b00110100;
								estado <= ESCREVE_INC;
							end
						char_5:
							begin
								char <= 8'b00110101;
								estado <= ESCREVE_INC;
							end
						char_6:
							begin
								char <= 8'b00110110;
								estado <= ESCREVE_INC;
							end
						char_7:
							begin
								char <= 8'b00110111;
								estado <= ESCREVE_INC;
							end
						char_8:
							begin
								char <= 8'b00111000;
								estado <= ESCREVE_INC;
							end
						char_9:
							begin
								char <= 8'b00111001;
								estado <= ESCREVE_INC;
							end
						char_exclamacao:
							begin
								char <= 8'b00100001;
								estado <= ESCREVE_INC;
							end
						char_hashtag:
							begin
								char <= 8'b00100011;
								estado <= ESCREVE_INC;
							end
						char_cifrao:
							begin
								char <= 8'b00100100;
								estado <= ESCREVE_INC;
							end
						char_porcentagem:
							begin
								char <= 8'b00100101;
								estado <= ESCREVE_INC;
							end
						char_e_comercial:
							begin
								char <= 8'b00100110;
								estado <= ESCREVE_INC;
							end
						char_asterisco:
							begin
								char <= 8'b00101010;
								estado <= ESCREVE_INC;
							end
						char_abre_parenteses:
							begin
								char <= 8'b00101000;
								estado <= ESCREVE_INC;
							end
						char_fecha_parenteses:
							begin
								char <= 8'b00101001;
								estado <= ESCREVE_INC;
							end
						char_menos:
							begin
								char <= 8'b00101101;
								estado <= ESCREVE_INC;
							end
						char_underline:
							begin
								char <= 8'b01011111;
								estado <= ESCREVE_INC;
							end
						char_igual:
							begin
								char <= 8'b00111101;
								estado <= ESCREVE_INC;
							end
						char_mais:
							begin
								char <= 8'b00101011;
								estado <= ESCREVE_INC;
							end
						char_abre_colchete:
							begin
								char <= 8'b01011011;
								estado <= ESCREVE_INC;
							end
						char_fecha_colchete:
							begin
								char <= 8'b01011101;
								estado <= ESCREVE_INC;
							end
						char_ponto:
							begin
								char <= 8'b00101110;
								estado <= ESCREVE_INC;
							end
						char_maior:
							begin
								char <= 8'b00111110;
								estado <= ESCREVE_INC;
							end
						char_virgula:
							begin
								char <= 8'b00101100;
								estado <= ESCREVE_INC;
							end
						char_menor:
							begin
								char <= 8'b00111100;
								estado <= ESCREVE_INC;
							end
						char_barra_direita:
							begin
								char <= 8'b00101111;
								estado <= ESCREVE_INC;
							end
						char_interrogacao:
							begin
								char <= 8'b00111111;
								estado <= ESCREVE_INC;
							end
						char_barra_veritcal:
							begin
								char <= 8'b01111100;
								estado <= ESCREVE_INC;
							end
						char_apostrofe:
							begin
								char <= 8'b00100111;
								estado <= ESCREVE_INC;
							end
						char_aspas:
							begin
								char <= 8'b00100010;
								estado <= ESCREVE_INC;
							end
						char_ponto_e_virgula:
							begin
								char <= 8'b00111011;
								estado <= ESCREVE_INC;
							end
						char_dois_pontos:
							begin
								char <= 8'b00111010;
								estado <= ESCREVE_INC;
							end
						char_espaco:
							begin
								char <= 8'b00100000;
								estado <= ESCREVE_INC;
							end
						char_backspace:
							begin
								char <= 8'b00100000;
								estado <= ESCREVE_DEC;
							end
						char_seta_dir:
							begin
								estado <= ANDA_DIR;
							end
						char_seta_esq:
							begin
								estado <= ANDA_ESQ;
							end
						char_home:
							begin
								estado <= POSICAO_COMECO;
								posicao <= 5'd0;
							end
						char_end:
							begin
								estado <= POSICAO_FIM;
								posicao <= 5'd31;
							end
						char_seta_baixo:
							begin
								estado <= SETA_BAIXO;
							end
						char_seta_cima:
							begin
								estado <= SETA_CIMA;
							end
					endcase
				end
				else begin
					estado <= ESPERA_COMANDO;
				end
			end
			
			// escreve incrmentalmente (para a direita)
			ESCREVE_INC: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h06; //6
				estado <= ABAIXA_LCD_E;
				proximo_estado <= ESCREVE_CHAR;
				write_dir <= write_inc;
			end
			
			// escreve decrementalmente (para a esquerda)
			ESCREVE_DEC: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h04; // 4
				estado <= ABAIXA_LCD_E;
				proximo_estado <= ESCREVE_CHAR;
				write_dir <= write_dec;
			end
			
			// escreve um caractere e incrementa/decrementa o cursor
			ESCREVE_CHAR: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b1;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= char;
				estado <= ABAIXA_LCD_E;
				// incremento
				if (write_dir == write_inc) begin
					// proxima linha
					if (posicao == 5'd15) begin
						proximo_estado <= LINHA2;
						posicao <= 5'd16;
					end
					// fim da tela
					else if (posicao == 5'd31) begin
						proximo_estado <= POSICAO_FIM;
						posicao <= 5'd31;
					end
					else begin
						posicao <= posicao + 5'b1;
						proximo_estado <= ESPERA_COMANDO;
					end
				end
				// decremento
				else begin
					// linha anterior
					if (posicao == 5'd16) begin
						proximo_estado <= LINHA1;
						posicao <= 5'd15;
					end
					// comeco da tela
					else if (posicao == 5'd0) begin
						proximo_estado <= POSICAO_COMECO;
						posicao <= 5'd0;
					end
					else begin
						posicao <= posicao - 5'd1;
						proximo_estado <= ESPERA_COMANDO;
					end
				end
			end
			
			ANDA_DIR: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h14;
				estado <= ABAIXA_LCD_E;
				// proxima linha
				if (posicao == 5'd15) begin
					proximo_estado <= LINHA2;
					posicao <= 5'd16;
				end
				// fim da tela
				else if (posicao == 5'd31) begin
					proximo_estado <= POSICAO_FIM;
					posicao <= 5'd31;
				end
				else begin
					posicao <= posicao + 5'b1;
					proximo_estado <= ESPERA_COMANDO;
				end
			end
			
			ANDA_ESQ: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h10;
				estado <= ABAIXA_LCD_E;
				// linha anterior
				if (posicao == 5'd16) begin
					proximo_estado <= LINHA1;
					posicao <= 5'd15;
				end
				// comeco da tela
				else if (posicao == 5'd0) begin
					proximo_estado <= POSICAO_COMECO;
					posicao <= 5'd0;
				end
				else begin
					posicao <= posicao - 5'd1;
					proximo_estado <= ESPERA_COMANDO;
				end
			end
			
			LINHA2: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'hC0;
				estado <= ABAIXA_LCD_E;
				proximo_estado <= ESPERA_COMANDO;
			end
			
			POSICAO_FIM: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'hCF;
				estado <= ABAIXA_LCD_E;
				proximo_estado <= ESPERA_COMANDO;
			end
			
			LINHA1: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h8F;
				estado <= ABAIXA_LCD_E;
				proximo_estado <= ESPERA_COMANDO;
			end
			
			POSICAO_COMECO: begin
				LCD_E_r <= 1'b1;
				LCD_RS_r <= 1'b0;
				LCD_RW_r <= 1'b0;
				LCD_DATA_r <= 8'h80;
				estado <= ABAIXA_LCD_E;
				proximo_estado <= ESPERA_COMANDO;
			end
			
			SETA_BAIXO: begin
				if(posicao >= 0 && posicao <= 15) begin
					LCD_E_r <= 1'b1;
					LCD_RS_r <= 1'b0;
					LCD_RW_r <= 1'b0;
					LCD_DATA_r <= {3'b110,posicao};
					posicao <= posicao + 5'd16;
				end
				estado <= ABAIXA_LCD_E;
				proximo_estado <= ESPERA_COMANDO;
			end
			
			SETA_CIMA: begin
				if(posicao >= 16 && posicao <= 31) begin
					LCD_E_r <= 1'b1;
					LCD_RS_r <= 1'b0;
					LCD_RW_r <= 1'b0;
					LCD_DATA_r <= {3'b100,posicao} - 5'd16;
					posicao <= posicao - 5'd16;
				end
				estado <= ABAIXA_LCD_E;
				proximo_estado <= ESPERA_COMANDO;
			end

			// LCD_en: borda de descida carrega dado/instrucao na contraladora
			ABAIXA_LCD_E: begin
				LCD_E_r <= 1'b0;
				estado <= SEGURA;
			end
			
			SEGURA: begin
				estado <= proximo_estado;
			end
		endcase
	end

endmodule
