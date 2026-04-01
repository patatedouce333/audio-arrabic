---
name: dom-web
description: Run Puppeteer or Playwright scripts for deep DOM interaction — scraping, clicking, filling forms, screenshots, HTTP requests. Uses local headless Chrome — no API keys needed.
---

# dom-web — Browser Automation via Puppeteer/Playwright

## Overview

Run headless browser scripts via Puppeteer v24 or Playwright v1.50 with Chrome 147.
All local — no API keys, no external services.
Use when you need deep DOM interaction that `web_fetch` can't handle (JS rendering, clicks, forms, screenshots).

## Install Location

All packages in `/root/.openclaw/browser-env/`
Run scripts from this directory so `require('puppeteer')` and `require('playwright')` resolve.

## Prerequisites

- `node` v22
- `chromium` system package (Debian bookworm)
- Playwright browsers: `~/.cache/ms-playwright/chromium-1217`
- All installed: `puppeteer`, `playwright`, `cheerio`, `jsdom`

## Puppeteer Quick Start

```bash
cd /root/.openclaw/browser-env
node -e "
const p = require('puppeteer');
p.launch({ headless: true, args: ['--no-sandbox'] }).then(async b => {
  const page = await b.newPage();
  await page.goto('https://example.com');
  console.log(await page.title());
  await b.close();
});
"
```

## Playwright Quick Start

```bash
cd /root/.openclaw/browser-env
node -e "
const { chromium } = require('playwright');
chromium.launch({ headless: true }).then(async b => {
  const page = await b.newPage();
  await page.goto('https://example.com');
  console.log(await page.title());
  await b.close();
});
"
```

## Common Patterns

**Screenshot:**
```javascript
const p = require('puppeteer');
const browser = await p.launch({ headless: true, args: ['--no-sandbox'] });
const page = await browser.newPage();
await page.setViewport({ width: 1920, height: 1080 });
await page.goto(url, { waitUntil: 'networkidle0' });
await page.screenshot({ path: '/path/to/output.png', fullPage: true });
await browser.close();
```

**DOM Scraping (Puppeteer):**
```javascript
const data = await page.evaluate(() => {
  const items = [...document.querySelectorAll('.item')];
  return items.map(el => ({
    title: el.querySelector('h2')?.textContent,
    link: el.querySelector('a')?.href,
    price: el.querySelector('.price')?.textContent
  }));
});
```

**Click + Fill Forms:**
```javascript
await page.type('#username', 'admin');
await page.type('#password', 'secret');
await page.click('#login-btn');
await page.waitForNavigation({ waitUntil: 'networkidle0' });
```

**HTTP Request via Cheerio (no browser, fast):**
```javascript
const http = require('http');
const cheerio = require('cheerio');
http.get(url, res => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const $ = cheerio.load(data);
    console.log($('title').text());
  });
});
```

**Playwright - WaitFor + Intercept:**
```javascript
const { chromium } = require('playwright');
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();

// Intercept network requests
page.on('request', req => {
  if (req.resourceType() === 'image') req.abort();
  else req.continue();
});

// Wait for specific selector
await page.goto(url);
await page.waitForSelector('.content-loaded');
const html = await page.content();
await browser.close();
```

## When to Use What

| Tool | Use when |
|---|---|
| **Puppeteer** | Complex DOM interaction, screenshots, login flows, SPAs |
| **Playwright** | Multi-browser, network interception, tracing, parallel |
| **cheerio** | Static HTML parsing (fast, no browser) |
| **jsdom** | DOM simulation for testing |
| **OpenClaw browser tool** | Simple page navigation + snapshot (built-in) |
| **web_fetch** | Extract text content from URLs (built-in) |

## Full Script Template

```bash
#!/bin/bash
URL="${1:-https://example.com}"
cd /root/.openclaw/browser-env
node << 'EOF'
const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();

  // Set viewport
  await page.setViewport({ width: 1920, height: 1080 });

  // Navigate with timeout
  await page.goto(process.env.URL || 'https://example.com', {
    waitUntil: 'networkidle0',
    timeout: 30000
  });

  // Interact
  // await page.wait...

  // Extract
  const title = await page.title();
  console.log('Title:', title);

  await browser.close();
})();
EOF
```

## Error Handling

- `ERR_CONNECTION_REFUSED` → Le serveur web n'est pas lancé
- `TimeoutError` → Augmenter timeout dans `page.goto()`
- `net::ERR_CERT_...` → Ajouter `--ignore-certificate-errors` dans args
