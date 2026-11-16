const form = document.querySelector('#filters');
const grid = document.querySelector('#vehicles');
const message = document.querySelector('#message');
let currentPage = 1;
let featured = true;
let params = new URLSearchParams();
const money = value => new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(value);
function element(tag, text, className) { const node = document.createElement(tag); node.textContent = text; if (className) node.className = className; return node; }
async function load() {
  grid.replaceChildren(); message.textContent = 'Loading…';
  const query = new URLSearchParams(params); query.set('page', currentPage); if (featured) query.set('featured', 'true');
  try {
    const response = await fetch('/api/vehicles?' + query); if (!response.ok) throw new Error('Unable to load vehicles.');
    const vehicles = await response.json();
    document.querySelector('#results-title').textContent = featured ? 'Featured vehicles' : 'Search results';
    message.textContent = vehicles.length ? `${vehicles.length} vehicle(s) on this page` : 'No vehicles found.';
    vehicles.forEach(v => {
      const card = element('article', '', 'card');
      if (v.photos.length) { const img = document.createElement('img'); img.src = v.photos[0].url; img.alt = v.photos[0].altText; card.append(img); }
      else card.append(element('div', 'PHOTO COMING SOON', 'placeholder'));
      const body = element('div', '', 'card-body'); body.append(element('span', v.status, 'badge'), element('h3', `${v.year} ${v.make} ${v.model}`), element('p', `${v.mileage.toLocaleString()} miles`), element('strong', money(v.salePrice ?? v.askingPrice)));
      const link = element('a', 'View details →', 'card-link'); link.href = '/vehicle.html?id=' + encodeURIComponent(v.id); body.append(link); card.append(body); grid.append(card);
    });
    document.querySelector('#page').textContent = `Page ${currentPage}`;
    document.querySelector('#previous').disabled = currentPage === 1;
    document.querySelector('#next').disabled = vehicles.length < 12;
  } catch { message.textContent = 'Could not load inventory. Check that the API and database are running.'; }
}
form.addEventListener('submit', event => { event.preventDefault(); params = new URLSearchParams(); for (const [key,value] of new FormData(form)) if (value.trim()) params.set(key, value.trim()); featured=false; currentPage=1; load(); });
form.addEventListener('reset', () => { params = new URLSearchParams(); featured=true; currentPage=1; load(); });
document.querySelector('#previous').addEventListener('click', () => { if(currentPage>1) { currentPage--; load(); } });
document.querySelector('#next').addEventListener('click', () => { currentPage++; load(); });
load();
