// DESCRIPTION: Verilator: Test for solve-before with multiple groups
//
// This file ONLY is placed under the Creative Commons Public Domain
// SPDX-FileCopyrightText: 2026
// SPDX-License-Identifier: CC0-1.0

class Packet;
  rand int a;
  rand int b;
  rand int c;
  
  // Chain: a must be solved before b, b before c
  constraint c_chain {
    solve a before b;
    solve b before c;
    
    a >= 0;
    a < 10;
    b == a * 10;  // b depends on a's value
    c == b + a;   // c depends on both a and b
  }
endclass

module t;
  Packet p;
  int v;

  initial begin
    p = new;
    
    // Test multiple randomizations
    for (int i = 0; i < 5; i++) begin
      v = p.randomize();
      if (v != 1) $stop;
      
      // These relationships must hold
      if (p.b != p.a * 10) begin
        $display("ERROR: b=%0d != a*10=%0d", p.b, p.a * 10);
        $stop;
      end
      if (p.c != p.b + p.a) begin
        $display("ERROR: c=%0d != b+a=%0d", p.c, p.b + p.a);
        $stop;
      end
      
      $display("a=%0d b=%0d c=%0d", p.a, p.b, p.c);
    end
    
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
