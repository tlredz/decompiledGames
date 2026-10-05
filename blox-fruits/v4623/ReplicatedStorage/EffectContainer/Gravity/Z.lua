local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(script.Parent.Modules.Beziers)
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage2:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
require(script.Parent.Modules.RockRipple)
local UselessRocksShouldntEvenBeUsedForGravity = require(script.Parent.Modules.UselessRocksShouldntEvenBeUsedForGravity)
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
require(script.Parent.Modules.SwirlsZ)
require(interpolationScheme.Parent:WaitForChild("SequenceMaps"):WaitForChild("NumSeqMap"))
local FX = require(ReplicatedStorage2:WaitForChild("FX"))
local z_Un = FX:WaitForChild("Gravity").Z_Un

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

local function ScaleParticle(descendant, p)
	local keypoints = descendant.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	descendant.Size = NumberSequence.new(numberSequenceKeypoints)
	descendant.Speed = NumberRange.new(descendant.Speed.Min * p, descendant.Speed.Max * p)
	descendant.Acceleration *= p
end

local function ScaleAttachmentsAndEmittersWithin(folder, p: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= p
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, p)
		end
	end
end

local function enableAll(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local emit = z_Un.Z.Z.Pull.Holder.Emit
emit.Parent = nil
return function(data)
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = data.Stage
	local player = data.Player

	if stage == 1 then
		local root = data.Root
		local holding = data.Holding

		if not (holding or holding.Value) then
			return
		end

		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.175

					if root.Parent == game.Players.LocalPlayer.Character then
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect.Parent = game.Lighting
						Util.Debris:AddItem(colorCorrectionEffect, 0.15)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.05, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Brightness = -0.1,
								Contrast = 0.07,
								Saturation = -0.07,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(211, 207, 248),
									player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.05)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Brightness = 0,
								Contrast = 0,
								Saturation = 0,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 255, 255),
									player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
					end
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)
		local TweenService2 = game:GetService("TweenService")
		local cFrame = root.CFrame * CFrame.new(0, 0, -3.5)
		local lastTime = tick()
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Cylinder
		part.Anchored = true
		part.Size = createVector(0, 0, 0)
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		part.Transparency = 0.9
		part.Size = createVector(0.123, 0.123, 0.123)
		part.Color = Util.WrapColor3Constructor(Color3.fromRGB(30, 0, 60), player, "GravityFruitVFXColor")
		local clone = emit:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, workspace.Terrain, player, "GravityFruitVFXColor")
		clone.spin:Emit(1)
		local clone2 = z_Un.Z.BLACKHOLE:Clone()
		clone2.Name = ""
		clone2:PivotTo(cFrame)
		Util.SetParentOverrideWithColor(clone2, folder, player, "GravityFruitVFXColor")
		local v2 = Util.Sound:Play("GravFruit_Z_Hold_01", root)
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(v2, TweenInfo.new(1), {
			RollOffMinDistance = 60,
			Volume = 1.8
		}):Play()
		local scale = clone2:GetScale()
		local v3 = nil
		local v4 = nil

		while not (tick() - lastTime > 0.15) or holding:IsDescendantOf(workspace) and holding.Value do
			local v5

			if tick() - lastTime < 0.2 then
				v5 = 0.1 + (tick() - lastTime) / 0.2 * 0.5
			else
				v5 = math.min(1, (tick() - lastTime - 0.2) / 2) + 0.6
			end

			local cFrame2 = root.CFrame * CFrame.new(0, 0, -3.5)
			clone2:PivotTo(cFrame2)
			clone2:ScaleTo(scale * v5)
			local clone3 = z_Un.Z.Z:Clone()
			clone3.Name = ""
			clone3:ScaleTo(v5)
			clone3:PivotTo(cFrame2)
			Util.SetParentOverrideWithColor(clone3, folder, player, "GravityFruitVFXColor")
			local distortion = clone3.Pull.Distortion
			clone.CFrame = cFrame2
			clone.spin.Size = NumberSequence.new(distortion.Size.X * 0.63)
			v4 = distortion
			v3 = clone3

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
			TweenService2:Create(distortion, tweenInfo, {
				Size = createVector(1, 1, 1),
				Transparency = 1
			}):Play()
			TweenService2:Create(clone3.Pull.Layer, tweenInfo, {
				Size = createVector(1, 1, 1),
				Transparency = 1
			}):Play()
			TweenService2:Create(clone3.Pull.Layer.Highlight, TweenInfo.new(0.12), {
				FillTransparency = 1
			}):Play()
			task.defer(function()
				clone3.Pull.Layer.Highlight.Adornee = distortion
			end)
			local v9 = distortion
			local v10 = clone3
			task.spawn(function()
				task.wait(0.275)
				TweenService2:Create(v9.Highlight, TweenInfo.new(0.01), {
					FillTransparency = -1,
					FillColor = Util.WrapColor3Constructor(Color3.fromRGB(80, 78, 136), player, "GravityFruitVFXColor")
				}):Play()
				TweenService2:Create(v10.Pull.Layer.Highlight, TweenInfo.new(0.01), {
					FillTransparency = -1,
					FillColor = Util.WrapColor3Constructor(Color3.fromRGB(80, 78, 136), player, "GravityFruitVFXColor")
				}):Play()
			end)
			local v11 = clone3
			task.delay(0.3, function()
				v11:Destroy()
			end)
			local v12 = 25 * v5

			for i = 1, 3 do
				local clone4 = z_Un.Z.beam1:Clone()
				clone4.CFrame = clone3:GetPivot() * CFrame.new(0, -1, 0) * CFrame.Angles(
					(math.random() - 0.5) * 1,
					math.random() * 3.141592653589793 * 2,
					i * 0.5 / 3
				)
				Util.SetParentOverrideWithColor(clone4, folder, player, "GravityFruitVFXColor")
				local v13 = i
				local v15 = v12
				task.spawn(function()
					local v16 = math.random(24, 32)
					local v17 = 0.3 + math.random() * 0.1
					local lastTime2 = tick()
					local v18 = 0.016666666666666666

					while tick() - lastTime2 < v17 do
						local v19 = ((tick() - lastTime2) / v17) ^ (v13 == 1 and 0.5 or v13)
						clone4.CFrame *= CFrame.Angles(0, v18 * v16 * (1 + v19), 0)

						for i2, child in pairs(clone4:GetChildren()) do
							if child:IsA("Attachment") then
								local v21 = child.Name == "a" and 1 or -1
								child.Position = Vector3.new(0, 0, v15 * v21 * (1 - v19))
							elseif child:IsA("Beam") then
								child.CurveSize0 = v15 * (1 - v19) * 2 / 3 * 2
								child.CurveSize1 = -v15 * (1 - v19) * 2 / 3 * 2
								child.Width1 = v15 * (1 - v19) * 0.5
								child.Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new((1 - v19) * 0.333, 0),
									NumberSequenceKeypoint.new(1 - v19, 1),
									NumberSequenceKeypoint.new(1, 1)
								})
							end
						end

						local RunService = game:GetService("RunService")
						v18 = RunService.RenderStepped:Wait()
					end

					clone4:Destroy()
				end)
			end

			local lastTime2 = tick()

			while tick() - lastTime2 < 0.11 do
				local cFrame3 = root.CFrame * CFrame.new(0, 0, -3.5)
				clone2:PivotTo(cFrame3)
				clone.CFrame = cFrame3
				clone.spin.Size = NumberSequence.new(distortion.Size.X * 0.63)
				local v14 = distortion.Size.X / 2
				local position = distortion.Position
				local vector2 = Vector3.new(0, -v14 * 2, 0)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Characters,
					workspace.Enemies,
					workspace._WorldOrigin
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(position, vector2, raycastParams)

				if raycastResult then
					local position2 = raycastResult.Position
					local magnitude = (position - position2).Magnitude

					if magnitude < v14 then
						local v15 = math.sqrt(v14 ^ 2 - magnitude ^ 2)
						part.Size = Vector3.new(0.123, v15 * 2, v15 * 2)
						part.CFrame = CFrame.new((Vector3.new(position.X, position2.Y + 0.0615, position.Z))) * CFrame.Angles(
							0,
							0,
							1.5707963267948966
						)
						part.Parent = folder
					else
						part.Parent = nil
					end
				else
					part.Parent = nil
				end

				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			end
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.1)
		end

		task.spawn(function()
			local scale2 = clone2:GetScale()
			local lastTime2 = tick()

			while tick() - lastTime2 < 0.3 do
				clone2:ScaleTo(scale2 * (1 - (tick() - lastTime2) / 0.3))

				if v3 and v3.Parent and v3:IsDescendantOf(workspace) then
					clone.spin.Size = NumberSequence.new(v4.Size.X * 0.63)
				else
					clone:Destroy()
				end

				task.wait()
			end

			if clone and clone.Parent then
				clone:Destroy()
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(0.5)
			clone2:Destroy()
		end)
		local tween = TweenService2:Create(
			part,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
			{
				Size = createVector(0, 0, 0),
				Transparency = 1
			}
		)
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
		task.wait(5)
		folder:Destroy()
	elseif stage == 2 then
		local v = data.ExplosionSize / 90
		local root = data.Root
		task.wait(0.1)
		task.spawn(function()
			if (origin - workspace.CurrentCamera.CFrame.Position).Magnitude < 290 then
				Util.CameraShaker:ShakeOnce(11, 11, 0.05, 1.45, createVector(1, 1, 1), createVector(1, 1, 1))
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 1.5)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
					{
						Brightness = -0.6,
						Contrast = 0.2,
						Saturation = 0,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(124, 80, 255),
							player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				task.wait(0.1)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Brightness = 0,
						Contrast = 0,
						Saturation = 0,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
			end
		end)
		local clone = z_Un.Z.ZPOP:Clone()
		Util.ResizeModel(clone, v)
		local primaryPart = clone.PrimaryPart
		primaryPart.CFrame = root.CFrame
		Util.Debris:AddItem(clone, 2)
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "GravityFruitVFXColor")
		task.defer(function()
			clone.HighlightInvert.Adornee = clone
		end)
		local play = Util.Sound:Play("GravFruit_Z_ExplosionRelease_05", root.Position)
		play.Volume = 2.5
		task.spawn(function()
			task.wait(0.075)
			emitAll(primaryPart.Pop)
		end)
		task.spawn(function()
			task.wait(0.15)
			local ray = Util.Ray
			local v2 = root.Position + createVector(0, 2, 0)
			local v3 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
			local v4, v5, v6 = ray(v2, createVector(-0, -60, -0), v3, false)

			if v4 ~= nil then
				local clone2 = z_Un.Z.ZFLOOR:Clone()
				Util.ResizeModel(clone2, v)
				clone2.CFrame = CFrame.new(v5)
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "GravityFruitVFXColor")
				Util.Debris:AddItem(clone2, 3.5)
				clone2.vfx.Smoke.Color = ColorSequence.new(v4.Color)
				clone2.vfx.Smoke2.Color = ColorSequence.new(v4.Color)
				emitAll(clone2)
				local v7 = 20 * v
				UselessRocksShouldntEvenBeUsedForGravity(v5, {
					RandomOffset = 0.2,
					Radius = v7 + 40 * v,
					Size = 20 * (0.4 + v * 0.6),
					Duration = 3.5,
					Amount = 33 * (0.2 + v * 0.8)
				})
				local v9 = CFrame.new(v5, v5 + v6) * CFrame.Angles(-1.5707963267948966, 0, 0)
				local v10 = v7 * 3
				local random = Random.new()
				local v11 = math.floor(v10 / 3)
				local v12 = math.max(6, v11 / 3)
				local v13 = v11 / 2

				for i = 1, v13 do
					local v14 = 6.283185307179586 * (i / v13)
					local v15 = Rock2.new({
						Type = "Ground",
						FadeOut = { 0.25, 0.5 },
						FadeIn = { 0.25, 0.5 },
						Lifetime = { 1, 2.5 },
						Size = Vector3.new(random:NextNumber(1, 2), random:NextNumber(1, 2), random:NextNumber(1, 2)),
						Scale = { v12 / 4, v12 / 2 }
					})
					local unit = Vector3.new(
						math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793),
						random:NextNumber(0.666, 1),
						(math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793))
					).Unit
					v15.Type = "Flying"
					v15:Spawn(v9 * CFrame.Angles(0, v14, 0) * CFrame.new(0, 0, -v10 / 4))
					v15:Eject({
						Velocity = Util.Misc.Physics.Velocity(
							Vector3.new(),
							unit * random:NextNumber(v12 * 3.5, v12 * 6.5),
							Vector3.new(0, -workspace.Gravity * random:NextNumber(0.45, 1.3), 0),
							0.25 + random:NextNumber(0, 2)
						),
						AngularVelocity = Vector3.new(
							random:NextNumber(-1, 1),
							random:NextNumber(-1, 1),
							random:NextNumber(-1, 1)
						) * 2 * 3.141592653589793 * (1 / v15.Scale)
					})
				end
			end
		end)
		task.spawn(function()
			task.wait(0.185)
			local cFrame = root.CFrame
			local folder = Instance.new("Folder", _WorldOrigin)
			Util.Debris:AddItem(folder, 2)

			for _ = 1, 9 do
				task.spawn(function()
					local clone2 = z_Un.Z.SPINWIND:Clone()
					Util.ResizeModel(clone2, v)
					clone2.CFrame = cFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
					Util.SetParentOverrideWithColor(clone2, folder, player, "GravityFruitVFXColor")
					TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						CFrame = clone2.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, -3.0543261909900767, 0)
					}):Play()
					TweenService:Create(
						clone2.Mesh,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Scale = createVector(84.852, 94.222, 84.037) * v
						}
					):Play()
					TweenService:Create(
						clone2.Decal,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Transparency = 1
						}
					):Play()
				end)
				task.wait(0.015)
			end
		end)
		TweenService:Create(
			primaryPart.Distortion,
			TweenInfo.new(0.075, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
			{
				Size = createVector(98, 98, 98) * v
			}
		):Play()
		TweenService:Create(
			primaryPart.Layer,
			TweenInfo.new(0.075, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
			{
				Size = createVector(102, 102, 102) * v
			}
		):Play()
		task.wait(0.0752)
		primaryPart.Distortion.Size = createVector(0, 0, 0)
		primaryPart.Layer.Size = createVector(0, 0, 0)
	end
end