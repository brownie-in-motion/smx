import { FilterState } from './components/filters'
import { RenderableScore } from './components/score-card'
import { Score, Song, Unplayed } from './hooks'
import { tags } from './data'

export type FlagData = {
    cleared: boolean
}

export const decodeFlag = (flag: number): FlagData => {
    return {
        cleared: (flag & 0b1) === 0b1,
    }
}

const compareBy = (
    songs: Map<number, Song>,
    kind: string,
    a: Score | Unplayed,
    b: Score | Unplayed,
): number => {
    if (kind === 'Title') {
        const songA = songs.get(a.song_id)!.title
        const songB = songs.get(b.song_id)!.title
        return songA.localeCompare(songB)
    } else if (kind === 'Difficulty') {
        return a.difficulty - b.difficulty
    } else {
        const scoreA = 'score' in a ? a.score : 0
        const scoreB = 'score' in b ? b.score : 0
        return scoreA - scoreB
    }
}

const checkTags = (selected: string[], score: Score | Unplayed): boolean => {
    if (selected.length === 0) return true
    for (const tag of selected) {
        if (tags.get(tag)?.has(score['song_id'])) return true
    }
    return false
}

export const filterCharts = (
    difficulty: string,
    songs: Map<number, Song>,
    charts: Score[],
    unplayed: Unplayed[],
    filter: FilterState,
): RenderableScore[] => {
    const filteredPlayed = charts.filter((score) => {
        if (score.score < filter.scoreRange[0]) return false
        if (score.score > filter.scoreRange[1]) return false
        if (score.difficulty < filter.difficultyRange[0]) return false
        if (score.difficulty > filter.difficultyRange[1]) return false

        const flags = decodeFlag(score.flags)
        if (filter.cleared === 'cleared' && !flags.cleared) return false
        if (filter.cleared === 'failed' && flags.cleared) return false

        if (!checkTags(filter.tags, score)) return false

        return true
    })

    const filteredUnplayed = unplayed.filter((unplayed) => {
        // there's disagreement about difficulty naming
        // if (unplayed['difficulty_name'] !== difficulty) return false

        if (0 < filter.scoreRange[0]) return false
        if (0 > filter.scoreRange[1]) return false
        if (unplayed.difficulty < filter.difficultyRange[0]) return false
        if (unplayed.difficulty > filter.difficultyRange[1]) return false

        if (filter.cleared === 'cleared') return false

        if (!checkTags(filter.tags, unplayed)) return false

        return true
    })

    const all: (Score | Unplayed)[] = []
    if (filter.charts === 'all') {
        all.push(...filteredPlayed)
        all.push(...filteredUnplayed)
    } else if (filter.charts === 'played') {
        all.push(...filteredPlayed)
    } else {
        all.push(...filteredUnplayed)
    }

    all.sort((a, b) => {
        let primaryResult = compareBy(songs, filter.primary, a, b)
        if (!filter.primaryAsc) primaryResult *= -1
        if (primaryResult !== 0) return primaryResult

        let secondaryResult = compareBy(songs, filter.secondary, a, b)
        if (!filter.secondaryAsc) secondaryResult *= -1
        return secondaryResult
    })

    return all.map((score) => ({
        id: score.id,
        'song_id': score['song_id'],
        score: 'score' in score ? score.score.toString() : 'No score',
        difficulty: score.difficulty,
        flags: decodeFlag('flags' in score ? score.flags : 0),
        username: 'username' in score ? score.username : null,
        'difficulty_name': difficulty, // score['difficulty_name'],
    }))
}
