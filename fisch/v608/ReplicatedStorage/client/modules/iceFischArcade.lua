local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local localPlayer = Players.LocalPlayer
local v = {
	6,
	8,
	6,
	16,
	18
}
local count = #v
local v2 = { "rbxassetid://75952562387743", "rbxassetid://130038696310212" }
local v3 = { "rbxassetid://75952562387743", "rbxassetid://92203290196200" }
local flag = false
local flag2 = false
local v4 = 1
local count2 = 0
local count3 = 0
local count4 = 0
local count5 = 0
local v5 = 3
local total = 0
local v6 = true
local v7 = nil
local v8 = nil
local v9 = false
local flag3 = false
local flag4 = false
local v10 = nil
local v11 = false
local v12 = 0.5
local v13 = false
local v14 = 0
local position = nil
local v15 = false
local heartbeatConnection = nil
local v16 = {}
local threads = {}
local v17 = {}
local count6 = 0
local cameraType = nil
local mouseDeltaSensitivity = nil
local v18 = nil
local v19 = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = nil
local v24 = nil
local v25 = nil
local v26 = nil
local v27 = nil
local v28 = nil
local v29 = nil
local v30 = nil
local v31 = nil
local fn
local fn2
local fn3
local fn4

-- equivalent calls inferred from this helper; original call sites unknown
local function lockMovement()
	local character = localPlayer.Character

	if character then
		character:SetAttribute("PlayingArcade", 0)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unlockMovement()
	local character = localPlayer.Character

	if character then
		character:SetAttribute("PlayingArcade", nil)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lockCamera()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		cameraType = currentCamera.CameraType
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = currentCamera.CFrame
	end

	mouseDeltaSensitivity = UserInputService.MouseDeltaSensitivity
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseDeltaSensitivity = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unlockCamera()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CameraType = cameraType or Enum.CameraType.Custom
		currentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") or nil
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseDeltaSensitivity = mouseDeltaSensitivity or 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateScoreLabel()
	local v32 = v27

	if v32 then
		v32.Text = "LV" .. v4 .. "  SCORE: " .. total
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateLivesLabel()
	local v32 = v28

	if v32 then
		v32.Text = "LIVES: " .. v5
	end
end

local function cleanupGameConnections()
	for _, connection in pairs(v16) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end

	table.clear(v16)
	table.clear(threads)
	local v32 = v21

	if v32 then
		for _, child in pairs(v32:GetChildren()) do
			if not (child.Name == "Fish" or child.Name == "GrayFish" or child.Name == "Kicker" or child.Name == "Shark" or child.Name == "Jellyfish" or child.Name == "OneUp" or child.Name == "HookFall") then
				continue
			end

			child:Destroy()
		end
	end

	local v33 = v29

	if v33 then
		v33:Destroy()
		v29 = nil
	end

	local v34 = v30

	if v34 then
		v34:Destroy()
		v30 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isHookBelowIce()
	local v32 = v23
	local v33 = v21

	if v32 and v33 and v33.AbsoluteSize.Y ~= 0 then
		return v32.Position.Y.Offset / v33.AbsoluteSize.Y > 0.25
	end

	return false
end

local function checkCollision(imageLabel)
	local v32 = v23

	if not (v32 and v32.Visible) then
		return false
	end

	local absolutePosition = v32.AbsolutePosition
	local absoluteSize = v32.AbsoluteSize
	local absoluteSize2 = imageLabel.AbsoluteSize
	local v33 = absoluteSize2.X * 0.25
	local v34 = absoluteSize2.Y * 0.25
	local v35 = imageLabel.AbsolutePosition + Vector2.new(v33, v34)
	local v36 = absoluteSize2 - Vector2.new(v33 * 2, v34 * 2)
	return absolutePosition.X < v35.X + v36.X and absolutePosition.X + absoluteSize.X > v35.X and absolutePosition.Y < v35.Y + v36.Y and absolutePosition.Y + absoluteSize.Y > v35.Y
end

local function checkLineCollision(imageLabel)
	local v32 = v22

	if not (v32 and v32.Visible) then
		return false
	end

	local absolutePosition = v32.AbsolutePosition
	local absoluteSize = v32.AbsoluteSize
	local absolutePosition2 = imageLabel.AbsolutePosition
	local absoluteSize2 = imageLabel.AbsoluteSize
	return absolutePosition.X < absolutePosition2.X + absoluteSize2.X and absolutePosition.X + absoluteSize.X > absolutePosition2.X and absolutePosition.Y < absolutePosition2.Y + absoluteSize2.Y and absolutePosition.Y + absoluteSize.Y > absolutePosition2.Y
end

local function createWorm()
	local parent = v23

	if not parent then
		return
	end

	if v10 then
		v10:Destroy()
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Worm"
	imageLabel.Size = UDim2.new(0.7, 0, 0.7, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://74583108514843"
	imageLabel.AnchorPoint = Vector2.new(0.5, 0)
	imageLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
	imageLabel.ZIndex = 2
	imageLabel.Parent = parent
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = imageLabel
	v10 = imageLabel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeWorm()
	if v10 then
		v10:Destroy()
		v10 = nil
	end
end

local function showNeedWormPrompt()
	local parent = v21

	if not parent then
		return
	end

	if v30 then
		v30:Destroy()
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "WormPrompt"
	textLabel.Size = UDim2.new(0.6, 0, 0.08, 0)
	textLabel.Position = UDim2.new(0.2, 0, 0.15, 0)
	textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.BackgroundTransparency = 0.4
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.ZIndex = 20
	textLabel.Text = "Click above the ice for a new worm!"
	textLabel.Parent = parent
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.2, 0)
	uICorner.Parent = textLabel
	v30 = textLabel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideNeedWormPrompt()
	if v30 then
		v30:Destroy()
		v30 = nil
	end
end

local function fishFlees()
	local v32 = v23
	local parent = v21
	local v34 = v8
	v6 = true
	v7 = nil
	v8 = nil

	if not (v34 and parent and v32) then
		return
	end

	local v35 = v32.AbsolutePosition.Y + v32.AbsoluteSize.Y - parent.AbsolutePosition.Y
	v34.Parent = parent
	v34.Size = UDim2.new(0.22, 0, 0.16, 0)
	v34.ScaleType = Enum.ScaleType.Fit
	v34.Position = UDim2.new(0.5, -20, 0, v35)
	v34.Rotation = 180
	v34.Visible = true
	TweenService:Create(v34, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, -20, 1, -50),
		ImageTransparency = 1
	}):Play()
	Debris:AddItem(v34, 0.8)

	if v10 and not v9 then
		v10.Visible = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function depositFish()
	local v32 = v8

	if not v32 then
		return
	end

	if v7 == "gray" then
		total += 8
		count5 += 1
	else
		total += 4
		count4 += 1
	end

	count3 += 1
	count2 += 1
	v32:Destroy()
	v8 = nil
	v7 = nil
	v6 = true

	if v10 then
		v10.Visible = true
	end

	updateScoreLabel() -- equivalent call inferred; original call site unknown
