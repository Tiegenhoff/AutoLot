const root = document.querySelector('#detail');
const id = new URLSearchParams(location.search).get('id');
function node(tag, text, cls) { const n=document.createElement(tag); n.textContent=text; if(cls)n.className=cls; return n; }
async function load() {
  if (!/^\d+$/.test(id || '')) { root.textContent='Invalid vehicle ID.'; return; }
  try {
    const response = await fetch('/api/vehicles/' + encodeURIComponent(id));
    if(response.status===404) {root.textContent='Vehicle not found.'; return;}
    if(!response.ok) throw new Error();
    const v=await response.json(); root.replaceChildren();
    root.append(node('p',v.status,'badge'),node('h1',`${v.year} ${v.make} ${v.model}`),node('p',new Intl.NumberFormat('en-US',{style:'currency',currency:'USD'}).format(v.salePrice ?? v.askingPrice),'price'));
    if(v.photos.length) {const gallery=node('div','','gallery'); for(const photo of v.photos){const img=document.createElement('img'); img.src=photo.url; img.alt=photo.altText; gallery.append(img);} root.append(gallery);}
    else root.append(node('div','PHOTO COMING SOON','placeholder'));
    root.append(node('h2','About this vehicle'),node('p',v.description || 'No description available.'));
    const dl=document.createElement('dl'); for(const [label,value] of [['Mileage',`${v.mileage.toLocaleString()} miles`],['Body style',v.bodyStyle],['Fuel',v.fuelType],['Transmission',v.transmission],['Engine',v.engine],['Color',v.color],['Condition',v.condition]]) {dl.append(node('dt',label),node('dd',value || 'Not listed'));} root.append(node('h2','Specifications'),dl);
    root.append(node('p','Test drive and reservation requests are coming soon.'));
  } catch { root.textContent='Unable to load this vehicle. Check that the API and database are running.'; }
}
load();
