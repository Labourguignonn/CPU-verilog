module mux_reg(
    input wire [4:0] twentotwen, 
    input wire [4:0] twentosix, 
    input wire [4:0] dec29, //MUDAR PRA 4 BITS SE NAO DER CERTO
    input wire [4:0] dec31,
    input wire [15:0] fiftozero, //VERIFICAR O TAMANHO SE N DER CERTO
    input wire [2:0] RegControl,
    output wire [4:0] muxRegOut
);

    assign muxRegOut = (RegControl == 3'b000) ? twentotwen :
    (RegControl == 3'b001) ? twentosix :
    (RegControl == 3'b010) ? dec29 :
    (RegControl == 3'b011) ? dec31 :
    (RegControl == 3'b100) ? fiftozero :
    reset; 

endmodule