end

local function cutLine()
	if flag3 then
		return
	end

	flag3 = true
	local v32 = v23
	local v33 = v22
	local parent = v21

	if v8 then
		fishFlees()
	end

	removeWorm() -- equivalent call inferred; original call site unknown

	if v32 and parent then
		local clone = v32:Clone()
		clone.Name = "HookFall"
		clone.Visible = true

		for _, child in clone:GetChildren() do
			if not (child:IsA("UIAspectRatioConstraint") or child:IsA("UICorner")) then
				child:Destroy()
			end
		end

		clone.Position = UDim2.new(
			v32.Position.X.Scale,
			v32.Position.X.Offset,
			0,
			v32.AbsolutePosition.Y - parent.AbsolutePosition.Y
		)
		clone.Parent = parent
		TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(clone.Position.X.Scale, clone.Position.X.Offset, 1.1, 0),
			ImageTransparency = 0.5
		}):Play()
		Debris:AddItem(clone, 0.6)
	end

	if v32 then
		v32.Visible = false
	end

	if v33 then
		v33.Visible = false
	end

	v9 = true
	showNeedWormPrompt()
end

local function shockLine()
	if flag4 then
		return
	end

	flag4 = true
	local v32 = v22

	if not v32 then
		flag4 = false
		return
	end

	if v8 then
		fishFlees()
	end

	local lastTime = tick()
	local v33 = count6
	local color = Color3.fromRGB(0, 0, 0)
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if flag2 and v33 == count6 then
			local v34 = tick() - lastTime

			if not (v34 >= 2) then
				v32.BackgroundColor3 = math.floor(v34 * 8) % 2 == 0 and Color3.fromRGB(255, 255, 0) or color
				return
			end
		end

		v32.BackgroundColor3 = color
		flag4 = false
		renderSteppedConnection:Disconnect()
		v16[renderSteppedConnection] = nil
	end)
	v16[renderSteppedConnection] = renderSteppedConnection
end

local function getNewWorm()
	if not v9 then
		return true
	end

	if v5 <= 0 then
		fn2()
		return false
	end

	v5 -= 1
	updateLivesLabel() -- equivalent call inferred; original call site unknown
	v9 = false
	flag3 = false
	hideNeedWormPrompt() -- equivalent call inferred; original call site unknown
	local v32 = v23

	if v32 then
		v32.Visible = true
	end

	local v33 = v22

	if v33 then
		v33.Visible = true
	end

	v6 = true
	v8 = nil
	v7 = nil
	createWorm()
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEndlessFish()
	return (math.max(0, count3 - 54))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSpeedMultiplier()
	local endlessFish = getEndlessFish() -- equivalent call inferred; original call site unknown

	if endlessFish <= 0 then
		return 1
	end

	return (math.max(0.5, 1 - endlessFish * 0.008))
end

local function getCurrentSpawnInterval()
	local v32 = 4 - (math.min(v4, count) - 1) * 0.5
	local endlessFish = getEndlessFish() -- equivalent call inferred; original call site unknown

	if endlessFish > 0 then
		v32 -= endlessFish * 0.015
	end

	return (math.max(0.8, v32))
end

