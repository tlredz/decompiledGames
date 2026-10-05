local createVector = vector.create
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local modules = ReplicatedStorage:WaitForChild("Modules")
local PingConfig = require(modules:WaitForChild("Services"):WaitForChild("PingConfig"))
local PingMarkerController = require(modules:WaitForChild("ClientUI"):WaitForChild("PingMarkerController"))
require(modules:WaitForChild("Core"):WaitForChild("PendingUpdates"))
local spr = require(modules:WaitForChild("Utils"):WaitForChild("spr"))
local InputService = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("InputService"))
local now = 0
local v = true
local v2 = 0
local thread = nil
local flag = false
local now2 = 0
local v3 = nil
local renderSteppedConnection = nil
local pingType = nil
local v4 = nil
local v5 = 0
local v6 = {
	up = 1,
	upright = 2,
	downright = 3,
	down = 4,
	downleft = 5,
	upleft = 6
}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetEvents()
	return ReplicatedStorage:FindFirstChild("Events")
end

local function IsInMatch()
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if not inGamePlayers then
		return false
	end

	local character = localPlayer.Character

	if not (character and inGamePlayers:FindFirstChild(character.Name)) then
		return false
	end

	local info = workspace:FindFirstChild("Info")

	if not info then
		return false
	end

	local floorActive = info:FindFirstChild("FloorActive")

	if floorActive then
		return floorActive.Value == true
	end

	return false
end

local function IsDev()
	local admin = ReplicatedStorage:FindFirstChild("Admin")
	return admin ~= nil and admin:FindFirstChild("DevFrame") ~= nil
end

local function GetCooldown()
	local admin = ReplicatedStorage:FindFirstChild("Admin")
	local v7

	if admin == nil then
		v7 = false
	else
		v7 = admin:FindFirstChild("DevFrame") ~= nil
	end

	if v7 then
		return PingConfig.DEV_COOLDOWN
	end

	return PingConfig.COOLDOWN
end

local function CanPing()
	if not (v and IsInMatch()) then
		return false
	end

	local v7 = tick() - now
	local admin = ReplicatedStorage:FindFirstChild("Admin")
	local v8

	if admin == nil then
		v8 = false
	else
		v8 = admin:FindFirstChild("DevFrame") ~= nil
	end

	local v9

	if v8 then
		v9 = PingConfig.DEV_COOLDOWN
	else
		v9 = PingConfig.COOLDOWN
	end

	return v9 <= v7
end

local function GetCooldownRemaining()
	local admin = ReplicatedStorage:FindFirstChild("Admin")
	local v7

	if admin == nil then
		v7 = false
	else
		v7 = admin:FindFirstChild("DevFrame") ~= nil
	end

	local v8

	if v7 then
		v8 = PingConfig.DEV_COOLDOWN
	else
		v8 = PingConfig.COOLDOWN
	end

	return (math.max(0, v8 - (tick() - now)))
end

local function DoShapecast()
	if not currentCamera then
		currentCamera = workspace.CurrentCamera
	end

	if not currentCamera then
		return nil
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local filterDescendantsInstances = {}

	if localPlayer.Character then
		table.insert(filterDescendantsInstances, localPlayer.Character)
	end

	local effects = workspace:FindFirstChild("Effects")

	if effects then
		table.insert(filterDescendantsInstances, effects)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	return (workspace:Spherecast(
		viewportPointToRay.Origin,
		PingConfig.CAST_RADIUS,
		viewportPointToRay.Direction * PingConfig.CAST_DISTANCE,
		raycastParams
	))
end

