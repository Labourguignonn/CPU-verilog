// O QUE FICA DEPOIS DO SIGN EXTEND

module shift_left2(
    input wire [31:0] ex, // extend
    output wire [31:0] shiftLeftOut
);
    // Módulo que realiza um deslocamento à esquerda de 2 bits no sinal de entrada "ex".
    // O resultado é atribuído à saída "shiftLeftOut".

    assign shiftLeftOut = ex << 2; 
    // Atribui à saída "shiftLeftOut" o valor do sinal de entrada "ex" deslocado à esquerda de 2 bits.
endmodule
