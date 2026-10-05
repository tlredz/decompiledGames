local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").Passive.Assets
workspace:WaitForChild("_WorldOrigin")
local Notification = require(ReplicatedStorage:WaitForChild("Notification"))
local v = {
	CFrame.new(3.25, -0.5, 2),
	CFrame.new(-3.25, -0.5, 2),
	CFrame.new(2, 2.75, 2),
	CFrame.new(-2, 2.75, 2)
}
local v2 = {
	CFrame.new(5, 0.5, 3),
	CFrame.new(-5, 0.5, 3),
	CFrame.new(3, 6, 3),
	CFrame.new(-3, 6, 3)
}
local v3 = {
	3.141592653589793,
	0,
	3.141592653589793,
	0
}
local v4 = {
	0,
	0.15,
	0.3,
	0.45
}

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v5 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v5 = math.max(v5, emitter.Lifetime.Max)
			end
		end

		task.wait(v5)
		folder:Destroy()
	end)
end

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect:GetAttribute("LoopEmit") then
			continue
		end

		if enabled == nil then
			if effect:GetAttribute("OVER") or effect:GetAttribute("USE") or effect:GetAttribute("GROW") then
				continue
			end

			if effect:IsA("Trail") then
				effect.Enabled = true
			elseif effect:GetAttribute("EmitDelay") and effect:GetAttribute("EmitDelay") > 0 then
				local v5 = effect
				task.delay(effect:GetAttribute("EmitDelay"), function()
					v5:Emit(1)
				end)
			else
				effect:Emit(1)
			end
		else
			effect.Enabled = enabled
		end

		if not (effect:IsA("Trail") or effect.Lifetime.Max <= max) then
			max = effect.Lifetime.Max
		end
	end

	return max
end

