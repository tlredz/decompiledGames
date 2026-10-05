local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local v = Component.new({
	Tag = "ClothesList"
})
local v2 = false
local v3 = false
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self._loadingBatch = false
	self._currentIndex = 1
	self._itemsToLoad = {}
	self._loadedItems = {}
	self._currentCategory = nil
	self.currentItemLayoutOrder = 0
	self._regularLayoutOffset = 0
	local ClothesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Clothes.ClothesConfig)
	v2 = ClothesConfig
	local ShowcasedItemCategoriesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.ShowcasedItemCategories.ShowcasedItemCategoriesConfig)
	v3 = ShowcasedItemCategoriesConfig
end

function v:ClearList()
	self._itemsToLoad = {}
	self._currentIndex = 1
	self._loadingBatch = false
	self._loadedItems = {}
	self.selectDebounce = false

	for _, button in self.Instance:GetChildren() do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	self.Instance.CanvasPosition = Vector2.new(0, 0)
	self._clickJanitor:Cleanup()
	self.Instance.CanvasPosition = Vector2.new(0, 0)
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, 0)
end

function v:ShouldLoadMoreItems()
	local instance = self.Instance
	local Y = instance.CanvasPosition.Y
	return instance.CanvasSize.Y.Offset - (Y + instance.AbsoluteSize.Y) < 200
end

