local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local parent = script.Parent
local elevatorDoor = parent:WaitForChild("ElevatorDoor")
local doorWheels = parent:WaitForChild("DoorWheels")
local opened = script.Parent:WaitForChild("Opened")
local openTrapDoors = script.Parent:WaitForChild("OpenTrapDoors")

local function createFreezerFrostEffect()
	local cardModifiers = workspace:FindFirstChild("Info") and workspace.Info:FindFirstChild("CardModifiers")

	if not (cardModifiers and cardModifiers:FindFirstChild("IceSkatingEnabled") and cardModifiers.IceSkatingEnabled.Value) then
		return
	end

	local basePart = elevatorDoor:FindFirstChildWhichIsA("BasePart") or elevatorDoor:FindFirstChild("Part")

	if not basePart then
		return
	end

	local part = Instance.new("Part")
	part.Name = "FreezerFrost"
	part.Size = createVector(8, 1, 8)
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Anchored = true
	part.CFrame = basePart.CFrame * CFrame.new(0, 0, -3)
	part.Parent = parent
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "FreezerFog"
	particleEmitter.Texture = "rbxassetid://1084969416"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 245, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(210, 235, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 220, 245))
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 4),
		NumberSequenceKeypoint.new(0.4, 7),
		NumberSequenceKeypoint.new(0.7, 9),
		NumberSequenceKeypoint.new(1, 6)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.2, 0.45),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(0.8, 0.85),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.LightEmission = 0.1
	particleEmitter.LightInfluence = 0.9
	particleEmitter.Lifetime = NumberRange.new(3, 5)
	particleEmitter.Rate = 0
	particleEmitter.Speed = NumberRange.new(6, 12)
	particleEmitter.SpreadAngle = Vector2.new(45, 20)
	particleEmitter.Acceleration = createVector(0, -3, 0)
	particleEmitter.Drag = 2
	particleEmitter.RotSpeed = NumberRange.new(-15, 15)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.EmissionDirection = Enum.NormalId.Front
	particleEmitter.Parent = part
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "FreezerMist"
	particleEmitter2.Texture = "rbxassetid://243660364"
	particleEmitter2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 240, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 225, 250)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 210, 240))
	})
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.2, 2),
		NumberSequenceKeypoint.new(0.5, 4),
		NumberSequenceKeypoint.new(0.8, 5),
		NumberSequenceKeypoint.new(1, 3)
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.3, 0.6),
		NumberSequenceKeypoint.new(0.7, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.LightEmission = 0.15
	particleEmitter2.LightInfluence = 0.8
	particleEmitter2.Lifetime = NumberRange.new(2, 4)
	particleEmitter2.Rate = 0
	particleEmitter2.Speed = NumberRange.new(3, 8)
	particleEmitter2.SpreadAngle = Vector2.new(60, 30)
	particleEmitter2.Acceleration = createVector(0, -1, 0)
	particleEmitter2.Drag = 1.5
	particleEmitter2.RotSpeed = NumberRange.new(-30, 30)
	particleEmitter2.Rotation = NumberRange.new(0, 360)
	particleEmitter2.EmissionDirection = Enum.NormalId.Front
	particleEmitter2.Parent = part
	local particleEmitter3 = Instance.new("ParticleEmitter")
	particleEmitter3.Name = "FrostSparkles"
	particleEmitter3.Texture = "rbxassetid://6490035152"
	particleEmitter3.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 230, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	})
	particleEmitter3.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.2, 0.4),
		NumberSequenceKeypoint.new(0.8, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 0),
		NumberSequenceKeypoint.new(0.85, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter3.LightEmission = 1
	particleEmitter3.LightInfluence = 0.2
	particleEmitter3.Lifetime = NumberRange.new(1, 2)
	particleEmitter3.Rate = 0
	particleEmitter3.Speed = NumberRange.new(4, 10)
	particleEmitter3.SpreadAngle = Vector2.new(50, 40)
	particleEmitter3.Acceleration = createVector(0, -2, 0)
	particleEmitter3.Drag = 2
	particleEmitter3.RotSpeed = NumberRange.new(-200, 200)
	particleEmitter3.Rotation = NumberRange.new(0, 360)
	particleEmitter3.EmissionDirection = Enum.NormalId.Front
	particleEmitter3.Parent = part
	Audio:Play("Sounds.Elevator.Gate.ColdAir", {
		Name = "ColdAirHiss",
		Volume = 0.15,
		PlaybackSpeed = 0.8,
		RollOffMaxDistance = 50,
		Parent = part
	})
	particleEmitter:Emit(80)
	particleEmitter2:Emit(50)
	particleEmitter3:Emit(35)
	task.delay(5, function()
		if part and part.Parent then
			part:Destroy()
		end
	end)
	print("[Elevator] Freezer frost effect triggered - ice level!")
end

local function renderlerp(elevatorDoor2, cFrame, p, p2, quad, p3, p4, _)
	local renderSteppedConnection = nil
	local total = 0
	local v = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		total += dt
		local v2 = total / p2
		local value = TweenService:GetValue(math.min(total / p2, 1), quad, p3)
		local lerped = cFrame.Position:Lerp(p.Position, value)
		local lerped2 = cFrame.Rotation:Lerp(p.Rotation, value)
		elevatorDoor2:PivotTo(CFrame.new(lerped) * lerped2)

		if v2 >= 1 then
			v = true
			renderSteppedConnection:Disconnect()
		end
	end)

	if p4 then
		while not v do
			task.wait()
		end
	end
