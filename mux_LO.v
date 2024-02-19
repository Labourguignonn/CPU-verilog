module mux_LO(input wire [31:0] multLo, // Entrada de 32 bits para o multiplicador Lo
              input wire [31:0] divLo, // Entrada de 32 bits para o divisor Lo
              input wire Locontrol, // Entrada de controle para selecionar entre multiplicador e divisor
              output wire [31:0] muxLoOut); // Saída de 32 bits para o resultado do multiplexador Lo
  
  assign muxLoOut = (Locontrol == 1'b0) ? multLo : divLo; // Atribui o valor do multiplicador ou divisor à saída baseado no controle
  
endmodule