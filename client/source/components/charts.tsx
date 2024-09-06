import {
    Center,
    ScrollArea,
    Stack,
    Tabs,
    TabsProps,
    ThemeIcon,
} from '@mantine/core'
import {
    IconBolt,
    IconCrown,
    IconHexagonMinus,
    IconSchool,
    IconShield,
    IconSkull,
} from '@tabler/icons-react'
import { useMobile, useScores, useSongs, useUnplayed } from '../hooks'
import { filterCharts } from '../util'
import { ScoreCard } from './score-card'
import { useState } from 'react'
import { FilterState } from './filters'

const BorderlessThemeIcon = ({
    children,
    ...others
}: {
    children: React.ReactNode
    [key: string]: any
}) => {
    return (
        <ThemeIcon
            variant="outline"
            style={{ border: 'none' }}
            size="sm"
            {...others}
        >
            {children}
        </ThemeIcon>
    )
}

const difficulties = [
    { value: 'beginner', color: 'green', icon: <IconSchool /> },
    { value: 'easy', color: 'yellow', icon: <IconShield /> },
    { value: 'hard', color: 'red', icon: <IconBolt /> },
    { value: 'wild', color: 'purple', icon: <IconCrown /> },
    { value: 'dual', color: 'blue', icon: <IconHexagonMinus /> },
    { value: 'full', color: 'cyan', icon: <IconSkull /> },
]

export const Charts = ({
    userId,
    filter,
    ...others
}: {
    userId?: number | null
    filter: FilterState
} & TabsProps) => {
    const small = useMobile()
    const songs = useSongs()
    const [tab, setTab] = useState<string>(difficulties[0].value)
    const scores = useScores(tab, userId)
    const unplayed = useUnplayed(tab, scores.data)

    const drawCharts = () => {
        const charts = filterCharts(
            tab,
            songs.data,
            scores.data ?? [],
            unplayed ?? [],
            filter,
        ).map((score) => (
            <ScoreCard
                small={small}
                songs={songs.data}
                score={score}
                key={score.id}
            />
        ))

        if (charts.length === 0) {
            return <Center>No scores found.</Center>
        }

        return charts
    }

    const inner = (
        <Stack mt={0} gap="sm">
            {!songs.data || scores.isLoading || scores.isError || !unplayed ? (
                <Center>Loading...</Center>
            ) : (
                drawCharts()
            )}
        </Stack>
    )

    return (
        <Tabs
            variant="default"
            value={tab}
            onChange={setTab}
            color={difficulties[0].color}
            {...others}
        >
            <Stack h="100%">
                <Tabs.List>
                    {difficulties.map((difficulty) => (
                        <Tabs.Tab
                            key={difficulty.value}
                            value={difficulty.value}
                            color={difficulty.color}
                            p="sm"
                        >
                            <BorderlessThemeIcon color={difficulty.color}>
                                {difficulty.icon}
                            </BorderlessThemeIcon>
                        </Tabs.Tab>
                    ))}
                </Tabs.List>

                <ScrollArea
                    offsetScrollbars
                    scrollbars="y"
                    style={{
                        flexGrow: 1,
                        minHeight: 0,
                    }}
                >
                    {inner}
                </ScrollArea>
            </Stack>
        </Tabs>
    )
}
