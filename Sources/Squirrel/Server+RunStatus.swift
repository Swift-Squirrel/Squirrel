//
//  Server+RunStatus.swift
//  Squirrel
//
//  Created by Filip Klembara on 4/4/18.
//

// MARK: - RunStatus
public extension Server {
    /// Server status
    ///
    /// - willRun: Server will be running in short time
    /// - running: Server is running
    /// - paused: Server is paused
    /// - pausing: Server is pausing
    /// - stopped: Server is stopped
    /// - stopping: Server is stopping
    public enum RunStatus {
        case willRun
        case running
        case paused
        case pausing(now: Bool, closure: ()->Void)
        case stopped
        case stopping(now: Bool)
    }

    /// True if server is paused
    public var isPaused: Bool {
        guard case .stopped = runStatus else {
            return false
        }
        return true
    }
    /// True if server will run
    var willRun: Bool {
        guard case .willRun = runStatus else {
            return false
        }
        return true
    }

    /// True if server is stopped
    var isStopped: Bool {
        guard case .stopped = runStatus else {
            return false
        }
        return true
    }

    /// True if server is running
    var isRunning: Bool {
        guard case .running = runStatus else {
            return false
        }
        return true
    }
}
