
module sign_extend_LT(input wire immediate,
                     output wire [31:0] extend);
  // ver qual o erro 
assign extend = {{31{1'b0}}, immediate};
  
  
endmodule