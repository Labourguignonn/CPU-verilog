module concat(
    input wire [31:0] PCOut,
    output wire [28:0] concOut;
    );

    //procurar saber o que é SOut

    assign concOut = {PCOut[31:28], SOut};
    
endmodule
