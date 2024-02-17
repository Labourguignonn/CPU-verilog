module mux_address(input wire [31:0] PCOut, //00
              input wire [31:0] tft, //01
              input wire [31:0] tff, //10
              input wire [31:0] tfs, //11
              input wire [31:0] ALU_Out,
              input wire [2:0] addressControl,
              output wire [31:0] addressOut
);

    assign addressOut = (addressControl == 3'b000) ? PCOut :
    (addressControl == 3'b001) ? tft :
    (addressControl == 3'b010) ? tff :
    (addressControl == 3'b011) ? tfs :
    ALU_Out;


endmodule