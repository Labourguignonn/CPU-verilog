
module sign_extend_LT(input wire immediate,
                     output wire [31:0] extend);
  // Este módulo realiza a extensão de sinal de um valor imediato.
  // O valor imediato é estendido para 32 bits, mantendo o bit de sinal.
  assign extend = {{31{1'b0}}, immediate};
endmodule