import gleam/dict
import gleam/http
import gleam/int
import gleam/io
import gleam/javascript/promise.{type Promise}
import gleam/json
import gleam/list
import gleam/option
import gleam/string
import gleam/result

import glen.{type Request, type Response}
import glen/status

import client
import schemas
import transformer

pub fn server(data: client.AuthData) -> fn(Request) -> Promise(Response) {
    fn (req: Request) {
        use <- glen.log(req)
        use <- glen.rescue_crashes
        use <- glen.static(req, "build", "./client/build")

        case glen.path_segments(req) {
            [] -> index_page(req)
            ["api", "users"] -> users_endpoint(data, req)
            ["api", "songs"] -> songs_endpoint(data, req)
            // ["api", "unplayed"] -> unplayed_songs_endpoint(data, req)
            ["api", "highscores"] -> global_highscores_endpoint(
                data,
                req,
            )
            _ -> promise.resolve(glen.text("not found", status.not_found))
        }
    }
}

fn index_page(req: Request) -> Promise(Response) {
    use <- glen.require_method(req, http.Get)
    promise.resolve(glen.file("./client/static/index.html", status.ok))
}

fn users_endpoint(auth: client.AuthData, req: Request) -> Promise(Response) {
    use <- glen.require_method(req, http.Get)

    let out: Promise(Result(json.Json, #(String, Int))) = {
        let query = dict.from_list(glen.get_query(req))

        use query <- transformer.raise_result({
            use _ <- result.map_error(dict.get(query, "query"))
            #("missing query parameter", status.bad_request)
        })

        use output <- promise.map(client.search_players(query, auth))
        use output <- result.map(result.map_error(
            output,
            fn (e) {
                io.debug(e)
                #("failed to search players", status.internal_server_error)
            }
        ))

        json.object([
            #("players", json.array(
                from: output,
                of: fn (player) {
                    json.object([
                        #("id", json.int(player.id)),
                        #("name", json.string(player.username))
                    ])
                },
            ))
        ])
    }

    use result <- promise.map(out)
    case result {
        Ok(json) -> glen.json(json.to_string(json), status.ok)
        Error(#(err, code)) -> glen.json(
            json.object([
                #("error", json.string(err)),
            ])
            |> json.to_string(),
            code
        )
    }
}

fn format_url(path: String) {
    string.concat([
        "https://",
        client.endpoint,
        "/",
        path,
    ])
}

fn songs_endpoint(auth: client.AuthData, req: Request) -> Promise(Response) {
    use <- glen.require_method(req, http.Get)

    let out: Promise(Result(json.Json, #(String, Int))) = {
        use output <- promise.map(client.list_songs(auth))
        use output <- result.map(result.map_error(
            output,
            fn (e) {
                io.debug(e)
                #("failed to search players", status.internal_server_error)
            }
        ))

        json.object([
            #("songs", json.array(
                from: output,
                of: fn (song) {
                    json.object([
                        #("id", json.int(song.id)),
                        #("game_song_id", json.int(song.game_song_id)),
                        #("title", json.string(song.title)),
                        #("bpm", json.string(song.bpm)),
                        #("release_date", json.string(song.release_date)),
                        #(
                            "cover",
                            json.string(format_url(song.cover))
                        ),
                        #(
                            "cover_thumb",
                            json.string(format_url(song.cover_thumb))
                        ),
                        #(
                            "music",
                            json.string(format_url(song.music))
                        ),
                    ])
                },
            ))
        ])
    }

    use result <- promise.map(out)
    case result {
        Ok(json) -> glen.json(json.to_string(json), status.ok)
        Error(#(err, code)) -> glen.json(
            json.object([
                #("error", json.string(err)),
            ])
            |> json.to_string(),
            code
        )
    }
}

