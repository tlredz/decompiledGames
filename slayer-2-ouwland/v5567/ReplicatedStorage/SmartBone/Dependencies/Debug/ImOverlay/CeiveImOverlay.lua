local GuiService = game:GetService("GuiService")
local rbxassetfontsfamiliesPressStart2Pjson = Font.new("rbxasset://fonts/families/PressStart2P.json")
local CeiveImOverlay = {}
CeiveImOverlay.__index = CeiveImOverlay

function CeiveImOverlay.new(value: number?, value2: number?, flag: boolean?)
	local v = flag == nil or flag
	local uDim = UDim2.fromOffset(25, 5 + GuiService:GetGuiInset().Y)
	local uDim2 = UDim2.new(1, -25, 1, -5)
	local uDim3 = UDim2.fromOffset(0, 0)
	local uDim4 = UDim2.fromScale(1, 1)
	local self = setmetatable({}, CeiveImOverlay)
	self.DefaultY = value or 5
	self.TextSize = value2 or 11
	self.BackFrame = Instance.new("Frame")
	local backFrame = self.BackFrame

	if v then
		uDim3 = uDim or uDim3
	end

	backFrame.Position = uDim3
	local backFrame2 = self.BackFrame

	if v then
		uDim4 = uDim2 or uDim4
	end

	backFrame2.Size = uDim4
	self.BackFrame.Name = "BackFrame"
	self.BackFrame.Transparency = 1
	self.ListLayout = Instance.new("UIListLayout")
	self.ListLayout.Padding = UDim.new(0, 2)
	self.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self.ListLayout.Parent = self.BackFrame
	self.m_Indent = 0
	self.DidUpdate = false
	self.m_State = ""
	self.m_PreviousState = ""
	self.m_RenderGroup = {}
	self.m_ItemPool = {}
	return self
end

function CeiveImOverlay:Begin(value: string, color: Color3?, color2: Color3?)
	if not value or type(value) ~= "string" then
		warn("Expected text to ImOverlay::Begin", debug.traceback())
		return
	end

	if color and typeof(color) ~= "Color3" then
		warn("BackgroundColor should be a Color3", debug.traceback())
		return
	end

	if color2 and typeof(color2) ~= "Color3" then
		warn("TextColor should be a Color3", debug.traceback())
		return
	end

	self:Text(value, color, color2)
	self.m_Indent += 1
end

function CeiveImOverlay:End()
	if self.m_Indent - 1 < 0 then
		error("Too many callbacks to ImOverlay::End")
	else
		self.m_Indent -= 1
	end
end

function CeiveImOverlay:Text(text: string, color: Color3?, color2: Color3?)
	if not text or type(text) ~= "string" then
		warn("Expected text to ImOverlay::Text", debug.traceback())
		return
	end

	if color and typeof(color) ~= "Color3" then
		warn("BackgroundColor should be a Color3", debug.traceback())
		return
	end

	if color2 and typeof(color2) ~= "Color3" then
		warn("TextColor should be a Color3", debug.traceback())
		return
	end

	local backgroundColor = color or Color3.new()
	local textColor = color2 or Color3.new(1, 1, 1)
	table.insert(self.m_RenderGroup, {
		Text = text,
		TextColor = textColor,
		BackgroundColor = backgroundColor,
		Indent = self.m_Indent
	})
	self.m_State ..= `{text}|{textColor}|{backgroundColor}|{self.m_Indent}`
end

function CeiveImOverlay:m_Pool()
	for _, uIListLayout in self.BackFrame:GetChildren() do
		if uIListLayout:IsA("UIListLayout") or not uIListLayout.Visible then
			continue
		end

		uIListLayout.Visible = false
		table.insert(self.m_ItemPool, uIListLayout)
	end
end

function CeiveImOverlay:m_Cleanup()
	self.m_State = ""
	self.m_Indent = 0
	self.m_RenderGroup = {}
end

function CeiveImOverlay:m_CreateLabel(text: string, textColor: Color3, backgroundColor: Color3, p2: number)
	local frame = Instance.new("Frame")
	frame.Name = "Background"
	frame.AutomaticSize = Enum.AutomaticSize.XY
	frame.BackgroundColor3 = backgroundColor
	frame.BackgroundTransparency = 0.4
	frame.BorderSizePixel = 0
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TaskText"
	textLabel.FontFace = rbxassetfontsfamiliesPressStart2Pjson
	textLabel.Text = text
	textLabel.TextColor3 = textColor
	textLabel.TextSize = self.TextSize
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.fromOffset(p2 * 50, 0)
	textLabel.Size = UDim2.fromOffset(0, self.DefaultY)
	textLabel.Parent = frame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingBottom = UDim.new(0, 2)
	uIPadding.Parent = textLabel
	local uIPadding2 = Instance.new("UIPadding")
	uIPadding2.Name = "UIPadding"
	uIPadding2.PaddingRight = UDim.new(0, 5)
	uIPadding2.PaddingLeft = UDim.new(0, 5)
	uIPadding2.Parent = frame
	return frame
end

function CeiveImOverlay:Render()
	if self.m_State == "" then
		self:m_Pool()
		self:m_Cleanup()
		self.DidUpdate = false
	else
		self.m_State ..= `{self.DefaultY}|{self.TextSize}`

		if self.m_State == self.m_PreviousState then
			self:m_Cleanup()
			self.DidUpdate = false
		else
			self:m_Pool()
			self.m_PreviousState = self.m_State
			self.DidUpdate = true

			for k, v in self.m_RenderGroup do
				if #self.m_ItemPool == 0 then
					local m_CreateLabel = self:m_CreateLabel(v.Text, v.TextColor, v.BackgroundColor, v.Indent)
					m_CreateLabel.LayoutOrder = k
					m_CreateLabel.Parent = self.BackFrame
				else
					local v2 = table.remove(self.m_ItemPool, #self.m_ItemPool)
					local taskText = v2.TaskText
					v2.LayoutOrder = k
					v2.BackgroundColor3 = v.BackgroundColor
					taskText.Text = v.Text
					taskText.TextColor3 = v.TextColor
					taskText.Position = UDim2.fromOffset(50 * v.Indent, 0)
					v2.Visible = true
					v2.Parent = self.BackFrame
				end
			end

			self:m_Cleanup()
		end
	end
end

function CeiveImOverlay:Destroy()
	self.BackFrame:Destroy()
	setmetatable(self, nil)
end

return CeiveImOverlay