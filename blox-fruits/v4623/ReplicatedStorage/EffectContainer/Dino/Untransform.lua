local _ = game.Players.LocalPlayer
local player = nil
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local untransform = FX:WaitForChild("Dino").Untransform
local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace._WorldOrigin
return function(p)
	player = p.player
	local root = p.Root

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	Util.Sound:Play("Tail Slash- Explosion", root, nil, 1, 1)
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "TRexFruitVFXColor")
	Util.Debris:AddItem(folder, 5)
	local cframe = CFrame.new(root.Position)
	local clone = untransform.Start:Clone()
	clone.CFrame = cframe
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local clone2 = untransform.StartImpact:Clone()
	clone2.CFrame = cframe
	Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")

	for _, emitter in pairs(clone2:GetDescendants()) do
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

	task.wait(0.15)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end