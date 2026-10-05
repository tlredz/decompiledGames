local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local untransform = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("Untransform")
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local v = {
	ScrapModelA = "ArcsteelScrapModelA",
	ScrapModelA2 = "ArcsteelScrapModelB"
}

local function hasCrimsonGoldSkin(player)
	if typeof(player) ~= "Instance" then
		return false
	end

	local magnetFruitVFXColor = player:FindFirstChild("MagnetFruitVFXColor")

	if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
		return true
	end

	local character = player.Character
	local primaryPart = character and character.PrimaryPart

	if primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" then
		return true
	end

	return false
end

local function resolveScrap(childName: string, flag: boolean)
	if not flag then
		return scraps:FindFirstChild(childName)
	end

	local v2 = v[childName]
	local child = v2 and scraps:FindFirstChild(v2)

	if child then
		return child
	end

	return scraps:FindFirstChild(childName)
end

local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
CustomCollisions.new("Rocks")
local _WorldOrigin = workspace._WorldOrigin

local function RecolorMagnetColor(instance, p)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(p, instance, "MagnetFruitVFXColor")
	end

	return p
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

local function QuadBezier(p, p2, p3, p4)
	return (1 - p4) ^ 2 * p + 2 * (1 - p4) * p4 * p2 + p4 ^ 2 * p3
end

local function AlignCFrame(data, p)
	local v2 = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v2).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v2).Unit
	return CFrame.fromMatrix(p2, unit2, v2, unit3)
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(...)
	local v2 = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 25)
	local curveSize2 = math.random(5, 25)
	v2.CurveSize0 = curveSize
	v2.CurveSize1 = curveSize2
	v2.MinRadius = 3
	v2.MaxRadius = 13
	v2.Frequency = 0.5
	v2.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v2.MinThicknessMultiplier = 0.2
	v2.MaxThicknessMultiplier = maxThicknessMultiplier
	v2.MinTransparency = 0
	v2.MaxTransparency = 1
	v2.PulseSpeed = 10
	v2.PulseLength = 1000000
	v2.FadeLength = 0.2
	v2.ContractFrom = 0.5
	v2.Color = Color3.new(1, 0.380392, 0.380392)
	v2.ColorOffsetSpeed = 3
	return v2
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (p4 - p3) * p
	local v4 = p4 + (p5 - p4) * p
	local v5 = v2 + (v3 - v2) * p
	return v5 + (v3 + (v4 - v3) * p - v5) * p
end

local function TrailCurve(clone, p, position, position2, cframe, cframe2, p2)
	local magnitude = (position - position2).Magnitude
	local v2 = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v2 / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v2 / 1.5)).Position
	math.random(20, 30)
	local v3 = CFrame.new(position3, position3 + p.LookVector) * cframe.Position
	local v4 = CFrame.new(position4, position4 + p.LookVector) * cframe2.Position
	local lastTime = tick()
	local v5 = magnitude / p2 / 60

	while tick() - lastTime < v5 do
		local v6 = (tick() - lastTime) / v5
		local v7 = cubicBezier(v6, position, v3, v4, position2)
		clone.CFrame = CFrame.new(clone.CFrame:Lerp(CFrame.new(v7, position2), v6).Position)
		RunService.Heartbeat:Wait()
	end
end