end

local function toggledoors(p)
	local doorOpen = parent.Positions.DoorOpen
	local doorClose = parent.Positions.DoorClose
	local cFrame = doorWheels.CFrame
	local v = cFrame * CFrame.Angles(2.7401669256310974, 0, 0)

	if p == true then
		local cFrame2 = doorClose.CFrame
		local cFrame3 = doorOpen.CFrame
		local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false)
		local v2 = elevatorDoor
		local quad = Enum.EasingStyle.Quad
		local out = Enum.EasingDirection.Out
		local renderSteppedConnection = nil
		local total = 0
		local v3 = false
		local v4 = 2
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			total += dt
			local v5 = total / v4
			local value = TweenService:GetValue(math.min(total / v4, 1), quad, out)
			local lerped = cFrame2.Position:Lerp(cFrame3.Position, value)
			local lerped2 = cFrame2.Rotation:Lerp(cFrame3.Rotation, value)
			v2:PivotTo(CFrame.new(lerped) * lerped2)

			if v5 >= 1 then
				v3 = true
				renderSteppedConnection:Disconnect()
			end
		end)
		local v5 = doorWheels
		local quad2 = Enum.EasingStyle.Quad
		local out2 = Enum.EasingDirection.Out
		local renderSteppedConnection2 = nil
		local total2 = 0
		local v6 = false
		local v7 = 2
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			total2 += dt
			local v8 = total2 / v7
			local value = TweenService:GetValue(math.min(total2 / v7, 1), quad2, out2)
			local lerped = cFrame.Position:Lerp(v.Position, value)
			local lerped2 = cFrame.Rotation:Lerp(v.Rotation, value)
			v5:PivotTo(CFrame.new(lerped) * lerped2)

			if v8 >= 1 then
				v6 = true
				renderSteppedConnection2:Disconnect()
			end
		end)
		createFreezerFrostEffect()
		local sounds = script.Parent:FindFirstChild("Sounds")

		if sounds then
			local opening = sounds:FindFirstChild("Opening")

			if opening then
				opening.Volume = 0.3
				opening.TimePosition = 0.25
				opening:Play()
				local tween = TweenService:Create(opening, tweenInfo, {
					Volume = 0
				})
				tween:Play()
				tween.Completed:Wait()
				opening:Stop()
			end

			local placeSound = sounds:FindFirstChild("PlaceSound")

			if placeSound then
				placeSound:Play()
			end

			local elevatorDing = workspace.Info.Panic.Value == false and sounds:FindFirstChild("ElevatorDing")

			if elevatorDing then
				elevatorDing:Play()
			end
		end
	else
		local cFrame2 = doorOpen.CFrame
		local v2 = doorClose.CFrame * CFrame.new(0, -1, 0)
		local v3 = cFrame * CFrame.Angles(-0.4363323129985824, 0, 0)
		local sounds = script.Parent:FindFirstChild("Sounds")
		local closing = sounds and sounds:FindFirstChild("Closing")

		if closing then
			closing:Play()
		end

		local v4 = doorWheels
		local quad = Enum.EasingStyle.Quad
		local v5 = Enum.EasingDirection.In
		local renderSteppedConnection = nil
		local total = 0
		local v6 = false
		local v7 = 0.75
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			total += dt
			local v8 = total / v7
			local value = TweenService:GetValue(math.min(total / v7, 1), quad, v5)
			local lerped = v.Position:Lerp(v3.Position, value)
			local lerped2 = v.Rotation:Lerp(v3.Rotation, value)
			v4:PivotTo(CFrame.new(lerped) * lerped2)

			if v8 >= 1 then
				v6 = true
				renderSteppedConnection:Disconnect()
			end
		end)
		renderlerp(elevatorDoor, cFrame2, v2, 0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In, true)
		local v8 = doorClose.CFrame * CFrame.new(0, -1, 0)
		local cFrame3 = doorClose.CFrame
		local v9 = cFrame * CFrame.Angles(-0.4363323129985824, 0, 0)
		local v10 = doorWheels
		local elastic = Enum.EasingStyle.Elastic
		local out = Enum.EasingDirection.Out
		local renderSteppedConnection2 = nil
		local total2 = 0
		local v11 = false
		local v12 = 1
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			total2 += dt
			local v13 = total2 / v12
			local value = TweenService:GetValue(math.min(total2 / v12, 1), elastic, out)
			local lerped = v9.Position:Lerp(cFrame.Position, value)
			local lerped2 = v9.Rotation:Lerp(cFrame.Rotation, value)
			v10:PivotTo(CFrame.new(lerped) * lerped2)

			if v13 >= 1 then
				v11 = true
				renderSteppedConnection2:Disconnect()
			end
		end)
		local v13 = elevatorDoor
		local elastic2 = Enum.EasingStyle.Elastic
		local out2 = Enum.EasingDirection.Out
		local renderSteppedConnection3 = nil
		local total3 = 0
		local v14 = false
		local v15 = 1
		renderSteppedConnection3 = RunService.RenderStepped:Connect(function(dt)
			total3 += dt
			local v16 = total3 / v15
			local value = TweenService:GetValue(math.min(total3 / v15, 1), elastic2, out2)
			local lerped = v8.Position:Lerp(cFrame3.Position, value)
			local lerped2 = v8.Rotation:Lerp(cFrame3.Rotation, value)
			v13:PivotTo(CFrame.new(lerped) * lerped2)

			if v16 >= 1 then
				v14 = true
				renderSteppedConnection3:Disconnect()
			end
		end)

		if sounds then
			local closing2 = sounds:FindFirstChild("Closing")

			if closing2 then
				closing2:Stop()
			end

			local closeSound = sounds:FindFirstChild("CloseSound")

			if closeSound then
				closeSound:Play()
			end

			local placeSound = sounds:FindFirstChild("PlaceSound")

			if placeSound then
				placeSound:Play()
			end

			local disruptSound = sounds:FindFirstChild("DisruptSound")

			if disruptSound then
				disruptSound:Play()
			end
		end
	end
