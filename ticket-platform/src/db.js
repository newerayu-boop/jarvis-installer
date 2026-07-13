'use strict';

// Ticket storage. Uses Supabase when SUPABASE_URL + SUPABASE_SERVICE_KEY are
// set; otherwise falls back to a local JSON file so you can test without a DB.
//
// Supabase schema (see README / migration):
//   create table tickets (
//     token text primary key,
//     ticket_number text not null,
//     full_name text not null,
//     tarif text not null default 'Standart',
//     event text,
//     issued_by bigint,
//     issued_by_name text,
//     used boolean not null default false,
//     used_at timestamptz,
//     created_at timestamptz not null default now()
//   );

const fs = require('fs');
const path = require('path');

const URL = process.env.SUPABASE_URL;
const KEY = process.env.SUPABASE_SERVICE_KEY;
const TABLE = process.env.SUPABASE_TABLE || 'tickets';
const usingSupabase = Boolean(URL && KEY);

let supabase = null;
if (usingSupabase) {
  const { createClient } = require('@supabase/supabase-js');
  supabase = createClient(URL, KEY, { auth: { persistSession: false } });
}

/* ─── Local JSON fallback ─────────────────────────────────────── */
const FILE = path.join(__dirname, '..', 'data', 'tickets.json');
function readFileStore() {
  try { return JSON.parse(fs.readFileSync(FILE, 'utf8')); }
  catch { return {}; }
}
function writeFileStore(obj) {
  fs.mkdirSync(path.dirname(FILE), { recursive: true });
  fs.writeFileSync(FILE, JSON.stringify(obj, null, 2));
}

/* ─── Public API ──────────────────────────────────────────────── */

async function createTicket(t) {
  const row = {
    token: t.token,
    ticket_number: String(t.number),
    full_name: t.name,
    tarif: t.tarif,
    event: t.event || null,
    issued_by: t.issuedBy || null,
    issued_by_name: t.issuedByName || null,
    used: false,
    used_at: null,
    created_at: new Date().toISOString(),
  };
  if (usingSupabase) {
    const { data, error } = await supabase.from(TABLE).insert(row).select().single();
    if (error) throw new Error(`Supabase insert: ${error.message}`);
    return data;
  }
  const store = readFileStore();
  store[t.token] = row;
  writeFileStore(store);
  return row;
}

async function getTicketByToken(token) {
  if (usingSupabase) {
    const { data, error } = await supabase.from(TABLE).select('*').eq('token', token).maybeSingle();
    if (error) throw new Error(`Supabase select: ${error.message}`);
    return data;
  }
  return readFileStore()[token] || null;
}

// Atomically flip used=false -> true. Returns the row if we won the race,
// or null if it was already used / not found (prevents double entry).
async function markUsed(token) {
  if (usingSupabase) {
    const { data, error } = await supabase.from(TABLE)
      .update({ used: true, used_at: new Date().toISOString() })
      .eq('token', token).eq('used', false)
      .select().maybeSingle();
    if (error) throw new Error(`Supabase update: ${error.message}`);
    return data; // null if it was already used
  }
  const store = readFileStore();
  const row = store[token];
  if (!row || row.used) return null;
  row.used = true;
  row.used_at = new Date().toISOString();
  writeFileStore(store);
  return row;
}

module.exports = { createTicket, getTicketByToken, markUsed, usingSupabase };
