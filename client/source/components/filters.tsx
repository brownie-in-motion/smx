import {
    Button,
    Group,
    MultiSelect,
    Rating,
    ScrollArea,
    SegmentedControl,
    Text,
} from '@mantine/core'
import { ratings, tags } from '../data'

export const sortOptions = ['Title', 'Score', 'Difficulty']

export type FilterState = {
    scoreRange: [number, number]
    difficultyRange: [number, number]
    charts: 'all' | 'played' | 'unplayed'
    cleared: 'all' | 'cleared' | 'failed'
    primary: string
    primaryAsc: boolean
    secondary: string
    secondaryAsc: boolean
    tags: string[]
}

export const defaultFilter = (): FilterState => ({
    scoreRange: [0, 100000],
    difficultyRange: [1, 27],
    charts: 'all',
    cleared: 'all',
    primary: 'Difficulty',
    primaryAsc: true,
    secondary: 'Title',
    secondaryAsc: true,
    tags: [],
})

const toExactLowStars = (filter: FilterState): number | null => {
    const [low, high] = filter.scoreRange
    if (low !== 0 || !ratings.includes(high + 1)) return null
    return ratings.indexOf(high + 1) + 2
}

const toExactHighStars = (filter: FilterState): number | null => {
    const [low, high] = filter.scoreRange
    if (high !== 100_000 || !ratings.includes(low)) return null
    return ratings.indexOf(low) + 2
}

import {
    Accordion,
    Divider,
    Stack,
    RangeSlider,
    Select,
    Checkbox,
} from '@mantine/core'
import { useCallback, useState } from 'react'

export const Filters = ({
    filter,
    setFilter,
}: {
    filter: FilterState
    setFilter: (filter: FilterState) => void
}) => {
    const [lowStars, highStars] = [
        toExactLowStars(filter),
        toExactHighStars(filter),
    ]

    const [active, setActive] = useState(false)

    const value = active ? 'filter' : null
    const onChange = useCallback((value: string | null) => {
        setActive(value === 'filter')
    }, [])

    const inner = (
        <Stack pb={1}>
            {' '}
            {/* need some padding for scrollbar interactions */}
            <Divider />
            <Stack gap="xs">
                <Text size="md">Score range</Text>
                <RangeSlider
                    minRange={1000}
                    min={0}
                    max={100000}
                    step={1000}
                    value={filter.scoreRange}
                    onChange={(value) =>
                        setFilter({
                            ...filter,
                            scoreRange: value,
                        })
                    }
                />
                <Stack gap="xs">
                    <Group gap="xs">
                        <Text size="sm">Less than</Text>
                        <Rating
                            count={6}
                            value={lowStars}
                            onChange={(value) => {
                                if (value < 2) return
                                const score = ratings[value - 2]
                                setFilter({
                                    ...filter,
                                    scoreRange: [0, score - 1],
                                })
                            }}
                        />
                    </Group>
                    <Group gap="xs">
                        <Text size="sm">...or at least</Text>
                        <Rating
                            count={6}
                            value={highStars}
                            onChange={(value) => {
                                if (value < 2) return
                                const score = ratings[value - 2]
                                setFilter({
                                    ...filter,
                                    scoreRange: [score, 100_000],
                                })
                            }}
                        />
                    </Group>
                </Stack>
            </Stack>
            <Stack gap="xs">
                <Text size="md">Difficulty range</Text>
                <RangeSlider
                    minRange={0}
                    min={1}
                    max={27}
                    step={1}
                    value={filter.difficultyRange}
                    onChange={(value) =>
                        setFilter({
                            ...filter,
                            difficultyRange: value,
                        })
                    }
                />
            </Stack>
            <Stack gap="xs">
                <Text size="md">Played status</Text>
                <SegmentedControl
                    value={filter.charts}
                    data={[
                        { label: 'Any', value: 'all' },
                        { label: 'Played', value: 'played' },
                        { label: 'Unplayed', value: 'unplayed' },
                    ]}
                    onChange={(value: 'all' | 'played' | 'unplayed') =>
                        setFilter({
                            ...filter,
                            charts: value,
                        })
                    }
                />
            </Stack>
            <Stack gap="xs">
                <Text size="md">Cleared status</Text>
                <SegmentedControl
                    value={filter.cleared}
                    data={[
                        { label: 'Any', value: 'all' },
                        { label: 'Cleared', value: 'cleared' },
                        { label: 'Failed', value: 'failed' },
                    ]}
                    onChange={(value: 'all' | 'cleared' | 'failed') =>
                        setFilter({
                            ...filter,
                            cleared: value,
                        })
                    }
                />
            </Stack>
            <Stack gap="xs">
                <Text size="md">Song tags</Text>
                <MultiSelect
                    data={Array.from(tags.keys())}
                    value={filter.tags}
                    onChange={(value: string[]) =>
                        setFilter({
                            ...filter,
                            tags: value,
                        })
                    }
                />
            </Stack>
            <Divider />
            <Stack gap="xs">
                <Text size="md">Sort first by...</Text>
                <Select
                    allowDeselect={false}
                    value={filter.primary}
                    data={sortOptions}
                    onChange={(value) => {
                        let secondary = filter.secondary
                        if (value === filter.secondary) {
                            secondary =
                                sortOptions.find((item) => item !== value) ??
                                null
                        }
                        setFilter({
                            ...filter,
                            primary: value,
                            secondary,
                        })
                    }}
                />
                <Checkbox
                    checked={filter.primaryAsc}
                    onChange={() =>
                        setFilter({
                            ...filter,
                            primaryAsc: !filter.primaryAsc,
                        })
                    }
                    label="Ascending?"
                />
            </Stack>
            <Stack gap="xs">
                <Text size="md">And if they're the same, by...</Text>
                <Select
                    allowDeselect={false}
                    value={filter.secondary}
                    data={sortOptions.filter((item) => item !== filter.primary)}
                    onChange={(value) =>
                        setFilter({
                            ...filter,
                            secondary: value,
                        })
                    }
                />
                <Checkbox
                    checked={filter.secondaryAsc}
                    onChange={() =>
                        setFilter({
                            ...filter,
                            secondaryAsc: !filter.secondaryAsc,
                        })
                    }
                    label="Ascending?"
                />
            </Stack>
            <Button onClick={() => setActive(false)}>Close</Button>
            <Button
                onClick={() => setFilter(defaultFilter())}
                color="red"
                variant="outline"
            >
                Reset filters
            </Button>
        </Stack>
    )

    return (
        <Accordion
            variant="contained"
            value={value}
            onChange={onChange}
            styles={{
                content: {
                    maxHeight: 400,
                },
            }}
        >
            <Accordion.Item value="filter">
                <Accordion.Control>
                    <Text size="lg" w={700}>
                        Sort and filter
                    </Text>
                </Accordion.Control>
                <Accordion.Panel mah="100%" pb="lg">
                    <ScrollArea
                        className="scrollarea-inherit"
                        scrollbars="y"
                        mah="inherit"
                        offsetScrollbars
                    >
                        {inner}
                    </ScrollArea>
                </Accordion.Panel>
            </Accordion.Item>
        </Accordion>
    )
}
