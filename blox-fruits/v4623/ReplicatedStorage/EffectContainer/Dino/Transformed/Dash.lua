local _ = game.Players.LocalPlayer
local player = nil
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local dash = FX:WaitForChild("Dino").Transformed.Dash
local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace._WorldOrigin

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

Util.ResizeModel(dash.Dash, 0.7, dash.Dash.Position)
Util.ResizeModel(dash.StartImpact, 0.7, dash.StartImpact.Position)
return function(data)
	player = data.player
	local root = data.Root
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "TRexFruitVFXColor")
	Util.Debris:AddItem(folder, 2.5)
	local cframe = CFrame.new(data.Origin, data.Origin + data.Direction)
	local leftRight = data.LeftRight or 1
	Util.Sound:Play(leftRight == 1 and "DinoDash1" or "DinoDash2", root or cframe.Position, nil, 0.5, 1)
	local clone = dash.StartImpact:Clone()
	clone.CFrame = cframe
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")
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

	local clone2 = dash.Dash:Clone()
	clone2.CFrame = cframe
	Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")
	clone2.Weld.Part1.Massless = true
	clone2.Anchored = true

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.defer(function()
		local lastTime = tick()

		while tick() - lastTime < 0.15 do
			local velocity = root.Velocity

			if velocity.Magnitude < 0.1 then
				velocity = cframe.LookVector
			end

			clone2.CFrame = CFrame.new(root.Position, root.Position + velocity)
			task.wait()
		end
	end)
	task.spawn(function()
		task.wait(0.1275)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Parent.Name == "LineAttachment" then
				emitter.Enabled = false
			end
		end

		task.wait(0.0225)

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end
	end)
end