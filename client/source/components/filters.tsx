import { Button, MultiSelect, SegmentedControl, Text } from '@mantine/core'
import { tags } from '../data'

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


import {
    Accordion,
    Divider,
    Stack,
    RangeSlider,
    Select,
    Checkbox,
} from '@mantine/core'

export const Filters = ({
    filter,
    setFilter,
}: {
    filter: FilterState
    setFilter: (filter: FilterState) => void
}) => {
    return (
        <Accordion variant="contained">
            <Accordion.Item value="filter">
                <Accordion.Control>
                    <Text size="lg" w={700}>
                        Sort and filter
                    </Text>
                </Accordion.Control>
                <Accordion.Panel>
                    <Stack>
                        <Divider />
                        <Stack gap="xs">
                            <Text size="sm">Score range</Text>
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
                        </Stack>
                        <Stack gap="xs">
                            <Text size="sm">Difficulty range</Text>
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
                            <Text size="sm">Played status</Text>
                            <SegmentedControl
                                value={filter.charts}
                                data={[
                                    { label: 'Any', value: 'all' },
                                    { label: 'Played', value: 'played' },
                                    { label: 'Unplayed', value: 'unplayed' },
                                ]}
                                onChange={(
                                    value: 'all' | 'played' | 'unplayed',
                                ) =>
                                    setFilter({
                                        ...filter,
                                        charts: value,
                                    })
                                }
                            />
                        </Stack>
                        <Stack gap="xs">
                            <Text size="sm">Cleared status</Text>
                            <SegmentedControl
                                value={filter.cleared}
                                data={[
                                    { label: 'Any', value: 'all' },
                                    { label: 'Cleared', value: 'cleared' },
                                    { label: 'Failed', value: 'failed' },
                                ]}
                                onChange={(
                                    value: 'all' | 'cleared' | 'failed',
                                ) =>
                                    setFilter({
                                        ...filter,
                                        cleared: value,
                                    })
                                }
                            />
                        </Stack>
                        <Stack gap="xs">
                            <Text size="sm">Song tags</Text>
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
                            <Text size="sm">Sort first by...</Text>
                            <Select
                                allowDeselect={false}
                                value={filter.primary}
                                data={sortOptions}
                                onChange={(value) => {
                                    let secondary = filter.secondary
                                    if (value === filter.secondary) {
                                        secondary =
                                            sortOptions.find(
                                                (item) => item !== value,
                                            ) ?? null
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
                            <Text size="sm">
                                And if they're the same, by...
                            </Text>
                            <Select
                                allowDeselect={false}
                                value={filter.secondary}
                                data={sortOptions.filter(
                                    (item) => item !== filter.primary,
                                )}
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
                        <Button
                            onClick={() => setFilter(defaultFilter())}
                            color="red"
                        >
                            Reset filters
                        </Button>
                    </Stack>
                </Accordion.Panel>
            </Accordion.Item>
        </Accordion>
    )
}