local function GetPingContext(p)
	if not p then
		return "Location", nil, nil
	end

	local instance = p.Instance

	if not instance then
		return "Location", nil, nil
	end

	local _ = p.Position
	local parent = instance.Parent
	local parent2 = parent and parent.Parent
	local monsters = workspace:FindFirstChild("Monsters")

	if monsters and (instance:IsDescendantOf(monsters) or parent and parent:IsDescendantOf(monsters)) then
		return "Twisted", instance, nil
	end

	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers and parent and parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") and inGamePlayers:FindFirstChild(parent.Name) then
		return "Teammate", parent, parent.Name
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function IsGenerator(p2)
		if not p2 then
			return false
		end

		local name = p2.Name:lower()
		return name:find("generator") ~= nil or name:find("machine") ~= nil
	end

	-- equivalent call inferred; original call site unknown
	if not IsGenerator(instance) then
		-- equivalent call inferred; original call site unknown
		if not IsGenerator(parent) then
			-- equivalent call inferred; original call site unknown
			if not IsGenerator(parent2) then
				-- equivalent calls inferred from this helper; original call sites unknown
				local function IsExit(p2)
					if not p2 then
						return false
					end

					local name = p2.Name:lower()
					return name:find("exit") ~= nil or name:find("elevator") ~= nil or name:find("door") ~= nil
				end

				-- equivalent call inferred; original call site unknown
				if IsExit(instance) then
					return "Exit", instance, nil
				end

				-- equivalent call inferred; original call site unknown
				if IsExit(parent) then
					return "Exit", instance, nil
				end

				if instance.Name == "Tape" or parent and parent.Name == "Tape" then
					return "Tape", instance.Name == "Tape" and instance or parent, nil
				end

				local function IsInItemsFolder(parent3)
					if not parent3 then
						return false
					end

					while parent3 and parent3 ~= workspace do
						if parent3.Name == "Items" then
							return true
						else
							parent3 = parent3.Parent
						end
					end

					return false
				end

				local v7

				if instance then
					local parent3 = instance

					while true do
						if not parent3 or parent3 == workspace then
							v7 = false
							break
						end

						if parent3.Name == "Items" then
							v7 = true
							break
						else
							parent3 = parent3.Parent
						end
					end
				else
					v7 = false
				end

				if not v7 then
					return "Location", nil, nil
				end

				if instance:IsA("BasePart") then
					if not parent:IsA("Model") then
						parent = instance
					end
				else
					parent = instance
				end

				return "Item", parent, parent.Name
			end
		end
	end

	-- equivalent call inferred; original call site unknown
	if not IsGenerator(parent) then
		parent = instance
	end

	-- equivalent call inferred; original call site unknown
	if IsGenerator(parent2) then
		parent = parent2
	end

	return "Generator", parent, nil
end

local v7 = {
	{
		type = "Location",
		label = "HERE",
		color = Color3.fromRGB(255, 255, 255)
	},
	{
		type = "Twisted",
		label = "DANGER!",
		color = Color3.fromRGB(255, 50, 50)
	},
	{
		type = "NeedHealing",
		label = "HEAL ME!",
		color = Color3.fromRGB(255, 100, 150)
	},
	{
		type = "Generator",
		label = "GENERATOR",
		color = Color3.fromRGB(255, 215, 0)
	},
	{
		type = "Item",
		label = "ITEM",
		color = Color3.fromRGB(144, 238, 144)
	},
	{
		type = "Exit",
		label = "EXIT",
		color = Color3.fromRGB(180, 100, 255)
	}
}

