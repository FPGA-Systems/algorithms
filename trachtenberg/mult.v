`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2023 07:33:36 PM
// Design Name: 
// Module Name: mult
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mult(
    input [4:0] ia,
    input [4:0] ib,
    input iclk,
    output [9:0] ores,
    output ovalid,
    input istart,
    output oready
    );
    reg [4 : 0] a;
    reg [4 : 0] b;
    
    reg [9 : 0] ans;
    
    reg valid;
    reg ready;
   
   
    always@(posedge iclk) begin
        if (istart) begin
            a <= ia;
            b <= ib;
            
            ready <= 0;
        end
        
        if (valid) begin
            ready <= 1;
        end
        
        valid <= istart;
        
        ans <= a * b;
    end
    
    assign ovalid = valid;
    assign oready = ready;
    assign ores = ans;
    
endmodule
