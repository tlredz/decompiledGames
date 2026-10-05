local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = Util.Debris
local _ = Util.Sound
local roar = FX:WaitForChild("DracoRace").Roar
local v = {}
local flag = false

local function charInRange(vector: Vector3, p: number)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local magnitude = (humanoidRootPart.Position - vector).magnitude

		if magnitude <= p then
			return magnitude
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v2 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v2 = math.max(v2, emitter.Lifetime.Max)
			end
		end

		task.wait(v2)
		folder:Destroy()
	end)
end

local function updateBuffs(p)
	if not flag then
		flag = true
		local v2 = 0.016666666666666666

		while flag do
			local _ = workspace.CurrentCamera.CFrame.Position

			if #v == 0 then
				flag = false
				return
			end

			for k, v3 in pairs(v) do
				if v3[1] and v3[2]:IsDescendantOf(workspace) and v3[2].Parent:GetAttribute(v3[4] == 1 and "DOT_ArrowBuff" or "DOT_ArrowDebuff") and v3[3] ~= nil and v3[3].Health > 0 then
					v3[1].PrimaryPart.CFrame = CFrame.new(v3[2].Position) * (v3[1].PrimaryPart.CFrame - v3[1].PrimaryPart.Position) * CFrame.Angles(
						0,
						math.rad(v2 * 360),
						0
					)
				else
					if v3[1] then
						v3[1]:Destroy()
					end

					if v3[5] then
						Util.Sound:FadeOut(v3[5], 0.1)
					end

					Util.Sound:Play("SmokeLeopardProjectile2", v3[2].CFrame)
					local clone = roar.Phase1.DespawnImpact:Clone()
					clone.CFrame = v3[2].CFrame
					Util.SetParentOverrideWithColor(clone, _WorldOrigin, p, "DracoRaceVFXColors", true)
					Util.SyncColorsOnChange(clone, p, "DracoRaceVFXColors")
					local v4 = v3[4]

					for _, emitter in pairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v5 = v4
						local v6 = emitter
						task.spawn(function()
							if v5 == 2 then
								v6.Color = ColorSequence.new(
									Util.WrapColor3Constructor(
										Color3.fromRGB(240, 44, 26),
										p,
										"DracoRaceVFXColors",
										true
									),
									Util.WrapColor3Constructor(
										Color3.fromRGB(240, 44, 26),
										p,
										"DracoRaceVFXColors",
										true
									)
								)
							elseif v5 == 1 then
								v6.Color = ColorSequence.new(
									Util.WrapColor3Constructor(
										Color3.fromRGB(93, 225, 45),
										p,
										"DracoRaceVFXColors",
										true
									),
									Util.WrapColor3Constructor(
										Color3.fromRGB(93, 225, 45),
										p,
										"DracoRaceVFXColors",
										true
									)
								)
							end

							if v6:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v6:GetAttribute("EmitDelay"))
							end

							v6:Emit(v6:GetAttribute("EmitCount"))
						end)
					end

					DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
					table.remove(v, k)
				end
			end

			v2 = RunService.Heartbeat:Wait()
		end

		if next(v) then
			for _, v3 in ipairs(v) do
				if v3[1] then
					v3[1]:Destroy()
				end

				if v3[5] then
					Util.Sound:FadeOut(v3[5], 0.1)
				end
			end
		end
	end
end

return function(data)
	local ID = data.ID
	local player = data.player

	if ID == 1 then
		local head = data.Head
		local duration = data.Duration

		if not head then
			return
		end

		local cFrame = head.CFrame * CFrame.new(0, 2, -2.5)
		Util.Sound:Play("DracoRoar", head)
		local clone = roar.Phase1.RoarModel:Clone()
		clone.PrimaryPart.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "DracoRaceVFXColors", true)
		Util.SyncColorsOnChange(clone, player, "DracoRaceVFXColors")
		local v3 = {}

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			v3[emitter] = tick() + 1 / emitter.Rate
			emitter.Enabled = false
		end

		local v4 = tick() + duration

		while true do
			for k, v5 in pairs(v3) do
				if not (v5 - tick() <= 0) then
					continue
				end

				v3[k] = tick() + 1 / k.Rate
				k:Emit(1)
			end

			task.wait()

			if not (v4 - tick() <= 0) then
				continue
			end

			Util.Debris:AddItem(clone, 2)
			return
		end
	elseif ID == 2 then
		local buffType = data.BuffType
		local characters = data.Characters

		for _, character in ipairs(characters) do
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if not (humanoidRootPart and humanoid) then
				continue
			end

			local v2 = false

			for _, v4 in ipairs(v) do
				if not (v4[2] == humanoidRootPart and v4[4] == buffType) then
					continue
				end

				v2 = true
				break
			end

			if v2 then
				continue
			end

			local clone = buffType == 1 and roar.Phase1.BuffModel:Clone():Clone() or roar.Phase1.DeBuffModel:Clone()
			clone.PrimaryPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
				0,
				math.rad((math.random(0, 360))),
				0
			)
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "DracoRaceVFXColors", true)
			Util.SyncColorsOnChange(clone, player, "DracoRaceVFXColors")
			local v4 = {
				clone,
				humanoidRootPart,
				humanoid,
				buffType,
				(Util.Sound:Play(buffType == 1 and "loopbuff" or "loopdebuff", humanoidRootPart))
			}
			table.insert(v, v4)
			Util.Sound:Play("SmokeLeopardExplosion2", humanoidRootPart.CFrame)
			local clone2 = roar.Phase1.StartImpact:Clone()
			clone2.CFrame = humanoidRootPart.CFrame
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "DracoRaceVFXColors", true)
			Util.SyncColorsOnChange(clone2, player, "DracoRaceVFXColors")

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					if buffType == 2 then
						v5.Color = ColorSequence.new(
							Util.WrapColor3Constructor(Color3.fromRGB(240, 44, 26), player, "DracoRaceVFXColors", true),
							Util.WrapColor3Constructor(Color3.fromRGB(240, 44, 26), player, "DracoRaceVFXColors", true)
						)
					elseif buffType == 1 then
						v5.Color = ColorSequence.new(
							Util.WrapColor3Constructor(Color3.fromRGB(93, 225, 45), player, "DracoRaceVFXColors", true),
							Util.WrapColor3Constructor(Color3.fromRGB(93, 225, 45), player, "DracoRaceVFXColors", true)
						)
					end

					if v5:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v5:GetAttribute("EmitDelay"))
					end

					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		end

		task.spawn(updateBuffs, player)
	end
end