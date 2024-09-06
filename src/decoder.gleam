import gleam/dynamic.{type Decoder}

pub opaque type Marker {
    Marker
}

pub opaque type Goal(a, g) {
    Goal(inner: fn (a) -> g)
}

pub fn parameter(
    f: fn (b) -> Goal(a, g),
) -> Goal(#(b, a), g) {
    Goal(
        inner: fn (x) {
            let #(b, a) = x
            f(b).inner(a)
        }
    )
}

pub fn return(a: a) -> Goal(Marker, a) {
    Goal(inner: fn (_) { a })
}

pub opaque type Solve(a, g) {
    Solve(
        inner: Decoder(fn(a) -> g),
    )
}

pub fn create_goal(goal: Goal(a, g)) -> Solve(a, g) {
    Solve(
        inner: fn (_) {
            Ok(goal.inner)
        }
    )
}

pub fn solve(decode: Decoder(b)) -> fn(Solve(#(b, a), g)) -> Solve(a, g) {
    fn (current: Solve(#(b, a), g)) {
        Solve(
            inner: dynamic.decode1(
                fn (x) {
                    let #(f, b) = x
                    fn(a) { f(#(b, a)) }
                },
                dynamic.decode2(fn (a, b) { #(a, b) }, current.inner, decode)
            )
        )
    }
}

pub fn to_decoder(s: Solve(Marker, a)) -> Decoder(a) {
    dynamic.decode1(fn (f) { f(Marker) }, s.inner)
}
