local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local baseField = FX:WaitForChild("DracoRace").BaseField
local _ = Util.MasterClock
local _ = Util.Debris
local _ = Util.Sound
local v = {
	TintColor = Color3.fromRGB(225, 197, 157),
	Contrast = 0.1,
	Saturation = 0.1
}
local v2 = {
	["rbxassetid://18429682338"] = {
		Texture = "rbxassetid://84023204837527",
		SizeScale = 0.5,
		SquashFactor = 1
	},
	["rbxassetid://18429702573"] = {
		Texture = "rbxassetid://80652870771662",
		SizeScale = 0.375,
		SquashFactor = 2.6666666666666665
	},
	["rbxassetid://12622311066"] = {
		Texture = "rbxassetid://102508743684291",
		SizeScale = 0.256,
		SquashFactor = 1
	}
}
local v3 = {
	["Particle_2|rbxassetid://18414333078"] = 5,
	["Particle_3|rbxassetid://13395479051"] = 3,
	["Particle_1|rbxassetid://13395479051"] = 3,
	["Particle_3|rbxassetid://18414570420"] = 3,
	["Particle_6|rbxassetid://13937543537"] = 0,
	["Particle_3|rbxassetid://17134914805"] = 3,
	["Particle_4|rbxassetid://17135057814"] = 3
}

local function scaleParticle(state, p: number, flag: boolean, list)
	local v4 = list and {
		Size = list[1].Keypoints,
		Speed = list[2],
		Acceleration = list[3]
	} or {
		Size = state.Size.Keypoints,
		Speed = state.Speed,
		Acceleration = state.Acceleration
	}

	for i = 1, #v4.Size do
		v4.Size[i] = NumberSequenceKeypoint.new(v4.Size[i].Time, v4.Size[i].Value * p, v4.Size[i].Envelope * p)
	end

	state.Size = NumberSequence.new(v4.Size)
	state.Speed = NumberRange.new(v4.Speed.Min * p, v4.Speed.Max * p)

	if flag then
		state.Acceleration = Vector3.new(v4.Acceleration.X * p, v4.Acceleration.Y * p, v4.Acceleration.Z * p)
	end
end

local function scaleEmitterOpacity(state, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in ipairs(state.Transparency.Keypoints) do
		local v4 = 1 - keypoint.Value
		local v5

		if state.LightEmission >= 0.5 then
			v5 = math.min(1, v4 * p)
		else
			v5 = 1 - (1 - v4) ^ p
		end

		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, 1 - v5, keypoint.Envelope))
	end

	state.Transparency = NumberSequence.new(numberSequenceKeypoints)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function foldDuplicateEmitter(instance, p)
	scaleEmitterOpacity(p, 2)
	instance:Destroy()
end

local function isStackedHazeEmitter(emitter)
	if emitter.Speed.Max > 1 then
		return false
	end

	local v4 = 0

	for _, keypoint in ipairs(emitter.Size.Keypoints) do
		v4 = math.max(v4, keypoint.Value + keypoint.Envelope)
	end

	local v5 = 1

	for _, keypoint in ipairs(emitter.Transparency.Keypoints) do
		v5 = math.min(v5, keypoint.Value)
	end

	return v4 >= 25 and v5 >= 0.65
end

local function thinStackedEmitters(folder, p: number)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and isStackedHazeEmitter(emitter)) then
			continue
		end

		local midpoint = (emitter.Lifetime.Min + emitter.Lifetime.Max) / 2
		local v5 = emitter.Rate * midpoint

		if not (p < v5) then
			continue
		end

		scaleEmitterOpacity(emitter, v5 / p)
		emitter.Rate = p / midpoint
	end
end

local function thinGroundEmitters(folder)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = v3[emitter.Name .. "|" .. emitter.Texture]

		if v4 == 0 then
			emitter:Destroy()
		elseif v4 then
			local midpoint = (emitter.Lifetime.Min + emitter.Lifetime.Max) / 2
			local v6 = emitter.Rate * midpoint

			if v4 < v6 then
				if emitter.LightEmission >= 0.5 then
					emitter.Brightness *= v6 / v4
				else
					scaleEmitterOpacity(emitter, v6 / v4)
				end

				emitter.Rate = v4 / midpoint
			end
		end
	end
