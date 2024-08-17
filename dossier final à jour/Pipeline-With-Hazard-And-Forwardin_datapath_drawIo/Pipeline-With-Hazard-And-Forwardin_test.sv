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

        clk = 0;
        reset = 1;
        #5 reset = 0;

        // Simulation clock
        forever #5 clk = ~clk;
    end

    initial begin
        // Arrêter la simulation après un certain temps
        #200 $finish;
    end

endmodule

