local AtelierTheme = {}
local colors = {
	bg = Color3.fromRGB(23, 26, 31),
	surface = Color3.fromRGB(34, 38, 45),
	raised = Color3.fromRGB(46, 51, 60),
	accent = Color3.fromRGB(73, 97, 131),
	text = Color3.fromRGB(238, 241, 246),
	muted = Color3.fromRGB(157, 168, 184)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function corner(instance, p)
	(instance:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", instance)).CornerRadius = UDim.new(0, p)
end

local function stroke(instance)
	local uIStroke = instance:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", instance)
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Color = Color3.fromRGB(85, 96, 113)
	uIStroke.Transparency = 0.55
	uIStroke.Thickness = 1
end

local function label(parent, name, text, position, size, textSize)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.Text = text
	textLabel.Position = position
	textLabel.Size = size
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextSize = textSize
	textLabel.TextColor3 = colors.text
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = parent
	return textLabel
end

function AtelierTheme:style()
	if self:FindFirstAncestor("BodyEditorPanel") or self:GetAttribute("AtelierStyled") then
		return
	end

	self:SetAttribute("AtelierStyled", true)

	if self:IsA("TextLabel") or self:IsA("TextButton") or self:IsA("TextBox") then
		self.Font = Enum.Font.GothamMedium
		self.TextColor3 = colors.text

		if self.Name == "Title" or self.Name == "Heading" then
			self.Font = Enum.Font.GothamBold
			self.TextSize = 28
		end

		if self.Name == "Subtitle" or self.Name == "Status" or self.Name == "Hint" or self.Name == "Creator" or self.Name == "Message" or self.Name == "Summary" then
			self.TextColor3 = colors.muted
		end

		if self.Name == "Price" then
			self.TextColor3 = Color3.fromRGB(175, 195, 223)
		end
	end

	if self:IsA("ScrollingFrame") then
		self.ScrollBarThickness = 3
		self.ScrollBarImageColor3 = colors.accent
	end

	if self:IsA("TextBox") then
		self.BackgroundColor3 = colors.surface
		self.PlaceholderColor3 = colors.muted
		corner(self, 10) -- equivalent call inferred; original call site unknown
		stroke(self)
	end

	if self:IsA("GuiButton") then
		if not self:GetAttribute("Nav") then
			self.BackgroundColor3 = ({
				Search = true,
				Apply = true,
				Buy = true,
				BuyAll = true,
				Wear = true,
				Publish = true
			})[self.Name] and self.Interactable and colors.accent or colors.raised
		end

		self.BorderSizePixel = 0
		corner(self, 10) -- equivalent call inferred; original call site unknown
		stroke(self)

		if self.Name == "Remove" and self.Parent and self.Parent.Name == "Actions" then
			self.BackgroundColor3 = Color3.fromRGB(225, 48, 59)
			self.TextColor3 = Color3.new(1, 1, 1)
			self.Font = Enum.Font.GothamBold
		end
	end

	if self:IsA("Frame") and (self.Name == "Panel" or self.Name == "FilterPanel" or self.Name == "Details" or self.Name == "PublishPanel") then
		self.BackgroundColor3 = colors.bg
		self.Active = true
		corner(self, 18) -- equivalent call inferred; original call site unknown
		stroke(self)
	elseif self:IsA("Frame") and self.Name == "Preview" then
		self.BackgroundColor3 = colors.surface
		corner(self, 14) -- equivalent call inferred; original call site unknown
	end

	if self:IsA("GuiObject") and (self.Name:match("^Item_") or self.Name:match("^Outfit_")) then
		self.BackgroundColor3 = colors.surface
		corner(self, 12) -- equivalent call inferred; original call site unknown
		stroke(self)
	end
end

function AtelierTheme.apply(instance)
	local screenGui = instance:FindFirstChild("ScreenGui")

	if not screenGui or screenGui:FindFirstChild("AtelierRail") then
		return
	end

	for _, folder in ipairs(instance:GetChildren()) do
		if not (folder.Name == "ScreenGui" or folder.Name == "CatalogGui" or folder.Name == "CommunityGui" or folder.Name == "WearingGui") then
			continue
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			AtelierTheme.style(descendant)
		end

		if not folder:FindFirstChild("Root") then
			continue
		end

		folder.Root.BackgroundColor3 = colors.bg
		folder.Root.BackgroundTransparency = 0.28
	end

	local frame = Instance.new("Frame")
	frame.Name = "AtelierRail"
	frame.Size = UDim2.fromOffset(208, 480)
	frame.Position = UDim2.new(0, 20, 0.5, -240)
	frame.BackgroundColor3 = colors.bg
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	corner(frame, 18) -- equivalent call inferred; original call site unknown
	stroke(frame)
	local uDim = UDim2.fromOffset(20, 20)
	local uDim2 = UDim2.fromOffset(170, 34)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Wordmark"
	textLabel.Text = "ATELIER"
	textLabel.Position = uDim
	textLabel.Size = uDim2
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextSize = 27
	textLabel.TextColor3 = colors.text
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = frame
	textLabel.Font = Enum.Font.GothamBlack
	local uDim3 = UDim2.fromOffset(20, 58)
	local uDim4 = UDim2.fromOffset(175, 18)
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Tagline"
	textLabel2.Text = "YOUR AVATAR. YOUR SIGNATURE."
	textLabel2.Position = uDim3
	textLabel2.Size = uDim4
	textLabel2.BackgroundTransparency = 1
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.TextSize = 8
	textLabel2.TextColor3 = colors.text
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Parent = frame
	textLabel2.TextColor3 = colors.muted
	local frame2 = Instance.new("Frame")
	frame2.Name = "Rule"
	frame2.Position = UDim2.fromOffset(20, 94)
	frame2.Size = UDim2.fromOffset(168, 1)
	frame2.BackgroundColor3 = colors.raised
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	local uDim5 = UDim2.fromOffset(20, 110)
	local uDim6 = UDim2.fromOffset(170, 18)
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "Section"
	textLabel3.Text = "THE DRESSING ROOM"
	textLabel3.Position = uDim5
	textLabel3.Size = uDim6
	textLabel3.BackgroundTransparency = 1
	textLabel3.Font = Enum.Font.GothamMedium
	textLabel3.TextSize = 10
	textLabel3.TextColor3 = colors.text
	textLabel3.TextXAlignment = Enum.TextXAlignment.Left
	textLabel3.Parent = frame
	textLabel3.TextColor3 = colors.muted
	local v2 = {
		{
			screenGui.Frame.CatalogButton,
			"Catalog",
			"01",
			144
		},
		{
			screenGui.CommunityButton,
			"Community",
			"03",
			258
		},
		{
			screenGui.WearingButton,
			"Currently Wearing",
			"04",
			315
		},
		{
			screenGui.Frame.CatelogButton,
			"UGC Claim",
			"05",
			372
		}
	}

	for _, list in ipairs(v2) do
		local button, text, text2, v5 = table.unpack(list)
		button:SetAttribute("Nav", true)
		button.AnchorPoint = Vector2.zero
		button.Position = UDim2.new(0, 32, 0.5, -240 + v5)
		button.Size = UDim2.fromOffset(184, 46)
		button.ZIndex = 3
		button.BackgroundTransparency = 0
		button.BackgroundColor3 = colors.surface

		if button:IsA("ImageButton") then
			button.Image = ""
		end

		for _, descendant in ipairs(button:GetDescendants()) do
			if descendant:IsA("TextLabel") or descendant:IsA("UIGradient") then
				descendant:Destroy()
			end
		end

		if button:IsA("TextButton") then
			button.Text = ""
		end

		local uDim7 = UDim2.fromOffset(12, 0)
		local uDim8 = UDim2.fromOffset(23, 46)
		local textLabel4 = Instance.new("TextLabel")
		textLabel4.Name = "NavIndex"
		textLabel4.Text = text2
		textLabel4.Position = uDim7
		textLabel4.Size = uDim8
		textLabel4.BackgroundTransparency = 1
		textLabel4.Font = Enum.Font.GothamMedium
		textLabel4.TextSize = 10
		textLabel4.TextColor3 = colors.text
		textLabel4.TextXAlignment = Enum.TextXAlignment.Left
		textLabel4.Parent = button
		textLabel4.TextColor3 = Color3.fromRGB(175, 195, 223)
		local uDim9 = UDim2.fromOffset(39, 0)
		local uDim10 = UDim2.fromOffset(142, 46)
		local textLabel5 = Instance.new("TextLabel")
		textLabel5.Name = "NavTitle"
		textLabel5.Text = text
		textLabel5.Position = uDim9
		textLabel5.Size = uDim10
		textLabel5.BackgroundTransparency = 1
		textLabel5.Font = Enum.Font.GothamMedium
		textLabel5.TextSize = 13
		textLabel5.TextColor3 = colors.text
		textLabel5.TextXAlignment = Enum.TextXAlignment.Left
		textLabel5.Parent = button
		corner(button, 10) -- equivalent call inferred; original call site unknown
		stroke(button)
	end

	local uDim7 = UDim2.fromOffset(20, 445)
	local uDim8 = UDim2.fromOffset(180, 16)
	local textLabel4 = Instance.new("TextLabel")
	textLabel4.Name = "Footer"
	textLabel4.Text = "CREATE / COLLECT / REPEAT"
	textLabel4.Position = uDim7
	textLabel4.Size = uDim8
	textLabel4.BackgroundTransparency = 1
	textLabel4.Font = Enum.Font.GothamMedium
	textLabel4.TextSize = 9
	textLabel4.TextColor3 = colors.text
	textLabel4.TextXAlignment = Enum.TextXAlignment.Left
	textLabel4.Parent = frame
	textLabel4.TextColor3 = colors.muted

	for childName, v3 in pairs({
		CatalogGui = { "The catalog", "THE EDIT  /  Discover your next signature piece" },
		CommunityGui = { "Community looks", "THE LOOKBOOK  /  Style worth sharing" },
		WearingGui = { "Outfit", nil }
	}) do
		local child = instance:FindFirstChild(childName)

		if not child then
			continue
		end

		local panel = child.Root.Panel
		panel.Title.Text = v3[1]

		if panel:FindFirstChild("Subtitle") then
			panel.Subtitle.Text = v3[2]
		end

		if not panel:FindFirstChild("Tabs") then
			continue
		end

		for _, button in ipairs(panel.Tabs:GetChildren()) do
			if button:IsA("TextButton") then
				button.Size = UDim2.fromOffset(math.max(72, #button.Text * 8 + 28), 36)
			end
		end
	end
end

AtelierTheme.colors = colors
return AtelierTheme