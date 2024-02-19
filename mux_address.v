module mux_address(
    input wire [31:0] PCOut, // 01 Entrada do registrador PCOut
    input wire [31:0] tft, // 10 Entrada do registrador tft
    input wire [31:0] tff, // 11 Entrada do registrador tff
    input wire [31:0] tfs, // Entrada do registrador tfs
    input wire [31:0] ALU_Out, // Entrada do resultado da ALU
    input wire [2:0] addressControl, // Entrada de controle do endereço
    output wire [31:0] addressOut // Saída do endereço
);

    assign addressOut = (addressControl == 3'b000) ? PCOut : // Se addressControl for igual a 000, atribui PCOut a addressOut
                        (addressControl == 3'b001) ? tft : // Se addressControl for igual a 001, atribui tft a addressOut
                        (addressControl == 3'b010) ? tff : // Se addressControl for igual a 010, atribui tff a addressOut
                        (addressControl == 3'b011) ? tfs : // Se addressControl for igual a 011, atribui tfs a addressOut
                        ALU_Out; // Caso contrário, atribui ALU_Out a addressOut

endmodule