return function(player)
	local player2 = player.Player
	local v5 = {}
	local v6 = {}

	local function TweenOrbScale(model, p: number, p2: number, p3: number, options)
		if not (model and model:IsA("Model") and model.PrimaryPart) then
			return
		end

		local v7 = v5[model]

		if not (v7 and v7.Original) then
			return
		end

		local parts = v7.Original.Parts
		local particles = v7.Original.Particles
		local v8 = {}

		for _, v9 in ipairs(options or {}) do
			v8[v9] = true
		end

		local v9 = 1

		for k, part in pairs(parts) do
			if not k or not part or not (part.Size.Magnitude > 0) or v8[k.Name] then
				continue
			end

			v9 = k.Size.Magnitude / part.Size.Magnitude
			break
		end

		local v11 = p2 / p3
		local v12 = p - v9

		for i = 1, p3 do
			if not model:IsDescendantOf(workspace) then
				break
			end

			local v13 = v9 + v12 * (i / p3)

			for k, part in pairs(parts) do
				if not k or not k.Parent or v8[k.Name] then
					continue
				end

				k.Size = part.Size * v13
				local _ = part.RelativeCFrame.Position * v13
			end

			if v7.Original.MeshScale then
				local animate = model:FindFirstChild("Animate")
				local specialMesh = animate and animate:FindFirstChildOfClass("SpecialMesh")

				if specialMesh then
					specialMesh.Scale = v7.Original.MeshScale * v13
				end
			end

			for emitter, particle in pairs(particles) do
				if not emitter or not emitter.Parent or v8[emitter.Name] or not emitter:IsA("ParticleEmitter") then
					continue
				end

				if typeof(particle.Size) == "NumberSequence" then
					local numberSequenceKeypoints = {}

					for _, keypoint in ipairs(particle.Size.Keypoints) do
						table.insert(
							numberSequenceKeypoints,
							NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * v13, keypoint.Envelope * v13)
						)
					end

					emitter.Size = NumberSequence.new(numberSequenceKeypoints)
				end

				if typeof(particle.Transparency) == "NumberSequence" then
					emitter.Transparency = particle.Transparency
				end
			end

			for instance, position in pairs(v7.Original.Positions) do
				if instance:IsA("Attachment") then
					instance.Position = position.Position * v13
				elseif instance:IsA("Motor6D") then
					instance.C0 = CFrame.new(0, position.C0.Y * v13, 0)
				end
			end

			task.wait(v11)
		end
	end

	local function shuffleDelays()
		for i = #v4, 2, -1 do
			local v7 = math.random(1, i)
			local v8 = v4
			local v9 = v4
			local v10 = v4[v7]
			local v11 = v4[i]
			v8[i] = v10
			v9[v7] = v11
		end

		for _, v7 in pairs(v5) do
			if not v7 then
				continue
			end

			TweenService:Create(v7.Attach0, TweenInfo.new(0.5), {
				Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), 0)
			})
			v7.AngVelo.AngularVelocity = Vector3.new(-math.random(8, 12), 0, 0)
		end
	end

	local total = 0
	local flag = false
	local v7 = false
	local proxy = player.Proxy

	if not proxy then
		return
	end

	local heartbeatConnection = nil
	local v8 = { "Emit", "Max", "USE" }

	local function Despawn(folder, value)
		local v9 = value or 0.25
		task.delay(v9 * 0.9, function()
			for _, descendant in pairs(folder:GetDescendants()) do
				if (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam")) and descendant.Enabled == true then
					if descendant:GetAttribute("LoopEmit") then
						descendant:SetAttribute("LoopActive", false)
					end

					descendant.Enabled = false
					descendant:SetAttribute("WasEnabled", true)
				elseif descendant:IsA("BasePart") and descendant.Transparency == 0 then
					descendant.Transparency = 1
					descendant:SetAttribute("WasVisible", true)
				end
			end
		end)
		folder.PrimaryPart.Anchored = true
		ParticleState(folder)
		task.delay(2, function()
			folder:Destroy()
		end)
		TweenOrbScale(folder, 0.01, v9, 20, v8)
	end

	local character = player.Character
	local Players = game:GetService("Players")
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)
	local v9 = false

	if playerFromCharacter then
		local Players2 = game:GetService("Players")
		v9 = playerFromCharacter == Players2.LocalPlayer or v9
	end

	local root = player.Root
	local orb = assets.Phase1.Orb
	local _ = root.CFrame * CFrame.new(0, 0, -10)
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, workspace._WorldOrigin, player2, "LightningFruitVFXColor", true)
	Util.SyncColorsOnChange(folder, player2, "LightningFruitVFXColor")

	local function createOrb(instance)
		local index = instance:GetAttribute("Index")

		for i = 1, 1 do
			local clone = orb:Clone()
			Util.SetParentOverrideWithColor(clone, folder, player2, "LightningFruitVFXColor", true)
			Util.SyncColorsOnChange(clone, player2, "LightningFruitVFXColor")
			local offset = v[i]
			clone:PivotTo(root.CFrame * offset)
			local original = {
				Parts = {},
				Particles = {},
				Positions = {}
			}

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant ~= clone.PrimaryPart then
					original.Parts[descendant] = {
						Size = descendant.Size,
						RelativeCFrame = clone.PrimaryPart.CFrame:toObjectSpace(descendant.CFrame)
					}
				elseif descendant:IsA("ParticleEmitter") then
					original.Particles[descendant] = {
						Size = descendant.Size,
						Transparency = descendant.Transparency
					}
				elseif descendant:IsA("SpecialMesh") and descendant.Parent.Name == "Animate" then
					original.MeshScale = descendant.Scale
				elseif descendant.Name == "Attach0" then
					original.Positions[descendant] = {
						Position = descendant.Position
					}
				elseif descendant:IsA("Motor6D") then
					original.Positions[descendant] = {
						C0 = descendant.C0
					}
				end
			end

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
					if descendant:GetAttribute("OVER") == nil and descendant:GetAttribute("USE") == nil then
						if descendant:GetAttribute("GROW") then
							descendant.Enabled = true
						else
							descendant.Enabled = false
						end

						local v12 = descendant
						task.spawn(function()
							repeat
								task.wait()
							until not instance:IsDescendantOf(workspace)

							if v12:GetAttribute("GROW") then
								v12.Enabled = false
							else
								v12.Enabled = true
							end
						end)
					else
						descendant.Enabled = false
					end
				elseif descendant:IsA("BasePart") and descendant:GetAttribute("WasVisible") then
					descendant.Transparency = 0
				end
			end

			task.spawn(function()
				TweenOrbScale(clone, 1, 3.5, 60, v8)
			end)
			local v13 = clone
			task.spawn(function()
				local v14 = Util.Sound:Play("BF_Thunder_Passive_Orbs_ChargeUp_V2_01", v13.PrimaryPart)
				TweenService:Create(v14, TweenInfo.new(0.25), {
					Volume = 0.3
				}):Play()

				repeat
					task.wait()
				until not instance:IsDescendantOf(workspace)

				if not v5[v13] then
					return
				end

				if v14 then
					Util.Sound:FadeOut(v14, 0.2)
				end

				v5[v13].Charging = false

				if v9 then
					local count = 0

					for i2, child in pairs(proxy:GetChildren()) do
						if string.find(child.Name, "LightningOrb") then
							count += 1
						end
					end

					Notification.new("<Color=Green>Charge+<Color=/> (" .. tostring(count) .. "/4)", 2):Display()
				end

				Util.Sound:Play("BF_Thunder_Passive_Orb_Appear_V2_03", v13.PrimaryPart)
				Util.Sound:Play("BF_Thunder_Passive_Orb_Loop_01", v13.PrimaryPart)
				local clone2 = assets.Phase1.StartImpact:Clone()
				clone2.CFrame = v13.PrimaryPart.CFrame
				Util.SetParentOverrideWithColor(clone2, folder, player2, "LightningFruitVFXColor", true)
				Util.SyncColorsOnChange(clone2, player2, "LightningFruitVFXColor")
				DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

				for i2, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			clone.PrimaryPart.Anchored = false
			local alignPosition = clone.AlignPosition
			alignPosition.Position = clone.PrimaryPart.Position + createVector(0, 0.1, 0)
			local angularVelocity = clone.AngularVelocity
			angularVelocity.AngularVelocity = createVector(-10, 0, 0)
			clone.PrimaryPart.Attach0.Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), 0)
			local particle = nil

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:GetAttribute("LoopEmit") then
					particle = descendant
				end
			end

			v5[clone] = {
				Index = index,
				Charging = true,
				Offset = offset,
				AlignPos = alignPosition,
				AngVelo = angularVelocity,
				Attach0 = clone.PrimaryPart.Attach0,
				VerticalOffset = v3[i],
				Original = original,
				Particle = particle,
				Overcharged = false,
				FollowDelay = v4[i]
			}
		end
	end

	local _ = root.Position

	for _, child in pairs(player.Proxy:GetChildren()) do
		if child.Name == "OrbCharging" then
			createOrb(child)
		elseif string.find(child.Name, "LightningOrb_") then
			local v10 = tonumber((string.gsub(child.Name, "LightningOrb_", "")))
			local folder2 = Instance.new("Folder")
			folder2:SetAttribute("Index", v10)
			Util.SetParentOverrideWithColor(folder2, workspace._WorldOrigin, player2, "LightningFruitVFXColor", true)
			Util.SyncColorsOnChange(folder2, player2, "LightningFruitVFXColor")
			createOrb(folder2)
			Util.Debris:AddItem(folder2, 0.1)
		end
	end

	local childAddedConnection = proxy.ChildAdded:Connect(function(child)
		if child.Name == "OrbCharging" and child:IsDescendantOf(proxy) then
			createOrb(child)
		end
	end)
	local childRemovedConnection = proxy.ChildRemoved:Connect(function(child)
		if child:GetAttribute("Ignore") then
			return
		end

		local v10 = tonumber((string.gsub(child.Name, "LightningOrb_", "")))

		for k, v11 in pairs(v5) do
			if not (v11 and v11.Index == v10) then
				continue
			end

			local folder2 = k
			task.spawn(function()
				local clone = assets.Phase1.Spark:Clone()
				clone.CFrame = folder2.PrimaryPart.CFrame
				Util.SetParentOverrideWithColor(clone, folder, player2, "LightningFruitVFXColor", true)
				Util.SyncColorsOnChange(clone, player2, "LightningFruitVFXColor")
				Util.Sound:Play("BF_Thunder_PassiveOrb_Consumed_0" .. tostring(math.random(1, 3)), clone.Position)
				DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

				for i, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				for i, effect in pairs(folder2:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end

				Despawn(folder2, 0.05)
			end)
			v5[k] = nil
			break
		end
	end)
	local moveDirectionChangedConnection = character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if character.Humanoid.MoveDirection.Magnitude > 0 and not v7 then
			v7 = true
			shuffleDelays()
			local v10 = 1

			for _, v11 in pairs(v5) do
				if not v11 then
					continue
				end

				v11.FollowDelay = v4[v10]
				v10 += 1
			end
		elseif v7 and character.Humanoid.MoveDirection.Magnitude <= 0 then
			v7 = false
		end
	end)
	local diedConnection = nil
	diedConnection = character.Humanoid.Died:Connect(function()
		diedConnection:Disconnect()
		flag = true
	end)
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if not root:IsDescendantOf(workspace) then
			flag = true
		end

		if not proxy:IsDescendantOf(workspace) then
			flag = true
		end

		if flag then
			heartbeatConnection:Disconnect()

			if moveDirectionChangedConnection then
				moveDirectionChangedConnection:Disconnect()
			end

			if childAddedConnection then
				childAddedConnection:Disconnect()
			end

			if childRemovedConnection then
				childRemovedConnection:Disconnect()
			end

			if diedConnection then
				diedConnection:Disconnect()
			end

			for k, _ in pairs(v5) do
				v5[k] = nil
			end

			folder:Destroy()
		else
			table.insert(v6, {
				time = total,
				cframe = root.CFrame
			})

			while v6[1] and total - v6[1].time > 1.5 do
				table.remove(v6, 1)
			end

			local count = 0

			for k, v10 in pairs(v5) do
				if not v10 then
					continue
				end

				count += 1
				local projectile = k:FindFirstChild("Projectile")
				local v11 = math.clamp(
					((projectile and projectile.Size or createVector(0, 0, 0)).Magnitude - (createVector(1.8, 1.8, 1.8)).Magnitude) / ((createVector(
						3.06,
						3.06,
						3.06
					)).Magnitude - (createVector(1.8, 1.8, 1.8)).Magnitude),
					0,
					1
				)
				local _ = count >= 5
				local offset

				if v10.Overcharged == true then
					offset = v2[count]:Lerp(v2[count], v11)
				else
					offset = v[count]:Lerp(v[count], v11)
				end

				v10.Offset = offset

				if not v10.Charging and v10.Particle and v10.Particle:GetAttribute("LoopActive") == true then
					v10.Particle.Enabled = false
					v10.Particle:Clear()
					v10.Particle:Emit()
				end

				local v13 = total - v10.FollowDelay
				local cFrame = root.CFrame

				for i = #v6, 1, -1 do
					if not (v6[i].time <= v13) then
						continue
					end

					cFrame = v6[i].cframe
					break
				end

				local position = (cFrame * v10.Offset).Position + Vector3.new(
					0,
					math.sin(total * 2 + v3[count]) * 0.5,
					0
				)
				v10.AlignPos.Position = position
			end
		end
	end)
end