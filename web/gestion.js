const state = {
  view: 'patients',
  patients: [],
  administrators: [],
  roles: []
};

const elements = {
  status: document.querySelector('#database-status'),
  statusText: document.querySelector('#database-status-text'),
  patientCount: document.querySelector('#patient-count'),
  administratorCount: document.querySelector('#administrator-count'),
  patientTabCount: document.querySelector('#patient-tab-count'),
  administratorTabCount: document.querySelector('#administrator-tab-count'),
  addRecord: document.querySelector('#add-record'),
  addRecordLabel: document.querySelector('#add-record-label'),
  search: document.querySelector('#search-records'),
  refresh: document.querySelector('#refresh-records'),
  export: document.querySelector('#export-records'),
  tabs: [...document.querySelectorAll('.tab')],
  tableHead: document.querySelector('#records-head'),
  tableBody: document.querySelector('#records-body'),
  resultCount: document.querySelector('#table-result-count'),
  message: document.querySelector('#message-bar'),
  dialog: document.querySelector('#record-dialog'),
  form: document.querySelector('#record-form'),
  dialogTitle: document.querySelector('#dialog-title'),
  dialogEyebrow: document.querySelector('#dialog-eyebrow'),
  formIntro: document.querySelector('#form-intro'),
  formError: document.querySelector('#form-error'),
  save: document.querySelector('#save-record'),
  roleSelect: document.querySelector('#role-select')
};

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (character) => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;'
  })[character]);
}

function formatDate(value) {
  if (!value) return '—';
  const date = new Date(`${String(value).slice(0, 10)}T12:00:00`);
  return Number.isNaN(date.getTime())
    ? '—'
    : new Intl.DateTimeFormat('es-CO', { day: '2-digit', month: 'short', year: 'numeric' }).format(date);
}

function currentRows() {
  return state.view === 'patients' ? state.patients : state.administrators;
}

function searchableText(record) {
  return [
    record.givenNames,
    record.familyNames,
    record.documentType,
    record.documentNumber,
    record.phone,
    record.email,
    record.role
  ].filter(Boolean).join(' ').toLocaleLowerCase('es');
}

function visibleRows() {
  const query = elements.search.value.trim().toLocaleLowerCase('es');
  return currentRows().filter((record) => !query || searchableText(record).includes(query));
}

function renderTable() {
  const isPatientView = state.view === 'patients';
  const columns = isPatientView
    ? ['ID', 'Paciente', 'Documento', 'Nacimiento', 'Teléfono', 'Fecha de ingreso']
    : ['ID', 'Administrativo', 'Documento', 'Cargo', 'Teléfono', 'Correo electrónico', 'Fecha de ingreso'];
  const rows = visibleRows();

  elements.tableHead.innerHTML = `<tr>${columns.map((column) => `<th scope="col">${column}</th>`).join('')}</tr>`;
  if (rows.length === 0) {
    const emptyMessage = elements.search.value.trim()
      ? 'No se encontraron registros con esa búsqueda.'
      : isPatientView ? 'Todavía no hay pacientes registrados. Usa “Registrar paciente” para agregar el primero.'
        : 'No hay administrativos registrados.';
    elements.tableBody.innerHTML = `<tr><td class="table-message" colspan="${columns.length}">${emptyMessage}</td></tr>`;
  } else {
    elements.tableBody.innerHTML = rows.map((record) => {
      const name = `${record.givenNames || ''} ${record.familyNames || ''}`.trim() || 'Nombre pendiente';
      const cells = isPatientView
        ? [
            record.id,
            `<span class="person-cell"><span class="row-avatar patient-avatar">${escapeHtml(initials(name))}</span><b>${escapeHtml(name)}</b></span>`,
            `<span class="document-cell"><b>${escapeHtml(record.documentType)}</b>${escapeHtml(record.documentNumber)}</span>`,
            escapeHtml(formatDate(record.birthDate)),
            escapeHtml(record.phone || '—'),
            escapeHtml(formatDate(record.createdAt))
          ]
        : [
            record.id,
            `<span class="person-cell"><span class="row-avatar staff-avatar">${escapeHtml(initials(name))}</span><b>${escapeHtml(name)}</b></span>`,
            `<span class="document-cell"><b>${escapeHtml(record.documentType)}</b>${escapeHtml(record.documentNumber)}</span>`,
            `<span class="role-pill">${escapeHtml(record.role || 'Sin cargo')}</span>`,
            escapeHtml(record.phone || '—'),
            escapeHtml(record.email || '—'),
            escapeHtml(formatDate(record.createdAt))
          ];
      return `<tr>${cells.map((cell, index) => `<td${index === 0 ? ' class="id-cell"' : ''}>${cell}</td>`).join('')}</tr>`;
    }).join('');
  }
  elements.resultCount.textContent = `Mostrando ${rows.length} de ${currentRows().length} registros`;
  elements.patientCount.textContent = state.patients.length;
  elements.administratorCount.textContent = state.administrators.length;
  elements.patientTabCount.textContent = state.patients.length;
  elements.administratorTabCount.textContent = state.administrators.length;
}

