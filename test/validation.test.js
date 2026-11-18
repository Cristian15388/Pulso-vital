const test = require('node:test');
const assert = require('node:assert/strict');
const { validateEmail, validatePerson } = require('../server/validation');

const validPerson = {
  documentType: 'CC',
  documentNumber: 'DEMO-1234',
  givenNames: 'Ana María',
  familyNames: 'Pérez Soto'
};

test('accepts a complete patient registration with a valid past birth date', () => {
  assert.deepEqual(validatePerson({ ...validPerson, birthDate: '1990-06-15', phone: '3001234567' }, true), []);
});

test('rejects invalid document type and future birth date', () => {
  const errors = validatePerson({
    ...validPerson,
    documentType: 'INVALID',
    birthDate: '2999-01-01'
  }, true);

  assert.equal(errors.length, 2);
  assert.match(errors[0], /tipo de documento/);
  assert.match(errors[1], /fecha de nacimiento/);
});

test('allows an administrative record without a birth date or optional contact fields', () => {
  assert.deepEqual(validatePerson(validPerson, false), []);
});

test('validates optional administrative email addresses', () => {
  assert.equal(validateEmail('personal@example.test'), true);
  assert.equal(validateEmail('not-an-email'), false);
});
