module concat(
    input wire [31:0] PCOut, // Declaração de entrada PCOut de 32 bits
    input wire [27:0] sl26to28, // Declaração de entrada sl26to28 de 28 bits
    output wire [28:0] concatOut); // Declaração de saída concatOut de 29 bits

    assign concatOut = {PCOut[31:28], sl26to28}; // Concatena os bits mais significativos de PCOut com sl26to28 e atribui a concatOut
    
endmodule