fn build_highscore_json(
    data: schemas.HighscoreData
) -> Result(json.Json, Nil) {
    let schemas.HighscoreData(scores, players, charts) = data

    let list: Result(List(json.Json), Nil) = {
        use score <- list.try_map(dict.values(scores))

        use player <- result.try(
            dict.get(
                players,
                int.to_string(score.gamer_id),
            )
        )

        use chart <- result.map(
            dict.get(
                charts,
                int.to_string(score.song_chart_id),
            )
        )

        json.object([
            #("id", json.int(score.id)),
            #("gamer_id", json.int(score.gamer_id)),
            #("song_chart_id", json.int(score.song_chart_id)),
            #("score", json.int(score.score)),
            #("grade", json.int(score.grade)),
            #("max_combo", json.int(score.max_combo)),
            #("perfect1", json.int(score.perfect1)),
            #("perfect2", json.int(score.perfect2)),
            #("early", json.int(score.early)),
            #("late", json.int(score.late)),
            #("misses", json.int(score.misses)),
            #("green", json.int(score.green)),
            #("yellow", json.int(score.yellow)),
            #("red", json.int(score.red)),
            #("steps", json.int(score.steps)),
            #("country", json.string(player.country)),
            #("username", json.string(player.username)),
            #("hex_color", json.nullable(
                from: player.hex_color,
                of: json.string
            )),
            #("picture_path", json.nullable(
                from: player.picture_path,
                of: json.string,
            )),
            #("song_id", json.int(chart.song_id)),
            #("difficulty", json.int(chart.difficulty)),
            #("difficulty_name", json.string(chart.difficulty_name)),
            #("flags", json.int(score.flags)),
        ])
    }

    use inner <- result.map(list)

    json.object([
        #("scores", json.array(from: inner, of: fn (x) { x })),
    ])
}

fn global_highscores_endpoint(
    auth: client.AuthData,
    req: Request,
) -> Promise(Response) {
    use <- glen.require_method(req, http.Get)

    let out: Promise(Result(json.Json, #(String, Int))) = {
        let params = dict.from_list(glen.get_query(req))

        use query <- transformer.raise_result({
            use _ <- result.map_error(dict.get(params, "difficulty"))
            #("missing query parameter", status.bad_request)
        })

        use query <- transformer.raise_result(
            case query {
                "beginner" -> Ok(client.Beginner)
                "easy" -> Ok(client.Easy)
                "hard" -> Ok(client.Hard)
                "wild" -> Ok(client.Wild)
                "dual" -> Ok(client.Dual)
                "full" -> Ok(client.Full)
                _ -> Error(#("invalid difficulty", status.bad_request))
            }
        )

        let user = dict.get(params, "user_id")
            |> result.try(int.parse)
            |> option.from_result

        use output <- promise.map(client.list_high_scores(query, user, auth))
        use output <- result.try(result.map_error(
            output,
            fn (e) {
                io.debug(e)
                #("failed to find high scores", status.internal_server_error)
            }
        ))

        use _ <- result.map_error(build_highscore_json(output))
        #("received invalid data", status.internal_server_error)
    }

    use result <- promise.map(out)
    case result {
        Ok(json) -> {
            glen.json(json.to_string(json), status.ok)
        }
        Error(#(err, code)) -> glen.json(
            json.object([
                #("error", json.string(err)),
            ])
            |> json.to_string(),
            code
        )
    }
}

// not real
// fn unplayed_songs_endpoint(
//     auth: client.AuthData,
//     req: Request,
// ) -> Promise(Response) {
//     use <- glen.require_method(req, http.Get)
// 
//     let out: Promise(Result(json.Json, #(String, Int))) = {
//         use user_id <- transformer.raise_result({
//             use _ <- result.map_error(
//                 glen.get_query(req)
//                     |> dict.from_list
//                     |> dict.get("user_id")
//                     |> result.try(int.parse)
//             )
//             #("bad query parameter", status.bad_request)
//         })
// 
//         use charts <- promise.map(client.list_unplayed_charts(user_id, auth))
//         use charts <- result.map(result.map_error(
//             charts,
//             fn (e) {
//                 io.debug(e)
//                 #("failed to list songs", status.internal_server_error)
//             }
//         ))
// 
//         json.object([
//             #("unplayed", json.array(
//                 from: charts,
//                 of: fn (chart) {
//                     json.object([
//                         #("id", json.int(chart.id)),
//                         #("song_id", json.int(chart.song_id)),
//                         #("difficulty", json.int(chart.difficulty)),
//                         #(
//                             "difficulty_name",
//                             json.string(chart.difficulty_name),
//                         ),
//                     ])
//                 },
//             ))
//         ])
//     }
// 
//     use result <- promise.map(out)
//     case result {
//         Ok(json) -> glen.json(json.to_string(json), status.ok)
//         Error(#(err, code)) -> glen.json(
//             json.object([
//                 #("error", json.string(err)),
//             ])
//             |> json.to_string(),
//             code
//         )
//     }
// }
