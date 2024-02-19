/**
 * Módulo responsável por implementar um multiplexador de extensão.
 * O multiplexador seleciona entre dois sinais de entrada, dependendo do valor de exControl.
 * Se exControl for igual a 0, o sinal de saída será loadouthalf.
 * Se exControl for igual a 1, o sinal de saída será fiftozero.
 */
module mux_extend(input wire [15:0] loadouthalf, 
              input wire [15:0] fiftozero, //immediate
              input wire exControl,
              output wire [15:0] muxExtOut);
  
  assign muxExtOut = (exControl == 1'b0) ? loadouthalf : fiftozero;
  
endmodule