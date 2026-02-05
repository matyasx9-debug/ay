const resourceName = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'ay_devpanel';

const panel = document.getElementById('panel');
const closeBtn = document.getElementById('closeBtn');

function post(endpoint, payload = {}) {
  return fetch(`https://${resourceName}/${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });
}

window.addEventListener('message', (event) => {
  const data = event.data;
  if (data.action === 'toggle') {
    panel.classList.toggle('hidden', !data.state);
    if (data.defaults) {
      document.getElementById('weather').value = data.defaults.weather;
      document.getElementById('hour').value = data.defaults.hour;
      document.getElementById('minute').value = data.defaults.minute;
      document.getElementById('noclipSpeed').value = data.defaults.noclipSpeed;
    }
  }
});

closeBtn.addEventListener('click', () => post('close'));
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') post('close');
});

document.querySelectorAll('[data-action]').forEach((btn) => {
  btn.addEventListener('click', () => {
    const action = btn.dataset.action;
    const payload = { action };

    if (action === 'spawnVehicle') payload.model = document.getElementById('vehicleModel').value.trim();
    if (action === 'setWeather') payload.weather = document.getElementById('weather').value;
    if (action === 'setTime') {
      payload.hour = Number(document.getElementById('hour').value || 12);
      payload.minute = Number(document.getElementById('minute').value || 0);
    }
    if (action === 'announce') payload.message = document.getElementById('announce').value.trim();
    if (action === 'setNoclipSpeed') payload.value = Number(document.getElementById('noclipSpeed').value || 1.5);
    if (action === 'tpCoords') {
      payload.x = Number(document.getElementById('tpX').value);
      payload.y = Number(document.getElementById('tpY').value);
      payload.z = Number(document.getElementById('tpZ').value);
    }
    if (action === 'giveWeapon') payload.weapon = document.getElementById('weaponName').value.trim();
    if (action === 'clearArea') payload.radius = Number(document.getElementById('clearRadius').value || 50);

    post('action', payload);
  });
});

const toggles = [
  { id: 'godmode', action: 'godmode' },
  { id: 'invisible', action: 'invisible' },
  { id: 'noclip', action: 'noclip' },
  { id: 'coords', action: 'coords' },
  { id: 'superJump', action: 'superJump' },
  { id: 'fastRun', action: 'fastRun' },
  { id: 'freezeTime', action: 'freezeTime' },
  { id: 'blackout', action: 'blackout' },
  { id: 'forceEngine', action: 'forceEngine' }
];

toggles.forEach(({ id, action }) => {
  const el = document.getElementById(id);
  el.addEventListener('change', () => {
    post('action', { action, state: el.checked });
  });
});
