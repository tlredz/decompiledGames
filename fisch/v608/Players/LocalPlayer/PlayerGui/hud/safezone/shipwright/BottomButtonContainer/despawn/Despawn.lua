local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.packages.Net)
local localPlayer = Players.LocalPlayer
local _ = localPlayer.PlayerGui.hud.safezone
local remoteEvent = Net:RemoteEvent("Boats/Despawn", -1)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateHasBoat()
	local hasBoat = localPlayer:GetAttribute("HasBoat") == true
	script.Parent.Visible = hasBoat
end

script.Parent.Activated:Connect(function()
	remoteEvent:FireServer()
end)
localPlayer:GetAttributeChangedSignal("HasBoat"):Connect(updateHasBoat)
updateHasBoat() -- equivalent call inferred; original call site unknown