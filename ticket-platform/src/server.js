'use strict';

const express = require('express');
const { getTicketByToken, markUsed } = require('./db');
const config = require('./config');

const STAFF_PIN = process.env.STAFF_PIN || ''; // optional gate for check-in

const app = express();
app.use(express.urlencoded({ extended: false }));

function esc(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function page(status, ticket, opts = {}) {
  // status: 'valid' | 'used' | 'invalid'
  const theme = {
    valid:   { color: '#22c55e', icon: '✅', title: 'Bilet HAQIQIY' },
    used:    { color: '#f59e0b', icon: '⚠️', title: 'Bilet ALLAQACHON ishlatilgan' },
    invalid: { color: '#ef4444', icon: '⛔️', title: 'Bilet TOPILMADI' },
  }[status];

  const details = ticket ? `
    <div class="rows">
      <div class="row"><span>Ishtirokchi</span><b>${esc(ticket.full_name)}</b></div>
      <div class="row"><span>Bilet raqami</span><b>#${esc(ticket.ticket_number)}</b></div>
      <div class="row"><span>Tarif</span><b>${esc(ticket.tarif)}</b></div>
      ${ticket.used_at ? `<div class="row"><span>Kirgan vaqti</span><b>${esc(new Date(ticket.used_at).toLocaleString('uz-UZ'))}</b></div>` : ''}
    </div>` : '';

  const checkin = (status === 'valid') ? `
    <form method="POST" action="/t/${esc(opts.token)}/checkin" class="checkin">
      ${STAFF_PIN ? '<input name="pin" inputmode="numeric" placeholder="Xodim PIN kodi" autocomplete="off" required>' : ''}
      <button type="submit">Kirdi — belgilash</button>
    </form>` : '';

  const err = opts.error ? `<div class="err">${esc(opts.error)}</div>` : '';

  return `<!doctype html><html lang="uz"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Bilet tekshiruvi</title>
<style>
  :root{--gold:#E5B86F;--gold-light:#F3D293}
  *{margin:0;padding:0;box-sizing:border-box}
  body{min-height:100vh;background:radial-gradient(120% 60% at 50% 0%,#161206,#080808 60%);
    color:#fafafa;font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;
    display:flex;align-items:center;justify-content:center;padding:22px}
  .card{width:100%;max-width:420px;background:#111;border:1.5px solid #262626;border-radius:26px;
    padding:34px 28px;box-shadow:0 30px 80px rgba(0,0,0,.6)}
  .icon{font-size:64px;text-align:center;line-height:1}
  h1{text-align:center;font-size:23px;margin:14px 0 4px;color:${theme.color}}
  .sub{text-align:center;color:#8c8c8c;font-size:14px;margin-bottom:22px}
  .rows{background:#0c0c0c;border:1px solid #242424;border-radius:16px;overflow:hidden}
  .row{display:flex;justify-content:space-between;align-items:center;padding:15px 18px;border-bottom:1px solid #1c1c1c;font-size:15px}
  .row:last-child{border-bottom:0}
  .row span{color:#8c8c8c}
  .row b{color:#fafafa;font-weight:600;text-align:right}
  .brand{display:flex;align-items:center;gap:10px;justify-content:center;margin-top:24px;color:#8c8c8c;font-size:13px}
  .mark{width:30px;height:30px;border-radius:8px;background:linear-gradient(135deg,#E5B86F,#C9A85D);
    color:#0a0a0a;font-weight:800;display:flex;align-items:center;justify-content:center;font-size:15px}
  .checkin{margin-top:22px;display:flex;flex-direction:column;gap:10px}
  .checkin input{padding:14px 16px;border-radius:12px;border:1.5px solid #2a2a2a;background:#0c0c0c;color:#fff;font-size:16px}
  .checkin button{padding:16px;border:0;border-radius:12px;cursor:pointer;font-size:17px;font-weight:700;
    background:linear-gradient(90deg,#E5B86F,#F3D293);color:#0a0a0a}
  .err{margin-top:14px;background:rgba(239,68,68,.12);border:1px solid rgba(239,68,68,.4);
    color:#fca5a5;padding:12px 14px;border-radius:12px;font-size:14px;text-align:center}
</style></head><body>
  <div class="card">
    <div class="icon">${theme.icon}</div>
    <h1>${theme.title}</h1>
    <div class="sub">${esc(config.event.eventSub)}</div>
    ${details}
    ${err}
    ${checkin}
    <div class="brand"><span class="mark">${esc(config.brand.mark)}</span>${esc(config.brand.name)} · ${esc(config.brand.url)}</div>
  </div>
</body></html>`;
}

app.get('/', (_req, res) => res.send('OK'));

app.get('/t/:token', async (req, res) => {
  try {
    const ticket = await getTicketByToken(req.params.token);
    if (!ticket) return res.status(404).send(page('invalid', null));
    const status = ticket.used ? 'used' : 'valid';
    res.send(page(status, ticket, { token: req.params.token }));
  } catch (err) {
    console.error('verify error:', err);
    res.status(500).send(page('invalid', null, { error: 'Server xatosi' }));
  }
});

app.post('/t/:token/checkin', async (req, res) => {
  try {
    if (STAFF_PIN && String(req.body.pin || '') !== STAFF_PIN) {
      const ticket = await getTicketByToken(req.params.token);
      return res.status(403).send(page(ticket && ticket.used ? 'used' : 'valid', ticket,
        { token: req.params.token, error: 'PIN noto\'g\'ri' }));
    }
    const row = await markUsed(req.params.token);
    if (!row) {
      // Already used or not found — re-fetch to show accurate state.
      const ticket = await getTicketByToken(req.params.token);
      return res.send(page(ticket ? 'used' : 'invalid', ticket, { token: req.params.token }));
    }
    res.send(page('used', row, { token: req.params.token }));
  } catch (err) {
    console.error('checkin error:', err);
    res.status(500).send(page('invalid', null, { error: 'Server xatosi' }));
  }
});

module.exports = { app };
