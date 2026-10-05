local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").M1.Assets
local LastInput = require(ReplicatedStorage.Modules.LastInput)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

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

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local LightningBoltShafi = require(game.ReplicatedStorage.Util.LightningBoltShafi)

local function ShafiBolt(player, ...)
	local v = LightningBoltShafi.new(...)
	local curveSize = -math.random(-5, 5) * 2
	local curveSize2 = math.random(-5, 5) * 2
	v.CurveSize0 = curveSize
	v.CurveSize1 = curveSize2
	v.Frequency = 1
	v.AnimationSpeed = 10
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = math.random(3, 6)
	v.Color = Util.WrapColor3Constructor(Color3.new(0.411765, 0.952941, 1), player, "LightningFruitVFXColor")
	pcall(function()
		if player.Character and player.Character.PrimaryPart then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:GetAttribute("LightningSkin") and humanoidRootPart:GetAttribute("LightningSkin") == "Purple" and math.random(
				1,
				2
			) == 2 then
				v.Color = Color3.new(0, 0, 0)
			end
		end
	end)
	return v
end

return function(data)
	local origin = data.Origin
	local player = data.Player

	if (currentCamera.CFrame.p - origin).Magnitude > 500 then
		return
	end

	local proxy = data.Proxy

	if not proxy then
		return
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
	local root = data.Root
	local cFrame = root.CFrame

	if root:GetAttribute("LightningSkin") then
		local _ = root:GetAttribute("LightningSkin") == "Purple"
	end

	local holding = data.Holding

	if not (holding and holding.Value) then
		return
	end

	local range = data.Range
	local clonesByClone = {}
	local v = {}
	local v2 = {}

	for _ = 1, 2 do
		local clone = assets.Phase1.PointA:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		clone:SetAttribute("Active", false)

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("Beam") then
				effect.CurveSize0 = 0
				effect.CurveSize1 = 0
				effect.Enabled = false
				effect:SetAttribute("W0", effect.Width0)
				effect:SetAttribute("W1", effect.Width1)
			elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local _ = clone.PointB
		clonesByClone[clone] = clone
	end

	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = false
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
	local clone = assets.Phase1.HoldAura:Clone()
	clone:PivotTo(cFrame)
	Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
	local pointBAura = clone.PointBAura
	pointBAura.WeldConstraint.Enabled = false
	pointBAura.Anchored = true

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local aura = clone.Aura
	local v3 = tick() + 0
	local v4 = tick() + 0
	local v5 = tick() + 0
	local clone2 = assets.Phase1.GroundBurn1:Clone()
	clone2:PivotTo(cFrame)
	Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
	local emittersByEmitter = {}
	local v6 = {}

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emittersByEmitter[emitter] = emitter
		emitter.Enabled = false
	end

	local clone3 = assets.Phase0.HandAura:Clone()
	clone3.CFrame = root.Parent.RightHand.CFrame
	Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")
	clone3.Weld.Part1 = root.Parent.RightHand
	clone3.Anchored = false
	clone3.Massless = true
	local clone4 = assets.Phase0.HandAura:Clone()
	clone4.CFrame = root.Parent.LeftHand.CFrame
	Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
	clone4.Weld.Part1 = root.Parent.LeftHand
	clone4.Anchored = false
	clone4.Massless = true
	local v7 = {}

	for _, v8 in pairs({ clone4:GetDescendants(), clone3:GetDescendants() }) do
		for _, emitter in pairs(v8) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end

	local v8 = tick() + 0
	local v9 = false
	local mouse = nil
	local v10 = false

	if typeof(data.Player) == "Instance" and data.Player:IsA("Player") then
		local player2 = data.Player
		local Players = game:GetService("Players")

		if player2 == Players.LocalPlayer then
			if LastInput:IsMobile() then
				mouse = true
				v10 = true
			else
				mouse = data.Player:GetMouse()
			end
		end
	end

	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = data.MousePos.Value
	local clone5 = assets.Phase0A.StartImpact:Clone()
	clone5.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
	Util.Sound:Play("BF_Thunder_M1_LightningHands_Activate_V2_01", root)
	local v11 = Util.Sound:Play("BF_Thunder_M1_LightningHands_CastingLoop_01", root)
	TweenService:Create(v11, TweenInfo.new(1), {
		Volume = 1
	}):Play()

	for _, emitter in pairs(clone5:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown
	local v12 = 0

	while true do
		local value = data.MousePos.Value

		if mouse and v10 then
			local hUDNoInset = player.PlayerGui:FindFirstChild("HUDNoInset")

			if hUDNoInset then
				local v13 = hUDNoInset.AbsolutePosition + hUDNoInset.AbsoluteSize / 2
				local viewportPointToRay = currentCamera:ViewportPointToRay(v13.X, v13.Y)
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams2.FilterDescendantsInstances = {
					workspace._WorldOrigin,
					workspace.Characters,
					workspace.Enemies
				}
				local raycastResult = workspace:Raycast(
					viewportPointToRay.Origin,
					viewportPointToRay.Direction * 80,
					raycastParams2
				)
				value = raycastResult and raycastResult.Position or viewportPointToRay.Origin + viewportPointToRay.Direction * 80
			end
		elseif mouse and not v10 then
			value = mouse.Hit.Position
		end

		TweenService:Create(vector3Value, TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Value = value
		}):Play()
		local cframe = CFrame.new(
			root.Position,
			(Vector3.new(vector3Value.Value.X, root.Position.Y, vector3Value.Value.Z))
		)
		local cframe2 = CFrame.new(cframe.Position, vector3Value.Value)
		local ray = Ray.new(
			cframe2.Position,
			CFrame.new(cframe2.Position, cframe2 * CFrame.new(0, 0, -range).Position).LookVector * (1 + range)
		)
		local part, position2, v14 = workspace:FindPartOnRayWithIgnoreList(
			ray,
			{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		)
		local magnitude = (cframe.Position - position2).Magnitude
		pointBAura.Position = cframe2 * CFrame.new(0, 0, -magnitude * 0.75).Position
		local raycastResult = workspace:Raycast(
			position2 + createVector(0, 1, 0),
			createVector(-0, -9, -0),
			raycastParams
		)

		if raycastResult then
			clone2.Size = Vector3.new(clone2.Size.X, clone2.Size.Y, magnitude * 0.7)
			clone2.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			clone2.CFrame = CFrame.new(clone2.Position, clone2.Position + cframe.LookVector) * CFrame.new(
				0,
				0,
				magnitude * 1 / 6
			)

			if v9 == false then
				v9 = true

				for _, v15 in pairs(emittersByEmitter) do
					v15.Enabled = true
				end
			end
		elseif v9 == true then
			v9 = false

			for _, v15 in pairs(emittersByEmitter) do
				v15.Enabled = false
			end
		end

		if v4 - tick() <= 0 then
			v4 = tick() + 0.1

			for _ = 1, math.random(1, 4) do
				task.spawn(function()
					local clone6 = FX:WaitForChild("Lightning2").M1.Part:Clone()
					clone6.CFrame = cframe
					Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
					clone6.Attach1.Position = Vector3.new(math.random(-15, 15) * 2, math.random(-5, 5) * 2, 0)
					local shafiBolt = ShafiBolt(player, clone6.Attach0, clone6.Attach1, 15, 1, folder)
					v6[shafiBolt] = clone6
					task.wait(0.15 * math.random() + 0.2)
					shafiBolt:Destroy()
					v6[clone6] = nil
				end)
			end
		end

		local v15 = nil
		local parentsByParent = {}
		local value2 = nil

		for _, child in pairs(proxy:GetChildren()) do
			if child.Value and child:GetAttribute("PrimaryTarget") then
				v15 = child
			end
		end

		if v15 and v15.Value and v15.Value:IsDescendantOf(workspace) then
			value2 = v15.Value
			parentsByParent[value2.Parent] = value2.Parent

			if v7[value2.Parent] == nil then
				local clone6 = assets.Phase1.HitAura:Clone()
				clone6:PivotTo(value2.CFrame)
				Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
				v7[value2.Parent] = clone6

				for _, emitter in pairs(clone6:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end

			for _, child in pairs(proxy:GetChildren()) do
				if not (child ~= v15 and child.Value and child.Value:IsDescendantOf(workspace)) then
					continue
				end

				local parent = child.Value.Parent
				parentsByParent[parent] = parent
				task.spawn(function()
					if v7[parent] == nil then
						local clone6 = assets.Phase1.HitAura:Clone()
						clone6:PivotTo(parent.PrimaryPart.CFrame)
						Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
						Util.Sound:Play("BF_Thunder_M1_LightningHands_NPCDamageChain_01", clone6)
						v7[parent] = clone6

						for i, emitter in pairs(clone6:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end
					end
				end)
			end

			for _, child in pairs(proxy:GetChildren()) do
				if not (child ~= v15 and child.Value and child.Value:IsDescendantOf(workspace)) then
					continue
				end

				local parent = child.Value.Parent
				parentsByParent[parent] = parent
				task.spawn(function()
					if v7[parent] == nil then
						local clone6 = assets.Phase1.HitAura:Clone()
						clone6:PivotTo(parent.PrimaryPart.CFrame)
						Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
						v7[parent] = clone6

						for i, emitter in pairs(clone6:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end
					end
				end)
			end

			if v5 - tick() <= 0 then
				v5 = tick() + 0.1

				for _, child in pairs(proxy:GetChildren()) do
					if not (child ~= v15 and child.Value and child.Value:IsDescendantOf(workspace)) then
						continue
					end

					local parent = child.Value.Parent

					for _ = 1, math.random(1, 2) do
						local parent2 = parent
						task.spawn(function()
							local clone6 = FX:WaitForChild("Lightning2").M1.Part:Clone()
							clone6.CFrame = CFrame.new(value2.Position, parent2.PrimaryPart.Position)
							Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
							clone6.Attach1.WorldPosition = parent2.PrimaryPart.Position
							local shafiBolt = ShafiBolt(player, clone6.Attach0, clone6.Attach1, 8, 0.5, folder)
							task.wait(0.25 * math.random() + 0.2)
							shafiBolt:Destroy()
						end)
					end
				end
			end
		end

		if part and not v15 and v8 - tick() <= 0 then
			v8 = tick() + 0.03
			local clone6 = assets.Phase1.Model.Spark:Clone()
			clone6.CFrame = CFrame.new(position2, position2 + v14) * CFrame.new(
				math.random(-15, 15),
				math.random(-5, 5),
				0
			)
			Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
			Util.Sound:Play(
				"BF_Thunder_M1_LightningHands_GroundSpark_0" .. tostring(math.random(1, 3)),
				clone6.Position
			)

			for _, emitter in pairs(clone6:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
		end

		for k, folder2 in pairs(v7) do
			if parentsByParent[k] and folder2:IsDescendantOf(workspace) then
				folder2:PivotTo(parentsByParent[k].PrimaryPart.CFrame)
			else
				for _, descendant in pairs(folder2:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") then
						descendant.Enabled = false
					elseif descendant:IsA("Sound") then
						descendant.Volume = 0
						descendant:Destroy()
					end
				end

				v7[k] = nil
				local v16 = folder2
				task.delay(1, function()
					v16:Destroy()
				end)
			end
		end

		if v3 - tick() <= 0 then
			v3 = tick() + 0.03
			local position = position2
			local magnitude2 = magnitude
			task.spawn(function()
				local v18 = nil

				for k, v20 in pairs(clonesByClone) do
					if v20:GetAttribute("Active") ~= false then
						continue
					end

					v20:SetAttribute("Active", true)
					v18 = v20
					break
				end

				if v18 == nil then
					return
				end

				local pointB = v18.PointB
				pointB.Position = position
				pointB:SetAttribute("Pos", position)
				v[v18] = v18
				v2[pointB] = pointB
				local v20 = 0.015 * math.random() + 0.015

				for i, descendant in pairs(pointB:GetDescendants()) do
					if descendant:IsA("Beam") then
						descendant.CurveSize0 = 0
						descendant.CurveSize1 = 0
						descendant.Width0 = descendant:GetAttribute("W0") * math.random(5, 25) / 10
						descendant.Width1 = descendant:GetAttribute("W1") * math.random(5, 25) / 20
						descendant.LightEmission = 0
						descendant.Brightness = math.random(4, 6)
						descendant.Enabled = true
						local textureLength = descendant.TextureLength
						local v21 = magnitude2 / range
						TweenService:Create(
							descendant,
							TweenInfo.new(v20 / 2, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, true),
							{
								CurveSize0 = math.random(-15, 15) * math.random(15, 20) / 10 * v21,
								CurveSize1 = math.random(-15, 15) * math.random(15, 20) / 10 * v21,
								Width0 = descendant:GetAttribute("W0") * math.random(2, 12) / 10 * v21,
								Width1 = descendant:GetAttribute("W1") * math.random(2, 12) / 20 * v21,
								LightEmission = 0.15,
								Brightness = math.random(5, 7),
								TextureSpeed = math.random(10, 25) / 15,
								TextureLength = textureLength * math.random(8, 12) / 10
							}
						):Play()
						local v22 = descendant
						task.delay(v20, function()
							v22.Enabled = false
							v22.TextureLength = textureLength
						end)
					elseif descendant:IsA("Attachment") then
						if not descendant:GetAttribute("Trail") then
							local v21 = magnitude2 / math.random(3, 6)
							local v22 = magnitude2 / math.random(3, 6)
							descendant.WorldCFrame = descendant.Parent.CFrame * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								0,
								(math.rad((math.random(-180, 180))))
							) * CFrame.new(v21, v22, 0)
							TweenService:Create(descendant, TweenInfo.new(v20), {
								Position = descendant.Position + Vector3.new(
									math.random(-5, 5),
									math.random(-5, 5),
									math.random(-5, 5)
								)
							}):Play()
						end
					elseif descendant:IsA("ParticleEmitter") then
						descendant.Enabled = true
						local v21 = descendant
						task.delay(v20, function()
							v21.Enabled = false
						end)
					elseif descendant:IsA("Trail") then
						descendant.Enabled = true
						local v21 = descendant
						task.delay(v20, function()
							v21.Enabled = false
						end)
					end
				end

				task.wait(v20)
				v[v18] = nil
				v2[pointB] = nil
				v18:SetAttribute("Active", false)
				pointB:SetAttribute("Pos", nil)
				pointB:SetAttribute("Step", 0)
				pointB:SetAttribute("Dir", nil)
			end)
		end

		for _, v16 in pairs(v) do
			v16.CFrame = cframe2 * CFrame.new(0, 0, -2.5)
		end

		for _, v16 in pairs(v2) do
			local pos = v16:GetAttribute("Pos") or position2
			local v17 = (v16:GetAttribute("Step") or 0) + 3
			v16:SetAttribute("Step", v17)

			if (pos - position2).Magnitude > 3 or v16:GetAttribute("Dir") ~= nil then
				local dir = v16:GetAttribute("Dir") or CFrame.new(pos, position2)
				v16:SetAttribute("Dir", dir)
				v16.Position = dir * CFrame.new(0, 0, -v17).Position
			else
				v16.Position = pos
			end
		end

		if value2 then
			for _, v16 in pairs(v6) do
				v16.Attach1.WorldPosition = value2.Position
				v16.CFrame = cframe2
			end
		else
			for k, v16 in pairs(v6) do
				local pos = v16:GetAttribute("Pos") or nil

				if pos == nil then
					v16:SetAttribute("Pos", position2)
					v16:SetAttribute("StartPos", position2)
				elseif (v16:GetAttribute("StartPos") - position2).Magnitude > 3 then
					local unit = (pos - position2).Unit
					local position = cframe2.Position
					local cframe3 = CFrame.lookAt(position, position2)
					local lookVector = cframe3.LookVector
					local upVector = cframe3.UpVector
					local vector2 = Vector3.new(cframe3.RightVector:Dot(unit), upVector:Dot(unit), lookVector:Dot(unit))
					local Y = math.abs(vector2.Y)

					if Y < 0.9 then
						math.clamp(math.atan2(vector2.Y, vector2.X), -0.7853981633974483, 0.7853981633974483)
					end

					if Y < 0.9 then
						local v17 = 0
						local v18 = 0
						local vectorToObjectSpace = cframe2:VectorToObjectSpace(unit)

						if math.abs(vectorToObjectSpace.X) > math.abs(vectorToObjectSpace.Z) then
							v18 = vectorToObjectSpace.X * magnitude * 0.5
						else
							v17 = vectorToObjectSpace.Z * magnitude * 0.5
						end

						local v19 = v12 * 12.5
						local v20 = math.clamp(v17, -35, 35) * 2
						local v21 = math.clamp(v18, -35, 35) * 2
						k.CurveSize0 += (v20 - k.CurveSize0) * v19
						k.CurveSize1 += (v21 - k.CurveSize1) * v19
					end

					v16:SetAttribute("Pos", position2)
				end

				v16.Attach1.Position = Vector3.new(v16.Attach1.Position.X, v16.Attach1.Position.Y, -magnitude)
				v16.CFrame = cframe2
			end
		end

		clone.CFrame = cframe2
		aura.Size = Vector3.new(aura.Size.X, aura.Size.Y, magnitude)
		aura.Weld.C1 = CFrame.new(0, 0, -magnitude / 2)
		v12 = task.wait()

		if holding.Value then
			continue
		end

		if v11 then
			Util.Sound:FadeOut(v11, 0.2)
		end

		for _, v16 in pairs({ clone4:GetDescendants(), clone3:GetDescendants() }) do
			for _, emitter in pairs(v16) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		task.delay(2, function()
			clone3:Destroy()
			clone4:Destroy()
		end)

		for _, v16 in pairs(emittersByEmitter) do
			v16.Enabled = false
		end

		for _, folder2 in pairs(v7) do
			for _, descendant in pairs(folder2:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:IsA("Sound") then
					descendant.Volume = 0
					descendant:Destroy()
				end
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		Util.Debris:AddItem(folder, 5)
		break
	end
end