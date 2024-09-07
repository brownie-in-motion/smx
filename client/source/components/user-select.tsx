import { useEffect, useState } from 'react'
import { Accordion, CloseButton, Combobox, InputBase, useCombobox } from '@mantine/core'
import { useDebouncedState } from '@mantine/hooks'
import { User, useUsers } from '../hooks'

export const UserSelect = ({
    user,
    onChange,
}: {
    user: User
    onChange: (user: User | null) => void
}) => {
    const combobox = useCombobox({
        onDropdownClose: () => combobox.resetSelectedOption(),
    })

    const [search, setSearch] = useState(
        user?.name || '',
    )
    const [searchDebounced, setSearchDebounced] = useDebouncedState(
        user?.name || '',
        500,
    )
    const { data, isLoading } = useUsers(searchDebounced)

    useEffect(() => {
        setSearchDebounced(search)
    }, [search])

    useEffect(() => {
        setSearch(user?.name || '')
    }, [user])

    const options = (data ?? []).map((item) => (
        <Combobox.Option value={item.name} key={item.id}>
            {item.name} {item.country}
        </Combobox.Option>
    ))

    return (
        <Combobox
            size='lg'
            store={combobox}
            withinPortal={false}
            onOptionSubmit={(val) => {
                const user = data?.find((item) => item.name === val) ?? null
                setSearch(val)
                onChange(user)
                combobox.closeDropdown()
            }}
        >
            <Combobox.Target>
                <InputBase
                    size='lg'
                    rightSection={
                        user !== null ? (
                            <CloseButton
                                size="md"
                                onMouseDown={(event) => event.preventDefault()}
                                onClick={() => {
                                    setSearch('')
                                    onChange(null)
                                }}
                                aria-label="Clear value"
                            />
                        ) : (
                            <Accordion.Chevron />
                        )
                    }
                    value={search}
                    onChange={(event) => {
                        combobox.openDropdown()
                        combobox.updateSelectedOptionIndex()
                        setSearch(event.currentTarget.value)
                    }}
                    onClick={() => combobox.openDropdown()}
                    onFocus={() => combobox.openDropdown()}
                    onBlur={() => {
                        combobox.closeDropdown()
                        setSearch(user?.name || '')
                    }}
                    placeholder="Search users"
                    rightSectionPointerEvents={user === null ? 'none' : 'all'}
                />
            </Combobox.Target>

            <Combobox.Dropdown>
                <Combobox.Options>
                    {isLoading ? (
                        <Combobox.Empty>Loading...</Combobox.Empty>
                    ) : options.length ? (
                        options
                    ) : (
                        <Combobox.Empty>No users found.</Combobox.Empty>
                    )}
                </Combobox.Options>
            </Combobox.Dropdown>
        </Combobox>
    )
}
