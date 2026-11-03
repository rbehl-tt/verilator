// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// Re-randomizes objects whose solution space is too large to cut into
// enumerable cells. On each object the first call takes the plain solver path,
// and the second sizes the space and draws a batch of samples that the
// following calls use.

// verilog_format: off
`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
`define check_range(gotv,minv,maxv) do if ((gotv) < (minv) || (gotv) > (maxv)) begin $write("%%Error: %s:%0d:  got=%0d exp=[%0d:%0d]\n", `__FILE__,`__LINE__, (gotv), (minv), (maxv)); `stop; end while(0);
// verilog_format: on

module t;
  class C;
    rand int arr[10];
    constraint c {
      foreach (arr[i]) {
        arr[i] inside {[0 : 1000]};
      }
    }
  endclass

  initial begin
    automatic int ok;
    automatic int low = 0;
    // Each object sizes its own space and draws its own batch, so the check
    // below does not hinge on one random draw
    repeat (8) begin
      automatic C c = new;
      repeat (17) begin
        ok = c.randomize();
        `checkd(ok, 1);
        foreach (c.arr[i]) begin
          `check_range(c.arr[i], 0, 1000);
          if (c.arr[i] < 16) low++;
        end
      end
    end
    // 1360 uniform values hold 22 below 16 on average
    `check_range(low, 0, 60);
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
