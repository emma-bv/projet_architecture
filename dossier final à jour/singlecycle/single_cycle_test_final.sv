module ALU_Test;

    reg clk;
    reg reset;

    PipelinedProcessor pp (
        .clk(clk),
        .reset(reset)
    );

    initial begin
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
