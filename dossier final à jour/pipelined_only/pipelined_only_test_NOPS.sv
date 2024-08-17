// Testbench pour le processeur pipeliné
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

        // Initialisation des registres
        pp.registers[31] = 32'd0; // Valeur initiale de X31
        pp.registers[1] = 32'd0;  // Valeur initiale de X1
        pp.registers[2] = 32'd0;  // Valeur initiale de X2

        // Ajout des instructions de test
        // ADD X5, X31, X31
        pp.memory.mem[0] = 32'b000000000001_11111_000_00101_0110011; // Encodage de l'instruction
        // ADDI X6, X31, #20
        pp.memory.mem[1] = 32'b000000000101_11111_000_00110_0010011;
        // NOP
        pp.memory.mem[2] = 32'b000000000000_00000_000_00000_0000000;
        // LSL X10, X5, #3
        pp.memory.mem[3] = 32'b000000000011_00101_001_01010_0010011;
        // ADD X11, X1, X10
        pp.memory.mem[4] = 32'b000000000000_01010_000_01011_0110011;
        // LDUR X12, [X11, #0]
        pp.memory.mem[5] = 32'b000000000000_01011_010_01100_0000011;
        // STUR X13, [X11, #4]
        pp.memory.mem[6] = 32'b000000000001_01011_010_01101_0100011;

        // Attente pour observer les résultats
        #100;

        // Affichage des valeurs finales des registres
        $display("X11 = %d", pp.registers[11]);
        $display("X12 = %d", pp.registers[12]);
        $display("X13 = %d", pp.registers[13]);
        $display("X14 = %d", pp.registers[14]);
        $display("X15 = %d", pp.registers[15]);

        // Fin du test
        $finish;
    end

    // Génération de l'horloge
    always #5 clk = ~clk;

endmodule

