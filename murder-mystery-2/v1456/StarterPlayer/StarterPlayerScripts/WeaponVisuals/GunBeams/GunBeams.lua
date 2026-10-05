local CreateBeam = require(script.CreateBeam)
game.ReplicatedStorage:WaitForChild("WeaponEvents"):WaitForChild("GunBeam").OnClientEvent:connect(CreateBeam)