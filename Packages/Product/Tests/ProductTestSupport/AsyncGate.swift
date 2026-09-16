//
//  AsyncGate.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

/// Lets a test hold a task at a chosen point and release it on command.
///
/// This is what makes the cancellation tests deterministic instead of timing-based: a
/// test can park a search inside the loader, cancel it there, and only then let it
/// return — rather than sleeping and hoping the ordering came out right on a loaded CI
/// machine.
///
/// `open()` latches, so a gate opened before anyone waits on it never strands a caller.
public actor AsyncGate {
    private var isOpen = false
    private var waiting: [CheckedContinuation<Void, Never>] = []

    public init() {}

    public func wait() async {
        guard !isOpen else {
            return
        }

        await withCheckedContinuation { waiting.append($0) }
    }

    public func open() {
        isOpen = true

        for continuation in waiting {
            continuation.resume()
        }

        waiting = []
    }
}
