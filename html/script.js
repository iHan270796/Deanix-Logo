window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === "update") {
        document.getElementById("player-id").innerHTML = "<i class='fa-solid fa-id-badge'></i> " + data.id;
        document.getElementById("job").innerHTML = data.jobIcon + " " + data.job;
        document.getElementById("gang").innerHTML = data.gangIcon + " " + data.gang;
        document.getElementById("bank").innerHTML = "<i class='fa-solid fa-university'></i> $" + data.bank.toLocaleString();
        document.getElementById("cash").innerHTML = "<i class='fa-solid fa-money-bill-wave'></i> $" + data.cash.toLocaleString();
    }

    if (data.action === "show") {
        document.getElementById("hud").style.display = "flex";
    }

    if (data.action === "hide") {
        document.getElementById("hud").style.display = "none";
    }
});
