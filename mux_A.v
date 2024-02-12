module mux_A(input wire [31:0] memOut,
              input wire [31:0] rdataone,
              input wire muxAControl,
              output wire [31:0] aOut);
  
  assign aOut = (muxAControl == 1'b0) ? memOut : rdataone;
  
  
endmodule