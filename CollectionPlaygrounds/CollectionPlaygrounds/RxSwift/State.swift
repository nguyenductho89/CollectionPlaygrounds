//
//  Copyright (c) 2015 Adam Sharp. All rights reserved.
//
/// The state monad. Wraps a stateful function S -> (A, S).
public struct State<S, A> {
    // MARK: Initialisers
    /// Wrap a stateful computation.
    public init(f: @escaping (S) -> (A, S)) {
        fn = f
    }

    /// Lift a value into stateful computation that returns the value and the state unchanged.
    public init(_ a: A) {
        fn = { s in (a, s) }
    }


    // MARK: Running stateful computations
    /// Run the computation with a starting state, returning a tuple of the value and the final state.
    public func run(s: S) -> (A, S) {
        return fn(s)
    }

    /// Run the computation and return on the resulting value, discarding the final state.
    public func eval(s: S) -> A {
        return run(s: s).0
    }

    /// Run the computation and return the final state, discarding the resulting value.
    public func exec(s: S) -> S {
        return run(s: s).1
    }


    // MARK: Sequencing stateful computations
    /// Run this computation, discarding its result, then run the next computation.
    public func then<B>(next: State<S, B>) -> State<S, B> {
        return flatMap { _ in next }
    }

    /// Given a top-level function returning a stateful computation, allow it to be passed by name instead of called explicity.
    ///
    /// Example::
    ///
    ///     // Instead of this
    ///     put(newstate).then(get())
    ///
    ///     // Allows this
    ///     put(newstate).then(get)
    ///
    public func then<B>(next: () -> State<S, B>) -> State<S, B> {
        return then(next: next())
    }


    // MARK: Higher order functions
    /// Return a new stateful computation which is the result of applying `f` to the result of this computation.
    public func map<B>(f: @escaping (A) -> B) -> State<S, B> {
        return flatMap { yield(a: f($0)) }
    }

    /// Sequence this computation with computation, using the value of this computation as input to the second.
    public func flatMap<B>(f: @escaping (A) -> State<S, B>) -> State<S, B> {
        return State<S, B> { s1 in
            let (a, s2) = self.run(s: s1)
            return f(a).run(s: s2)
        }
    }


    // MARK: Private
    private let fn: (S) -> (A, S)
}


// MARK: Operations
/// A computation that yields the current state as its result.
public func get<S>() -> State<S, S> {
    return State { s in (s, s) }
}

/// A computation that replaces the current state.
public func put<S>(s: S) -> State<S, ()> {
    return State { _ in ((), s) }
}

/// Lift a value into the State monad.
public func yield<S, A>(a: A) -> State<S, A> {
    return State(a)
}

/// Return a new state by applying a function to the current state, discarding the old state.
///
/// Example::
///
///     modify { $0 + 1 }.exec(1)   // => 2
///
/// This is equivalent to a swift assignment operation::
///
///     var i = 1; i += 1           // => 2
///
public func modify<S>(f: @escaping (S) -> S) -> State<S, ()> {
    return State { s in ((), f(s)) }
}
