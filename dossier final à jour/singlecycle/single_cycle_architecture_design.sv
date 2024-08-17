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

module SingleCycleProcessor (
    input clk,
    input reset
);

    reg [31:0] PC;                    // Compteur de programme
    reg [31:0] registers [0:31];      // Fichier de registres
    wire [31:0] instruction;          // Instruction actuelle
    reg [31:0] A, B, imm;             // Opérandes et immédiat (déclarés comme reg)
    reg [31:0] ALUResult;             // Résultat de l'ALU
    wire [31:0] MemOut;
    reg [3:0] ALUOp;                  // Code d'opération pour l'ALU
    reg write_enable;                 // Signal de contrôle pour l'écriture en mémoire

    // Instanciation de la mémoire pour les instructions et les données
    Memory memory (
        .address(PC),
        .write_data(registers[instruction[24:20]]),
        .write_enable(write_enable),
        .read_data(instruction)
    );

    // Instanciation de l'ALU
    ALU alu (
        .ALUOp(ALUOp),
        .A(A),
        .B(B),
        .imm(imm),
        .Result(ALUResult)
    );

    // Initialisation des registres pour éviter des valeurs nulles
    initial begin
        registers[11] = 32'd100;
        registers[12] = 32'd50;
        registers[13] = 32'd25;
        registers[14] = 32'd12;
        registers[15] = 32'd6;
    end

    // Logique combinatoire pour l'exécution d'instructions en un seul cycle
    always @(*) begin
        // Valeurs des opérandes A, B et immediate
        A = registers[instruction[19:15]];
        B = registers[instruction[24:20]];
        imm = {20'b0, instruction[31:20]}; // Extension pour l'immédiat

        // Définir l'opération de l'ALU
        case (instruction[6:0])
            7'b0110011: begin // ADD, SUB, LSL (R-type)
                case (instruction[14:12])
                    3'b000: ALUOp = instruction[30] ? 4'b0011 : 4'b0000; // SUB si bit 30 = 1, sinon ADD
                    3'b001: ALUOp = 4'b0010; // LSL
                    default: ALUOp = 4'b0000; // Par défaut, ADD
                endcase
            end
            7'b0010011: ALUOp = 4'b0001; // ADDI
            7'b0000011: ALUOp = 4'b0000; // LDUR (similaire à ADD)
            7'b0100011: ALUOp = 4'b0000; // STUR (similaire à ADD)
            default: ALUOp = 4'b0000;
        endcase

        // Contrôle d'écriture en mémoire
        write_enable = (instruction[6:0] == 7'b0100011); // STUR (écriture en mémoire)
    end

    // Logique séquentielle pour mettre à jour les registres et le PC
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 0;
        end else begin
            case (instruction[6:0])
                7'b0110011: registers[instruction[11:7]] <= ALUResult; // R-type (ADD, SUB, LSL)
                7'b0010011: registers[instruction[11:7]] <= ALUResult; // I-type (ADDI)
                7'b0000011: registers[instruction[11:7]] <= MemOut; // LDUR (chargement depuis la mémoire)
            endcase
            PC <= PC + 4; // Passage à l'instruction suivante
        end
    end

    // Affichage des registres X11 à X15 à chaque cycle
    always @(posedge clk) begin
        $display("X11: %d, X12: %d, X13: %d, X14: %d, X15: %d", registers[11], registers[12], registers[13], registers[14], registers[15]);
    end

endmodule
