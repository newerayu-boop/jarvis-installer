-- Biletlar jadvali. Supabase SQL Editor da bir marta ishga tushiring.

create table if not exists public.tickets (
  token           text primary key,
  ticket_number   text not null,
  full_name       text not null,
  tarif           text not null default 'Standart',
  event           text,
  issued_by       bigint,
  issued_by_name  text,
  used            boolean not null default false,
  used_at         timestamptz,
  created_at      timestamptz not null default now()
);

create index if not exists tickets_created_at_idx on public.tickets (created_at desc);
create index if not exists tickets_number_idx     on public.tickets (ticket_number);

-- Xizmat faqat SERVICE key bilan yozadi/oqiydi (RLS ni yoqib qo'yamiz,
-- policy qo'shmaymiz — service key RLS ni chetlab o'tadi).
alter table public.tickets enable row level security;
