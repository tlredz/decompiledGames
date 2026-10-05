game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Debounce = require(packages.Debounce)
local parent = script.Parent
local parent2 = parent.Parent.Parent
local track = nil
parent.Activated:Connect(function()
	if Debounce(`ItemUse/ThrowTableAnimation/{parent2.Name}`, 4) then
		return
	end

	if not track then
		track = parent2.Character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(script.ThrowTable)
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = false
	end

	Net:RemoteEvent("UseItem"):FireServer()
	task.wait(0.1)
	track:Play()
end)