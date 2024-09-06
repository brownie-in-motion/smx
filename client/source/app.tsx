import '@mantine/core/styles.css'

import { AppShell, Container, MantineProvider, Stack } from '@mantine/core'
import { createRoot } from 'react-dom/client'
import { UserSelect } from './components/user-select'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Charts } from './components/charts'
import { User } from './hooks'
import { defaultFilter, Filters, FilterState } from "./components/filters"
import { useLocalStorage } from '@mantine/hooks'

export const queryClient = new QueryClient()

const App = () => {
    const [user, setUser] = useLocalStorage<User | null>({
        key: 'user',
        defaultValue: null,
    })

    const [filter, setFilter] = useLocalStorage<FilterState>({
        key: 'filter',
        defaultValue: defaultFilter(),
    })

    return (
        <Container style={{ height: '100%' }}>
            <Stack style={{ height: '100%' }}>
                <UserSelect user={user} onChange={setUser} />
                <Filters
                    filter={filter}
                    setFilter={setFilter}
                />
                <Charts
                    filter={filter}
                    userId={user?.id}
                    style={{
                        flexGrow: 1,
                        minHeight: 0,
                    }}
                />
            </Stack>
        </Container>
    )
}

createRoot(document.getElementById('root')!).render(
    <MantineProvider>
        <QueryClientProvider client={queryClient}>
            <AppShell
                disabled
                padding='lg'
                styles={{
                    root: { height: '100%' },
                    main: { height: '100%' },
                }}
            >
                <AppShell.Main>
                    <App />
                </AppShell.Main>
            </AppShell>
        </QueryClientProvider>
    </MantineProvider>,
)
