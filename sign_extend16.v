
module sign_extend16(input wire [15:0] immediate,
                     output wire [31:0] extend);

  assign extend = (immediate[15]) ? {{16{1'b1}}, immediate} : {16'b0, immediate};
  
  
endmodule
