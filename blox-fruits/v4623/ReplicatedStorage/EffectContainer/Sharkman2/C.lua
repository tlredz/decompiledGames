local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Sharkman2").C.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
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

local function RecolorSharkmanTintColor(player, p)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3ConstructorForTintColor(p, player, "SharkmanKarateFruitVFXColor")
	end

	return p
end

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

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function Curve(folder, p, p2, p3, p4)
	local position = folder.Position
	local v = 25

	if p4 == true then
		v /= 2
	else
		p3 = 30
	end

	local v2 = p2 * CFrame.new(math.random(-p3, p3), math.random(-p3, p3), -p).Position
	local magnitude = (position - v2).Magnitude
	folder.CFrame = CFrame.new(position, v2)
	local v3 = (position - v2) / 2
	local position2 = CFrame.new(CFrame.new(position) * (v3 / -1.5)).Position
	local position3 = CFrame.new(CFrame.new(v2) * (v3 / 1.5)).Position
	local v4 = position2 + Vector3.new(math.random(-v, v), math.random(-v, v), math.random(-v, v))
	local v5 = position3 + Vector3.new(math.random(-v, v), math.random(-v, v), math.random(-v, v))
	local v6 = math.random(5, 10)
	local lastTime = tick()
	local v7 = magnitude / v6 / 60

	while tick() - lastTime < v7 do
		local v8 = (tick() - lastTime) / v7
		local v9 = cubicBezier(v8, position, v4, v5, v2)
		folder.CFrame = folder.CFrame:Lerp(CFrame.new(v9, v2), v8)
		RunService.Heartbeat:Wait()
	end
end

local function TrailsCurve(cFrame, _, p, folder, p2)
	local v = p

	for i = 1, 3 do
		local v2 = p / 3
		local v3

		if i == 3 or v < p / 3 then
			v2 = v
			v3 = true
		else
			v3 = false
		end

		Curve(folder, v2, cFrame, p2, v3)
		cFrame *= CFrame.new(0, 0, -v2)
		v -= p / 3

		if v3 == true then
			break
		end
	end

	for _, emitter in pairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.delay(1, function()
		folder:Destroy()
	end)
end

local function PullGroundSpark(cFrame, p, p2, duration, p3, p4)
	for i = 1, 2 do
		local cframe = nil
		local v = nil

		if i == 1 then
			cframe = CFrame.Angles(0, 0.3490658503988659, 0)
			v = -3
		elseif i == 2 then
			cframe = CFrame.Angles(0, -0.3490658503988659, 0)
			v = 3
		end

		local v3 = cFrame * cframe * CFrame.new(v, 0, -p).Position
		local raycastResult = workspace:Raycast(v3 + createVector(0, 15, 0), CFrame.new(v3).UpVector * -50, p3)

		if not raycastResult then
			continue
		end

		local v5 = raycastResult.Position + createVector(0, 5, 0)
		task.spawn(function()
			local clone = assets.Phase1.GroundSparkPull:Clone()
			clone.CFrame = cFrame * cframe
			clone.Orientation = Vector3.new(0, clone.Orientation.Y, clone.Orientation.Z)
			clone.Position = v5 + createVector(0, -6, 0)
			clone.CFrame = clone.CFrame
			Util.SetParentOverrideWithColor(clone, p2, p4, "SharkmanKarateFruitVFXColor")

			for i2, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local tween = TweenService:Create(
				clone,
				TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Position = clone.CFrame * CFrame.new(v, 0, p).Position
				}
			)
			clone.CFrame *= CFrame.Angles(-0.8726646259971648, 0, 0)
			tween:Play()
			task.wait(duration * 0.95)

			for i2, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end
end