local function showLevelTransition(p: number)
	local parent = v21

	if not parent then
		return
	end

	v11 = true
	local frame = Instance.new("Frame")
	frame.Name = "LevelOverlay"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.5
	frame.ZIndex = 30
	frame.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.6, 0, 0.15, 0)
	textLabel.Position = UDim2.new(0.2, 0, 0.4, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.ZIndex = 31
	textLabel.Text = "LEVEL " .. p
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.new(0.6, 0, 0.06, 0)
	textLabel2.Position = UDim2.new(0.2, 0, 0.56, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextColor3 = Color3.fromRGB(200, 200, 200)
	textLabel2.Font = Enum.Font.Gotham
	textLabel2.TextScaled = true
	textLabel2.ZIndex = 31
	textLabel2.Text = "Catch " .. v[p] .. " fish!"
	textLabel2.Parent = frame
	v29 = frame
	task.delay(2.5, function()
		if frame.Parent then
			frame:Destroy()
		end

		if v29 == frame then
			v29 = nil
		end

		v11 = false
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkLevelUp()
	if count < v4 then
		return
	end

	if v[v4] <= count2 then
		if v4 < count then
			v4 += 1
			count2 = 0
			showLevelTransition(v4)
		else
			v4 += 1
			count2 = 0
		end

		updateScoreLabel() -- equivalent call inferred; original call site unknown
	end
end

local function spawnFish(flag5: boolean?)
	local parent = v21
	local parent2 = v23

	if not (flag2 and parent and parent2) then
		return
	end

	local v34 = flag5 == true
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = v34 and "GrayFish" or "Fish"
	imageLabel.Size = UDim2.new(0.22, 0, 0.16, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 2
	local v35 = math.random(40, 85) / 100
	local endlessFish = getEndlessFish() -- equivalent call inferred; original call site unknown
	local v36 = (v34 and 4.5 or 5) * (endlessFish <= 0 and 1 or math.max(0.5, 1 - endlessFish * 0.008))
	local uDim, uDim2

	if math.random() > 0.5 then
		imageLabel.Image = v34 and "rbxassetid://130696867239648" or "rbxassetid://111167099921967"
		uDim = UDim2.new(1.05, 0, v35, 0)
		uDim2 = UDim2.new(-0.2, 0, v35, 0)
	else
		imageLabel.Image = v34 and "rbxassetid://131069401551255" or "rbxassetid://72501180344546"
		uDim = UDim2.new(-0.2, 0, v35, 0)
		uDim2 = UDim2.new(1.05, 0, v35, 0)
	end

	imageLabel.Position = uDim
	imageLabel.Parent = parent
	local tween = TweenService:Create(imageLabel, TweenInfo.new(v36, Enum.EasingStyle.Linear), {
		Position = uDim2
	})
	tween:Play()
	local heartbeatConnection2 = nil
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if imageLabel.Parent and flag2 then
			local hookBelowIce = isHookBelowIce() -- equivalent call inferred; original call site unknown

			if hookBelowIce and checkCollision(imageLabel) and v6 and not (v9 or flag3 or flag4) then
				v8 = imageLabel
				v7 = v34 and "gray" or "orange"
				v6 = false
				tween:Cancel()
				heartbeatConnection2:Disconnect()

				if v10 then
					v10.Visible = false
				end

				imageLabel.Parent = parent2
				imageLabel.Size = UDim2.new(2, 0, 3, 0)
				imageLabel.Image = v34 and "rbxassetid://131069401551255" or "rbxassetid://72501180344546"
				imageLabel.Rotation = -90
				imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				parent2.ZIndex = parent2.ZIndex or 3
				imageLabel.ZIndex = math.max(1, parent2.ZIndex - 1)
				imageLabel.Position = UDim2.new(0.4, 0, 1.8, 0)
			end
		else
			heartbeatConnection2:Disconnect()
			v16[heartbeatConnection2] = nil
		end
	end)
	v16[heartbeatConnection2] = heartbeatConnection2
	tween.Completed:Connect(function()
		if imageLabel.Parent and v8 ~= imageLabel then
			imageLabel:Destroy()
		end

		if heartbeatConnection2 and heartbeatConnection2.Connected then
			heartbeatConnection2:Disconnect()
			v16[heartbeatConnection2] = nil
		end
	end)
end

local function spawnKicker(flag5: boolean?)
	local parent = v21

	if not (flag2 and parent) then
		return
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Kicker"
	imageLabel.BackgroundTransparency = 1
	local v33 = math.random(1, #v2)

	if v33 == 1 then
		imageLabel.Size = UDim2.new(0.2, 0, 0.2, 0)
	else
		imageLabel.Size = UDim2.new(0.14, 0, 0.14, 0)
	end

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = imageLabel
	imageLabel.ZIndex = 5
	local v34 = math.random(40, 85) / 100

	if flag5 == nil then
		flag5 = math.random() > 0.5
	end

	local uDim, uDim2

	if flag5 then
		imageLabel.Image = v3[v33]
		uDim = UDim2.new(1.05, 0, v34, 0)
		uDim2 = UDim2.new(-0.2, 0, v34, 0)
	else
		imageLabel.Image = v2[v33]
		uDim = UDim2.new(-0.2, 0, v34, 0)
		uDim2 = UDim2.new(1.05, 0, v34, 0)
	end

	imageLabel.Position = uDim
	imageLabel.Parent = parent
	local tween = TweenService:Create(imageLabel, TweenInfo.new(getSpeedMultiplier() * 5, Enum.EasingStyle.Linear), {
		Position = uDim2
	})
	tween:Play()
	local heartbeatConnection2 = nil
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if imageLabel.Parent and flag2 then
			local hookBelowIce = isHookBelowIce() -- equivalent call inferred; original call site unknown

			if hookBelowIce and checkCollision(imageLabel) and not v6 and v8 then
				fishFlees()
				heartbeatConnection2:Disconnect()
				v16[heartbeatConnection2] = nil
			end
		else
			heartbeatConnection2:Disconnect()
			v16[heartbeatConnection2] = nil
		end
	end)
	v16[heartbeatConnection2] = heartbeatConnection2
	tween.Completed:Connect(function()
		if imageLabel.Parent then
			imageLabel:Destroy()
		end

		if heartbeatConnection2 and heartbeatConnection2.Connected then
			heartbeatConnection2:Disconnect()
			v16[heartbeatConnection2] = nil
		end
	end)
end

local function spawnShark(flag5: boolean?)
	local parent = v21

	if not (flag2 and parent) then
		return
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Shark"
	imageLabel.Size = UDim2.new(0.55, 0, 0.3, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Image = "rbxassetid://120420739190917"
	imageLabel.ZIndex = 5
	local v33 = math.random(40, 80) / 100
	local uDim, uDim2

	if flag5 == true then
		imageLabel.Image = "rbxassetid://134748845792917"
		uDim = UDim2.new(1.1, 0, v33, 0)
		uDim2 = UDim2.new(-0.5, 0, v33, 0)
	else
		imageLabel.Image = "rbxassetid://120420739190917"
		uDim = UDim2.new(-0.5, 0, v33, 0)
		uDim2 = UDim2.new(1.1, 0, v33, 0)
	end

	imageLabel.Position = uDim
	imageLabel.Parent = parent
	local tween = TweenService:Create(imageLabel, TweenInfo.new(getSpeedMultiplier() * 3, Enum.EasingStyle.Linear), {
		Position = uDim2
	})
	tween:Play()
	local v34 = false
	local heartbeatConnection2 = nil
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if imageLabel.Parent and flag2 then
			if not (v34 or flag3 or flag4) then
				local hookBelowIce = isHookBelowIce() -- equivalent call inferred; original call site unknown

				if hookBelowIce and checkCollision(imageLabel) then
					v34 = true
					cutLine()
					heartbeatConnection2:Disconnect()
					v16[heartbeatConnection2] = nil
				end
			end
		else
			heartbeatConnection2:Disconnect()
			v16[heartbeatConnection2] = nil
		end
	end)
	v16[heartbeatConnection2] = heartbeatConnection2
	tween.Completed:Connect(function()
		if imageLabel.Parent then
			imageLabel:Destroy()
		end

		if heartbeatConnection2 and heartbeatConnection2.Connected then
			heartbeatConnection2:Disconnect()
			v16[heartbeatConnection2] = nil
		end
	end)
end

local function spawnJellyfish(flag5: boolean?)
	local parent = v21

	if not (flag2 and parent and v22) then
		return
	end

	if flag5 == nil then
		flag5 = false
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Jellyfish"
	imageLabel.Size = UDim2.new(0.1, 0, 0.15, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Image = flag5 and "rbxassetid://88015132675226" or "rbxassetid://91941168211721"
	imageLabel.ZIndex = 6
	local v34 = math.random(40, 85) / 100
	local uDim, uDim2

	if flag5 then
		uDim = UDim2.new(1.05, 0, v34, 0)
		uDim2 = UDim2.new(-0.1, 0, v34, 0)
	else
		uDim = UDim2.new(-0.1, 0, v34, 0)
		uDim2 = UDim2.new(1.05, 0, v34, 0)
	end

	imageLabel.Position = uDim
	imageLabel.Parent = parent
	local lastTime = tick()
	local v35 = getSpeedMultiplier() * 4
	local v36 = false
	local heartbeatConnection2 = nil
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if imageLabel.Parent and flag2 then
			local v37 = tick() - lastTime
			local v38 = math.min(v37 / v35, 1)
			local v39 = uDim.X.Scale + (uDim2.X.Scale - uDim.X.Scale) * v38
			local v40 = uDim.X.Offset + (uDim2.X.Offset - uDim.X.Offset) * v38
			local v41 = math.sin(v37 * 4) * 0.035
			imageLabel.Position = UDim2.new(v39, v40, v34 + v41, 0)

			if v38 >= 1 then
				heartbeatConnection2:Disconnect()
				v16[heartbeatConnection2] = nil

				if imageLabel.Parent then
					imageLabel:Destroy()
				end
			elseif not (v36 or flag3 or flag4) then
				local hookBelowIce = isHookBelowIce() -- equivalent call inferred; original call site unknown

				if hookBelowIce and (checkCollision(imageLabel) or checkLineCollision(imageLabel)) then
					v36 = true
					shockLine()
				end
			end
		else
			heartbeatConnection2:Disconnect()
			v16[heartbeatConnection2] = nil
		end
	end)
	v16[heartbeatConnection2] = heartbeatConnection2
end

local function spawn1Up()
	local parent = v21

	if not flag2 or not parent or v5 >= 5 then
		return
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "OneUp"
	imageLabel.Size = UDim2.new(0.06, 0, 0.06, 0)
	imageLabel.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
	imageLabel.BackgroundTransparency = 0.3
	imageLabel.Image = "rbxassetid://74583108514843"
	imageLabel.ZIndex = 7
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = imageLabel
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = imageLabel
	local v33 = math.random(35, 75) / 100
	local uDim = UDim2.new(-0.1, 0, v33, 0)
	local uDim2 = UDim2.new(1.1, 0, v33, 0)
	imageLabel.Position = uDim
	imageLabel.Parent = parent
	local tween = TweenService:Create(imageLabel, TweenInfo.new(5, Enum.EasingStyle.Linear), {
		Position = uDim2
	})
	tween:Play()
	local v34 = false
	local heartbeatConnection2 = nil
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if imageLabel.Parent and flag2 then
			if not v34 then
				local hookBelowIce = isHookBelowIce() -- equivalent call inferred; original call site unknown

				if hookBelowIce and checkCollision(imageLabel) and not flag3 then
					v34 = true

					if v5 < 5 then
						v5 += 1
						updateLivesLabel() -- equivalent call inferred; original call site unknown
					end

					local textLabel = Instance.new("TextLabel")
					textLabel.Size = UDim2.new(0.3, 0, 0.06, 0)
					textLabel.Position = UDim2.new(0.35, 0, 0.45, 0)
					textLabel.BackgroundTransparency = 1
					textLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
					textLabel.Font = Enum.Font.GothamBold
					textLabel.TextScaled = true
					textLabel.ZIndex = 25
					textLabel.Text = "+1 LIFE!"
					textLabel.Parent = parent
					Debris:AddItem(textLabel, 1.5)
					TweenService:Create(imageLabel, TweenInfo.new(0.3), {
						ImageTransparency = 1,
						BackgroundTransparency = 1
					}):Play()
					Debris:AddItem(imageLabel, 0.3)
					heartbeatConnection2:Disconnect()
					v16[heartbeatConnection2] = nil
				end
			end
		else
			heartbeatConnection2:Disconnect()
			v16[heartbeatConnection2] = nil
		end
	end)
	v16[heartbeatConnection2] = heartbeatConnection2
	tween.Completed:Connect(function()
		if imageLabel.Parent then
			imageLabel:Destroy()
		end

		if heartbeatConnection2 and heartbeatConnection2.Connected then
			heartbeatConnection2:Disconnect()
			v16[heartbeatConnection2] = nil
		end
	end)
end

local function spawnByIndex(p: number)
	if p <= 7 then
		spawnFish(false)
	elseif p == 8 then
		spawn1Up()
	elseif p == 9 then
		spawnJellyfish(false)
	elseif p == 10 then
		spawnJellyfish(true)
	elseif p == 11 then
		spawnShark(false)
	elseif p == 12 then
		spawnShark(true)
	elseif p == 13 then
		spawnKicker(false)
	elseif p == 14 then
		spawnKicker(true)
	elseif p == 15 then
		spawnKicker(false)
	elseif p == 16 then
		spawnKicker(true)
	elseif p >= 17 then
		spawnFish(true)
	end
end

local v32 = {
	{
		{ 100, 0 }
	},
	{
		{ 1400, 1 }
	},
	{
		{ 100, 2 }
	},
	{
		{ 200, 3 }
	},
	{
		{ 100, 4 }
	},
	{
		{ 1400, 5 }
	},
	{
		{ 200, 6 }
	},
	{
		{ 100, 0 },
		{ 600, 1 },
		{ 1200, 2 }
	},
	{
		{ 100, 3 },
		{ 900, 17 }
	},
	{
		{ 100, 0 },
		{ 800, 4 },
		{ 1300, 5 },
		{ 2000, 15 }
	},
	{
		{ 1400, 6 },
		{ 1700, 7 }
	},
	{
		{ 100, 0 },
		{ 500, 16 }
	},
	{
		{ 100, 1 },
		{ 700, 18 },
		{ 1400, 2 }
	},
	{
		{ 200, 3 },
		{ 800, 4 },
		{ 1400, 5 },
		{ 2100, 6 }
	},
	{
		{ 100, 17 }
	},
	{
		{ 100, 0 },
		{ 400, 1 },
		{ 1200, 16 },
		{ 1700, 2 }
	},
	{
		{ 100, 9 }
	},
	{
		{ 100, 10 }
	},
	{
		{ 100, 9 },
		{ 400, 3 },
		{ 1500, 10 }
	},
	{
		{ 200, 0 },
		{ 1100, 18 },
		{ 2400, 9 }
	},
	{
		{ 100, 11 }
	},
	{
		{ 100, 12 }
	},
	{
		{ 200, 11 },
		{ 400, 6 },
		{ 1300, 9 }
	},
	{
		{ 900, 12 },
		{ 1000, 15 },
		{ 1900, 2 }
	},
	{
		{ 100, 10 },
		{ 2000, 11 }
	},
	{
		{ 100, 15 },
		{ 500, 11 },
		{ 900, 7 }
	},
	{
		{ 100, 6 },
		{ 900, 12 }
	},
	{
		{ 200, 0 },
		{ 900, 12 },
		{ 1900, 9 }
	},
	{
		{ 600, 9 },
		{ 1200, 17 }
	},
	{
		{ 500, 2 },
		{ 1200, 16 },
		{ 1700, 12 }
	},
	{
		{ 400, 13 }
	},
	{
		{ 400, 14 }
	},
	{
		{ 100, 13 },
		{ 1900, 14 }
	},
	{
		{ 400, 13 },
		{ 800, 1 },
		{ 1600, 9 }
	},
	{
		{ 700, 14 },
		{ 800, 5 },
		{ 1600, 12 },
		{ 2400, 19 }
	},
	{
		{ 200, 9 },
		{ 1600, 10 },
		{ 1700, 3 }
	},
	{
		{ 600, 8 },
		{ 1200, 10 },
		{ 1900, 14 }
	},
	{
		{ 100, 8 },
		{ 200, 18 },
		{ 900, 4 },
		{ 2200, 14 }
	},
	{
		{ 1000, 7 },
		{ 1200, 15 }
	},
	{
		{ 300, 17 },
		{ 1400, 13 },
		{ 2800, 1 }
	}
}

local function chooseGroup()
	local v33 = math.min(v4, count)

	if v33 <= 1 then
		return math.random(1, 10)
	end

	if v33 == 2 then
		return math.random(1, 20)
	elseif v33 == 3 then
		return math.random(1, 30)
	end

	local v34 = math.min(31, math.floor(math.max(0, count3 - 54) / 5) + 11)
	return math.random(v34, 40)
end

local function spawnWave()
	if not flag2 or v11 then
		return
	end

	local v34 = v32[chooseGroup()]

	if not v34 then
		return
	end

	local v35 = count6

	for _, v36 in ipairs(v34) do
		local v37 = v36[1]
		local v39 = v36[2]
		task.delay(v37 / 1000, function()
			if flag2 and count6 == v35 and not v11 then
				spawnByIndex(v39)
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startSpawnLoop()
	local v33 = count6
	table.clear(threads)
	table.insert(threads, task.spawn(function()
		task.wait(1.5)

		while flag2 and v33 == count6 do
			spawnWave()
			local v34 = 4 - (math.min(v4, count) - 1) * 0.5
			local endlessFish = getEndlessFish() -- equivalent call inferred; original call site unknown

			if endlessFish > 0 then
				v34 -= endlessFish * 0.015
			end

			task.wait((math.max(0.8, v34)))
		end
	end))
end

local IceFischArcade = {
	init = function()
		task.spawn(function()
			local v33 = {
				"rbxassetid://72501180344546",
				"rbxassetid://111167099921967",
				"rbxassetid://131069401551255",
				"rbxassetid://130696867239648",
				"rbxassetid://74583108514843",
				"rbxassetid://120420739190917",
				"rbxassetid://134748845792917",
				"rbxassetid://91941168211721",
				"rbxassetid://88015132675226",
				"rbxassetid://74583108514843"
			}

			for _, v34 in v2 do
				table.insert(v33, v34)
			end

			for _, v34 in v3 do
				table.insert(v33, v34)
			end

			local v34 = {}

			for _, image in v33 do
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Image = image
				table.insert(v34, imageLabel)
			end

			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://137998965071998"
			ContentProvider:PreloadAsync(v34)
			ContentProvider:PreloadAsync({ sound })

			for _, v35 in v34 do
				v35:Destroy()
			end

			sound:Destroy()
		end)
	end,
	isOpen = function()
		return flag
	end,
	open = function(instance)
		if flag then
			return
		end

		flag = true
		local iceFischArcade = instance:FindFirstChild("IceFischArcade")

		if iceFischArcade then
			local playerGui = localPlayer:FindFirstChild("PlayerGui")

			if not playerGui then
				flag = false
				return
			end

			local clone = iceFischArcade:Clone()
			clone.Name = "IceFischArcade"
			clone.Enabled = true
			clone.ResetOnSpawn = false
			local gameLogic = clone:FindFirstChild("GameLogic")

			if gameLogic then
				gameLogic:Destroy()
			end

			for _, sound in clone:GetDescendants() do
				if sound:IsA("Sound") then
					sound:Destroy()
				end
			end

			clone.Parent = playerGui
			v18 = clone
			local menu = clone:WaitForChild("Menu")
			local fischGame = clone:WaitForChild("FischGame")

			for _, parent in { menu, fischGame } do
				if parent:FindFirstChildOfClass("UIAspectRatioConstraint") then
					continue
				end

				local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uIAspectRatioConstraint.AspectRatio = 1.7777777777777777
				uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
				uIAspectRatioConstraint.Parent = parent
			end

			v19 = menu
			v20 = fischGame
			v21 = fischGame
			local fishingLine = fischGame:WaitForChild("FishingLine")
			local hook = fischGame:WaitForChild("Hook")
			local exitButton = fischGame:WaitForChild("ExitButton")
			local exitButton2 = menu:WaitForChild("ExitButton")
			local playButton = menu:WaitForChild("PlayButton")
			local scoreLabel = fischGame:WaitForChild("ScoreLabel")
			local livesLabel = fischGame:WaitForChild("LivesLabel")
			v22 = fishingLine
			v23 = hook
			v24 = exitButton
			v25 = exitButton2
			v26 = playButton
			v27 = scoreLabel
			v28 = livesLabel
			flag2 = false
			v4 = 1
			count2 = 0
			count3 = 0
			count4 = 0
			count5 = 0
			total = 0
			v5 = 3
			v6 = true
			v8 = nil
			v7 = nil
			v9 = false
			flag3 = false
			flag4 = false
			v10 = nil
			v11 = false
			v12 = 0.5
			v13 = false
			position = nil
			count6 += 1
			menu.Visible = true
			fischGame.Visible = false
			lockMovement() -- equivalent call inferred; original call site unknown
			lockCamera() -- equivalent call inferred; original call site unknown
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://137998965071998"
			sound.Volume = 0.4
			sound.Looped = false
			sound.TimePosition = 35
			sound.Parent = clone
			sound:Play()
			v31 = sound
			sound.Ended:Connect(function()
				if sound.Parent then
					sound.TimePosition = 35
					sound:Play()
				end
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function addConn(p)
				table.insert(v17, p)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setGamepadSelection(selectedObject)
				if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
					GuiService.SelectedObject = selectedObject
				end
			end

			addConn(RunService.RenderStepped:Connect(function()
				if not (flag2 and fischGame.Visible) then
					return
				end

				if flag3 then
					hook.Visible = false
					fishingLine.Visible = false
				else
					local v33 = nil
					local success, result = pcall(function()
						return UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
					end)
					local v34 = false

					if success and result then
						for _, v36 in pairs(result) do
							if not ((v36.KeyCode == Enum.KeyCode.Thumbstick1 or v36.KeyCode == Enum.KeyCode.Thumbstick2) and math.abs(v36.Position.Y) > 0.1) then
								continue
							end

							v34 = true
							v13 = true
							v12 = math.clamp(v12 - v36.Position.Y * 0.035, 0, 1)
							v33 = v12 * fischGame.AbsoluteSize.Y
							break
						end
					end

					if not v34 and v14 ~= 0 then
						v34 = true
						v13 = true
						v12 = math.clamp(v12 + v14 * 0.02, 0, 1)
						v33 = v12 * fischGame.AbsoluteSize.Y
					end

					if not v34 and v15 then
						v33 = v12 * fischGame.AbsoluteSize.Y
						v34 = true
					end

					if not v34 then
						v13 = false
						local v35

						if position then
							v35 = position.Y
						else
							v35 = UserInputService:GetMouseLocation().Y
						end

						v33 = v35 - fischGame.AbsolutePosition.Y
						v12 = math.clamp(v33 / fischGame.AbsoluteSize.Y, 0, 1)
					end

					local v35 = fischGame.AbsoluteSize.Y * 0.02
					local v36 = math.clamp(v33, v35, fischGame.AbsoluteSize.Y * 0.92)
					hook.Position = UDim2.new(0.496, 0, 0, v36)
					fishingLine.Position = UDim2.new(0.505, 0, 0.02, 0)
					local v37 = math.max(0, v36 - v35)
					fishingLine.Size = UDim2.new(0, 2, 0, v37)
					fishingLine.Visible = v37 > 0
					fishingLine.BackgroundTransparency = 0

					if not flag4 then
						fishingLine.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					end

					fishingLine.BorderSizePixel = 0
					fishingLine.ZIndex = 5
				end
			end)) -- equivalent call inferred; original call site unknown
			addConn(UserInputService.TouchMoved:Connect(function(p, _)
				if flag2 then
					position = p.Position
				end
			end)) -- equivalent call inferred; original call site unknown
			addConn(UserInputService.InputBegan:Connect(function(input, _)
				if flag2 and input.UserInputType == Enum.UserInputType.Touch then
					position = input.Position
				end
			end)) -- equivalent call inferred; original call site unknown
			addConn(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch then
					position = nil
				end
			end)) -- equivalent call inferred; original call site unknown
			local onActivated
			addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if input.KeyCode == Enum.KeyCode.DPadUp then
					v14 = -1
				elseif input.KeyCode == Enum.KeyCode.DPadDown then
					v14 = 1
				elseif input.KeyCode == Enum.KeyCode.ButtonB then
					if flag2 then
						onActivated()
					else
						fn()
					end
				else
					if gameProcessed or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch and input.KeyCode ~= Enum.KeyCode.ButtonA and input.KeyCode ~= Enum.KeyCode.ButtonX or not flag2) then
						return
					end

					local v33 = hook.Position.Y.Offset / fischGame.AbsoluteSize.Y

					if v6 or not v8 then
						if not v9 then
							return
						end

						if v33 <= 0.25 or flag3 then
							if not v9 then
								return
							end

							if v5 <= 0 then
								fn2()
								return
							end

							v5 -= 1
							updateLivesLabel() -- equivalent call inferred; original call site unknown
							v9 = false
							flag3 = false
							hideNeedWormPrompt() -- equivalent call inferred; original call site unknown
							local v34 = v23

							if v34 then
								v34.Visible = true
							end

							local v35 = v22

							if v35 then
								v35.Visible = true
							end

							v6 = true
							v8 = nil
							v7 = nil
							createWorm()
						end
					elseif v33 <= 0.25 then
						depositFish() -- equivalent call inferred; original call site unknown
						checkLevelUp() -- equivalent call inferred; original call site unknown
					else
						fishFlees()
					end
				end
			end)) -- equivalent call inferred; original call site unknown
			addConn(UserInputService.InputEnded:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.DPadUp and v14 == -1 then
					v14 = 0
				elseif input.KeyCode == Enum.KeyCode.DPadDown and v14 == 1 then
					v14 = 0
				end
			end)) -- equivalent call inferred; original call site unknown
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				addConn(humanoid.Died:Connect(function()
					fn()
				end)) -- equivalent call inferred; original call site unknown
			end

			addConn(localPlayer.CharacterAdded:Connect(function()
				fn()
			end)) -- equivalent call inferred; original call site unknown
			addConn(playButton.Activated:Connect(function()
				GuiService.SelectedObject = nil
				menu.Visible = false
				fischGame.Visible = true
				count6 += 1
				Net:RemoteEvent("IceFischArcade_GameStart"):FireServer()
				flag2 = true
				v4 = 1
				count2 = 0
				count3 = 0
				count4 = 0
				count5 = 0
				total = 0
				v5 = 3
				v6 = true
				v8 = nil
				v7 = nil
				v9 = false
				flag3 = false
				flag4 = false
				v11 = false
				v12 = 0.5
				v13 = false
				position = nil
				updateScoreLabel() -- equivalent call inferred; original call site unknown
				updateLivesLabel() -- equivalent call inferred; original call site unknown
				fischGame.ClipsDescendants = true
				hook.Visible = true
				fishingLine.Visible = true
				createWorm()
				startSpawnLoop() -- equivalent call inferred; original call site unknown
			end)) -- equivalent call inferred; original call site unknown

			onActivated = function()
				if not flag2 then
					return
				end

				flag2 = false
				cleanupGameConnections()
				count6 += 1

				if v8 then
					v8:Destroy()
					v8 = nil
				end

				fishingLine.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				flag4 = false
				v6 = true
				v7 = nil
				v9 = false
				flag3 = false
				v4 = 1
				count2 = 0
				total = 0
				v5 = 3
				count4 = 0
				count5 = 0
				count3 = 0
				v11 = false
				v12 = 0.5
				v13 = false
				position = nil
				hook.Visible = true
				fishingLine.Visible = true
				menu.Visible = true
				fischGame.Visible = false
				setGamepadSelection(playButton) -- equivalent call inferred; original call site unknown
			end

			addConn(exitButton.Activated:Connect(onActivated)) -- equivalent call inferred; original call site unknown
			addConn(exitButton2.Activated:Connect(function()
				fn()
			end)) -- equivalent call inferred; original call site unknown
			local instructionsFrame = menu:FindFirstChild("InstructionsFrame")
			local v33 = nil

			for _, button in menu:GetChildren() do
				if not button:IsA("TextButton") then
					continue
				end

				local name = button.Name:lower()

				if not (name:find("instruct") or name:find("howto") or name:find("how_to")) then
					continue
				end

				v33 = button
				break
			end

			if instructionsFrame and v33 then
				local backButton = instructionsFrame:FindFirstChild("BackButton")
				addConn(v33.Activated:Connect(function()
					instructionsFrame.Visible = true

					if backButton then
						setGamepadSelection(backButton) -- equivalent call inferred; original call site unknown
					end
				end)) -- equivalent call inferred; original call site unknown

				if backButton then
					addConn(backButton.Activated:Connect(function()
						instructionsFrame.Visible = false
						setGamepadSelection(playButton) -- equivalent call inferred; original call site unknown
					end)) -- equivalent call inferred; original call site unknown
				end
			elseif instructionsFrame and not v33 then
				warn(
					"[IceFischArcade] InstructionsFrame found but no instructions button. Menu children:",
					menu:GetChildren()
				)
			end

			local leaderboardFrame = menu:FindFirstChild("LeaderboardFrame")
			local v35 = nil

			for _, button in menu:GetChildren() do
				if not button:IsA("TextButton") then
					continue
				end

				local name = button.Name:lower()

				if not (name:find("highscore") or name:find("high_score") or name:find("leaderboard")) then
					continue
				end

				v35 = button
				break
			end

			if leaderboardFrame and v35 then
				local entries = leaderboardFrame:FindFirstChild("Entries")
				local backButton = leaderboardFrame:FindFirstChild("BackButton")

				fn3 = function()
					if not entries then
						return
					end

					for _, label in entries:GetChildren() do
						if label:IsA("TextLabel") and label.Name ~= "Loading" then
							label:Destroy()
						end
					end

					local loading = entries:FindFirstChild("Loading")

					if loading then
						loading.Visible = true
						loading.Text = "Loading..."
					end

					leaderboardFrame.Visible = true
					local success, result = pcall(function()
						return Net:Invoke("IceFischArcade_GetLeaderboard")
					end)

					if loading then
						loading.Visible = false
					end

					if success and result and #result ~= 0 then
						for i, v37 in ipairs(result) do
							local textLabel = Instance.new("TextLabel")
							textLabel.Name = "Entry_" .. i
							textLabel.Size = UDim2.new(1, 0, 0, 28)
							textLabel.LayoutOrder = i
							local backgroundColor

							if i % 2 == 0 then
								backgroundColor = Color3.fromRGB(30, 50, 100)
							else
								backgroundColor = Color3.fromRGB(25, 45, 90)
							end

							textLabel.BackgroundColor3 = backgroundColor
							textLabel.BackgroundTransparency = 0.3
							textLabel.Font = Enum.Font.GothamBold
							textLabel.TextScaled = true
							textLabel.ZIndex = leaderboardFrame.ZIndex + 2

							if i == 1 then
								textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
							elseif i == 2 then
								textLabel.TextColor3 = Color3.fromRGB(192, 192, 192)
							elseif i == 3 then
								textLabel.TextColor3 = Color3.fromRGB(205, 127, 50)
							else
								textLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
							end

							textLabel.Text = "  #" .. i .. "  " .. (v37.displayName or "Player") .. "  —  " .. (v37.score or 0) .. " pts"
							textLabel.TextXAlignment = Enum.TextXAlignment.Left
							textLabel.Parent = entries
							local uICorner = Instance.new("UICorner")
							uICorner.CornerRadius = UDim.new(0.15, 0)
							uICorner.Parent = textLabel
						end
					elseif loading then
						loading.Visible = true
						loading.Text = "No scores yet!"
					end
				end

				fn4 = function()
					leaderboardFrame.Visible = false
				end

				if backButton then
					addConn(backButton.Activated:Connect(function()
						fn4()
						setGamepadSelection(playButton) -- equivalent call inferred; original call site unknown
					end)) -- equivalent call inferred; original call site unknown
				end

				addConn(v35.Activated:Connect(function()
					fn3()

					if backButton then
						setGamepadSelection(backButton) -- equivalent call inferred; original call site unknown
					end
				end)) -- equivalent call inferred; original call site unknown
			elseif v35 and not leaderboardFrame then
				warn("[IceFischArcade] HighScoresButton found but no LeaderboardFrame. Run GenerateIceFischLeaderboard in Studio.")
			end

			setGamepadSelection(playButton) -- equivalent call inferred; original call site unknown
		else
			warn("[IceFischArcade] No IceFischArcade ScreenGui found on arcade model")
			flag = false
		end
	end
}