function initials(name) {
  return name.split(/\s+/).filter(Boolean).slice(0, 2).map((part) => part[0]).join('').toLocaleUpperCase('es') || 'PV';
}

function setStatus(connected, message) {
  elements.status.classList.toggle('is-online', connected);
  elements.status.classList.toggle('is-offline', !connected);
  elements.statusText.textContent = message;
}

function showMessage(message, type) {
  elements.message.textContent = message;
  elements.message.className = `message-bar ${type}`;
  elements.message.hidden = false;
}

function clearMessage() {
  elements.message.hidden = true;
  elements.message.textContent = '';
  elements.message.className = 'message-bar';
}

async function requestJson(url, options = {}) {
  const response = await fetch(url, {
    headers: { 'Content-Type': 'application/json', ...options.headers },
    ...options
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.error || `La solicitud falló (${response.status}).`);
  return data;
}

async function loadRoles() {
  state.roles = await requestJson('/api/roles');
  elements.roleSelect.innerHTML = '<option value="">Selecciona un cargo</option>'
    + state.roles.map((role) => `<option value="${role.id}">${escapeHtml(role.name)}</option>`).join('');
}

async function loadRecords() {
  elements.refresh.disabled = true;
  elements.tableBody.innerHTML = '<tr><td class="table-message" colspan="7">Cargando registros…</td></tr>';
  try {
    const [health, patients, administrators] = await Promise.all([
      requestJson('/api/health'),
      requestJson('/api/patients'),
      requestJson('/api/administrators')
    ]);
    state.patients = patients;
    state.administrators = administrators;
    setStatus(true, `Conectado · ${health.database}`);
    clearMessage();
    renderTable();
  } catch (error) {
    setStatus(false, 'Sin conexión con MySQL');
    showMessage(`${error.message} Revisa que el servidor MySQL esté iniciado y que la configuración de .env sea correcta.`, 'message-error');
    elements.tableBody.innerHTML = '<tr><td class="table-message" colspan="7">No se pudieron cargar los datos. Cuando MySQL esté conectado, pulsa “Actualizar”.</td></tr>';
    elements.resultCount.textContent = 'No se pudo consultar la base de datos';
    console.error('Error al cargar los registros:', error);
  } finally {
    elements.refresh.disabled = false;
  }
}

function setView(view) {
  state.view = view;
  elements.tabs.forEach((tab) => {
    const isActive = tab.dataset.view === view;
    tab.classList.toggle('is-active', isActive);
    tab.setAttribute('aria-selected', String(isActive));
  });
  const isPatientView = view === 'patients';
  elements.addRecordLabel.textContent = isPatientView ? 'Registrar paciente' : 'Agregar administrativo';
  elements.search.placeholder = isPatientView ? 'Buscar por nombre o documento' : 'Buscar por nombre, cargo o documento';
  renderTable();
  clearMessage();
}

function openForm() {
  const isPatientView = state.view === 'patients';
  elements.form.reset();
  elements.formError.hidden = true;
  elements.formError.textContent = '';
  elements.dialogTitle.textContent = isPatientView ? 'Registrar paciente' : 'Agregar administrativo';
  elements.dialogEyebrow.textContent = isPatientView ? 'NUEVO PACIENTE' : 'NUEVO ADMINISTRATIVO';
  elements.formIntro.textContent = isPatientView
    ? 'Completa los datos de identificación y contacto del paciente.'
    : 'Completa los datos del administrativo que trabaja en la clínica.';
  document.querySelectorAll('.patient-field').forEach((field) => {
    field.hidden = !isPatientView;
    field.querySelectorAll('input, select').forEach((input) => { input.required = isPatientView; });
  });
  document.querySelectorAll('.administrator-field').forEach((field) => {
    field.hidden = isPatientView;
    field.querySelectorAll('input, select').forEach((input) => { input.required = !isPatientView && input.name === 'roleId'; });
  });
  elements.dialog.showModal();
  elements.dialog.querySelector('select[name="documentType"]').focus();
}

function closeForm() {
  if (elements.dialog.open) elements.dialog.close();
}

async function saveRecord(event) {
  event.preventDefault();
  elements.formError.hidden = true;
  if (!elements.form.reportValidity()) return;

  const formData = new FormData(elements.form);
  const record = Object.fromEntries(formData.entries());
  const isPatientView = state.view === 'patients';
  const endpoint = isPatientView ? '/api/patients' : '/api/administrators';
  elements.save.disabled = true;
  elements.save.textContent = 'Guardando…';

  try {
    const result = await requestJson(endpoint, {
      method: 'POST',
      body: JSON.stringify(record)
    });
    closeForm();
    await loadRecords();
    showMessage(result.message, 'message-success');
  } catch (error) {
    elements.formError.textContent = error.message;
    elements.formError.hidden = false;
  } finally {
    elements.save.disabled = false;
    elements.save.textContent = 'Guardar registro';
  }
}

function csvCell(value) {
  let text = String(value ?? '');
  if (/^[=+\-@]/.test(text)) text = `'${text}`;
  return `"${text.replace(/"/g, '""')}"`;
}

function exportCsv() {
  const isPatientView = state.view === 'patients';
  const headers = isPatientView
    ? ['ID', 'Tipo de documento', 'Documento', 'Nombres', 'Apellidos', 'Fecha de nacimiento', 'Teléfono', 'Fecha de ingreso']
    : ['ID', 'Tipo de documento', 'Documento', 'Nombres', 'Apellidos', 'Cargo', 'Teléfono', 'Correo', 'Fecha de ingreso'];
  const data = visibleRows().map((record) => isPatientView
    ? [record.id, record.documentType, record.documentNumber, record.givenNames, record.familyNames, record.birthDate, record.phone, record.createdAt]
    : [record.id, record.documentType, record.documentNumber, record.givenNames, record.familyNames, record.role, record.phone, record.email, record.createdAt]);
  const csv = `\uFEFF${[headers, ...data].map((row) => row.map(csvCell).join(',')).join('\r\n')}`;
  const url = URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8' }));
  const link = document.createElement('a');
  link.href = url;
  link.download = `${state.view}-pulso-vital.csv`;
  link.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

elements.tabs.forEach((tab) => tab.addEventListener('click', () => setView(tab.dataset.view)));
elements.addRecord.addEventListener('click', openForm);
elements.refresh.addEventListener('click', loadRecords);
elements.export.addEventListener('click', exportCsv);
elements.search.addEventListener('input', renderTable);
elements.form.addEventListener('submit', saveRecord);
document.querySelector('#close-dialog').addEventListener('click', closeForm);
document.querySelector('#cancel-dialog').addEventListener('click', closeForm);
elements.dialog.addEventListener('click', (event) => {
  if (event.target === elements.dialog) closeForm();
});

loadRoles().catch((error) => {
  elements.roleSelect.innerHTML = '<option value="">No se pudieron cargar los cargos</option>';
  showMessage(error.message, 'message-error');
  console.error('Error al cargar los cargos administrativos:', error);
});
loadRecords();
