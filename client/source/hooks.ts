import { useMediaQuery } from "@mantine/hooks"
import { useQuery } from "@tanstack/react-query"

export type User = {
    id: number,
    country: string,
    name: string,
}

export type Song = {
    id: number,
    game_song_id: number,
    title: string,
    bpm: string,
    'release_date': string,
    'cover': string,
    'cover_thumb': string,
    music: string,
}

const getUsers = async (query: string): Promise<User[]> => {
    if (query === '') return []
    const searchParams = new URLSearchParams({ query })
    const result = await fetch('/api/users?' + searchParams.toString())
    const data = await result.json()
    return data['players'] as User[]
}

export const useUsers = (query: string) => {
    return useQuery({
        queryKey: ['users', query],
        queryFn: () => getUsers(query),
    })
}

const getSongs = async (): Promise<Map<number, Song>> => {
    const result = await fetch('/api/songs')
    const data = await result.json()
    const songs = data['songs'] as Song[]

    return new Map(songs.map((song) => [song.id, song]))
}

export const useSongs = () => {
    return useQuery({
        queryKey: ['songs'],
        queryFn: getSongs,
        staleTime: Infinity,
        refetchOnMount: false,
        refetchInterval: false,
        refetchOnWindowFocus: false,
    })
}

export type Score = {
    id: number,
    gamer_id: number,
    song_chart_id: number,
    score: number,
    grade: number,
    max_combo: number,
    perfect1: number,
    perfect2: number,
    early: number,
    late: number,
    misses: number,
    green: number,
    yellow: number,
    red: number,
    steps: number,
    country: string,
    username: string,
    hex_color: string | null,
    picture_path: string | null,
    song_id: number,
    difficulty: number,
    difficulty_name: string,
    flags: number,
}

const getScores = async (
    difficulty: string,
    userId: number | null,
): Promise<Score[]> => {
    const searchParams = new URLSearchParams({
        difficulty,
        ...(userId ? { 'user_id': userId.toString() } : {}),
    })
    const result = await fetch('/api/highscores?' + searchParams.toString())
    const data = await result.json()
    return data['scores'] as Score[]
}

export const useScores = (difficulty: string, userId: number | null) => {
    return useQuery({
        queryKey: ['scores', difficulty, userId],
        queryFn: () => getScores(difficulty, userId),
    })
}

export type Unplayed = {
    id: number,
    song_id: number,
    difficulty: number,
    difficulty_name: string,
}

export const useUnplayed = (
    difficulty: string,
    played: Score[] | null,
): Unplayed[] | null => {
    const byOthers = useScores(difficulty, null)

    if (!played) return null
    if (!byOthers.data) return null

    // map(song -> set(difficulty))
    const playedCharts = new Map<number, Set<number>>()
    for (const score of played) {
        if (!playedCharts.has(score['song_id'])) {
            playedCharts.set(score['song_id'], new Set())
        }
        playedCharts.get(score['song_id'])?.add(score.difficulty)
    }

    const result = []
    for (const score of byOthers.data) {
        if (playedCharts.get(score['song_id'])?.has(score.difficulty)) {
            continue
        }

        result.push({
            id: score.id,
            song_id: score['song_id'],
            difficulty: score.difficulty,
            difficulty_name: score.difficulty_name,
        })
    }

    return result
}

export const useMobile = () => {
    return useMediaQuery(`(max-width: 900px)`);
}
