'use strict';

const crypto = require('crypto');

// Unambiguous alphabet (no 0/O/1/I/l) for short, human-safe tokens.
const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

function newToken(len = 8) {
  const bytes = crypto.randomBytes(len);
  let out = '';
  for (let i = 0; i < len; i++) out += ALPHABET[bytes[i] % ALPHABET.length];
  return out;
}

module.exports = { newToken };
