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

        // Simulation
        #1000 $finish;
    end

    always #5 clk = ~clk; // Horloge à 10 unités de temps

endmodule
