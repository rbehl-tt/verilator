// DESCRIPTION: Verilator: Verilog Test module for simple solve-before
//
// This file ONLY is placed under the Creative Commons Public Domain
// SPDX-FileCopyrightText: 2026
// SPDX-License-Identifier: CC0-1.0

class Packet;
  rand byte x;
  rand byte y;
  
  // Simple solve-before: x should be solved before y
  constraint c_order {
    solve x before y;
    x > y;
    x >= 0;
    x < 100;
  }
endclass

module t;
  Packet p;
  int v;

  initial begin
    p = new;
    
    // Test multiple randomizations
    for (int i = 0; i < 10; i++) begin
      v = p.randomize();
      if (v != 1) $stop;
      if (p.x <= p.y) $stop;
      $display("x=%0d y=%0d", p.x, p.y);
    end
    
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
