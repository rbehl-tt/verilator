// -*- mode: C++; c-file-style: "cc-mode" -*-
//*************************************************************************
// DESCRIPTION: Verilator: Solver communication logfile support
//
// Code available from: https://verilator.org
//
//*************************************************************************
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of either the GNU Lesser General Public License Version 3
// or the Perl Artistic License Version 2.0.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0
//
//*************************************************************************

#ifndef VERILATED_SOLVER_LOG_H_
#define VERILATED_SOLVER_LOG_H_

#include "verilatedos.h"

#include <fstream>
#include <iostream>
#include <memory>
#include <mutex>
#include <string>

//######################################################################

/// Thread-safe solver communication logger
/// Logs all communications to/from the SMT solver in SMT-LIB2 format
class VlSolverLog final {
private:
    std::unique_ptr<std::ofstream> m_logFile;
    std::mutex m_mutex;
    bool m_isOpen = false;

public:
    /// Constructor - initializes with optional logfile path
    /// @param logfilePath  Path to logfile, empty string disables logging
    explicit VlSolverLog(const std::string& logfilePath = "") {
        if (!logfilePath.empty()) {
            try {
                m_logFile = std::make_unique<std::ofstream>(logfilePath, std::ios::app);
                m_isOpen = m_logFile && m_logFile->is_open();
                if (!m_isOpen) {
                    std::cerr << "Warning: Failed to open solver logfile: " << logfilePath << "\n";
                }
            } catch (const std::exception& e) {
                std::cerr << "Warning: Exception opening solver logfile: " << e.what() << "\n";
            }
        }
    }

    /// Destructor - closes logfile
    ~VlSolverLog() {
        if (m_logFile && m_logFile->is_open()) {
            m_logFile->close();
        }
    }

    /// Check if logging is enabled
    bool isOpen() const { return m_isOpen; }

    /// Log a command sent to the solver
    /// @param command  The SMT-LIB2 command being sent
    void logCommand(const std::string& command) {
        if (!m_isOpen) return;
        std::lock_guard<std::mutex> lock(m_mutex);
        try {
            (*m_logFile) << ">" << command << "\n";
            m_logFile->flush();
        } catch (...) {
            // Silently ignore logging errors to avoid disrupting simulation
        }
    }

    /// Log a response from the solver
    /// @param response  The SMT-LIB2 response from solver
    void logResponse(const std::string& response) {
        if (!m_isOpen) return;
        std::lock_guard<std::mutex> lock(m_mutex);
        try {
            (*m_logFile) << "<" << response << "\n";
            m_logFile->flush();
        } catch (...) {
            // Silently ignore logging errors to avoid disrupting simulation
        }
    }

    // Deleted copy operations - not copyable
    VlSolverLog(const VlSolverLog&) = delete;
    VlSolverLog& operator=(const VlSolverLog&) = delete;

    // Deleted move operations - ensure single instance per simulation
    VlSolverLog(VlSolverLog&&) = delete;
    VlSolverLog& operator=(VlSolverLog&&) = delete;
};

//######################################################################

#endif  // guard
