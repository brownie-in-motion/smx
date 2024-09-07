import gleam/fetch
import gleam/http
import gleam/http/request
import gleam/option.{type Option, None, Some}
import gleam/int
import gleam/io
import gleam/javascript/promise.{type Promise}
import gleam/json
import gleam/list
import gleam/result

import schemas

pub const endpoint = "data.stepmaniax.com"

pub opaque type AuthData {
    AuthData(id: Int, token: String, uuid: String)
}

pub type ClientError {
    FetchError(fetch.FetchError)
    DecodeError(json.DecodeError)
}

fn lift_fetch(
    x: Promise(Result(a, fetch.FetchError))
) -> Promise(Result(a, ClientError)) {
    promise.map(x, fn (y) { result.map_error(y, FetchError) })
}

fn lift_parse(
    x: Result(a, json.DecodeError)
) -> Result(a, ClientError) {
    result.map_error(x, DecodeError)
}

fn fetch_data(
    path: String,
    data: schemas.Entries,
    // using Result as coproduct but this might not be idiomatic
    auth: Result(AuthData, String),
    query: List(#(String, String))
) -> request.Request(String) {
    let data = list.concat([
        data,
        case auth {
            Error(uuid) -> [
                #("uuid", json.string(uuid)),
                #("noAuth", json.bool(True)),
            ]
            Ok(AuthData(id, token, uuid)) -> [
                #("auth_gamer", json.int(id)),
                #("auth_token", json.string(token)),
                #("uuid", json.string(uuid)),
            ]
        },
    ])

    request.set_query(
        request.Request(
            http.Post,
            [#("content-type", "application/json")],
            json.to_string(json.object(data)),
            http.Https,
            endpoint,
            None,
            path,
            None,
        ),
        query,
    )
}

pub fn generate_auth(
    uuid: String,
    username: String,
    password: String,
) -> Promise(Result(AuthData, ClientError)) {
    let data = schemas.SignInRequest(username, password)

    let req = fetch_data(
        "/sign/in",
        schemas.from_sign_in_req(data),
        Error(uuid),
        [],
    )

    use resp <- promise.try_await(fetch.send(req) |> lift_fetch)
    use resp <- promise.map_try(fetch.read_text_body(resp) |> lift_fetch)
    use resp <- result.map(schemas.to_sign_in_res(resp.body) |> lift_parse)

    AuthData(resp.account_id, resp.token, uuid)
}

pub fn list_songs(
    auth: AuthData,
) -> Promise(Result(List(schemas.Song), ClientError)) {
    let req = fetch_data("/song/list", [], Ok(auth), [])

    use resp <- promise.try_await(fetch.send(req) |> lift_fetch)
    use resp <- promise.map_try(fetch.read_text_body(resp) |> lift_fetch)

    schemas.to_songs_response(resp.body) |> lift_parse
}

pub fn search_players(
    search: String,
    auth: AuthData,
) -> Promise(Result(List(schemas.User), ClientError)) {
    let data = schemas.SearchRequest(search)

    let req = fetch_data(
        "/gamer/search",
        schemas.from_search_req(data),
        Ok(auth),
        [],
    )

    use resp <- promise.try_await(fetch.send(req) |> lift_fetch)
    use resp <- promise.map_try(fetch.read_text_body(resp) |> lift_fetch)

    schemas.to_search_response(resp.body) |> lift_parse
}

pub fn list_unplayed_charts(
    user_id: Int,
    auth: AuthData,
) -> Promise(Result(List(schemas.Chart), ClientError)) {
    let data = schemas.ScoreSearch(user_id)

    let req = fetch_data(
        "/gamer/score/unplayed",
        schemas.from_score_search_req(data),
        Ok(auth),
        [],
    )

    use resp <- promise.try_await(fetch.send(req) |> lift_fetch)
    use resp <- promise.map_try(fetch.read_text_body(resp) |> lift_fetch)

    io.println(resp.body)

    schemas.to_charts_response(resp.body) |> lift_parse
}

pub fn list_scores(
    user_id: Int,
    auth: AuthData,
) -> Promise(Result(List(schemas.Score), ClientError)) {
    let data = schemas.ScoreSearch(user_id)

    let req = fetch_data(
        "/gamer/score/history",
        schemas.from_score_search_req(data),
        Ok(auth),
        [],
    )

    use resp <- promise.try_await(fetch.send(req) |> lift_fetch)
    use resp <- promise.map_try(fetch.read_text_body(resp) |> lift_fetch)

    schemas.to_history_response(resp.body) |> lift_parse
}

pub type Difficulty {
    Beginner
    Easy
    Hard
    Wild
    Dual
    Full
}

pub fn list_high_scores(
    difficulty: Difficulty,
    user_id: Option(Int),
    auth: AuthData,
) -> Promise(Result(schemas.HighscoreData, ClientError)) {
    let difficulty = case difficulty {
        Beginner -> "beginner"
        Easy -> "easy"
        Hard -> "hard"
        Wild -> "wild"
        Dual -> "dual"
        Full -> "full"
    }

    let req = case user_id {
        Some(id) -> fetch_data(
            "/highscores/users/" <> int.to_string(id) <> "/" <> difficulty,
            [],
            Ok(auth),
            [],
        )
        None -> fetch_data(
            "/highscores/region/all/" <> difficulty,
            [],
            Ok(auth),
            [],
        )
    }

    use resp <- promise.try_await(fetch.send(req) |> lift_fetch)
    use resp <- promise.map_try(fetch.read_text_body(resp) |> lift_fetch)

    schemas.to_highscores_response(resp.body) |> lift_parse
}