end

local function applyCroppedTextures(folder)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = v2[emitter.Texture]

		if not (v4 and v4.Texture ~= "") then
			continue
		end

		emitter.Texture = v4.Texture
		local numberSequenceKeypoints = {}

		for _, keypoint in ipairs(emitter.Size.Keypoints) do
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(
					keypoint.Time,
					keypoint.Value * v4.SizeScale,
					keypoint.Envelope * v4.SizeScale
				)
			)
		end

		emitter.Size = NumberSequence.new(numberSequenceKeypoints)

		if v4.SquashFactor == 1 then
			continue
		end

		local numberSequenceKeypoints2 = {}

		for _, keypoint in ipairs(emitter.Squash.Keypoints) do
			table.insert(
				numberSequenceKeypoints2,
				NumberSequenceKeypoint.new(
					keypoint.Time,
					v4.SquashFactor * (1 + keypoint.Value) - 1,
					keypoint.Envelope * v4.SquashFactor
				)
			)
		end

		emitter.Squash = NumberSequence.new(numberSequenceKeypoints2)
	end
end

local function AlignCFrame(data, p)
	local v4 = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v4).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v4).Unit
	return CFrame.fromMatrix(p2, unit2, v4, unit3)
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local colorCorrectionEffect = nil
local v4 = false
local lastTime = os.clock()
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function updateColCorrection(playerFromCharacter)
	lastTime = os.clock()
	local v6 = "in"

	if not v4 then
		v4 = true
		task.spawn(function()
			while v4 ~= false and colorCorrectionEffect and playerFromCharacter ~= nil and playerFromCharacter.Parent ~= nil do
				local flag = false

				for _, v7 in ipairs(v5) do
					if v7[1] and (v7[1].Position - workspace.CurrentCamera.CFrame.Position).Magnitude <= v7[2] then
						flag = true
					end
				end

				local v7 = math.min(1, (os.clock() - lastTime) / 1.5)

				if flag then
					if v6 ~= "in" then
						v6 = "in"
						v7 = 0
						lastTime = os.clock()
					end

					colorCorrectionEffect.TintColor = colorCorrectionEffect.TintColor:Lerp(
						Util.WrapColor3ConstructorForTintColor(
							v.TintColor,
							playerFromCharacter,
							"DracoRaceVFXColors",
							true
						),
						v7
					)
					local v8 = colorCorrectionEffect
					local saturation = colorCorrectionEffect.Saturation
					v8.Saturation = saturation + (v.Saturation - saturation) * v7
					local v9 = colorCorrectionEffect
					local contrast = colorCorrectionEffect.Contrast
					v9.Contrast = contrast + (v.Contrast - contrast) * v7
				else
					if v6 ~= "out" then
						v6 = "out"
						v7 = 0
						lastTime = os.clock()
					end

					colorCorrectionEffect.TintColor = colorCorrectionEffect.TintColor:Lerp(
						Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							playerFromCharacter,
							"DracoRaceVFXColors",
							true
						),
						v7
					)
					local v8 = colorCorrectionEffect
					local saturation = colorCorrectionEffect.Saturation
					v8.Saturation = saturation + (0 - saturation) * v7
					local v9 = colorCorrectionEffect
					local contrast = colorCorrectionEffect.Contrast
					v9.Contrast = contrast + (0 - contrast) * v7
				end

				RunService.RenderStepped:Wait()
			end

			v5 = {}
			v4 = false
		end)
	end
end

