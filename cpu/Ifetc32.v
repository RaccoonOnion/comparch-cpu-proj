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


module Ifetc32(Instruction, branch_base_addr, link_addr, clock, reset, Addr_result,Read_data_1, Branch, nBranch, Jmp, Jal, Jr, Zero,rs,rt,rd);
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
output reg [4:0] rs;
output reg [4:0] rt;
output reg [4:0] rd;
always@(negedge clock)
begin
 rs<=Instruction[25:21];
    rt<=Instruction[20:16];
    rd<=Instruction[15:11];
   end

reg[31:0] PC, Next_PC;
always @(*) begin
if(((Branch) && (Zero )) || ((nBranch ) && (!Zero))) // beq, bne
begin
Next_PC = Addr_result; // the calculated new value for PC

end

else if(Jr )

Next_PC = Read_data_1; // the value of $31 register

else Next_PC = PC+4; // PC+4

end

always @(negedge clock,posedge reset) begin
if(reset)
    PC <= 32'h0000_0000;
else begin
    if((Jmp) || (Jal )) begin
        PC <= {4'b0,Instruction[25:0],2'b00}   ;
        link_addr<=PC+4;
    end
else PC <= Next_PC;
end
end
assign branch_base_addr=PC+4;



romm instmem(
.clka(clock),
.addra(PC[15:2]),
.douta(Instruction)
);
endmodule
