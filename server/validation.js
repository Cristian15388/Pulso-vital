const documentTypes = new Set(['CC', 'TI', 'CE', 'PA', 'RC']);

function isText(value, minLength, maxLength) {
  return typeof value === 'string'
    && value.trim().length >= minLength
    && value.trim().length <= maxLength;
}

function validatePerson(body = {}, includeBirthDate) {
  const errors = [];
  if (!documentTypes.has(body.documentType)) errors.push('Selecciona un tipo de documento válido.');
  if (!isText(body.documentNumber, 3, 30)) errors.push('El documento debe tener entre 3 y 30 caracteres.');
  if (!isText(body.givenNames, 2, 100)) errors.push('Escribe los nombres (máximo 100 caracteres).');
  if (!isText(body.familyNames, 2, 100)) errors.push('Escribe los apellidos (máximo 100 caracteres).');
  if (includeBirthDate) {
    if (typeof body.birthDate !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(body.birthDate)) {
      errors.push('La fecha de nacimiento no es válida.');
    } else {
      const birthDate = new Date(`${body.birthDate}T00:00:00Z`);
      if (Number.isNaN(birthDate.getTime()) || birthDate.toISOString().slice(0, 10) !== body.birthDate
          || birthDate > new Date()) {
        errors.push('La fecha de nacimiento debe ser una fecha válida que no esté en el futuro.');
      }
    }
  }
  if (body.phone !== undefined && body.phone !== '' && !isText(body.phone, 5, 30)) {
    errors.push('El teléfono debe tener entre 5 y 30 caracteres.');
  }
  return errors;
}

function validateEmail(email) {
  return typeof email === 'string'
    && email.length <= 254
    && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

module.exports = { validateEmail, validatePerson };
