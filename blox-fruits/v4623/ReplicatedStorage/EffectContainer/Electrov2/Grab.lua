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
	local dist = data.Dist or 6.5
	local timeout = data.Timeout or 5
	local humanoidRootPart = attackerChar:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = victimChar:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart2 and grabExists then
		local lastTime = tick()
		local v = (humanoidRootPart:GetAttribute("CFrameGrab") or 0) + 1
		humanoidRootPart:SetAttribute("CFrameGrab", v)
		local v2 = (humanoidRootPart2:GetAttribute("CFrameGrab") or 0) + 1
		humanoidRootPart2:SetAttribute("CFrameGrab", v2)

		while RunService.RenderStepped:Wait() and grabExists and grabExists.Parent and humanoidRootPart and humanoidRootPart2 and humanoidRootPart.Parent and attackerHum and victimHum and not (victimHum.Health <= 0 or attackerHum.Health <= 0 or timeout < tick() - lastTime or v < humanoidRootPart:GetAttribute("CFrameGrab") or v2 < humanoidRootPart2:GetAttribute("CFrameGrab") or victimChar:FindFirstChild("AntiMover")) do
			humanoidRootPart2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -dist)
		end

		local v3 = humanoidRootPart:GetAttribute("CFrameGrab") - 1

		if v3 <= 0 then
			v3 = nil
		end

		humanoidRootPart:SetAttribute("CFrameGrab", v3)
		local v4 = humanoidRootPart2:GetAttribute("CFrameGrab") - 1

		if v4 <= 0 then
			v4 = nil
		end

		humanoidRootPart2:SetAttribute("CFrameGrab", v4)
	end
end