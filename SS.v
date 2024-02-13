module SS(input clk, 
          input reset,
          input wire [1:0] storeSel,
          input wire [31:0] bOut,
          input wire [31:0] mdrOut,
          output wire [31:0] ssOut);

  assign ssOut = (storeSel == 2'b00) ?  {mdrOut[31:8], bOut[7:0]} :
    (storeSel == 2'b01) ? {mdrOut[31:16], bOut[15:0]} :
    bOut;

endmodule