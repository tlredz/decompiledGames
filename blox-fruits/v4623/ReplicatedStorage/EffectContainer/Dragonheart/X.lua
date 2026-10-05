local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Dragonheart").X.Assets
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Util = require(game.ReplicatedStorage.Util)
local cameraShaker = Util.CameraShaker
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

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

-- equivalent calls inferred from this helper; original call sites unknown
local function viewerIsClose(position, p, fn)
	local character = localPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= p then
			fn()
		end
	end
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

local function CameraFlame(parent)
	local currentCamera = workspace.CurrentCamera
	local clone = assets.Phase1.CameraFocus:Clone()
	clone.Parent = parent
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local clone2 = assets.Phase1.CustomColorCorrection:Clone()
	local tween = TweenService:Create(clone2, TweenInfo.new(0.7), {
		Brightness = clone2.Brightness,
		Contrast = clone2.Contrast,
		Saturation = clone2.Saturation,
		TintColor = clone2.TintColor
	})
	clone2.Brightness = 0
	clone2.Contrast = 0
	clone2.Saturation = 0
	clone2.TintColor = Color3.fromRGB(255, 255, 255)
	clone2.Parent = workspace.CurrentCamera
	tween:Play()
	clone2.Parent = game.Lighting
	return clone, renderSteppedConnection, clone2
end

