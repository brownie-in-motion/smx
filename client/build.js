// @ts-ncheck

const { build, context } = require('esbuild')

void (async () => {
    const app = {
        entryPoints: ['source/app.tsx'],
        bundle: true,
        format: 'esm',
        outdir: 'build',
        loader: { '.ttf': 'file' },
        jsxImportSource: 'react',
        jsx: 'automatic',
        logLevel: 'info',
        splitting: true,
    }

    if (process.argv.includes('--watch')) {
        const c = await context(app)
        await c.watch()
    } else {
        await build(app)
    }
})()
