'use strict';

// Ticket renderer: builds the layout with Satori (HTML/CSS -> SVG) and
// rasterizes to PNG with resvg. No headless browser — runs anywhere,
// including serverless (Vercel).

const { Resvg } = require('@resvg/resvg-js');
const { fonts, photoDataUri } = require('./assets');
const config = require('../config');

const GOLD_GRAD = 'linear-gradient(90deg,#E5B86F,#F7E3B5 55%,#E5B86F)';
const W = 900, H = 1900;
const STUB_PAD = 70, MAX_NAME_W = W - STUB_PAD * 2; // 760

// Satori element helper: h(type, style, ...children)
function h(type, style, ...children) {
  return { type, props: { style, children: children.length <= 1 ? children[0] : children } };
}
const img = (src, style) => ({ type: 'img', props: { src, style } });

// Approximate auto-fit: pick a font size so long names fit (up to ~2 lines).
function nameSize(name) {
  const cap = 88, min = 34, avg = 0.60;
  const len = Math.max(name.length, 1);
  const oneLine = MAX_NAME_W / (len * avg);
  const twoLine = (MAX_NAME_W * 1.9) / (len * avg);
  return Math.max(min, Math.min(cap, Math.floor(Math.max(oneLine, twoLine))));
}

function buildTree({ name, number, tarif }) {
  const e = config.event, b = config.brand, l = config.labels;
  const nSize = nameSize(name);

  return h('div', { display: 'flex', flexDirection: 'column', width: W, height: H, background: '#0e0e0e', borderRadius: 44, overflow: 'hidden', fontFamily: 'Manrope' },
    // ── ARTWORK ──
    h('div', { display: 'flex', position: 'relative', width: W, height: 1160 },
      img(photoDataUri, { position: 'absolute', top: 0, left: 0, width: W, height: 1160, objectFit: 'cover', objectPosition: '50% 22%' }),
      h('div', { position: 'absolute', top: 0, left: 0, width: W, height: 1160, backgroundImage: 'linear-gradient(180deg,rgba(8,8,8,0.55) 0%,rgba(8,8,8,0) 22%,rgba(8,8,8,0) 55%,rgba(14,14,14,0.9) 88%,#0e0e0e 100%)' }),
      h('div', { display: 'flex', position: 'absolute', top: 46, left: 0, width: W, justifyContent: 'center', alignItems: 'center', fontSize: 30, fontWeight: 600, color: '#eaeaea' },
        h('span', {}, e.date),
        h('span', { color: '#E5B86F', marginLeft: 16, marginRight: 16 }, '•'),
        h('span', {}, e.venue),
        h('span', { color: '#E5B86F', marginLeft: 16, marginRight: 16 }, '•'),
        h('span', {}, e.time),
      ),
      h('div', { display: 'flex', position: 'absolute', top: 108, left: 0, width: W, justifyContent: 'center', fontFamily: 'Montserrat', fontWeight: 800, fontSize: 46, letterSpacing: 14, color: '#EBCB8A' }, e.badge),
      h('div', { display: 'flex', flexDirection: 'column', alignItems: 'center', position: 'absolute', bottom: 44, left: 0, width: W },
        h('div', { display: 'flex', fontFamily: 'Montserrat', fontWeight: 700, fontSize: 52, color: '#FAFAFA' }, e.speaker),
        h('div', { display: 'flex', fontWeight: 500, fontSize: 26, letterSpacing: 1, color: '#E5B86F', marginTop: 8 }, e.eventSub),
      ),
    ),
    // ── tear line ──
    h('div', { display: 'flex', width: 780, marginLeft: 60, marginRight: 60, borderTopWidth: 4, borderTopStyle: 'dashed', borderTopColor: 'rgba(229,184,111,0.55)', height: 0 }),
    // ── STUB ──
    h('div', { display: 'flex', flexDirection: 'column', padding: '56px 70px 60px', background: '#141414', flexGrow: 1 },
      h('div', { display: 'flex', fontWeight: 600, fontSize: 24, letterSpacing: 3, color: '#8c8c8c' }, l.attendee),
      h('div', { display: 'flex', fontFamily: 'Montserrat', fontWeight: 800, fontSize: nSize, lineHeight: 1.06, marginTop: 12, color: 'transparent', backgroundImage: GOLD_GRAD, backgroundClip: 'text', maxWidth: MAX_NAME_W }, name),
      h('div', { display: 'flex', marginTop: 48 },
        h('div', { display: 'flex', flexDirection: 'column', flexGrow: 1, flexBasis: 0, background: '#1a1a1a', border: '1px solid #2a2a2a', borderRadius: 22, padding: '26px 30px', marginRight: 24 },
          h('div', { display: 'flex', fontSize: 22, letterSpacing: 2, color: '#8c8c8c' }, l.venue),
          h('div', { display: 'flex', fontFamily: 'Montserrat', fontWeight: 700, fontSize: 44, color: '#FAFAFA', marginTop: 8 }, e.venue),
        ),
        h('div', { display: 'flex', flexDirection: 'column', flexGrow: 1, flexBasis: 0, background: '#241f14', border: '1px solid rgba(229,184,111,0.45)', borderRadius: 22, padding: '26px 30px' },
          h('div', { display: 'flex', fontSize: 22, letterSpacing: 2, color: '#8c8c8c' }, l.tarif),
          h('div', { display: 'flex', fontFamily: 'Montserrat', fontWeight: 700, fontSize: 44, color: '#F3D293', marginTop: 8 }, tarif || config.defaultTarif),
        ),
      ),
      h('div', { display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginTop: 56 },
        h('div', { display: 'flex', alignItems: 'center' },
          h('div', { display: 'flex', justifyContent: 'center', alignItems: 'center', width: 64, height: 64, borderRadius: 16, background: '#E0B267', color: '#0a0a0a', fontFamily: 'Montserrat', fontWeight: 900, fontSize: 34, marginRight: 16 }, b.mark),
          h('div', { display: 'flex', flexDirection: 'column' },
            h('div', { display: 'flex', fontFamily: 'Montserrat', fontWeight: 700, fontSize: 30, color: '#FAFAFA' }, b.name),
            h('div', { display: 'flex', fontSize: 23, color: '#8c8c8c' }, b.url),
          ),
        ),
        h('div', { display: 'flex', flexDirection: 'column', alignItems: 'flex-end' },
          h('div', { display: 'flex', fontSize: 22, letterSpacing: 2, color: '#8c8c8c' }, l.number),
          h('div', { display: 'flex', fontFamily: 'Montserrat', fontWeight: 900, fontSize: 78, color: '#E5B86F', lineHeight: 1, marginTop: 6 }, '#' + number),
        ),
      ),
    ),
  );
}

