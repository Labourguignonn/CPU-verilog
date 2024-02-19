module mux_ALU1(
    input wire [31:0] PCOut, 
    input wire [31:0] AOut, 
    input wire [31:0] zero,
    input wire [31:0] auxOut,
    input wire [1:0] ALU1control,
    output wire [31:0] ALU1Out
);
// Esta linha define um módulo chamado "mux_ALU1" com portas de entrada e saída.

    assign ALU1Out = (ALU1control == 2'b00) ? PCOut :
    (ALU1control == 2'b01) ? AOut :
    (ALU1control == 2'b10) ? zero :
    auxOut; 
// Esta linha atribui o valor de ALU1Out com base no valor de ALU1control.
// Se ALU1control for 2'b00, ALU1Out recebe o valor de PCOut.
// Se ALU1control for 2'b01, ALU1Out recebe o valor de AOut.
// Se ALU1control for 2'b10, ALU1Out recebe o valor de zero.
// Caso contrário, ALU1Out recebe o valor de auxOut.

endmodule

