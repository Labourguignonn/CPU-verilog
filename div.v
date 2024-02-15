module div(  
    input wire clk,  
    input wire reset,  
    input wire divControl,  
    input wire [31:0] aInput,
    input wire [31:0] bInput,
    output wire [31:0] HI,  // Quocient
    output wire [31:0] LO,  // Rest
    output wire err,         // Divison by zero
    output wire ok         // = 1 when ready to get the result   
);  

    reg active;          // True if the divider is running  
    reg [4:0] cycle;     // Number of cycles to go. May be [5:0]
    reg [31:0] result;   // Begin with aInput, end with HI
    reg [31:0] divisor;  // bInput 
    reg [31:0] mod;     // Running modulo (rest)

    // Calculate the current digit
    wire [32:0] sub = {mod[30:0], result[31]} - divisor;  
    assign err = !BOut;
    // Send the results to our master  
    assign HI = result;
    assign LO = mod;
    assign ok = ~active;
  
   // The state machine  
    always @(posedge clk,posedge reset) begin  
        if (reset) begin  
            active <= 0;  
            cycle <= 0;  
            result <= 0;  
            divisor <= 0;  
            mod <= 0;  
        end
        else if(divControl) begin  
            if (active) begin  
                // Run an iteration of the divider.  
                if (sub[32] == 0) begin  
                    mod <= sub[31:0];  
                    result <= {result[30:0], 1'b1};  
                end  
                else begin
                    mod <= {mod[30:0], result[31]};
                    result <= {result[30:0], 1'b0};  
                end  
                if (cycle == 0) begin  
                    active <= 0;  
                end  
                cycle <= cycle - 5'd1;  
            end
            else begin  
                cycle <= 5'd31;     
                result <= aInput;  
                divisor <= bInput;  
                mod <= 32'b0;  
                active <= 1;
            end
        end
    end
endmodule 