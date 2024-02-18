
module sign_extend16(input wire [15:0] immediate,
                     output wire [31:0] extend);

  assign extend = {{16{immediate[15]}}, immediate};
  
  
endmodule
