'use strict';

// ─────────────────────────────────────────────────────────────
//  EVENT CONFIG — bitta joyda o'zgartiring, hamma biletga tushadi.
//  Change these once per event; every generated ticket uses them.
// ─────────────────────────────────────────────────────────────
module.exports = {
  event: {
    badge:     'OFFLINE',
    date:      '18-iyul',
    time:      '14:00–18:00',
    venue:     'M-Factor',
    speaker:   'Yusufbay Kadirov',
    eventSub:  'AI OFFLINE TRENING · 1 KUNLIK MASTER KLASS',
    photo:     'assets/expert.jpg',        // relative to src/
  },

  // Default tarif when the seller doesn't specify one.
  defaultTarif: 'Standart',

  // Brand block (bottom-left of the stub).
  brand: {
    mark: 'AI',
    name: "Sun'iy Intellekt",
    url:  'suniyintellect.uz',
  },

  // Static labels on the ticket (Uzbek).
  labels: {
    attendee: 'Ishtirokchi',
    venue:    'Manzil',
    tarif:    'Tarif',
    number:   'Bilet raqami',
    qr:       'Kirishda skanerlang',
  },

  // Public base URL of THIS service — the QR link points here:
  //   {PUBLIC_URL}/t/{token}
  // Set PUBLIC_URL in the environment after you deploy.
  publicUrl: process.env.PUBLIC_URL || 'http://localhost:3000',
};