local function WaterProjectile(cFrame, folder, p, p2)
	local function WaterSlashes()
		for _ = 1, 7 do
			local clone = assets.Phase1.SlashModel:Clone()
			clone.PrimaryPart.CFrame = cFrame * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
			Util.SetParentOverrideWithColor(clone, folder, p2, "SharkmanKarateFruitVFXColor")
			local folder2 = clone
			task.spawn(function()
				task.spawn(function()
					for i = 100, 200, 10 do
						folder2:ScaleTo(i / 100)
						task.wait()
					end

					for i = 200, 250, 5 do
						folder2:ScaleTo(i / 100)
						task.wait()
					end

					task.wait(0.115)

					for i = 250, 200, -math.random(10, 15) do
						folder2:ScaleTo(i / 100)
						task.wait()
					end
				end)
				task.wait(0.115)
				local v = 0.15 * math.random() + 0.25

				for i, beam in pairs(folder2:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local tween = TweenService:Create(
						beam,
						TweenInfo.new(v, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween:Play()
					local v3 = beam
					task.spawn(function()
						tween.Completed:Wait()
						v3:Destroy()
					end)
				end
			end)
			task.spawn(function()
				local v2 = math.random(40, 70)
				local v3 = 0.15 * math.random() + 0.15

				for i = 1, 10 do
					local tween = TweenService:Create(
						clone.PrimaryPart,
						TweenInfo.new(v3 / 10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, -p / 10) * CFrame.Angles(
								0,
								0,
								(math.rad(-v2))
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end

				local tween = TweenService:Create(
					clone.PrimaryPart,
					TweenInfo.new(v3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, -p / 10) * CFrame.Angles(
							0,
							0,
							(math.rad(-v2 * 2))
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end)
			task.wait(0.025)
		end
	end

	task.spawn(function()
		WaterSlashes()
	end)
	task.spawn(function()
		for _ = 1, 10 do
			task.spawn(function()
				local clone = assets.Phase1.SmallWaterTrailModel:Clone()
				local primaryPart = clone.PrimaryPart
				primaryPart.CFrame = cFrame * CFrame.new(
					math.random(-50, 50) / 10,
					math.random(-50, 50) / 10,
					math.random(-35, 35) / 10
				)
				Util.SetParentOverrideWithColor(clone, folder, p2, "SharkmanKarateFruitVFXColor")
				clone:ScaleTo(math.random(10, 20) / 10)
				local v = 0.5 * math.random() + 0.5

				for _, effect in pairs(primaryPart:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					elseif effect:IsA("Trail") then
						effect.Enabled = true
						effect.Lifetime *= v
					end
				end

				TrailsCurve(cFrame, folder, p, primaryPart, 25)
			end)
		end
	end)
	local clone = assets.Phase1.WaterTrail:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, p2, "SharkmanKarateFruitVFXColor")

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		CFrame = cFrame * CFrame.new(0, 0, -p)
	}):Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

local function WaterPull(cFrame, folder, raycastParams, p, duration, p2)
	local function WaterSlashes()
		for _ = 1, 7 do
			local clone = assets.Phase1.SlashModel:Clone()
			clone.PrimaryPart.CFrame = cFrame * CFrame.new(0, 0, -p) * CFrame.Angles(
				0,
				0,
				(math.rad((math.random(-180, 180))))
			)
			Util.SetParentOverrideWithColor(clone, folder, p2, "SharkmanKarateFruitVFXColor")
			local folder2 = clone
			task.spawn(function()
				task.spawn(function()
					for i = 200, 250, 5 do
						folder2:ScaleTo(i / 100)
						task.wait(0.016666666666666666)
					end

					task.wait(0.07)

					for i = 250, 150, -math.random(5, 10) do
						folder2:ScaleTo(i / 100)
						task.wait(0.016666666666666666)
					end
				end)
				task.wait(0.1)
				local v = 0.15 * math.random() + 0.175

				for i, beam in pairs(folder2:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local tween = TweenService:Create(
						beam,
						TweenInfo.new(v, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween:Play()
					local v3 = beam
					task.spawn(function()
						tween.Completed:Wait()
						v3:Destroy()
					end)
				end
			end)
			task.spawn(function()
				p *= 0.9
				local v2 = math.random(40, 70)
				local v3 = 0.15 * math.random() + 0.15

				for i = 1, 7 do
					local tween = TweenService:Create(
						clone.PrimaryPart,
						TweenInfo.new(v3 / 7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, p / 7) * CFrame.Angles(
								0,
								0,
								(math.rad(-v2))
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end

				local tween = TweenService:Create(
					clone.PrimaryPart,
					TweenInfo.new(v3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, p / 10) * CFrame.Angles(
							0,
							0,
							(math.rad(-v2 * 2))
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end)
			task.wait(0.025)
		end
	end

	task.spawn(function()
		WaterSlashes()
	end)
	task.spawn(function()
		for _ = 1, 10 do
			task.spawn(function()
				local clone = assets.Phase1.SmallWaterTrailModel:Clone()
				local primaryPart = clone.PrimaryPart
				primaryPart.CFrame = cFrame * CFrame.new(math.random(-50, 50) / 10, math.random(-50, 50) / 10, -p)
				primaryPart.CFrame = CFrame.new(primaryPart.Position, cFrame.Position)
				Util.SetParentOverrideWithColor(clone, folder, p2, "SharkmanKarateFruitVFXColor")
				clone:ScaleTo(math.random(10, 20) / 10)
				local v = 0.5 * math.random() + 0.5

				for _, effect in pairs(primaryPart:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					elseif effect:IsA("Trail") then
						effect.Enabled = true
						effect.Lifetime *= v
					end
				end

				TrailsCurve(primaryPart.CFrame, folder, p, primaryPart, 5)
			end)
		end
	end)
	task.spawn(function()
		PullGroundSpark(cFrame, p, folder, duration, raycastParams, p2)
	end)
	local clone = assets.Phase1.PullAura:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, p2, "SharkmanKarateFruitVFXColor")

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = true
			effect:Emit(1)
			local v = effect
			task.spawn(function()
				task.wait(duration)
				v.Enabled = false
			end)
		elseif effect:IsA("Beam") then
			local v = effect
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v:Destroy()
			end)
		elseif effect.Name == "Attach0" then
			TweenService:Create(effect, TweenInfo.new(0.25 * math.random() + 0.25), {
				Position = effect.Position + Vector3.new(
					math.random(-25, 25) * 1.5,
					math.random(-25, 25) * 1.5,
					math.random(-25, 50) * 1.5
				)
			}):Play()
		end
	end
end

local function CameraWater(folder, player)
	local currentCamera = workspace.CurrentCamera
	local clone = assets.Phase2.CameraFocus2:Clone()
	Util.SetParentOverrideWithColor(clone, folder, player, "SharkmanKarateFruitVFXColor")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 0, 0)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local screenColorSFC = assets.Phase2.ScreenColorSFC
	local v = game.Lighting:FindFirstChild("ScreenColorSFC")

	if v then
		v:SetAttribute("UsedTimes", v:GetAttribute("UsedTimes") + 1)
	else
		v = Instance.new("ColorCorrectionEffect")
		v.Name = "ScreenColorSFC"
		v:SetAttribute("UsedTimes", 1)
	end

	v.Parent = game.Lighting
	local usedTimes = v:GetAttribute("UsedTimes")
	local tweenInfo = TweenInfo.new(0.35)
	local v4 = {
		Brightness = screenColorSFC.Brightness,
		Contrast = screenColorSFC.Contrast,
		Saturation = screenColorSFC.Saturation,
		TintColor = 0
	}
	local tintColor = screenColorSFC.TintColor

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		tintColor = Util.WrapColor3ConstructorForTintColor(tintColor, player, "SharkmanKarateFruitVFXColor")
	end

	v4.TintColor = tintColor
	local v5 = TweenService:Create(v, tweenInfo, v4)
	v5:Play()
	task.wait(1)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.spawn(function()
		if v:GetAttribute("UsedTimes") == usedTimes then
			local tweenInfo2 = TweenInfo.new(1.5)
			local player2 = player
			local color = Color3.fromRGB(255, 255, 255)

			if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
				color = Util.WrapColor3ConstructorForTintColor(color, player2, "SharkmanKarateFruitVFXColor")
			end

			v5 = TweenService:Create(v, tweenInfo2, {
				TintColor = color,
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			})
			v5:Play()
			v5.Completed:Wait()

			if v:GetAttribute("UsedTimes") == usedTimes then
				v:Destroy()
			end
		end
	end)
	task.wait(0.5)
	renderSteppedConnection:Disconnect()
	clone:Destroy()
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function SkillUse(player)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local sharkmanColorOwner = GetSharkmanColorOwner(player, character)

	if player.Holding then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		local _ = humanoidRootPart.CFrame
		local clone = assets.Phase0.HandAura:Clone()
		clone.CFrame = humanoidRootPart.Parent.RightHand.CFrame
		Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		clone.WeldConstraint.Part1 = humanoidRootPart.Parent.RightHand
		clone.Anchored = false
		clone.Massless = true
		local clone2 = assets.Phase0.HandAura:Clone()
		clone2.CFrame = humanoidRootPart.Parent.LeftHand.CFrame
		Util.SetParentOverrideWithColor(clone2, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		clone2.WeldConstraint.Part1 = humanoidRootPart.Parent.LeftHand
		clone2.Anchored = false
		clone2.Massless = true
		local v2 = Util.Sound:Play("SharkmanK_C_Hold_01", humanoidRootPart)

		for _, v3 in pairs({ clone2:GetDescendants(), clone:GetDescendants() }) do
			for _, emitter in pairs(v3) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end

		repeat
			task.wait()
		until not (player.Holding and player.Holding.Value and player.Holding:IsDescendantOf(workspace))

		if v2 then
			Util.Sound:FadeOut(v2, 0.3)
		end

		task.delay(0.25, function()
			for _, v3 in pairs({ clone2:GetDescendants(), clone:GetDescendants() }) do
				for _, emitter in pairs(v3) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			task.delay(2, function()
				clone:Destroy()
				clone2:Destroy()
			end)
		end)
		Util.Debris:AddItem(folder, 7)
	else
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 10)
		local cFrame = player.CFrame

		if player.Stage == 1 then
			local clone = assets.Phase1.StartImpact:Clone()
			clone.CFrame = cFrame * CFrame.new(0, 0, -5)
			Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
			Util.Sound:Play("SharkmanK_C_Release_01", cFrame.Position)

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

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			WaterProjectile(cFrame, folder, 100, sharkmanColorOwner)
			task.wait(0.3)
			WaterPull(cFrame, folder, raycastParams, 100, 0.25, sharkmanColorOwner)
			task.wait(0.525)
		elseif player.Stage == 2 then
			local clone = assets.Phase2.HitImpactModel:Clone()
			local primaryPart = clone.PrimaryPart
			primaryPart.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
			local clone2 = assets.Phase2.HitImpact2:Clone()
			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
			Util.Sound:Play("SharkmanK_C_TargetHitPunch_05", cFrame.Position)
			local emittersByEmitter = {}

			for _, v2 in pairs({ primaryPart:GetDescendants(), clone2:GetDescendants() }) do
				for _, emitter in pairs(v2) do
					if emitter:IsA("ParticleEmitter") then
						emittersByEmitter[emitter] = emitter
					end
				end
			end

			if player.Player == game.Players.LocalPlayer then
				task.spawn(function()
					local currentCamera = workspace.CurrentCamera
					local clone3 = assets.Phase2.CameraFocus:Clone()
					Util.SetParentOverrideWithColor(clone3, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
					local renderSteppedConnection = RunService.RenderStepped:Connect(function()
						clone3.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
					end)

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					task.wait(1)

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.wait(0.5)
					renderSteppedConnection:Disconnect()
					clone3:Destroy()
				end)
			end

			local flag = false

			for _, victimRoot in pairs(player.VictimRoots) do
				if not (victimRoot and victimRoot.Parent == game.Players.LocalPlayer.Character) then
					continue
				end

				flag = true
				break
			end

			if flag then
				task.spawn(function()
					CameraWater(folder, sharkmanColorOwner)
				end)
			end

			local v3 = tick() + (1 - (workspace:GetServerTimeNow() - player.Timestamp))

			while true do
				clone:ScaleTo(math.random(5, 13) / 10)
				primaryPart.CFrame = humanoidRootPart.CFrame * CFrame.new(
					math.random(-5, 5) * 1.5,
					math.random(-3, 3),
					-math.random(3, 5)
				)
				clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(
					math.random(-5, 5) * 1.5,
					math.random(-3, 3),
					-math.random(3, 5)
				)

				for _, v4 in pairs(emittersByEmitter) do
					v4:Emit(v4:GetAttribute("EmitCount"))
				end

				task.wait(0.075)

				if not (v3 - tick() <= 0) then
					continue
				end

				local cFrame2 = humanoidRootPart.CFrame
				local clone3 = assets.Phase3.BeforeExplosion:Clone()
				clone3.CFrame = cFrame2 * CFrame.new(0, 0, -7)
				Util.SetParentOverrideWithColor(clone3, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

				for _, emitter in pairs(clone3:GetDescendants()) do
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

				DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
				task.wait(0.175)
				local clone4 = assets.Phase3.Explosion:Clone()
				clone4.CFrame = cFrame2 * CFrame.new(0, 0, -15)
				Util.SetParentOverrideWithColor(clone4, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

				for _, emitter in pairs(clone4:GetDescendants()) do
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

				DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown
				local clone5 = assets.Phase3.WaterSplash:Clone()
				clone5.CFrame = cFrame2 * CFrame.new(0, 10, -50)
				Util.SetParentOverrideWithColor(clone5, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

				for _, emitter in pairs(clone5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Enabled = true
					emitter:Emit(1)
				end

				local raycastResult = workspace:Raycast(
					clone5.Position + createVector(0, 15, 0) + createVector(0, 1, 0),
					createVector(-0, -50, -0),
					raycastParams
				)

				if raycastResult then
					clone5.WaterSplash3.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
				else
					clone5.WaterSplash3:Destroy()
				end

				task.wait(0.5)

				for _, emitter in pairs(clone5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if emitter.Parent.Name == "WaterSplash3" then
						local v4 = emitter
						task.delay(0.25, function()
							v4.Enabled = false
						end)
					else
						emitter.Enabled = false
					end
				end

				return
			end
		elseif player.Stage == 3 then
			local clone = assets.Extra.BurnModel:Clone()
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.PrimaryPart.Anchored = false
			clone.PrimaryPart.Weld.Part1 = humanoidRootPart
			Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					local v2 = effect
					task.spawn(function()
						v2.Enabled = true
						v2.LockedToPart = true
						v2:Emit(1)
						task.wait(5)
						v2.Enabled = false
					end)
				elseif effect:IsA("Beam") then
					local v2 = effect
					task.spawn(function()
						v2.Enabled = true
						local tween = TweenService:Create(v2, TweenInfo.new(0.15), {
							Width0 = v2.Width0,
							Width1 = v2.Width1
						})
						v2.Width0 = 0
						v2.Width1 = 0
						tween:Play()
						task.wait(5)
						TweenService:Create(v2, TweenInfo.new(0.25), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end
			end
		end
	end
end

return SkillUse