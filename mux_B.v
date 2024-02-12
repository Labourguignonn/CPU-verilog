
module mux_B(input wire [31:0] memOut,
              input wire [31:0] rdatatwo,
              input wire bControl,
              output wire [31:0] bOut);
  
  assign bOut = (bControl == 1'b0) ? memOut : rdatatwo;
  
  
endmodule