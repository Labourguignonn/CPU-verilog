//VER SE ESTAR TRATANDO A EXCEÇÃO CORRETAMENTE! 

module LS(input wire [1:0] loadSel,
          input wire [31:0] mdrOut,
          input wire [1:0] exceptionControl,
          output wire [31:0] lsOutD,
          output wire [15:0] lsOutEx);

    assign lsOutD = (loadSel == 2'b00) ?  {24{'0'}, mdrOut[7:0]} :
        (loadSel == 2'b01) ? {16{'0'}, mdrOut[15:0]} :
        mdrOut;

    assign lsOutEx = (exceptionControl != 2'b00) ? {8{'0'}, mdrOut[31:24]}; 


endmodule