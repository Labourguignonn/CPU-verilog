module SS(input clk, 
          input reset,
          input wire [1:0] storeSel, // Seleção de armazenamento
          input wire [31:0] bOut, // Saída b
          input wire [31:0] mdrOut, // Saída mdr
          output wire [31:0] ssOut); // Saída ss

  assign ssOut = (storeSel == 2'b00) ?  {mdrOut[31:8], bOut[7:0]} : // Se storeSel for 00, ssOut recebe os bits 31 a 8 de mdrOut e os bits 7 a 0 de bOut
    (storeSel == 2'b01) ? {mdrOut[31:16], bOut[15:0]} : // Se storeSel for 01, ssOut recebe os bits 31 a 16 de mdrOut e os bits 15 a 0 de bOut
    bOut; // Caso contrário, ssOut recebe bOut

endmodule