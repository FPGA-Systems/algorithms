`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2023 06:52:31 PM
// Design Name: 
// Module Name: tb
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


module tb();
    
    reg [4:0] ia, ib;
    wire [9 : 0] ores, ores_2;
    reg iclk, istart;
    wire oready, ovalid, oready_2, ovalid_2;
    
    //tb
    reg [9:0] tb_res0, tb_res;
    
    
    initial begin
        iclk = 0;
        ia = 0;
        ib = 0;
        istart = 0;
    end
    
    always 
        #5 iclk = !iclk;
    
    integer i, j;
    
    always begin
        for (i = 0; i < 2**5; i = i + 1) begin
            for (j = 0; j < 2**5; j = j + 1) begin
                ia = i;
                ib = j;
                istart = 1;
                #10
                istart = 0;
                wait (ovalid);
                #10;
            end
        end
        
        #200;
        $finish;
    end
    
    //check
    always @(posedge iclk)
    begin
        tb_res0 <= ia * ib;
        tb_res <= tb_res0;
    end
    
    always @(negedge iclk) 
    begin
        
            if (tb_res != ores) begin
                $display ("Error ia = %d; ib = %d", ia, ib);
            end
            
            if (ores_2 != ores) begin
                $display ("Error M ia = %d; ib = %d", ia, ib);
            end
        
    end
    
    trachtenberg_logic dut (
        .ia(ia),
        .ib(ib),
        .iclk(iclk),
        .istart(istart),
        .oready(oready),
        .ovalid(ovalid),
        .ores(ores)
    );
    
    mult dut_2 (
        .ia(ia),
        .ib(ib),
        .iclk(iclk),
        .istart(istart),
        .oready(oready_2),
        .ovalid(ovalid_2),
        .ores(ores_2)
    );
endmodule
