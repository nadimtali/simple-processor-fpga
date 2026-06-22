module proc_top (
    input  logic [9:0] SW,      // Board switches
    input  logic [1:0] KEY,     // Board pushbuttons
    output logic [9:0] LEDR     // Board LEDs
);

    // Board connections:
    // SW[8:0]  -> DIN input of the processor
    // SW[9]    -> Run signal
    // KEY[0]   -> Resetn
    // KEY[1]   -> Clock
    // LEDR[8:0] -> BusWires
    // LEDR[9]   -> Done

    proc processor_inst (
        .DIN      (SW[8:0]),
        .Resetn   (KEY[0]),
        .Clock    (KEY[1]),
        .Run      (SW[9]),
        .Done     (LEDR[9]),
        .BusWires (LEDR[8:0])
    );

endmodule