return function(data)
	assert(
		data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)
	local player = data.Player
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 10)
	local root = data.Root
	local _ = root.Position
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
	local cFrame = root.CFrame
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://87316878647020"
	local rig = data.Rig
	local mechCF = data.MechCF
	rig:PivotTo(mechCF)
	Util.Sound:Play("Magnet_DeTransformation_DeTransform_02", mechCF.Position)
	task.spawn(function()
		local highlight = Instance.new("Highlight")
		highlight.Parent = rig
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.FillColor = Color3.new(0, 0, 0)
		TweenService:Create(highlight, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			FillTransparency = 0
		}):Play()
		task.wait(2.5)
		highlight:Destroy()
	end)
	local v2 = Util.Anims:Get(rig, "Magnet Mech Untransform")
	v2.Priority = Enum.AnimationPriority.Action4
	v2:Play()
	local cFrame2 = mechCF * CFrame.new(0, 25, 0)
	task.spawn(function()
		TweenService:Create(root, TweenInfo.new(0.1), {
			CFrame = cFrame * CFrame.new(0, 30, -10)
		}):Play()
		task.wait(0.1)
		local clone = untransform.Phase1.JumpImpact:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 30, -10) * CFrame.Angles(-0.6108652381980153, 0, 0)
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)
	task.spawn(function()
		task.wait(0.15)
		local clone = untransform.Phase2.PullAura:Clone()
		clone:ScaleTo(1.5)
		clone:PivotTo(cFrame2)
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				v4:Emit(1)
				v4.Enabled = true
				task.wait(2.1)
				v4.Enabled = false
			end)
		end
	end)
	task.spawn(function()
		task.wait(1.35)
		local clone = untransform.Phase2.HeadAura:Clone()
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				v4:Emit(1)
				v4.Enabled = true
				task.wait(0.95)
				v4.Enabled = false
			end)
		end

		task.wait(0.35)
		local clone2 = untransform.Phase2.StartStars:Clone()
		clone2.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				v4:Emit(1)
				v4.Enabled = true
				task.wait(0.5)
				v4.Enabled = false
			end)
		end
	end)
	task.spawn(function()
		task.wait(2.5)
		local clone = untransform.Phase3.Sphere:Clone()
		clone.Size = createVector(32.5, 32.5, 32.5)
		clone.CFrame = CFrame.new(cFrame2.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
			math.random(-180, 180),
			math.random(-180, 180),
			math.random(-180, 180)
		)
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		task.spawn(function()
			TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = clone.Size * 3.7
			}):Play()

			for _, decal in pairs(clone:GetDescendants()) do
				if not decal:IsA("Decal") then
					continue
				end

				decal.Transparency = 0.5
				TweenService:Create(decal, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
			end
		end)
		task.spawn(function()
			local clone2 = untransform.Phase3.Sphere1:Clone()
			clone2.Size = createVector(32.5, 32.5, 32.5)
			clone2.CFrame = CFrame.new(cFrame2.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
				math.random(-180, 180),
				math.random(-180, 180),
				math.random(-180, 180)
			)
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
			task.spawn(function()
				TweenService:Create(clone2, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = clone2.Size * 3.7
				}):Play()

				for _, decal in pairs(clone2:GetDescendants()) do
					if not decal:IsA("Decal") then
						continue
					end

					decal.Transparency = 0.5
					TweenService:Create(decal, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
						Transparency = 1,
						StudsPerTileU = math.random(15, 20) * 2,
						StudsPerTileV = math.random(15, 20) * 2
					}):Play()
				end
			end)
		end)
		task.spawn(function()
			for i = 1, 10 do
				local v4 = i
				task.spawn(function()
					local clone2 = script.Part:Clone()
					local cFrame3 = CFrame.new(cFrame2.Position) * CFrame.Angles(
						math.rad(math.random(-180, 180) / 10),
						math.rad((math.random(-180, 180))),
						(math.rad(math.random(-180, 180) / 10))
					) * CFrame.new(0, 0, -62.5)
					clone2.CFrame = cFrame3
					Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
					clone2.Attach1.WorldPosition = cFrame3 * CFrame.new(0, 0, 125).Position
					local shafiBolt = ShafiBolt(clone2.Attach0, clone2.Attach1, math.random(8, 12) * 1.25, 0.5, folder)
					shafiBolt.CurveSize0 = -90
					shafiBolt.CurveSize1 = 90
					shafiBolt.Frequency = math.random(5, 10) * 2
					shafiBolt.MaxRadius = 12
					shafiBolt.AnimationSpeed = math.random(20, 50) / 10
					local v7 = player
					local color = Color3.fromRGB(51, 54, 255)

					if typeof(v7) == "Instance" and v7.Parent then
						color = WrapColor3Constructor(color, v7, "MagnetFruitVFXColor")
					end

					shafiBolt.Color = color

					if v4 % 2 == 0 then
						local v8 = player
						local color2 = Color3.fromRGB(71, 80, 255)

						if typeof(v8) == "Instance" and v8.Parent then
							color2 = WrapColor3Constructor(color2, v8, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color2
						shafiBolt.Thickness = 1
					end

					task.spawn(function()
						task.wait(0.15 + math.random() * 0.1)
						shafiBolt:Destroy()
					end)
				end)
			end
		end)
		local clone2 = untransform.Phase3.ExplosionFinalModel:Clone()
		clone2:ScaleTo(1.5)
		local primaryPart = clone2.PrimaryPart
		primaryPart.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")

		if (workspace.CurrentCamera.CFrame.p - cFrame2.Position).Magnitude < 100 then
			Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.6)
		end

		DeleteImpactAfterDuration(primaryPart) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(primaryPart:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				if v4:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v4:GetAttribute("EmitDelay"))
				end

				local lifetime = v4.Lifetime
				v4.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
				v4:Emit(v4:GetAttribute("EmitCount") * 1.25)
			end)
		end
	end)
	local scrapModelA

	if hasCrimsonGoldSkin(data.Player) then
		local scrapModelA2 = v.ScrapModelA
		scrapModelA = scrapModelA2 and scraps:FindFirstChild(scrapModelA2)

		if not scrapModelA then
			scrapModelA = scraps:FindFirstChild("ScrapModelA")
		end
	else
		scrapModelA = scraps:FindFirstChild("ScrapModelA")
	end

	scrapModelA:ScaleTo(2)
	local children = scrapModelA:GetChildren()
	local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	local v4 = 1

	local function popScrap()
		local clone = children[math.random(1, #children)]:Clone()
		clone.Anchored = false
		clone.CanCollide = false
		clone.Size = clone.Size * v4 * (math.random(8, 20) / 10)
		local v5 = cFrame2.Position + vector2 + Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
		clone.CFrame = CFrame.new(v5) * CFrame.Angles(
			math.rad((math.random(-180, 180))),
			math.rad((math.random(-180, 180))),
			(math.rad((math.random(-180, 180))))
		)
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		clone.AssemblyLinearVelocity = Vector3.new(math.random(-100, 100), 0, math.random(-100, 100)).Unit * math.random(
			25,
			50
		) + Vector3.new(math.random(-35, 35), math.random(-10, 75), math.random(-35, 35))
		clone.AssemblyAngularVelocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
		task.delay(0.35, function()
			clone.CanCollide = true
		end)
		local v6 = 0.6 + math.random() * 0.6
		task.delay(v6, function()
			if not (clone and clone.Parent) then
				return
			end

			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(0, 0, 0)
			}):Play()
			local Debris = game:GetService("Debris")
			Debris:AddItem(clone, 0.2)
		end)
	end

	local cFrame4 = cFrame2 * CFrame.new(0, 2.5, 0)
	local now = tick()
	local v6 = tick() + 2
	local v7 = tick() + 1
	local now2 = tick()
	local v8 = tick() + 0.5
	local v9 = tick() + 3.5 - 0.975

	while true do
		if v6 - tick() > 0 and now - tick() <= 0 then
			for i = 1, 3 do
				local v10 = i
				task.spawn(function()
					local clone = nil

					if v10 == 1 then
						clone = untransform.Phase3.Trail:Clone()
					elseif v10 == 2 then
						clone = untransform.Phase3.Trail2:Clone()
					elseif v10 == 3 then
						clone = untransform.Phase3.Trail3:Clone()
					end

					clone.CFrame = cFrame4
					Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
					clone.CFrame = clone.CFrame * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					) * CFrame.new(0, 0, math.random(20, 35) * 2.5)

					for i2, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					TrailCurve(
						clone,
						cFrame4,
						clone.Position,
						cFrame4.Position + Vector3.new(
							math.random(-25, 25) / 5,
							math.random(-15, 15) / 5,
							math.random(-25, 25) / 5
						),
						CFrame.new(math.random(-50, 50) / 3, math.random(-50, 50) / 3, math.random(-50, 50) / 3),
						CFrame.new(math.random(-50, 50) / 3, math.random(-50, 50) / 3, math.random(-50, 50) / 3),
						math.random(25, 30) / 5
					)

					for i2, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
			end
		end

		if v6 - tick() > 0 and v7 - tick() <= 0 and now2 - tick() <= 0 then
			now2 = tick() + 0.1
			task.spawn(function()
				for i = 1, 3 do
					local v10 = i
					task.spawn(function()
						local clone = script.Part:Clone()
						local cFrame3 = CFrame.new(cFrame2.Position) * CFrame.new(
							math.random(-25, 25) * 1.5,
							math.random(-25, 25) / 5 - 35,
							math.random(-25, 25) * 1.5
						)
						clone.CFrame = cFrame3
						Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
						clone.Attach1.WorldPosition = cFrame3 * CFrame.new(0, 62.5 + math.random(-25, 10), 0).Position
						local shafiBolt = ShafiBolt(clone.Attach0, clone.Attach1, math.random(8, 12) * 1, 0.5, folder)
						shafiBolt.CurveSize0 = 0
						shafiBolt.CurveSize1 = 0
						shafiBolt.Frequency = math.random(5, 10) * 2
						shafiBolt.MaxRadius = 12
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local v13 = player
						local color = Color3.fromRGB(90, 90, 255)

						if typeof(v13) == "Instance" and v13.Parent then
							color = WrapColor3Constructor(color, v13, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v10 % 2 == 0 then
							local v14 = player
							local color2 = Color3.fromRGB(38, 38, 255)

							if typeof(v14) == "Instance" and v14.Parent then
								color2 = WrapColor3Constructor(color2, v14, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color2
							shafiBolt.Thickness = 0.7
						end

						task.spawn(function()
							task.wait(0.1 + math.random() * 0.035)
							shafiBolt:Destroy()
						end)
					end)
				end
			end)
		end

		if v6 - tick() > 0 and v8 - tick() <= 0 then
			task.spawn(popScrap)
			task.spawn(popScrap)
		end

		task.wait(0.1)

		if not (v9 - tick() <= 0) then
			continue
		end

		local clone = untransform.Phase3.EndImpact:Clone()
		clone.CFrame = cFrame2 * CFrame.new(0, -30, 0)
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v10 = emitter
			task.spawn(function()
				if v10:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v10:GetAttribute("EmitDelay"))
				end

				local lifetime = v10.Lifetime
				v10.Lifetime = NumberRange.new(lifetime.Min * 1.15, lifetime.Max * 1.15)
				v10:Emit(v10:GetAttribute("EmitCount") * 1)
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		rig:Destroy()
		v4 = 1.15

		for _ = 1, 12 do
			task.spawn(popScrap)
			task.spawn(popScrap)
		end

		break
	end
end