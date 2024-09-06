import gleam/javascript/promise.{type Promise}

pub fn map_error(
    promise: Promise(Result(a, b)),
    callback: fn(b) -> Promise(c),
) -> Promise(Result(a, c)) {
    promise.await(promise, fn (result) {
        case result {
            Ok(value) -> promise.resolve(Ok(value))
            Error(error) -> {
                use error <- promise.await(callback(error))
                promise.resolve(Error(error))
            }
        }
    })
}

pub fn try_await(
    promise: Promise(Result(a, b)),
    callback: fn(a) -> Promise(Result(c, b))
) -> Promise(Result(c, b)) {
    promise.try_await(promise, callback)
}

pub fn raise_result(
    result: Result(a, b),
    callback: fn(a) -> Promise(Result(c, b))
) -> Promise(Result(c, b)) {
    case result {
        Ok(value) -> callback(value)
        Error(error) -> promise.resolve(Error(error))
    }
}

pub fn raise_promise(
    promise: Promise(a),
    callback: fn(a) -> Promise(Result(b, c))
) -> Promise(Result(b, c)) {
    promise.await(promise, callback)
}

pub fn return(x: a) -> Promise(Result(a, b)) {
    promise.resolve(Ok(x))
}
