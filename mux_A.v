module mux_A(input wire [31:0] memOut,
              input wire [31:0] rdataone,
              input wire aControl,
              output wire [31:0] aOut);
  
  assign aOut = (aControl == 1'b0) ? memOut : rdataone;
  
  
endmodule