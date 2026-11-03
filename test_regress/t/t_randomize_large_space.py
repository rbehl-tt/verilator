#!/usr/bin/env python3
# DESCRIPTION: Verilator: Verilog Test driver/expect definition
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either the GNU Lesser General Public License Version 3
# or the Perl Artistic License Version 2.0.
# SPDX-FileCopyrightText: 2026 Wilson Snyder
# SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0

import vltest_bootstrap

test.scenarios('vlt')

if not test.have_solver:
    test.skip("No constraint solver installed")

test.compile()

solver_log = test.obj_dir + "/solver.log"

test.execute(all_run_flags=['+verilator+solver+file+' + solver_log])

# Each solve or enumerated solution answers sat once: one to start the solver, then 143 per
# object. The first call solves once and runs 4 diversity rounds. The second enumerates 61
# solutions twice (no cut, then the most cut) and the 16 of the batch.
test.file_grep_count(solver_log, r'^< sat$', 1 + 8 * 143)

test.passes()
