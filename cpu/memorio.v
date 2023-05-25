`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/24 17:41:11
// Design Name: 
// Module Name: memorio
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


module memorio( mRead, ioRead,m_rdata, io_rdata,  r_wdata);
input mRead; // read memory, from Controller

input ioRead; // read IO, from Controller


input[31:0] m_rdata; // data read from Data-Memory
input[15:0] io_rdata; // data read from IO,16 bits
output reg[31:0]  r_wdata; // data to Decoder(register file)




// The data wirte to register file may be from memory or io. // While the data is from io, it should be the lower 16bit of r_wdata. 
always @* begin

if( ioRead)
r_wdata ={16'b0,io_rdata};
else if(mRead)
r_wdata=m_rdata;
// Chip select signal of Led and Switch are all active high;
end
endmodule

