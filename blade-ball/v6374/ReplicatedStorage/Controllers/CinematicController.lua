local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local CinematicController = {}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = {
	localPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"),
	localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar")
}
local v2 = require3(ReplicatedStorage2.Common.Utils)
local _ = v2.StateStack
local currentCamera = workspace.CurrentCamera
local cframe = CFrame.new()
local cframe2 = CFrame.new()

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function quadBezier(p, p2, p3, p4)
	local v3 = p2 + (p4 - p2) * p
	return v3 + (p4 + (p3 - p4) * p - v3) * p
end

local stateStack = v2.StateStack.new()
local maid = v2.Maid.new()

local function isNotDestroyed(parent)
	while parent.Parent ~= nil do
		if parent.Parent == game then
			return true
		else
			parent = parent.Parent
		end
	end
end

local function setCameraStep(callback, p)
	if callback then
		currentCamera.CameraType = Enum.CameraType.Scriptable
		maid.ReassignCameraSubject = localPlayer.CharacterAdded:Connect(function(character)
			if currentCamera.CameraSubject then
				local cameraSubject = currentCamera.CameraSubject
				local v3

				while true do
					if cameraSubject.Parent == nil then
						v3 = nil
						break
					end

					if cameraSubject.Parent == game then
						v3 = true
						break
					else
						cameraSubject = cameraSubject.Parent
					end
				end

				if not v3 then
					currentCamera.CameraSubject = character:WaitForChild("Humanoid")
				end
			end
		end)
		maid.Render = RunService.RenderStepped:Connect(function(dt)
			local v3, v4, v5 = callback(dt)

			if v5 then
				currentCamera.CFrame = v3 * cframe * CFrame.Angles(0, 0, (math.rad(v5)))
			else
				currentCamera.CFrame = v3 * cframe
			end

			if v4 then
				CinematicController:Remove(p)
			end
		end)
	else
		maid.Render = nil
		currentCamera.CameraType = Enum.CameraType.Custom
	end
end

function CinematicController.Reset(_)
	if #stateStack:GetStacks() ~= 0 then
		for _, v3 in pairs(stateStack:GetStacks()) do
			CinematicController:Remove(v3)
		end
	end

	setCameraStep()
end

function CinematicController:AddCameraStep(callback)
	local v3 = nil
	v3 = v2.StateStack.newState(function()
		setCameraStep(callback, v3)
		return function()
			if v3.InterruptOnFinished and #stateStack:GetStacks() == 0 then
				setCameraStep()
			end
		end
	end)

	for _, v4 in pairs(v) do
		v4.Enabled = false
	end

	stateStack:AddStack(v3)
	return v3
end

function CinematicController:Remove(p)
	stateStack:RemoveStack(p)

	if #stateStack:GetStacks() <= 0 then
		for _, v3 in pairs(v) do
			v3.Enabled = true
		end
	else
		return p
	end
end

local function findClosestValues(list, p: number)
	local count = #list

	if p <= list[1].Time then
		return list[1], list[2], 1
	end

	if list[count].Time <= p then
		return list[count], nil, count
	end

	local v3 = 1

	while v3 < count do
		local v4 = math.floor((v3 + count) / 2)

		if list[v4].Time < p then
			v3 = v4 + 1
		else
			count = v4
		end
	end

	if list[v3].Time == p then
		return list[v3], list[v3 + 1], v3
	end

	if p < list[v3].Time then
		return list[v3 - 1], list[v3], v3 - 1
	end

	return list[v3], list[v3 + 1], v3
end

function CinematicController.PlayPoints(_, cframe3: CFrame, list)
	local lastTime = tick()
	local v3 = 0

	local function interpolateCamera()
		local v4 = tick() - lastTime
		local closestValues, v5, v6 = findClosestValues(list, v4)
		local v7 = not (closestValues and v5) and 0 or v5.Time - closestValues.Time or 0

		if v3 ~= v6 then
			v3 = v6
		end

		if not closestValues then
			return currentCamera.CFrame, v6 == #list
		end

		if not (v5 and v7 ~= 0) then
			return cframe3 * closestValues.CFrame, v6 == #list
		end

		local v8 = math.clamp((v4 - closestValues.Time) / v7, 0, 1)
		return cframe3 * closestValues.CFrame:Lerp(v5.CFrame, v8), v6 == #list
	end

	return CinematicController:AddCameraStep(interpolateCamera)
end

function CinematicController.PlayPointsWithAnimationTrack(_, data, cframe3: CFrame, list, value: number?)
	local v3 = 0
	local v4 = value or 0
	data.Ended:Connect(function()
		v3 = #list
	end)

	local function interpolateCamera()
		local v5 = math.max(data.TimePosition - v4, 0)
		local closestValues, v6, v7 = findClosestValues(list, v5)
		local v8 = not (closestValues and v6) and 0 or v6.Time - closestValues.Time or 0

		if not closestValues then
			print("No point found at", v5)
		end

		if v3 ~= v7 then
			v3 = v7
		end

		if not closestValues then
			return currentCamera.CFrame, v7 == #list or data.IsPlaying == false
		end

		if not (v6 and v8 ~= 0) then
			return cframe3 * closestValues.CFrame, v7 == #list or data.IsPlaying == false
		end

		local v9 = math.clamp((v5 - closestValues.Time) / v8, 0, 1)
		return cframe3 * closestValues.CFrame:Lerp(v6.CFrame, v9), v7 == #list or data.IsPlaying == false
	end

	return CinematicController:AddCameraStep(interpolateCamera)
