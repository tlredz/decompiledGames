local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Gas").Transformed.Z.Assets
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

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, position, p2, p3, position2)
	local v = position + (p2 - position) * p
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (position2 - p3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function GasDomainExpansion(cframe, folder, duration)
	task.spawn(function()
		task.wait(0.3)
		local clone = assets.Phase2.RingBeam:Clone()
		clone.CFrame = cframe
		clone.Parent = folder
		local descendants = clone:GetDescendants()

		for _, instance in pairs(descendants) do
			if instance:IsA("Beam") then
				instance.CurveSize0 *= 1
				instance.CurveSize1 *= 1
				instance.Width0 *= 1
				instance.Width1 *= 1
			elseif instance:IsA("Attachment") then
				instance.Position = Vector3.new(
					instance.Position.X * 1,
					instance.Position.Y * 1,
					instance.Position.Z * 1
				)
			end
		end

		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

		for _, instance in pairs(descendants) do
			if instance:IsA("Beam") then
				local v = instance
				task.spawn(function()
					local tween = TweenService:Create(v, tweenInfo, {
						CurveSize0 = v.CurveSize0 * 5.5,
						CurveSize1 = v.CurveSize1 * 5.5,
						Width0 = v.Width0 * 5.5,
						Width1 = v.Width1 * 5.5,
						TextureSpeed = v.TextureSpeed
					})
					tween:Play()
					tween.Completed:Wait()
					TweenService:Create(v, tweenInfo2, {
						TextureSpeed = 0.5,
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			elseif instance:IsA("Attachment") then
				local v = instance
				task.spawn(function()
					local tween = TweenService:Create(v, tweenInfo, {
						Position = Vector3.new(v.Position.X * 5.5, 0, v.Position.Z * 5.5)
					})
					tween:Play()
					tween.Completed:Wait()
				end)
			end
		end

		task.wait(duration)
		clone:Destroy()
	end)
	task.spawn(function()
		task.wait(0.15)
		local clone = assets.Phase2.RingBeam:Clone()
		clone.CFrame = cframe
		clone.Parent = folder
		local descendants = clone:GetDescendants()

		for _, instance in pairs(descendants) do
			if instance:IsA("Beam") then
				instance.CurveSize0 *= 1
				instance.CurveSize1 *= 1
				instance.Width0 *= 1
				instance.Width1 *= 1
			elseif instance:IsA("Attachment") then
				instance.Position = Vector3.new(
					instance.Position.X * 1,
					instance.Position.Y * 1,
					instance.Position.Z * 1
				)
			end
		end

		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

		for _, instance in pairs(descendants) do
			if instance:IsA("Beam") then
				local v = instance
				task.spawn(function()
					local tween = TweenService:Create(v, tweenInfo, {
						CurveSize0 = v.CurveSize0 * 4,
						CurveSize1 = v.CurveSize1 * 4,
						Width0 = v.Width0 * 4,
						Width1 = v.Width1 * 4,
						TextureSpeed = v.TextureSpeed
					})
					tween:Play()
					tween.Completed:Wait()
					TweenService:Create(v, tweenInfo2, {
						TextureSpeed = 0.5,
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			elseif instance:IsA("Attachment") then
				local v = instance
				task.spawn(function()
					local tween = TweenService:Create(v, tweenInfo, {
						Position = Vector3.new(v.Position.X * 4, 0, v.Position.Z * 4)
					})
					tween:Play()
					tween.Completed:Wait()
				end)
			end
		end

		task.wait(duration)
		clone:Destroy()
	end)
	task.spawn(function()
		local clone = assets.Phase2.RingBeam:Clone()
		clone.CFrame = cframe
		clone.Parent = folder
		local descendants = clone:GetDescendants()

		for _, instance in pairs(descendants) do
			if instance:IsA("Beam") then
				instance.CurveSize0 *= 1
				instance.CurveSize1 *= 1
				instance.Width0 *= 1
				instance.Width1 *= 1
			elseif instance:IsA("Attachment") then
				instance.Position = Vector3.new(
					instance.Position.X * 1,
					instance.Position.Y * 1,
					instance.Position.Z * 1
				)
			end
		end

		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

		for _, instance in pairs(descendants) do
			if instance:IsA("Beam") then
				local v = instance
				task.spawn(function()
					local tween = TweenService:Create(v, tweenInfo, {
						CurveSize0 = v.CurveSize0 * 3,
						CurveSize1 = v.CurveSize1 * 3,
						Width0 = v.Width0 * 3,
						Width1 = v.Width1 * 3,
						TextureSpeed = v.TextureSpeed
					})
					tween:Play()
					tween.Completed:Wait()
					TweenService:Create(v, tweenInfo2, {
						TextureSpeed = 0.5,
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			elseif instance:IsA("Attachment") then
				local v = instance
				task.spawn(function()
					local tween = TweenService:Create(v, tweenInfo, {
						Position = Vector3.new(v.Position.X * 3, 0, v.Position.Z * 3)
					})
					tween:Play()
					tween.Completed:Wait()
				end)
			end
		end

		task.wait(duration)
		clone:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GasRingBeams(p, parent, p2, p3)
	local lastTime = tick()
	task.spawn(function()
		repeat
			local clone = assets.Phase2.RingBeam:Clone()
			clone.CFrame = p * CFrame.new(0, -50, 0)
			clone.Parent = parent
			local descendants = clone:GetDescendants()

			for _, instance in pairs(descendants) do
				if instance:IsA("Beam") then
					instance.CurveSize0 *= 7
					instance.CurveSize1 *= 7
				elseif instance:IsA("Attachment") then
					instance.Position = Vector3.new(
						instance.Position.X * 7,
						instance.Position.Y * 7,
						instance.Position.Z * 7
					)
				end
			end

			local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

			for _, instance in pairs(descendants) do
				if instance:IsA("Beam") then
					local v = instance
					local v2 = tweenInfo
					local v3 = tweenInfo2
					task.spawn(function()
						local tween = TweenService:Create(v, v2, {
							CurveSize0 = v.CurveSize0 * 0.75,
							CurveSize1 = v.CurveSize1 * 0.75
						})
						tween:Play()
						tween.Completed:Wait()
						TweenService:Create(v, v3, {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				elseif instance:IsA("Attachment") then
					local v = instance
					local v2 = tweenInfo
					local v3 = tweenInfo2
					task.spawn(function()
						local tween = TweenService:Create(v, v2, {
							Position = Vector3.new(v.Position.X * 0.75, 50, v.Position.Z * 0.75)
						})
						tween:Play()
						tween.Completed:Wait()
						TweenService:Create(v, v3, {
							Position = Vector3.new(v.Position.X, 55, v.Position.Z)
						}):Play()
					end)
				end
			end

			local clone2 = assets.Phase2.RingBeam:Clone()
			clone2.CFrame = p * CFrame.new(0, -15, 0)
			clone2.Parent = parent
			local descendants2 = clone2:GetDescendants()

			for _, instance in pairs(descendants2) do
				if instance:IsA("Beam") then
					instance.CurveSize0 *= 5
					instance.CurveSize1 *= 5
				elseif instance:IsA("Attachment") then
					instance.Position = Vector3.new(
						instance.Position.X * 5,
						instance.Position.Y * 5,
						instance.Position.Z * 5
					)
				end
			end

			local tweenInfo3 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tweenInfo4 = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

			for _, instance in pairs(descendants2) do
				if instance:IsA("Beam") then
					local v = instance
					local v2 = tweenInfo3
					local v3 = tweenInfo4
					task.spawn(function()
						local tween = TweenService:Create(v, v2, {
							CurveSize0 = v.CurveSize0 * 0.95,
							CurveSize1 = v.CurveSize1 * 0.95
						})
						tween:Play()
						tween.Completed:Wait()
						TweenService:Create(v, v3, {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				elseif instance:IsA("Attachment") then
					local v = instance
					local v2 = tweenInfo3
					local v3 = tweenInfo4
					task.spawn(function()
						local tween = TweenService:Create(v, v2, {
							Position = Vector3.new(v.Position.X * 0.95, 35, v.Position.Z * 0.95)
						})
						tween:Play()
						tween.Completed:Wait()
						TweenService:Create(v, v3, {
							Position = Vector3.new(v.Position.X, 40, v.Position.Z)
						}):Play()
					end)
				end
			end

			task.wait(0.35)
		until p2 <= tick() - lastTime or p3.Value == true
	end)
end

local function GasGroundPoison(cframe, folder, p, raycastParams, explosionTrigger)
	local raycastResult = workspace:Raycast(
		cframe.Position + createVector(0, 1, 0),
		CFrame.new(cframe.Position).UpVector * -25,
		raycastParams
	)

	if raycastResult then
		local clone = assets.Phase3.GroundGas:Clone()
		clone.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local v = tick() + p

		repeat
			task.wait()
		until v - tick() <= 0 or explosionTrigger.Value == true

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end
end

local function GasDomainCreate(_, cframe, folder, duration, folder2, explosionTrigger)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function SpinningTrails(instance, cFrame, p, p2, p3, p4)
		task.spawn(function()
			local clone = instance:Clone()
			clone.CFrame = cFrame
			clone.Parent = folder

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
					descendant.Enabled = true
				elseif descendant:IsA("Attachment") then
					TweenService:Create(
						descendant,
						TweenInfo.new(p4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(
								descendant.Position.X * p3,
								descendant.Position.Y * p3,
								descendant.Position.Z * p3
							)
						}
					):Play()
				end
			end

			repeat
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone.CFrame * CFrame.Angles(0, math.rad(p2), 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			until p.Value == false

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
	end

	task.spawn(function()
		local spinTrails = assets.Phase3.SpinTrails
		local clone = assets.Phase3.GasDomain2:Clone()
		clone.CFrame = cframe
		clone.Parent = folder2

		for _, emitter in pairs(folder2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local boolValue = Instance.new("BoolValue")
		boolValue.Value = true
		boolValue.Parent = folder
		task.spawn(function()
			for i = 1, 2 do
				local trail1 = spinTrails.Trail1
				local cFrame = folder2.CFrame

				if i == 2 then
					cFrame *= CFrame.Angles(0, 3.141592653589793, 0)
				end

				SpinningTrails(trail1, cFrame, boolValue, 125, 7, 1) -- equivalent call inferred; original call site unknown
			end
		end)
		task.spawn(function()
			for _ = 1, 10 do
				SpinningTrails(
					spinTrails.Trail2,
					folder2.CFrame * CFrame.Angles(
						math.rad((math.random(-15, 15))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-15, 15))))
					),
					boolValue,
					math.random(50, 120),
					math.random(5, 8),
					1
				) -- equivalent call inferred; original call site unknown
			end
		end)
		local v = tick() + duration

		repeat
			task.wait()
		until v - tick() <= 0 or explosionTrigger.Value == true

		boolValue.Value = false

		for _, emitter in pairs(folder2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)

	local function TrailCurve(instance, cFrame, position, position2)
		local magnitude = (position - position2).Magnitude
		instance.CFrame = CFrame.new(position, position2)
		local v = (position - position2) / 2
		local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
		local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
		local cframe2 = CFrame.new(math.random(-50, 50), math.random(-50, 50) / 2, math.random(-50, 50))
		local cframe3 = CFrame.new(math.random(-50, 50), math.random(-50, 50) / 2, math.random(-50, 50))
		local v2 = CFrame.new(position3, position3 + cFrame.LookVector) * cframe2.Position
		local v3 = CFrame.new(position4, position4 + cFrame.LookVector) * cframe3.Position
		local speed = instance:GetAttribute("Speed")
		local lastTime = tick()
		local v4 = magnitude / speed / 60
		local _ = (magnitude / speed + speed) / 60

		while tick() - lastTime < v4 do
			local v5 = (tick() - lastTime) / v4
			local v6 = cubicBezier(v5, position, v2, v3, position2)
			instance.CFrame = instance.CFrame:Lerp(CFrame.new(v6, position2), v5)
			RunService.Heartbeat:Wait()
		end
	end

	local domainTrails = assets.Phase3.DomainTrails
	local clonesByClone = {}

	for _ = 1, 5 do
		local clone = domainTrails.Trail1:Clone()
		clone.CFrame = cframe
		clone.Parent = folder
		clone:SetAttribute("Moving", false)
		clone:SetAttribute("Speed", math.random(15, 35) / 5)
		clonesByClone[clone] = clone
	end

	for _ = 1, 5 do
		local clone = domainTrails.Trail2:Clone()
		clone.CFrame = cframe
		clone.Parent = folder
		clone:SetAttribute("Moving", false)
		clone:SetAttribute("Speed", math.random(15, 35) / 5)
		clonesByClone[clone] = clone
	end

	for _, folder3 in pairs(clonesByClone) do
		for _, emitter in pairs(folder3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Destroy()
			end
		end
	end

	local lastTime = tick()
	local position = nil
	local v = nil

	while true do
		for _, v2 in pairs(clonesByClone) do
			if v2:GetAttribute("Moving") ~= false then
				continue
			end

			local v3 = v2
			task.spawn(function()
				v3:SetAttribute("Moving", true)
				position = v3.Position
				v = cframe * CFrame.new(math.random(-70, 70), math.random(-50, 50), math.random(-70, 70)).Position
				TrailCurve(v3, cframe, position, v)
				v3:SetAttribute("Moving", false)
			end)
		end

		task.wait(0.1)

		if not (duration <= tick() - lastTime or explosionTrigger.Value == true) then
			continue
		end

		for _, folder3 in pairs(clonesByClone) do
			for _, trail in pairs(folder3:GetDescendants()) do
				if trail:IsA("Trail") then
					trail:Destroy()
				end
			end
		end

		break
	end
end

local function CameraBlur(parent, duration)
	task.spawn(function()
		local currentCamera = workspace.CurrentCamera
		task.spawn(function()
			local clone = assets.Phase4.Blur:Clone()
			local tween = TweenService:Create(clone, TweenInfo.new(0.15), {
				Size = clone.Size
			})
			clone.Size = 0
			clone.Parent = workspace.CurrentCamera
			tween:Play()
			task.wait(duration)
			local tween2 = TweenService:Create(clone, TweenInfo.new(0.25), {
				Size = 0
			})
			tween2:Play()
			tween2.Completed:Wait()
			clone:Destroy()
		end)
		local clone = assets.Phase4.CameraFocus:Clone()
		clone.Parent = parent
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
		end)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.wait(duration)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(0.5)
		renderSteppedConnection:Disconnect()
		clone:Destroy()
	end)
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
return function(data)
	if data.Stage == 2 and data.Position then
		local duration = data.Duration
		local cframe = CFrame.new(data.Position)

		if (data.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1100 then
			return
		end

		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoidRootPart and humanoid and humanoid.Health > 0 and data.Owner ~= character and (cframe.Position - humanoidRootPart.Position).Magnitude <= 85 then
			task.spawn(function()
				local blurEffect = Instance.new("BlurEffect")
				blurEffect.Name = "GZBlur"
				blurEffect.Size = 10
				local Debris = game:GetService("Debris")
				Debris:AddItem(blurEffect, duration + 0.5)
				local tween = TweenService:Create(blurEffect, TweenInfo.new(0.15), {
					Size = blurEffect.Size
				})
				blurEffect.Size = 0
				blurEffect.Parent = workspace.CurrentCamera
				tween:Play()
				local lastTime = tick()
				local v = true

				while tick() - lastTime < duration and blurEffect.Parent == workspace.CurrentCamera and localPlayer.Character == character and humanoidRootPart:IsDescendantOf(workspace) and not (humanoid.Health <= 0) do
					if v and (cframe.Position - humanoidRootPart.Position).Magnitude > 85 then
						TweenService:Create(blurEffect, TweenInfo.new(0.25), {
							Size = 0
						}):Play()
						v = false
					elseif v == false and (cframe.Position - humanoidRootPart.Position).Magnitude <= 85 then
						tween:Play()
						v = true
					end

					task.wait(0.1)
				end

				if blurEffect.Parent then
					local tween2 = TweenService:Create(blurEffect, TweenInfo.new(0.25), {
						Size = 0
					})
					tween2:Play()
					tween2.Completed:Wait()
					blurEffect:Destroy()
				end
			end)
		end

		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 7)
		local v = Util.Sound:Play("BF_GASFRUIT_TSFM_SuffocatingFlames_Explode_01", cframe.Position)
		GasDomainExpansion(cframe, folder, duration)
		task.wait(0.3)
		local clone = assets.Phase3.GasDomain:Clone()
		clone.CFrame = cframe
		local explosionTrigger = data.ExplosionTrigger
		clone.Parent = folder
		task.spawn(function()
			GasRingBeams(cframe, folder, duration, explosionTrigger) -- equivalent call inferred; original call site unknown
		end)
		task.spawn(function()
			GasGroundPoison(cframe, folder, duration * 0.75, raycastParams, explosionTrigger)
		end)
		GasDomainCreate(raycastParams, cframe, folder, duration, clone, explosionTrigger)

		if explosionTrigger.Value == true then
			task.spawn(function()
				local clone2 = assets.Phase5.Explosion:Clone()
				clone2.CFrame = cframe
				clone2.Parent = folder

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v2 = emitter
					coroutine.wrap(function()
						if v2:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v2:GetAttribute("EmitDelay"))
						end

						v2:Emit(v2:GetAttribute("EmitCount"))
					end)()
				end
			end)

			if v then
				Util.Sound:FadeOut(v, 0.5)
			end
		end
	else
		local root = data.Root

		if data.Holding then
			local folder = Instance.new("Folder")
			folder.Parent = _WorldOrigin
			local clone = assets.Phase0.HoldAura:Clone()
			clone.CFrame = root.CFrame
			clone.Parent = folder
			local descendantsByDescendant = {}

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = true
				elseif descendant:IsA("Attachment") and descendant.Name == "Attachment" then
					descendantsByDescendant[descendant] = descendant
				end
			end

			local v = Util.Sound:Play("BF_GASFRUIT_TSFM_SuffocatingFlames_Charge_01", clone)

			while true do
				for _, v2 in pairs(descendantsByDescendant) do
					v2.WorldCFrame *= CFrame.Angles(0.008726646259971648, 0.008726646259971648, 0.008726646259971648)
				end

				clone.CFrame = CFrame.new(root.CFrame * CFrame.new(-3, 6.666, -38).Position)
				task.wait()

				if data.Holding:IsDescendantOf(workspace) and data.Holding.Value then
					continue
				end

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				Util.Sound:FadeOut(v, 0.2)
				task.wait(5)
				folder:Destroy()
				return
			end
		else
			local start = data.Start
			local v = data.End
			local duration = data.Duration

			if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1100 then
				return
			end

			if root == game.Players.LocalPlayer.Character.HumanoidRootPart then
				Util.CameraShaker:ShakeOnce(4, 6, 0.4, 0.4)
			end

			local folder = Instance.new("Folder")
			folder.Parent = _WorldOrigin
			local cframe = CFrame.new(start, v)
			local clone = assets.Phase1.StartImpact:Clone()
			clone.CFrame = cframe
			clone.Parent = folder
			Util.Sound:Play("BF_GASFRUIT_TSFM_SuffocatingFlames_Fire_01", cframe.Position)
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

			local clone2 = assets.Phase1.Projectile:Clone()
			clone2.CFrame = cframe
			clone2.Parent = folder

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local cFrame = CFrame.new(v, start) * CFrame.Angles(0, 3.141592653589793, 0)
			local tween = TweenService:Create(
				clone2,
				TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = cFrame
				}
			)
			tween:Play()
			tween.Completed:Wait()

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local cframe2 = CFrame.new(cFrame.Position)
			local clone3 = assets.Phase2.Explosion:Clone()
			clone3.CFrame = cframe2
			clone3.Parent = folder

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				coroutine.wrap(function()
					if v3:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v3:GetAttribute("EmitDelay"))
					end

					v3:Emit(v3:GetAttribute("EmitCount"))
				end)()
			end

			Util.Debris:AddItem(folder, 5)
		end
	end
end