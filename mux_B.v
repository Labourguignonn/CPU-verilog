
module mux_B(input wire [31:0] memOut,
              input wire [31:0] rdatatwo,
              input wire muxBControl,
              output wire [31:0] bOut);
  
  assign bOut = (muxBControl == 1'b0) ? memOut : rdatatwo;
  
  
endmodule