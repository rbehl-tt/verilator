// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain
// SPDX-FileCopyrightText: 2026
// SPDX-License-Identifier: CC0-1.0

// Test constraint that no adjacent bits in a vector are both 1s

class NoAdjacentBits;
    rand bit [9:0] vec;
    
    constraint c_no_adjacent {
        // Ensure no two adjacent bits are both 1
        // Check each pair explicitly
        foreach (vec[i])
          if (i <= 8) vec[i] == 1 -> vec[i+1] == 0;
    }
    
    function int verify();
        // Check that no adjacent bits are both 1
        for (int i = 0; i < 9; i++) begin
            if (vec[i] && vec[i+1]) begin
                $display("ERROR: Adjacent bits at positions %0d and %0d are both 1", i, i+1);
                $display("  vec = 10'b%b", vec);
                return 0;
            end
        end
        return 1;
    endfunction
endclass

module t;
    initial begin
        NoAdjacentBits obj;
        int result;
        static int success = 0;
        
        obj = new();
        
        // Run multiple randomizations to test the constraint
        for (int trial = 0; trial < 20; trial++) begin
            result = obj.randomize();
            if (result != 1) begin
                $display("ERROR: randomize failed on trial %0d", trial);
                $stop;
            end
            
            result = obj.verify();
            if (result != 1) begin
                $display("ERROR: Verification failed on trial %0d", trial);
                $stop;
            end
            
            // Display some sample values
            if (trial < 5) begin
                $display("Trial %0d: vec = 10'b%b (decimal %0d)", trial, obj.vec, obj.vec);
            end
            success++;
        end
        
        $display("PASSED: All %0d trials successful - no adjacent bits are 1s", success);
        $write("*-* All Finished *-*\n");
        $finish;
    end
endmodule
