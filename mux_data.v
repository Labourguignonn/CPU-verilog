module mux_data(
    input wire [31:0] twotwensev, // 227
    input wire [31:0] loadOutUp,  
    input wire [31:0] ALUOut, 
    input wire [31:0] shiftleft, // embaixo do mdr
    input wire [31:0] HIout, 
    input wire [31:0] LOout, 
    input wire [31:0] shiftregout,
    input wire [31:0] LTout,
    input wire [2:0] dataControl,
    output wire [31:0] muxdataOut
);

    assign muxdataOut = (dataControl == 3'b000) ? twotwensev :
    (dataControl == 3'b001) ? loadOutUp :
    (dataControl == 3'b010) ? ALUOut :
    (dataControl == 3'b011) ? shiftleft :
    (dataControl == 3'b100) ? HIout :
    (dataControl == 3'b101) ? LOout :
    (dataControl == 3'b110) ? shiftregout :
    (dataControl == 3'b111) ? LTout :
    reset; 

endmodule