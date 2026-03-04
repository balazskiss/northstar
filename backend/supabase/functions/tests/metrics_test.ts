import { assert, assertEquals } from 'jsr:@std/assert@1'
import { createClient, FunctionsHttpError } from '@supabase/supabase-js'
import { load } from 'jsr:@std/dotenv'

await load({ envPath: './tests/.env', export: true })

const client = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_ANON_KEY') ?? '',
  { auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false } },
)

// Always consumes the response body so Deno doesn't report leaks.
// Returns { status, data } for clean assertions in every test.
async function invoke(path: string, options?: Record<string, unknown>) {
  const { data, error } = await client.functions.invoke(path, options)
  if (error instanceof FunctionsHttpError) {
    const body = await error.context.json().catch(() => null)
    return { status: error.context.status, data: body }
  }
  if (error) throw error
  return { status: 200, data }
}

// --- helpers ---

async function createTestMetric(): Promise<string> {
  const { data, error } = await client
    .from('metrics')
    .insert({ title: 'Test Metric', value: 42 })
    .select('id')
    .single()
  if (error) throw new Error('Test setup failed: ' + error.message)
  return data.id
}

async function deleteTestMetric(id: string) {
  await client.from('metrics').delete().eq('id', id)
}

// --- GET /metrics/:id ---

Deno.test('GET returns all metric fields', async () => {
  const id = await createTestMetric()
  try {
    const { status, data } = await invoke(`metrics/${id}`, { method: 'GET' })
    assertEquals(status, 200)
    const metric = data as Record<string, unknown>
    assertEquals(metric.id, id)
    assertEquals(metric.value, 42)
    assert('title' in metric)
    assert('description' in metric)
    assert('created_at' in metric)
    assert('updated_at' in metric)
  } finally {
    await deleteTestMetric(id)
  }
})

Deno.test('GET returns 404 for non-existent metric', async () => {
  const { status } = await invoke('metrics/00000000-0000-0000-0000-000000000000', { method: 'GET' })
  assertEquals(status, 404)
})

Deno.test('GET returns 400 for invalid id format', async () => {
  const { status } = await invoke('metrics/not-a-uuid', { method: 'GET' })
  assertEquals(status, 400)
})

// --- PATCH /metrics/:id ---

Deno.test('PATCH updates value and returns updated metric', async () => {
  const id = await createTestMetric()
  try {
    const { status, data } = await invoke(`metrics/${id}`, { method: 'PATCH', body: { value: 99 } })
    assertEquals(status, 200)
    const metric = data as Record<string, unknown>
    assertEquals(metric.id, id)
    assertEquals(metric.value, 99)
  } finally {
    await deleteTestMetric(id)
  }
})

Deno.test('PATCH returns 400 when value is missing', async () => {
  const id = await createTestMetric()
  try {
    const { status } = await invoke(`metrics/${id}`, { method: 'PATCH', body: { title: 'oops' } })
    assertEquals(status, 400)
  } finally {
    await deleteTestMetric(id)
  }
})

Deno.test('PATCH returns 400 when value is not a number', async () => {
  const id = await createTestMetric()
  try {
    const { status } = await invoke(`metrics/${id}`, { method: 'PATCH', body: { value: 'high' } })
    assertEquals(status, 400)
  } finally {
    await deleteTestMetric(id)
  }
})

Deno.test('PATCH returns 404 for non-existent metric', async () => {
  const { status } = await invoke('metrics/00000000-0000-0000-0000-000000000000', {
    method: 'PATCH',
    body: { value: 1 },
  })
  assertEquals(status, 404)
})
