local createVector = vector.create
local TextService = game:GetService("TextService")
local ValleyTheme = require(script.Parent.ValleyTheme)
local OverheadView = {
	Width = 260,
	MaxDistance = 70,
	SizeMultiplier = 1.3,
	HeadOffset = 1.45
}
local color = Color3.fromRGB(8, 18, 20)

local function textWidth(data)
	local v = data.RichText and data.Text:gsub("<[^>]->", "") or data.Text
	return math.ceil(TextService:GetTextSize(v, data.TextSize, data.Font, Vector2.new(2000, 100)).X) + 2
end

local function separator(content, name)
	local selected = content:FindFirstChild(name)

	if not selected then
		selected = Instance.new("TextLabel")
		selected.Name = name
		selected.Parent = content
	end

	selected.BackgroundTransparency = 1
	selected.BorderSizePixel = 0
	selected.Text = "·"
	selected.TextSize = 11
	selected.Font = Enum.Font.GothamMedium
	selected.TextColor3 = ValleyTheme.Muted
	selected.TextStrokeColor3 = color
	selected.TextStrokeTransparency = 0.78
	selected.TextXAlignment = Enum.TextXAlignment.Center
	selected.TextYAlignment = Enum.TextYAlignment.Center
	return selected
end

local function row(items, items2, p, p2)
	local v = {}

	for _, item in items do
		if item.Visible and item.Text ~= "" then
			table.insert(v, item)
		end
	end

	for _, item in items2 do
		item.Visible = false
	end

	local v2 = math.max(0, #v - 1) * 10
	local v3 = {}

	for k, v4 in v do
		v3[k] = textWidth(v4)
		v2 += v3[k]
	end

	if v2 > 248 then
		local v4 = math.max(0, #v - 1) * 10
		local v5 = (248 - v4) / math.max(1, v2 - v4)
		v2 = v4

		for k in v do
			v3[k] = math.floor(v3[k] * v5)
			v2 += v3[k]
		end
	end

	local v4 = (OverheadView.Width - v2) / 2

	for k, v5 in v do
		v5.Position = UDim2.fromOffset(v4, p)
		v5.Size = UDim2.fromOffset(v3[k], p2)
		v4 += v3[k]
		local item = items2[k]

		if not (k < #v and item) then
			continue
		end

		item.Visible = true
		item.Position = UDim2.fromOffset(v4, p)
		item.Size = UDim2.fromOffset(10, p2)
		v4 += 10
	end
end

function OverheadView:apply()
	self.Size = UDim2.fromOffset(OverheadView.Width, 48)
	self.SizeOffset = Vector2.new(0, 0.5)
	self.StudsOffset = createVector(0, 0, 0)
	self.StudsOffsetWorldSpace = Vector3.new(0, OverheadView.HeadOffset, 0)
	self.ExtentsOffset = createVector(0, 0, 0)
	self.ExtentsOffsetWorldSpace = createVector(0, 0, 0)
	self.ResetOnSpawn = false
	self.MaxDistance = OverheadView.MaxDistance
	self.AlwaysOnTop = false
	self.LightInfluence = 0
	self.ClipsDescendants = false
	local content = self.Content
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.AnchorPoint = Vector2.zero
	content.Position = UDim2.fromOffset(0, 0)
	content.Size = UDim2.fromOffset(OverheadView.Width, 48)

	for _, descendant in content:GetDescendants() do
		if not (descendant:IsA("UIListLayout") or descendant:IsA("UIAspectRatioConstraint") or descendant:IsA("UISizeConstraint") or descendant:IsA("UITextSizeConstraint") or descendant:IsA("UIScale") or descendant:IsA("UIStroke")) then
			continue
		end

		descendant:Destroy()
	end

	local uIScale = Instance.new("UIScale")
	uIScale.Name = "Scale"
	uIScale.Scale = OverheadView.SizeMultiplier
	uIScale.Parent = content

	for _, v in {
		"DisplayName",
		"SpecialRank",
		"JourneyTitle",
		"Wins",
		"Lvl",
		"AFK",
		"Username"
	} do
		local v2 = content[v]
		v2.BackgroundTransparency = 1
		v2.BorderSizePixel = 0
		v2.AnchorPoint = Vector2.zero
		v2.TextScaled = false
		v2.TextWrapped = false
		v2.RichText = v == "DisplayName"
		v2.TextTruncate = Enum.TextTruncate.AtEnd
		v2.TextXAlignment = Enum.TextXAlignment.Center
		v2.TextYAlignment = Enum.TextYAlignment.Center
		v2.TextStrokeColor3 = color
		v2.TextStrokeTransparency = v == "DisplayName" and 0.65 or 0.76
		v2.TextTransparency = 0
		v2.Font = v == "DisplayName" and Enum.Font.GothamBold or Enum.Font.GothamMedium
		v2.TextSize = v == "DisplayName" and 22 or 11

		if v == "DisplayName" then
			v2.TextColor3 = Color3.fromRGB(247, 248, 241)
		elseif v == "Wins" or v == "Lvl" then
			v2.TextColor3 = Color3.fromRGB(205, 220, 211)
		end
	end

	content.Username.Visible = false
	content.AFK.Text = "AFK"
	content.AFK.TextColor3 = ValleyTheme.Gold
	separator(content, "TitleDot")
	separator(content, "StatDot1")
	separator(content, "StatDot2")
	self:SetAttribute("LayoutHeight", 48)
	self:SetAttribute("RenderScale", OverheadView.SizeMultiplier)
	self:SetAttribute("RenderFade", 0)
end

function OverheadView:layout()
	local content = self.Content
	local visible = content.SpecialRank.Visible or content.JourneyTitle.Visible
	local total = 0

	for _, v in { content.SpecialRank, content.JourneyTitle } do
		v.TextSize = 11

		if v.Visible then
			total += textWidth(v)
		end
	end

	if content.SpecialRank.Visible and content.JourneyTitle.Visible then
		total += 10
	end

	if total > 248 then
		local textSize = math.max(9, (math.floor(2728 / total)))
		content.SpecialRank.TextSize = textSize
		content.JourneyTitle.TextSize = textSize
	end

	row({ content.SpecialRank, content.JourneyTitle }, { content.TitleDot }, 0, 12)
	local v = visible and 12 or 0
	content.DisplayName.TextSize = 22
	local v2 = textWidth(content.DisplayName)

	if v2 > 248 then
		content.DisplayName.TextSize = math.max(16, (math.floor(5456 / v2)))
	end

	content.DisplayName.Position = UDim2.fromOffset(6, v)
	content.DisplayName.Size = UDim2.fromOffset(248, 24)
	row({ content.Lvl, content.Wins, content.AFK }, { content.StatDot1, content.StatDot2 }, v + 23, 13)
	local v3 = v + 36
	content.Size = UDim2.fromOffset(OverheadView.Width, v3)
	self:SetAttribute("LayoutHeight", v3)
	local scale = content.Scale.Scale
	self.Size = UDim2.fromOffset(OverheadView.Width * scale, v3 * scale)
	content.Username.Visible = false
end

function OverheadView:camera(p)
	if not (p and self.Adornee) then
		return
	end

	local magnitude = (p.CFrame.Position - self.Adornee.Position).Magnitude
	local v = math.clamp(p.ViewportSize.Y / 720, 0.8, 1.08)
	local scale = math.min(
		OverheadView.SizeMultiplier * v * math.clamp(24 / math.max(24, magnitude), 0.58, 1),
		p.ViewportSize.X * 0.9 / OverheadView.Width
	)
	local textTransparency = math.clamp((magnitude - 50) / (OverheadView.MaxDistance - 50), 0, 1)

	if math.abs(scale - (self:GetAttribute("RenderScale") or 1)) > 0.005 then
		self:SetAttribute("RenderScale", scale)
		self.Content.Scale.Scale = scale
		self.Size = UDim2.fromOffset(OverheadView.Width * scale, (self:GetAttribute("LayoutHeight") or 48) * scale)
	end

	if math.abs(textTransparency - (self:GetAttribute("RenderFade") or 0)) > 0.005 then
		self:SetAttribute("RenderFade", textTransparency)

		for _, label in self.Content:GetChildren() do
			if not label:IsA("TextLabel") then
				continue
			end

			label.TextTransparency = textTransparency
			local v4 = label.Name == "DisplayName" and 0.65 or 0.76
			label.TextStrokeTransparency = v4 + (1 - v4) * textTransparency
		end
	end
end

return OverheadView