require(script.Parent.Parent.Types)
local TextService = game:GetService("TextService")

-- equivalent calls inferred from this helper; original call sites unknown
local function getVerticalRenderScale(UI)
	local offset = UI.Size.Y.Offset
	local Y = UI.AbsoluteSize.Y

	if offset <= 0 or Y <= 0 then
		return 1
	end

	return Y / offset
end

return function(p, data)
	local extended = data.extend("Tab", "Tab")

	function extended:Init()
		self.ComponentContainers = {}
		self.CurTab = ""

		function self.OnTabChanged() end

		self.OnTabOpened = p.Signal.new()

		for _, frame in self.UI.TabCtn:GetChildren() do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end

		for _, frame in self.UI.ContentCtn:GetChildren() do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end

		self:GetMainContainer().OnUpdateWidth:Connect(function()
			self:UpdateTabHeight()
		end)
	end

	function extended:SetSizeY(p2: number)
		self.UI.Size = UDim2.new(1, 0, 0, p2)
		self:UpdateHeight()
		self:UpdateParentHeight()
		return self
	end

	function extended:SetTabs(list)
		for k, v in list do
			local clone = self.OriginalUI.TabCtn.TabFrameSelected:Clone()
			clone.Name = v
			clone.Title.Text = v
			clone.LayoutOrder = k - 1
			clone.Parent = self.UI.TabCtn

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("GuiObject") then
					guiObject.ZIndex += self.UI.ZIndex
				end
			end

			local getTextBoundsParams = Instance.new("GetTextBoundsParams")
			getTextBoundsParams.Text = v
			getTextBoundsParams.Size = clone.Title.TextSize
			getTextBoundsParams.Width = 100000
			getTextBoundsParams.Font = clone.Title.FontFace
			local textBoundsAsync = TextService:GetTextBoundsAsync(getTextBoundsParams)
			clone.Size = UDim2.fromOffset(textBoundsAsync.X + 12, clone.Size.Y.Offset)
			clone.Interactibility.MouseEnter:Connect(function()
				clone.WhiteFrame.BackgroundTransparency = 0.8
			end)
			local v3 = clone
			clone.Interactibility.MouseLeave:Connect(function()
				v3.WhiteFrame.BackgroundTransparency = 1
			end)
			local v4 = v
			clone.Interactibility.MouseButton1Click:Connect(function()
				self:OpenTab(v4)
			end)
			local clone2 = self.OriginalUI.ContentCtn.ContainerEx:Clone()
			clone2.Name = v
			clone2.Parent = self.UI.ContentCtn

			for _, guiObject in clone2:GetDescendants() do
				if guiObject:IsA("GuiObject") then
					guiObject.ZIndex += self.UI.ZIndex
				end
			end

			self.ComponentContainers[v] = p.ComponentManager.new(clone2, self)
		end

		self:OpenTab(list[1])
		self:UpdateTabHeight()
		return self
	end

	function extended.GetOpenTabName(p2)
		return p2.CurTab
	end

	function extended:OpenTab(curTab: string)
		self.CurTab = curTab
		self:UpdateDisplay()
		self:UpdateHeight()
		self:UpdateParentHeight()
		self.OnTabChanged(curTab)
		self.OnTabOpened:Fire(curTab)
		return self
	end

	function extended:UpdateDisplay()
		local tabFrameSelected = self.OriginalUI.TabCtn.TabFrameSelected
		local tabFrameUnSelected = self.OriginalUI.TabCtn.TabFrameUnSelected

		for _, frame in self.UI.TabCtn:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			local v = frame.Name == self.CurTab
			local backgroundColor

			if v then
				backgroundColor = tabFrameSelected.BackgroundColor3
			else
				backgroundColor = tabFrameUnSelected.BackgroundColor3
			end

			frame.BackgroundColor3 = backgroundColor
			local title = frame.Title
			local textColor

			if v then
				textColor = tabFrameSelected.Title.TextColor3
			else
				textColor = tabFrameUnSelected.Title.TextColor3
			end

			title.TextColor3 = textColor
			local decoHighlight = frame.DecoHighlight
			local backgroundColor2

			if v then
				backgroundColor2 = tabFrameSelected.DecoHighlight.BackgroundColor3
			else
				backgroundColor2 = tabFrameUnSelected.DecoHighlight.BackgroundColor3
			end

			decoHighlight.BackgroundColor3 = backgroundColor2
			frame.WhiteFrame.Visible = not v
		end

		for _, frame in self.UI.ContentCtn:GetChildren() do
			if frame:IsA("Frame") then
				frame.Visible = frame.Name == self.CurTab
			end
		end

		return self
	end

	function extended:GetComponentCtn(p3: string)
		return self.ComponentContainers[p3]
	end

	function extended:GetAllComponentCtn()
		local componentContainers = {}

		for _, componentContainer in self.ComponentContainers do
			table.insert(componentContainers, componentContainer)
		end

		return componentContainers
	end

	function extended:SetOnTabChanged(onTabChanged)
		self.OnTabChanged = onTabChanged
		return self
	end

	function extended:UpdateTabHeight()
		local tabCtn = self.UI:FindFirstChild("TabCtn")

		if not tabCtn then
			return
		end

		local verticalRenderScale = getVerticalRenderScale(self.UI) -- equivalent call inferred; original call site unknown
		local v = tabCtn.UIListLayout.AbsoluteContentSize.Y / math.max(verticalRenderScale, 0.001)
		tabCtn.Size = UDim2.new(1, 0, 0, v)
		self:UpdateHeight()
	end

	function extended.GetHeight(p2)
		return p2.UI.Size.Y.Offset
	end

	function extended:UpdateHeight(flag: boolean?)
		if self.UI.Parent and self.CurTab ~= "" and self:GetComponentCtn(self.CurTab) then
			self.UI.Size = UDim2.new(
				1,
				0,
				0,
				self:GetComponentCtn(self.CurTab):GetComponentsHeight() + self.UI.TabCtn.Size.Y.Offset
			)
		end

		return data.UpdateHeight(self, flag)
	end

	function extended:OnDestroy()
		self.OnTabOpened:DisconnectAll()

		for _, v in self:GetAllComponentCtn() do
			for _, v2 in v:GetAll() do
				v2:Destroy()
			end
		end

		data.OnDestroy(self)
	end

	return extended
end