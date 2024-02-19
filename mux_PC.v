module mux_pc( 
    input wire [31:0] EPCOut,  // Entrada do registrador EPCOut de 32 bits
    input wire [31:0] zero,  // Entrada do registrador zero de 32 bits
    input wire [31:0] ALUOut,  // Entrada do registrador ALUOut de 32 bits
    input wire [31:0] concatOut,  // Entrada do registrador concatOut de 32 bits
    input wire [31:0] ALUresult,  // Entrada do registrador ALUresult de 32 bits
    input wire [2:0] muxPCcontrol,  // Entrada do controle de seleção do multiplexador de 3 bits
    output wire [31:0] muxPCOut  // Saída do multiplexador de 32 bits
);

 
    assign muxPCOut = (muxPCcontrol == 3'b000) ? EPCOut :  // Se o controle for igual a 000, a saída será EPCOut
     (muxPCcontrol == 3'b001) ? zero :  // Se o controle for igual a 001, a saída será zero
     (muxPCcontrol == 3'b010) ? ALUOut :  // Se o controle for igual a 010, a saída será ALUOut
     (muxPCcontrol == 3'b011) ? concatOut :  // Se o controle for igual a 011, a saída será concatOut
     ALUresult;  // Caso contrário, a saída será ALUresult

endmodule
