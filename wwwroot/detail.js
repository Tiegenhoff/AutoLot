const root = document.querySelector('#detail');
const status = document.querySelector('#detail-status');
const id = new URLSearchParams(location.search).get('id');
function node(tag, text, cls) {
  const element = document.createElement(tag);
  element.textContent = text;
  if (cls) element.className = cls;
  return element;
}

async function load() {
  if (!/^\d+$/.test(id || '')) {
    status.textContent = 'Invalid vehicle ID.';
    root.setAttribute('aria-busy', 'false');
    return;
  }

  try {
    const response = await fetch('/api/vehicles/' + encodeURIComponent(id));
    if (response.status === 404) {
      status.textContent = 'Vehicle not found.';
      return;
    }
    if(!response.ok) throw new Error();
    const vehicle = await response.json();
    root.replaceChildren();
    root.append(
      node('p', vehicle.status, 'badge'),
      node('h1', `${vehicle.year} ${vehicle.make} ${vehicle.model}`),
      node('p', new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(vehicle.salePrice ?? vehicle.askingPrice), 'price')
    );

    if (vehicle.photos.length) {
      const gallery = node('div', '', 'gallery');
      gallery.setAttribute('role', 'group');
      gallery.setAttribute('aria-label', 'Vehicle photos');
      for (const photo of vehicle.photos) {
        const image = document.createElement('img');
        image.src = photo.url;
        image.alt = photo.altText || `${vehicle.year} ${vehicle.make} ${vehicle.model}`;
        gallery.append(image);
      }
      root.append(gallery);
    } else {
      root.append(node('div', 'COOL PHOTO HERE', 'placeholder'));
    }

    root.append(node('h2', 'About this vehicle'), node('p', vehicle.description || 'No description available.'));
    const specifications = document.createElement('dl');
    for (const [label, value] of [
      ['Mileage', `${vehicle.mileage.toLocaleString()} miles`],
      ['Body style', vehicle.bodyStyle],
      ['Fuel', vehicle.fuelType],
      ['Transmission', vehicle.transmission],
      ['Engine', vehicle.engine],
      ['Color', vehicle.color],
      ['Condition', vehicle.condition]
    ]) {
      specifications.append(node('dt', label), node('dd', value || 'Not listed'));
    }
    root.append(node('h2', 'Specifications'), specifications);
    status.textContent = 'Vehicle details loaded.';
  } catch {
    status.textContent = 'Unable to load this vehicle.';
  } finally {
    root.setAttribute('aria-busy', 'false');
  }
}
load();
