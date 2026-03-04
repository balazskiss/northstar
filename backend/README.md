# Backend

Supabase backend with edge functions.

## Prerequisites

- [Supabase CLI](https://supabase.com/docs/guides/cli) — `npm install` installs it locally
- [Deno](https://deno.com) — required to run edge function tests
- [Docker](https://www.docker.com) — required to run Supabase locally

## Run

```sh
# Start the local Supabase stack (DB, Auth, Storage, Edge Runtime)
npx supabase start

# In a second terminal, serve edge functions with hot reload
npx supabase functions serve
```

Studio is available at http://localhost:54323.

## Test

```sh
# Copy env template and fill in the local anon key printed by `supabase start`
cp supabase/functions/tests/.env.example supabase/functions/tests/.env

cd supabase/functions
deno task test
```

## Edge Functions

Replace `<anon-key>` with the key printed by `supabase start`, and `<id>` with a metric UUID.

**Get a metric**
```sh
curl http://localhost:54321/functions/v1/metrics/<id> \
  -H 'Authorization: Bearer <anon-key>'
```

**Update a metric's value**
```sh
curl -X PATCH http://localhost:54321/functions/v1/metrics/<id> \
  -H 'Authorization: Bearer <anon-key>' \
  -H 'Content-Type: application/json' \
  -d '{"value": 42}'
```

For production, replace `http://localhost:54321` with `https://<project-ref>.supabase.co`.

## Deploy

```sh
# Link to your Supabase project (once)
npx supabase link --project-ref <project-ref>

# Push DB migrations
npx supabase db push

# Deploy all edge functions
npx supabase functions deploy
```