local function CreatePingWheel()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PingWheel"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 100
	local frame = Instance.new("Frame")
	frame.Name = "Center"
	frame.Size = UDim2.new(0, 380, 0, 380)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	local uIScale = Instance.new("UIScale")
	uIScale.Name = "MainScale"
	uIScale.Scale = 0
	uIScale.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "CenterCircle"
	frame2.Size = UDim2.new(0, 60, 0, 60)
	frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame2.BackgroundTransparency = 0.3
	frame2.Parent = frame
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = frame2
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Label"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "AUTO"
	textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	textLabel.TextSize = 12
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = frame2
	local v8 = #v7

	for i, v9 in ipairs(v7) do
		local v10 = (i - 1) * (6.283185307179586 / v8) - 1.5707963267948966
		local v11 = math.cos(v10) * 140
		local v12 = math.sin(v10) * 140
		local frame3 = Instance.new("Frame")
		frame3.Name = "Option_" .. v9.type
		frame3.Size = UDim2.new(0, 90, 0, 44)
		frame3.Position = UDim2.new(0.5, v11, 0.5, v12)
		frame3.AnchorPoint = Vector2.new(0.5, 0.5)
		frame3.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		frame3.BackgroundTransparency = 0.2
		frame3.BorderSizePixel = 0
		frame3.Rotation = 0
		frame3.Parent = frame
		local uIScale2 = Instance.new("UIScale")
		uIScale2.Name = "Scale"
		uIScale2.Scale = 1
		uIScale2.Parent = frame3
		local uICorner2 = Instance.new("UICorner")
		uICorner2.CornerRadius = UDim.new(0, 8)
		uICorner2.Parent = frame3
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Name = "Stroke"
		uIStroke.Color = v9.color
		uIStroke.Thickness = 2
		uIStroke.Transparency = 0.5
		uIStroke.Parent = frame3
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "Label"
		textLabel2.Size = UDim2.new(1, 0, 1, 0)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = v9.label
		textLabel2.TextColor3 = v9.color
		textLabel2.TextSize = 14
		textLabel2.Font = Enum.Font.GothamBold
		textLabel2.TextStrokeTransparency = 0.5
		textLabel2.Parent = frame3
		frame3:SetAttribute("Angle", v10)
		frame3:SetAttribute("PingType", v9.type)
		frame3:SetAttribute("BaseX", v11)
		frame3:SetAttribute("BaseY", v12)
	end

	screenGui.Parent = playerGui
	return screenGui
end

local function UpdateWheelSelection()
	if not v3 then
		return nil
	end

	local center = v3:FindFirstChild("Center")

	if not center then
		return nil
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local absoluteSize = center.AbsoluteSize
	local v8 = mouseLocation - (center.AbsolutePosition + absoluteSize / 2)

	if v8.Magnitude < 40 then
		for _, child in ipairs(center:GetChildren()) do
			if not child.Name:find("Option_") then
				continue
			end

			local scale = child:FindFirstChild("Scale")
			local stroke = child:FindFirstChild("Stroke")
			local baseX = child:GetAttribute("BaseX") or 0
			local baseY = child:GetAttribute("BaseY") or 0

			if scale then
				spr.target(scale, 0.6, 2, {
					Scale = 1
				})
			end

			spr.target(child, 0.5, 2, {
				Rotation = 0,
				Position = UDim2.new(0.5, baseX, 0.5, baseY),
				BackgroundTransparency = 0.2
			})

			if stroke then
				spr.target(stroke, 0.5, 2, {
					Transparency = 0.5
				})
			end
		end

		local centerCircle = center:FindFirstChild("CenterCircle")

		if centerCircle then
			spr.target(centerCircle, 0.5, 2, {
				BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			})
			local label = centerCircle:FindFirstChild("Label")

			if label then
				label.Text = "AUTO"
				label.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
		end

		pingType = nil
		return nil
	else
		local v9 = math.atan2(v8.Y, v8.X)
		local v10 = 1e999
		local v11 = nil

		for _, child in ipairs(center:GetChildren()) do
			if not child.Name:find("Option_") then
				continue
			end

			local angle = child:GetAttribute("Angle")

			if not angle then
				continue
			end

			local v12 = math.abs(v9 - angle)

			if v12 > 3.141592653589793 then
				v12 = 6.283185307179586 - v12
			end

			if not (v12 < v10) then
				continue
			end

			v11 = child
			v10 = v12
		end

		for _, child in ipairs(center:GetChildren()) do
			if not child.Name:find("Option_") then
				continue
			end

			local scale = child:FindFirstChild("Scale")
			local stroke = child:FindFirstChild("Stroke")
			local baseX = child:GetAttribute("BaseX") or 0
			local baseY = child:GetAttribute("BaseY") or 0

			if child == v11 then
				local angle = child:GetAttribute("Angle") or 0
				local v12 = baseX + math.cos(angle) * 12
				local v13 = baseY + math.sin(angle) * 12

				if scale then
					spr.target(scale, 0.5, 2.5, {
						Scale = 1.2
					})
				end

				spr.target(child, 0.4, 2.5, {
					Rotation = math.random(-3, 3),
					Position = UDim2.new(0.5, v12, 0.5, v13),
					BackgroundTransparency = 0
				})

				if stroke then
					spr.target(stroke, 0.4, 2, {
						Transparency = 0
					})
				end
			else
				if scale then
					spr.target(scale, 0.6, 2, {
						Scale = 1
					})
				end

				spr.target(child, 0.5, 2, {
					Rotation = 0,
					Position = UDim2.new(0.5, baseX, 0.5, baseY),
					BackgroundTransparency = 0.3
				})

				if stroke then
					spr.target(stroke, 0.5, 2, {
						Transparency = 0.5
					})
				end
			end
		end

		if not v11 then
			return pingType
		end

		pingType = v11:GetAttribute("PingType")
		local centerCircle = center:FindFirstChild("CenterCircle")

		if not centerCircle then
			return pingType
		end

		local label = v11:FindFirstChild("Label")
		local label2 = centerCircle:FindFirstChild("Label")

		if label2 and label then
			label2.Text = label.Text
			label2.TextColor3 = label.TextColor3
		end

		spr.target(centerCircle, 0.5, 2, {
			BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		})
		return pingType
	end
