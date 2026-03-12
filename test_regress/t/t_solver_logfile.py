#!/usr/bin/env python3
# DESCRIPTION: Verilator: Solver Logfile Feature Test
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either the GNU Lesser General Public License Version 3
# or the Perl Artistic License Version 2.0.
# SPDX-FileCopyrightText: 2026 Wilson Snyder
# SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0

import vltest_bootstrap
import os

test.scenarios('simulator')

if not test.have_solver:
    test.skip("No constraint solver installed")

# Test basic compilation with --solver-logfile option
logfile = os.path.join(test.obj_dir, 'solver.log')
test.compile(verilator_flags2=['--solver-logfile', logfile])

test.execute()

# Check that logfile was created and contains expected SMT-LIB2 format
if not os.path.exists(logfile):
    test.error("Solver logfile was not created: " + logfile)
with open(logfile, 'r', encoding='utf-8') as f:
    content = f.read()
    # Should contain solver commands and responses in SMT-LIB2 format
    if '>(check-sat)' not in content:
        test.error("Logfile missing solver commands")
    if '<sat' not in content and '<unsat' not in content:
        test.error("Logfile missing solver responses")

test.passes()
