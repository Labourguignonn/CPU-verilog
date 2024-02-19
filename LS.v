//VER SE ESTAR TRATANDO A EXCEÇÃO CORRETAMENTE! 


module LS(inout wire clk,  // Declaração de um pino bidirecional chamado "clk"
          input wire reset,  // Declaração de um pino de entrada chamado "reset"
          input wire [1:0] loadSel,  // Declaração de um pino de entrada chamado "loadSel" com 2 bits
          input wire [31:0] mdrOut,  // Declaração de um pino de entrada chamado "mdrOut" com 32 bits
          input wire [1:0] exceptionControl,  // Declaração de um pino de entrada chamado "exceptionControl" com 2 bits
          output wire [31:0] lsOutD,  // Declaração de um pino de saída chamado "lsOutD" com 32 bits
          output wire [15:0] lsOutEx);  // Declaração de um pino de saída chamado "lsOutEx" com 16 bits

    assign lsOutD = (loadSel == 2'b00) ?  {24'b0, mdrOut[7:0]} :  // Atribuição condicional para "lsOutD" baseado no valor de "loadSel"
        (loadSel == 2'b01) ? {16'b0, mdrOut[15:0]} :  // Atribuição condicional para "lsOutD" baseado no valor de "loadSel"
        mdrOut;  // Atribuição direta de "mdrOut" para "lsOutD"

    assign lsOutEx = (exceptionControl != 2'b00) ? {8'b0, mdrOut[31:24]} :  // Atribuição condicional para "lsOutEx" baseado no valor de "exceptionControl"
    5'b0;  // Atribuição direta de 5 bits 0 para "lsOutEx"

    //linha 16 colocada apenas para parar de dar erro

endmodule

