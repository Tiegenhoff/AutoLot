const message = document.querySelector('#account-message');
const accountForms = document.querySelector('#account-forms');
const accountPanel = document.querySelector('#account-panel');
let antiforgeryToken;

async function getErrorMessage(response) {
  const result = await response.json().catch(() => ({}));
  if (Array.isArray(result.errors)) return result.errors.join(' ');
  return result.message || 'The request could not be completed.';
}

async function postJson(url, payload) {
  return fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': antiforgeryToken
    },
    body: JSON.stringify(payload)
  });
}

function showAccount(account) {
  accountForms.hidden = true;
  accountPanel.hidden = false;
  document.querySelector('#account-name').textContent = account.fullName;
  document.querySelector('#account-email').textContent = account.email;
}

function renderHistory(container, items, type) {
  container.replaceChildren();
  if (!items.length) {
    const emptyMessage = document.createElement('p');
    emptyMessage.textContent = `No ${type} yet.`;
    container.append(emptyMessage);
    return;
  }

  const list = document.createElement('ul');
  for (const item of items) {
    const entry = document.createElement('li');
    const link = document.createElement('a');
    link.href = `/vehicle.html?id=${encodeURIComponent(item.vehicleId)}`;
    link.textContent = `${item.year} ${item.make} ${item.model}`;

    const status = document.createElement('span');
    status.className = 'badge';
    status.textContent = item.status;

    const date = document.createElement('p');
    const timestamp = type === 'reservations' ? item.requestDate : item.preferredDateTime;
    const label = type === 'reservations' ? 'Requested' : 'Preferred test drive';
    date.textContent = `${label}: ${new Intl.DateTimeFormat(undefined, {
      dateStyle: 'medium',
      timeStyle: 'short'
    }).format(new Date(timestamp))}`;

    entry.append(link, document.createTextNode(' '), status, date);
    list.append(entry);
  }
  container.append(list);
}

async function loadHistory() {
  message.textContent = 'Loading your request history…';
  const response = await fetch('/api/customer/requests');
  if (!response.ok) {
    message.textContent = await getErrorMessage(response);
    return;
  }

  const history = await response.json();
  renderHistory(document.querySelector('#reservations-history'), history.reservations, 'reservations');
  renderHistory(document.querySelector('#test-drives-history'), history.testDrives, 'test-drive requests');
  message.textContent = 'Your request history is up to date.';
}

async function initialize() {
  try {
    const tokenResponse = await fetch('/api/account/antiforgery', { cache: 'no-store' });
    if (!tokenResponse.ok) throw new Error('Unable to prepare secure account requests.');
    antiforgeryToken = (await tokenResponse.json()).token;

    const response = await fetch('/api/account/me');
    if (response.ok) {
      showAccount(await response.json());
      await loadHistory();
    } else if (response.status !== 401) {
      message.textContent = 'Unable to load your account. Please try again.';
    }
  } catch (error) {
    message.textContent = error.message || 'Unable to connect to the account service.';
  }
}

document.querySelector('#login-form').addEventListener('submit', async event => {
  event.preventDefault();
  message.textContent = 'Signing in…';
  const form = event.currentTarget;
  const data = new FormData(form);
  const response = await postJson('/api/account/login', {
    email: data.get('email'),
    password: data.get('password'),
    rememberMe: data.get('rememberMe') !== null
  });

  if (!response.ok) {
    message.textContent = await getErrorMessage(response);
    return;
  }

  form.reset();
  showAccount(await response.json());
  await loadHistory();
});

document.querySelector('#register-form').addEventListener('submit', async event => {
  event.preventDefault();
  message.textContent = 'Creating your account…';
  const form = event.currentTarget;
  const data = new FormData(form);
  const response = await postJson('/api/account/register', {
    fullName: data.get('fullName'),
    email: data.get('email'),
    phone: data.get('phone'),
    password: data.get('password')
  });

  if (!response.ok) {
    message.textContent = await getErrorMessage(response);
    return;
  }

  form.reset();
  showAccount(await response.json());
  await loadHistory();
});

document.querySelector('#logout-button').addEventListener('click', async () => {
  message.textContent = 'Signing out…';
  const response = await postJson('/api/account/logout', {});
  if (!response.ok) {
    message.textContent = await getErrorMessage(response);
    return;
  }

  accountPanel.hidden = true;
  accountForms.hidden = false;
  message.textContent = 'You have signed out.';
});

initialize();
