
  create table "public"."metrics" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "title" text not null,
    "description" text,
    "value" numeric not null
      );


CREATE UNIQUE INDEX metrics_pkey ON public.metrics USING btree (id);

alter table "public"."metrics" add constraint "metrics_pkey" PRIMARY KEY using index "metrics_pkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$
;

grant delete on table "public"."metrics" to "anon";

grant insert on table "public"."metrics" to "anon";

grant references on table "public"."metrics" to "anon";

grant select on table "public"."metrics" to "anon";

grant trigger on table "public"."metrics" to "anon";

grant truncate on table "public"."metrics" to "anon";

grant update on table "public"."metrics" to "anon";

grant delete on table "public"."metrics" to "authenticated";

grant insert on table "public"."metrics" to "authenticated";

grant references on table "public"."metrics" to "authenticated";

grant select on table "public"."metrics" to "authenticated";

grant trigger on table "public"."metrics" to "authenticated";

grant truncate on table "public"."metrics" to "authenticated";

grant update on table "public"."metrics" to "authenticated";

grant delete on table "public"."metrics" to "service_role";

grant insert on table "public"."metrics" to "service_role";

grant references on table "public"."metrics" to "service_role";

grant select on table "public"."metrics" to "service_role";

grant trigger on table "public"."metrics" to "service_role";

grant truncate on table "public"."metrics" to "service_role";

grant update on table "public"."metrics" to "service_role";

CREATE TRIGGER metrics_updated_at BEFORE UPDATE ON public.metrics FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


