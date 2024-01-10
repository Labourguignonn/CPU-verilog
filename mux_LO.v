
module mux_LO(input wire [31:0] multLo,
              input wire [31:0] divLo,
              input wire Locontrol,
              output wire [31:0] muxLoOut);
  
  assign muxLoOut = (Locontrol == 1'b0) ? multLo : divLo;
  
  
endmodule