local function Holding(humanoid, humanoidRootPart, folder, holding, start, raycastParams, clone, emitters)
	local folder2, connection, v

	if humanoidRootPart == (localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")) then
		folder2, connection, v = CameraFlame(folder)
	else
		folder2 = nil
		v = nil
		connection = nil
	end

	local clone2 = assets.Phase1.HoldAura:Clone()
	clone2.CFrame = humanoidRootPart.CFrame
	clone2.Anchored = false
	clone2.WeldConstraint.Part1 = humanoidRootPart
	clone2.Parent = folder
	local v2 = Util.Sound:Play("DragonHeart.DragonHeartXHold", humanoidRootPart)
	local v3 = {}
	local v4 = {}
	local effects = {}

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter.Rate *= 0.6
	end

	local raycastResult = workspace:Raycast(
		start.Position + createVector(0, 1, 0),
		createVector(-0, -66, -0),
		raycastParams
	)
	local clone3

	if raycastResult then
		local cFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
		clone3 = assets.Phase1.HoldArea:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = clone2

		for _, effect in pairs(clone3:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				if effect.Parent.Name ~= "Ring3" then
					table.insert(v3, effect)
					effect.Enabled = true
				end

				if effect.Parent.Name == "Ring3" and holding.Value == true then
					local v6 = effect
					task.spawn(function()
						task.wait(0.25 + math.random(50, 150) / 100)

						if holding.Value == true and v3 ~= nil and v4 ~= nil then
							table.insert(v3, v6)
							table.insert(v4, v6)
							v6.Enabled = true
						end
					end)
				end
			elseif effect:IsA("Beam") then
				table.insert(effects, effect)
			end
		end
	end

	local function ScaleParticle(state, p)
		local keypoints = state.Size.Keypoints
		local numberSequenceKeypoints = {}

		for i, keypoint in ipairs(keypoints) do
			numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
				keypoint.Time,
				keypoint.Value * p,
				keypoint.Envelope * p
			)
		end

		state.Size = NumberSequence.new(numberSequenceKeypoints)
		state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
		state.Acceleration *= p
	end

	local now = tick()
	local v5 = tick() + 0.5
	local now2 = tick()
	local v6 = 1
	local v7 = 0.1

	while true do
		if holding.Value == true and v6 < 10 and now - tick() <= 0 then
			now = tick() + 0.005

			for _ = 1, 5 do
				v6 = math.clamp(v6 + 0.1 + 0.05, 1, 10)
				v7 = math.clamp((v6 / 50) ^ 0.825 - 0.08 + 0.08, 0.08, 0.18)
				clone:ScaleTo(v7)

				if clone3 ~= nil then
					clone3.ScaleModel:ScaleTo(v6)
				end

				if holding.Value ~= true or not humanoid:IsDescendantOf(workspace) or humanoid.Health <= 0 then
					continue
				end

				task.wait(0.016666666666666666)
			end

			if v5 - tick() <= 0 then
				v5 = tick() + 0.5

				for _ = 1, 5 do
					for _, v8 in pairs(v4) do
						ScaleParticle(v8, 1.0225)
					end

					if holding.Value ~= true or not humanoid:IsDescendantOf(workspace) or humanoid.Health <= 0 then
						continue
					end

					task.wait(0.016666666666666666)
				end
			end

			if clone3 ~= nil then
				local X = clone3.ScaleModel.Ring.Size.X
				clone3.Ring2.Size = Vector3.new(X, clone3.Ring2.Size.Y, X)
				clone3.Ring3.Size = Vector3.new(X * 1.25, clone3.Ring3.Size.Y, X * 1.25)
			end

			for _, v8 in pairs(effects) do
				v8.Width0 = math.clamp(v8.Width0, 5, 15)
				v8.Width1 = math.clamp(v8.Width1, 5, 15)
			end
		end

		for _, item in pairs(emitters) do
			if item.SpreadAngle.X >= 180 then
				item:Emit(1)
			end
		end

		if now2 - tick() <= 0 then
			now2 = tick() + 0.15

			for _, v8 in pairs(v3) do
				v8:Emit(1)
			end
		end

		task.spawn(function()
			local cFrame = humanoidRootPart.CFrame * CFrame.new(
				math.random(-25, 25) * 2,
				math.random(-55, -50),
				math.random(-25, 25) * 2
			)
			local position = humanoidRootPart.Position
			local holdTrails = assets.Phase1.HoldTrails
			local clone4 = nil
			local v9 = math.random(1, #holdTrails:GetChildren())

			if v9 == 1 then
				clone4 = holdTrails.Trail1:Clone()
			elseif v9 == 2 then
				clone4 = holdTrails.Trail2:Clone()
			elseif v9 == 3 then
				clone4 = holdTrails.Trail3:Clone()
			elseif v9 == 4 then
				clone4 = holdTrails.Trail4:Clone()
			end

			clone4.CFrame = cFrame
			clone4.Parent = folder
			local position2 = clone4.Position
			local magnitude = (position2 - position).Magnitude
			clone4.CFrame = CFrame.new(position2, position)
			local v10 = (position2 - position) / 2
			local position3 = CFrame.new(CFrame.new(position2) * (v10 / -1.5)).Position
			local position4 = CFrame.new(CFrame.new(position) * (v10 / 1.5)).Position
			local halfMagnitude = magnitude / 2
			local v12 = position3 + Vector3.new(
				math.random(-halfMagnitude, halfMagnitude),
				math.random(-halfMagnitude / 2, halfMagnitude),
				math.random(-halfMagnitude, halfMagnitude)
			)
			local v13 = position4 + Vector3.new(
				math.random(-halfMagnitude, halfMagnitude),
				math.random(-halfMagnitude / 2, halfMagnitude),
				math.random(-halfMagnitude, halfMagnitude)
			)
			local v14 = math.random(10, 20) / 5
			local lastTime = tick()
			local v15 = magnitude / v14 / 60

			while tick() - lastTime < v15 do
				local v16 = (tick() - lastTime) / v15
				local v17 = cubicBezier(v16, position2, v12, v13, position)
				clone4.CFrame = clone4.CFrame:Lerp(CFrame.new(v17, position), v16)
				RunService.Heartbeat:Wait()
			end

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.spawn(function()
				task.wait(0.5)
				clone4:Destroy()
			end)
		end)
		local lastTime = tick()

		while tick() - lastTime < 0.1 and holding.Value == true and humanoid:IsDescendantOf(workspace) and not (humanoid.Health <= 0) do
			task.wait()
		end

		if not (holding.Value ~= true or not humanoid:IsDescendantOf(workspace) or humanoid.Health <= 0) then
			continue
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.3)
		end

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end

		v3 = nil
		v4 = nil
		task.spawn(function()
			task.wait(1.5)
			clone2:Destroy()
		end)

		if folder2 then
			task.spawn(function()
				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				TweenService:Create(v, TweenInfo.new(0.25), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
				task.wait(0.5)
				connection:Disconnect()
				folder2:Destroy()
				v:Destroy()
			end)
		end

		return v6, v7
	end
end

local function GroundRock(raycastResult, parent, data, fn)
	local cframe = CFrame.new(raycastResult.Position)
	local material = raycastResult.Material
	local color = raycastResult.Instance.Color
	local rockAmount = data.RockAmount
	local rockSize = data.RockSize
	local positionOffset = data.PositionOffset
	local rockRotationAmount = data.RockRotationAmount
	local rockRotationSpeed = data.RockRotationSpeed
	local rockRotationPower = data.RockRotationPower
	local duration = data.Duration

	for _ = 1, rockAmount do
		task.spawn(function()
			local clone = assets.Phase3.Rock:Clone()
			clone.Position = cframe.Position + Vector3.new(
				math.random(-positionOffset, positionOffset),
				math.random(0, positionOffset / 25),
				math.random(-positionOffset, positionOffset)
			)
			clone.Size = Vector3.new(
				math.random(rockSize / 2, rockSize),
				math.random(rockSize / 2, rockSize),
				math.random(rockSize / 2, rockSize)
			)
			clone.Material = material
			clone.Color = color
			rocks:ApplyCollision(clone, nil, true)
			clone.Parent = parent
			task.spawn(function()
				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.wait(duration + math.random(10, 50) / 100)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				TweenService:Create(
					clone,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
					{
						Size = createVector(0.01, 0.01, 0.01)
					}
				):Play()
			end)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.P = 3000
			bodyVelocity.Parent = clone
			fn(bodyVelocity, clone)
			clone.Attachment0.Orientation = createVector(0, 0, 0)
			local v = math.random(-rockRotationPower, rockRotationPower)
			local v2 = math.random(-rockRotationPower, rockRotationPower)
			local v3 = math.random(-rockRotationPower, rockRotationPower)
			local v4 = v / rockRotationAmount
			local v5 = v2 / rockRotationAmount
			local v6 = v3 / rockRotationAmount
			task.spawn(function()
				task.wait(0.05)

				for i = 1, rockRotationAmount do
					v = math.clamp(v - v4, 0, rockRotationPower * 1.5)
					v2 = math.clamp(v2 - v5, 0, rockRotationPower * 1.5)
					v3 = math.clamp(v3 - v6, 0, rockRotationPower * 1.5)
					local tween = TweenService:Create(
						clone.Attachment0,
						TweenInfo.new(rockRotationSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone.Attachment0.CFrame * CFrame.Angles(math.rad(v), math.rad(v2), (math.rad(v3)))
						}
					)
					tween:Play()
					tween.Completed:Wait()
					tween:Destroy()

					if i ~= rockRotationAmount then
						continue
					end

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				clone.AlignOrientation:Destroy()
			end)
			Util.Debris:AddItem(clone, 10)
		end)
		task.wait(0.01)
	end
end

local function TornadoSlash(folder, data)
	local multiplier = data.Multiplier
	local multiplier2 = data.Multiplier2
	local mutliplier2Time = data.Mutliplier2Time
	local beamOutTime = data.BeamOutTime
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local slashType = data.SlashType
	local slashCFrame = data.SlashCFrame
	local slashSpeed = data.SlashSpeed
	local slashSpeed2 = data.SlashSpeed2
	local spinIterations = data.SpinIterations
	local clone = slashType:Clone()
	clone.CFrame = slashCFrame
	clone.Parent = folder

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= multiplier
			descendant.CurveSize1 *= multiplier
			descendant.Width0 *= multiplier
			descendant.Width1 *= multiplier
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * multiplier,
				descendant.Position.Y * multiplier,
				descendant.Position.Z * multiplier
			)
		end
	end

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.Enabled = true
			local v = descendant
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						CurveSize0 = v.CurveSize0 * multiplier2,
						CurveSize1 = v.CurveSize1 * multiplier2,
						Width0 = v.Width0 * multiplier2,
						Width1 = v.Width1 * multiplier2
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				tween:Play()
			end)
		elseif descendant:IsA("Attachment") then
			TweenService:Create(
				descendant,
				TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(
						descendant.Position.X * multiplier2,
						descendant.Position.Y * multiplier2,
						descendant.Position.Z * multiplier2
					)
				}
			):Play()
		end
	end

	for _ = 1, spinIterations do
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(slashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * slashAngle
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v = beam
		task.spawn(function()
			local tween = TweenService:Create(
				v,
				TweenInfo.new(beamOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
			tween:Play()
			tween.Completed:Wait()
			v:Destroy()
		end)
	end

	TweenService:Create(clone, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * slashAngle2
	}):Play()
end

local function GroundExplosion(p, raycastParams, folder, _, duration, p2)
	local v = 50 * p2
	local raycastResult = workspace:Raycast(
		p.Position + createVector(0, 1, 0),
		createVector(0, 1, 0) * -v,
		raycastParams
	)

	if raycastResult then
		local cFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
		task.spawn(function()
			GroundRock(raycastResult, folder, {
				RockAmount = 25,
				RockSize = 10,
				PositionOffset = 70 * p2,
				RockRotationAmount = 10,
				RockRotationSpeed = 0.25,
				RockRotationPower = 150,
				Duration = 0.5
			}, function(p3, p4)
				local v4 = math.random(150, 200) * p2
				Util.Debris:AddItem(p3, math.random(10, 20) / 170)
				p3.Velocity = CFrame.new(p4.Position, p4.Position + cFrame.LookVector).UpVector * v4
			end)
		end)
		task.spawn(function()
			local clone = assets.Phase3.GroundImpact:Clone()
			Util.ResizeModel(clone, p2)
			clone.CFrame = cFrame
			clone.Parent = folder

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

			DeleteImpactAfterDuration(clone)
			local clone2 = assets.Phase3.GroundBurn:Clone()
			Util.ResizeModel(clone2, p2)
			clone2.CFrame = cFrame
			clone2.Parent = folder

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					v3.Enabled = true
					task.wait(duration)
					v3.Enabled = false
				end)
			end
		end)
	end
end

return function(player)
	local character = player.Character
	local holding = player.Holding
	local firePosition = player.FirePosition
	local _ = player.Timestamp
	local mousePos = player.MousePos

	if not (mousePos and firePosition and holding) then
		return
	end

	local humanoidRootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid

	if (humanoidRootPart.CFrame.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1200 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = false
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

	if player.TeleportStart then
		local clone = assets.Phase1.TeleportImpact:Clone()
		clone.CFrame = player.TeleportStart
		clone.Parent = folder
		DeleteImpactAfterDuration(clone)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			coroutine.wrap(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)()
		end

		Util.Debris:AddItem(folder, 5)
	else
		local clone = assets.Phase2.ProjectileModel:Clone()
		clone:ScaleTo(0.08)
		local primaryPart = clone.PrimaryPart
		primaryPart.CFrame = humanoidRootPart.CFrame + createVector(0, 15, 0)
		local emitters = {}

		for _, emitter in pairs(primaryPart:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			table.insert(emitters, emitter)
		end

		clone.Parent = folder
		local flag = true
		local v = 15
		local lastTime = tick()
		task.spawn(function()
			while flag do
				v = math.min(1, ((tick() - lastTime) / 3) ^ 0.725) * 40 + 15
				primaryPart.CFrame = CFrame.new(
					humanoidRootPart.Position + createVector(0, 1, 0) * v,
					mousePos:IsA("Vector3Value") and mousePos.Value or mousePos.Hit.p
				)
				task.wait()
			end
		end)
		local v2, v3 = Holding(
			humanoid,
			humanoidRootPart,
			folder,
			holding,
			player.Start,
			raycastParams,
			clone,
			emitters
		)
		flag = false
		local lastTime2 = tick()
		local value = nil

		while tick() - lastTime2 < 3 do
			if typeof(firePosition) == "number" then
				if character:FindFirstChild("DraconicFirePos" .. firePosition) then
					firePosition = character:FindFirstChild("DraconicFirePos" .. firePosition)
				end
			elseif firePosition.Value and firePosition.Value.Position.Magnitude > 0.01 then
				value = firePosition.Value
				break
			end

			task.wait()
		end

		if not value then
			Util.Debris:AddItem(folder, 5)
			return
		end

		clone:ScaleTo((math.min(0.18, v3 + 0.0333)))
		local cframe = CFrame.new(primaryPart.Position, value.Position)
		primaryPart.CFrame = cframe
		local clone2 = assets.Phase2.StartImpact:Clone()
		clone2.CFrame = cframe
		clone2.Parent = folder
		Util.Sound:Play("DragonHeart.DragonHeartXFire", cframe.Position)
		Util.ResizeModel(clone2, v / 15)
		DeleteImpactAfterDuration(clone2)

		for _, emitter in pairs(clone2:GetDescendants()) do
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

		local v4 = v * 5 + 300
		local _ = 0.1 + (cframe.Position - value.Position).Magnitude
		local v5 = math.clamp(10 / v2 * 0.3, 0.25, 0.5) * 1.3
		local v6 = value.Position - (value.Position - cframe.Position).Unit
		local ray, _, v7 = Util.Ray(
			v6,
			value.Position - v6 + (value.Position - v6).Unit,
			{ workspace.Characters, workspace.Enemies }
		)
		local v8 = not ray and createVector(0, 1, 0) or v7
		local cFrame = CFrame.new(value.Position, cframe.p) * CFrame.Angles(0, 3.141592653589793, 0)
		local v10 = (cframe.Position - value.Position).Magnitude / v4 * v5
		local tween = TweenService:Create(
			primaryPart,
			TweenInfo.new(v10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = cFrame
			}
		)
		tween:Play()
		task.spawn(function()
			local v11 = tick() + v10

			while true do
				for _, v12 in pairs(emitters) do
					v12:Emit(1)
				end

				task.wait(0.07)

				if not (v11 - tick() <= 0) then
					continue
				end

				emitters = nil
				break
			end
		end)
		tween.Completed:Wait()

		for _, emitter in pairs(primaryPart:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local cFrame2 = CFrame.new(cFrame.Position, cFrame.Position + v8) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local v12 = math.min(1, ((tick() - lastTime) / 3) ^ 0.875) * 0.6 + 1
		local clone3 = assets.Phase3.ExplosionStartImpact:Clone()
		Util.ResizeModel(clone3, v12)
		clone3.CFrame = cFrame2
		clone3.Parent = folder
		DeleteImpactAfterDuration(clone3)
		Util.Sound:Play("DragonHeart.DragonHeartXExplosion", cFrame2.Position)

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v13 = emitter
			coroutine.wrap(function()
				if v13:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v13:GetAttribute("EmitDelay"))
				end

				v13:Emit(v13:GetAttribute("EmitCount"))
			end)()
		end

		local clone4 = assets.Phase3.ExplosionSphere:Clone()
		Util.ResizeModel(clone4, v12)
		clone4.CFrame = cFrame2 * CFrame.new(0, ray and 30 or 0, 0)
		clone4.Parent = folder
		DeleteImpactAfterDuration(clone4)

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v13 = emitter
			coroutine.wrap(function()
				if v13:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v13:GetAttribute("EmitDelay"))
				end

				v13:Emit(v13:GetAttribute("EmitCount"))
			end)()
		end

		task.wait(0.15)
		task.wait(0.1)
		task.spawn(function()
			GroundExplosion(cFrame2, raycastParams, folder, 0.35, 1.5, v12)
		end)
		clone4:Destroy()
		local clone5 = assets.Phase3.Explosion:Clone()
		Util.ResizeModel(clone5, v12)
		clone5.CFrame = cFrame2 * CFrame.new(0, ray and 15 or 0, 0)
		clone5.Parent = folder

		for _, emitter in pairs(clone5:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v13 = emitter
			task.spawn(function()
				if v13:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v13:GetAttribute("EmitDelay"))
				end

				v13:Emit(v13:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone5)
		local clone6 = assets.Phase4.PillarExplosion:Clone()
		Util.ResizeModel(clone6, v12)
		clone6.CFrame = cFrame2
		clone6.Parent = folder

		for _, emitter in pairs(clone6:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v13 = emitter
			task.spawn(function()
				if v13:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v13:GetAttribute("EmitDelay"))
				end

				v13:Emit(v13:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone6)
		task.spawn(function()
			local function fn()
				cameraShaker:ShakeOnce(15, 7, 0.15, 0.6)
				local clone7 = assets.Phase4.CustomColorCorrection:Clone()
				local tween2 = TweenService:Create(clone7, TweenInfo.new(0.15), {
					Brightness = clone7.Brightness,
					Contrast = clone7.Contrast,
					Saturation = clone7.Saturation,
					TintColor = clone7.TintColor
				})
				clone7.Brightness = 0
				clone7.Contrast = 0
				clone7.Saturation = 0
				clone7.TintColor = Color3.fromRGB(255, 255, 255)
				clone7.Parent = workspace.CurrentCamera
				tween2:Play()
				clone7.Parent = game.Lighting
				tween2.Completed:Wait()
				TweenService:Create(clone7, TweenInfo.new(0.1), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
			end

			viewerIsClose(cFrame2.Position, v12 * 100 + 100, fn) -- equivalent call inferred; original call site unknown
		end)
		task.spawn(function()
			local slashCFrame = cFrame2 * CFrame.new(0, 5, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
			TornadoSlash(folder, {
				Multiplier = v12 * 2.5 * 0.875,
				Multiplier2 = v12 * 2.5 * 0.875,
				Mutliplier2Time = v12 * 0.15,
				BeamOutTime = 0.25,
				SlashAngle = CFrame.new(0, 0, v12 * -10) * CFrame.Angles(0, 0, 0.5235987755982988),
				SlashAngle2 = CFrame.new(0, 0, v12 * -15) * CFrame.Angles(0, 0, 0.8726646259971648),
				SlashType = assets.Phase4.RingBeam,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.05,
				SlashSpeed2 = 0.15,
				SpinIterations = 3
			})
		end)
		task.spawn(function()
			local slashCFrame = cFrame2 * CFrame.Angles(1.5707963267948966, 0, 0)
			TornadoSlash(folder, {
				Multiplier = v12 * 1.5 * 0.875,
				Multiplier2 = v12 * 2.5 * 0.875,
				Mutliplier2Time = v12 * 0.25,
				BeamOutTime = 0.25,
				SlashAngle = CFrame.new(0, 0, v12 * -15) * CFrame.Angles(0, 0, -0.8726646259971648),
				SlashAngle2 = CFrame.new(0, 0, v12 * -15) * CFrame.Angles(0, 0, -1.7453292519943295),
				SlashType = assets.Phase4.RingBeam,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.025,
				SlashSpeed2 = 0.5,
				SpinIterations = 7
			})
		end)
		task.wait(0.1)
		local clone7 = assets.Phase4.Pillar:Clone()
		Util.ResizeModel(clone7, v12)
		clone7.CFrame = cFrame2
		clone7.Parent = folder
		local emitters2 = {}

		for _, emitter in pairs(clone7:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Parent ~= clone7.Attachment then
				table.insert(emitters2, emitter)
			end
		end

		for _, v13 in pairs(emitters2) do
			v13.Enabled = true
		end

		task.spawn(function()
			local v13 = tick() + 0.5

			while true do
				for _, v14 in pairs(emitters2) do
					v14:Emit(1)
				end

				task.wait(0.15)

				if not (v13 - tick() <= 0) then
					continue
				end

				for _, emitter in pairs(clone7:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				break
			end
		end)
		task.spawn(function()
			for _ = 1, 10 do
				local clone8 = assets.Phase4.SpinTrail:Clone()
				Util.ResizeModel(clone8, v12)
				clone8.CFrame = cFrame2
				clone8.Parent = folder

				for _, effect in pairs(clone8:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				clone8.SpinTrail2.WeldConstraint.Enabled = false
				clone8.SpinTrail2.CFrame = clone8.CFrame * CFrame.new(
					math.random(-40, -20) * v12,
					math.random(-15, 15) * v12,
					0
				)
				clone8.SpinTrail2.WeldConstraint.Enabled = true
				clone8.CFrame *= CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				local v13 = math.random(1, 3)

				if v13 == 1 then
					clone8.Trail.Color = ColorSequence.new(Color3.fromRGB(248, 42, 45), Color3.fromRGB(255, 95, 40))
				elseif v13 == 2 then
					clone8.Trail.Color = ColorSequence.new(Color3.fromRGB(189, 37, 17), Color3.fromRGB(255, 99, 21))
				elseif v13 == 3 then
					clone8.Trail.Color = ColorSequence.new(Color3.fromRGB(156, 73, 18), Color3.fromRGB(255, 40, 25))
				end

				local v14 = math.random(7, 15) * 2 * v12
				clone8.SpinTrail2.Attach0.Position = Vector3.new(v14, 0, 0)
				clone8.SpinTrail2.Attach1.Position = Vector3.new(-v14, 0, 0)
				clone8.Trail.Lifetime = math.random(15, 30) / 100
				task.spawn(function()
					local v16 = math.random(7, 15)
					local v17 = math.random(25, 65) / 10

					for i = 1, 20 do
						clone8.CFrame = clone8.CFrame * CFrame.new(0, v17 * v12, 0) * CFrame.Angles(0, math.rad(v16), 0)
						task.wait()
					end
				end)
				task.wait(0.025)
			end
		end)
		Util.Debris:AddItem(folder, 15)
	end
end