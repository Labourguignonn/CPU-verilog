
module mux_memwrite(input wire [31:0] StoresizeOut, //0
              input wire [31:0] BOut, //1
              input wire memwritecontrol,
              output wire [31:0] memwriteOut);
  
  assign memwriteOut = (memwritecontrol == 1'b0) ? StoresizeOut : BOut;
  
  
endmodule