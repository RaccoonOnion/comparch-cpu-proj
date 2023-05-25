`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 16:16:02
// Design Name: 
// Module Name: executs32
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

// Note: The design of this part aligns with lab10
module executs32(clock,Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,
                 Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,PC_plus_4
                 );
    // From Decoder
    input clock;
    input[31:0]  Read_data_1;		// �����뵥Ԫ��Read_data_1����
    input[31:0]  Read_data_2;		// �����뵥Ԫ��Read_data_2����
    input[31:0]  Sign_extend;		// �����뵥Ԫ������չ���������
    // From IFetch
    input[5:0]   Function_opcode;  	// ȡָ��Ԫ����r-����ָ�����,r-form instructions[5:0]
    input[5:0]   Exe_opcode;  		// ȡָ��Ԫ���Ĳ�����
    input[31:0]  PC_plus_4;         // ����ȡָ��Ԫ��PC+4
    input[4:0]   Shamt;             // ����ȡָ��Ԫ��instruction[10:6]��ָ����λ����
    // From Controller
    input[1:0]   ALUOp;             // ���Կ��Ƶ�Ԫ������ָ����Ʊ���
    input  		 Sftmd;            // ���Կ��Ƶ�Ԫ�ģ���������λָ��
    input        ALUSrc;            // ���Կ��Ƶ�Ԫ�������ڶ�������������������beq��bne���⣩
    input        I_format;          // ���Կ��Ƶ�Ԫ�������ǳ�beq, bne, LW, SW֮���I-����ָ��
    input        Jr;               // ���Կ��Ƶ�Ԫ��������JRָ��
    // Output
    output    Zero;              // Ϊ1��������ֵΪ0 
    output reg [31:0] ALU_Result;        // ��������ݽ��
    output[31:0] Addr_Result;		// ����ĵ�ַ���        

    reg[31:0] Ainput,Binput; // two operands for calculation
  wire[5:0]  Exe_code; // use to generate ALU_ctrl. (I_format==0) ? Function_opcode : { 3'b000 , Opcode[2:0] };
    wire[2:0] ALU_ctl; // the control signals which affact operation in ALU directely
    wire[2:0] Sftm; // identify the types of shift instruction, equals to Function_opcode[2:0]
    reg[31:0] Shift_Result; // the result of shift operation
    reg[31:0] ALU_output_mux; // the result of arithmetic or logic calculation
    wire[31:0] Branch_Addr; // the calculated address of the instruction, Addr_Result is Branch_Addr[31:0]

    // OK
    // Part One: Selection on Operand 2
    // from Controller, 1 means the Binput is an extended immediate, otherwise the Binput is Read_data_2
   always@(*)begin Ainput = Read_data_1;
    Binput = (ALUSrc == 0) ? Read_data_2 : Sign_extend[31:0];
       
    
    end
     assign Exe_code = (I_format==0) ? Function_opcode :{ 3'b000 , Exe_opcode[2:0] };
    
    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];
    // OK
    // Part two: ALU control generation

    
    // 
    // Part three: Calculation: ALU_output_mux
    // Note some instructions need to be identified: shift, lui, *(jr, j, jal)
    always @ (*)
    begin
    case(ALU_ctl)
    3'b000:ALU_output_mux = Ainput & Binput;
    3'b001:ALU_output_mux = Ainput | Binput;
    3'b010:ALU_output_mux = $signed(Ainput) + $signed(Binput); // for lw and sw, we calculate addr below
    3'b011:ALU_output_mux = Ainput + Binput; // Note!! addu/addiu overflow detection TODO
    3'b100:ALU_output_mux = Ainput ^ Binput;
    3'b101:ALU_output_mux = (I_format) ? Ainput | Binput : ~(Ainput | Binput);// TODO: refine for lui
    3'b110:ALU_output_mux =  $signed(Ainput) - $signed( Binput); // for beq,bne, addr below
    3'b111:ALU_output_mux = Ainput - Binput;
//    case(Exe_code[3:0])
//        4'b0011: ALU_output_mux = (I_format) ? Ainput < Binput : Ainput - Binput; // TODO:check unsigned
//        4'b1010, 4'b1011: ALU_output_mux = Ainput < Binput;
//    endcase
    default:ALU_output_mux = 32'h0;
    endcase
    end
    
    // Part four: Shift Operation
    assign Sftm = Function_opcode[2:0]; //the code of shift operations    
    
    always @(*) 
    begin // six types of shift instructions
    if(Sftmd)
    case(Sftm[2:0])
    3'b000:Shift_Result = Binput << Shamt; //Sll rd,rt,shamt 00000
    3'b010:Shift_Result = Binput >> Shamt; //Srl rd,rt,shamt 00010
    3'b100:Shift_Result = Binput << Ainput; //Sllv rd,rt,rs 00100
    3'b110:Shift_Result = Binput >> Ainput; //Srlv rd,rt,rs 00110 TODO: check
    3'b011:Shift_Result = $signed(Binput) >>> Shamt; //Sra rd,rt,shamt 00011
    3'b111:Shift_Result = $signed(Binput) >>> Ainput; //Srav rd,rt,rs 00111
    default:Shift_Result = Binput;
    endcase
    else
    Shift_Result = Binput;
    end
    
    // Part five: Assigning ALU_result
// Declare an internal variable to perform the computation.
   
    
    always @(*) begin
    //set type operation (slt, slti)
        if( ((ALU_ctl == 3'b111) && (Exe_code[3:0] == 4'b1010))  || ((ALU_ctl == 3'b110) && (ALUOp[1] == 1'b1) && (I_format)) )
            ALU_Result = (($signed(Ainput) < $signed(Binput)) ? 1: 0);
        //set type operation (sltu, sltiu)
        else if( ((ALU_ctl == 3'b111) && (Exe_code[3:0] == 4'b1011))  || ((ALU_ctl == 3'b111) && (Exe_code[3:0] == 4'b0011) && (I_format)) )
            ALU_Result = ((Ainput < Binput) ? 1: 0);
        //lui operation
        else if((ALU_ctl == 3'b101) && (I_format == 1'b1))
            ALU_Result[31:0] = {Binput[15:0],16'b0} ;
        //shift operation
        else if(Sftmd == 1'b1)
            ALU_Result = Shift_Result;
        //other types of operation in ALU (arithmatic or logic calculation)
        else
            ALU_Result = ALU_output_mux;
    end
    
    // Then, assign the output to the computed value.
  //  assign ALU_Result = ALU_Result_internal;

    
    // Part six: Addr_result and Zero TODO
// Declare internal variables for Addr_Result and Zero.
   // wire [31:0] branch_addr;  // Branch address calculation
    assign Addr_Result = PC_plus_4 + (Sign_extend << 2);
    
   // reg Zero_internal;  // Zero flag
   assign Zero=(ALU_output_mux==32'b0)?1'b1:1'b0;
    


    
    
endmodule