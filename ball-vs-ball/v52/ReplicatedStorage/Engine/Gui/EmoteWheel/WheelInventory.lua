local createVector = vector.create
local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local AssetLibrary = require(ReplicatedStorage.Engine.Service.AssetLibrary)
local v = AssetLibrary.Get("通用组件", "占位格子"):WaitForChild("已装备标签")
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local EmoteWheelLoadoutService = require(ReplicatedStorage.Engine.Service.EmoteWheelLoadoutService)
local client2 = EmoteWheelLoadoutService.client
local FLYER_ONLY_SLOTS = EmoteWheelLoadoutService.FLYER_ONLY_SLOTS
local WheelConfig = require(script.Parent.WheelConfig)
local PreviewRenderer = require(script.Parent.PreviewRenderer)
local WheelInventory = {}
WheelInventory.__index = WheelInventory

-- equivalent calls inferred from this helper; original call sites unknown
local function findRatingByLvl(rating: number)
	for _, v2 in Config.rating.list do
		if v2.lvl == rating then
			return v2
		end
	end

	return nil
end

local function compareFlyers(p, p2)
	if p.rating == p2.rating then
		return tostring(p.itemId) < tostring(p2.itemId)
	end

	return p.rating > p2.rating
end

local function compareFreeEmotes(p, p2)
	if p.rating == p2.rating then
		return p.sourceOrder < p2.sourceOrder
	end

	return p.rating > p2.rating
end

-- equivalent calls inferred from this helper; original call sites unknown
local function matchesSlot(generatedCell, data)
	if not data or generatedCell.kind ~= data.kind then
		return false
	end

	if generatedCell.kind == "freeEmote" then
		return generatedCell.id == data.id
	end

	return generatedCell.itemId == data.itemId
end

function WheelInventory.new(p, animator)
	local object = setmetatable({}, WheelInventory)
	object.animator = animator
	object.frame = p["库存"]
	object.list = object.frame["列表"]
	object.template = object.list["格子1"]
	object.template.Visible = false
	object.titleLabel = object.frame:FindFirstChild("文字")
	object.generatedCells = {}
	object.previewCleanups = {}
	object.refreshRevision = 0

	for _, button in object.list:GetChildren() do
		if button:IsA("GuiButton") and button ~= object.template then
			button:Destroy()
		end
	end

	object.frame.Visible = false
	animator:OnHighlightChanged(function()
		if object.frame.Visible then
			object:_refresh()
		end
	end)
	WheelConfig.onLoadoutChanged(function()
		if object.frame.Visible then
			object:_updateMasks()
		end
	end)
	return object
end

function WheelInventory:_clearGeneratedSlots()
	self.refreshRevision += 1

	for _, previewCleanup in self.previewCleanups do
		previewCleanup()
	end

	table.clear(self.previewCleanups)
	table.clear(self.generatedCells)

	for _, button in self.list:GetChildren() do
		if button:IsA("GuiButton") and button:GetAttribute("WheelInventoryGeneratedSlot") then
			button:Destroy()
		end
	end
end

function WheelInventory:_buildRecords()
	local items = client.items()
	local v2 = {}
	local v3 = {}

	if typeof(items) == "table" then
		for _, item in items do
			if item.itemType ~= "飞行器" or v2[item.itemId] then
				continue
			end

			local v4 = Config.skin.byCnId[item.itemId]

			if not v4 then
				continue
			end

			v2[item.itemId] = true
			table.insert(v3, {
				kind = "flyer",
				id = item.instanceId,
				itemId = item.itemId,
				name = v4.name,
				nameCn = v4.nameCn,
				rating = tonumber(v4.rating) or 0,
				assetName = v4.assetName
			})
		end
	end

	table.sort(v3, compareFlyers)
	local result = {}

	for _, v4 in ipairs(v3) do
		table.insert(result, v4)
	end

	if self.animator.highlighted and FLYER_ONLY_SLOTS[self.animator.highlighted] then
		return result
	end

	local v4 = {}

	for i, v5 in ipairs(Config.freeEmote.list) do
		table.insert(v4, {
			kind = "freeEmote",
			id = v5.cnId,
			name = v5.name,
			nameCn = v5.nameCn,
			rating = tonumber(v5.rating) or 0,
			animation = v5.animation,
			sourceOrder = i
		})
	end

	table.sort(v4, compareFreeEmotes)

	for _, v5 in ipairs(v4) do
		table.insert(result, v5)
	end

	return result
