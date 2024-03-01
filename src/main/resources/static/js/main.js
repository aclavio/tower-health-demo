'use strict';

const TOWER_HEALTH_URL = '/health';

const towerHealthTableBody = document.getElementById('tower-health-table-body');
console.log("towerHealthTableBody:", towerHealthTableBody);

async function getTowerHealth() {
    const response = await fetch(TOWER_HEALTH_URL, {
        method: 'GET',
        mode: 'cors',
        cache: 'no-cache'
    });
    return response.json();
}

function updateTowerHealthTable(healthData = []) {
    function tableColumn(val) {
        const col = document.createElement('td');
        col.textContent = val;
        return col;
    }

    const now = new Date();

    const newRows = healthData
        .sort((l, r) => l.name.localeCompare(r.name))
        .map(sensor => {
            const ts = new Date(parseInt(sensor.timestamp));
            sensor.timestamp = ts.toLocaleString();
            const diff = now - ts;
            sensor.status = 'OK';
            if (diff > 15000) {
                sensor.status = 'WARN';
            }
            if (diff > 30000) {
                sensor.status = 'ERR';
            }
            return sensor;
        })
        .map(sensor => {
            const row = document.createElement('tr');
            row.setAttribute('class', `tower-health-row status-${sensor.status}`);
            row.appendChild(tableColumn(sensor.name));
            row.appendChild(tableColumn(sensor.tower));
//            row.appendChild(tableColumn(sensor.confidence));
//            row.appendChild(tableColumn(sensor.data));
            row.appendChild(tableColumn(sensor.timestamp));
            row.appendChild(tableColumn(sensor.status));
            return row;
        });

    towerHealthTableBody.replaceChildren(...newRows);
}

setInterval(async () => {
    let healthData = await getTowerHealth();
    console.log(healthData);
    updateTowerHealthTable(healthData);
}, 5000);