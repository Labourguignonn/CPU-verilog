module mux_address(input wire [31:0] PCOut, //00
              input wire [31:0] tft, //01
              input wire [31:0] tff, //10
              input wire [31:0] tfs, //11
              input wire [31:0] ALU_Out
              input wire [2:0] addressControl,
              output wire [31:0] addressOut);
  
  assign adressOut = (addressControl == 2'b000) ? PCOut :
    (addressControl == 2'b001) ? tft :
    (addressControl == 2'b010) ? tff :
    (addressControl == 2'b011) ? tfs :
    (addressControl == 2'b100) ? ALU_Out:
    reset; 
  
  
endmodule