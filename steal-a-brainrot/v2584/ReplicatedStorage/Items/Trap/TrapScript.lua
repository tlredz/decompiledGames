game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Debounce = require(packages.Debounce)
local parent = script.Parent
local parent2 = parent.Parent.Parent
parent.Activated:Connect(function()
	if Debounce(`ItemUse/PlaceTrapClient/{parent2.Name}`, 2) then
		return
	end

	Net:RemoteEvent("UseItem"):FireServer()
end)