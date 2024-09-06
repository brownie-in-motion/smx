import gleam/io
import gleam/javascript/promise
import gleam/result

import envoy
import glen

import client
import server
import transformer

pub fn main() {
    use #(username, password) <- transformer.raise_result({
        use error <- result.map_error({
            use username <- result.try(envoy.get("USERNAME"))
            use password <- result.map(envoy.get("PASSWORD"))

            #(username, password)
        })

        io.println("Missing username and password")

        error
    })

    use auth <- transformer.try_await({
        use e <- transformer.map_error(
            client.generate_auth(username, password)
        )
        io.println("Error generating auth")
        io.debug(e)
        promise.resolve(Nil)
    })

    glen.serve(3000, server.server(auth))
    transformer.return(Nil)
}
