//ANALISAR 
module sign_extend16(input wire [15:0] immediate,
                     output wire [31:0] extend);
  
  assign extend = (immediate[15] == 0) ? {16'b0000000000000000, immediate} :
  {16'b1111111111111111, immediate};
  
  
endmodule