end

function CinematicController:CreateCinematic(data)
	local duration = data.Duration or 1
	local positionA = data.PositionA
	local positionB = data.PositionB or positionA
	local positionPivot = data.PositionPivot
	local lookVectorA = data.LookVectorA
	local lookVectorB = data.LookVectorB or lookVectorA
	local lookVectorPivot = data.LookVectorPivot
	local lastTime = nil
	local fn = positionPivot and function(p)
		local positionA2 = positionA
		local positionPivot2 = positionPivot
		local v6 = positionA2 + (positionPivot2 - positionA2) * p
		return v6 + (positionPivot2 + (positionB - positionPivot2) * p - v6) * p
	end or function(p)
		local positionA2 = positionA
		return positionA2 + (positionB - positionA2) * p
	end
	local fn2 = lookVectorPivot and function(p)
		local lookVectorA2 = lookVectorA
		local lookVectorPivot2 = lookVectorPivot
		local v6 = lookVectorA2 + (lookVectorPivot2 - lookVectorA2) * p
		return v6 + (lookVectorPivot2 + (lookVectorB - lookVectorPivot2) * p - v6) * p
	end or function(p)
		local lookVectorA2 = lookVectorA
		return lookVectorA2 + (lookVectorB - lookVectorA2) * p
	end
	local cameraTiltStart = data.CameraTiltStart or 0
	local cameraTiltEnd = data.CameraTiltEnd or 0

	local function interpolateCamera()
		local v3 = math.clamp((os.clock() - lastTime) / duration, 0, 1)
		local v4 = fn(v3)
		local v5 = fn2(v3)

		if cameraTiltStart == 0 and cameraTiltEnd == 0 then
			return CFrame.new(v4, v5), v3 == 1
		end

		local v6 = cameraTiltStart
		return CFrame.new(v4, v5), v3 == 1, v6 + (cameraTiltEnd - v6) * v3
	end

	if data.SmoothTransition then
		local smoothTransition = tonumber(data.SmoothTransition) or 1
		local cFrame = currentCamera.CFrame
		local v3 = fn(0)
		local v4 = fn2(0)
		local cframe3 = CFrame.new(v3, v4)
		local lastTime2 = os.clock()
		CinematicController:AddCameraStep(function()
			local v5 = math.clamp((os.clock() - lastTime2) / smoothTransition, 0, 1)
			local lerped = cFrame:Lerp(cframe3, v5)
			local v6 = v5 == 1
			local v7

			if cameraTiltStart ~= 0 then
				v7 = cameraTiltStart or nil
			end

			return lerped, v6, v7
		end).Removed:Wait()
	end

	lastTime = os.clock()
	return CinematicController:AddCameraStep(interpolateCamera), duration
end

function CinematicController:GetCinematicConfiguration(instance)
	local positions = {
		instance.Position:FindFirstChild("Start"),
		instance.Position:FindFirstChild("End"),
		instance.Position:FindFirstChild("Input")
	}
	local positions2 = {
		instance.Focus:FindFirstChild("Start"),
		instance.Focus:FindFirstChild("End"),
		instance.Focus:FindFirstChild("Input")
	}

	for k, part in pairs(positions) do
		if typeof(part) == "Instance" and part:IsA("BasePart") then
			positions[k] = part.Position
		end
	end

	for k, part in pairs(positions2) do
		if typeof(part) == "Instance" and part:IsA("BasePart") then
			positions2[k] = part.Position
		end
	end

	return positions, positions2, instance:GetAttribute("Duration")
end

function CinematicController.CreateCinematicFromConfiguration(_, instance, p: number?, smoothTransition)
	local cinematicConfiguration, v3, v4 = CinematicController:GetCinematicConfiguration(instance)
	local duration = p or v4 or instance:GetAttribute("Duration")
	return CinematicController:CreateCinematic({
		PositionA = cinematicConfiguration[1],
		PositionB = cinematicConfiguration[2],
		PositionPivot = cinematicConfiguration[3],
		LookVectorA = v3[1],
		LookVectorB = v3[2],
		LookVectorPivot = v3[3],
		CameraTiltStart = instance:GetAttribute("CameraTiltStart"),
		CameraTiltEnd = instance:GetAttribute("CameraTiltEnd"),
		Duration = duration,
		SmoothTransition = smoothTransition
	})
end

function CinematicController.Shake(_, value: number?, value2: number?, value3: number?)
	local v3 = value2 or 1
	local v4 = value or 1
	local v5 = value3 or 1
	local lastTime = os.clock()
	cframe = cframe2
	maid.Shake = RunService.PostSimulation:Connect(function(dt)
		local v6 = math.clamp((os.clock() - lastTime) / v5, 0, 1)
		local v7 = v3 * (1 - v6)
		local cframe3 = CFrame.Angles(
			math.random() * 3.141592653589793 * 2 * v7,
			math.sin(v6 * 3.141592653589793 * 2 * v4) * math.clamp(v3 / 2, 0, 3.141592653589793),
			math.random() * 3.141592653589793 * 2 * v7
		)
		cframe = cframe:Lerp(cframe3, dt):Lerp(cframe2, v6)
		local v8 = currentCamera.CFrame * cframe3
		currentCamera.CFrame = currentCamera.CFrame:Lerp(v8, dt)
	end)
	maid.ShakeDisable = v2.Thread.Delay(v5, function()
		maid.Shake = nil
		maid.ShakeDisable = nil
	end)
end

return CinematicController