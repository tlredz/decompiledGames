workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local attackerChar = data.AttackerChar
	local attackerHum = data.AttackerHum
	local victimChar = data.VictimChar
	local victimHum = data.VictimHum
	local grabExists = data.GrabExists
	local timeout = data.Timeout or 5
	local humanoidRootPart = attackerChar:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = victimChar:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart2 and grabExists then
		local lastTime = tick()

		while RunService.RenderStepped:Wait() and grabExists and grabExists.Parent and humanoidRootPart and humanoidRootPart2 and humanoidRootPart.Parent and humanoidRootPart.Parent and attackerHum and victimHum and not (victimHum.Health <= 0 or attackerHum.Health <= 0 or timeout < tick() - lastTime) do
			humanoidRootPart2.CFrame = grabExists.Value
		end
	end
end