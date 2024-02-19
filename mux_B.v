module mux_B(input wire [31:0] rdatatwo, 
              input wire [31:0] memOut, 
              input wire muxBControl, 
              output wire [31:0] muxBOut);
  
  // Atribui o valor de "rdatatwo" a "muxBOut" se "muxBControl" for 1'b0, caso contrário atribui o valor de "memOut" a "muxBOut"
  assign muxBOut = (muxBControl == 1'b0) ? rdatatwo : memOut;
  
endmodule