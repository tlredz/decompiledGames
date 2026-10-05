local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local parent = script.Parent
local elevatorDoor = parent:WaitForChild("ElevatorDoor")
local doorWheels = parent:WaitForChild("DoorWheels")
local opened = script.Parent:WaitForChild("Opened")
local openTrapDoors = script.Parent:WaitForChild("OpenTrapDoors")

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
		script.Parent.Sounds.Opening.Volume = 0.3
		script.Parent.Sounds.Opening.TimePosition = 0.25
		script.Parent.Sounds.PlaceSound:Play()
		script.Parent.Sounds.Opening:Play()
		local tween = TweenService:Create(script.Parent.Sounds.Opening, tweenInfo, {
			Volume = 0
		})
		tween:Play()
		tween.Completed:Wait()
		script.Parent.Sounds.Opening:Stop()

		if workspace.Info.Panic.Value == false then
			script.Parent.Sounds.ElevatorDing:Play()
		end
	else
		local cFrame2 = doorOpen.CFrame
		local v2 = doorClose.CFrame * CFrame.new(0, -1, 0)
		local v3 = cFrame * CFrame.Angles(-0.4363323129985824, 0, 0)
		script.Parent.Sounds.Closing:Play()
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
		script.Parent.Sounds.Closing:Stop()
		script.Parent.Sounds.CloseSound:Play()
		script.Parent.Sounds.PlaceSound:Play()
		script.Parent.Sounds.DisruptSound:Play()
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
		script.Parent.StoreSounds.Opening:Play()
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
		script.Parent.StoreSounds.Closing:Play()
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