end

local function UpdateWheelSelectionForGamepad(p)
	if not v3 then
		return
	end

	local center = v3:FindFirstChild("Center")

	if not center then
		return
	end

	local type

	if p and v7[p] then
		type = v7[p].type
	end

	for _, child in ipairs(center:GetChildren()) do
		if not child.Name:find("Option_") then
			continue
		end

		local scale = child:FindFirstChild("Scale")
		local stroke = child:FindFirstChild("Stroke")
		local baseX = child:GetAttribute("BaseX") or 0
		local baseY = child:GetAttribute("BaseY") or 0

		if child:GetAttribute("PingType") == type and p then
			local angle = child:GetAttribute("Angle") or 0
			local v8 = baseX + math.cos(angle) * 12
			local v9 = baseY + math.sin(angle) * 12

			if scale then
				spr.target(scale, 0.5, 2.5, {
					Scale = 1.2
				})
			end

			spr.target(child, 0.4, 2.5, {
				Rotation = math.random(-3, 3),
				Position = UDim2.new(0.5, v8, 0.5, v9),
				BackgroundTransparency = 0
			})

			if stroke then
				spr.target(stroke, 0.4, 2, {
					Transparency = 0
				})
			end
		else
			if scale then
				spr.target(scale, 0.6, 2, {
					Scale = 1
				})
			end

			spr.target(child, 0.5, 2, {
				Rotation = 0,
				Position = UDim2.new(0.5, baseX, 0.5, baseY),
				BackgroundTransparency = p and 0.3 or 0.2
			})

			if stroke then
				spr.target(stroke, 0.5, 2, {
					Transparency = 0.5
				})
			end
		end
	end

	local centerCircle = center:FindFirstChild("CenterCircle")
	local label = centerCircle and centerCircle:FindFirstChild("Label")

	if label then
		if p and v7[p] then
			label.Text = v7[p].label
			label.TextColor3 = v7[p].color
		else
			label.Text = "AUTO"
			label.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end

	if p and v7[p] then
		pingType = v7[p].type
	else
		pingType = nil
	end
end

