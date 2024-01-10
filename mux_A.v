
module mux_A(input wire [31:0] memOut,
              input wire [31:0] rdataone,
              input wire Acontrol,
              output wire [31:0] AOut);
  
  assign AOut = (Acontrol == 1'b0) ? memOut : rdataone;
  
  
endmodule