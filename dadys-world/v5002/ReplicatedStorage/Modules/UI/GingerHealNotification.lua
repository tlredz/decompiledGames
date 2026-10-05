local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local flag = false
local localPlayer = nil
local onClientEventConnection = nil
local frame = nil
local v = nil
local v2 = {}
local v3 = nil

local function createNotificationUI()
	if frame then
		return
	end

	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = playerGui:FindFirstChild("ScreenGui")

	if not screenGui then
		return
	end

	frame = Instance.new("Frame")
	frame.Name = "GingerHealNotification"
	frame.Size = UDim2.new(0, 200, 0, 60)
	frame.Position = UDim2.new(0.5, -100, 0, 100)
	frame.BackgroundColor3 = Color3.fromRGB(139, 90, 43)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.ZIndex = 100
	frame.Parent = screenGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 10)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(255, 200, 150)
	uIStroke.Thickness = 2
	uIStroke.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Icon"
	imageLabel.Size = UDim2.new(0, 50, 0, 50)
	imageLabel.Position = UDim2.new(0, 5, 0.5, -25)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://87154471381383"
	imageLabel.ZIndex = 101
	imageLabel.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(1, -60, 1, 0)
	textLabel.Position = UDim2.new(0, 55, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "Ginger is healing you!"
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 101
	textLabel.Parent = frame
end

local function getHealerCount()
	local count = 0

	for _ in pairs(v2) do
		count += 1
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateNotificationText()
	if not frame then
		return
	end

	local text = frame:FindFirstChild("Text")

	if not text then
		return
	end

	local count = 0

	for _ in pairs(v2) do
		count += 1
	end

	if count == 0 then
		return
	end

	if count == 1 then
		text.Text = next(v2) .. " is healing you!"
	else
		text.Text = "Multiple Gingers are healing you!"
	end
end

local function showNotification()
	createNotificationUI()

	if not frame then
		return
	end

	if v3 then
		v3:Cancel()
		v3 = nil
	end

	local text = frame and frame:FindFirstChild("Text")

	if text then
		local count = 0

		for _ in pairs(v2) do
			count += 1
		end

		if count ~= 0 then
			if count == 1 then
				text.Text = next(v2) .. " is healing you!"
			else
				text.Text = "Multiple Gingers are healing you!"
			end
		end
	end

	frame.Visible = true

	if frame.Position.Y.Offset < 0 then
		frame.Position = UDim2.new(0.5, -100, 0, -60)
		TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, -100, 0, 100)
		}):Play()
	end

	local icon = frame:FindFirstChild("Icon")

	if icon and not v then
		v = TweenService:Create(icon, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Position = UDim2.new(0, 5, 0.5, -30),
			Rotation = 10
		})
		v:Play()
	end
end

local function hideNotification()
	if not frame then
		return
	end

	local count = 0

	for _ in pairs(v2) do
		count += 1
	end

	if count > 0 then
		return
	end

	if v then
		v:Cancel()
		v = nil
	end

	local icon = frame:FindFirstChild("Icon")

	if icon then
		icon.Position = UDim2.new(0, 5, 0.5, -25)
		icon.Rotation = 0
	end

	if v3 then
		v3:Cancel()
	end

	local tween = TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, -100, 0, -60)
	})
	v3 = tween
	tween:Play()
	tween.Completed:Connect(function()
		if frame then
			local count2 = 0

			for _ in pairs(v2) do
				count2 += 1
			end

			if count2 == 0 then
				frame.Visible = false
			end
		end

		if v3 == tween then
			v3 = nil
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function connectToHealEvent(p)
	if onClientEventConnection then
		return
	end

	onClientEventConnection = p.OnClientEvent:Connect(function(p2, value)
		if p2 == "BeingHealed" then
			v2[value or "Ginger"] = true
			showNotification()
		elseif p2 == "HealCancelled" then
			v2[value or "Ginger"] = nil
			local count = 0

			for _ in pairs(v2) do
				count += 1
			end

			if count == 0 then
				hideNotification()
				return
			end

			updateNotificationText() -- equivalent call inferred; original call site unknown
		elseif p2 == "HealComplete" then
			v2[value or "Ginger"] = nil
			local text = frame and frame:FindFirstChild("Text")

			if text then
				text.Text = "Healed!"
				text.TextColor3 = Color3.fromRGB(100, 255, 100)
			end

			task.delay(1, function()
				if not frame then
					return
				end

				local count = 0

				for _ in pairs(v2) do
					count += 1
				end

				if count == 0 then
					hideNotification()
				else
					local text2 = frame and frame:FindFirstChild("Text")

					if text2 then
						local count2 = 0

						for _ in pairs(v2) do
							count2 += 1
						end

						if count2 ~= 0 then
							if count2 == 1 then
								text2.Text = next(v2) .. " is healing you!"
							else
								text2.Text = "Multiple Gingers are healing you!"
							end
						end
					end
				end

				local text2 = frame:FindFirstChild("Text")

				if text2 then
					text2.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
			end)
		end
	end)
end

local childAddedConnection = nil
local childRemovedConnection = nil
local changedConnection = nil
local GingerHealNotification = {}

function GingerHealNotification.init()
	if flag then
		return
	end

	localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		flag = true
		return
	end

	local gingerHealChannel = events:FindFirstChild("GingerHealChannel")

	if gingerHealChannel then
		connectToHealEvent(gingerHealChannel) -- equivalent call inferred; original call site unknown
	else
		childAddedConnection = events.ChildAdded:Connect(function(remoteEvent)
			if remoteEvent.Name == "GingerHealChannel" and remoteEvent:IsA("RemoteEvent") then
				connectToHealEvent(remoteEvent) -- equivalent call inferred; original call site unknown

				if childAddedConnection then
					childAddedConnection:Disconnect()
					childAddedConnection = nil
				end
			end
		end)
	end

	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		childRemovedConnection = inGamePlayers.ChildRemoved:Connect(function(child)
			local name = child.Name

			if v2[name] then
				v2[name] = nil
				local count = 0

				for _ in pairs(v2) do
					count += 1
				end

				if count == 0 then
					hideNotification()
					return
				end

				updateNotificationText() -- equivalent call inferred; original call site unknown
			end
		end)
	end

	local info = workspace:FindFirstChild("Info")
	local floorActive = info and info:FindFirstChild("FloorActive")

	if floorActive then
		changedConnection = floorActive.Changed:Connect(function(p)
			if p == false then
				local count = 0

				for _ in pairs(v2) do
					count += 1
				end

				if count > 0 then
					v2 = {}
					local text = frame and frame:FindFirstChild("Text")

					if text then
						text.TextColor3 = Color3.fromRGB(255, 255, 255)
					end

					hideNotification()
				end
			end
		end)
	end

	flag = true
end

function GingerHealNotification.cleanup()
	if onClientEventConnection then
		onClientEventConnection:Disconnect()
		onClientEventConnection = nil
	end

	if childAddedConnection then
		childAddedConnection:Disconnect()
		childAddedConnection = nil
	end

	if childRemovedConnection then
		childRemovedConnection:Disconnect()
		childRemovedConnection = nil
	end

	if changedConnection then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	if v then
		v:Cancel()
		v = nil
	end

	if v3 then
		v3:Cancel()
		v3 = nil
	end

	if frame then
		frame:Destroy()
		frame = nil
	end

	v2 = {}
	flag = false
end

return GingerHealNotification