require('dotenv').config();

const crypto = require('node:crypto');
const path = require('node:path');
const express = require('express');
const mysql = require('mysql2/promise');
const { validateEmail, validatePerson } = require('./validation');

const app = express();
const webDirectory = path.join(__dirname, '..', 'web');
const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'pulso_vital',
  waitForConnections: true,
  connectionLimit: 5,
  queueLimit: 0,
  charset: 'utf8mb4',
  dateStrings: true
});

const demoGivenNames = ['Valentina', 'Mateo', 'Lucía', 'Samuel', 'Camila', 'Tomás', 'Sara', 'Nicolás'];
const demoFamilyNames = ['Rojas', 'Mendoza', 'Castro', 'Vargas', 'Navarro', 'Cárdenas', 'Pardo', 'Salazar'];

app.disable('x-powered-by');
app.use(express.json({ limit: '16kb' }));

function validationError(res, errors) {
  return res.status(400).json({ error: errors.join(' ') });
}

function handleApiError(res, error, fallbackMessage) {
  if (error.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({ error: 'Ya existe un registro con ese documento o correo.' });
  }
  console.error(fallbackMessage, error);
  return res.status(500).json({ error: fallbackMessage });
}

async function seedDemoAdministrators() {
  const [[{ total }]] = await pool.query('SELECT COUNT(*) AS total FROM administrativos');
  if (Number(total) > 0) return;

  const [roles] = await pool.query(
    'SELECT id_cargo FROM cargos_administrativos ORDER BY id_cargo'
  );
  const roleIds = roles.map((role) => role.id_cargo);
  if (roleIds.length === 0) {
    throw new Error('No hay cargos cargados. Ejecuta sql/04_registro_app.sql.');
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const [existingAdministrators] = await connection.query(
      'SELECT id_administrativo FROM administrativos LIMIT 1 FOR UPDATE'
    );
    if (existingAdministrators.length > 0) {
      await connection.commit();
      return;
    }

    for (let index = 0; index < 5; index += 1) {
      const suffix = crypto.randomBytes(4).toString('hex');
      const givenNames = `${demoGivenNames[crypto.randomInt(demoGivenNames.length)]} ${demoGivenNames[crypto.randomInt(demoGivenNames.length)]}`;
      const familyNames = `${demoFamilyNames[crypto.randomInt(demoFamilyNames.length)]} ${demoFamilyNames[crypto.randomInt(demoFamilyNames.length)]}`;
      const roleId = roleIds[crypto.randomInt(roleIds.length)];
      const [{ insertId }] = await connection.execute(
        'INSERT INTO administrativos (tipo_documento, numero_documento) VALUES (?, ?)',
        ['CC', `DEMO-${suffix.toUpperCase()}`]
      );
      await connection.execute(
        'INSERT INTO administrativo_nombres_hist (id_administrativo, valido_desde, nombres) VALUES (?, NOW(), ?)',
        [insertId, givenNames]
      );
      await connection.execute(
        'INSERT INTO administrativo_apellidos_hist (id_administrativo, valido_desde, apellidos) VALUES (?, NOW(), ?)',
        [insertId, familyNames]
      );
      await connection.execute(
        'INSERT INTO administrativo_cargo_hist (id_administrativo, valido_desde, id_cargo) VALUES (?, NOW(), ?)',
        [insertId, roleId]
      );
      await connection.execute(
        'INSERT INTO administrativo_telefono_hist (id_administrativo, valido_desde, telefono) VALUES (?, NOW(), ?)',
        [insertId, `000-${crypto.randomInt(1000000).toString().padStart(6, '0')}`]
      );
      await connection.execute(
        'INSERT INTO administrativo_correo_hist (id_administrativo, valido_desde, correo) VALUES (?, NOW(), ?)',
        [insertId, `admin-${suffix}@example.test`]
      );
    }
    await connection.commit();
    console.info('Se crearon cinco registros ficticios de personal para demostración.');
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

app.get('/api/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: process.env.DB_NAME || 'pulso_vital' });
  } catch (error) {
    handleApiError(res, error, 'No se pudo conectar con MySQL.');
  }
});

