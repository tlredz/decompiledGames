local createVector = vector.create
game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Sharkman2").M1.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function GetSharkmanColorOwner(player, model)
	local player2 = player.Player or player.player

	if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
		return player2
	end

	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return player2
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(model)

	if playerFromCharacter and playerFromCharacter.Parent then
		return playerFromCharacter
	end

	return model
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.defer(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, position, p2, p3, p4)
	local v = position + (p2 - position) * p
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (p4 - p3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function TrailCurve(folder, cFrame, position, list, cframe, cframe2, p, p2)
	local v = list[1].CFrame * list[2].Position
	folder.CFrame = CFrame.new(position, v)
	local lastTime = tick()
	local v2 = 12 / p / 60
	local v3 = (12 / p + p) / 60
	local v4 = false

	while tick() - lastTime < v2 do
		local v5 = (tick() - lastTime) / v2
		local v6 = list[1].CFrame * list[2].Position
		local v7 = (position - v6) / 2
		local position2 = CFrame.new(CFrame.new(position) * (v7 / -1.5)).Position
		local position3 = CFrame.new(CFrame.new(v6) * (v7 / 1.5)).Position
		local v8 = CFrame.new(position2, position2 + cFrame.LookVector) * cframe.Position
		local v9 = CFrame.new(position3, position3 + cFrame.LookVector) * cframe2.Position
		local v10 = cubicBezier(v5, position, v8, v9, v6)
		folder.CFrame = folder.CFrame:Lerp(CFrame.new(v10, v6), v5)

		if v4 == false then
			if tick() - lastTime < v3 * 0.6 then
				cubicBezier((tick() - lastTime) / v3, position, v8, v9, v6)
			else
				v4 = true

				if p2 == true then
					for _, part in pairs(folder:GetDescendants()) do
						if part:IsA("MeshPart") then
							part.Transparency = 1
						end
					end
				end
			end
		end

		RunService.Heartbeat:Wait()
	end
end

local function SkillUse(player)
	local character = player.Character
	local _ = player.Humanoid
	local combo = player.Combo
	local v = character and character.Name == "Sharkman Master" and 2.5 or 1
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 5)
	local primaryPart = character and character.PrimaryPart

	if not primaryPart then
		return
	end

	local sharkmanColorOwner = GetSharkmanColorOwner(player, character)
	local cFrame = primaryPart.CFrame
	local v3 = math.clamp(1 + (primaryPart.Size.Y / 2.1 - 1), 1, 5) * 0.975

	local function CFramenew(p, p2, p3)
		return CFrame.new(Vector3.new(p, p2, p3) * v3)
	end

	if combo == 1 then
		local clone = assets.Phase1.Trail:Clone()
		clone.CFrame = cFrame * CFrame.new(createVector(-7, -5, 3) * v3)
		Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		clone.Size *= v
		local position = clone.Position
		local cframe = CFrame.new(createVector(5, 1, -7) * v3)
		local cframe2 = CFrame.new(createVector(-15, 3, -7) * v3)
		local cframe3 = CFrame.new(createVector(-3, 2.5, -10) * v3)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("MeshPart") then
				local v5 = descendant
				local transparency = descendant.Transparency
				task.defer(function()
					v5.Transparency = 1
					task.wait(0.05)
					v5.Transparency = transparency
				end)
			end
		end

		Util.Sound:Play("Sharkman_M1_1_Final", cFrame.Position)
		TrailCurve(clone, cFrame, position, { primaryPart, cframe }, cframe2, cframe3, 1.5)
		TrailCurve(
			clone,
			cFrame,
			clone.Position,
			{ primaryPart, (CFrame.new(createVector(3, 1.5, 5) * v3)) },
			CFrame.new(createVector(5, -1, -1) * v3),
			CFrame.new(createVector(7, 0, 0) * v3),
			1.5,
			true
		)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("MeshPart") then
				descendant.Transparency = 1
			end
		end
	elseif combo == 2 then
		local clone = assets.Phase1.Trail:Clone()
		clone.CFrame = cFrame * CFrame.new(createVector(3, 1.5, 5) * v3)
		Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		clone.Size *= v
		local position = clone.Position
		local cframe = CFrame.new(createVector(-3.5, -1, -7) * v3)
		local cframe2 = CFrame.new(createVector(13, 1, 4) * v3)
		local cframe3 = CFrame.new(createVector(8, -1.5, -10) * v3)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("MeshPart") then
				local v5 = descendant
				local transparency = descendant.Transparency
				task.defer(function()
					v5.Transparency = 1
					task.wait(0.05)
					v5.Transparency = transparency
				end)
			end
		end

		Util.Sound:Play("Sharkman_M1_2_Final", cFrame.Position)
		TrailCurve(clone, cFrame, position, { primaryPart, cframe }, cframe2, cframe3, 1.5)
		TrailCurve(
			clone,
			cFrame,
			clone.Position,
			{ primaryPart, (CFrame.new(createVector(-5, -1, 5) * v3)) },
			CFrame.new(createVector(-5, 0, -2.5) * v3),
			CFrame.new(createVector(-5, 0, 1) * v3),
			1.5
		)
		TrailCurve(
			clone,
			cFrame,
			clone.Position,
			{ primaryPart, (CFrame.new(createVector(5, 0, -1) * v3)) },
			CFrame.new(createVector(0, 0, 7) * v3),
			CFrame.new(createVector(5, 0, 5) * v3),
			1,
			true
		)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("MeshPart") then
				descendant.Transparency = 1
			end
		end
	elseif combo == 3 then
		local clone = assets.Phase1.GroundWater:Clone()
		clone.Size *= v
		clone.CFrame = cFrame * CFrame.new(createVector(0, -2.5, 3) * v3)
		Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		clone.Anchored = false
		clone.WeldConstraint.Part1 = primaryPart
		clone.Massless = true

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		Util.Sound:Play("Sharkman_M1_3_Final", cFrame.Position)
		task.wait(0.35)

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				effect.Enabled = false
			end
		end
	elseif combo == 4 then
		local clone = assets.Phase1.Trail:Clone()
		clone.Size *= v
		clone.CFrame = cFrame * CFrame.new(createVector(5, 0, -1) * v3)
		Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		local position = clone.Position
		local cframe = CFrame.new(createVector(-5, 0, 1) * v3)
		local cframe2 = CFrame.new(createVector(5, 1, -7) * v3)
		local cframe3 = CFrame.new(createVector(-5, -5, -5) * v3)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("MeshPart") then
				local v5 = descendant
				local transparency = descendant.Transparency
				task.defer(function()
					v5.Transparency = 1
					task.wait(0.05)
					v5.Transparency = transparency
				end)
			end
		end

		Util.Sound:Play("Sharkman_M1_4_Final", cFrame.Position)
		TrailCurve(clone, cFrame, position, { primaryPart, cframe }, cframe2, cframe3, 1.5)
		TrailCurve(
			clone,
			cFrame,
			clone.Position,
			{ primaryPart, (CFrame.new(createVector(0, 5.5, 0) * v3)) },
			CFrame.new(createVector(-1.5, 1, 7) * v3),
			CFrame.new(createVector(1, 3.5, 5) * v3),
			1.25
		)
		TrailCurve(
			clone,
			cFrame,
			clone.Position,
			{ primaryPart, (CFrame.new(createVector(0, -3, -10) * v3)) },
			CFrame.new(createVector(0, 2.5, -2.5) * v3),
			CFrame.new(createVector(0, 1.5, -1) * v3),
			1.5,
			true
		)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("MeshPart") then
				descendant.Transparency = 1
			end
		end

		local cFrame2 = primaryPart.CFrame * CFrame.new(createVector(0, -2.5, -10) * v3)
		local clone2 = assets.Phase1.Explosion:Clone()
		clone2.Size *= v
		clone2.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone2, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v6 = emitter
			task.defer(function()
				if v6:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v6:GetAttribute("EmitDelay"))
				end

				v6:Emit(v6:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
	end
end

return SkillUse