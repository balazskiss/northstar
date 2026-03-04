import { assertEquals } from 'jsr:@std/assert@1'
import { createClient } from '@supabase/supabase-js'
import { load } from 'jsr:@std/dotenv'

await load({ envPath: './tests/.env', export: true })

const client = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_ANON_KEY') ?? '',
  { auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false } },
)

Deno.test('hello-world returns greeting with provided name', async () => {
  const { data, error } = await client.functions.invoke('hello-world', {
    body: { name: 'Functions' },
  })

  if (error) throw error
  assertEquals(data.message, 'Hello Functions!')
})
