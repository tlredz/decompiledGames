local createVector = vector.create
local _ = game.Players.LocalPlayer
local player = nil
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local jump = FX:WaitForChild("Dino").Transformed.Jump
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

Util.ResizeModel(jump.StartImpact, 0.9, jump.StartImpact.Position)
return function(data)
	player = data.player
	local root = data.Root
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "TRexFruitVFXColor")
	Util.Debris:AddItem(folder, 3)
	local cFrame = CFrame.new(data.Origin, data.Origin + root.CFrame.LookVector * createVector(1, 0, 1)) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	)
	Util.Sound:Play("DinoSkydash", root or cFrame.Position, nil, 1, 1)
	local clone = jump.StartImpact:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")
	DeleteImpactAfterDuration(clone)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end
end