app.get('/api/patients', async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        p.id_paciente AS id,
        p.tipo_documento AS documentType,
        p.numero_documento AS documentNumber,
        p.fecha_nacimiento AS birthDate,
        p.creado_en AS createdAt,
        names.nombres AS givenNames,
        surnames.apellidos AS familyNames,
        (
          SELECT phone.telefono
          FROM paciente_telefono_hist AS phone
          WHERE phone.id_paciente = p.id_paciente AND phone.valido_hasta IS NULL
          ORDER BY phone.valido_desde DESC
          LIMIT 1
        ) AS phone
      FROM pacientes AS p
      LEFT JOIN paciente_nombres_hist AS names
        ON names.id_paciente = p.id_paciente AND names.valido_hasta IS NULL
      LEFT JOIN paciente_apellidos_hist AS surnames
        ON surnames.id_paciente = p.id_paciente AND surnames.valido_hasta IS NULL
      ORDER BY p.creado_en DESC, p.id_paciente DESC
    `);
    res.json(rows);
  } catch (error) {
    handleApiError(res, error, 'No se pudieron cargar los pacientes.');
  }
});

app.post('/api/patients', async (req, res) => {
  const body = req.body || {};
  const errors = validatePerson(body, true);
  if (errors.length) return validationError(res, errors);

  const { documentType, documentNumber, givenNames, familyNames, birthDate, phone } = body;
  let connection;
  try {
    connection = await pool.getConnection();
    await connection.beginTransaction();
    const [{ insertId }] = await connection.execute(
      'INSERT INTO pacientes (tipo_documento, numero_documento, fecha_nacimiento) VALUES (?, ?, ?)',
      [documentType, documentNumber.trim(), birthDate]
    );
    await connection.execute(
      'INSERT INTO paciente_nombres_hist (id_paciente, valido_desde, nombres) VALUES (?, NOW(), ?)',
      [insertId, givenNames.trim()]
    );
    await connection.execute(
      'INSERT INTO paciente_apellidos_hist (id_paciente, valido_desde, apellidos) VALUES (?, NOW(), ?)',
      [insertId, familyNames.trim()]
    );
    if (phone && phone.trim()) {
      await connection.execute(
        'INSERT INTO paciente_telefono_hist (id_paciente, telefono, valido_desde, tipo_telefono) VALUES (?, ?, NOW(), ?)',
        [insertId, phone.trim(), 'MOVIL']
      );
    }
    await connection.commit();
    res.status(201).json({ id: insertId, message: 'Paciente registrado correctamente.' });
  } catch (error) {
    if (connection) await connection.rollback();
    handleApiError(res, error, 'No se pudo guardar el paciente.');
  } finally {
    if (connection) connection.release();
  }
});

app.get('/api/administrators', async (_req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        staff.id_administrativo AS id,
        staff.tipo_documento AS documentType,
        staff.numero_documento AS documentNumber,
        staff.creado_en AS createdAt,
        names.nombres AS givenNames,
        surnames.apellidos AS familyNames,
        role_name.nombre AS role,
        (
          SELECT contact.telefono
          FROM administrativo_telefono_hist AS contact
          WHERE contact.id_administrativo = staff.id_administrativo
            AND contact.valido_hasta IS NULL
          ORDER BY contact.valido_desde DESC
          LIMIT 1
        ) AS phone,
        (
          SELECT contact.correo
          FROM administrativo_correo_hist AS contact
          WHERE contact.id_administrativo = staff.id_administrativo
            AND contact.valido_hasta IS NULL
          ORDER BY contact.valido_desde DESC
          LIMIT 1
        ) AS email
      FROM administrativos AS staff
      LEFT JOIN administrativo_nombres_hist AS names
        ON names.id_administrativo = staff.id_administrativo AND names.valido_hasta IS NULL
      LEFT JOIN administrativo_apellidos_hist AS surnames
        ON surnames.id_administrativo = staff.id_administrativo AND surnames.valido_hasta IS NULL
      LEFT JOIN administrativo_cargo_hist AS assignment
        ON assignment.id_administrativo = staff.id_administrativo AND assignment.valido_hasta IS NULL
      LEFT JOIN cargos_administrativos AS role_name
        ON role_name.id_cargo = assignment.id_cargo
      ORDER BY staff.creado_en DESC, staff.id_administrativo DESC
    `);
    res.json(rows);
  } catch (error) {
    handleApiError(res, error, 'No se pudieron cargar los administrativos.');
  }
});

