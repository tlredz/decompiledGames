local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local V = FX:WaitForChild("BombRework").V
local _WorldOrigin = workspace._WorldOrigin
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false
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

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil then
			if not effect:IsA("ParticleEmitter") then
				continue
			end

			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end

		if not effect:IsA("ParticleEmitter") or effect.Lifetime.Max <= max then
			continue
		end

		max = effect.Lifetime.Max
	end

	return max
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

local random = Random.new()
local v = {}
return function(player)
	local origin = player.Origin
	local state = player.State
	local player2 = player.Player

	if (currentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local bombMax = player.BombMax
	local bombMin = player.BombMin
	local character = player.Character

	if state == "End" and v[character] ~= "Start" or typeof(state) == "number" and v[character] ~= "Start" then
		return
	end

	v[character] = state

	if typeof(state) == "number" then
		return
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "BombFruitVFXColor")
	Util.Debris:AddItem(folder, 10)
	local head = character.Head
	local v2 = {}

	for _, accessory in ipairs(character:GetChildren()) do
		if not accessory:IsA("Accessory") then
			continue
		end

		local handle = accessory:FindFirstChild("Handle")

		if not handle then
			continue
		end

		if handle:FindFirstChild("AccessoryRigidConstraint", true) then
			for _, descendant in ipairs(accessory:GetDescendants()) do
				if descendant:IsA("BasePart") then
					v2[descendant] = descendant.LocalTransparencyModifier
					descendant.LocalTransparencyModifier = 1
				elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
					v2[descendant] = descendant.Transparency
					descendant.Transparency = 1
				end
			end
		else
			local weld = handle:FindFirstChildWhichIsA("Weld") or handle:FindFirstChildWhichIsA("Motor6D")

			if weld and (weld.Part0 == head or weld.Part1 == head) then
				for _, descendant in ipairs(accessory:GetDescendants()) do
					if descendant:IsA("BasePart") then
						v2[descendant] = descendant.LocalTransparencyModifier
						descendant.LocalTransparencyModifier = 1
					elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
						v2[descendant] = descendant.Transparency
						descendant.Transparency = 1
					end
				end
			end
		end
	end

	local face = head:FindFirstChild("face")

	if face then
		face.Transparency = 1
	end

	head.Transparency = 1
	local _ = head.CFrame
	local absol = V.Absol
	local root = player.Root
	local humanoid = player.Humanoid
	local lastTime = os.clock()
	local lastTime2 = os.clock()
	local lastTime3 = os.clock()
	local clone = V.Phase1.BombModel:Clone()
	clone:PivotTo(head.CFrame)
	Util.SetParentOverrideWithColor(clone, folder, player2, "BombFruitVFXColor")
	local primaryPart = clone.PrimaryPart
	local v3 = (head.Position - character.UpperTorso.Position).Magnitude / 2.25
	local numberValue = Instance.new("NumberValue", folder)
	numberValue.Value = 1
	local clone2 = V.Phase1.HeadAura:Clone()
	clone2.CFrame = primaryPart.CFrame
	Util.Sound:Play("BF_NewFruit_V_Activate_Hold_01", root)
	local v4 = Util.Sound:Play("BF_NewFruit_V_Charge_Up_01", root.Position)
	TweenService:Create(v4, TweenInfo.new(0.5), {
		Volume = 1
	}):Play()
	Util.SetParentOverrideWithColor(clone2, clone, player2, "BombFruitVFXColor")
	local holding = player.Holding
	task.spawn(function()
		repeat
			task.wait()
		until not (holding and holding:IsDescendantOf(workspace) and holding.Value)

		pcall(function()
			if v4 then
				Util.Sound:FadeOut(v4, 0.2)
				v4 = nil
			end
		end)
	end)
	local _ = tick() + 0.5
	local _ = workspace.CurrentCamera
	local v5

	repeat
		local _ = root.CFrame
		local v6 = (os.clock() - lastTime) / 3
		v5 = bombMin + (bombMax - bombMin) * v6
		clone:ScaleTo(v5)
		local v7 = v3 * clone:GetScale()
		clone:PivotTo(head.CFrame * CFrame.new(0, v7, 0) * CFrame.new(0, 0.7 * clone:GetScale(), 0))
		local _ = clone:GetScale() / 6.5
		task.spawn(function()
			humanoid.CameraOffset += Vector3.new(0, v5 * 0.001, 0)

			if os.clock() - lastTime2 >= 0.06 then
				lastTime2 = os.clock()
				local clone3 = absol.BombParts:GetChildren()[random:NextInteger(1, #absol.BombParts:GetChildren())]:Clone()
				clone3.Size += createVector(1, 1, 1) * v5
				clone3.Orientation = Vector3.new(
					random:NextNumber(0, 360),
					random:NextNumber(0, 360),
					random:NextNumber(0, 360)
				)
				local v8 = (random:NextInteger(0, 1) * 2 - 1) * (random:NextNumber(5, 12) * v5)
				local lookVector = (primaryPart.CFrame * CFrame.Angles(
					random:NextInteger(0, 6.283185307179586),
					random:NextNumber(0, 6.283185307179586),
					random:NextNumber(0, 6.283185307179586)
				)).LookVector
				local raycastResult = workspace:Raycast(primaryPart.Position, lookVector * v8, raycastParams)
				local position = raycastResult and raycastResult.Position or primaryPart.Position + lookVector * v8
				local _ = primaryPart.Position
				local clone4 = absol.BombPartAppearModel:Clone()
				clone4:ScaleTo(v5)
				local bombPartAppear = clone4.BombPartAppear
				bombPartAppear.Position = position
				Util.SetParentOverrideWithColor(clone4, folder, player2, "BombFruitVFXColor")
				task.delay(ParticleState(bombPartAppear), clone4.Destroy, bombPartAppear)
				clone3.Position = position
				Util.SetParentOverrideWithColor(clone3, folder, player2, "BombFruitVFXColor")
				local number = random:NextNumber(0.1, 0.2)

				for i = 0, 1, RunService.Heartbeat:Wait() / number do
					local position2 = primaryPart.Position
					local raycastResult2 = workspace:Raycast(
						clone3.Position,
						position + (position2 - position) * i - clone3.Position,
						raycastParams
					)
					clone3.Position = position + (position2 - position) * i

					if raycastResult2 then
						local clone5 = absol.SurfaceHit:Clone()
						clone5.CFrame = CFrame.lookAt(
							raycastResult2.Position,
							raycastResult2.Position + raycastResult2.Normal
						) * CFrame.Angles(-1.5707963267948966, 0, 0)
						Util.SetParentOverrideWithColor(clone5, folder, player2, "BombFruitVFXColor")
						task.delay(ParticleState(clone5), clone5.Destroy, clone5)

						for _ = 1, random:NextInteger(2, 3) do
							local clone6 = absol.SparkTrail:Clone()
							clone6.CFrame = clone5.CFrame
							Util.SetParentOverrideWithColor(clone6, folder, player2, "BombFruitVFXColor")
							clone6:ApplyAngularImpulse((clone5.CFrame.LookVector + Vector3.new(
								0,
								random:NextNumber(0.5, 1.5)
							)) * random:NextNumber(100, 500))
							task.delay(random:NextNumber(0.1, 0.3), function()
								clone6.Trail.Enabled = false
								task.wait(clone6.Trail.Lifetime)
								clone6:Destroy()
							end)
						end
					end

					RunService.Heartbeat:Wait()
				end

				clone3:Destroy()
			end

			if os.clock() - lastTime3 >= 0.03 then
				lastTime3 = os.clock()
				local clone3 = absol.Trail:Clone()
				local number = random:NextNumber(0, 360)
				local number2 = random:NextNumber(360, 720)
				local v8 = random:NextNumber(5, 12) * v5
				local v9 = v8
				local number3 = random:NextNumber(0, 360)
				local number4 = random:NextNumber(360, 720)
				clone3.Trail.Lifetime = random:NextNumber(0.1, 0.2)
				local position = primaryPart.Position
				local v10 = math.sin((math.rad(number))) * v8
				local v11 = math.sin((math.rad(number3))) * v8
				clone3.Position = position + Vector3.new(v10, v11, math.cos((math.rad(number))) * v8)
				Util.SetParentOverrideWithColor(clone3, folder, player2, "BombFruitVFXColor")
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					number += number2 * dt
					number3 += number4 * dt
					v8 -= v9 * dt

					if v8 < 0 then
						heartbeatConnection:Disconnect()
						task.wait(clone3.Trail.Lifetime)
						clone3:Destroy()
					end

					clone3.Position = primaryPart.Position + Vector3.new(
						math.sin((math.rad(number))) * v8,
						math.sin((math.rad(number3))) * v8,
						math.cos((math.rad(number))) * v8
					)
				end)
			end
		end)
		RunService.Heartbeat:Wait()
	until character == nil or character.Parent == nil or typeof(v[character]) == "number" or not (holding and holding:IsDescendantOf(workspace) and holding.Value)

	pcall(function()
		if v4 then
			Util.Sound:FadeOut(v4, 0.2)
			v4 = nil
		end
	end)

	if not v[character] then
		return
	end

	v[character] = nil
	local _ = clone:GetScale() / 6.5
	local clone3 = absol.WarningModel:Clone()
	local warning = clone3.Warning
	clone3:ScaleTo(v5)
	warning.Position = primaryPart.Position + Vector3.new(0, v5 * 4, 0)
	Util.SetParentOverrideWithColor(clone3, folder, player2, "BombFruitVFXColor")
	local clone4 = V.Phase2.BombModel:Clone()
	clone4:PivotTo(primaryPart.CFrame)
	clone4:ScaleTo(clone:GetScale() * 0.9)
	Util.SetParentOverrideWithColor(clone4, folder, player2, "BombFruitVFXColor")
	Util.Sound:Play("BF_NewFruit_V_Large_Explosion_02", primaryPart.Position)
	task.spawn(function()
		local highlight = clone4.PrimaryPart.Highlight
		clone.PrimaryPart.Transparency = 1
		local face2 = clone.PrimaryPart:FindFirstChild("face")

		if face2 then
			face2.Transparency = 1
		end

		local tween = TweenService:Create(
			clone4.PrimaryPart,
			TweenInfo.new(0.125, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = clone4.PrimaryPart.Size
			}
		)
		clone4.PrimaryPart.Size = clone4.PrimaryPart.Size * 0.5
		tween:Play()
		TweenService:Create(highlight, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
			FillTransparency = 1
		}):Play()

		local function blink(p)
			local tweenInfo = TweenInfo.new(p / 2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			local tween2 = TweenService:Create(clone4.PrimaryPart, tweenInfo, {
				Transparency = 1
			})
			local tween3 = TweenService:Create(clone4.PrimaryPart, tweenInfo, {
				Transparency = 0
			})
			tween2:Play()
			tween2.Completed:Wait()
			tween3:Play()
			tween3.Completed:Wait()
		end

		task.wait(0.125)
		blink(0.1)
		blink(0.05)
	end)
	task.wait(0.3)
	clone4:Destroy()
	local clone5 = absol.ExplosionModel:Clone()
	local explosion = clone5.Explosion
	clone5:ScaleTo(v5)
	explosion.Position = primaryPart.Position
	Util.SetParentOverrideWithColor(explosion, folder, player2, "BombFruitVFXColor")

	if (workspace.CurrentCamera.CFrame.p - explosion.CFrame.Position).Magnitude < 220 then
		Util.CameraShaker:ShakeOnce(12, 8, 0.1, 0.4)
	end

	task.delay(ParticleState(explosion), clone5.Destroy, clone5)
	local raycastResult = workspace:Raycast(primaryPart.Position, Vector3.new(0, v5 * -10, 0), raycastParams)

	if raycastResult then
		local clone6 = absol.FloorScorchModel:Clone()
		local floorScorch = clone6.FloorScorch
		clone6:ScaleTo(v5)
		floorScorch.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		Util.SetParentOverrideWithColor(clone6, folder, player2, "BombFruitVFXColor")
		task.delay(ParticleState(floorScorch), floorScorch.Destroy, floorScorch)

		for _ = 1, random:NextNumber(7, 12) do
			local clone7 = absol.CloudTrail:Clone()
			clone7.Position = raycastResult.Position
			clone7.Color = raycastResult.Instance.Color
			clone7.Size = createVector(1, 1, 1) * random:NextNumber(1, 3)
			clone7.Orientation = Vector3.new(
				random:NextNumber(0, 360),
				random:NextNumber(0, 360),
				random:NextNumber(0, 360)
			)
			Util.SetParentOverrideWithColor(clone7, folder, player2, "BombFruitVFXColor")
			Util.Debris:AddItem(clone7, 5)
			clone7.Anchored = false
			clone7.CanCollide = false
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(70000000, 70000000, 70000000)
			bodyVelocity.Velocity = Vector3.new(
				random:NextNumber(-0.2, 0.2),
				random:NextNumber(0.1, 0.4),
				random:NextNumber(-0.2, 0.2)
			).Unit * random:NextNumber(50, 300) * (v5 - 1) / 7
			Util.SetParentOverrideWithColor(bodyVelocity, clone7, player2, "BombFruitVFXColor")
			task.delay(0.3, function()
				bodyVelocity:Destroy()
				task.delay(0.25, function()
					clone7.CanCollide = true
				end)
				task.wait(random:NextNumber(0.9, 1.85))
				ParticleState(clone7, true)
				clone7.Material = Enum.Material.Neon
				TweenService:Create(clone7, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Color = Util.WrapColor3Constructor(Color3.new(1, 0.372549, 0.160784), player2, "BombFruitVFXColor")
				}):Play()
				clone7.Smoke.Enabled = false
				clone7.Smoke.Enabled = false
				local number = random:NextNumber(0.1, 0.3)
				TweenService:Create(clone7, TweenInfo.new(number, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				task.wait(number)
				task.wait((ParticleState(clone7, false)))
				clone7:Destroy()
			end)
		end
	end

	humanoid.CameraOffset = createVector(0, 0, 0)
	task.spawn(function()
		if raycastResult then
			for _ = 1, 10 do
				local clone6 = V.Phase2.Trail:Clone()
				clone6.Position = raycastResult.Position
				clone6.Color = raycastResult.Instance.Color
				clone6.Size = createVector(1, 1, 1) * random:NextNumber(1, 3)
				clone6.Orientation = Vector3.new(
					random:NextNumber(0, 360),
					random:NextNumber(0, 360),
					random:NextNumber(0, 360)
				)
				Util.SetParentOverrideWithColor(clone6, folder, player2, "BombFruitVFXColor")
				Util.Debris:AddItem(clone6, 5)
				clone6.Anchored = false
				clone6.CanCollide = false
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(70000000, 70000000, 70000000)
				bodyVelocity.Velocity = Vector3.new(
					random:NextNumber(-0.2, 0.2),
					random:NextNumber(0.1, 0.4),
					random:NextNumber(-0.2, 0.2)
				).Unit * random:NextNumber(50, 300) * (v5 - 1) / 7
				Util.SetParentOverrideWithColor(bodyVelocity, clone6, player2, "BombFruitVFXColor")
				task.delay(0.15, function()
					bodyVelocity:Destroy()
					task.wait(random:NextNumber(0.9, 1.85) / 2)
					ParticleState(clone6, true)
					clone6.Material = Enum.Material.Neon
					TweenService:Create(clone6, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
						Color = Util.WrapColor3Constructor(
							Color3.new(1, 0.372549, 0.160784),
							player2,
							"BombFruitVFXColor"
						)
					}):Play()
					local v8 = random:NextNumber(0.1, 0.3) / 2
					task.wait(v8)
					task.wait((ParticleState(clone6, false)))
					clone6:Destroy()
				end)
			end
		end
	end)
	local player3 = player.Player
	local Players = game:GetService("Players")

	if player3 == Players.LocalPlayer then
		task.spawn(function()
			local clone6 = absol.ColorCorrection:Clone()
			Util.SetParentOverrideWithColor(clone6, game.Lighting, player2, "BombFruitVFXColor")
			TweenService:Create(clone6, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Brightness = 0,
				TintColor = Util.WrapColor3ConstructorForTintColor(Color3.new(1, 1, 1), player2, "BombFruitVFXColor")
			}):Play()
			task.wait(0.3)
			clone6:Destroy()
		end)
	end

	clone3:Destroy()
	clone:Destroy()
	task.wait(3)

	for instance, v6 in pairs(v2) do
		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = v6
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			instance.Transparency = v6
		end
	end

	if face then
		face.Transparency = 0
	end

	head.Transparency = 0
	local clone6 = V.Phase3.EndImpact:Clone()
	clone6.CFrame = head.CFrame
	Util.SetParentOverrideWithColor(clone6, folder, player2, "BombFruitVFXColor")
	DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown

	for _, emitter in pairs(clone6:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v6 = emitter
		task.spawn(function()
			if v6:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v6:GetAttribute("EmitDelay"))
			end

			v6:Emit(v6:GetAttribute("EmitCount"))
		end)
	end
end