import { Paper, Image, Stack, Text } from '@mantine/core'
import { Song } from '../hooks'
import { FlagData } from '../util'

const capitalized = (s: string) => s.charAt(0).toUpperCase() + s.slice(1)

export type RenderableScore = {
    id: number
    song_id: number
    score: string
    difficulty: number
    flags: FlagData
    username?: string
    difficulty_name: string
}

export const ScoreCard = ({
    songs,
    score,
    small,
}: {
    songs: Map<number, Song>
    score: RenderableScore
    small?: boolean
}) => {
    const mobile = small
    const imageSize = mobile ? '3rem' : '5rem'
    const bigText = mobile ? 'md' : 'xl'
    const smallText = mobile ? 'sm' : 'md'

    const song = songs.get(score.song_id)
    if (!song)
        return (
            <Paper withBorder p="xs">
                No song found
            </Paper>
        )

    const difficulty = score['difficulty_name']
    return (
        <Paper withBorder p="xs" w="100%">
            <div
                style={{
                    display: 'grid',
                    gridTemplateColumns: `${imageSize} minmax(0, 1fr) auto`,
                    gap: '1rem',
                    width: '100%',
                }}
            >
                <Image radius="xs" src={song.cover_thumb} />
                <Stack gap={1} w="100%">
                    <Text
                        fw={700}
                        size={bigText}
                        w="100%"
                        style={{
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                            overflow: 'hidden',
                        }}
                    >
                        {song.title}
                    </Text>
                    <Text size={smallText}>
                        {capitalized(difficulty)} {score.difficulty}
                    </Text>
                </Stack>
                <Stack gap={1} align="end">
                    <Text
                        size={bigText}
                        {...(score.flags.cleared ? {} : { c: 'dimmed' })}
                    >
                        {score.score}
                    </Text>
                    <Text size={smallText}>{score.username}</Text>
                </Stack>
            </div>
        </Paper>
    )
}