app.get('/api/roles', async (_req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT id_cargo AS id, nombre AS name FROM cargos_administrativos ORDER BY nombre'
    );
    res.json(rows);
  } catch (error) {
    handleApiError(res, error, 'No se pudieron cargar los cargos administrativos.');
  }
});

app.post('/api/administrators', async (req, res) => {
  const body = req.body || {};
  const errors = validatePerson(body, false);
  if (body.email && !validateEmail(body.email)) errors.push('Escribe un correo electrónico válido.');
  if (!Number.isInteger(Number(body.roleId)) || Number(body.roleId) < 1) {
    errors.push('Selecciona un cargo válido.');
  }
  if (errors.length) return validationError(res, errors);

  const { documentType, documentNumber, givenNames, familyNames, phone, email, roleId } = body;
  let connection;
  try {
    connection = await pool.getConnection();
    await connection.beginTransaction();
    const [{ insertId }] = await connection.execute(
      'INSERT INTO administrativos (tipo_documento, numero_documento) VALUES (?, ?)',
      [documentType, documentNumber.trim()]
    );
    await connection.execute(
      'INSERT INTO administrativo_nombres_hist (id_administrativo, valido_desde, nombres) VALUES (?, NOW(), ?)',
      [insertId, givenNames.trim()]
    );
    await connection.execute(
      'INSERT INTO administrativo_apellidos_hist (id_administrativo, valido_desde, apellidos) VALUES (?, NOW(), ?)',
      [insertId, familyNames.trim()]
    );
    await connection.execute(
      'INSERT INTO administrativo_cargo_hist (id_administrativo, valido_desde, id_cargo) VALUES (?, NOW(), ?)',
      [insertId, Number(roleId)]
    );
    if (phone && phone.trim()) {
      await connection.execute(
        'INSERT INTO administrativo_telefono_hist (id_administrativo, valido_desde, telefono) VALUES (?, NOW(), ?)',
        [insertId, phone.trim()]
      );
    }
    if (email && email.trim()) {
      await connection.execute(
        'INSERT INTO administrativo_correo_hist (id_administrativo, valido_desde, correo) VALUES (?, NOW(), ?)',
        [insertId, email.trim().toLowerCase()]
      );
    }
    await connection.commit();
    res.status(201).json({ id: insertId, message: 'Administrativo registrado correctamente.' });
  } catch (error) {
    if (connection) await connection.rollback();
    if (error.code === 'ER_NO_REFERENCED_ROW_2') {
      return res.status(400).json({ error: 'El cargo seleccionado ya no existe. Actualiza la página.' });
    }
    handleApiError(res, error, 'No se pudo guardar el administrativo.');
  } finally {
    if (connection) connection.release();
  }
});

app.get('/', (_req, res) => res.sendFile(path.join(webDirectory, 'index.html')));
app.use(express.static(webDirectory, { extensions: ['html'] }));

async function start() {
  try {
    await pool.query('SELECT 1');
    await seedDemoAdministrators();
    const host = process.env.HOST || '127.0.0.1';
    const port = Number(process.env.PORT || 3000);
    app.listen(port, host, () => {
      console.info(`Pulso Vital está disponible en http://${host}:${port}`);
    });
  } catch (error) {
    console.error('No se pudo iniciar Pulso Vital. Comprueba MySQL y ejecuta los scripts SQL indicados en README.md.', error);
    await pool.end();
    process.exitCode = 1;
  }
}

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, async () => {
    await pool.end();
    process.exit(0);
  });
}

start();
