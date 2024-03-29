`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/17 18:08:22
// Design Name: 
// Module Name: ifet
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


module Ifetc32(Instruction, branch_base_addr, link_addr, clock, reset, Addr_result,Read_data_1, Branch, nBranch, Jmp, Jal, Jr, Zero);
output[31:0] Instruction; // the instruction fetched from this module to Decoder and Controller
output  [31:0] branch_base_addr; // (pc+4) to ALU which is used by branch type instruction
output reg [31:0] link_addr; // (pc+4) to Decoder which is used by jal instruction
//from CPU TOP
input clock, reset; // Clock and reset
// from ALU
input[31:0] Addr_result; // the calculated address from ALU

input Zero; // while Zero is 1, it means the ALUresult is zero
// from Decoder
input[31:0] Read_data_1; // the address of instruction used by jr instruction

// from Controller
input Branch; // while Branch is 1,it means current instruction is beq
input nBranch; // while nBranch is 1,it means current instruction is bnq
input Jmp; // while Jmp 1, it means current instruction is jump
input Jal; // while Jal is 1, it means current instruction is jal
input Jr; // while Jr is 1, it means current instruction is j


reg[31:0] PC, Next_PC;
always @* begin
if(((Branch == 1) && (Zero == 1 )) || ((nBranch == 1) && (Zero == 0))) // beq, bne
begin
Next_PC = Addr_result; // the calculated new value for PC

end
else if(Jr == 1)
Next_PC = Read_data_1; // the value of $31 register
else Next_PC = PC+4; // PC+4
end
always @(negedge clock) begin
if(reset == 1)
PC <= 32'h0000_0000;
else begin
if((Jmp == 1) || (Jal == 1)) begin
PC <= {Next_PC[31:28],Instruction[25:0],2'b00}   ;
link_addr<=PC+4;
end
else PC <= Next_PC;
end
end
assign branch_base_addr=PC+4;



rom instmem(
.clka(clock),
.addra(PC[15:2]),
.douta(Instruction)
);
endmodule