return function(instance)
	local ID = instance.ID
	local _ = instance.player

	if ID == 1 then
		local root = instance.Root
		local humanoid = instance.Humanoid

		if root and humanoid then
			local _ = humanoid.HipHeight
			local radius = instance.Radius
			local comet = instance.Comet
			local thorn = instance.Thorn
			local v6 = radius / 150
			local v7 = radius / 40
			local v8 = 40 * v7

			local function canRun()
				local v9 = humanoid

				if not v9 then
					return v9
				end

				if humanoid.Parent == nil or not (humanoid.Health > 0) then
					return false
				else
					v9 = root

					if v9 then
						if root.Parent == nil then
							return false
						else
							return (instance.Reference:IsDescendantOf(workspace))
						end
					end
				end

				return v9
			end

			table.insert(v5, { root, radius })
			local v9 = {}
			local playerFromCharacter = game.Players:GetPlayerFromCharacter(humanoid.Parent)

			local function addToRecolor(p)
				task.spawn(function()
					if not playerFromCharacter then
						return
					end

					if v9[p] then
						warn("Already added", p)
						return
					end

					v9[p] = true
					local ColorShiftObjectDescendants = require(game.ReplicatedStorage.Util.ColorShiftObjectDescendants)
					ColorShiftObjectDescendants(p, playerFromCharacter, "DracoRaceVFXColors", true)
					local SyncColorsOnChange = require(game.ReplicatedStorage.Util.SyncColorsOnChange)
					SyncColorsOnChange(p, playerFromCharacter, "DracoRaceVFXColors", true)
				end)
			end

			if colorCorrectionEffect == nil then
				colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				local setParentOverrideWithColor = Util.SetParentOverrideWithColor
				local v10 = colorCorrectionEffect
				local Lighting = game:GetService("Lighting")
				setParentOverrideWithColor(v10, Lighting, playerFromCharacter, "DracoRaceVFXColors", true)
				Util.SyncColorsOnChange(colorCorrectionEffect, playerFromCharacter, "DracoRaceVFXColors", true)
				colorCorrectionEffect.Name = "DracoFieldCC"
			end

			updateColCorrection(playerFromCharacter) -- equivalent call inferred; original call site unknown

			local function combine(instance2, instance3)
				for _, child in pairs(instance3:GetChildren()) do
					if instance2:FindFirstChild(child.Name) then
						continue
					end

					Util.SetParentOverrideWithColor(child, instance2, playerFromCharacter, "DracoRaceVFXColors", true)
					Util.SyncColorsOnChange(child, playerFromCharacter, "DracoRaceVFXColors", true)
				end

				for _, attachment in pairs(instance3:GetChildren()) do
					if not attachment:IsA("Attachment") then
						continue
					end

					for _, child in pairs(attachment:GetChildren()) do
						if instance2[attachment.Name]:FindFirstChild(child.Name) then
							continue
						end

						Util.SetParentOverrideWithColor(
							child,
							instance2[attachment.Name],
							playerFromCharacter,
							"DracoRaceVFXColors",
							true
						)
						Util.SyncColorsOnChange(child, playerFromCharacter, "DracoRaceVFXColors", true)
					end
				end
			end

			local clone = baseField.GroundAura:Clone()
			local clone2 = baseField.FieldModel:Clone()
			local field = clone2.Field
			local attachment2 = clone2.Aura.Attachment2
			foldDuplicateEmitter(attachment2.Particle_2, attachment2.Particle_1) -- equivalent call inferred; original call site unknown
			foldDuplicateEmitter(attachment2.Particle_4, attachment2.Particle_3) -- equivalent call inferred; original call site unknown
			applyCroppedTextures(clone2)
			thinStackedEmitters(clone2, 2)
			thinGroundEmitters(field)
			thinGroundEmitters(clone)
			task.spawn(function()
				if not playerFromCharacter then
					return
				end

				if v9[clone] then
					warn("Already added", clone)
					return
				end

				v9[clone] = true
				local ColorShiftObjectDescendants = require(game.ReplicatedStorage.Util.ColorShiftObjectDescendants)
				ColorShiftObjectDescendants(clone, playerFromCharacter, "DracoRaceVFXColors", true)
				local SyncColorsOnChange = require(game.ReplicatedStorage.Util.SyncColorsOnChange)
				SyncColorsOnChange(clone, playerFromCharacter, "DracoRaceVFXColors", true)
			end)
			task.spawn(function()
				if not playerFromCharacter then
					return
				end

				if v9[clone2] then
					warn("Already added", clone2)
					return
				end

				v9[clone2] = true
				local ColorShiftObjectDescendants = require(game.ReplicatedStorage.Util.ColorShiftObjectDescendants)
				ColorShiftObjectDescendants(clone2, playerFromCharacter, "DracoRaceVFXColors", true)
				local SyncColorsOnChange = require(game.ReplicatedStorage.Util.SyncColorsOnChange)
				SyncColorsOnChange(clone2, playerFromCharacter, "DracoRaceVFXColors", true)
			end)
			clone2:PivotTo(CFrame.new(root.Position) * CFrame.new(0, -2, 0))
			local _ = clone2.Field.Aura.Size * v7
			local now = os.clock()
			local v10 = {
				Glow = { now, 1 },
				Fire = { now, 0.04 },
				Lines = { now, 0.03 },
				FloorGlow = { now, 0.2 },
				Waves = { now, 0.2 }
			}
			local _ = {
				ThornBeamExt1 = {
					6,
					6,
					-1,
					1
				},
				ThornBeamExt2 = {
					6,
					6,
					1,
					-1
				},
				ThornBeamIn1 = {
					10,
					10,
					-1,
					1
				},
				ThornBeamIn2 = {
					10,
					10,
					1,
					-1
				},
				CometBeamIn = {
					10,
					0,
					1,
					-1
				},
				CometBeamIn2 = {
					25,
					0,
					1,
					-1
				},
				CometBeamExt = {
					0,
					15,
					-1,
					1
				},
				CometBeamExt2 = {
					0,
					25,
					-1,
					1
				}
			}

			if comet then
				v10.GlowRing = { now, 0.9 }
				v10.Thorns = { now, 0.2 }
				v10.ThinRing = { now, 0.3 }
			end

			if thorn then
				v10.Glow = { now, 1 }
				v10.OrbitSpikes = { now, 1 }
				v10.Thorns = { now, 0.2 }
				v10.Fire = { now, 0.04 }
				v10.Lines = { now, 0.03 }
				v10.FloorGlow = { now, 0.2 }
				v10.ThinRing = { now, 0.3 }
				v10.Waves = { now, 0.2 }
			end

			local attachment = clone2.Aura.Attachment
			local aura2 = field.Aura2
			local descendants = field:GetDescendants()
			aura2:GetChildren()
			local children = attachment:GetChildren()
			task.spawn(function()
				if not playerFromCharacter then
					return
				end

				if v9[aura2] then
					warn("Already added", aura2)
					return
				end

				v9[aura2] = true
				local ColorShiftObjectDescendants = require(game.ReplicatedStorage.Util.ColorShiftObjectDescendants)
				ColorShiftObjectDescendants(aura2, playerFromCharacter, "DracoRaceVFXColors", true)
				local SyncColorsOnChange = require(game.ReplicatedStorage.Util.SyncColorsOnChange)
				SyncColorsOnChange(aura2, playerFromCharacter, "DracoRaceVFXColors", true)
			end)
			local v11 = Util.Sound:Play("Burn2", aura2, nil, 0.5, 0.5)
			local v12 = Util.Sound:Play("Burn2", attachment, nil, 0.3, 0.25)
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, playerFromCharacter, "DracoRaceVFXColors", true)
			Util.SyncColorsOnChange(clone2, playerFromCharacter, "DracoRaceVFXColors", true)
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, playerFromCharacter, "DracoRaceVFXColors", true)
			Util.SyncColorsOnChange(clone, playerFromCharacter, "DracoRaceVFXColors", true)
			clone2:ScaleTo(3.75 * v6)
			local aura = clone2.Aura
			Util.SetParentOverrideWithColor(aura, _WorldOrigin, playerFromCharacter, "DracoRaceVFXColors", true)
			Util.SyncColorsOnChange(aura, playerFromCharacter, "DracoRaceVFXColors", true)
			local v13 = {}
			local v14 = {}
			local flag = false

			for _, emitter in ipairs(aura:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					table.insert(v13, emitter)
				end
			end

			local emittersByEmitter = {}

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emittersByEmitter[emitter] = emitter
			end

			local clone3 = nil
			local effectsByEffect = {}
			local clone4

			if thorn then
				clone4 = baseField.ThornModel:Clone()
				clone4:ScaleTo(3.75 * v6)
				applyCroppedTextures(clone4)
				thinStackedEmitters(clone4, 2)
				Util.SetParentOverrideWithColor(clone4, _WorldOrigin, playerFromCharacter, "DracoRaceVFXColors", true)
				Util.SyncColorsOnChange(clone4, playerFromCharacter, "DracoRaceVFXColors", true)

				for _, effect in pairs(clone4:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						if effect.Parent.Name == "Attachment2" or effect.Parent.Name == "Aura" then
							effect.Enabled = false
							effectsByEffect[effect] = effect
						elseif effect.Name == "BackgroundAura" then
							effect.Size = NumberSequence.new(radius * 1.21)
							scaleEmitterOpacity(effect, 2)
							effect:Emit(1)
							table.insert(v14, effect)
							clone3 = effect
						elseif effect.Parent.Name == "Attachment" then
							table.insert(v13, effect)
						else
							descendants[effect] = effect
						end
					elseif effect:IsA("Beam") then
						effect.Transparency = NumberSequence.new(0.9)
					end
				end
			else
				clone4 = nil
			end

			local v15 = {}

			if comet then
				if not thorn then
					clone3 = baseField.ThornModel.SphereModel.Aura:FindFirstChild("BackgroundAura", true):Clone()
					clone3.Size = NumberSequence.new(radius * 1.21)
					scaleEmitterOpacity(clone3, 2)
					table.insert(v14, clone3)
					Util.SetParentOverrideWithColor(clone3, attachment, playerFromCharacter, "DracoRaceVFXColors", true)
					Util.SyncColorsOnChange(clone3, playerFromCharacter, "DracoRaceVFXColors", true)
					clone3:Emit(1)
				end

				for i = 1, 5 do
					local clone5 = baseField.CometModel:Clone()

					if i == 1 then
						clone5:ScaleTo(2.5)
					elseif i == 2 then
						clone5:ScaleTo(2.25)
					elseif i == 3 then
						clone5:ScaleTo(2)
					elseif i == 4 then
						clone5:ScaleTo(1.75)
					elseif i == 5 then
						clone5:ScaleTo(1.5)
					end

					clone5.PrimaryPart.Anchored = false
					clone5.PrimaryPart.Massless = true
					clone5.PrimaryPart.Weld.Part1 = aura

					for _, descendant in pairs(clone5:GetDescendants()) do
						if descendant:IsA("Attachment") then
							descendant.Position *= 1.4 * v6
						elseif descendant:IsA("Beam") then
							descendant.Segments *= 4
							descendant.CurveSize0 *= 1.4 * v6
							descendant.CurveSize1 *= 1.4 * v6
							descendant.LightEmission += 0.3
							descendant.Brightness += 0.3
						elseif descendant:IsA("ParticleEmitter") then
							descendant.LightEmission += 0.3
							descendant.Brightness += 1.3
						end
					end

					Util.SetParentOverrideWithColor(
						clone5,
						_WorldOrigin,
						playerFromCharacter,
						"DracoRaceVFXColors",
						true
					)
					Util.SyncColorsOnChange(clone5, playerFromCharacter, "DracoRaceVFXColors", true)
					v15[clone5.PrimaryPart] = tick()
					clone5.PrimaryPart.Weld.C1 = clone5.PrimaryPart.Weld.C1 * CFrame.Angles(
						math.rad(i * 45),
						math.rad(i * 45),
						(math.rad(i * 90))
					)

					for _, descendant in pairs(clone5:GetDescendants()) do
						children[descendant] = descendant
					end
				end
			end

			local v16 = {}
			local v17 = 0.016666666666666666
			local total = 0
			local v18 = true

			for _, emitter in pairs(descendants) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				v16[emitter] = tick() + 1 / emitter.Rate
				emitter.Enabled = false
			end

			local now2 = tick()
			local health = humanoid.Health
			Util.SyncColorsOnChange(clone2, playerFromCharacter, "DracoRaceVFXColors", true)
			local v19 = false
			local v20 = 0
			local v21 = false
			local total2 = 0

			while true do
				local v22

				if humanoid then
					if humanoid.Parent == nil or not (humanoid.Health > 0) then
						v22 = false
					elseif root then
						if root.Parent == nil then
							v22 = false
						else
							v22 = instance.Reference:IsDescendantOf(workspace)
						end
					else
						v22 = root
					end
				else
					v22 = humanoid
				end

				if v22 then
					local magnitude = (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude

					if magnitude < 2000 then
						v19 = not v19

						if flag then
							if radius * 0.5 < magnitude then
								flag = false

								for _, v23 in ipairs(v13) do
									v23.Enabled = true
								end

								for _, v23 in ipairs(v14) do
									v23:Emit(1)
								end
							end
						elseif magnitude < radius * 0.4 then
							flag = true

							for _, v23 in ipairs(v13) do
								v23.Enabled = false
							end

							for _, v23 in ipairs(v14) do
								v23:Clear()
							end
						end

						local _ = v17 * 60
						local ray, v23, v24 = Util.Ray(
							root.Position,
							createVector(0, 1, 0) * -v8,
							{ workspace.Characters, workspace.Enemies }
						)
						total += ((1 + -1 * math.clamp(math.min((root.Position - v23).Magnitude, v8) / v8, 0, 1)) ^ 0.5 - total) * 0.05

						if v7 * total > 0.01 then
							local _ = clone2.Parent == workspace._WorldOrigin

							if v19 and math.abs(v20 - v7 * total) > 0.02 then
								clone2:ScaleTo(v7 * total)
								v20 = v7 * total
							end
						else
							local _ = clone2.Parent == nil
						end

						if v11 then
							v11.Volume = 0 + 0.5 * total
						end

						local v25 = false

						if ray then
							v25 = true

							for k, v26 in pairs(v16) do
								if not (v26 - tick() <= 0) then
									continue
								end

								v16[k] = tick() + 1 / k.Rate
								k:Emit(1)
							end

							if v21 == false then
								v21 = true

								for _, v26 in pairs(emittersByEmitter) do
									v26.Enabled = true
								end
							end
						elseif v21 == true then
							v21 = false

							for _, v26 in pairs(emittersByEmitter) do
								v26.Enabled = false
							end
						end

						if field and v25 then
							local v26 = v23 + (v25 and Vector3.new() or Vector3.new(0, v8, 0))
							local v27 = CFrame.new(v26, v24) + v24 * 0.01
							local p = v27.p
							local unit = v27.LookVector:Cross(createVector(0, 1, 0)).Unit
							local unit2 = (unit.Magnitude > 0.001 and unit or v27.RightVector).Unit
							local unit3 = unit2:Cross(createVector(0, 1, 0)).Unit
							local cframe = CFrame.fromMatrix(p, unit2, createVector(0, 1, 0), unit3)
							clone2.PrimaryPart.CFrame = cframe
							clone.CFrame = CFrame.new(v26 + v24 * 0.1, v26 + v24) * CFrame.Angles(
								-1.5706963267948966,
								0,
								0
							) + v24 * clone.Size.Y / 2
						end

						for _, v26 in ipairs(v25 and ({ descendants, children } or { children }) or { children }) do
							for _, v27 in pairs(v26) do
								if not (v27 and v10[v27.Name] and os.clock() - v10[v27.Name][1] > v10[v27.Name][2]) then
									continue
								end

								v27:Emit(v27:GetAttribute("EmitCount"))
								v10[v27.Name][1] = os.clock()
							end
						end

						aura.CFrame = CFrame.new(root.Position)
						local _ = aura.Parent == _WorldOrigin
						local _ = clone.Parent == _WorldOrigin

						if thorn then
							clone4.PrimaryPart.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, total2, 0)
							total2 += v17 * 0.666

							if humanoid.Health < health and now2 - tick() <= 0 then
								now2 = tick() + 0.333

								for _, v26 in pairs(effectsByEffect) do
									v26:Emit(v26:GetAttribute("EmitCount"))
								end
							end

							health = humanoid.Health
						end

						if comet then
							for k, v26 in pairs(v15) do
								if not (v26 - tick() <= 0) then
									continue
								end

								v15[k] = tick() + 0.25
								TweenService:Create(
									k.Weld,
									TweenInfo.new(0.249, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										C1 = k.Weld.C1 * CFrame.Angles(0, 0.4363323129985824, 0)
									}
								):Play()
							end
						end

						if clone3 then
						end

						v17 = RunService.PreRender:Wait()
					else
						aura.CFrame = CFrame.new(0, 100000, 0)
						local _ = clone2.Parent == nil
						local _ = clone.Parent == nil

						if thorn then
							clone4.PrimaryPart.CFrame = CFrame.new(root.Position + createVector(0, 99999, 0)) * CFrame.Angles(
								0,
								total2,
								0
							)
						end

						task.wait(0.5)
						v18 = v18 and false
					end
				else
					table.clear(v9)

					if next(v5) then
						for i, v23 in ipairs(v5) do
							if v23[1] == root then
								table.remove(v5, i)
							end
						end
					end

					for _, emitter in ipairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = false

						if emitter.Name == "BackgroundAura" then
							emitter:Clear()
						end
					end

					if aura then
						for _, emitter in ipairs(aura:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Enabled = false

							if emitter.Name == "BackgroundAura" then
								emitter:Clear()
							end
						end
					end

					task.spawn(function()
						if clone then
							for _, effect in ipairs(clone:GetDescendants()) do
								if effect:IsA("ParticleEmitter") then
									effect.Enabled = false

									if effect.Name == "BackgroundAura" then
										effect:Clear()
									end
								elseif effect:IsA("Beam") then
									TweenService:Create(effect, TweenInfo.new(0.3), {
										Width0 = 0,
										Width1 = 0
									}):Play()
								end
							end
						end

						if clone4 then
							for _, effect in ipairs(clone4:GetDescendants()) do
								if effect:IsA("ParticleEmitter") then
									effect.Enabled = false

									if effect.Name == "BackgroundAura" then
										effect:Clear()
									end
								elseif effect:IsA("Beam") then
									TweenService:Create(effect, TweenInfo.new(0.3), {
										Width0 = 0,
										Width1 = 0
									}):Play()
								end
							end
						end

						for k in pairs(v15) do
							local parent = k.Parent

							for _, effect in ipairs(parent:GetDescendants()) do
								if effect:IsA("ParticleEmitter") then
									effect.Enabled = false
								elseif effect:IsA("Beam") then
									TweenService:Create(effect, TweenInfo.new(0.3), {
										Width0 = 0,
										Width1 = 0
									}):Play()
								end
							end
						end

						task.wait(2)

						if clone then
							clone:Destroy()
						end

						if clone4 then
							clone4:Destroy()
						end

						for k in pairs(v15) do
							k.Parent:Destroy()
						end

						v15 = nil
					end)
					task.spawn(function()
						local lastTime2 = os.clock()

						while os.clock() - lastTime2 < 1 and field do
							local v23 = math.min((os.clock() - lastTime2) / 1, 1)

							if v12 then
								v12.Volume = 0.25 + -0.25 * v23
							end

							if v11 then
								v11.Volume = 0.5 + -0.5 * v23
							end

							RunService.Heartbeat:Wait()
						end

						task.delay(2, function()
							if field then
								field:Destroy()
							end

							if clone2 then
								clone2:Destroy()
							end

							if aura then
								aura:Destroy()
							end
						end)
					end)
					break
				end
			end
		end
	end
end