function v:LoadNextBatch()
	if self._loadingBatch or not self.Instance.Visible or self._currentIndex > #self._itemsToLoad then
		return
	end

	local _currentCategory = self._currentCategory
	self._loadingBatch = true
	local v4 = math.min(self._currentIndex + 60 - 1, #self._itemsToLoad)

	for i = self._currentIndex, v4 do
		if _currentCategory ~= self._currentCategory then
			self._loadingBatch = false
			return
		end

		if not self.Instance.Visible then
			self._loadingBatch = false
			return
		end

		local v5 = self._itemsToLoad[i]

		if not v5 or not v5.Id or v5.Id == "" or self._loadedItems[v5.Id] then
			continue
		end

		self._loadedItems[v5.Id] = true
		local clone = self.templateButton:Clone()
		clone.Name = string.format("%08d_%s", i, v5.Name)
		clone.SelectedIcon.Visible = false

		if self._currentCategory == "Outfits" then
			clone:SetAttribute("ShirtId", v5.ShirtId)
			clone:SetAttribute("PantsId", v5.PantsId)
		else
			clone:SetAttribute("Id", v5.Id)
		end

		clone.Icon.Image = "rbxthumb://type=Asset&id=" .. v5.Id .. "&w=150&h=150"
		clone.LayoutOrder = (self._regularLayoutOffset or 0) + i

		if v5.RPButton then
			clone.RP.Visible = true
		end

		clone.Parent = self.Instance
		local v6 = v5
		self._clickJanitor:Add(clone.Activated:Connect(function()
			if self.selectDebounce then
				return
			end

			self.selectDebounce = true
			task.delay(0.5, function()
				self.selectDebounce = false
			end)

			if self._currentCategory == "Outfits" then
				WearingController.WearOutfit(v6.ShirtId, v6.PantsId, v6.Accessories)
			elseif self._currentCategory:lower():match("pant") then
				WearingController.WearPants(v6.Id)
			elseif self._currentCategory:lower():match("shirt") then
				WearingController.WearShirt(v6.Id)
			else
				WearingController.WearAsset(v6.Id, true)
			end
		end))
		task.wait(0.01)
	end

	if _currentCategory == self._currentCategory then
		self._currentIndex = v4 + 1
		local uIGridLayout = self.Instance:FindFirstChild("UIGridLayout")
		self.Instance.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
	end

	self._loadingBatch = false
end

function v:CreateShowcasedItem(layoutOrder: number, data, callback)
	if not (data and data.Name) then
		return
	end

	local clone = self.templateButton:Clone()
	clone.Name = string.format("%08d_%s", layoutOrder, data.Name)
	clone:SetAttribute("Id", data.Id)
	clone.SelectedIcon.Visible = false
	local itemType = data.ItemType

	if data.ItemType == "Bundle" then
		clone:SetAttribute("IsBundle", true)
		local v4 = ""
		itemType = "BundleThumbnail"

		for _, v5 in data.BundledItems or {} do
			if v5.Type ~= "Asset" or not v5.Name or v5.Name:lower():match("mood") then
				continue
			end

			v4 ..= v5.Id .. ","
		end

		clone:SetAttribute("BundledItems", v4)
	end

	clone.Icon.Image = `rbxthumb://type={itemType}&id={data.Id}&w=150&h=150`
	clone.LayoutOrder = layoutOrder
	local emptyMesh = data.CornerIconData and data.CornerIconData.Image and clone:FindFirstChild("EmptyMesh")

	if emptyMesh then
		emptyMesh.Visible = true
		emptyMesh.Image = data.CornerIconData.Image

		if data.CornerIconData.Position then
			emptyMesh.Position = UDim2.new(
				data.CornerIconData.Position.X.Scale,
				data.CornerIconData.Position.X.Offset,
				data.CornerIconData.Position.Y.Scale,
				data.CornerIconData.Position.Y.Offset
			)
		end

		if data.CornerIconData.Size then
			emptyMesh.Size = UDim2.new(
				data.CornerIconData.Size.X.Scale,
				data.CornerIconData.Size.X.Offset,
				data.CornerIconData.Size.Y.Scale,
				data.CornerIconData.Size.Y.Offset
			)
		end
	end

	if callback then
		callback(clone)
	end

	clone.Parent = self.Instance
	local id = data.Id
	local assetType = data.AssetType
	self._clickJanitor:Add(clone.Activated:Connect(function()
		if self.selectDebounce then
			return
		end

		self.selectDebounce = true
		task.delay(0.5, function()
			self.selectDebounce = false
		end)

		if clone:GetAttribute("IsBundle") then
			WearingController.WearBundle(id)
		elseif assetType == "Shirt" then
			WearingController.WearShirt(id)
		elseif assetType == "Pants" then
			WearingController.WearPants(id)
		else
			WearingController.WearAsset(id, true)
		end
	end))
	return clone
end

function v:LoadShowcasedCategoryItems()
	local v4 = v3.getConfig()[self.Instance:GetAttribute("Subcategory")]

	if not v4 then
		return
	end

	for _, v5 in v4 do
		self.currentItemLayoutOrder += 1
		local clone = self.templateButton:Clone()
		clone:SetAttribute("ShowcasedItemCategory", true)
		clone.Name = string.format("%08d_ShowcasedCategory", self.currentItemLayoutOrder)
		clone.SelectedIcon.Visible = false
		clone.Icon.Image = v5.CategoryIcon
		clone.Parent = self.Instance
		local v6 = v5

		local function ApplyShowcasedItemCatBorder(clone2)
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Parent = clone2
			uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			uIStroke.LineJoinMode = Enum.LineJoinMode.Round
			uIStroke.Thickness = 0.02
			uIStroke.Transparency = 0.5
			uIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner

			if v6.BorderColor then
				uIStroke.Color = Color3.fromRGB(v6.BorderColor[1], v6.BorderColor[2], v6.BorderColor[3])
			end
		end

		ApplyShowcasedItemCatBorder(clone)
		local currentItemLayoutOrder = self.currentItemLayoutOrder
		clone.LayoutOrder = currentItemLayoutOrder
		local v7 = nil
		local v8 = v5
		local ApplyShowcasedItemCatBorder2 = ApplyShowcasedItemCatBorder
		self._clickJanitor:Add(clone.Activated:Connect(function()
			if v7 then
				v7:Destroy()
				v7 = nil
			else
				v7 = Janitor.new()

				for k, content in v8.Contents do
					local clone2 = table.clone(content)
					clone2.ItemType = v8.BundledItems and "Bundle" or "Asset"
					clone2.AssetType = v8.AssetType

					if clone2.BundledItems then
						for k2, bundledItem in clone2.BundledItems do
							if not (bundledItem.Id and bundledItem.Name) then
								warn(bundledItem)
								error("Bundled item inside of an RC-based Showcased Item Category must have an Id and Name field! Item data is above.")
							end

							local clone3 = table.clone(bundledItem)
							clone3.Type = "Asset"
							clone2.BundledItems[k2] = clone3
						end
					end

					local showcasedItem = self:CreateShowcasedItem(
						currentItemLayoutOrder + k,
						clone2,
						ApplyShowcasedItemCatBorder2
					)

					if showcasedItem then
						v7:Add(showcasedItem)
					end
				end
			end
		end))
		self.currentItemLayoutOrder += #v5.Contents
	end
end

function v:Build(itemsToLoad, currentCategory: string)
	self:ClearList()
	self._itemsToLoad = itemsToLoad
	self._currentIndex = 1
	self._currentCategory = currentCategory
	self.currentItemLayoutOrder = 0
	local uIGridLayout = self.Instance:FindFirstChild("UIGridLayout")

	if currentCategory == "Outfits" then
		uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIGridLayout.CellSize = UDim2.new(0.323, 0, 1, 0)
	else
		uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIGridLayout.CellSize = UDim2.new(0.24, 0, 1, 0)
	end

	uIGridLayout.CellPadding = UDim2.new(0.01, 0, 0, 0)
	self:LoadShowcasedCategoryItems()
	self._regularLayoutOffset = self.currentItemLayoutOrder
	self:LoadNextBatch()
end

function v:Start()
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	local config = v2.getConfig()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if self:ShouldLoadMoreItems() then
			self:LoadNextBatch()
		end
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if not self.Instance.Visible then
			self:ClearList()
			return
		end

		local subcategory = self.Instance:GetAttribute("Subcategory")

		if not config[subcategory] then
			return
		end

		self:Build(config[subcategory], subcategory)
	end))
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"AvatarEditorMenu",
		AvatarEditorMenu
	)
	self._Janitor:Add(waitForAncestorComponent.OnVisibleChanged:Connect(function(p)
		if not p then
			self:ClearList()
		end
	end))
end

function v:Refresh()
	if self._currentCategory then
		self:Build(v2.getConfig()[self._currentCategory], self._currentCategory)
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v