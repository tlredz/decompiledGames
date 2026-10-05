local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local start = data.Start
	local origin = data.Origin
	local scale = data.Scale or 1

	if (origin.p - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	local v = Util.Sound:Play("Wind", origin)
	local clone = script.Tornado:Clone()
	clone.Size *= scale
	clone.CFrame = start
	clone.Parent = _WorldOrigin
	TweenService:Create(clone, TweenInfo.new(2), {
		CFrame = origin
	}):Play()
	task.wait(2)
	Util.Sound:FadeOut(v, 0.4)
	task.wait(0.25)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		child.Enabled = false
	end

	task.wait(1)
	clone:Destroy()
end