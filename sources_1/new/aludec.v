`timescale 1ns / 1ps
`include "defines.vh"
module aludec(
    input wire [5:0] Op,
    input wire [5:0] Funct,
    output reg [7:0] ALUControl
);

always @(*) begin
    case(Op)
        6'b000000: begin
            case(Funct)
                //logic inst
                `EXE_AND: ALUControl <= `EXE_AND_OP;
                `EXE_OR : ALUControl <= `EXE_OR_OP ;
                `EXE_XOR: ALUControl <= `EXE_XOR_OP;
                `EXE_NOR: ALUControl <= `EXE_NOR_OP;
                //shift inst
                `EXE_SLL : ALUControl <= `EXE_SLL_OP ;
                `EXE_SLLV: ALUControl <= `EXE_SLLV_OP;
                `EXE_SRL : ALUControl <= `EXE_SRL_OP ;	
                `EXE_SRLV: ALUControl <= `EXE_SRLV_OP;
                `EXE_SRA : ALUControl <= `EXE_SRA_OP ;
                `EXE_SRAV: ALUControl <= `EXE_SRAV_OP;
                //move inst
                `EXE_MFHI: ALUControl <= `EXE_MFHI_OP;
                `EXE_MTHI: ALUControl <= `EXE_MTHI_OP;
                `EXE_MFLO: ALUControl <= `EXE_MFLO_OP;
                `EXE_MTLO: ALUControl <= `EXE_MTLO_OP;
                //ari inst
                `EXE_SLT  : ALUControl <= `EXE_SLT_OP;
                `EXE_SLTU : ALUControl <= `EXE_SLTU_OP;
                `EXE_ADD  : ALUControl <= `EXE_ADD_OP;
                `EXE_ADDU : ALUControl <= `EXE_ADDU_OP;
                `EXE_SUB  : ALUControl <= `EXE_SUB_OP;
                `EXE_SUBU : ALUControl <= `EXE_SUBU_OP;
                `EXE_MULT : ALUControl <= `EXE_MULT_OP;
                `EXE_MULTU: ALUControl <= `EXE_MULTU_OP;
                `EXE_DIV  : ALUControl <= `EXE_DIV_OP;
                `EXE_DIVU : ALUControl <= `EXE_DIVU_OP;
                //J type
                `EXE_JALR: ALUControl <= `EXE_JALR_OP;
                `EXE_JR  : ALUControl <= `EXE_JR_OP;
                default: ALUControl <= `EXE_NOP_OP;
            endcase
        end
        //logic inst
        `EXE_ANDI : ALUControl <= `EXE_ANDI_OP;
        `EXE_ORI  : ALUControl <= `EXE_ORI_OP;
        `EXE_XORI : ALUControl <= `EXE_XORI_OP;
        `EXE_LUI  : ALUControl <= `EXE_LUI_OP;
        //ari inst
        `EXE_SLTI : ALUControl <= `EXE_SLTI_OP;
        `EXE_SLTIU: ALUControl <= `EXE_SLTIU_OP;
        `EXE_ADDI : ALUControl <= `EXE_ADDI_OP;
        `EXE_ADDIU: ALUControl <= `EXE_ADDIU_OP;
        //J type
        `EXE_J     :ALUControl <= `EXE_J_OP;
        `EXE_JAL   :ALUControl <= `EXE_JAL_OP;
        `EXE_BEQ   :ALUControl <= `EXE_BEQ_OP;
        `EXE_BGEZ  :ALUControl <= `EXE_BGEZ_OP;
        `EXE_BGEZAL:ALUControl <= `EXE_BGEZAL_OP;
        `EXE_BGTZ  :ALUControl <= `EXE_BGTZ_OP;
        `EXE_BLEZ  :ALUControl <= `EXE_BLEZ_OP;
        `EXE_BLTZ  :ALUControl <= `EXE_BLTZ_OP;
        `EXE_BLTZAL:ALUControl <= `EXE_BLTZAL_OP;
        `EXE_BNE   :ALUControl <= `EXE_BNE_OP;
        //mem inst
        `EXE_LB   : ALUControl <= `EXE_LB_OP;
        `EXE_LBU  : ALUControl <= `EXE_LBU_OP;
        `EXE_LH   : ALUControl <= `EXE_LH_OP;
        `EXE_LHU  : ALUControl <= `EXE_LHU_OP;
        `EXE_LW   : ALUControl <= `EXE_LW_OP;
        `EXE_SB   : ALUControl <= `EXE_SB_OP;
        `EXE_SH   : ALUControl <= `EXE_SH_OP;
        `EXE_SW   : ALUControl <= `EXE_SW_OP;
        default: ALUControl <= `EXE_NOP_OP;
    endcase
end

endmodule