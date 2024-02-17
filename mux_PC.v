module mux_pc( 
    input wire [31:0] EPCOut, 
    input wire [31:0] zero, 
    input wire [31:0] ALUOut, 
    input wire [31:0] concatOut, 
    input wire [31:0] ALUresult,
    input wire [2:0] muxPCcontrol,
    output wire [31:0] muxPCOut
);

 
    assign muxPCOut = (muxPCcontrol == 3'b000) ? EPCOut :
     (muxPCcontrol == 3'b001) ? zero :
     (muxPCcontrol == 3'b010) ? ALUOut :
     (muxPCcontrol == 3'b011) ? concatOut :
     ALUresult; 

endmodule
