local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local CmdrPermissions = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrPermissions)
local color = Color3.fromRGB(180, 180, 190)
local color2 = Color3.fromRGB(220, 200, 120)
local color3 = Color3.fromRGB(100, 210, 130)
local color4 = Color3.fromRGB(230, 100, 100)

-- equivalent calls inferred from this helper; original call sites unknown
local function isArray(result)
	local count = 0

	for k in pairs(result) do
		if type(k) ~= "number" then
			return false
		end

		count += 1
	end

	return count == #result
end

local function validateJson(text: string)
	local success, result = pcall(function()
		return HttpService:JSONDecode(text)
	end)

	if not success then
		return false, (`Invalid JSON: {result}`)
	end

	if type(result) ~= "table" then
		return false, "Root JSON value must be an object/table"
	end

	-- equivalent call inferred; original call site unknown
	if isArray(result) then
		return false, "Root JSON value must be an object, not an array"
	end

	return true, nil
end

local function createButton(frame, name: string, text: string, backgroundColor: Color3, layoutOrder: number)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.LayoutOrder = layoutOrder
	textButton.Size = UDim2.new(0, 120, 1, 0)
	textButton.BackgroundColor3 = backgroundColor
	textButton.BorderSizePixel = 0
	textButton.Font = Enum.Font.GothamMedium
	textButton.Text = text
	textButton.TextColor3 = Color3.new(1, 1, 1)
	textButton.TextSize = 16
	textButton.AutoButtonColor = true
	textButton.Parent = frame
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 6)
	uICorner.Parent = textButton
	return textButton
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSaveEnabled(p, flag: boolean)
	p.Active = flag
	p.AutoButtonColor = flag
	local backgroundColor

	if flag then
		backgroundColor = Color3.fromRGB(40, 120, 70)
	else
		backgroundColor = Color3.fromRGB(55, 70, 60)
	end

	p.BackgroundColor3 = backgroundColor
	p.TextTransparency = flag and 0 or 0.35
end