local function ShowPingWheel()
	if v3 then
		return
	end

	v4 = nil
	v5 = 0
	v3 = CreatePingWheel()

	if not v3 then
		return
	end

	local center = v3:FindFirstChild("Center")
	local mainScale = center and center:FindFirstChild("MainScale")

	if mainScale then
		center.Rotation = -5
		spr.target(mainScale, 0.5, 2.5, {
			Scale = 1
		})
		spr.target(center, 0.5, 2, {
			Rotation = 0
		})
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if v5 < 0.3 then
			UpdateWheelSelection()
		end
	end)
end

local function HidePingWheel()
	local v8 = pingType
	v4 = nil
	v5 = 0

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v3 then
		local center = v3:FindFirstChild("Center")

		if center then
			local mainScale = center:FindFirstChild("MainScale")

			if mainScale then
				spr.target(mainScale, 0.3, 1, {
					Scale = 0
				})
				spr.target(center, 0.3, 1, {
					Rotation = 5
				})
				task.delay(0.15, function()
					if v3 then
						v3:Destroy()
						v3 = nil
					end
				end)
			else
				v3:Destroy()
				v3 = nil
			end
		else
			v3:Destroy()
			v3 = nil
		end
	end

	pingType = nil
	return v8
end

local function ShowCooldownFeedback()
	local admin = ReplicatedStorage:FindFirstChild("Admin")
	local v8

	if admin == nil then
		v8 = false
	else
		v8 = admin:FindFirstChild("DevFrame") ~= nil
	end

	local v9

	if v8 then
		v9 = PingConfig.DEV_COOLDOWN
	else
		v9 = PingConfig.COOLDOWN
	end

	local v10 = math.max(0, v9 - (tick() - now))
	local events = GetEvents() -- equivalent call inferred; original call site unknown
	local displayMessage = events and events:FindFirstChild("DisplayMessage")

	if displayMessage then
		displayMessage:FireServer(string.format("Ping ready in %.1fs", v10), Color3.fromRGB(255, 200, 100))
	end
end

local function DoPing()
	if not IsInMatch() then
		return
	end

	local v8

	if v and IsInMatch() then
		local v9 = tick() - now
		local admin = ReplicatedStorage:FindFirstChild("Admin")
		local v10

		if admin == nil then
			v10 = false
		else
			v10 = admin:FindFirstChild("DevFrame") ~= nil
		end

		local v11

		if v10 then
			v11 = PingConfig.DEV_COOLDOWN
		else
			v11 = PingConfig.COOLDOWN
		end

		v8 = v11 <= v9
	else
		v8 = false
	end

	if not v8 then
		ShowCooldownFeedback()
		return
	end

	local doShapecast = DoShapecast()
	local v10, v11, v12 = GetPingContext(doShapecast)
	local position

	if doShapecast then
		position = doShapecast.Position
	elseif currentCamera then
		position = currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * 50
	else
		return
	end

	now = tick()
	local events = GetEvents() -- equivalent call inferred; original call site unknown

	if events then
		local pingEvent = events:FindFirstChild("PingEvent")

		if pingEvent then
			pingEvent:FireServer(v10, position, v12)
			return
		end

		warn("[PingController] PingEvent not found, creating local ping only")
		PingMarkerController.CreatePing(localPlayer.Name, v10, position, v11, v12)
	else
		warn("[PingController] Events folder not found, creating local ping only")
		PingMarkerController.CreatePing(localPlayer.Name, v10, position, v11, v12)
	end
end

local function SetupPingReceiver()
	local events = GetEvents() -- equivalent call inferred; original call site unknown

	if not events then
		warn("[PingController] Events folder not found, ping receiver not set up")
		return
	end

	local clientPingEvent = events:FindFirstChild("ClientPingEvent")

	if clientPingEvent then
		clientPingEvent.OnClientEvent:Connect(function(p, p2, p3, p4)
			local instance = nil

			if p2 == "Generator" or p2 == "Item" or p2 == "Tape" then
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { localPlayer.Character }
				local spherecast = workspace:Spherecast(
					p3 + createVector(0, 2, 0),
					3,
					createVector(0, -4, 0),
					raycastParams
				)

				if spherecast then
					instance = spherecast.Instance

					if instance and instance:IsA("BasePart") then
						local parent = instance.Parent

						if parent:IsA("Model") then
							instance = parent
						end
					end
				end
			end

			PingMarkerController.CreatePing(p, p2, p3, instance, p4)
		end)
	else
		warn("[PingController] ClientPingEvent not found")
	end
