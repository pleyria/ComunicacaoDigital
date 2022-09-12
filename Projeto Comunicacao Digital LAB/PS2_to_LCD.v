/* Modulo de conversao PS/2 para LCD.
 * Recebe scan codes PS/2 e o sinal de codigo novo finish_ps2.
 * Gera os comandos para o o display conforme os scancodes.
 * A cada comando gerado, o nivel logico de num_comando e alternado.*/

module PS2_to_LCD(scancode, finish_ps2, comando, num_comando);
	// PS2
	input [7:0] scancode;
	input finish_ps2;
	
	// LCD
	output [7:0] comando;
	output num_comando;
	
	reg [3:0] estado;
	reg [7:0] comando_r;
	reg num_comando_r;
	reg shift;
	
	// estados
	parameter
	INICIO = 4'd0,
	SIMPLES = 4'd1,
	BREAK_1 = 4'd2,
	BREAK_2 = 4'd3,
	DUPLO_1 = 4'd4,
	DUPLO_2 = 4'd5,
	BREAK_DUPLO = 4'd6;
	
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
	
	assign comando = comando_r;
	assign num_comando = num_comando_r;

	initial begin
		estado = INICIO;
		comando_r = 8'hFF;
		num_comando_r = 1'b0;
		shift = 1'b0;
	end
	
	// circuito para ativar o always na
	// borda de descida e de subida
	reg r_finish_ps2 = 1'b0;
	wire pos_neg_finish_ps2 = (r_finish_ps2 ^ finish_ps2);
	
	always @(posedge pos_neg_finish_ps2) begin
	
		r_finish_ps2 = ~r_finish_ps2;
	
		case(estado)
			INICIO: begin
				if (scancode == 8'hE0) begin
					estado <= DUPLO_1;
				end
				else begin
					estado <= SIMPLES;
				end
			end
			
			SIMPLES: begin
				if (scancode == 8'hF0) begin
					estado <= BREAK_1;
				end
				else begin
					case(scancode)
						// letras
						8'h1C: begin
							if(shift) begin
								comando_r <= char_A_maiusculo;
							end
							else begin
								comando_r <= char_a;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h32: begin
							if(shift) begin
								comando_r <= char_B_maiusculo;
							end
							else begin
								comando_r <= char_b;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h21: begin
							if(shift) begin
								comando_r <= char_C_maiusculo;
							end
							else begin
								comando_r <= char_c;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h23: begin
							if(shift) begin
								comando_r <= char_D_maiusculo;
							end
							else begin
								comando_r <= char_d;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h24: begin
							if(shift) begin
								comando_r <= char_E_maiusculo;
							end
							else begin
								comando_r <= char_e;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h2B: begin
							if(shift) begin
								comando_r <= char_F_maiusculo;
							end
							else begin
								comando_r <= char_f;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h34: begin
							if(shift) begin
								comando_r <= char_G_maiusculo;
							end
							else begin
								comando_r <= char_g;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h33: begin
							if(shift) begin
								comando_r <= char_H_maiusculo;
							end
							else begin
								comando_r <= char_h;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h43: begin
							if(shift) begin
								comando_r <= char_I_maiusculo;
							end
							else begin
								comando_r <= char_i;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h3B: begin
							if(shift) begin
								comando_r <= char_J_maiusculo;
							end
							else begin
								comando_r <= char_j;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h42: begin
							if(shift) begin
								comando_r <= char_K_maiusculo;
							end
							else begin
								comando_r <= char_k;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h4B: begin
							if(shift) begin
								comando_r <= char_L_maiusculo;
							end
							else begin
								comando_r <= char_l;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h3A: begin
							if(shift) begin
								comando_r <= char_M_maiusculo;
							end
							else begin
								comando_r <= char_m;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h31: begin
							if(shift) begin
								comando_r <= char_N_maiusculo;
							end
							else begin
								comando_r <= char_n;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h44: begin
							if(shift) begin
								comando_r <= char_O_maiusculo;
							end
							else begin
								comando_r <= char_o;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h4D: begin
							if(shift) begin
								comando_r <= char_P_maiusculo;
							end
							else begin
								comando_r <= char_p;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h15: begin
							if(shift) begin
								comando_r <= char_Q_maiusculo;
							end
							else begin
								comando_r <= char_q;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h2D: begin
							if(shift) begin
								comando_r <= char_R_maiusculo;
							end
							else begin
								comando_r <= char_r;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h1B: begin
							if(shift) begin
								comando_r <= char_S_maiusculo;
							end
							else begin
								comando_r <= char_s;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h2C: begin
							if(shift) begin
								comando_r <= char_T_maiusculo;
							end
							else begin
								comando_r <= char_t;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h3C: begin
							if(shift) begin
								comando_r <= char_U_maiusculo;
							end
							else begin
								comando_r <= char_u;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h2A: begin
							if(shift) begin
								comando_r <= char_V_maiusculo;
							end
							else begin
								comando_r <= char_v;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h1D: begin
							if(shift) begin
								comando_r <= char_W_maiusculo;
							end
							else begin
								comando_r <= char_w;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h22: begin
							if(shift) begin
								comando_r <= char_X_maiusculo;
							end
							else begin
								comando_r <= char_x;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h35: begin
							if(shift) begin
								comando_r <= char_Y_maiusculo;
							end
							else begin
								comando_r <= char_y;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h1A: begin
							if(shift) begin
								comando_r <= char_Z_maiusculo;
							end
							else begin
								comando_r <= char_z;
							end
							num_comando_r <= ~num_comando_r;
						end
						// numeros
						8'h45: begin
							if(shift) begin
								comando_r <= char_fecha_parenteses;
							end
							else begin
								comando_r <= char_0;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h16: begin
							if(shift) begin
								comando_r <= char_exclamacao;
							end
							else begin
								comando_r <= char_1;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h1E: begin
							// nao tem arroba @ no display
							// a tecla 2 so mostra o numero 2 mesmo
							if(!shift) begin
								comando_r <= char_2;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h26: begin
							if(shift) begin
								comando_r <= char_hashtag;
							end
							else begin
								comando_r <= char_3;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h25: begin
							if(shift) begin
								comando_r <= char_cifrao;
							end
							else begin
								comando_r <= char_4;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h2E: begin
							if(shift) begin
								comando_r <= char_porcentagem;
							end
							else begin
								comando_r <= char_5;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h36: begin
							// tecla 6 so mostra o 6
							if(!shift) begin
								comando_r <= char_6;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h3D: begin
							if(shift) begin
								comando_r <= char_e_comercial;
							end
							else begin
								comando_r <= char_7;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h3E: begin
							if(shift) begin
								comando_r <= char_asterisco;
							end
							else begin
								comando_r <= char_8;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h46: begin
							if(shift) begin
								comando_r <= char_abre_parenteses;
							end
							else begin
								comando_r <= char_9;
							end
							num_comando_r <= ~num_comando_r;
						end
						// simbolos
						8'h0E: begin
							if(shift) begin
								comando_r <= char_aspas;
							end
							else begin
								comando_r <= char_apostrofe;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h4E: begin
							if(shift) begin
								comando_r <= char_underline;
							end
							else begin
								comando_r <= char_menos;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h55: begin
							if(shift) begin
								comando_r <= char_mais;
							end
							else begin
								comando_r <= char_igual;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h41: begin
							if(shift) begin
								comando_r <= char_menor;
							end
							else begin
								comando_r <= char_virgula;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h49: begin
							if(shift) begin
								comando_r <= char_maior;
							end
							else begin
								comando_r <= char_ponto;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h4A: begin
							if(shift) begin
								comando_r <= char_dois_pontos;
							end
							else begin
								comando_r <= char_ponto_e_virgula;
							end
							num_comando_r <= ~num_comando_r;
						end
						8'h51: begin
							if(shift) begin
								comando_r <= char_interrogacao;
							end
							else begin
								comando_r <= char_barra_direita;
							end
							num_comando_r <= ~num_comando_r;
						end
						// acoes
						8'h12, 8'h59: begin
							shift	<= 1'b1;
						end
						8'h66: begin
							comando_r <= char_backspace;
							num_comando_r <= ~ num_comando_r;
						end
						8'h29: begin
							comando_r <= char_espaco;
							num_comando_r <= ~ num_comando_r;
						end
						8'h74: begin
							comando_r <= char_seta_dir;
							num_comando_r <= ~ num_comando_r;
						end
						8'h6b: begin
							comando_r <= char_seta_esq;
							num_comando_r <= ~ num_comando_r;
						end
						8'h6c: begin
							comando_r <= char_home;
							num_comando_r <= ~ num_comando_r;
						end
						8'h69: begin
							comando_r <= char_end;
							num_comando_r <= ~ num_comando_r;
						end
						8'h72: begin
							comando_r <= char_seta_baixo;
							num_comando_r <= ~ num_comando_r;
						end
						8'h75: begin
							comando_r <= char_seta_cima;
							num_comando_r <= ~ num_comando_r;
						end
						
						default: begin
							comando_r <= 8'hFF;
						end
					endcase
					estado <= INICIO;
				end
			end
			
			BREAK_1: begin
				if (scancode == 8'h12 || scancode == 8'h59) begin
					shift <= 1'b0;
				end
				estado <= BREAK_2;
			end
			
			BREAK_2: begin
				estado <= INICIO;
			end
			
			DUPLO_1: begin
				estado <= DUPLO_2;
			end
			
			DUPLO_2: begin
				if (scancode == 8'hF0) begin
					estado <= BREAK_DUPLO;
				end
				else begin
					estado <= SIMPLES;
				end
			end
			
			BREAK_DUPLO: begin
				estado <= BREAK_1;
			end
		endcase
	end

endmodule
