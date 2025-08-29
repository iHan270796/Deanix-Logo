let hudVisible = true;

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
        hudVisible = true;
        document.getElementById("hud").style.display = "flex";
        document.getElementById("voice-hud").style.display = "flex";
    }

    if (data.action === "hide") {
        hudVisible = false;
        document.getElementById("hud").style.display = "none";
        document.getElementById("weapon-hud").classList.add("hidden");
        document.getElementById("voice-hud").style.display = "none";
    }

    if (data.action === "updateWeapon" && hudVisible) {
        if (data.weapon) {
            const weaponHud = document.getElementById("weapon-hud");
            weaponHud.classList.remove("hidden");
            document.getElementById("weapon-icon").className = data.weapon.icon;
            document.getElementById("ammo-count").textContent = `${data.ammoClip} / ${data.ammoTotal}`;
        } else {
            document.getElementById("weapon-hud").classList.add("hidden");
        }
    }

    if (data.action === "voice" && hudVisible) {
        const voiceHud = document.getElementById("voice-hud");
        if (data.talking) {
            voiceHud.classList.add("talking");
        } else {
            voiceHud.classList.remove("talking");
        }
    }

    if (data.action === "vehicleHud" && hudVisible) {
        if (data.inVehicle) {
            document.getElementById("bottom-hud").classList.add("in-vehicle");
        } else {
            document.getElementById("bottom-hud").classList.remove("in-vehicle");
        }
    }
});
