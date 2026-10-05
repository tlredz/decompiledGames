local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local quantumCloner = Players.LocalPlayer.PlayerGui:WaitForChild("ToolsFrames").QuantumCloner
local controllers = ReplicatedStorage:WaitForChild("Controllers")
require(controllers.CharacterController)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Debounce = require(packages.Debounce)
local parent = script.Parent
local parent2 = parent.Parent.Parent
local heartbeatConnection = nil
parent.Activated:Connect(function()
	local _ = game.Players.LocalPlayer
	Net:RemoteEvent("UseItem"):FireServer()
end)
parent.Equipped:Connect(function()
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		debug.profilebegin("QuantumCloner:Update")

		if workspace:FindFirstChild((`{parent2.UserId}_Clone`)) then
			quantumCloner.Visible = true
		end

		debug.profileend()
	end)
end)
parent.Unequipped:Connect(function()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	quantumCloner.Visible = false
end)
parent2.CharacterAdded:Connect(function()
	quantumCloner.Visible = false

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end
end)
quantumCloner.TeleportToClone.MouseButton1Up:Connect(function()
	if Debounce(`ItemUse/QuantumClonerTeleport/{parent2.Name}`, 5) then
		return
	end

	Net:RemoteEvent("QuantumCloner/OnTeleport"):FireServer()
end)