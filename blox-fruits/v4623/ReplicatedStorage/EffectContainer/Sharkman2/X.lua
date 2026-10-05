local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Sharkman2").X.Assets
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

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

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

	local screenColorSFX = assets.Phase2.ScreenColorSFX
	local v = game.Lighting:FindFirstChild("ScreenColorSFX")

	if v then
		v:SetAttribute("UsedTimes", v:GetAttribute("UsedTimes") + 1)
	else
		v = Instance.new("ColorCorrectionEffect")
		v.Name = "ScreenColorSFX"
		v:SetAttribute("UsedTimes", 1)
	end

	v.Parent = game.Lighting
	local usedTimes = v:GetAttribute("UsedTimes")
	local tweenInfo = TweenInfo.new(0.35)
	local v4 = {
		Brightness = screenColorSFX.Brightness,
		Contrast = screenColorSFX.Contrast,
		Saturation = screenColorSFX.Saturation,
		TintColor = 0
	}
	local tintColor = screenColorSFX.TintColor

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		tintColor = Util.WrapColor3ConstructorForTintColor(tintColor, player, "SharkmanKarateFruitVFXColor")
	end

	v4.TintColor = tintColor
	local v5 = TweenService:Create(v, tweenInfo, v4)
	v5:Play()
	local clone2 = assets.Phase2.DepthOfField:Clone()
	clone2.Parent = game.Lighting
	task.spawn(function()
		for _ = 1, 5 do
			local tween = TweenService:Create(
				currentCamera,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					FieldOfView = 70 + math.random(-5, 5) / 5
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end

		TweenService:Create(currentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			FieldOfView = 70
		}):Play()
	end)
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
	clone2:Destroy()
	task.wait(0.5)
	renderSteppedConnection:Disconnect()
	clone:Destroy()
end

local raycastParams2 = RaycastParams.new()
raycastParams2.IgnoreWater = false
raycastParams2.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