end

local function toggletrapdoors(p)
	local openTrapDoorL = parent.Positions.OpenTrapDoorL
	local openTrapDoorR = parent.Positions.OpenTrapDoorR
	local closeTrapDoorL = parent.Positions.CloseTrapDoorL
	local closeTrapDoorR = parent.Positions.CloseTrapDoorR
	local _ = doorWheels.CFrame * CFrame.Angles(2.7401669256310974, 0, 0)

	if p == true then
		local cFrame = closeTrapDoorL.CFrame
		local cFrame2 = openTrapDoorL.CFrame
		local cFrame3 = closeTrapDoorR.CFrame
		local cFrame4 = openTrapDoorR.CFrame
		local trapDoorL = script.Parent.TrapDoorL
		local quad = Enum.EasingStyle.Quad
		local out = Enum.EasingDirection.Out
		local renderSteppedConnection = nil
		local total = 0
		local v = false
		local v2 = 1
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			total += dt
			local v3 = total / v2
			local value = TweenService:GetValue(math.min(total / v2, 1), quad, out)
			local lerped = cFrame.Position:Lerp(cFrame2.Position, value)
			local lerped2 = cFrame.Rotation:Lerp(cFrame2.Rotation, value)
			trapDoorL:PivotTo(CFrame.new(lerped) * lerped2)

			if v3 >= 1 then
				v = true
				renderSteppedConnection:Disconnect()
			end
		end)
		local trapDoorR = script.Parent.TrapDoorR
		local quad2 = Enum.EasingStyle.Quad
		local out2 = Enum.EasingDirection.Out
		local renderSteppedConnection2 = nil
		local total2 = 0
		local v3 = false
		local v4 = 1
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			total2 += dt
			local v5 = total2 / v4
			local value = TweenService:GetValue(math.min(total2 / v4, 1), quad2, out2)
			local lerped = cFrame3.Position:Lerp(cFrame4.Position, value)
			local lerped2 = cFrame3.Rotation:Lerp(cFrame4.Rotation, value)
			trapDoorR:PivotTo(CFrame.new(lerped) * lerped2)

			if v5 >= 1 then
				v3 = true
				renderSteppedConnection2:Disconnect()
			end
		end)
		local storeSounds = script.Parent:FindFirstChild("StoreSounds")
		local opening = storeSounds and storeSounds:FindFirstChild("Opening")

		if opening then
			opening:Play()
		end
	else
		local cFrame = openTrapDoorL.CFrame
		local cFrame2 = closeTrapDoorL.CFrame
		local cFrame3 = openTrapDoorR.CFrame
		local cFrame4 = closeTrapDoorR.CFrame
		local trapDoorL = script.Parent.TrapDoorL
		local bounce = Enum.EasingStyle.Bounce
		local out = Enum.EasingDirection.Out
		local renderSteppedConnection = nil
		local total = 0
		local v = false
		local v2 = 0.85
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			total += dt
			local v3 = total / v2
			local value = TweenService:GetValue(math.min(total / v2, 1), bounce, out)
			local lerped = cFrame.Position:Lerp(cFrame2.Position, value)
			local lerped2 = cFrame.Rotation:Lerp(cFrame2.Rotation, value)
			trapDoorL:PivotTo(CFrame.new(lerped) * lerped2)

			if v3 >= 1 then
				v = true
				renderSteppedConnection:Disconnect()
			end
		end)
		local trapDoorR = script.Parent.TrapDoorR
		local bounce2 = Enum.EasingStyle.Bounce
		local out2 = Enum.EasingDirection.Out
		local renderSteppedConnection2 = nil
		local total2 = 0
		local v3 = false
		local v4 = 0.85
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			total2 += dt
			local v5 = total2 / v4
			local value = TweenService:GetValue(math.min(total2 / v4, 1), bounce2, out2)
			local lerped = cFrame3.Position:Lerp(cFrame4.Position, value)
			local lerped2 = cFrame3.Rotation:Lerp(cFrame4.Rotation, value)
			trapDoorR:PivotTo(CFrame.new(lerped) * lerped2)

			if v5 >= 1 then
				v3 = true
				renderSteppedConnection2:Disconnect()
			end
		end)
		task.wait(0.25)
		local storeSounds = script.Parent:FindFirstChild("StoreSounds")
		local closing = storeSounds and storeSounds:FindFirstChild("Closing")

		if closing then
			closing:Play()
		end
	end
end

opened.Changed:Connect(function(p)
	toggledoors(p)
end)
openTrapDoors.Changed:Connect(function(p)
	toggletrapdoors(p)
end)

if opened.Value == true then
	toggledoors(true)
else
	toggledoors(false)
end

if openTrapDoors.Value == true then
	toggletrapdoors(true)
else
	toggletrapdoors(false)
end