module mux_memwrite(input wire [31:0] StoresizeOut, //0 - Entrada de dados de tamanho de armazenamento
              input wire [31:0] BOut, //1 - Entrada de dados B
              input wire memwritecontrol, // Controle de escrita em memória
              output wire [31:0] memwriteOut); // Saída de dados de escrita em memória
  
  assign memwriteOut = (memwritecontrol == 1'b0) ? StoresizeOut : BOut; // Atribui a saída de dados de escrita em memória com base no controle de escrita em memória
  
endmodule