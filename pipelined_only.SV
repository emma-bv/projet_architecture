module ALU (
    input [3:0] ALUOp,
    input [31:0] A,
    input [31:0] B,
    input [31:0] imm,
    output reg [31:0] Result
);

// Codes d'opération
localparam ADD  = 4'b0000;
localparam ADDI = 4'b0001;
localparam LSL  = 4'b0010;
localparam SUB  = 4'b0011;

always @(*) begin
    case (ALUOp)
        ADD:  Result = A + B;
        ADDI: Result = A + imm;
        LSL:  Result = A << B;
        SUB:  Result = A - B;
        default: Result = 32'b0;
    endcase
end

endmodule

module Memory (
    input [31:0] address,
    input [31:0] write_data,
    input write_enable,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:39];
    
    initial begin
        mem[0] = 32'd0;
        mem[1] = 32'd19;
        mem[2] = 32'd36;
        mem[3] = 32'd51;
        mem[4] = 32'd64;
        mem[5] = 32'd75;
        mem[6] = 32'd84;
        mem[7] = 32'd91;
        mem[8] = 32'd96;
        mem[9] = 32'd99;
        mem[10] = 32'd100;
        mem[11] = 32'd99;
        mem[12] = 32'd96;
        mem[13] = 32'd91;
        mem[14] = 32'd84;
        mem[15] = 32'd75;
        mem[16] = 32'd64;
        mem[17] = 32'd51;
        mem[18] = 32'd36;
        mem[19] = 32'd19;
        mem[20] = 32'd0;
    end
    
    always @(address or write_data or write_enable) begin
        if (write_enable)
            mem[address[5:2]] = write_data;
        read_data = mem[address[5:2]];
    end
endmodule

module PipelinedProcessor (
    input clk,
    input reset
);
    // Déclaration des registres et des signaux de pipeline
    reg [31:0] registers [0:31];
    reg [31:0] memory [0:39];
    reg [31:0] PC;
    reg [31:0] IF_ID_IR, IF_ID_PC;
    reg [31:0] ID_EX_A, ID_EX_B, ID_EX_imm, ID_EX_IR;
    reg [31:0] EX_MEM_ALUOut, EX_MEM_B, EX_MEM_IR;
    reg [31:0] MEM_WB_ALUOut, MEM_WB_IR;
    reg [3:0] ALUOp;
    wire [31:0] ALU_Result;
    wire [31:0] mem_data;

    // Instanciation de l'ALU
    ALU alu (
        .ALUOp(ALUOp),
        .A(ID_EX_A),
        .B(ID_EX_B),
        .imm(ID_EX_imm),
        .Result(ALU_Result)
    );

    // Instanciation de la mémoire
    Memory memory_unit (
        .address(EX_MEM_ALUOut),
        .write_data(EX_MEM_B),
        .write_enable(EX_MEM_IR[5]),
        .read_data(mem_data)
    );

    // Initialisation
    initial begin
        PC = 0;
        registers[31] = 0;
        registers[1] = 0;
        registers[2] = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 0;
            IF_ID_IR <= 0;
            IF_ID_PC <= 0;
            ID_EX_A <= 0;
            ID_EX_B <= 0;
            ID_EX_imm <= 0;
            ID_EX_IR <= 0;
            EX_MEM_ALUOut <= 0;
            EX_MEM_B <= 0;
            EX_MEM_IR <= 0;
            MEM_WB_ALUOut <= 0;
            MEM_WB_IR <= 0;
        end else begin
            // Étape d'Instruction Fetch (IF)
            IF_ID_IR <= memory[PC];
            IF_ID_PC <= PC;
            PC <= PC + 4;

            // Étape d'Instruction Decode (ID)
            ID_EX_A <= registers[IF_ID_IR[19:15]];
            ID_EX_B <= registers[IF_ID_IR[24:20]];
            ID_EX_imm <= IF_ID_IR[31:20];
            ID_EX_IR <= IF_ID_IR;

            // Étape d'Execution (EX)
            case (ID_EX_IR[6:0])
                7'b0110011: begin // R-type
                    ALUOp <= ID_EX_IR[14:12];
                    EX_MEM_ALUOut <= ALU_Result;
                    EX_MEM_B <= ID_EX_B;
                    EX_MEM_IR <= ID_EX_IR;
                end
                7'b0010011: begin // I-type
                    ALUOp <= ID_EX_IR[14:12];
                    EX_MEM_ALUOut <= ALU_Result;
                    EX_MEM_B <= ID_EX_B;
                    EX_MEM_IR <= ID_EX_IR;
                end
                // Ajouter d'autres cas pour d'autres types d'instructions
            endcase

            // Étape de Memory (MEM)
            MEM_WB_ALUOut <= EX_MEM_ALUOut;
            MEM_WB_IR <= EX_MEM_IR;

            // Étape de Write Back (WB)
            if (MEM_WB_IR[6:0] == 7'b0110011) // R-type
                registers[MEM_WB_IR[11:7]] <= MEM_WB_ALUOut;
        end
    end
endmodule
