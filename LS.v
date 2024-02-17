//VER SE ESTAR TRATANDO A EXCEÇÃO CORRETAMENTE! 

module LS(inout wire clk, 
          input wire reset,
          input wire [1:0] loadSel,
          input wire [31:0] mdrOut,
          input wire [1:0] exceptionControl,
          output wire [31:0] lsOutD,
          output wire [15:0] lsOutEx);

    assign lsOutD = (loadSel == 2'b00) ?  {24'b1, mdrOut[7:0]} :
        (loadSel == 2'b01) ? {16'b1, mdrOut[15:0]} :
        mdrOut;

    assign lsOutEx = (exceptionControl != 2'b00) ? {8'b0, mdrOut[31:24]} :
    5'b0;
    //linha 16 colocada apenas para parar de dar erro


endmodule