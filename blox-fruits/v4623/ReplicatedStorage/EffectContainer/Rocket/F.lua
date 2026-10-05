local _ = game.Players.LocalPlayer
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local phase1 = FX:WaitForChild("Rocket").F.Phase1
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)

local function DeleteImpactAfterDuration(folder)
	local v = 0

	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local max = emitter.Lifetime.Max
		v = math.max(v, max)
	end

	task.spawn(function()
		task.wait(v)
		folder:Destroy()
	end)
end

return function(p)
	local root = p.Root
	local holding = p.Holding

	if (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local cFrame = root.CFrame
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local clone = phase1.StartImpact:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	DeleteImpactAfterDuration(clone)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)
	end

	local v = Util.Sound:Play("BlackLegIgnite2", root, 15, 0.925, 1)
	task.wait(0.25)
	local clone2 = phase1.Flight:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = folder
	clone2.Anchored = false
	clone2.Weld.Part0 = root

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local v2 = Util.Sound:Play("FireFistBallLoop", root, 10, nil)

	while holding:IsDescendantOf(workspace) and holding.Value do
		wait()
	end

	Util.Sound:FadeOut(v2, 0.33)
	Util.Sound:FadeOut(v, 0.175)
	clone2.Weld.Enabled = false
	clone2.Anchored = true

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	task.delay(5, function()
		folder:Destroy()
	end)
end