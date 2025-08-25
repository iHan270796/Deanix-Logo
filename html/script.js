window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === "update") {
        document.getElementById("player-id").textContent = data.id;
        document.getElementById("job").textContent = data.job;
        document.getElementById("job-icon").textContent = data.jobIcon;
        document.getElementById("gang").textContent = data.gang;
        // document.getElementById("gang").textContent = "GANG: " + data.gang;
        document.getElementById("bank").textContent = "BANK: $" + data.bank.toLocaleString();
        document.getElementById("cash").textContent = "CASH: $" + data.cash.toLocaleString();
    }


    if (data.action === "show") {
        document.getElementById("hud").style.display = "flex";
    }

    if (data.action === "hide") {
        document.getElementById("hud").style.display = "none";
    }
});