end

local function FindClosestItem(position, value)
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return nil, nil
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		return nil, nil
	end

	local items = model:FindFirstChild("Items")

	if not items then
		return nil, nil
	end

	local v8 = value or 100
	local model2 = nil

	for _, child in ipairs(items:GetChildren()) do
		if child:IsA("Model") and child.PrimaryPart then
			local magnitude = (child.PrimaryPart.Position - position).Magnitude

			if magnitude < v8 then
				model2 = child
				v8 = magnitude
			end
		elseif child:IsA("BasePart") then
			local magnitude = (child.Position - position).Magnitude

			if magnitude < v8 then
				model2 = child
				v8 = magnitude
			end
		end
	end

	if model2 then
		return model2, model2:IsA("Model") and model2.PrimaryPart and model2.PrimaryPart.Position or model2.Position
	end

	return nil, nil
end

local function FindClosestTwisted(position, value)
	local tagged = CollectionService:GetTagged("Twisted")

	if #tagged == 0 then
		return nil, nil
	end

	local v8 = value or 50
	local v9 = nil

	for _, model in ipairs(tagged) do
		if not model:IsA("Model") then
			local parent = model.Parent

			while parent and parent ~= workspace do
				if parent:IsA("Model") then
					model = parent
					break
				else
					parent = parent.Parent
				end
			end
		end

		if not (model and model:IsA("Model") and model.Parent) then
			continue
		end

		local primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")

		if not primaryPart then
			continue
		end

		local magnitude = (primaryPart.Position - position).Magnitude

		if not (magnitude < v8) then
			continue
		end

		v9 = model
		v8 = magnitude
	end

	if not v9 then
		return nil, nil
	end

	local primaryPart = v9.PrimaryPart or v9:FindFirstChild("HumanoidRootPart")
	return v9, primaryPart and primaryPart.Position or nil
end

local function DoPingWithType(p)
	if not IsInMatch() then
		return
	end

	local v8

	if v and IsInMatch() then
		local v9 = tick() - now
		local admin = ReplicatedStorage:FindFirstChild("Admin")
		local v10

		if admin == nil then
			v10 = false
		else
			v10 = admin:FindFirstChild("DevFrame") ~= nil
		end

		local v11

		if v10 then
			v11 = PingConfig.DEV_COOLDOWN
		else
			v11 = PingConfig.COOLDOWN
		end

		v8 = v11 <= v9
	else
		v8 = false
	end

	if not v8 then
		ShowCooldownFeedback()
		return
	end

	local doShapecast = DoShapecast()
	local name, v10

	if not p then
		p, v10, name = GetPingContext(doShapecast)
	end

	local position

	if doShapecast then
		position = doShapecast.Position
	elseif currentCamera then
		position = currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * 50
	else
		return
	end

	local character = localPlayer.Character
	local position2

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			position2 = humanoidRootPart.Position
		else
			position2 = position
		end
	else
		position2 = position
	end

	if p == "Item" or p == "Tape" then
		local v11
		v11, position2 = FindClosestItem(position, 50)

		if v11 and position2 then
			name = v11.Name
		else
			position2 = position
		end
	elseif p == "Twisted" then
		local v11
		v11, position2 = FindClosestTwisted(position2, 50)

		if v11 and position2 then
			name = v11.Name
		else
			position2 = position
		end
	elseif p == "NeedHealing" then
		name = localPlayer:GetAttribute("SelectedCharacter") or character and character.Name
	else
		position2 = position
	end

	now = tick()
	local events = GetEvents() -- equivalent call inferred; original call site unknown

	if events then
		local pingEvent = events:FindFirstChild("PingEvent")

		if pingEvent then
			pingEvent:FireServer(p, position2, name)
			return
		end

		warn("[PingController] PingEvent not found, creating local ping only")
		PingMarkerController.CreatePing(localPlayer.Name, p, position2, v10, name)
	else
		warn("[PingController] Events folder not found, creating local ping only")
		PingMarkerController.CreatePing(localPlayer.Name, p, position2, v10, name)
	end
