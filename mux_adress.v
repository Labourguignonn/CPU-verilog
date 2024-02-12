module mux_adress(input wire [31:0] PCOut, //00
              input wire [31:0] tft, //01
              input wire [31:0] tff, //10
              input wire [31:0] tfs, //11
              input wire [1:0] adresscontrol,
              output wire [31:0] adressOut);
  
  assign adressOut = (adresscontrol == 2'b00) ? PCOut :
    (adresscontrol == 2'b01) ? tft :
    (adresscontrol == 2'b10) ? tff :
    (adresscontrol == 2'b11) ? tfs :
    reset; 
  
  
endmodule