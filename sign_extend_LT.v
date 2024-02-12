
module sign_extend_LT(input wire immediate,
                     output wire [31:0] extend);
  
  assign extend = {31{'0'}, immediate};
  
  
endmodule