module mux_data(
    input wire [31:0] twotwensev, // Entrada de dados 1: valor 227
    input wire [31:0] loadOutUp,  // Entrada de dados 2: valor loadOutUp
    input wire [31:0] ALUOut,     // Entrada de dados 3: valor ALUOut
    input wire [31:0] shiftleft,  // Entrada de dados 4: valor shiftleft
    input wire [31:0] HIout,      // Entrada de dados 5: valor HIout
    input wire [31:0] LOout,      // Entrada de dados 6: valor LOout
    input wire [31:0] shiftregout,// Entrada de dados 7: valor shiftregout
    input wire [31:0] LTout,      // Entrada de dados 8: valor LTout
    input wire [2:0] dataControl, // Seleção de controle de dados
    output wire [31:0] muxdataOut // Saída do multiplexador de dados
);

        // Atribuição condicional para selecionar a saída do multiplexador de dados
        assign muxdataOut = (dataControl == 3'b000) ? twotwensev : // Se dataControl for igual a 000, seleciona twotwensev como saída
        (dataControl == 3'b001) ? loadOutUp : // Se dataControl for igual a 001, seleciona loadOutUp como saída
        (dataControl == 3'b010) ? ALUOut : // Se dataControl for igual a 010, seleciona ALUOut como saída
        (dataControl == 3'b011) ? shiftleft : // Se dataControl for igual a 011, seleciona shiftleft como saída
        (dataControl == 3'b100) ? HIout : // Se dataControl for igual a 100, seleciona HIout como saída
        (dataControl == 3'b101) ? LOout : // Se dataControl for igual a 101, seleciona LOout como saída
        (dataControl == 3'b110) ? shiftregout : // Se dataControl for igual a 110, seleciona shiftregout como saída
        LTout; // Caso contrário, seleciona LTout como saída

    endmodule
