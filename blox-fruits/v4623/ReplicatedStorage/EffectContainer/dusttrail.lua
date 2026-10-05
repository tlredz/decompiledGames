workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(p)
	local char = p.char
	local ti = p.ti
	local lastTime = tick()
	local renderSteppedConnection = nil
	local clone = script.smokeswirl:Clone()
	clone.CFrame = char.HumanoidRootPart.CFrame
	clone.Parent = char
	local weld = Instance.new("Weld", char.HumanoidRootPart)
	weld.Part0 = weld.Parent
	weld.Part1 = clone
	weld.C0 = CFrame.new(0, -char.Humanoid.HipHeight, 0)
	renderSteppedConnection = RunService.RenderStepped:connect(function()
		if ti <= tick() - lastTime then
			renderSteppedConnection:disconnect()
			clone.Smoke.Enabled = false
			Util.Debris:AddItem(clone, 2)
			Util.Debris:AddItem(weld, 2)
		else
			local ray = Util.Ray(char.HumanoidRootPart.Position, char.HumanoidRootPart.CFrame.upVector * -10, {
				workspace.Characters,
				clone,
				char,
				workspace.Enemies
			})

			if not ray then
				clone.Smoke.Enabled = false
				return
			end

			clone.Smoke.Enabled = true
			clone.Smoke.Color = ColorSequence.new(ray.Color)
		end
	end)
end