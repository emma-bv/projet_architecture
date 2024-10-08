// Code your design here
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