end

local function OnInputBegan(p, p2)
	if p2 then
		return
	end

	if p.UserInputType == PingConfig.Keybinds.Mouse or p.KeyCode == PingConfig.Keybinds.Gamepad then
		if not IsInMatch() then
			return
		end

		local now3 = tick()
		local v8 = now3 - v2 <= 0.35
		v2 = now3

		if v8 then
			if thread then
				task.cancel(thread)
				thread = nil
			end

			DoPingWithType("Twisted")
		else
			flag = true
			now2 = tick()
			task.spawn(function()
				task.wait(0.2)

				if flag then
					ShowPingWheel()
				end
			end)
		end
	end
end

local function OnInputEnded(p, _)
	if (p.UserInputType == PingConfig.Keybinds.Mouse or p.KeyCode == PingConfig.Keybinds.Gamepad) and flag then
		flag = false
		local v8 = tick() - now2

		if v3 then
			local hidePingWheel = HidePingWheel()

			if hidePingWheel then
				DoPingWithType(hidePingWheel)
			else
				DoPingWithType(nil)
			end
		elseif v8 < 0.2 then
			if thread then
				task.cancel(thread)
			end

			thread = task.delay(0.1, function()
				thread = nil
				DoPingWithType(nil)
			end)
		end
	end
end

local function Initialize()
	UserInputService.InputBegan:Connect(OnInputBegan)
	UserInputService.InputEnded:Connect(OnInputEnded)
	InputService.GameplayInterrupted:Connect(function()
		flag = false

		if v3 then
			HidePingWheel()
		end
	end)
	UserInputService.InputChanged:Connect(function(input, _)
		if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick2 then
			if not v3 then
				return
			end

			local X = input.Position.X
			local Y = input.Position.Y
			v5 = math.sqrt(X * X + Y * Y)
			local v8 = X > 0.5 and "right" or X < -0.5 and "left" or ""
			local v9 = (Y > 0.5 and "up" or Y < -0.5 and "down" or "") .. v8

			if v6[v9] then
				v4 = v6[v9]
			elseif v5 < 0.5 then
				v4 = nil
			end

			UpdateWheelSelectionForGamepad(v4)
		end
	end)
	task.spawn(function()
		task.wait(1)
		SetupPingReceiver()
	end)
end

local PingController = {}

function PingController.SetEnabled(p)
	v = p
end

function PingController.IsOnCooldown()
	local v8

	if v and IsInMatch() then
		local v9 = tick() - now
		local admin = ReplicatedStorage:FindFirstChild("Admin")
		local v10

		if admin == nil then
			v10 = false
		else
			v10 = admin:FindFirstChild("DevFrame") ~= nil
		end

		local v11

		if v10 then
			v11 = PingConfig.DEV_COOLDOWN
		else
			v11 = PingConfig.COOLDOWN
		end

		v8 = v11 <= v9
	else
		v8 = false
	end

	return not v8
end

function PingController.GetCooldownRemaining()
	local admin = ReplicatedStorage:FindFirstChild("Admin")
	local v8

	if admin == nil then
		v8 = false
	else
		v8 = admin:FindFirstChild("DevFrame") ~= nil
	end

	local v9

	if v8 then
		v9 = PingConfig.DEV_COOLDOWN
	else
		v9 = PingConfig.COOLDOWN
	end

	return (math.max(0, v9 - (tick() - now)))
end

function PingController.ForcePing()
	DoPing()
end

return PingController