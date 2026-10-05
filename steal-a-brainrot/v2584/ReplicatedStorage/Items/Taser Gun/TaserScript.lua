game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Debounce = require(packages.Debounce)
local parent = script.Parent
local parent2 = parent.Parent.Parent
parent.Activated:Connect(function()
	if Debounce(`ItemUse/TaserGun/{parent2.Name}`, 5) then
		return
	end

	local _ = game.Players.LocalPlayer
	local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
	local target = PlayerMouse.Target
	Net:RemoteEvent("UseItem"):FireServer(target)
end)