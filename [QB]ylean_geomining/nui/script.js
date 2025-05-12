document.body.style.display = 'none';

let shopItems = [];

const postToServer = (url, data = {}, callback = () => {}) => {
    $.post(url, JSON.stringify(data), callback);
};

const elements = {
    playerNameElement: document.querySelector('.title'),
    steps: document.querySelector('.additional-title'),
    leaderboard: document.querySelector('.leaderboard'),  // Referencja do tabeli leaderboard
    shop: document.querySelector('.shop-container')  // Referencja do shop-container
};

function updateShop() {
    let newShopContent = '';
  
    shopItems.forEach((item, index) => {
      newShopContent += `<div class="shop-item" id="shop-item-${index}">
        <p class="shop-item-label">${item.label} x${item.amount}</p>
        <img src="${item.icon}" alt="${item.label}" class="shop-item-icon">
        <p class="shop-item-price">👣 ${item.price}</p>
      </div>`;
    });
  
    elements.shop.innerHTML = newShopContent;
  
    // Dodajemy event listener do każdego kafelka sklepu
    shopItems.forEach((item, index) => {
      document.querySelector(`#shop-item-${index}`).addEventListener('click', () => {
        postToServer('https://ylean_geomining/buyItem', {name: item.item, price: item.price, amount: item.amount, label: item.label});
      });
    });
  }

window.addEventListener('message', async (event) => {
    if (event.data.type === 'open') {
        document.body.style.display = 'block';
        if (event.data.playerName) {
            elements.playerNameElement.textContent = 'Welcome ' + event.data.playerName;
        }
        if (event.data.steps) {
            elements.steps.textContent = '👣 ' +event.data.steps;
        }
        updateShop();
    } else if (event.data.action === 'closeNUI') {
        document.body.style.display = 'none';
    } else if (event.data.action === 'updateLeaderboard') {  // Zmień 'type' na 'action'
        updateLeaderboard(event.data.leaderboard);
    }
    else if (event.data.action === 'updateShop') {  // Zmień 'type' na 'action'
        shopItems = event.data.shopItems;
        updateShop();
    }
});

function updateLeaderboard(leaderboardData) {
    let newTableContent = `<tr>
        <th>#</th>
        <th>Name</th>
        <th>Steps</th>
    </tr>`;

    leaderboardData.forEach((player, index) => {
        newTableContent += `<tr>
            <td>${index + 1}</td>
            <td>${player.name}</td>
            <td>${player.steps}</td>
        </tr>`;
    });

    elements.leaderboard.innerHTML = newTableContent;
}

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
      document.body.style.display = 'none';
      postToServer('https://ylean_geomining/close');
    }
});
