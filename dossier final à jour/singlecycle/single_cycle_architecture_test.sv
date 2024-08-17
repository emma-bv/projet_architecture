module SingleCycleProcessor_tb;

    reg clk;
    reg reset;

    SingleCycleProcessor scp (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, SingleCycleProcessor_tb);
        
        // Initialisation
        clk = 0;
        reset = 1;
        #5 reset = 0;

        // Simulation
        #1000 $finish;
    end

    always #5 clk = ~clk; // Horloge à 10 unités de temps

endmodule
