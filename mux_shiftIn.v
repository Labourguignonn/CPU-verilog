module mux_shiftIn(input wire [31:0] AOut,
              input wire [31:0] BOut,
              input wire [31:0] mdrOut,
              input wire [1:0] shiftincontrol,
              output wire [31:0] shiftInOut);
  
  assign shiftInOut = (shiftincontrol == 2'b00) ? AOut :
     (shiftincontrol == 2'b01) ? BOut :
      mdrOut;
  
  
endmodule