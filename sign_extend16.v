//ANALISAR (OK)
module sign_extend16(input wire [15:0] immediate,
                     output wire [31:0] extend);
  //ver qual o erro 
  assign extend = {{16{1'b0}}, immediate};
  
  
endmodule