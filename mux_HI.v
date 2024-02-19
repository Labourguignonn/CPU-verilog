module mux_HI(input wire [31:0] multHi, // Entrada de 32 bits para o multiplicador de alta
              input wire [31:0] divHi, // Entrada de 32 bits para o divisor de alta
              input wire Hicontrol, // Entrada de controle Hicontrol
              output wire [31:0] muxHiOut); // Saída de 32 bits para o multiplexador de alta
  
  assign muxHiOut = (Hicontrol == 1'b0) ? multHi : divHi; // Atribui a saída muxHiOut com base no valor de Hicontrol
  
endmodule