fn2 = function()
	flag2 = false
	cleanupGameConnections()
	Net:RemoteEvent("IceFischArcade_GameOver"):FireServer(total)
	local parent = v21

	if parent then
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(0.6, 0, 0.12, 0)
		textLabel.Position = UDim2.new(0.2, 0, 0.3, 0)
		textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.BackgroundTransparency = 0.3
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextScaled = true
		textLabel.ZIndex = 30
		textLabel.Text = "GAME OVER"
		textLabel.Parent = parent
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0.15, 0)
		uICorner.Parent = textLabel
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Size = UDim2.new(0.7, 0, 0.07, 0)
		textLabel2.Position = UDim2.new(0.15, 0, 0.43, 0)
		textLabel2.BackgroundTransparency = 1
		textLabel2.TextColor3 = Color3.fromRGB(220, 220, 220)
		textLabel2.Font = Enum.Font.Gotham
		textLabel2.TextScaled = true
		textLabel2.ZIndex = 30
		local v34 = count4 .. " fish x4 = " .. count4 * 4

		if count5 > 0 then
			v34 ..= "  |  " .. count5 .. " gray x8 = " .. count5 * 8
		end

		textLabel2.Text = v34 .. "  |  TOTAL: " .. total
		textLabel2.Parent = parent
		Debris:AddItem(textLabel, 4)
		Debris:AddItem(textLabel2, 4)
	end

	task.wait(4)
	local v34 = v19
	local v35 = v20

	if v34 and v35 then
		v34.Visible = true
		v35.Visible = false
	end
