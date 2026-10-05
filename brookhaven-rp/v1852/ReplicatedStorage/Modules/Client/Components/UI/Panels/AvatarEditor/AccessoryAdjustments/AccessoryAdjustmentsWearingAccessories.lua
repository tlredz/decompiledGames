local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local AccessoryAdjustmentsState = require(ReplicatedStorage.Modules.Client.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsState)
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "AvatarEditorWearingAccessories"
})
local v2 = {
	[8] = true,
	[42] = true,
	[43] = true,
	[44] = true,
	[45] = true,
	[46] = true,
	[47] = true
}

local function getAccessoryWearingAssets(items)
	local result = {}

	if not items then
		return result
	end

	local v3, v4 = ABTest.GetExperimentVariables("multiple-hairs"):timeout(3):await()

	if v3 and v4.editingHairsEnabled == true then
		v2[41] = true
	end

	for _, item in items do
		if v2[item.assetType.id] == true then
			table.insert(result, item)
		end
	end

	return result
end

function v:_findGreenCheckMark(instance)
	local itemFrame = instance:FindFirstChild("ItemFrame")

	if not itemFrame then
		return nil
	end

	local itemImage = itemFrame:FindFirstChild("ItemImage")

	if not itemImage then
		return nil
	end

	local greenCheckMark = itemImage:FindFirstChild("GreenCheckMark")

	if greenCheckMark and greenCheckMark:IsA("ImageLabel") then
		return greenCheckMark
	end

	return nil
end

function v:_refreshSelectionVisuals()
	if not self._scroller then
		return
	end

	for _, frame in self._scroller:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local _findGreenCheckMark = self:_findGreenCheckMark(frame)

		if _findGreenCheckMark ~= nil then
			_findGreenCheckMark.Visible = frame == self._selectedRow
		end
	end
end

function v:_setSelectedRow(selectedRow)
	if self._selectedRow == selectedRow then
		return
	end

	local v3

	if selectedRow ~= nil then
		v3 = self._rowAssetByRow[selectedRow]
	end

	local id

	if v3 ~= nil then
		id = tonumber(v3.id)
	end

	local selectedAssetId = AccessoryAdjustmentsState.GetSelectedAssetId()
	self._selectedRow = selectedRow
	self:_refreshSelectionVisuals()
	AccessoryAdjustmentsState.SetSelectedAsset(v3)

	if id ~= selectedAssetId then
		self.OnSelectionChanged:Fire(v3)
	end
end

function v:_cleanupScroller()
	self._selectedRow = nil
	self._rowAssetByRow = {}

	if not self._scroller then
		return
	end

	for _, frame in self._scroller:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	self._scroller.CanvasPosition = Vector2.new(0, 0)
	self._itemsJanitor:Cleanup()
end

function v:_updateCanvasSize()
	if not self._scroller then
		return
	end

	local uIListLayout = self._scroller:FindFirstChild("UIListLayout")

	if uIListLayout and uIListLayout:IsA("UIListLayout") then
		local absoluteContentSize = uIListLayout.AbsoluteContentSize
		self._scroller.CanvasSize = UDim2.new(0, absoluteContentSize.X, 0, 0)
	end
end

