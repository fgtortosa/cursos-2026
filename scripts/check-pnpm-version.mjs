import { readFileSync } from 'node:fs'

function getExpectedPnpmVersion() {
  const packageJsonUrl = new URL('../package.json', import.meta.url)
  const packageJson = JSON.parse(readFileSync(packageJsonUrl, 'utf8'))
  const packageManager = packageJson.packageManager ?? ''
  const match = packageManager.match(/^pnpm@(.+)$/)

  return match?.[1] ?? null
}

function getCurrentPnpmVersion() {
  const userAgent = process.env.npm_config_user_agent ?? ''
  const match = userAgent.match(/pnpm\/([^\s]+)/)

  return match?.[1] ?? null
}

const expectedVersion = getExpectedPnpmVersion()
const currentVersion = getCurrentPnpmVersion()

if (!expectedVersion) {
  process.exit(0)
}

if (currentVersion === expectedVersion) {
  process.exit(0)
}

const detectedVersion = currentVersion ?? 'desconocida'
const expectedPackageManager = `pnpm@${expectedVersion}`

console.error('')
console.error(`[pnpm-version-check] Este proyecto requiere ${expectedPackageManager}.`)
console.error(`[pnpm-version-check] Version detectada: ${detectedVersion}.`)
console.error('[pnpm-version-check]')
console.error('[pnpm-version-check] Para corregirlo ejecuta:')
console.error(`[pnpm-version-check] 1) corepack prepare ${expectedPackageManager} --activate`)
console.error('[pnpm-version-check] 2) corepack pnpm install')
console.error('[pnpm-version-check] 3) corepack pnpm docs:dev')
console.error('[pnpm-version-check]')
console.error('[pnpm-version-check] Evita usar "pnpm ..." directo si tu version global es distinta.')
console.error('')

process.exit(1)