end

fn = function()
	if not flag then
		return
	end

	flag2 = false
	cleanupGameConnections()
	unlockMovement() -- equivalent call inferred; original call site unknown
	unlockCamera() -- equivalent call inferred; original call site unknown

	for _, connection in ipairs(v17) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end

	table.clear(v17)

	if v8 then
		v8:Destroy()
		v8 = nil
	end

	local v33 = v18

	if v33 then
		v33:Destroy()
		v18 = nil
	end

	if v31 then
		v31:Stop()
		v31:Destroy()
		v31 = nil
	end

	GuiService.SelectedObject = nil
	v19 = nil
	v20 = nil
	v21 = nil
	v22 = nil
	v23 = nil
	v24 = nil
	v25 = nil
	v26 = nil
	v27 = nil
	v28 = nil
	v10 = nil
	v29 = nil
	v30 = nil
	flag = false
end

IceFischArcade.close = fn
local v33 = {
	Shark = true,
	Jellyfish = true,
	Kicker = true
}
local _ = {
	Fish = true,
	GrayFish = true
}
local v34 = {
	OneUp = 4,
	GrayFish = 3,
	Fish = 2,
	Worm = 1
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getHookYFraction()
	local v35 = v23
	local v36 = v21

	if v35 and v36 and v36.AbsoluteSize.Y ~= 0 then
		return v35.Position.Y.Offset / v36.AbsoluteSize.Y
	end

	return 0.5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEntityYFraction(p)
	local v35 = v21

	if v35 and v35.AbsoluteSize.Y ~= 0 then
		return (p.AbsolutePosition.Y + p.AbsoluteSize.Y * 0.5 - v35.AbsolutePosition.Y) / v35.AbsoluteSize.Y
	end

	return 0.5
end

local function getEntityXFraction(p)
	local v35 = v21

	if v35 and v35.AbsoluteSize.X ~= 0 then
		return (p.AbsolutePosition.X + p.AbsoluteSize.X * 0.5 - v35.AbsolutePosition.X) / v35.AbsoluteSize.X
	end

	return 0.5
end

local function isNearHookX(p, p2: number)
	local v35 = v21
	return math.abs(((not v35 or v35.AbsoluteSize.X == 0) and 0.5 or (p.AbsolutePosition.X + p.AbsoluteSize.X * 0.5 - v35.AbsolutePosition.X) / v35.AbsoluteSize.X) - 0.496) < p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startAutoplay()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not (flag2 and v21 and v23) then
			return
		end

		local v35 = v21
		local hookYFraction = getHookYFraction() -- equivalent call inferred; original call site unknown

		if v9 or flag3 then
			if hookYFraction > 0.27 then
				v12 = math.max(0, v12 - 0.045)
				return
			end

			if not v9 then
				return
			end

			if v5 <= 0 then
				fn2()
				return
			end

			v5 -= 1
			updateLivesLabel() -- equivalent call inferred; original call site unknown
			v9 = false
			flag3 = false
			hideNeedWormPrompt() -- equivalent call inferred; original call site unknown
			local v36 = v23

			if v36 then
				v36.Visible = true
			end

			local v37 = v22

			if v37 then
				v37.Visible = true
			end

			v6 = true
			v8 = nil
			v7 = nil
			createWorm()
		elseif v6 or not v8 then
			local v36 = 0
			local v37 = 1e999
			local v38 = false
			local v39 = false
			local v40 = nil
			local v41 = nil

			for _, guiObject in v35:GetChildren() do
				if not (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
					continue
				end

				local name = guiObject.Name

				if v33[name] then
					if name == "Jellyfish" then
						local v42 = v21

						if math.abs(((not v42 or v42.AbsoluteSize.X == 0) and 0.5 or (guiObject.AbsolutePosition.X + guiObject.AbsoluteSize.X * 0.5 - v42.AbsolutePosition.X) / v42.AbsoluteSize.X) - 0.496) < 0.22 then
							v38 = true
						end
					else
						local v42 = v21

						if math.abs(((not v42 or v42.AbsoluteSize.X == 0) and 0.5 or (guiObject.AbsolutePosition.X + guiObject.AbsoluteSize.X * 0.5 - v42.AbsolutePosition.X) / v42.AbsoluteSize.X) - 0.496) < 0.18 then
							local entityYFraction = getEntityYFraction(guiObject) -- equivalent call inferred; original call site unknown

							if math.abs(entityYFraction - hookYFraction) < 0.25 then
								v40 = entityYFraction
								v39 = true
							end
						end
					end
				else
					local v42 = v34[name]

					if v42 then
						local v43 = v21

						if math.abs(((not v43 or v43.AbsoluteSize.X == 0) and 0.5 or (guiObject.AbsolutePosition.X + guiObject.AbsoluteSize.X * 0.5 - v43.AbsolutePosition.X) / v43.AbsoluteSize.X) - 0.496) < 0.25 then
							local v44 = math.abs(getEntityYFraction(guiObject) - hookYFraction)

							if v36 < v42 or v42 == v36 and v44 < v37 then
								v41 = guiObject
								v37 = v44
								v36 = v42
							end
						end
					end
				end
			end

			if v38 and hookYFraction > 0.23 then
				v12 = math.max(0, v12 - 0.09)
			elseif v39 and v40 then
				if hookYFraction <= v40 then
					v12 = math.max(0, v12 - 0.0675)
				else
					v12 = math.min(1, v12 + 0.0675)
				end
			elseif v41 then
				local v42 = getEntityYFraction(v41) - hookYFraction

				if math.abs(v42) < 0.02 then
					return
				end

				if v42 > 0 then
					v12 = math.min(1, v12 + 0.045)
				else
					v12 = math.max(0, v12 - 0.045)
				end
			else
				local v42 = 0.55 - hookYFraction

				if math.abs(v42) > 0.03 then
					if v42 > 0 then
						v12 = math.min(1, v12 + 0.0225)
					else
						v12 = math.max(0, v12 - 0.0225)
					end
				end
			end
		else
			if hookYFraction > 0.27 then
				v12 = math.max(0, v12 - 0.045)
				return
			end

			depositFish() -- equivalent call inferred; original call site unknown
			checkLevelUp() -- equivalent call inferred; original call site unknown
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopAutoplay()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.P and localPlayer.UserId == 2971021 then
		v15 = not v15

		if v15 then
			v13 = true
			startAutoplay() -- equivalent call inferred; original call site unknown
			print("[IceFischArcade] Autoplay ON")
		else
			stopAutoplay() -- equivalent call inferred; original call site unknown
			print("[IceFischArcade] Autoplay OFF")
		end
	end
end)
return IceFischArcade