`timescale 1ns/1ps

module user_project_wrapper_tb;

    reg wb_clk_i;
    reg wb_rst_i;
    reg wbs_stb_i;
    reg wbs_cyc_i;
    reg wbs_we_i;
    reg [3:0] wbs_sel_i;
    reg [31:0] wbs_dat_i;
    reg [31:0] wbs_adr_i;
    wire wbs_ack_o;
    wire [31:0] wbs_dat_o;

    wire [127:0] la_data_out;
    reg [127:0] la_data_in = 128'h0;
    reg [127:0] la_oenb = 128'h0;

    reg [39:0] io_in = 2'h0;
    wire [39:0] io_out;
    wire [39:0] io_oeb;

    reg user_clock2;

    wire [2:0] user_irq;

    // Instantiate the user_project_wrapper
    user_project_wrapper uut (
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        .wbs_stb_i(wbs_stb_i),
        .wbs_cyc_i(wbs_cyc_i),
        .wbs_we_i(wbs_we_i),
        .wbs_sel_i(wbs_sel_i),
        .wbs_dat_i(wbs_dat_i),
        .wbs_adr_i(wbs_adr_i),
        .wbs_ack_o(wbs_ack_o),
        .wbs_dat_o(wbs_dat_o),
        .la_data_in(la_data_in),
        .la_data_out(la_data_out),
        .la_oenb(la_oenb),
        .io_in(io_in),
        .io_out(io_out),
        .io_oeb(io_oeb),
        .user_clock2(user_clock2),
        .user_irq(user_irq)
    );

    // Clock Generation
    always begin
        #5 wb_clk_i = ~wb_clk_i;
    end

    initial begin
        // VCD Dump Initialization
        $dumpfile("output.vcd");
        $dumpvars(0, user_project_wrapper_tb);

        wb_clk_i = 0;
        wb_rst_i = 1;
        wbs_stb_i = 0;
        wbs_cyc_i = 0;
        wbs_we_i = 0;
        wbs_sel_i = 4'hf; // Assuming all data bits are valid
        wbs_dat_i = 0;
        wbs_adr_i = 0;
        user_clock2 = 1'b0;

        #10 wb_rst_i = 0; // Release reset
        #10;

        // Write to a
        wbs_adr_i = 2'b00; 
        wbs_dat_i = 8'hA5; // Arbitrary value
        wbs_stb_i = 1'b1;  // Strobe signal high
        wbs_cyc_i = 1'b1;  // Cycle signal high
        wbs_we_i = 1'b1;   // Write enable
        #10;

        // Write to b
        wbs_adr_i = 2'b01;
        wbs_dat_i = 8'h5A; // Arbitrary value
        wbs_stb_i = 1'b1;
        wbs_cyc_i = 1'b1;
        wbs_we_i = 1'b1;
        #10;

        // Read sum
        wbs_adr_i = 2'b10;
        wbs_stb_i = 1'b1;
        wbs_cyc_i = 1'b1;
        wbs_we_i = 1'b0; // Read operation
        #10;

        // Check the read data
        if (wbs_ack_o) begin
            $display("Read Sum: %h", wbs_dat_o);
        end

        // Stop VCD dumping before finishing the simulation
        $dumpoff;
        $finish;
    end
endmodule
