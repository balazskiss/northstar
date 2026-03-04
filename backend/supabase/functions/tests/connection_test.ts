import { assert } from 'jsr:@std/assert@1'
import { createClient } from '@supabase/supabase-js'
import { load } from 'jsr:@std/dotenv'

await load({ envPath: './tests/.env', export: true })

Deno.test('supabase connection', async () => {
  const client = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false } },
  )

  const { error } = await client.from('metrics').select('id').limit(1)
  assert(!error, error?.message)
})