local function SkillUse(player)
	local WAIT_INTERVAL = 0.5
	local DELAY_DURATION = 0.25
	local character = player.Character
	local _ = player.Humanoid
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local sharkmanColorOwner = GetSharkmanColorOwner(player, character)
	local heldProxy = player.HeldProxy
	local cFrame = humanoidRootPart.CFrame
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 7)

	if player.Stage == 1 then
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 0, -5)
		Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		Util.Sound:Play("SharkmanK_X_Release_05", cFrame.Position)

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
		local clone2 = assets.Phase1.Projectile:Clone()
		clone2.CFrame = cFrame * CFrame.new(0, 0, -5)
		clone2.SharkModel:ScaleTo(1)
		Util.SetParentOverrideWithColor(clone2, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		clone2.SharkModel.AnimationController:LoadAnimation(clone2.SharkModel.SharkSwim):Play(0, nil, 1.5)
		local v2 = Util.Sound:Play("SharkmanK_X_FlightLoop_01", clone2)
		TweenService:Create(v2, TweenInfo.new(1.5), {
			Volume = 1
		}):Play()
		local v3 = false
		local lastTime = tick()
		task.spawn(function()
			clone2.Aura.WeldConstraint.Enabled = false

			for _, emitter in pairs(clone2.Aura:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			while tick() - lastTime < 0.3 and not v3 and clone2.Parent do
				local v4 = ((tick() - lastTime) / 0.3) ^ 0.75
				clone2.SharkModel:ScaleTo(1 + v4 * 4)
				task.wait(0.016666666666666666)
			end

			if v3 == false or clone2.Parent then
				clone2.SharkModel:ScaleTo(5)
				clone2.Aura.WeldConstraint.Enabled = true

				for _, emitter in pairs(clone2.Aura:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end
		end)
		local clone3 = assets.Phase1.GroundBurn:Clone()
		clone3.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone3, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local emitters = {}
		local v4 = false

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				table.insert(emitters, emitter)
			end
		end

		local clone4 = assets.Phase0.HandAura:Clone()
		clone4.CFrame = humanoidRootPart.Parent.RightHand.CFrame
		Util.SetParentOverrideWithColor(clone4, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		clone4.WeldConstraint.Part1 = humanoidRootPart.Parent.RightHand
		clone4.Anchored = false
		clone4.Massless = true
		local clone5 = assets.Phase0.HandAura:Clone()
		clone5.CFrame = humanoidRootPart.Parent.LeftHand.CFrame
		Util.SetParentOverrideWithColor(clone5, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		clone5.WeldConstraint.Part1 = humanoidRootPart.Parent.LeftHand
		clone5.Anchored = false
		clone5.Massless = true

		for _, v5 in pairs({ clone5:GetDescendants(), clone4:GetDescendants() }) do
			for _, emitter in pairs(v5) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end

		local spring = Util.Spring.new(0.75, 6, clone2.Position)
		local v5 = tick() + player.Duration
		local v6 = true
		local v7 = 0.016666666666666666

		while true do
			task.spawn(function()
				local raycastResult = workspace:Raycast(
					clone2.Position + createVector(0, 1, 0),
					createVector(-0, -25, -0),
					raycastParams2
				)

				if raycastResult then
					clone3.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01

					if v4 == false then
						v4 = true

						for _, v8 in pairs(emitters) do
							v8.Enabled = true
							v8:Emit(1)
						end
					end
				elseif v4 == true then
					v4 = false

					for _, v8 in pairs(emitters) do
						v8.Enabled = false
					end
				end
			end)

			if v6 and not (player.Holding and player.Holding.Value and player.Holding:IsDescendantOf(workspace)) then
				v6 = false

				for _, v8 in pairs({ clone5:GetDescendants(), clone4:GetDescendants() }) do
					for _, emitter in pairs(v8) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end
			end

			spring:SetGoal(heldProxy:GetAttribute("ServerPosition"))
			spring:Update(v7)
			local position = spring:GetPosition()
			clone2.CFrame = CFrame.new(position) * clone2.CFrame:Lerp(CFrame.lookAt(clone2.Position, position), v7 * 10).Rotation
			v7 = RunService.Heartbeat:Wait()

			if not (v5 - tick() <= 0 or heldProxy.Value == false or not heldProxy:IsDescendantOf(workspace)) then
				continue
			end

			if v2 then
				Util.Sound:FadeOut(v2, 0.2)
			end

			v3 = true
			task.delay(DELAY_DURATION, function()
				for _, v8 in pairs({ clone5:GetDescendants(), clone4:GetDescendants() }) do
					for _, emitter in pairs(v8) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				task.delay(2, function()
					clone4:Destroy()
					clone5:Destroy()
				end)
			end)

			for _, descendant in pairs(clone2:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
					descendant.Enabled = false
				elseif descendant:IsA("MeshPart") then
					descendant.Transparency = 1
				else
					descendant:IsA("Trail")
				end
			end

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local cFrame2 = clone2.CFrame
			local clone6 = assets.Phase2.HitImpact:Clone()
			clone6.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone6, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
			Util.Sound:Play("SharkmanK_X_Despawn_06", cFrame2.Position)

			for _, emitter in pairs(clone6:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v8 = emitter
				task.spawn(function()
					if v8:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v8:GetAttribute("EmitDelay"))
					end

					v8:Emit(v8:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
			task.wait(WAIT_INTERVAL)
			clone2:Destroy()
			return
		end
	elseif player.Stage == 2 then
		local cFrame2 = player.CFrame
		local victimRoot = player.VictimRoot

		if victimRoot then
			local clone = assets.Phase2.HitImpact:Clone()
			clone.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

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
			local clone2 = assets.Phase2.WaterBubble:Clone()
			clone2.CFrame = victimRoot.CFrame
			Util.SetParentOverrideWithColor(clone2, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
			clone2.Anchored = false
			clone2.Massless = true
			clone2.Weld.Part1 = victimRoot
			Util.Sound:Play("SharkmanK_X_BubblePrison_02", victimRoot)
			local ray = Ray.new(CFrame.new(clone2.Position).Position, CFrame.new(clone2.Position).UpVector * -40)
			local part, v2 = workspace:FindPartOnRayWithIgnoreList(ray, { folder })

			if part then
				clone2.WaterSplashGround.WeldConstraint.Enabled = false
				clone2.WaterSplashGround.Anchored = true
				clone2.WaterSplashGround.CFrame = CFrame.new(v2)
			else
				clone2.WaterSplashGround:Destroy()
			end

			clone2.WaterSplash2.WeldConstraint.Enabled = false
			clone2.WaterSplash2.Anchored = true

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emitter:Emit(1)
			end

			task.spawn(function()
				local clone3 = assets.Phase2.SharkRingBeam:Clone()
				clone3.CFrame = victimRoot.CFrame
				Util.SetParentOverrideWithColor(clone3, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
				local v3 = tick() + 1
				local v4 = 0.016666666666666666

				repeat
					clone3.CFrame = CFrame.new(victimRoot.Position, victimRoot.Position + clone3.CFrame.LookVector) * CFrame.Angles(
						0,
						math.rad(v4 * 360),
						0
					)
					clone2.WaterSplash2.CFrame = CFrame.new(clone2.Position)
					v4 = RunService.Heartbeat:Wait()
				until v3 - tick() <= 0

				clone3:Destroy()
			end)

			if victimRoot and victimRoot.Parent == game.Players.LocalPlayer.Character then
				task.spawn(function()
					CameraWater(folder, sharkmanColorOwner)
				end)
			end

			task.wait(1)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.delay(0.1, function()
				clone2:Destroy()
			end)
		end

		if victimRoot then
			cFrame2 = CFrame.new(victimRoot.Position)
		end

		local clone = assets.Phase2.Explosion:Clone()
		clone.CFrame = CFrame.new(cFrame2.Position)
		Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		Util.Sound:Play("SharkmanK_X_Explode_01", clone.Position)

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
		local clone2 = assets.Phase2.WaterSplash:Clone()
		clone2.CFrame = cFrame2 * CFrame.new(0, 10, 0)
		Util.SetParentOverrideWithColor(clone2, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter:Emit(1)
		end

		local raycastResult = workspace:Raycast(
			cFrame2.Position + createVector(0, 5, 0),
			createVector(-0, -35, -0),
			raycastParams2
		)

		if raycastResult then
			clone2.WaterSplash3.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		else
			clone2.WaterSplash3:Destroy()
		end

		task.wait(WAIT_INTERVAL)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter.Parent.Name == "WaterSplash3" then
				local v2 = emitter
				task.delay(DELAY_DURATION, function()
					v2.Enabled = false
				end)
			else
				emitter.Enabled = false
			end
		end
	elseif player.Stage == 3 then
		local cFrame2 = player.CFrame
		local victimRoot = player.VictimRoot
		local grabProxy = player.GrabProxy
		local v2 = false
		local maxHold = player.MaxHold

		if victimRoot then
			local clone = assets.Phase2.HitImpact:Clone()
			clone.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					if v3:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v3:GetAttribute("EmitDelay"))
					end

					v3:Emit(v3:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			local clone2 = assets.Phase2.WaterBubble:Clone()
			clone2.CFrame = victimRoot.CFrame
			Util.SetParentOverrideWithColor(clone2, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
			clone2.Anchored = false
			clone2.Massless = true
			clone2.Weld.Part1 = victimRoot
			Util.Sound:Play("SharkmanK_X_BubblePrison_02", victimRoot)
			local ray = Ray.new(CFrame.new(clone2.Position).Position, CFrame.new(clone2.Position).UpVector * -40)
			local part, v3 = workspace:FindPartOnRayWithIgnoreList(ray, { folder })

			if part then
				clone2.WaterSplashGround.WeldConstraint.Enabled = false
				clone2.WaterSplashGround.Anchored = true
				clone2.WaterSplashGround.CFrame = CFrame.new(v3)
			else
				clone2.WaterSplashGround:Destroy()
			end

			clone2.WaterSplash2.WeldConstraint.Enabled = false
			clone2.WaterSplash2.Anchored = true

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emitter:Emit(1)
			end

			task.spawn(function()
				local clone3 = assets.Phase2.SharkRingBeam:Clone()
				clone3.CFrame = victimRoot.CFrame
				Util.SetParentOverrideWithColor(clone3, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
				local v4 = tick() + maxHold
				local v5 = 0.016666666666666666

				repeat
					clone3.CFrame = CFrame.new(victimRoot.Position, victimRoot.Position + clone3.CFrame.LookVector) * CFrame.Angles(
						0,
						math.rad(v5 * 360),
						0
					)
					clone2.WaterSplash2.CFrame = CFrame.new(clone2.Position)
					v5 = RunService.Heartbeat:Wait()
				until v4 - tick() <= 0 or v2

				clone3:Destroy()
			end)

			if victimRoot and victimRoot.Parent == game.Players.LocalPlayer.Character then
				task.spawn(function()
					CameraWater(folder, sharkmanColorOwner)
				end)
			end

			local _ = player.MousePos
			local _ = clone2.CFrame
			tick()
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(_)
				if v2 or not grabProxy:IsDescendantOf(workspace) then
					heartbeatConnection:Disconnect()
					return
				end

				local position = grabProxy.Value.Position
				local serverCFrame = grabProxy:GetAttribute("ServerCFrame")

				if serverCFrame then
					local position2 = serverCFrame.Position
					local lerped = position:Lerp(position2, 0.5)
					local v4 = position2 - lerped
					local unit = v4.Unit

					if unit == unit then
						if v4.Magnitude < 0.1 then
							unit = grabProxy.Value.LookVector
						end

						grabProxy.Value = CFrame.new(lerped, lerped + unit)
					end
				end
			end)

			repeat
				task.wait()
			until not grabProxy:IsDescendantOf(workspace)

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end

			v2 = true

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.delay(0.1, function()
				clone2:Destroy()
			end)
		end

		if victimRoot then
			cFrame2 = CFrame.new(victimRoot.Position)
		end

		local clone = assets.Phase2.Explosion:Clone()
		clone.CFrame = CFrame.new(cFrame2.Position)
		Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		Util.Sound:Play("SharkmanK_X_Explode_01", clone.Position)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local clone2 = assets.Phase2.WaterSplash:Clone()
		clone2.CFrame = cFrame2 * CFrame.new(0, 10, 0)
		Util.SetParentOverrideWithColor(clone2, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter:Emit(1)
		end

		local raycastResult = workspace:Raycast(
			cFrame2.Position + createVector(0, 5, 0),
			createVector(-0, -35, -0),
			raycastParams2
		)

		if raycastResult then
			clone2.WaterSplash3.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		else
			clone2.WaterSplash3:Destroy()
		end

		task.wait(WAIT_INTERVAL)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter.Parent.Name == "WaterSplash3" then
				local v3 = emitter
				task.delay(DELAY_DURATION, function()
					v3.Enabled = false
				end)
			else
				emitter.Enabled = false
			end
		end
	end
end

return SkillUse