// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 PlanV GmbH
// SPDX-License-Identifier: CC0-1.0

`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);

module t;

  class RandomTest;
    rand bit [31:0] value;
    constraint c_value { value > 100 && value < 1000; }
  endclass

  RandomTest obj;

  initial begin
    obj = new();

    // Attempt randomization which may trigger solver
    repeat (10) begin
      `checkd(obj.randomize(), 1)  // Expect randomization to succeed
      $write("Randomized value: %0d\n", obj.value);
    end

    $write("*-* All Finished *-*\n");
    $finish;
  end

endmodule
