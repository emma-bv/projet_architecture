module ALU (
    input [3:0] ALUOp,       // Code opération pour sélectionner l'opération à effectuer
    input [31:0] A,          // Premier opérande
    input [31:0] B,          // Deuxième opérande
    input [31:0] imm,        // Valeur immédiate pour ADDI
    output reg [31:0] Result // Résultat de l'opération
);

// Définition des codes d'opération
localparam ADD  = 4'b0000;
localparam ADDI = 4'b0001;
localparam LSL  = 4'b0010;
localparam SUB  = 4'b0011;

always @(*) begin
    case (ALUOp)
        ADD:  Result = A + B;          // Addition
        ADDI: Result = A + imm;        // Addition avec immédiat
        LSL:  Result = A << B;         // Décalage logique à gauche
        SUB:  Result = A - B;          // Soustraction
        default: Result = 32'b0;       // Par défaut, résultat nul
    endcase
end

endmodule

module Memory (
    input [31:0] address,
    input [31:0] write_data,
    input write_enable,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:39]; // Mémoire de 40 mots (0 à 39) pour stocker les valeurs
    
    // Initialisation de la mémoire avec les valeurs données
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
            mem[address[5:2]] = write_data; // Écriture en mémoire (adresse divisée par 4 pour accéder aux mots)
        read_data = mem[address[5:2]]; // Lecture en mémoire
    end
endmodule

module PipelinedProcessor (
    input clk,
    input reset
);

    // Registres pour chaque étape du pipeline
    reg [31:0] IF_ID_IR, IF_ID_NPC;
    reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_IMM;
    reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
    reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_MemOut;

    // Autres signaux
    reg [31:0] PC;
    wire [31:0] NPC, IR, A, B, IMM, ALUOut, MemOut, Result;
    wire [3:0] ALUOp;
    wire write_enable;

    reg [31:0] registers [0:31]; // Déclaration des registres

    // Instanciation des modules
    ALU alu (
        .ALUOp(ALUOp),
        .A(ID_EX_A),
        .B(ID_EX_B),
        .imm(ID_EX_IMM),
        .Result(ALUOut)
    );

    Memory memory (
        .address(EX_MEM_ALUOut),
        .write_data(EX_MEM_B),
        .write_enable(write_enable),
        .read_data(MemOut)
    );

    // Initialisation des registres avec des valeurs de départ
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'd0;
        end

        // Chargement de données spécifiques pour les tests dans les registres
        registers[12] = 32'd5;
        registers[13] = 32'd10;
        registers[14] = 32'd15;
        registers[15] = 32'd20;
    end

    // Étape IF
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 0;
        end else begin
            IF_ID_IR <= memory.mem[PC[5:2]]; // Assurez-vous que PC est correctement indexé
            IF_ID_NPC <= PC + 4;
            PC <= PC + 4;
        end
    end

    // Étape ID
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ID_EX_IR <= 0;
            ID_EX_NPC <= 0;
            ID_EX_A <= 0;
            ID_EX_B <= 0;
            ID_EX_IMM <= 0;
        end else begin
            ID_EX_IR <= IF_ID_IR;
            ID_EX_NPC <= IF_ID_NPC;
            ID_EX_A <= registers[IF_ID_IR[19:15]];
            ID_EX_B <= registers[IF_ID_IR[24:20]];
            ID_EX_IMM <= {20'b0, IF_ID_IR[31:20]}; // Pour simplification, IMM est traité ainsi
        end
    end

    // Étape EX
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_IR <= 0;
            EX_MEM_ALUOut <= 0;
            EX_MEM_B <= 0;
        end else begin
            EX_MEM_IR <= ID_EX_IR;
            EX_MEM_ALUOut <= ALUOut;
            EX_MEM_B <= ID_EX_B;
        end
    end

    // Étape MEM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_IR <= 0;
            MEM_WB_ALUOut <= 0;
            MEM_WB_MemOut <= 0;
        end else begin
            MEM_WB_IR <= EX_MEM_IR;
            MEM_WB_ALUOut <= EX_MEM_ALUOut;
            MEM_WB_MemOut <= MemOut;
        end
    end

    // Étape WB
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Rien à faire ici pour reset
        end else begin
            case (MEM_WB_IR[6:0])
                7'b1100011: // SUB instruction
                    registers[MEM_WB_IR[11:7]] <= MEM_WB_ALUOut;
                7'b0010011: // ADDI instruction
                    registers[MEM_WB_IR[11:7]] <= MEM_WB_ALUOut;
                7'b0000011: // LDUR instruction
                    registers[MEM_WB_IR[11:7]] <= MEM_WB_MemOut;
                7'b0100011: // STUR instruction
                    registers[MEM_WB_IR[11:7]] <= MEM_WB_ALUOut;
                default: ;
            endcase

            // Affichage des registres X12, X13, X14 et X15
            $display("Cycle %d:", $time / 10);
            $display("Register X12: %d", registers[12]);
            $display("Register X13: %d", registers[13]);
            $display("Register X14: %d", registers[14]);
            $display("Register X15: %d", registers[15]);
        end
    end

endmodule
