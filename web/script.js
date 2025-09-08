let currentTab = 'stock';
let vapeshopData = {
    balance: 0,
    stock: [],
    vapes: []
};

// Debug: Log when script loads
console.log('VD-Vapeshop NUI script loaded');

// Test function to show dashboard
function testShowDashboard() {
    console.log('Test: Showing dashboard');
    document.getElementById('app').classList.remove('hidden');
}

function getVapeImageName(vapeName) {
    return vapeName.toLowerCase()
        .replace(/\s+/g, '_')
        .replace(/[^a-z0-9_]/g, '') + '.png';
}

document.addEventListener('DOMContentLoaded', function() {
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeDashboard();
        }
    });
});

function switchTab(tabName) {
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[onclick="switchTab('${tabName}')"]`).classList.add('active');
    
    document.querySelectorAll('.tab-panel').forEach(panel => {
        panel.classList.remove('active');
    });
    document.getElementById(`${tabName}-tab`).classList.add('active');
    
    currentTab = tabName;
    
    if (tabName === 'stock') {
        loadStockData();
    } else if (tabName === 'shipments') {
        loadShipmentsData();
    }
}

function closeDashboard() {
    document.getElementById('app').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeDashboard`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function loadStockData() {
    fetch(`https://${GetParentResourceName()}/getStockData`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            vapeshopData.stock = data.stock || [];
            updateStockDisplay();
        }
    })
    .catch(error => {
        console.error('Error loading stock data:', error);
    });
}

function updateStockDisplay() {
    const stockList = document.getElementById('stockList');
    
    // Ensure stock is an array
    if (!vapeshopData.stock || !Array.isArray(vapeshopData.stock) || vapeshopData.stock.length === 0) {
        stockList.innerHTML = `
            <div class="no-stock">
                <i class="fas fa-box-open"></i>
                <p>No stock available</p>
            </div>
        `;
        return;
    }
    
    stockList.innerHTML = vapeshopData.stock.map(item => `
        <div class="stock-item">
            <img src="images/${getVapeImageName(item.name)}" alt="${item.name}" class="vape-image" onerror="this.style.display='none'">
            <div class="stock-info">
                <span class="stock-name">${item.name}</span>
                <span class="stock-count">${item.count}</span>
            </div>
        </div>
    `).join('');
}

function loadShipmentsData() {
    fetch(`https://${GetParentResourceName()}/getShipmentsData`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            vapeshopData.vapes = data.vapes || [];
            updateShipmentsDisplay();
        }
    })
    .catch(error => {
        console.error('Error loading shipments data:', error);
    });
}

function updateShipmentsDisplay() {
    const shipmentsList = document.getElementById('shipmentsList');
    
    if (!vapeshopData.vapes || vapeshopData.vapes.length === 0) {
        shipmentsList.innerHTML = '<p style="color: #888; text-align: center;">No shipments available</p>';
        return;
    }
    
    shipmentsList.innerHTML = vapeshopData.vapes.map(vape => `
        <div class="shipment-item">
            <div class="shipment-header">
                <img src="images/${getVapeImageName(vape.name)}" alt="${vape.name}" class="shipment-image" onerror="this.style.display='none'">
                <div class="shipment-title">
                    <span class="shipment-name">${vape.name}</span>
                    <span class="shipment-price">$${vape.shipment.price.toLocaleString()}</span>
                </div>
            </div>
            <div class="shipment-details">
                <span>Quantity: ${vape.shipment.vapecount}</span>
                <span>Price per unit: $${vape.price}</span>
            </div>
            <button class="purchase-btn" onclick="purchaseShipment('${vape.name}')">
                <i class="fas fa-shopping-cart"></i> Purchase Shipment
            </button>
        </div>
    `).join('');
}

function purchaseShipment(vapeName) {
    const button = event.target;
    const originalText = button.innerHTML;
    
    button.innerHTML = '<div class="loading"></div> Purchasing...';
    button.disabled = true;
    
    fetch(`https://${GetParentResourceName()}/purchaseShipment`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            vape: vapeName
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            loadStockData();
            updateBalance();
            showNotification('success', data.message);
        } else {
            showNotification('error', data.message);
        }
    })
    .catch(error => {
        console.error('Error purchasing shipment:', error);
        showNotification('error', 'Failed to purchase shipment');
    })
    .finally(() => {
        button.innerHTML = originalText;
        button.disabled = false;
    });
}

function depositMoney() {
    const type = document.getElementById('depositType').value;
    const amount = parseInt(document.getElementById('depositAmount').value);
    
    if (!amount || amount <= 0) {
        showNotification('error', 'Please enter a valid amount');
        return;
    }
    
    const button = event.target;
    const originalText = button.innerHTML;
    
    button.innerHTML = '<div class="loading"></div> Depositing...';
    button.disabled = true;
    
    fetch(`https://${GetParentResourceName()}/depositMoney`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            type: type,
            amount: amount
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            updateBalance();
            document.getElementById('depositAmount').value = '';
            showNotification('success', data.message);
        } else {
            showNotification('error', data.message);
        }
    })
    .catch(error => {
        console.error('Error depositing money:', error);
        showNotification('error', 'Failed to deposit money');
    })
    .finally(() => {
        button.innerHTML = originalText;
        button.disabled = false;
    });
}

function withdrawMoney() {
    const type = document.getElementById('withdrawType').value;
    const amount = parseInt(document.getElementById('withdrawAmount').value);
    
    if (!amount || amount <= 0) {
        showNotification('error', 'Please enter a valid amount');
        return;
    }
    
    const button = event.target;
    const originalText = button.innerHTML;
    
    button.innerHTML = '<div class="loading"></div> Withdrawing...';
    button.disabled = true;
    
    fetch(`https://${GetParentResourceName()}/withdrawMoney`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            type: type,
            amount: amount
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            updateBalance();
            document.getElementById('withdrawAmount').value = '';
            showNotification('success', data.message);
        } else {
            showNotification('error', data.message);
        }
    })
    .catch(error => {
        console.error('Error withdrawing money:', error);
        showNotification('error', 'Failed to withdraw money');
    })
    .finally(() => {
        button.innerHTML = originalText;
        button.disabled = false;
    });
}

function updateBalance() {
    fetch(`https://${GetParentResourceName()}/getBalance`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            vapeshopData.balance = data.balance;
            document.getElementById('businessBalance').textContent = `$${data.balance.toLocaleString()}`;
        }
    })
    .catch(error => {
        console.error('Error loading balance:', error);
    });
}

function showNotification(type, message) {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-circle'}"></i>
        <span>${message}</span>
    `;
    
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#27ae60' : '#e74c3c'};
        color: white;
        padding: 12px 16px;
        border-radius: 8px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        animation: slideIn 0.3s ease;
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

window.addEventListener('message', function(event) {
    const data = event.data;
    console.log('NUI received message:', data);
    
    switch(data.type) {
        case 'openDashboard':
            console.log('Opening dashboard...');
            document.getElementById('app').classList.remove('hidden');
            updateBalance();
            loadStockData();
            break;
        case 'updateData':
            if (data.balance !== undefined) {
                vapeshopData.balance = data.balance;
                document.getElementById('businessBalance').textContent = `$${data.balance.toLocaleString()}`;
            }
            if (data.stock) {
                vapeshopData.stock = data.stock;
                updateStockDisplay();
            }
            break;
    }
});

const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);
