module concat(
    input wire [31:0] PCOut,
    input wire [27:0] sl26to28,
    output wire [28:0] concatOut;
    );

    assign concatOut = {PCOut[31:28], sl26to28};
    
endmodule
