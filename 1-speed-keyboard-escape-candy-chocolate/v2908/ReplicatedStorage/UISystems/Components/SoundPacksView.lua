local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundPacks = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("SoundPacks"))
local SoundPackButton = require(script.Parent.SoundPackButton)
local SoundPacksView = {}
SoundPacksView.__index = SoundPacksView

function SoundPacksView.Hydrate(instance, options)
	local v = options or {}
	assert(type(v.isPackUnlocked) == "function", "[SoundPacksView] opts.isPackUnlocked requis")
	local template = v.template or instance:FindFirstChild("Template")
	assert(template, "[SoundPacksView] Template introuvable dans " .. instance:GetFullName())
	template.Visible = false
	local classicSoundPack = instance:FindFirstChild("ClassicSoundPack")
	local soundPacksFrame = instance:FindFirstChild("SoundPacksFrame")
	local scrollingFrame = soundPacksFrame and soundPacksFrame:FindFirstChild("ScrollingFrame")
	assert(classicSoundPack, "[SoundPacksView] ClassicSoundPack introuvable dans " .. instance:GetFullName())
	assert(
		scrollingFrame,
		"[SoundPacksView] SoundPacksFrame/ScrollingFrame introuvable dans " .. instance:GetFullName()
	)
	local object = setmetatable({
		Modal = instance,
		Buttons = {},
		_sections = {},
		_isPackUnlocked = v.isPackUnlocked,
		_getPriceText = v.getPriceText,
		_equipped = v.equipped or SoundPacks.DEFAULT_SOUND
	}, SoundPacksView)
	local count = 0
	local clone = nil
	local clone2 = nil

	for _, v2 in ipairs(SoundPacks.GetSortedPacks()) do
		if v2.pack.unlock.type ~= "Free" then
			count += 1
		end
	end

	if count > 0 then
		local uIGridLayout = scrollingFrame:FindFirstChildOfClass("UIGridLayout")

		if uIGridLayout then
			clone = uIGridLayout:Clone()
			uIGridLayout:Destroy()
			local cellSize = clone.CellSize
			clone.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, 0, 100000)
		end

		local uIPadding = scrollingFrame:FindFirstChildOfClass("UIPadding")

		if uIPadding then
			clone2 = uIPadding:Clone()
			uIPadding:Destroy()
		end

		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.FillDirection = Enum.FillDirection.Vertical
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Padding = UDim.new(0.025, 0)
		uIListLayout.Parent = scrollingFrame

		if scrollingFrame:IsA("ScrollingFrame") then
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame.CanvasSize = UDim2.new()
		end
	end

	local title = instance:FindFirstChild("Title")

	local function createSection(key: string, pack)
		local frame = Instance.new("Frame")
		frame.Name = key
		frame.BackgroundTransparency = 1
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.Size = UDim2.fromScale(1, 0)
		frame.LayoutOrder = pack.order
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.FillDirection = Enum.FillDirection.Vertical
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = frame
		local v2

		if title and title:IsA("TextLabel") then
			v2 = title:Clone()
		else
			v2 = Instance.new("TextLabel")
			v2.BackgroundTransparency = 1
			v2.TextScaled = true
			v2.Font = Enum.Font.FredokaOne
			v2.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		v2.Name = "PackTitle"
		v2.AnchorPoint = Vector2.new(0, 0)
		v2.Position = UDim2.new()
		v2.Size = UDim2.fromScale(1, 0)
		v2.LayoutOrder = 1
		v2.Text = pack.displayName
		v2.Visible = true
		v2.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "Grid"
		frame2.BackgroundTransparency = 1
		frame2.AutomaticSize = Enum.AutomaticSize.Y
		frame2.Size = UDim2.fromScale(0.8, 0)
		frame2.LayoutOrder = 2

		if clone then
			local clone_2 = clone:Clone()
			clone_2.Parent = frame2
		end

		(clone2 and clone2:Clone() or Instance.new("UIPadding")).Parent = frame2
		frame2.Parent = frame
		return frame, frame2
	end

	local onSoundActivated = v.onSoundActivated
	local onSoundHovered = v.onSoundHovered
	local count2 = 0

	for _, v2 in ipairs(SoundPacks.GetSortedPacks()) do
		local key = v2.key
		local pack = v2.pack
		local v3 = pack.unlock.type == "Free"
		local parent = v3 and classicSoundPack or scrollingFrame
		local locked = not v.isPackUnlocked(key, pack)
		local price

		if object._getPriceText then
			price = object._getPriceText(key, pack) or nil
		end

		if not v3 then
			local v7
			v7, parent = createSection(key, pack)
			v7.Parent = scrollingFrame
			object._sections[key] = v7
		end

		for _, v7 in ipairs(SoundPacks.GetPackSounds(key)) do
			local key2 = v7.key
			local sound = v7.sound
			count2 += 1
			local name = key
			object.Buttons[key2] = SoundPackButton.Create({
				template = template,
				parent = parent,
				layoutOrder = count2,
				soundKey = key2,
				sound = sound,
				equipped = key2 == object._equipped,
				locked = locked,
				price = price,
				onActivated = onSoundActivated and (function(object2)
					onSoundActivated(object2.SoundKey, object2.Sound, object2:IsLocked(), name)
				end or nil) or nil,
				onHovered = onSoundHovered and (function(object2)
					onSoundHovered(object2.SoundKey, object2.Sound, object2:IsLocked())
				end or nil) or nil
			})
		end
	end

	if not next(object._sections) then
		return object
	end

	local cellPadding = clone and clone.CellPadding

	local function applyViewportSizes()
		local Y = scrollingFrame.AbsoluteSize.Y

		if Y <= 0 then
			return
		end

		for _, _section in pairs(object._sections) do
			local packTitle = _section:FindFirstChild("PackTitle")

			if packTitle then
				packTitle.Size = UDim2.new(1, 0, 0, (math.round(Y * 0.08)))
			end

			local uIListLayout = _section:FindFirstChildOfClass("UIListLayout")

			if uIListLayout then
				uIListLayout.Padding = UDim.new(0, (math.round(Y * 0.025)))
			end

			local grid = _section:FindFirstChild("Grid")

			if not grid then
				continue
			end

			local uIPadding = grid:FindFirstChildOfClass("UIPadding")

			if uIPadding then
				uIPadding.PaddingBottom = UDim.new(0, (math.round(Y * 0.01)))
			end

			local uIGridLayout = grid:FindFirstChildOfClass("UIGridLayout")

			if uIGridLayout and cellPadding then
				uIGridLayout.CellPadding = UDim2.new(
					cellPadding.X.Scale,
					cellPadding.X.Offset,
					0,
					(math.round(Y * cellPadding.Y.Scale + cellPadding.Y.Offset))
				)
			end
		end
	end

	applyViewportSizes()
	object._viewportConn = scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyViewportSizes)
	return object
