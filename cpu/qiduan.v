`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/26 19:41:31
// Design Name: 
// Module Name: light_7seg_ego1
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



module qiduan(input clk,input reset,input [3:0]sw,output reg [7:0] seg_out);
   
    always @ (posedge clk,posedge reset)
    begin
    if(reset)
    begin seg_out<=8'b1111_1100;
    end
    else
    begin
    
     
        case(sw)
            4'h0: seg_out <= 8'b1111_1100; //0
            4'h1: seg_out <= 8'b0110_0000; //1
            4'h2: seg_out <= 8'b1101_1010; //2
            4'h3: seg_out <= 8'b1111_0010; //3
            4'h4: seg_out <= 8'b0110_0110; //4
            4'h5: seg_out <= 8'b1011_0110; //5
            4'h6: seg_out <= 8'b1011_1110; //6
            4'h7: seg_out <= 8'b1110_0000; //7
            4'h8: seg_out <= 8'b1111_1110; //8
            4'h9: seg_out <= 8'b1110_0110; //9
            default:seg_out<=8'b1111_1100;
            
            
           
        endcase    
        end
        end
        
endmodule