function fontSpec() {
  return [
    { name: 'Montserrat', data: fonts.montserrat700, weight: 700, style: 'normal' },
    { name: 'Montserrat', data: fonts.montserrat800, weight: 800, style: 'normal' },
    { name: 'Montserrat', data: fonts.montserrat900, weight: 900, style: 'normal' },
    { name: 'Manrope', data: fonts.manrope500, weight: 500, style: 'normal' },
    { name: 'Manrope', data: fonts.manrope600, weight: 600, style: 'normal' },
    { name: 'Manrope', data: fonts.manrope700, weight: 700, style: 'normal' },
  ];
}

/**
 * Render a ticket to a PNG Buffer.
 * @param {{name:string, number:string|number, tarif?:string}} data
 * @returns {Promise<Buffer>}
 */
// В шрифтах билета нет эмодзи: они печатаются пустым квадратом, и такой
// билет уходит клиенту. Убираем их до рендера — пустое поле честнее «тофу».
function printable(s) {
  return String(s == null ? '' : s)
    .replace(/[\p{Extended_Pictographic}‍️︎]/gu, '')
    .replace(/\s+/g, ' ')
    .trim();
}

async function renderTicketPng(data) {
  const satori = (await import('satori')).default;
  const svg = await satori(buildTree({
    name: printable(data.name),
    number: String(data.number || '').trim(),
    tarif: printable(data.tarif) || undefined,
  }), { width: W, height: H, fonts: fontSpec() });
  return new Resvg(svg, { fitTo: { mode: 'width', value: W } }).render().asPng();
}

module.exports = { renderTicketPng };
