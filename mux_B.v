
module mux_B(input wire [31:0] rdatatwo,
              input wire [31:0] memOut,
              input wire muxBControl,
              output wire [31:0] muxBOut);
  
  assign muxBOut = (muxBControl == 1'b0) ? rdatatwo : memOut;
  
  
endmodule