end

function WheelInventory:_ensureViewport(parent)
	local viewportFrame = parent:FindFirstChild("动画预览")

	if viewportFrame and viewportFrame:IsA("ViewportFrame") then
		return viewportFrame
	end

	if viewportFrame then
		viewportFrame:Destroy()
	end

	local viewportFrame2 = Instance.new("ViewportFrame")
	viewportFrame2.Name = "动画预览"
	viewportFrame2.BackgroundTransparency = 1
	viewportFrame2.Size = UDim2.fromScale(1, 0.72)
	viewportFrame2.Position = UDim2.fromScale(0, 0)
	viewportFrame2.ZIndex = parent.ZIndex + 1
	viewportFrame2.Ambient = Color3.fromRGB(190, 190, 190)
	viewportFrame2.LightColor = Color3.fromRGB(255, 255, 255)
	viewportFrame2.LightDirection = createVector(-1, -1, -1)
	viewportFrame2.Parent = parent
	return viewportFrame2
end

function WheelInventory:_writeCell(instance, data, p: number)
	instance.Visible = true
	instance.Active = true
	instance.Interactable = true
	local firstChild = instance:FindFirstChild("名称")
	local v2 = firstChild and firstChild:FindFirstChild("文字")

	if v2 then
		v2.Text = data.name
	end

	local ratingByLvl = findRatingByLvl(data.rating) -- equivalent call inferred; original call site unknown
	local color

	if ratingByLvl then
		color = Color3.fromHex(ratingByLvl.colorHex)
	else
		color = Color3.new(1, 1, 1)
	end

	local firstChild2 = instance:FindFirstChild("品质描边")
	local v3 = firstChild and firstChild:FindFirstChild("品质描边")

	if firstChild2 then
		firstChild2.Color = color
	end

	if v3 then
		v3.Color = color
	end

	local _ensureViewport = self:_ensureViewport(instance)
	task.spawn(function()
		local v4 = PreviewRenderer.render(_ensureViewport, data)

		if p == self.refreshRevision and instance.Parent ~= nil and self.frame.Visible then
			if v4 then
				table.insert(self.previewCleanups, v4)
			end
		elseif v4 then
			v4()
		end
	end)
	ButtonActions.Bind(instance, function()
		local highlighted = self.animator.highlighted

		if not highlighted then
			return
		end

		if not client2.setSlot(highlighted, {
			kind = data.kind,
			id = data.id
		}) then
			warn("[WheelInventory] 更新表情轮盘槽位失败")
		end
	end)
end

function WheelInventory:_updateTitle()
	if not self.titleLabel then
		return
	end

	local highlighted = self.animator.highlighted
	self.titleLabel.Text = highlighted ~= nil and FLYER_ONLY_SLOTS[highlighted] ~= nil and "Flyers" or "Emotes"
end

function WheelInventory:_updateMasks()
	local v2

	if self.animator.highlighted then
		v2 = WheelConfig.SlotContents[self.animator.highlighted]
	end

	for k, generatedCell in self.generatedCells do
		local guiObject = k:FindFirstChild("已装备标签")

		if not (guiObject and guiObject:IsA("GuiObject")) then
			continue
		end

		local visible = matchesSlot(generatedCell, v2) -- equivalent call inferred; original call site unknown
		guiObject.Visible = visible
	end
end

function WheelInventory:_refresh()
	self:_clearGeneratedSlots()
	local refreshRevision = self.refreshRevision
	local _buildRecords = self:_buildRecords()

	for i, _buildRecord in ipairs(_buildRecords) do
		local clone = self.template:Clone()
		local clone2 = v:Clone()
		clone2.Visible = false
		clone2.Parent = clone
		clone.Name = "格子" .. tostring(i)
		clone.LayoutOrder = i
		clone:SetAttribute("WheelInventoryGeneratedSlot", true)
		clone.Parent = self.list
		self.generatedCells[clone] = _buildRecord
		self:_writeCell(clone, _buildRecord, refreshRevision)
	end

	self.list.CanvasPosition = Vector2.zero
	self:_updateMasks()
	self:_updateTitle()
end

function WheelInventory:Open()
	self.frame.Visible = true
	self:_refresh()
end

function WheelInventory:Close()
	self.frame.Visible = false
	self:_clearGeneratedSlots()
end

function WheelInventory.IsOpen(p)
	return p.frame.Visible
end

return WheelInventory