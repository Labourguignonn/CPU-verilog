module mux_shiftIn(
      input wire [31:0] AOut, // Entrada AOut de 32 bits
      input wire [31:0] BOut, // Entrada BOut de 32 bits
      input wire [31:0] mdrOut, // Entrada mdrOut de 32 bits
      input wire [1:0] shiftincontrol, // Entrada shiftincontrol de 2 bits
      output wire [31:0] shiftInOut // Saída shiftInOut de 32 bits
);
      
      assign shiftInOut = (shiftincontrol == 2'b00) ? AOut : // Se shiftincontrol for 2'b00, shiftInOut recebe AOut
             (shiftincontrol == 2'b01) ? BOut : // Se shiftincontrol for 2'b01, shiftInOut recebe BOut
                  mdrOut; // Caso contrário, shiftInOut recebe mdrOut
      
endmodule