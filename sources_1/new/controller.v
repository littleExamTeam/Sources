`timescale 1ns / 1ps
`include "defines.vh"

module main_dec(
    input wire [5:0] op,funct,
    output wire jump, regwrite, regdst,
    output wire alusrcA,
    output wire [1:0] alusrcB, //这里修改成两位是为了选择操作数，0位扩�???
    output wire branch, memwrite, 
    output wire [1:0] memtoreg,
    output wire HIwrite, //这里是去寻找是否写HILO 直接传给HILO
    output wire LOwrite //选择写的是HI还是LO寄存�? 0 LO 1 HI  信号传给HILO

);

reg [11:0] signals; //添加LOwrite之后变成11�?

//assign {jump, regwrite, regdst, alusrcB[1:0], branch, memwrite, memtoreg} = signals;
assign {regwrite, memtoreg[1:0], memwrite, alusrcA ,{alusrcB[1:1]}, {alusrcB[0:0]}, regdst, jump, branch,HIwrite,LOwrite} = signals;
//100  00
// `define EXE_NOP			6'b000000
// `define EXE_AND 		6'b100100
// `define EXE_OR 			6'b100101
// `define EXE_XOR 		6'b100110
// `define EXE_NOR			6'b100111
// `define EXE_ANDI		6'b001100
// `define EXE_ORI			6'b001101
// `define EXE_XORI		6'b001110
// `define EXE_LUI			6'b001111
always @(*) begin
    case(op)
    //     `EXE_NOP: begin    //R-type
    //     signals <= 8'b011 000;
    //     aluop_reg <= 2'b10;
    // end
        6'b000000: begin    //lw
        case(funct)
            `EXE_SLL:signals <= 12'b1_00_0_1_00_1_0_0_0_0;
            `EXE_SRA:signals <= 12'b1_00_0_1_00_1_0_0_0_0;
            `EXE_SRL:signals <= 12'b1_00_0_1_00_1_0_0_0_0;
            `EXE_MFHI:signals <= 12'b1_10_0_0_00_1_0_0_0_0;
            `EXE_MFLO:signals <= 12'b1_01_0_0_00_1_0_0_0_0;
            `EXE_MTHI:signals <= 12'b0_00_0_0_00_1_0_0_1_0;
            `EXE_MTLO:signals <= 12'b0_00_0_0_00_1_0_0_0_1;
            default: signals <= 12'b1_00_0_0_00_1_0_0_0_0;
            
        endcase
    
    end
        `EXE_ANDI:signals <= 12'b1_00_0_0_10_0_0_0_0_0;
        `EXE_XORI:signals <= 12'b1_00_0_0_10_0_0_0_0_0;
        `EXE_ORI:signals <= 12'b1_00_0_0_10_0_0_0_0_0;
        `EXE_LUI:signals <= 12'b1_00_0_0_10_0_0_0_0_0;
        default:signals <= 12'b0_00_0_0_00_0_0_0_0_0;
    endcase
end

endmodule

module controller(
    input wire [5:0] Op, Funct,
    output wire Jump, RegWrite, RegDst,
    output wire ALUSrcA, 
    output wire [1:0] ALUSrcB, 
    output wire Branch, MemWrite, 
    output wire [1:0]MemtoReg,
    output wire HIwrite,LOwrite,
    output wire [7:0] ALUContr 
);


main_dec main_dec(
    .op(Op),
    .funct(Funct),
    .jump(Jump),
    .regwrite(RegWrite),
    .regdst(RegDst),
    .alusrcA(ALUSrcA),
    .alusrcB(ALUSrcB),
    .branch(Branch),
    .memwrite(MemWrite),
    .memtoreg(MemtoReg),
    .HIwrite(HIwrite),
    .LOwrite(LOwrite)
);

aludec aludec(
    .Funct(Funct),
    .Op(Op),
    .ALUControl(ALUContr)
);

endmodule
