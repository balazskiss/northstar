import { createClient, SupabaseClient } from '@supabase/supabase-js'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

// Matches: /functions/v1/metrics/:id
const ROUTE_REGEX = /\/metrics\/([^/]+)$/

export async function getMetric(supabase: SupabaseClient, id: string): Promise<Response> {
  const { data, error } = await supabase
    .from('metrics')
    .select('*')
    .eq('id', id)
    .single()

  if (error) {
    if (error.code === 'PGRST116') {
      return jsonResponse({ error: 'Metric not found' }, 404)
    }
    console.error('Database error:', error.message)
    return jsonResponse({ error: 'Failed to fetch metric' }, 500)
  }

  return jsonResponse(data, 200)
}

export async function updateMetric(supabase: SupabaseClient, id: string, req: Request): Promise<Response> {
  let body: unknown
  try {
    body = await req.json()
  } catch {
    return jsonResponse({ error: 'Request body must be valid JSON' }, 400)
  }

  if (
    typeof body !== 'object' ||
    body === null ||
    !('value' in body) ||
    typeof (body as Record<string, unknown>).value !== 'number' ||
    !isFinite((body as Record<string, unknown>).value as number)
  ) {
    return jsonResponse({ error: '"value" must be a finite number' }, 400)
  }

  const { value } = body as { value: number }

  const { data, error } = await supabase
    .from('metrics')
    .update({ value })
    .eq('id', id)
    .select('*')
    .single()

  if (error) {
    if (error.code === 'PGRST116') {
      return jsonResponse({ error: 'Metric not found' }, 404)
    }
    console.error('Database error:', error.message)
    return jsonResponse({ error: 'Failed to update metric' }, 500)
  }

  return jsonResponse(data, 200)
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const pathname = new URL(req.url).pathname
  const match = pathname.match(ROUTE_REGEX)

  if (!match) {
    return jsonResponse({ error: 'Not found' }, 404)
  }

  const id = match[1]

  if (!UUID_REGEX.test(id)) {
    return jsonResponse({ error: 'Invalid id — must be a UUID' }, 400)
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')

  if (!supabaseUrl || !supabaseAnonKey) {
    console.error('Missing SUPABASE_URL or SUPABASE_ANON_KEY')
    return jsonResponse({ error: 'Server configuration error' }, 500)
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: { Authorization: req.headers.get('Authorization') ?? '' },
    },
  })

  switch (req.method) {
    case 'GET':   return getMetric(supabase, id)
    case 'PATCH': return updateMetric(supabase, id, req)
    default:      return jsonResponse({ error: 'Method not allowed' }, 405)
  }
})
