const { chromium } = require('/opt/node22/lib/node_modules/playwright');
const path = require('path');
const fs = require('fs');

(async () => {
  const mode = process.argv[2] || 'test';
  const outDir = process.argv[3] || 'frames';
  const SPEED = parseFloat(process.env.SPEED || '1.0');
  const FPS = 30;
  const sceneUrl = 'file://' + path.resolve(__dirname, 'scene.html');

  const browser = await chromium.launch({
    executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome',
    args: ['--no-sandbox','--disable-gpu','--force-color-profile=srgb','--hide-scrollbars','--allow-file-access-from-files']
  });
  const page = await browser.newPage({ viewport: { width: 1080, height: 1920 }, deviceScaleFactor: 1 });
  page.on('pageerror', e => console.log('PAGEERR', e.message));
  await page.goto(sceneUrl, { waitUntil: 'load' });
  await page.waitForFunction('window.__ready===true', { timeout: 20000 });
  // wait for fonts
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(300);
  const SCENE_DUR = await page.evaluate(() => window.__SCENE_DUR || 44.0);
  const DUR = SCENE_DUR / SPEED;
  console.log('SCENE_DUR', SCENE_DUR, 'SPEED', SPEED, 'video DUR', DUR.toFixed(2));

  fs.mkdirSync(path.resolve(__dirname, outDir), { recursive: true });

  if (mode === 'test') {
    const times = (process.argv[4]||'0.8,3.5,7,11.8,16,20.5,23,25.5,28.5,33,36,39.5,41.5').split(',').map(Number);
    for (const t of times) {
      await page.evaluate(async (tt) => await window.renderAt(tt), t);
      await page.waitForTimeout(30);
      const nm = 'test_' + String(t).replace('.','_') + '.png';
      await page.screenshot({ path: path.resolve(__dirname, outDir, nm) });
      console.log('rendered', nm);
    }
  } else {
    const N = Math.round(DUR * FPS);
    const t0 = Date.now();
    for (let i = 0; i < N; i++) {
      const t = (i / FPS) * SPEED;   // scene-time; SPEED>1 => visuals+captions play faster
      await page.evaluate(async (tt) => await window.renderAt(tt), t);
      await page.screenshot({ path: path.resolve(__dirname, outDir, 'f_' + String(i).padStart(5,'0') + '.png') });
      if (i % 60 === 0) {
        const el = (Date.now()-t0)/1000;
        console.log(`frame ${i}/${N}  ${el.toFixed(0)}s  ${(i/Math.max(el,1)).toFixed(1)}fps`);
      }
    }
    console.log('DONE', N, 'frames in', ((Date.now()-t0)/1000).toFixed(0),'s');
  }
  await browser.close();
})().catch(e => { console.error('FATAL', e); process.exit(1); });
