import gleam/dict
import gleam/dynamic
import gleam/json
import gleam/option.{type Option}
import gleam/int
import gleam/list
import gleam/result

import decoder

pub type Entries = List(#(String, json.Json))

pub type SignInRequest {
    SignInRequest(
        username: String,
        password: String,
    )
}

pub fn from_sign_in_req(data: SignInRequest) -> Entries {
    [
        #("account", json.string(data.username)),
        #("password", json.string(data.password)),
        #("noAuth", json.bool(True)),
    ]
}

pub type SignInResponse {
    SignInResponse(
        account_id: Int,
        token: String,
    )
}

pub fn to_sign_in_res(
    data: String,
) -> Result(SignInResponse, json.DecodeError) {
    let decoder = dynamic.decode2(
        SignInResponse,
        dynamic.field("account", of: dynamic.field("id", dynamic.int)),
        dynamic.field("auth_token", of: dynamic.string),
    )

    json.decode(from: data, using: decoder)
}

pub type Song {
    Song(
        id: Int,
        game_song_id: Int,
        is_enabled: Int,
        allow_edits: Int,
        title: String,
        subtitle: String,
        artist: String,
        genre: String,
        label: String,
        bpm: String,
        release_date: String,
        timing_bpms: String,
        timing_stops: String,
        timing_offset_ms: Int,
        first_beat: Float,
        last_beat: Float,
        first_ms: Int,
        last_ms: Int,
        cover_path: String,
        website: String,
        created_at: String,
        updated_at: String,
        cover: String,
        cover_thumb: String,
        music: String,
    )
}

fn song_decode() -> dynamic.Decoder(Song) {
    decoder.create_goal({
        use id <- decoder.parameter
        use game_song_id <- decoder.parameter
        use is_enabled <- decoder.parameter
        use allow_edits <- decoder.parameter
        use title <- decoder.parameter
        use subtitle <- decoder.parameter
        use artist <- decoder.parameter
        use genre <- decoder.parameter
        use label <- decoder.parameter
        use bpm <- decoder.parameter
        use release_date <- decoder.parameter
        use timing_bpms <- decoder.parameter
        use timing_stops <- decoder.parameter
        use timing_offset_ms <- decoder.parameter
        use first_beat <- decoder.parameter
        use last_beat <- decoder.parameter
        use first_ms <- decoder.parameter
        use last_ms <- decoder.parameter
        use cover_path <- decoder.parameter
        use website <- decoder.parameter
        use created_at <- decoder.parameter
        use updated_at <- decoder.parameter
        use cover <- decoder.parameter
        use cover_thumb <- decoder.parameter
        use music <- decoder.parameter

        decoder.return(Song(
            id: id,
            game_song_id: game_song_id,
            is_enabled: is_enabled,
            allow_edits: allow_edits,
            title: title,
            subtitle: subtitle,
            artist: artist,
            genre: genre,
            label: label,
            bpm: bpm,
            release_date: release_date,
            timing_bpms: timing_bpms,
            timing_stops: timing_stops,
            timing_offset_ms: timing_offset_ms,
            first_beat: first_beat,
            last_beat: last_beat,
            first_ms: first_ms,
            last_ms: last_ms,
            cover_path: cover_path,
            website: website,
            created_at: created_at,
            updated_at: updated_at,
            cover: cover,
            cover_thumb: cover_thumb,
            music: music,
        ))
    })
    |> decoder.solve(dynamic.field("id", dynamic.int))
    |> decoder.solve(dynamic.field("game_song_id", dynamic.int))
    |> decoder.solve(dynamic.field("is_enabled", dynamic.int))
    |> decoder.solve(dynamic.field("allow_edits", dynamic.int))
    |> decoder.solve(dynamic.field("title", dynamic.string))
    |> decoder.solve(dynamic.field("subtitle", dynamic.string))
    |> decoder.solve(dynamic.field("artist", dynamic.string))
    |> decoder.solve(dynamic.field("genre", dynamic.string))
    |> decoder.solve(dynamic.field("label", dynamic.string))
    |> decoder.solve(dynamic.field("bpm", dynamic.string))
    |> decoder.solve(dynamic.field("release_date", dynamic.string))
    |> decoder.solve(dynamic.field("timing_bpms", dynamic.string))
    |> decoder.solve(dynamic.field("timing_stops", dynamic.string))
    |> decoder.solve(dynamic.field("timing_offset_ms", dynamic.int))
    |> decoder.solve(dynamic.field("first_beat", dynamic.float))
    |> decoder.solve(dynamic.field("last_beat", dynamic.float))
    |> decoder.solve(dynamic.field("first_ms", dynamic.int))
    |> decoder.solve(dynamic.field("last_ms", dynamic.int))
    |> decoder.solve(dynamic.field("cover_path", dynamic.string))
    |> decoder.solve(dynamic.field("website", dynamic.string))
    |> decoder.solve(dynamic.field("created_at", dynamic.string))
    |> decoder.solve(dynamic.field("updated_at", dynamic.string))
    |> decoder.solve(dynamic.field("cover", dynamic.string))
    |> decoder.solve(dynamic.field("cover_thumb", dynamic.string))
    |> decoder.solve(dynamic.field("music", dynamic.string))
    |> decoder.to_decoder
}

pub fn to_songs_response(
    data: String,
) -> Result(List(Song), json.DecodeError) {
    json.decode(
        from: data,
        using: dynamic.field("songs", dynamic.list(song_decode())),
    )
}

pub type SearchRequest {
    SearchRequest(name: String)
}

pub fn from_search_req(data: SearchRequest) -> Entries {
    [
        #("search_string", json.string(data.name)),
    ]
}

pub type User {
    User(
        id: Int,
        country: String,
        username: String,
        hex_color: Option(String),
        picture_path: Option(String),
        description: Option(String),
        rival: Option(Int),
        private: Bool,
        published_edits: Int,
    )
}

pub fn user_decode() -> dynamic.Decoder(User) {
    decoder.create_goal({
        use id <- decoder.parameter
        use country <- decoder.parameter
        use username <- decoder.parameter
        use hex_color <- decoder.parameter
        use picture_path <- decoder.parameter
        use description <- decoder.parameter
        use rival <- decoder.parameter
        use private <- decoder.parameter
        use published_edits <- decoder.parameter

        decoder.return(User(
            id: id,
            country: country,
            username: username,
            hex_color: hex_color,
            picture_path: picture_path,
            description: description,
            rival: rival,
            private: private,
            published_edits: published_edits,
        ))
    })
    |> decoder.solve(dynamic.field("id", dynamic.int))
    |> decoder.solve(dynamic.field("country", dynamic.string))
    |> decoder.solve(dynamic.field("username", dynamic.string))
    |> decoder.solve(
        dynamic.field("hex_color", dynamic.optional(dynamic.string))
    )
    |> decoder.solve(
        dynamic.field("picture_path", dynamic.optional(dynamic.string))
    )
    |> decoder.solve(
        dynamic.field("description", dynamic.optional(dynamic.string))
    )
    |> decoder.solve(
        dynamic.field("rival", dynamic.optional(dynamic.int))
    )
    |> decoder.solve(dynamic.field("private", dynamic.bool))
    |> decoder.solve(dynamic.field("published_edits", dynamic.int))
    |> decoder.to_decoder
}

pub fn to_search_response(
    data: String,
) -> Result(List(User), json.DecodeError) {
    json.decode(
        from: data,
        using: dynamic.field("gamers", dynamic.list(user_decode())),
    )
}

pub type ScoreSearch {
    ScoreSearch(user_id: Int)
}

pub fn from_score_search_req(data: ScoreSearch) -> Entries {
    [
        #("gamer_id", json.int(data.user_id)),
        #("max_results", json.int(1000000)),
    ]
}

pub type Chart {
    Chart(
        id: Int,
        song_id: Int,
        difficulty_id: Int,
        game_difficulty_id: Int,
        steps_index: Int,
        is_enabled: Int,
        difficulty: Int,
        play_count: Int,
        pass_count: Int,
        difficulty_name: String,
        meter: Int,
    )
}

fn chart_decode() -> dynamic.Decoder(Chart) {
    decoder.create_goal({
        use id <- decoder.parameter
        use song_id <- decoder.parameter
        use difficulty_id <- decoder.parameter
        use game_difficulty_id <- decoder.parameter
        use steps_index <- decoder.parameter
        use is_enabled <- decoder.parameter
        use difficulty <- decoder.parameter
        use play_count <- decoder.parameter
        use pass_count <- decoder.parameter
        use difficulty_name <- decoder.parameter
        use meter <- decoder.parameter

        decoder.return(Chart(
            id: id,
            song_id: song_id,
            difficulty_id: difficulty_id,
            game_difficulty_id: game_difficulty_id,
            steps_index: steps_index,
            is_enabled: is_enabled,
            difficulty: difficulty,
            play_count: play_count,
            pass_count: pass_count,
            difficulty_name: difficulty_name,
            meter: meter,
        ))
    })
    |> decoder.solve(dynamic.field("id", dynamic.int))
    |> decoder.solve(dynamic.field("song_id", dynamic.int))
    |> decoder.solve(dynamic.field("difficulty_id", dynamic.int))
    |> decoder.solve(dynamic.field("game_difficulty_id", dynamic.int))
    |> decoder.solve(dynamic.field("steps_index", dynamic.int))
    |> decoder.solve(dynamic.field("is_enabled", dynamic.int))
    |> decoder.solve(dynamic.field("difficulty", dynamic.int))
    |> decoder.solve(dynamic.field("play_count", dynamic.int))
    |> decoder.solve(dynamic.field("pass_count", dynamic.int))
    |> decoder.solve(dynamic.field("difficulty_name", dynamic.string))
    |> decoder.solve(dynamic.field("meter", dynamic.int))
    |> decoder.to_decoder
}

pub fn to_charts_response(
    data: String,
) -> Result(List(Chart), json.DecodeError) {
    result.map(
        json.decode(
            from: data,
            using: dynamic.field(
                "charts",
                dynamic.dict(
                    of: dynamic.string,
                    to: chart_decode(),
                ),
            ),
        ),
        dict.values,
    )
}

pub type Score {
    Score(
        id: Int,
        gamer_id: Int,
        song_chart_id: Int,
        score: Int,
        uuid: String,
        grade: Int,
        max_combo: Int,
        music_speed: Option(Int),
        calories: Int,
        perfect1: Int,
        perfect2: Int,
        early: Int,
        late: Int,
        misses: Int,
        flags: Int,
        global_flags: Int,
        green: Int,
        yellow: Int,
        red: Int,
        steps: Int,

        // difficulty name is omitted for simplicity
        // (because highscore endpoint does not return it)
    )
}

fn score_decode() -> dynamic.Decoder(Score) {
    decoder.create_goal({
        use id <- decoder.parameter
        use gamer_id <- decoder.parameter
        use song_chart_id <- decoder.parameter
        use score <- decoder.parameter
        use uuid <- decoder.parameter
        use grade <- decoder.parameter
        use max_combo <- decoder.parameter
        use music_speed <- decoder.parameter
        use calories <- decoder.parameter
        use perfect1 <- decoder.parameter
        use perfect2 <- decoder.parameter
        use early <- decoder.parameter
        use late <- decoder.parameter
        use misses <- decoder.parameter
        use flags <- decoder.parameter
        use global_flags <- decoder.parameter
        use green <- decoder.parameter
        use yellow <- decoder.parameter
        use red <- decoder.parameter
        use steps <- decoder.parameter

        decoder.return(Score(
            id: id,
            gamer_id: gamer_id,
            song_chart_id: song_chart_id,
            score: score,
            uuid: uuid,
            grade: grade,
            max_combo: max_combo,
            music_speed: music_speed,
            calories: calories,
            perfect1: perfect1,
            perfect2: perfect2,
            early: early,
            late: late,
            misses: misses,
            flags: flags,
            global_flags: global_flags,
            green: green,
            yellow: yellow,
            red: red,
            steps: steps,
        ))
    })
    |> decoder.solve(dynamic.field("id", dynamic.int))
    |> decoder.solve(dynamic.field("gamer_id", dynamic.int))
    |> decoder.solve(dynamic.field("song_chart_id", dynamic.int))
    |> decoder.solve(dynamic.field("score", dynamic.int))
    |> decoder.solve(dynamic.field("uuid", dynamic.string))
    |> decoder.solve(dynamic.field("grade", dynamic.int))
    |> decoder.solve(dynamic.field("max_combo", dynamic.int))
    |> decoder.solve(
        dynamic.field("music_speed", dynamic.optional(dynamic.int))
    )
    |> decoder.solve(dynamic.field("calories", dynamic.int))
    |> decoder.solve(dynamic.field("perfect1", dynamic.int))
    |> decoder.solve(dynamic.field("perfect2", dynamic.int))
    |> decoder.solve(dynamic.field("early", dynamic.int))
    |> decoder.solve(dynamic.field("late", dynamic.int))
    |> decoder.solve(dynamic.field("misses", dynamic.int))
    |> decoder.solve(dynamic.field("flags", dynamic.int))
    |> decoder.solve(dynamic.field("global_flags", dynamic.int))
    |> decoder.solve(dynamic.field("green", dynamic.int))
    |> decoder.solve(dynamic.field("yellow", dynamic.int))
    |> decoder.solve(dynamic.field("red", dynamic.int))
    |> decoder.solve(dynamic.field("steps", dynamic.int))
    |> decoder.to_decoder
}

pub fn to_history_response(
    data: String,
) -> Result(List(Score), json.DecodeError) {
    json.decode(
        from: data,
        using: dynamic.field(
            "history",
            dynamic.list(score_decode()),
        )
    )
}

pub type HighscoreData {
    HighscoreData(
        scores: dict.Dict(String, Score),
        players: dict.Dict(String, User),
        charts: dict.Dict(String, Chart),
    )
}

pub fn to_highscores_response(
    data: String,
) -> Result(HighscoreData, json.DecodeError) {
    json.decode(
        from: data,
        using: dynamic.decode3(
            HighscoreData,
            dynamic.field(
                "scores",
                // honestly just to handle the empty array cases
                dynamic.any([
                    dynamic.decode1(
                        fn (data: List(Score)) {
                            dict.from_list({
                                use element <- list.map(data)
                                #(int.to_string(element.id), element)
                            })
                        },
                        dynamic.list(score_decode()),
                    ),
                    dynamic.dict(
                        of: dynamic.string,
                        to: score_decode(),
                    ),
                ]),
            ),
            dynamic.field(
                "gamers",
                dynamic.any([
                    dynamic.decode1(
                        fn (data: List(User)) {
                            dict.from_list({
                                use element <- list.map(data)
                                #(int.to_string(element.id), element)
                            })
                        },
                        dynamic.list(user_decode()),
                    ),
                    dynamic.dict(
                        of: dynamic.string,
                        to: user_decode(),
                    ),
                ]),
            ),
            dynamic.field(
                "charts",
                dynamic.any([
                    dynamic.decode1(
                        fn (data: List(Chart)) {
                            dict.from_list({
                                use element <- list.map(data)
                                #(int.to_string(element.id), element)
                            })
                        },
                        dynamic.list(chart_decode()),
                    ),
                    dynamic.dict(
                        of: dynamic.string,
                        to: chart_decode(),
                    ),
                ]),
            ),
        ),
    )
}
