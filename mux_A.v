module mux_A(input wire [31:0] memOut,
              input wire [31:0] rdataone,
              input wire muxAControl,
              output wire [31:0] muxAOut);
//portas de entrada e saída.

  assign muxAOut = (muxAControl == 1'b0) ? memOut : rdataone;
// Esta linha atribui o valor de muxAOut com base no valor de muxAControl.
// Se muxAControl for 1'b0, muxAOut recebe o valor de memOut.
// Caso contrário, muxAOut recebe o valor de rdataone.

endmodule

