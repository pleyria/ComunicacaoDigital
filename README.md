# Módulos de Teclado PS/2 e Display LCD para kit FPGA DE2-115

Projeto da disciplina Laboratório de Sistemas Computacionais: Comunicação Digital (1º semestre/2022). Implementação em Verilog da comunicação de um teclado PS/2 com o kit FPGA DE2-115 como método de entrada e *display* LCD como dispositivo de saída.

## Arquivos

- Projeto Comunicação Digital LAB: Projeto Quartus com código em Verilog para a integração da comunicação do telcado PS/2 com o *display* LCD.
- Referências: Material teórico usado como referência no desenvolvimento do projeto.

## Módulos

Dentro da pasta "Projeto Comunicação Digital LAB", encontram-se os seguintes módulos alguns módulos de E/S que podem ser utilizados separadamente.

### displayLDC.v

O arquivo `displayLCD.v` implementa o módulo de comunicação com o *display* LCD. Como entrada, ele recebe um número de 8 bits representando um comando novo. Os comandos são executados conforme a mudança do estado lógico no sinal `num_comando`, que funciona como um sinal de *clock*.

Este módulo executa o comando no *display* por meio dos sinais de saída conectados à controladora do kit FPGA. Os comandos disponíveis incluem caracteres convencionais do teclado e comandos especiais para apagar partes do texto ou movimentar o cursor pela tela. O código (8 bits) referente a cada comando pode ser encontrado no próprio código, presente nas listas `parameter`.

Os tipos de caracteres que podem ser exibidos no *display* LCD são mostrados a seguir:

1. Letras maiúsculas
   
   ![alt text](Referências/FPGA%20fotos/teste_letras_maiusculas.jpg)

2. Letras minusculas
   
   ![alt text](Referências/FPGA%20fotos/teste_letras_minusculas.jpg)

3. Números
   
   ![alt text](Referências/FPGA%20fotos/teste_numeros.jpg)

4. Símbolos especiais
   
   ![alt text](Referências/FPGA%20fotos/teste_simbolos.jpg)

Uma explicação deste módulo pode ser encontrada [neste vídeo](https://youtu.be/hXZPzcdNX2M)

### leitorPS2.v

O arquivo `leitorPS2.v` implementa o módulo de leitura do sinal do teclado PS/2. Como entrada, ele recebe os pacotes de dados do teclado de forma serial. O leitor produz uma saída paralela de um registrador com o *scan code* lido. As entradas `clk_ps2` e `data` são os sinais de entrada do teclado PS/2 e devem seguir a designação dos pinos conforme o manual do kit FPGA. A saída `scan_code` representa os 8 bits de um *scan code* que foi lido de maneira sequencial.

Para utilizar este módulo, é necessário usar também o módulo `registradorDesloc.v` para implementar um registrador de deslocamento.

O módulo `leitorPS2.v` pode ser utilizado de maneira independente em outros projetos, como método de entrada, porém ainda é necessário fazer um tratamento posterior dos dados recebidos, porque a saída deste módulo é apenas uma sequência de *scan codes* recebidos do teclado PS/2. A relação dos *scan codes* com as teclas pressionadas no teclado pode ser encontrada em detalhes no material de referência do projeto.

Uma explicação deste módulo pode ser encontrada [neste vídeo](https://youtu.be/HMGUHCdFYm4)

### PS2_to_LCD.v

O arquivo `PS2_to_LCD.v` implementa o módulo de conversão PS/2 para LCD. O objetivo deste módulo é transformar uma sequência de *scan codes* PS/2 em comandos únicos que possam ser recebidos e executados pelo módulo do *display* LCD. Como entrada, este componente recebe um *scan code* (8 bits), o sinal `finish_ps2`, indicando quando um sinal novo é recebido (fica com nível alto quando um código acaba de ser lido e com nível baixo quando o código ainda está sendo processado pelo leitor PS/2). As saídas são o comando (8 bits) seguindo a mesma codificação presente no módulo LCD e o sinal `num_comando` que serve como um *clock*, mudando de nível lógico a cada nova saída produzida.

Para realizar a conversão de PS/2 para os comandos LCD, este módulo implementa uma máquina de estados finitos. Para maiores detalhes sobre essa implementação, pode-se consultar o relatório técnico.

Uma explicação deste módulo pode se encontrada [neste vídeo](https://youtu.be/51DaE-nJqPw)

### ProjetoTeclado.v

Este é um exemplo de projeto que utiliza todos os componentes apresentados. O arquivo `ProjetoTeclado.v` realiza a integração do leitor PS/2, conversor PS/2 para LCD, *display* LCD e *displays* sete segmentos para fazer a implementação de um editor de texto simples com o kit FPGA.

Por ser o módulo principal do projeto, ele realiza a atribuição dos pinos de entrada e saída, conforme a configuração do kit FPGA, seguindo as especificações do manual para os *displays* e conector PS/2.

A imagem a seguir mostra a conexão do teclado ao kit FPGA pela entrada PS/2 no canto superior direito da placa, juntamente com a utilização do *display* LCD e os *displays* de sete segmentos como método de verificação de erros, através da visualização dos *scan codes* lidos.

![alt text](Referências/FPGA%20fotos/teste_conexao.jpg)

Um explicação deste módulo pode se encontrada [neste vídeo](https://youtu.be/XifBsfs18XA)