end

function SoundPacksView.GetButton(p, p2: string)
	return p.Buttons[p2]
end

function SoundPacksView:SetPackVisible(p2: string, visible: boolean)
	local _section = self._sections[p2]

	if _section then
		_section.Visible = visible
	end
end

function SoundPacksView:SetEquipped(equipped: string)
	self._equipped = equipped

	for k, button in pairs(self.Buttons) do
		button:SetEquipped(k == equipped)
	end
end

function SoundPacksView:RefreshLocks()
	for _, v in ipairs(SoundPacks.GetSortedPacks()) do
		local key = v.key
		local pack = v.pack
		local v2 = not self._isPackUnlocked(key, pack)
		local v3

		if self._getPriceText then
			v3 = self._getPriceText(key, pack) or nil
		end

		for _, v4 in ipairs(SoundPacks.GetPackSounds(key)) do
			local button = self.Buttons[v4.key]

			if button then
				button:SetLocked(v2, v3)
			end
		end
	end
end

function SoundPacksView:Destroy()
	if self._viewportConn then
		self._viewportConn:Disconnect()
		self._viewportConn = nil
	end

	for _, button in pairs(self.Buttons) do
		button:Destroy()
	end

	table.clear(self.Buttons)

	for _, _section in pairs(self._sections) do
		_section:Destroy()
	end

	table.clear(self._sections)
end

return SoundPacksView