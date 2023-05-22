`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/24 18:02:43
// Design Name: 
// Module Name: Decoder
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


module decode32(read_data_1,read_data_2,Instruction,mem_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4);
    output[31:0] read_data_1;               // ����ĵ�һ������
    output[31:0] read_data_2;               // ����ĵڶ�������
    input[31:0]  Instruction;               // ȡָ��Ԫ����ָ��
    input[31:0]  mem_data;   				//  ��DATA RAM or I/O portȡ��������
    input[31:0]  ALU_result;   				// ��ִ�е�Ԫ��������Ľ��
    input        Jal;                       //  ���Կ��Ƶ�Ԫ��˵����JALָ�� 
    input        RegWrite;                  // ���Կ��Ƶ�Ԫ
    input        MemtoReg;              // ���Կ��Ƶ�Ԫ
    input        RegDst;             
    output[31:0] Sign_extend;               // ��չ���32λ������
    input		 clock,reset;                // ʱ�Ӻ͸�λ
    input[31:0]  opcplus4;                 // ����ȡָ��Ԫ��JAL����
    
    reg [31:0] Reg[0:31];  
    wire [4:0] rs = Instruction[25: 21];
    wire [4:0] rt = Instruction[20: 16];
    wire [4:0] rd = Instruction[15: 11];
    
    
    integer i;
//    initial begin
//        for (i = 0; i < 32; i = i+ 1) Reg[i] <= 0;  
//    end
    
    always @(posedge clock) begin
     Reg[0] <= 32'b0;
        if(reset) begin
            for (i = 0; i < 32; i = i+ 1) 
            Reg[i] <= 32'b0;
//            {Reg[0], Reg[1], Reg[2], Reg[3], Reg[4], Reg[5], Reg[6], Reg[7], Reg[8], Reg[9], 
//            Reg[10], Reg[11], Reg[12], Reg[13], Reg[14], 
//            Reg[15], Reg[16], Reg[17], Reg[18], Reg[19],
//             Reg[20], Reg[21], Reg[22], Reg[23], Reg[24], Reg[25], Reg[26],
//              Reg[27], Reg[28], Reg[29], Reg[30], Reg[31]} <= 32*32'h0;
        end
        else if(RegWrite) begin 
          if(Jal)   begin
                      Reg[31] <= opcplus4;
                  end
           else if(MemtoReg) begin
              case(RegDst) 
                1'b0: if(rt!=5'b0)Reg[rt] <= mem_data;  
                1'b1:  if(rd!=5'b0)Reg[rd] <= mem_data; 
              endcase       
            end
            else begin
                 case(RegDst) 
                    1'b0:  if(rt!=5'b0)Reg[rt] <= ALU_result;  
                    1'b1: if(rd!=5'b0) Reg[rd] <= ALU_result; 
                endcase      
            end
         
           
        end
    end
    
   
    assign read_data_1 = Reg[rs];
    assign read_data_2 = Reg[rt];
    assign Sign_extend =  {(Instruction[31:26]!=6'hb&Instruction[31:26]!=6'hc&Instruction[31:26]!=6'hd&Instruction[31:26]!=6'he) ? (Instruction[15] ? 16'hffff : 16'h0000) : 16'h0000,  Instruction[15:0]};
endmodule
