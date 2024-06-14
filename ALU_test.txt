// Code your testbench here
// or browse Examples
module ALU_Test;

    // Déclaration des variables
    reg [3:0] ALUOp;
    reg [31:0] A, B, imm;
    wire [31:0] Result;
    reg [31:0] X [0:31]; // Registres
    reg [31:0] addr;
    reg write_enable;
    wire [31:0] mem_data;
    integer loop;

    // Instanciation de l'ALU
    ALU alu (
        .ALUOp(ALUOp),
        .A(A),
        .B(B),
        .imm(imm),
        .Result(Result)
    );

    // Instanciation de la mémoire
    Memory memory (
        .address(addr),
        .write_data(Result),
        .write_enable(write_enable),
        .read_data(mem_data)
    );

    // Procédure de test
    initial begin
        // Déclaration du fichier VCD
        $dumpfile("dump.vcd");
        $dumpvars(0, ALU_Test);
        
        // Initialisation des registres
        X[31] = 32'd0; // Valeur initiale de X31
        X[1] = 32'd0;  // Valeur initiale de X1
        X[2] = 32'd0;  // Valeur initiale de X2

        // ADD X5, X31, X31
        ALUOp = 4'b0000;
        A = X[31];
        B = X[31];
        #10 X[5] = Result;

        // ADDI X6, X31, #20
        ALUOp = 4'b0001;
        A = X[31];
        imm = 32'd20;
        #10 X[6] = Result;

        // Branche à ENT (ceci simule l'instruction B ENT)
        loop = 1;

        while (loop) begin
            // TOP: LSL X10, X5, #3
            ALUOp = 4'b0010;
            A = X[5];
            B = 32'd3;
            #10 X[10] = Result;

            // ADD X11, X1, X10
            ALUOp = 4'b0000;
            A = X[1];
            B = X[10];
            #10 X[11] = Result;

            // LDUR X12, [X11, #0]
            addr = X[11];
            write_enable = 0;
            #10 X[12] = mem_data;

            // LDUR X13, [X11, #8]
            addr = X[11] + 32'd8;
            write_enable = 0;
            #10 X[13] = mem_data;

            // SUB X14, X12, X13
            ALUOp = 4'b0011;
            A = X[12];
            B = X[13];
            #10 X[14] = Result;

            // ADD X15, X2, X10
            ALUOp = 4'b0000;
            A = X[2];
            B = X[10];
            #10 X[15] = Result;

            // STUR X14, [X15, #0]
            addr = X[15];
            write_enable = 1;
            #10; // Écriture en mémoire

            // ADDI X5, X5, #2
            ALUOp = 4'b0001;
            A = X[5];
            imm = 32'd2;
            #10 X[5] = Result;

            // ENT: SUB X16, X5, X6
            ALUOp = 4'b0011;
            A = X[5];
            B = X[6];
            #10 X[16] = Result;

            // CBZ X16, END (Compare and branch if zero)
            if (X[16] == 32'd0) begin
                loop = 0; // Termine la boucle
            end
        end

        // END: (Fin du test)
        $finish;
    end

endmodule
