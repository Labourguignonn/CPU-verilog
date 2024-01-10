
module mux_B(input wire [31:0] memOut,
              input wire [31:0] rdatatwo,
              input wire Bcontrol,
              output wire [31:0] BOut);
  
  assign BOut = (Bcontrol == 1'b0) ? memOut : rdatatwo;
  
  
endmodule