function v:_buildScroller(p)
	local id = nil

	if self._selectedRow ~= nil then
		local v3 = self._rowAssetByRow[self._selectedRow]

		if v3 ~= nil then
			id = tonumber(v3.id)
		end
	end

	if id == nil then
		id = AccessoryAdjustmentsState.GetSelectedAssetId()
	end

	self:_cleanupScroller()

	if not (self._templateItem and self._scroller) then
		return
	end

	Platform.IsMobile()
	local accessoryWearingAssets = getAccessoryWearingAssets(p)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toggleRowSelection(p2)
		if self._selectedRow == p2 then
			self:_setSelectedRow(nil)
		else
			self:_setSelectedRow(p2)
		end
	end

	local count = 0
	local v3 = nil
	local v4 = nil

	for _, accessoryWearingAsset in accessoryWearingAssets do
		if not (accessoryWearingAsset.id ~= "0" or accessoryWearingAsset.assetType.id ~= 13 and accessoryWearingAsset.assetType.id ~= 18) then
			continue
		end

		count += 1
		local clone = self._templateItem:Clone()

		if v3 == nil then
			v3 = clone
		end

		if id ~= nil and v4 == nil and tonumber(accessoryWearingAsset.id) == id then
			v4 = clone
		end

		self._rowAssetByRow[clone] = accessoryWearingAsset
		local name = accessoryWearingAsset.name

		if name == nil or name == "" then
			clone.Name = tostring(accessoryWearingAsset.id)
		else
			clone.Name = name
		end

		clone:SetAttribute("Id", accessoryWearingAsset.id)
		local itemFrame = clone:FindFirstChild("ItemFrame")

		if itemFrame and itemFrame:IsA("GuiObject") then
			local itemImage = itemFrame:FindFirstChild("ItemImage")

			if itemImage and (itemImage:IsA("ImageLabel") or itemImage:IsA("ImageButton")) then
				itemImage.Image = `rbxthumb://type=Asset&id={accessoryWearingAsset.id}&w=150&h=150`
			end

			local footer = itemFrame:FindFirstChild("Footer")

			if footer and footer:IsA("GuiObject") then
				footer.Visible = false
			end

			local unequip = itemFrame:FindFirstChild("Unequip")

			if unequip and unequip:IsA("GuiObject") then
				unequip.Visible = false
			end

			if itemFrame:IsA("GuiButton") then
				itemFrame.Selectable = true
				itemFrame.Active = true
				local v5 = clone
				self._itemsJanitor:Add(itemFrame.Activated:Connect(function()
					toggleRowSelection(v5) -- equivalent call inferred; original call site unknown
				end))
			else
				local v5 = clone
				self._itemsJanitor:Add(itemFrame.InputBegan:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
						return
					end

					toggleRowSelection(v5) -- equivalent call inferred; original call site unknown
				end))
			end
		end

		clone.Parent = self._scroller
	end

	if self._nothingWorn ~= nil then
		self._nothingWorn.Visible = count == 0
	end

	if count == 0 then
		self._selectedRow = nil
		self:_refreshSelectionVisuals()
		AccessoryAdjustmentsState.SetSelectedAsset(nil)
		self.OnSelectionChanged:Fire(nil)
	else
		if v4 ~= nil then
			v3 = v4
		end

		self:_setSelectedRow(v3)
	end

	self:_updateCanvasSize()
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._itemsJanitor = Janitor.new()
	self._selectedRow = nil
	self._rowAssetByRow = {}
	self.OnSelectionChanged = self._Janitor:Add(Signal.new())
end

function v:Start()
	self._scroller = self.Instance:WaitForChild("ScrollingFrame")
	self._nothingWorn = self.Instance:WaitForChild("NothingWorn")
	self._templateItem = self._scroller:FindFirstChild("Template")

	if not (self._templateItem and self._templateItem:IsA("GuiObject")) then
		warn("AvatarEditorWearingAccessories: Template GuiObject not found under ScrollingFrame")
		return
	end

	self._templateItem.Parent = nil
	self._Janitor:Add(WearingController.OnWearingUpdated:Connect(function(p)
		local canvasPosition = self._scroller.CanvasPosition
		self:_buildScroller(p.assets)
		self._scroller.CanvasPosition = canvasPosition
	end))
	self._Janitor:Add(AccessoryAdjustmentsState.SelectionChanged:Connect(function()
		task.defer(function()
			if AccessoryAdjustmentsState.IsAccessoryAdjustmentsPanelOpen() ~= true then
				return
			end

			if CameraController.ENABLE_AVATAR_EDITOR_ACCESSORY_CAMERA_FOCUS == true then
				CameraController.SetAvatarEditorCameraFocusAccessory(
					AccessoryAdjustmentsState.GetSelectedAccessoryInstance(),
					nil
				)
			else
				CameraController.SetAvatarEditorCamera(false)
			end
		end)
	end))
end

function v:Stop()
	self._itemsJanitor:Destroy()
	self._Janitor:Destroy()
end

return v