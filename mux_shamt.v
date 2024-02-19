module mux_shamt(
   input wire [4:0] fiftozero, // Entrada de 5 bits para fiftozero
   input wire [31:0] BOut, // Entrada de 32 bits para BOut
   input wire [4:0] twenfour, // Entrada de 5 bits para twenfour (24)
   input wire [1:0] shamtcontrol, // Entrada de 2 bits para shamtcontrol
   output wire [4:0] shamtOut // Saída de 5 bits para shamtOut
);
   
   assign shamtOut = (shamtcontrol == 2'b00) ? fiftozero : // Se shamtcontrol for 00, atribui fiftozero a shamtOut
       (shamtcontrol == 2'b01) ? BOut[4:0] : // Se shamtcontrol for 01, atribui os bits [4:0] de BOut a shamtOut
       twenfour; // Caso contrário, atribui twenfour a shamtOut
   
endmodule

