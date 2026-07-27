'use strict';

// ─────────────────────────────────────────────────────────────
//  EVENT CONFIG — change once per event; every ticket uses these.
// ─────────────────────────────────────────────────────────────
module.exports = {
  event: {
    badge:    'OFFLINE',
    date:     '2-avgust',
    time:     '14:00',
    venue:    'Hyatt Regency',
    entry:    '13:30',                       // kirish (eshiklar ochilishi)
    speaker:  'Yusufbay Kadirov',
    eventSub: 'AI OFFLINE TRENING · 1 KUNLIK MASTER KLASS',
    footer:   'Bilet faqat 1 kishi uchun',   // stub tagidagi eslatma
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
    attendee: 'ISHTIROKCHI',
    venue:    'MANZIL',
    tarif:    'TARIF',
    number:   'BILET RAQAMI',
  },
};
