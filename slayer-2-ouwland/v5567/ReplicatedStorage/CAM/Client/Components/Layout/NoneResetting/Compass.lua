local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local faye = require(ReplicatedStorage.Packages.faye)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local compassWidth = gameSettings.CompassWidth
local v = compassWidth / 360
local halfCompassWidth = compassWidth / 2
local currentCamera = workspace.CurrentCamera

local function MakeFrame(name: string, parent)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.fromScale(0.5, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	return frame
end

local function MakeLabel(text: string, p: number, flag: boolean?, parent)
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = text
	textLabel.Size = flag and UDim2.fromScale(0.15, 0.75) or UDim2.fromScale(0.2, 1)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.new(p, 0, 0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Font = flag and Enum.Font.SourceSansSemibold or Enum.Font.ArialBold
	textLabel.Parent = parent
	return textLabel
end

local v3 = nil
return function(parent)
	local v4 = faye.new()
	local frame = Instance.new("Frame")
	frame.Name = "Compass"
	frame.ZIndex = -2
	frame.Size = UDim2.new(0, compassWidth, 0, 25)
	frame.BackgroundTransparency = 1
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, -52.2)
	frame.ClipsDescendants = true
	frame.Parent = parent
	local visibility = ReplicatedStorage.CAM.Client.Components.Layout.Visibility
	local v5 = visibility:FindFirstChild("Compass")

	if v5 == nil then
		v5 = Instance.new("BoolValue")
		v5.Name = "Compass"
		v5.Value = true
		v5.Parent = visibility
	end

	frame.Visible = v5.Value
	v4:Connect(v5.Changed, function(visible: boolean)
		frame.Visible = visible
	end)
	local frame2 = Instance.new("Frame")
	frame2.Name = "LeftGloss"
	frame2.Size = UDim2.fromScale(0.5, 0.7)
	frame2.AnchorPoint = Vector2.new(0, 0.5)
	frame2.Position = UDim2.fromScale(0, 0.5)
	frame2.BackgroundColor3 = Color3.new()
	frame2.ZIndex = -1
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.85),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Rotation = 180
	uIGradient.Parent = frame2
	local frame3 = Instance.new("Frame")
	frame3.Name = "RightGloss"
	frame3.Size = UDim2.fromScale(0.5, 0.7)
	frame3.AnchorPoint = Vector2.new(0, 0.5)
	frame3.Position = UDim2.fromScale(0.5, 0.5)
	frame3.BackgroundColor3 = Color3.new()
	frame3.ZIndex = -1
	frame3.BorderSizePixel = 0
	frame3.Parent = frame
	local uIGradient2 = Instance.new("UIGradient")
	uIGradient2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.85),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient2.Parent = frame3
	local frame4 = Instance.new("Frame")
	frame4.Name = "Right"
	frame4.Size = UDim2.fromScale(0.5, 1)
	frame4.BackgroundTransparency = 1
	frame4.Parent = frame
	local frame5 = Instance.new("Frame")
	frame5.Name = "RightWrap"
	frame5.Size = UDim2.fromScale(0.5, 1)
	frame5.BackgroundTransparency = 1
	frame5.Parent = frame
	local frame6 = Instance.new("Frame")
	frame6.Name = "Left"
	frame6.Size = UDim2.fromScale(0.5, 1)
	frame6.BackgroundTransparency = 1
	frame6.Parent = frame
	local frame7 = Instance.new("Frame")
	frame7.Name = "LeftWrap"
	frame7.Size = UDim2.fromScale(0.5, 1)
	frame7.BackgroundTransparency = 1
	frame7.Parent = frame
	local v6 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function AddDirection(text: string, p2: number, p3: number, flag: boolean?, parent2)
		local label = MakeLabel(text, p2, flag, parent2)

		if v6[p3] == nil then
			v6[p3] = {}
		end

		table.insert(v6[p3], label)
	end

	for _, v7 in { frame6, frame7 } do
		AddDirection("N", 0, 0, false, v7) -- equivalent call inferred; original call site unknown
		AddDirection("45°", 0.25, 45, true, v7) -- equivalent call inferred; original call site unknown
		AddDirection("E", 0.5, 90, false, v7) -- equivalent call inferred; original call site unknown
		AddDirection("135°", 0.75, 135, true, v7) -- equivalent call inferred; original call site unknown
	end

	for _, v7 in { frame4, frame5 } do
		AddDirection("S", 0, 180, false, v7) -- equivalent call inferred; original call site unknown
		AddDirection("225°", 0.25, 225, true, v7) -- equivalent call inferred; original call site unknown
		AddDirection("W", 0.5, 270, false, v7) -- equivalent call inferred; original call site unknown
		AddDirection("315°", 0.75, 315, true, v7) -- equivalent call inferred; original call site unknown
	end

	v4:Connect(RunService.PostSimulation, function(p)
		local lookVector = currentCamera.CFrame.LookVector
		local v7 = (math.deg((math.atan2(-lookVector.X, -lookVector.Z))) + 360) % 360

		if v3 == nil then
			v3 = v7
		else
			local v8 = (v7 - v3 + 180) % 360 - 180
			v3 = (v3 + v8 * (1 - math.exp(-10 * p))) % 360
		end

		frame:SetAttribute("Heading", v3)
		local v8 = v3 * v
		frame6.Position = UDim2.fromOffset(v8, 0)
		frame7.Position = UDim2.fromOffset(v8 - compassWidth, 0)
		frame4.Position = UDim2.fromOffset(v8 - halfCompassWidth, 0)
		frame5.Position = UDim2.fromOffset(v8 + halfCompassWidth, 0)

		for k, v9 in v6 do
			local textTransparency = math.clamp(
				math.abs((v8 + k * v) % compassWidth - halfCompassWidth) / halfCompassWidth,
				0,
				1
			)

			for _, v11 in v9 do
				v11.TextTransparency = textTransparency
			end
		end
	end)
	return function()
		v4:Destroy()
		frame:Destroy()
	end
end