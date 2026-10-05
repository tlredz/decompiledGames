local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local _ = Util.Tween
local misc = Util.Misc
local spring = Util.Spring
local rock2 = Util.Rock2
local FX = require(game.ReplicatedStorage.FX)
local M1 = FX:WaitForChild("Dragon2").Transformed.M1
local currentCamera = workspace.CurrentCamera
local clone = M1.WindFragments:Clone()
local v = {
	"rbxassetid://13530134016",
	"rbxassetid://13530140163",
	"rbxassetid://13530139966",
	"rbxassetid://13530139228",
	"rbxassetid://13530138845",
	"rbxassetid://13530138036",
	"rbxassetid://13530137489",
	"rbxassetid://13530137232",
	"rbxassetid://13530136981",
	"rbxassetid://13530136328",
	"rbxassetid://13530135966",
	"rbxassetid://13530135746",
	"rbxassetid://13530135454",
	"rbxassetid://13530135233",
	"rbxassetid://13530134996",
	"rbxassetid://13530134790",
	""
}

local function playTexture(value)
	return v[value or 1]
end

local function TornadoSlash(folder, data, player)
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
	local clone2 = slashType:Clone()
	clone2.CFrame = slashCFrame
	Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
	local descendants = clone2:GetDescendants()

	for _, instance in pairs(descendants) do
		if instance:IsA("Beam") then
			instance.CurveSize0 *= multiplier
			instance.CurveSize1 *= multiplier
			instance.Width0 *= multiplier
			instance.Width1 *= multiplier
		elseif instance:IsA("Attachment") then
			instance.Position = Vector3.new(
				instance.Position.X * multiplier,
				instance.Position.Y * multiplier,
				instance.Position.Z * multiplier
			)
		end
	end

	for _, instance in pairs(descendants) do
		if instance:IsA("Beam") then
			instance.Enabled = true
			local v2 = instance
			task.spawn(function()
				local tween = TweenService:Create(
					v2,
					TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						CurveSize0 = v2.CurveSize0 * multiplier2,
						CurveSize1 = v2.CurveSize1 * multiplier2,
						Width0 = v2.Width0 * multiplier2,
						Width1 = v2.Width1 * multiplier2
					}
				)
				v2.Width0 = 0
				v2.Width1 = 0
				tween:Play()
			end)
		elseif instance:IsA("Attachment") then
			TweenService:Create(
				instance,
				TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(
						instance.Position.X * multiplier2,
						instance.Position.Y * multiplier2,
						instance.Position.Z * multiplier2
					)
				}
			):Play()
		end
	end

	for _ = 1, spinIterations do
		local tween = TweenService:Create(
			clone2,
			TweenInfo.new(slashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone2.CFrame * slashAngle
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	for _, beam in pairs(descendants) do
		if not beam:IsA("Beam") then
			continue
		end

		local v2 = beam
		task.spawn(function()
			local tween = TweenService:Create(
				v2,
				TweenInfo.new(beamOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
			tween:Play()
			tween.Completed:Wait()
			v2:Destroy()
		end)
	end

	TweenService:Create(clone2, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone2.CFrame * slashAngle2
	}):Play()
end

local function mockRootPart(cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = workspace._WorldOrigin
	Util.DestroyAfter(part, 10)
	return part
end

local time2 = time

function RenderSteppedLoopFor(p, callback, callback2)
	local renderSteppedConnection = nil
	local v2 = time2()
	local bindableEvent = Instance.new("BindableEvent")
	local v3 = false
	local v4 = {
		Disconnect = function(self)
			if callback2 then
				v3 = true
				callback2()
			end

			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
			end
		end
	}
	local v5 = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
		if time2() - v2 < p and v5 == false then
			if callback(v4) then
				v5 = true
			end
		elseif v3 == true or callback2 == nil then
			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
			end
		else
			v3 = true
			callback2()

			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
			end
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()

	if renderSteppedConnection ~= nil then
		renderSteppedConnection:Disconnect()
	end

	return renderSteppedConnection
end

local function visualizeVector(p: string, vector2: Vector3, vector3: Vector3, p2: number, value: number?, color: Color3?)
	local v2 = workspace:FindFirstChild(p .. "_VectorDebug")

	if not v2 then
		v2 = Instance.new("Part")
		v2.Name = p .. "_VectorDebug"
		v2.Anchored = true
		v2.CanCollide = false
		v2.CanTouch = false
		v2.CanQuery = false
		v2.CastShadow = false
		v2.Material = Enum.Material.Neon
		v2.Parent = workspace
	end

	local v3 = value or 0.2
	local unit = vector3.Unit
	v2.Size = Vector3.new(v3, v3, p2)
	v2.CFrame = CFrame.lookAt(vector2, vector2 + unit * p2) * CFrame.new(0, 0, -p2 * 0.5)

	if color then
		v2.Color = color
	else
		local v4 = math.atan2(unit.X, unit.Z)
		local v5 = math.acos(unit.Y)
		local v6 = ((v4 + 3.141592653589793) / 12.566370614359172 + v5 / 6.283185307179586) % 1
		v2.Color = Color3.fromHSV(v6, 1, 1)
	end

	local v4 = workspace:FindFirstChild(p .. "_Arrowhead_VectorDebug")

	if not v4 then
		v4 = Instance.new("Part")
		v4.Name = p .. "_Arrowhead_VectorDebug"
		v4.Anchored = true
		v4.CanCollide = false
		v4.CanTouch = false
		v4.CanQuery = false
		v4.CastShadow = false
		v4.Material = Enum.Material.Neon
		v4.Shape = Enum.PartType.Ball
		v4.Parent = workspace
	end

	v4.Size = Vector3.new(v3 * 2, v3 * 2, v3 * 2)
	v4.CFrame = CFrame.new(vector2 + unit * p2)
	v4.Color = v2.Color
	return v2
end

local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local v2 = CFrame.new(0, -7.5, 2.5) * CFrame.Angles(-0.8, 0, 0)
local inverse = (CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse() * CFrame.Angles(
	0,
	4.71238898038469,
	0
)):Inverse()
return function(player)
	if (player.position - workspace.CurrentCamera.CFrame.p).Magnitude > 1500 then
		return
	end

	local maxDistance = player.MaxDistance or 100
	local character = player.Character
	local player2 = player.player
	local v3 = false
	local head = nil
	local dragonModel = player.dragonModel
	local flag

	if dragonModel then
		flag = false
	else
		dragonModel = character:FindFirstChild("WesternDragonRig")
		flag = true
	end

	local tongue3 = nil

	if flag then
		player.Mouse = setmetatable({}, {
			__index = function(_, p)
				if p == "Value" then
					return (player.Head.CFrame * CFrame.new(0, 0, -1500)).Position
				end
			end
		})
		head = player.Head
	else
		tongue3 = dragonModel.RootPart:FindFirstChild("Tongue3", true)

		if tongue3 then
			local cFrame = tongue3.WorldCFrame * inverse * v2
			local part = Instance.new("Part")
			part.Name = "Mock" .. part.Name
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Transparency = 1
			part.CFrame = cFrame
			part.Parent = workspace._WorldOrigin
			Util.DestroyAfter(part, 10)
			head = part
			task.spawn(function()
				RenderSteppedLoopFor(10, function(connection)
					if v3 or not head:IsDescendantOf(workspace) then
						connection:Disconnect()
						return true
					else
						head.CFrame = tongue3.WorldCFrame * inverse * v2
					end
				end)
			end)
		end
	end

	local mouse = player.Mouse

	if tongue3 then
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local Players = game:GetService("Players")
		local localPlayer = Players.LocalPlayer

		local function computeEndPos()
			local cframe

			if workspace:GetServerTimeNow() - player.headAim.LastHeadAimUpdate.Value > 1 then
				cframe = CFrame.new(head.Position, mouse.Value)
			elseif localPlayer == player.player then
				cframe = CFrame.lookAlong(createVector(0, 0, 0), player.headAim.HeadAimClient.Value) + head.Position
			else
				cframe = CFrame.lookAlong(createVector(0, 0, 0), player.headAim.Value) + head.Position
			end

			local magnitude = (player.Mouse.Value - player.Head.Position).Magnitude
			return head.Position + magnitude * cframe.LookVector
		end

		mouse = {
			Value = computeEndPos()
		}
		local connection = nil
		connection = heartbeatLoopFor2(10, function()
			if v3 == true then
				connection:Disconnect()
				return
			end

			local v4 = computeEndPos()
			mouse.Value = v4
		end)
	end

	local fadeIn = player.FadeIn
	local fadeOut = player.FadeOut
	local lifetime = player.Lifetime
	local percentageofMax = player.percentageofMax
	local realMaxDistance = player.realMaxDistance
	local clone2 = M1.Fireball:Clone()
	task.delay(45, function()
		clone2:Destroy()
	end)
	local ballfire = clone2.Ballfire
	local cone = clone2.Cone
	local clone3 = clone:Clone()
	clone3.CFrame = cone.CFrame
	Util.SetParentOverrideWithColor(clone3, clone2, player2, "DragonFruitVFXColor")
	local position = head.Position
	local v4 = {
		Ball = {},
		Cone = {}
	}
	local v5 = {}

	for _, folder in pairs({ ballfire, cone }) do
		local v6 = folder == ballfire and "Ball" or folder == cone and "Cone" or false

		for _, effect in pairs(folder:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				v4[v6][effect] = {
					Rate = effect.Rate,
					Size = effect.Size.Keypoints,
					Speed = effect.Speed,
					SpreadAngle = effect.SpreadAngle,
					ZOffset = effect.ZOffset
				}
			elseif effect:IsA("Beam") then
				v5[effect] = {
					Witdh0 = effect.Width0,
					Witdh1 = effect.Width1
				}
			end
		end
	end

	local v6 = 1
	local now = 0
	local lastTime = tick()

	local function updateVisual(position2, p, p2, p3, p4)
		if p4 then
			math.clamp(p4 / (300 - p2), 1, 5)
		end

		local v7 = tick() - lastTime
		local v8 = v6 / #v
		local _ = #v / v6
		local range = math.max(1, (math.min(maxDistance, p2)))
		local v10 = math.clamp(range / 30, 1, 2)
		math.clamp(p3 / 30, 1, 2)
		ballfire.Size = createVector(1, 1, 1) * range / 2
		ballfire.Transparency = range == 0 and 1 or 0
		ballfire.PointLight.Range = ballfire.Size.X * 0.75
		cone.SpotLight.Range = range
		ballfire:SetAttribute("Width", ballfire.Size.X / 2)

		for k, v11 in pairs(v4.Ball) do
			misc.ScaleParticle(k, range / 30, v11)
			k.Rate = v11.Rate * v10
			k.ZOffset = v11.ZOffset + v11.ZOffset * 0.1 * v10
		end

		for k, v11 in pairs(v5) do
			k.Width0 = v11.Witdh0 * v10
			k.Width1 = v11.Witdh1 * v10
		end

		for k, v11 in pairs(v4.Cone) do
			local v12 = v11.Speed.Min / v11.Speed.Max
			local velocity = misc.CalculateVelocity(range, k.Lifetime.Max, k.Drag)
			k.Size = misc.ScaleKeypoints(v11.Size, range / 30)
			k.Rate = v11.Rate * v10
			k.Speed = NumberRange.new(velocity * v12, velocity)
			k.SpreadAngle = v11.SpreadAngle
			k.ZOffset = v11.ZOffset + v11.ZOffset * 0.1 * v10
		end

		local unit = (p - cone.Position).Unit
		ballfire.CFrame = CFrame.new(position2 + unit * range, position2) * CFrame.Angles(
			3.141592653589793 * v7,
			3.141592653589793 * v7,
			3.141592653589793 * v7
		)
		ballfire.Transparency = v10 == 2 and (currentCamera.CFrame.Position - ballfire.Position).Magnitude < 300 and 0 or 1
		cone.CFrame = CFrame.new(position2, ballfire.Position)
		clone3.Mesh.Scale = createVector(0.031, 0.02, 0.031) * Vector3.new(
			ballfire.Size.X * 0.6,
			range * 0.5,
			ballfire.Size.Z * 0.6
		)
		clone3.CFrame = cone.CFrame * CFrame.new(0, 0, -range * 0.5 / 2) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone3.Decal.Color3 = Util.WrapColor3Constructor(
			Color3.fromRGB(500 - v8 * 100, 500 - v8 * 300, 500 - v8 * 500),
			player2,
			"DragonFruitVFXColor"
		)
		clone3.Decal.Texture = v[v6 or 1]
		local v12 = math.min(1, (currentCamera.CFrame.p - ballfire.Position).Magnitude / ballfire.Size.X)

		if tick() - now > 0.15 then
			local v13 = math.min(1, (currentCamera.CFrame.p - ballfire.Position).Magnitude / (ballfire.Size.X * 2))

			if v13 < 1 then
				Effect.new("ShakeCam"):replicate({
					Preset = "Bump",
					Power = v13 * 0.9 * 1.25 + 0.1
				})
			end

			now = tick()
		end

		if Util.Misc.PointWithinCone(
			currentCamera.CFrame.p,
			position2,
			(ballfire.Position - position2).Unit,
			range,
			ballfire.Size.X / 2
		) then
			Effect.new("ColorCorrection"):replicate({
				FadeIn = 0.05,
				Lifetime = 0.05,
				FadeOut = 0.1,
				Brightness = 0.6,
				Saturation = -0.5,
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 170, 0),
					player2,
					"DragonFruitVFXColor"
				)
			})
		elseif v12 < 1 then
			local v13 = 1 - v12
			Effect.new("ColorCorrection"):replicate({
				FadeIn = 0.05,
				Lifetime = 0.05,
				FadeOut = 0.1,
				Brightness = v13 * 0.6,
				Saturation = v13 * -0.5,
				TintColor = Util.WrapColor3ConstructorForTintColor(Color3.new(1, 1, 1), player2, "DragonFruitVFXColor"):Lerp(
					Util.WrapColor3Constructor(Color3.fromRGB(255, 170, 0), player2, "DragonFruitVFXColor"),
					v13
				)
			})
		end
	end

	updateVisual(head.Position, mouse.Value, 1, 1, 0)
	Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player2, "DragonFruitVFXColor")
	Util.Sound:Play("BF_V3_Flamethrower_Activate_03", cone)
	local v7 = position + (mouse.Value - position).Unit
	local v8 = spring.new(1, 4, v7)
	local position2 = createVector(0, 0, 0)
	local v9 = 0
	local v10 = 0.016666666666666666
	local v11 = nil
	Effect.new("Dragon2.Misc.GroundTrail"):replicate({
		player = player2,
		Anchor = ballfire,
		Width = ballfire,
		Duration = ballfire,
		Lifetime = 2
	})
	local v12 = Util.Sound:Play("BF_V3_Flamethrower_Loop_02", cone)
	local beamSlash2 = M1.BeamSlash2
	local savedQualityLevel = UserSettings().GameSettings.SavedQualityLevel

	if _G.FastMode or savedQualityLevel == Enum.SavedQualitySetting.QualityLevel1 or savedQualityLevel == Enum.SavedQualitySetting.QualityLevel2 then
		beamSlash2 = M1.BeamSlashLow
	end

	local v13 = 1 - percentageofMax
	pcall(function()
		while true do
			local lastTime2 = tick()
			local v14 = lastTime2 - lastTime
			local v15 = math.min(1, v14 / fadeIn + v13)
			local v16 = math.clamp((v14 - fadeIn) / lifetime + v13, 0, 1)
			local v17 = math.clamp((v14 - fadeIn - lifetime) / fadeOut + v13, 0, 0.8)
			local value = mouse.Value
			local v18 = position + (value - position).Unit * math.max(
				1,
				math.min(realMaxDistance, (value - position).Magnitude) * v15 * (1 - v17)
			)
			local v19 = v18
			local magnitude = 0

			for i = -5, 5 do
				local cframe = CFrame.lookAt(position, v19)
				local v20 = v19 - position
				local v21 = v19 + cframe.RightVector * i * (v20.Magnitude / 25) - position
				local rayMap, v22, _ = Util.RayMap(position, v21)

				if not (rayMap and v22) then
					continue
				end

				local magnitude2 = (position - v22).Magnitude

				if not (magnitude < magnitude2) then
					continue
				end

				v18 = v22
				magnitude = magnitude2
			end

			v6 = v6 % #v + 1
			v8:SetGoal(v18)
			v8:Update(v10)
			local position3 = v8:GetPosition()
			local v20 = math.min(realMaxDistance, (v18 - cone.Position).Magnitude)
			local v21 = math.min(realMaxDistance, (position3 - cone.Position).Magnitude)
			position = head.Position

			if magnitude == 0 then
				magnitude = (cone.Position - ballfire.Position).Magnitude
			end

			updateVisual(position, position3, v21, v20, 0)
			local v22 = magnitude / 15

			if (position2 - ballfire.Position).Magnitude > ballfire.Size.Z then
				for i = -1, 1, 2 do
					for i2 = 1, 4 do
						local v23 = misc.AlignCFrame(CFrame.new(ballfire.Position, position2)) * CFrame.Angles(
							0,
							-0 + (i == -1 and 3.141592653589793 or 0) + i2 * 0.5235987755982988,
							0
						) * CFrame.new(0, 0, -ballfire.Size.X / 2)
						local rayMapCollidable, v24, v25 = Util.RayMapCollidable(
							v23 * (createVector(0, 1, 0) * ballfire.Size.Y / 2),
							createVector(-0, -1, -0) * ballfire.Size.Y
						)

						if not rayMapCollidable then
							continue
						end

						local v26 = rock2.new({
							Type = "Ground",
							Scale = { v22 * 0.75, v22 * 1.25 },
							FadeIn = 0.5,
							FadeOut = 0.5,
							Lifetime = { 0.75, 1.5 }
						})
						local alignCFrame = misc.AlignCFrame(CFrame.new(v24) + v25 * 0.1, v25)
						v26:Spawn(alignCFrame)

						if math.random(2) ~= 1 then
							continue
						end

						v26.Type = "Flying"
						v26:Eject({
							Velocity = (alignCFrame.LookVector + v25 * 1.5).Unit * math.random(v22 * 10, v22 * 15),
							RotVelocity = Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)) * 3.141592653589793 * (v22 * math.random(
								0.5,
								1
							))
						})
					end
				end

				position2 = ballfire.Position
			end

			local multiplier = magnitude / 15
			local _ = cone.CFrame * CFrame.new(0, 0, -multiplier) * CFrame.Angles(1.5707963267948966, 0, 0)

			if lastTime2 - v9 > 0.15 then
				local multiplier2 = multiplier
				task.spawn(function()
					local folder = Instance.new("Folder", workspace._WorldOrigin)
					Util.Debris:AddItem(folder, 2)
					local slashCFrame = cone.CFrame * CFrame.new(0, 0, -5)
					TornadoSlash(folder, {
						Multiplier = 0.35,
						Multiplier2 = multiplier2,
						Mutliplier2Time = 0.25,
						BeamOutTime = 0.25,
						SlashAngle = CFrame.new(0, 0, -magnitude / 5) * CFrame.Angles(0, 0, 0.8726646259971648),
						SlashAngle2 = CFrame.new(0, 0, 5) * CFrame.Angles(0, 0, 1.7453292519943295),
						SlashType = beamSlash2,
						SlashCFrame = slashCFrame,
						SlashSpeed = 0.025,
						SlashSpeed2 = 0.35,
						SpinIterations = 5
					}, player2)
				end)
				local multiplier3 = multiplier
				task.spawn(function()
					local folder = Instance.new("Folder", workspace._WorldOrigin)
					Util.Debris:AddItem(folder, 2)
					local slashCFrame = cone.CFrame * CFrame.new(0, 0, 0)
					TornadoSlash(folder, {
						Multiplier = 0.25,
						Multiplier2 = multiplier3,
						Mutliplier2Time = 0.35,
						BeamOutTime = 0.15,
						SlashAngle = CFrame.new(0, 0, -magnitude / 3) * CFrame.Angles(0, 0, 0.8726646259971648),
						SlashAngle2 = CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, 1.7453292519943295),
						SlashType = beamSlash2,
						SlashCFrame = slashCFrame,
						SlashSpeed = 0.025,
						SlashSpeed2 = 0.25,
						SpinIterations = 3
					}, player2)
				end)
				v9 = lastTime2
			end

			if v17 >= 0.8 and not v11 then
				v11 = tick() + 2.5
			end

			if v14 >= 1 and (player.Holding == nil or player.Holding.Value == false) or v11 and v11 < tick() or v17 == 1 then
				break
			end

			if v16 == 1 then
				ballfire:SetAttribute("Destroy", true)
			end

			RunService.RenderStepped:Wait()
			v10 = tick() - lastTime2
		end
	end)
	v3 = true
	player.Holding.Value = false
	ballfire.Transparency = 1

	if v12 then
		Util.Sound:FadeOut(v12, 1)
	end

	Util.Sound:Play("BF_V3_Flamethrower_Turn_Off_01", cone)
	local v14 = 0

	for _, v15 in pairs({ v4.Ball, v4.Cone }) do
		for k, _ in pairs(v15) do
			v14 = math.max(v14, k.Lifetime.Max)
			k.Enabled = false
		end
	end

	for k, _ in pairs(v5) do
		k.Enabled = false
	end

	TweenService:Create(clone3.Decal, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	TweenService:Create(ballfire.PointLight, TweenInfo.new(v14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 0
	}):Play()
	TweenService:Create(cone.SpotLight, TweenInfo.new(v14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 0
	}):Play()
	task.wait(v14)
	clone2:Destroy()
	v4 = {
		Ball = {},
		Cone = {}
	}
end