local function openEditor(p: string, p2: number, text: string)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local cmdrDataEditor = playerGui:FindFirstChild("CmdrDataEditor")

	if cmdrDataEditor ~= nil then
		cmdrDataEditor:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CmdrDataEditor"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1000
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local frame = Instance.new("Frame")
	frame.Name = "Root"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromScale(0.9, 0.92)
	frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 10)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(70, 70, 80)
	uIStroke.Thickness = 1
	uIStroke.Parent = frame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingTop = UDim.new(0, 10)
	uIPadding.PaddingBottom = UDim.new(0, 10)
	uIPadding.PaddingLeft = UDim.new(0, 10)
	uIPadding.PaddingRight = UDim.new(0, 10)
	uIPadding.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.fromOffset(0, 0)
	textLabel.Size = UDim2.new(1, 0, 0, 24)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = `Profile Data Editor — {p} ({p2})`
	textLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
	textLabel.TextSize = 18
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "Buttons"
	frame2.BackgroundTransparency = 1
	frame2.AnchorPoint = Vector2.new(0, 1)
	frame2.Position = UDim2.new(0, 0, 1, 0)
	frame2.Size = UDim2.new(1, 0, 0, 36)
	frame2.Parent = frame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Padding = UDim.new(0, 8)
	uIListLayout.Parent = frame2
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Status"
	textLabel2.BackgroundTransparency = 1
	textLabel2.AnchorPoint = Vector2.new(0, 1)
	textLabel2.Position = UDim2.new(0, 0, 1, -44)
	textLabel2.Size = UDim2.new(1, 0, 0, 36)
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.Text = "EDIT MODE - Please copy the JSON (Ctrl/Cmd + A to select all), edit in a JSON editor and paste it back"
	textLabel2.TextColor3 = color
	textLabel2.TextSize = 12
	textLabel2.TextWrapped = true
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.TextYAlignment = Enum.TextYAlignment.Center
	textLabel2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "EditorFrame"
	frame3.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	frame3.BorderSizePixel = 0
	frame3.ClipsDescendants = true
	frame3.Position = UDim2.fromOffset(0, 32)
	frame3.Size = UDim2.new(1, 0, 1, -120)
	frame3.Parent = frame
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0, 8)
	uICorner2.Parent = frame3
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "Scroll"
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Size = UDim2.fromScale(1, 1)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollingFrame.ScrollBarThickness = 8
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 130)
	scrollingFrame.Parent = frame3
	local uIPadding2 = Instance.new("UIPadding")
	uIPadding2.PaddingTop = UDim.new(0, 8)
	uIPadding2.PaddingBottom = UDim.new(0, 8)
	uIPadding2.PaddingLeft = UDim.new(0, 8)
	uIPadding2.PaddingRight = UDim.new(0, 8)
	uIPadding2.Parent = scrollingFrame
	local textBox = Instance.new("TextBox")
	textBox.Name = "JsonEditor"
	textBox.BackgroundTransparency = 1
	textBox.ClearTextOnFocus = false
	textBox.MultiLine = true
	textBox.TextWrapped = false
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.TextYAlignment = Enum.TextYAlignment.Top
	textBox.Font = Enum.Font.Code
	textBox.TextSize = 14
	textBox.TextColor3 = Color3.fromRGB(230, 230, 235)
	textBox.PlaceholderText = "Profile JSON"
	textBox.Text = text
	textBox.Position = UDim2.fromOffset(0, 0)
	textBox.Size = UDim2.new(1, -8, 0, 0)
	textBox.AutomaticSize = Enum.AutomaticSize.None
	textBox.Parent = scrollingFrame
	local button = createButton(frame2, "Close", "Close", Color3.fromRGB(70, 70, 80), 1)
	local button2 = createButton(frame2, "Save", "Save", Color3.fromRGB(40, 120, 70), 2)
	local flag = false
	local count = 0
	local v = true
	local flag2 = false

	local function updateScroll()
		if screenGui.Parent == nil then
			return
		end

		local v2 = math.max(textBox.TextBounds.Y, 14) + 14
		local v3 = v2 + 96
		textBox.Size = UDim2.new(1, -8, 0, v2)
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, v3)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function queueScrollUpdate()
		if flag2 then
			return
		end

		flag2 = true
		task.defer(function()
			flag2 = false
			updateScroll()
		end)
	end

	local function showEditingStatus()
		if flag then
			return
		end

		if v then
			textLabel2.Text = "EDIT MODE - Please copy the JSON (Ctrl/Cmd + A to select all), edit in a JSON editor and paste it back"
			textLabel2.TextColor3 = color
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshValidation()
		if flag then
			return
		end

		local v2, v3 = validateJson(textBox.Text)
		v = v2
		setSaveEnabled(button2, v2) -- equivalent call inferred; original call site unknown

		if v2 then
			if textLabel2.Text ~= "SAVE SUCCESS!" then
				textLabel2.Text = "EDIT MODE - Please copy the JSON (Ctrl/Cmd + A to select all), edit in a JSON editor and paste it back"
				textLabel2.TextColor3 = color
			end
		else
			textLabel2.Text = v3 or "Invalid JSON"
			textLabel2.TextColor3 = color4
		end
	end

	button.Activated:Connect(function()
		screenGui:Destroy()
	end)
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		queueScrollUpdate() -- equivalent call inferred; original call site unknown
		refreshValidation() -- equivalent call inferred; original call site unknown
	end)
	textBox:GetPropertyChangedSignal("TextBounds"):Connect(queueScrollUpdate)
	button2.Activated:Connect(function()
		if flag or not v then
			return
		end

		local v2, v3 = validateJson(textBox.Text)

		if v2 then
			flag = true
			local v4 = button2
			v4.Active = false
			v4.AutoButtonColor = false
			v4.BackgroundColor3 = Color3.fromRGB(55, 70, 60)
			v4.TextTransparency = 0.35
			textLabel2.Text = "Saving..."
			textLabel2.TextColor3 = color2
			local v5, v6 = Remotes.invokeServer("CmdrDataEditor_Save", p2, textBox.Text)
			flag = false

			if screenGui.Parent == nil then
				return
			end

			if v5 == true then
				count += 1
				local v7 = count
				textLabel2.Text = "SAVE SUCCESS!"
				textLabel2.TextColor3 = color3
				local v8 = button2
				v8.Active = true
				v8.AutoButtonColor = true
				v8.BackgroundColor3 = Color3.fromRGB(40, 120, 70)
				v8.TextTransparency = 0
				v = true
				task.delay(2.5, function()
					if screenGui.Parent == nil or v7 ~= count then
						return
					end

					if not flag and v then
						textLabel2.Text = "EDIT MODE - Please copy the JSON (Ctrl/Cmd + A to select all), edit in a JSON editor and paste it back"
						textLabel2.TextColor3 = color
					end

					refreshValidation() -- equivalent call inferred; original call site unknown
				end)
			else
				textLabel2.Text = tostring(v6 or "Save failed")
				textLabel2.TextColor3 = color4
				refreshValidation() -- equivalent call inferred; original call site unknown
			end
		else
			v = false
			local v4 = button2
			v4.Active = false
			v4.AutoButtonColor = false
			v4.BackgroundColor3 = Color3.fromRGB(55, 70, 60)
			v4.TextTransparency = 0.35
			textLabel2.Text = v3 or "Invalid JSON"
			textLabel2.TextColor3 = color4
		end
	end)
	screenGui.Parent = playerGui

	if not flag then
		local v2, v3 = validateJson(textBox.Text)
		v = v2
		setSaveEnabled(button2, v2) -- equivalent call inferred; original call site unknown

		if v2 then
			if textLabel2.Text ~= "SAVE SUCCESS!" then
				textLabel2.Text = "EDIT MODE - Please copy the JSON (Ctrl/Cmd + A to select all), edit in a JSON editor and paste it back"
				textLabel2.TextColor3 = color
			end
		else
			textLabel2.Text = v3 or "Invalid JSON"
			textLabel2.TextColor3 = color4
		end
	end

	updateScroll()
	task.defer(updateScroll)
end

return {
	Name = "data_openDataEditor",
	Aliases = {},
	Description = "Opens a JSON editor for a player's ProfileService data by user id. Defaults to the executor. Works for offline players.",
	Group = "Data",
	Args = {
		{
			Type = "playerId",
			Name = "playerId",
			Description = "Target user id. Prefix with \"#\" (e.g. #123456789). Defaults to you if omitted.",
			Optional = true
		}
	},
	ClientRun = function(_, p: number?)
		local localPlayer = Players.LocalPlayer

		if localPlayer == nil then
			return "Local player not found"
		end

		if CmdrPermissions.hasCommandAccess(localPlayer, "data_openDataEditor") ~= true then
			return "No permission"
		end

		local v = p or localPlayer.UserId

		if type(v) ~= "number" or v ~= math.floor(v) or v <= 0 then
			return "Invalid target user id"
		end

		local v2, text, v4, v5 = Remotes.invokeServer("CmdrDataEditor_Get", v)

		if v2 ~= true then
			return (tostring(text or "Failed to load profile data"))
		end

		openEditor(v4, v5, text)
		return (`Opened data editor for {v4} ({v5})`)
	end
}