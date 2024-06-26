// Code your testbench here
// or browse Examples
module ALU_Test;

    // Déclaration des variables
    reg clk;
    reg reset;

    // Instanciation du processeur pipeliné
    PipelinedProcessor pp (
        .clk(clk),
        .reset(reset)
    );

    // Initialisation du test
    initial begin
        // Déclaration du fichier VCD
        $dumpfile("dump.vcd");
        $dumpvars(0, ALU_Test);
        
        // Initialisation
        clk = 0;
        reset = 1;
        #5 reset = 0;

        // Ajout des instructions de test
        // Initialisation des registres
        pp.registers[31] = 32'd0; // Valeur initiale de X31
        pp.registers[1] = 32'd0;  // Valeur initiale de X1
        pp.registers[2] = 32'd0;  // Valeur initiale de X2

        // Instructions
        // ADD X5, X31, X31
        pp.memory.mem[0] = 32'b000000000001_11111_000_00101_0110011; // Encodage de l'instruction
        // ADDI X6, X31, #20
        pp.memory.mem[1] = 32'b000000000101_11111_000_00110_0010011;
        // NOP
        pp.memory.mem[2] = 32'b000000000000_00000_000_00000_0000000;
        // TOP: LSL X10, X5, #3
        pp.memory.mem[3] = 32'b000000000011_00101_001_01010_0010011;
        // ADD X11, X1, X10
        pp.memory.mem[4] = 32'b000000000000_01010_000_01011_0110011;
        // LDUR X12, [X11, #0]
        pp.memory.mem[5] = 32'b000000000000_01011_010_01100_0000011;
        // NOP
        pp.memory.mem[6] = 32'b000000000000_00000_000_00000_0000000;
        // LDUR X13, [X11, #8]
        pp.memory.mem[7] = 32'b000000000010_01011_010_01101_0000011;
        // NOP
        pp.memory.mem[8] = 32'b000000000000_00000_000_00000_0000000;
        // SUB X14, X12, X13
        pp.memory.mem[9] = 32'b000000000000_01100_000_01110_0110011;
        // ADD X15, X2, X10
        pp.memory.mem[10] = 32'b000000000000_01010_000_01111_0110011;
        // STUR X14, [X15, #0]
        pp.memory.mem[11] = 32'b000000000000_01110_010_00000_0100011;
        // NOP
        pp.memory.mem[12] = 32'b000000000000_00000_000_00000_0000000;
        // ADDI X5, X5, #2
        pp.memory.mem[13] = 32'b000000000010_00101_000_00101_0010011;
        // ENT: SUB X16, X5, X6
        pp.memory.mem[14] = 32'b000000000000_00101_000_10000_0110011;
        // CBZ X16, END (branch si zero)
        pp.memory.mem[15] = 32'b000000000000_10000_000_00000_1100011;
        // NOP
        pp.memory.mem[16] = 32'b000000000000_00000_000_00000_0000000;

        // Simulation
        #1000 $finish;
    end

    always #5 clk = ~clk; // Horloge à 10 unités de temps

endmodule
