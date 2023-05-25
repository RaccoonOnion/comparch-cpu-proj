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
    input[31:0]  Read_data_1;		// 从译码单元的Read_data_1中来
    input[31:0]  Read_data_2;		// 从译码单元的Read_data_2中来
    input[31:0]  Sign_extend;		// 从译码单元来的扩展后的立即数
    // From IFetch
    input[5:0]   Function_opcode;  	// 取指单元来的r-类型指令功能码,r-form instructions[5:0]
    input[5:0]   Exe_opcode;  		// 取指单元来的操作码
    input[31:0]  PC_plus_4;         // 来自取指单元的PC+4
    input[4:0]   Shamt;             // 来自取指单元的instruction[10:6]，指定移位次数
    // From Controller
    input[1:0]   ALUOp;             // 来自控制单元的运算指令控制编码
    input  		 Sftmd;            // 来自控制单元的，表明是移位指令
    input        ALUSrc;            // 来自控制单元，表明第二个操作数是立即数（beq，bne除外）
    input        I_format;          // 来自控制单元，表明是除beq, bne, LW, SW之外的I-类型指令
    input        Jr;               // 来自控制单元，表明是JR指令
    // Output
    output    Zero;              // 为1表明计算值为0 
    output reg [31:0] ALU_Result;        // 计算的数据结果
    output[31:0] Addr_Result;		// 计算的地址结果        

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