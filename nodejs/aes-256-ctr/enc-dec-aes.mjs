#!/usr/bin/env node

import crypto from 'crypto';

const PASSWORD_LENGTH = 128
const SALT_LENGTH = 16
const IV_LENGTH = 16
const KEY_LENGTH = IV_LENGTH * 2

const algorithm = 'aes-256-ctr'
const password = crypto.randomBytes(PASSWORD_LENGTH)
const rounds = 10_000
const salt = crypto.randomBytes(SALT_LENGTH)
const iv = crypto.randomBytes(IV_LENGTH)
const key = crypto.pbkdf2Sync(password, salt, rounds, KEY_LENGTH, 'sha256')
const input = Buffer.from('a')

// encrypt
const cipher = crypto.createCipheriv(algorithm, key, iv);
let encrypted = cipher.update(input);
encrypted = Buffer.concat([encrypted, cipher.final()]);

// decrypt
const decipher = crypto.createDecipheriv(algorithm, key, iv);
let decrypted = decipher.update(encrypted);
decrypted = Buffer.concat([decrypted, decipher.final()]);

console.log({
  input: input.toString(),
  encrypted: encrypted.toString(),
  decrypted: decrypted.toString()
})
