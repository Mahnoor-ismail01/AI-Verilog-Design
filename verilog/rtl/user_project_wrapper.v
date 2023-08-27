// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

/* Simple 32-bit Adder */
module simple_adder (
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] sum
);
    always @* sum = a + b;
endmodule

/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *

 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) 
(
`ifdef USE_POWER_PINS
    inout vdda1,    // User area 1 3.3V supply
    inout vdda2,    // User area 2 3.3V supply
    inout vssa1,    // User area 1 analog ground
    inout vssa2,    // User area 2 analog ground
    inout vccd1,    // User area 1 1.8V supply
    inout vccd2,    // User area 2 1.8v supply
    inout vssd1,    // User area 1 digital ground
    inout vssd2,    // User area 2 digital ground
`endif
//
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output reg [31:0] wbs_dat_o,
//
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,
//
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,
//
    inout [`MPRJ_IO_PADS-10:0] analog_io,
    //
    input   user_clock2,
    //
    output [2:0] user_irq
);

/* Adder instantiation */
reg [31:0] adder_input_a;
reg [31:0] adder_input_b;
wire [31:0] adder_output;

simple_adder adder_instance (
    .a(adder_input_a),
    .b(adder_input_b),
    .sum(adder_output)
);

/* Wishbone and Adder Logic */
always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if (wb_rst_i) begin
        adder_input_a <= 32'b0;
        adder_input_b <= 32'b0;
    end else if (wbs_cyc_i && wbs_stb_i) begin
        case (wbs_adr_i[1:0]) 
            2'b00: if (wbs_we_i) adder_input_a <= wbs_dat_i;
            2'b01: if (wbs_we_i) adder_input_b <= wbs_dat_i;
            2'b10: if (!wbs_we_i) wbs_dat_o <= adder_output;
        endcase
    end
end

always @(posedge wb_clk_i) begin
    if (wbs_cyc_i && wbs_stb_i) begin
        wbs_ack_o <= 1;
    end else begin
        wbs_ack_o <= 0;
    end
end

endmodule

`default_nettype wire
