
module mux_HI(input wire [31:0] multHi,
              input wire [31:0] divHi,
              input wire control,
              output wire [31:0] muxHiOut);
  
  assign muxHiOut = (control == 1'b0) ? multHi : divHi;
  
  
endmodule