
module mux_LO(input wire [31:0] multLo,
              input wire [31:0] divLo,
              input wire control,
              output wire [31:0] muxLoOut);
  
  assign muxLoOut = (control == 1'b0) ? multLo : divLo;
  
  
endmodule