local CreateBeam = require(script.CreateBeam)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("WeaponService")).GunFired.OnClientEvent:Connect(CreateBeam)