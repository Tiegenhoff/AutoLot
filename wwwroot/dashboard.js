const message = document.querySelector('#dashboard-message');
const dashboardPanel = document.querySelector('#dashboard-panel');
let antiforgeryToken;

async function getErrorMessage(response) {
  const result = await response.json().catch(() => ({}));
  if (Array.isArray(result.errors)) return result.errors.join(' ');
  if (result.errors && typeof result.errors === 'object') {
    const errors = Object.values(result.errors).flat();
    if (errors.length) return errors.join(' ');
  }
  return result.message || result.detail || result.title || 'The request could not be completed.';
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

async function initialize() {
  try {
    const accountResponse = await fetch('/api/account/me');
    if (accountResponse.status === 401) {
      window.location.replace('/account.html');
      return;
    }
    if (!accountResponse.ok) {
      throw new Error(await getErrorMessage(accountResponse));
    }

    const account = await accountResponse.json();
    document.querySelector('#account-name').textContent = account.fullName;
    document.querySelector('#account-email').textContent = account.email;
    dashboardPanel.hidden = false;

    const historyResponse = await fetch('/api/customer/requests');
    if (!historyResponse.ok) {
      message.textContent = `Your account is signed in, but request history could not be loaded: ${await getErrorMessage(historyResponse)}`;
      return;
    }

    const history = await historyResponse.json();
    renderHistory(document.querySelector('#reservations-history'), history.reservations, 'reservations');
    renderHistory(document.querySelector('#test-drives-history'), history.testDrives, 'test-drive requests');
    message.textContent = 'Your request history is up to date.';
  } catch (error) {
    message.textContent = error.message || 'Unable to connect to the account service.';
  }
}

document.querySelector('#logout-button').addEventListener('click', async () => {
  message.textContent = 'Signing out…';
  try {
    const tokenResponse = await fetch('/api/account/antiforgery', { cache: 'no-store' });
    if (!tokenResponse.ok) throw new Error('Unable to prepare a secure sign-out request.');
    antiforgeryToken = (await tokenResponse.json()).token;

    const response = await fetch('/api/account/logout', {
      method: 'POST',
      headers: { 'X-CSRF-TOKEN': antiforgeryToken }
    });
    if (!response.ok) {
      message.textContent = await getErrorMessage(response);
      return;
    }

    window.location.replace('/account.html');
  } catch (error) {
    message.textContent = error.message || 'Unable to sign out.';
  }
});

initialize();
