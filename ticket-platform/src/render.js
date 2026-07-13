'use strict';

const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const config = require('./config');

const SRC = __dirname;
const TEMPLATE = fs.readFileSync(path.join(SRC, 'template.html'), 'utf8');
const FONTS = fs.readFileSync(path.join(SRC, 'assets', 'fonts.css'), 'utf8');

// Photo is inlined once as a data URI (no network needed at render time).
const PHOTO_DATA_URI = (() => {
  const p = path.join(SRC, config.event.photo);
  const b64 = fs.readFileSync(p).toString('base64');
  const ext = path.extname(p).slice(1).toLowerCase() === 'png' ? 'png' : 'jpeg';
  return `data:image/${ext};base64,${b64}`;
})();

// One shared browser instance for the whole process.
let browserPromise = null;
async function getBrowser() {
  if (!browserPromise) {
    const opts = { args: ['--no-sandbox', '--disable-dev-shm-usage'] };
    if (process.env.CHROMIUM_PATH) opts.executablePath = process.env.CHROMIUM_PATH;
    browserPromise = chromium.launch(opts).then((b) => {
      // If Chromium dies (crash/OOM), drop the handle so the next render
      // relaunches a fresh browser instead of failing forever.
      b.on('disconnected', () => { browserPromise = null; });
      return b;
    }).catch((err) => { browserPromise = null; throw err; });
  }
  return browserPromise;
}

function escapeHtml(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/**
 * Render a ticket to a PNG Buffer.
 * @param {{name:string, number:string|number, tarif?:string, token:string}} data
 * @returns {Promise<Buffer>}
 */
async function renderTicket(data) {
  const values = {
    PHOTO:          PHOTO_DATA_URI,
    BADGE:          escapeHtml(config.event.badge),
    DATE:           escapeHtml(config.event.date),
    TIME:           escapeHtml(config.event.time),
    VENUE:          escapeHtml(config.event.venue),
    SPEAKER:        escapeHtml(config.event.speaker),
    EVENT_SUB:      escapeHtml(config.event.eventSub),
    NAME:           escapeHtml(data.name),
    NUMBER:         escapeHtml(data.number),
    TARIF:          escapeHtml(data.tarif || config.defaultTarif),
    BRAND_MARK:     escapeHtml(config.brand.mark),
    BRAND_NAME:     escapeHtml(config.brand.name),
    BRAND_URL:      escapeHtml(config.brand.url),
    LABEL_ATTENDEE: escapeHtml(config.labels.attendee),
    LABEL_VENUE:    escapeHtml(config.labels.venue),
    LABEL_TARIF:    escapeHtml(config.labels.tarif),
    LABEL_NUMBER:   escapeHtml(config.labels.number),
  };

  let html = TEMPLATE.replace('/*FONTS*/', FONTS);
  html = html.replace(/\{\{(\w+)\}\}/g, (m, key) =>
    Object.prototype.hasOwnProperty.call(values, key) ? values[key] : m);

  // One retry: if Chromium crashed between renders, getBrowser() will have
  // been reset by the 'disconnected' handler, so the second attempt relaunches.
  let lastErr;
  for (let attempt = 0; attempt < 2; attempt++) {
    let page;
    try {
      const browser = await getBrowser();
      page = await browser.newPage({
        viewport: { width: 1080, height: 1980 },
        deviceScaleFactor: 1,
      });
      await page.setContent(html, { waitUntil: 'networkidle' });
      // Wait for the name auto-fit script to finish sizing.
      await page.waitForFunction(() => window.__fitDone === true, { timeout: 3000 })
        .catch(() => {});
      const el = await page.$('.ticket');
      return await el.screenshot({ type: 'png' });
    } catch (err) {
      lastErr = err;
      browserPromise = null; // force a fresh browser on retry
    } finally {
      if (page) await page.close().catch(() => {});
    }
  }
  throw lastErr;
}

async function closeBrowser() {
  if (browserPromise) {
    const b = await browserPromise;
    await b.close();
    browserPromise = null;
  }
}

module.exports = { renderTicket, closeBrowser };
