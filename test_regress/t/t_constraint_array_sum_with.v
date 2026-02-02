// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 by Wilson Snyder and Contributors
// SPDX-License-Identifier: CC0-1.0

// Test case for array.sum() with (...) in constraints (issue #6455)

class three_duplicates_only;
  rand byte array[5];
  rand byte repeated_value;

  constraint three_duplicates_only_c {
    // Ensure exactly 3 occurrences of repeated_value
    array.sum() with (int'(item==repeated_value)) == 3;

    // All other values should appear exactly once
    foreach(array[i]) {
      array[i] != repeated_value -> array.sum() with (int'(item==array[i])) == 1;
    }
  }

  function void display();
    foreach (array[i]) begin
      $display("Array[%0d]: %d", i, unsigned'(array[i]));
    end
  endfunction

  function bit verify();
    int count_map[byte];
    int repeated_count = 0;

    // Count occurrences
    foreach (array[i]) begin
      if (!count_map.exists(array[i])) count_map[array[i]] = 0;
      count_map[array[i]]++;
    end

    // Check repeated_value appears exactly 3 times
    if (count_map.exists(repeated_value)) begin
      repeated_count = count_map[repeated_value];
      if (repeated_count != 3) begin
        $display("ERROR: repeated_value=%0d appears %0d times, expected 3",
                 repeated_value, repeated_count);
        return 0;
      end
    end else begin
      $display("ERROR: repeated_value=%0d doesn't appear in array", repeated_value);
      return 0;
    end

    // Check all other values appear exactly once
    foreach (count_map[val]) begin
      if (val != repeated_value && count_map[val] != 1) begin
        $display("ERROR: value=%0d appears %0d times, expected 1", val, count_map[val]);
        return 0;
      end
    end

    return 1;
  endfunction
endclass

module t;
  three_duplicates_only inst;

  initial begin
    inst = new();

    // Test multiple randomizations
    repeat (10) begin
      if (inst.randomize() == 0) begin
        $display("%%Error: Failed to randomize array.");
        $stop;
      end

      inst.display();

      if (!inst.verify()) begin
        $display("%%Error: Constraint verification failed.");
        $stop;
      end

      $display("---");
    end

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
