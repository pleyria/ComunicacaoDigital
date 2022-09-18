# Comunicacao Digital

Projeto da disciplina Laboratório de Sistemas Computacionais: Comunicação Digital (1º semestre/2022). Implementação em Verilog da comunicação de um teclado PS/2 com o kit FPGA DE2-115 como método de entrada e *display* LCD como dispositivo de saída.

## Arquivos

- Projeto Comunicação Digital LAB: Projeto Quartus com código em Verilog para a integração da comunicação do telcado PS/2 com o *display* LCD.
- Referências: Material téorico usado como referência no desenvolvimento do projeto.

## Módulos

Dentro da pasta "Projeto Comunicação Digital LAB", encontram-se os seguintes módulos:

- `displayLCD.v`: Módulo de comunicação com o *display* LCD. Recebe um número de 8 bits representando um comando novo. Os comandos são executados conforme a mudança do estado lógico no sinal `num_comando`. Executa o comando no *display* por meio dos sinais de saída conectados à controladora do kit FPGA.
- `leitorPS2.v`: Módulo de leitura do sinal do teclado PS/2. Recebe os pacotes de dados do teclado de forma serial. Produz uma saída paralela de um registrador com o *scan code* lido. Utiliza o módulo `registradorDesloc.v` para implementar um registrador de deslocamento interno.
- `PS2_to_LCD.v`:  Módulo de conversão PS/2 para LCD. Recebe *scan codes* PS/2 e o sinal de código novo `finish_ps2`. Gera comandos para o *display* conforme os *scan codes*. A cada comando gerado, o nivel lógico de `num_comando` é alternado.
- `hexto7segment.v`: Módulo usado apenas para testes. Decodificador hexadecimal para *display* de sete segmentos. Utilizado para verificar os *scan codes* recebidos do teclado.
- `ProjetoTeclado.v`: Módulo principal. Integração do leitor PS/2, coconversor PS/2 para LCD, *display* LCD e *displays* sete seg. Realiza a atribuição dos pinos de entrada e saída, conforme a configuração do kit FPGA.

O módulo `displayLCD.v` pode ser utilizado de maneira independente em outros projetos, como método de saída. Basta seguir a codificação dos comandos apresentados no arquivo, de forma a se gerar os símbolos desejados no *display* LCD.

O módulo `leitorPS2.v` pode ser utilizado de maneira independente em outros projetos, como método de entrada, porém ainda é necessário fazer um tratamento posterior dos dados recebidos, porque a saída deste módulo é apenas uma sequência de *scan codes* recebidos do teclado PS/2.

O módulo `S2_to_LCD.v` pode ser modificado para que a sequência de *scan codes* recebidos seja convertida em códigos únicos e usados em outros componentes.
