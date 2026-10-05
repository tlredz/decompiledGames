local createVector = vector.create
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- equivalent calls inferred from this helper; original call sites unknown
local function computeRingRadius(count: number)
	return (math.max(0.3, 0.2 / math.sin(6.283185307179586 / count / 2)))
end

local v = nil

local function resolveAdornee(instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if not instance:IsA("Model") then
		return nil
	end

	if instance.PrimaryPart == nil then
		return instance:FindFirstChildWhichIsA("BasePart")
	end

	return instance.PrimaryPart
end

local RadialMenu = {}

function RadialMenu.Open(basePart, list)
	if v ~= nil then
		v:Close()
	end

	if not basePart:IsA("BasePart") then
		if basePart:IsA("Model") then
			if basePart.PrimaryPart == nil then
				basePart = basePart:FindFirstChildWhichIsA("BasePart")
			else
				basePart = basePart.PrimaryPart
			end
		else
			basePart = nil
		end
	end

	if basePart == nil then
		warn("RadialMenu.Open: could not resolve a BasePart adornee from target")
		return nil
	end

	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui == nil then
		return nil
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "RadialMenu"
	billboardGui.Adornee = basePart
	billboardGui.Size = UDim2.fromOffset(400, 400)
	billboardGui.StudsOffsetWorldSpace = createVector(0, 0, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.ResetOnSpawn = false
	billboardGui.MaxDistance = 60
	billboardGui.Active = true
	billboardGui.ClipsDescendants = false
	local v2 = true
	local connections = {}
	local v3 = {
		IsOpen = function(_)
			return v2
		end
	}

	function v3:Close()
		if not v2 then
			return
		end

		v2 = false

		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
		billboardGui:Destroy()

		if v == v3 then
			v = nil
		end
	end

	local count = #list
	local ringRadius = computeRingRadius(count) -- equivalent call inferred; original call site unknown

	for k, v5 in list do
		local v6 = count == 2 and 0 or -1.5707963267948966
		local v7 = (k - 1) / count * 3.141592653589793 * 2 + v6
		local v8 = math.cos(v7) * ringRadius + 0.5
		local v9 = math.sin(v7) * ringRadius / 2 + 0.5
		local textButton = Instance.new("TextButton")
		textButton.Name = v5.text
		textButton.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton.Position = UDim2.fromScale(v8, v9)
		textButton.Size = UDim2.fromScale(0.34, 0.136)
		textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textButton.BackgroundTransparency = 0.5
		textButton.AutoButtonColor = true
		textButton.Text = ""
		textButton.Parent = billboardGui
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = textButton
		local v10

		if v5.icon == nil then
			v10 = false
		else
			v10 = v5.icon ~= ""
		end

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Label"
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Nunito
		textLabel.Text = v5.text
		textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.TextScaled = true
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.Parent = textButton

		if v10 then
			textLabel.AnchorPoint = Vector2.new(0, 0.5)
			textLabel.Position = UDim2.fromScale(0.06, 0.5)
			textLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Icon"
			imageLabel.BackgroundTransparency = 1
			imageLabel.AnchorPoint = Vector2.new(1, 0.5)
			imageLabel.Position = UDim2.new(0.94, 0, 0.5, 0)
			imageLabel.Size = UDim2.fromScale(0.75, 0.75)
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Image = v5.icon

			if v5.iconColor ~= nil then
				imageLabel.ImageColor3 = v5.iconColor
			end

			imageLabel.Parent = textButton
			local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			uIAspectRatioConstraint.AspectRatio = 1
			uIAspectRatioConstraint.Parent = imageLabel
		else
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.Position = UDim2.fromScale(0.5, 0.5)
			textLabel.Size = UDim2.new(0.88, 0, 0.94, 0)
		end

		local onActivated = v5.onActivated
		table.insert(connections, textButton.Activated:Connect(function()
			v3:Close()

			if onActivated ~= nil then
				onActivated()
			end
		end))
	end

	billboardGui.Parent = playerGui
	table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not gameProcessed then
				v3:Close()
			end
		elseif input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonA and GamepadService.GamepadCursorEnabled then
			local selectedObject = GuiService.SelectedObject

			if selectedObject == nil or not selectedObject:IsDescendantOf(billboardGui) then
				v3:Close()
			end
		end
	end))
	v = v3
	return v3
end

function RadialMenu.CloseActive()
	if v ~= nil then
		v:Close()
	end
end

return RadialMenu