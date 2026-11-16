const message = document.querySelector('#account-message');
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

async function initialize() {
  try {
    const tokenResponse = await fetch('/api/account/antiforgery', { cache: 'no-store' });
    if (!tokenResponse.ok) throw new Error('Unable to prepare secure account requests.');
    antiforgeryToken = (await tokenResponse.json()).token;

    const response = await fetch('/api/account/me');
    if (response.ok) {
      window.location.replace('/dashboard.html');
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
  window.location.assign('/dashboard.html');
});

document.querySelector('#register-form').addEventListener('submit', async event => {
  event.preventDefault();
  message.textContent = 'Creating your account…';
  const form = event.currentTarget;
  const data = new FormData(form);
  const response = await postJson('/api/account/register', {
    fullName: data.get('fullName'),
    email: data.get('email'),
    phone: data.get('phone')?.trim() || null,
    password: data.get('password')
  });

  if (!response.ok) {
    message.textContent = await getErrorMessage(response);
    return;
  }

  form.reset();
  window.location.assign('/dashboard.html');
});

initialize();
