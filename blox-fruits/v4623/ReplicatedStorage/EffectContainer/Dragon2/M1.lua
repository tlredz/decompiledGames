local createVector = vector.create
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local _ = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local M1 = FX:WaitForChild("Dragon2").M1

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
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

local function BasicSlash(folder)
	task.spawn(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
				task.wait(v2)
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)
		end
	end)
	local tween = TweenService:Create(
		folder.Weld,
		TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
				-2.6179938779914944,
				0,
				0
			)
		}
	)
	tween:Play()
	tween.Completed:Wait()
	folder.Weld.Enabled = false
	folder.Anchored = true
	TweenService:Create(folder, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = folder.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
	}):Play()
end

local function StartProjectileSlash(p, dragonBasicAttack, cFrame, folder, raycastParams, cframe, _, player)
	local clone = dragonBasicAttack.Phase2.ProjectileSlash:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
	local effectsByEffect = {}

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("Beam") then
			effect.Enabled = true
		elseif effect:IsA("ParticleEmitter") then
			effect.Enabled = true
			effectsByEffect[effect] = effect
		elseif effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local v = math.rad((math.random(-3, 3)))
	local v2 = math.rad((math.random(-3, 3)))
	local v3 = math.random(10, 20) / 10
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.3 / v3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			CFrame = clone.CFrame * CFrame.new(0, 0, -p) * CFrame.Angles(v, 0, v2)
		}
	)
	tween:Play()
	local v4 = true
	task.spawn(function()
		local clone2 = dragonBasicAttack.Phase2.GroundSpark:Clone()
		clone2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
		local emittersByEmitter = {}

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false
			emittersByEmitter[emitter] = emitter
		end

		local v5 = tick() + 0
		local v6 = tick() + 0
		local v7 = false

		while true do
			local v8 = clone.CFrame * cframe
			local raycastResult = workspace:Raycast(
				v8.Position + createVector(0, 1, 0),
				createVector(-0, -10, -0),
				raycastParams
			)
			local now = tick()

			if raycastResult then
				clone2.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0))

				if v7 == false then
					v7 = true

					for _, v9 in pairs(emittersByEmitter) do
						v9.Enabled = true
					end
				end

				if v6 < now then
					v5 = now + 0.025

					for _, v9 in pairs(emittersByEmitter) do
						v9:Emit(1)
					end
				end
			elseif v7 == true then
				v7 = false

				for _, v9 in pairs(emittersByEmitter) do
					v9.Enabled = false
				end
			end

			if v5 < now then
				v5 = now + 0.015

				for _, v9 in pairs(effectsByEffect) do
					v9:Emit(1)
				end
			end

			task.wait()

			if v4 ~= false then
				continue
			end

			for _, v9 in pairs(emittersByEmitter) do
				v9.Enabled = false
			end

			break
		end
	end)
	tween.Completed:Wait()
	v4 = false

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("Beam") then
			local v5 = effect
			task.spawn(function()
				local tween2 = TweenService:Create(
					v5,
					TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v5:Destroy()
			end)
		elseif effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		elseif effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	local clone2 = dragonBasicAttack.Phase2.ProjectileEnd:Clone()
	clone2.CFrame = clone.CFrame
	Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v5 = emitter
		task.spawn(function()
			if v5:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v5:GetAttribute("EmitDelay"))
			end

			v5:Emit(v5:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
return function(data)
	local root = data.Root
	local combo = data.Combo
	local hybrid = data.Hybrid
	local cFrame = data.CFrame
	local player = data.player

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	local dragonBasicAttack = M1.DragonBasicAttack
	local v

	if hybrid then
		dragonBasicAttack = M1.DragonBasicAttackBig
		v = 100
	else
		v = 75
	end

	local folder = Instance.new("Folder", workspace._WorldOrigin)
	Util.Debris:AddItem(folder, 5)

	if combo == 1 then
		local cframe = CFrame.Angles(0, 0, -0.6108652381980153)
		local cframe2 = CFrame.Angles(-2.9670597283903604, 0, 0)
		local cFrame2 = cFrame * cframe
		local cFrame3 = cFrame * CFrame.new(0, 0, -25) * cframe
		local clone = dragonBasicAttack.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				if v4:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v4:GetAttribute("EmitDelay"))
				end

				v4:Emit(v4:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = dragonBasicAttack.Phase1.Slash:Clone()
		clone2.CFrame = cFrame
		clone2.Weld.Part0 = root
		clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * cframe * cframe2
		Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
		Util.Sound:Play("BF_V3_Untransformed_Slash_01", clone2)
		BasicSlash(clone2)
		local clone3 = dragonBasicAttack.Phase1.SlashHit:Clone()
		clone3.CFrame = cFrame3
		Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
		StartProjectileSlash(v, dragonBasicAttack, cFrame3, folder, raycastParams, CFrame.new(0, 0, 0), nil, player)
	elseif combo == 2 then
		local cframe = CFrame.Angles(0, 0, 0.6108652381980153)
		local cframe2 = CFrame.Angles(-2.9670597283903604, 0, 0)
		local cFrame2 = cFrame * cframe
		local cFrame3 = cFrame * CFrame.new(0, 0, -25) * cframe
		local clone = dragonBasicAttack.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				if v4:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v4:GetAttribute("EmitDelay"))
				end

				v4:Emit(v4:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = dragonBasicAttack.Phase1.Slash:Clone()
		clone2.CFrame = cFrame
		clone2.Weld.Part0 = root
		clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * cframe * cframe2
		Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
		Util.Sound:Play("BF_V3_Untransformed_Slash_02", clone2)
		BasicSlash(clone2)
		local clone3 = dragonBasicAttack.Phase1.SlashHit:Clone()
		clone3.CFrame = cFrame3
		Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
		StartProjectileSlash(v, dragonBasicAttack, cFrame3, folder, raycastParams, CFrame.new(0, 0, 0), nil, player)
	elseif combo == data.MaxCombo then
		for i = 1, 2 do
			local v2 = i
			task.spawn(function()
				local cframe = CFrame.Angles(0, 0, -0.8726646259971648)

				if v2 == 2 then
					cframe = CFrame.Angles(0, 0, 0.8726646259971648)
				end

				local cframe2 = CFrame.Angles(-2.9670597283903604, 0, 0)
				local cFrame2 = cFrame * cframe
				local cFrame3 = cFrame * CFrame.new(0, 0, -25) * cframe
				local clone = dragonBasicAttack.Phase1.StartImpact:Clone()
				clone.CFrame = cFrame2
				Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

				for i2, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v5 = emitter
					task.spawn(function()
						if v5:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v5:GetAttribute("EmitDelay"))
						end

						v5:Emit(v5:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
				local clone2 = dragonBasicAttack.Phase1.Slash:Clone()
				clone2.CFrame = cFrame
				clone2.Weld.Part0 = root
				clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * cframe * cframe2
				Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")

				if v2 == 1 then
					Util.Sound:Play("Untransformed_Slash_03_v7", clone2)
				end

				BasicSlash(clone2)
				local clone3 = dragonBasicAttack.Phase1.SlashHit:Clone()
				clone3.CFrame = cFrame3
				Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")

				for i2, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
				local cframe3 = CFrame.new(-5, -2.5, 0)

				if v2 == 2 then
					cframe3 = CFrame.new(5, -2.5, 0)
				end

				StartProjectileSlash(v, dragonBasicAttack, cFrame3, folder, raycastParams, cframe3, nil, player)
			end)
		end
	elseif combo == 3 then
		local cframe = CFrame.Angles(0, 0, -1.2217304763960306)
		local cframe2 = CFrame.Angles(-2.9670597283903604, 0, 0)
		local cFrame2 = cFrame * cframe
		local cFrame3 = cFrame * CFrame.new(0, 0, -25) * cframe
		local clone = dragonBasicAttack.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				if v4:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v4:GetAttribute("EmitDelay"))
				end

				v4:Emit(v4:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = dragonBasicAttack.Phase1.Slash:Clone()
		clone2.CFrame = cFrame
		clone2.Weld.Part0 = root
		clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * cframe * cframe2
		Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
		Util.Sound:Play("BF_V3_Untransformed_Slash_01", clone2)
		BasicSlash(clone2)
		local clone3 = dragonBasicAttack.Phase1.SlashHit:Clone()
		clone3.CFrame = cFrame3
		Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
		StartProjectileSlash(v, dragonBasicAttack, cFrame3, folder, raycastParams, CFrame.new(-5, -5, 0), nil, player)
	elseif combo == 4 then
		local cframe = CFrame.Angles(0, 0, 1.2217304763960306)
		local cframe2 = CFrame.Angles(-2.9670597283903604, 0, 0)
		local cFrame2 = cFrame * cframe
		local cFrame3 = cFrame * CFrame.new(0, 0, -25) * cframe
		local clone = dragonBasicAttack.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				if v4:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v4:GetAttribute("EmitDelay"))
				end

				v4:Emit(v4:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = dragonBasicAttack.Phase1.Slash:Clone()
		clone2.CFrame = cFrame
		clone2.Weld.Part0 = root
		clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * cframe * cframe2
		Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
		Util.Sound:Play("BF_V3_Untransformed_Slash_02", clone2)
		BasicSlash(clone2)
		local clone3 = dragonBasicAttack.Phase1.SlashHit:Clone()
		clone3.CFrame = cFrame3
		Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
		StartProjectileSlash(v, dragonBasicAttack, cFrame3, folder, raycastParams, CFrame.new(5, -5, 0), nil, player)
	end
end