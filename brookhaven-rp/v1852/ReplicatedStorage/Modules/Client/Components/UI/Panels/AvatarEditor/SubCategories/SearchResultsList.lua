game:GetService("AvatarEditorService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "SearchResultsList"
})
local v2 = false
local count = 0
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local ForbiddenWordsConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.ForbiddenWords.ForbiddenWordsConfig)
local v3 = {
	All = {
		Enum.AvatarAssetType.FaceAccessory,
		Enum.AvatarAssetType.Hat,
		Enum.AvatarAssetType.BackAccessory,
		Enum.AvatarAssetType.HairAccessory,
		Enum.AvatarAssetType.WaistAccessory,
		Enum.AvatarAssetType.ShoulderAccessory
	},
	Outfits = { Enum.AvatarAssetType.Shirt, Enum.AvatarAssetType.Pants },
	Shirt = { Enum.AvatarAssetType.Shirt },
	Pants = { Enum.AvatarAssetType.Pants },
	Hat = { Enum.AvatarAssetType.Hat }
}

function v.IsWearing(_, p: number)
	return WearingController.IsWearing(p)
end

function v.IsForbidden(_, value: string)
	local config = ForbiddenWordsConfig.getConfig()
	local v4 = {}

	for k in value:lower():gmatch("%S+") do
		table.insert(v4, k)
	end

	for _, v5 in v4 do
		for _, word in config.Words do
			if v5 == word:lower() then
				return true
			end
		end
	end

	return false
end

function v:GetTableRepresentationOfSearchParams(data)
	if data then
		return {
			SearchKeyword = data.SearchKeyword,
			CreatorName = data.CreatorName,
			CreatorType = data.CreatorType,
			MinPrice = data.MinPrice,
			MaxPrice = data.MaxPrice,
			IncludeOffSale = data.IncludeOffSale,
			Limit = data.Limit,
			AssetTypes = data.AssetTypes,
			BundleTypes = data.BundleTypes,
			CategoryFilter = data.CategoryFilter,
			SortType = data.SortType,
			SortAggregation = data.SortAggregation
		}
	end

	return nil
end

function v:GetAssetTypes(value: string)
	if v3[value] then
		return v3[value]
	end

	for k, v4 in {
		Shirt = v3.Shirt,
		Pants = v3.Pants
	} do
		if string.find(value, k) then
			return v4
		end
	end

	return { Enum.AvatarAssetType[value .. "Accessory"] }
end

function v:GetCatalogSearchParams(searchKeyword: string, p: string)
	local catalogSearchParams = CatalogSearchParams.new()
	catalogSearchParams.Limit = 60
	catalogSearchParams.SearchKeyword = searchKeyword
	local assetTypes = self:GetAssetTypes(p)
	catalogSearchParams.IncludeOffSale = false
	catalogSearchParams.AssetTypes = assetTypes
	return catalogSearchParams
end

function v:ShouldLoadMoreItems()
	local instance = self.Instance
	local Y = instance.CanvasPosition.Y
	return instance.CanvasSize.Y.Offset - (Y + instance.AbsoluteSize.Y) < 100
end

function v:UpdateCanvasSize()
	local absoluteContentSize = self.Instance:FindFirstChild("UIGridLayout").AbsoluteContentSize
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, absoluteContentSize.Y)
end

function v:ProcessSearchResult(p)
	if not (p and p.Id and self.Instance.Visible and v2) then
		return false
	end

	self:Build(p)
	self:UpdateCanvasSize()
	task.wait(0.01)
	return true
end

function v:ProcessSearchPage(object2)
	for _, v4 in object2:GetCurrentPage() do
		if not self:ProcessSearchResult(v4) then
			return false
		end
	end

	return true
end

function v:CleanupSearch()
	for _, button in self.Instance:GetChildren() do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	self.Instance.CanvasPosition = Vector2.new(0, 0)
	self._clickJanitor:Cleanup()
	self._clickJanitor = Janitor.new()
end

function v:LoadCatalogSearchResults(p: string, p2: string)
	v2 = false
	count += 1
	local v4 = count
	task.wait()
	self:CleanupSearch()
	local instantiableComponent = ComponentUtil.CloneInstantiableComponent("LoadingSpinner")

	if instantiableComponent then
		instantiableComponent.Parent = self.Instance.Parent
	end

	v2 = true
	local catalogSearchParams = self:GetCatalogSearchParams(p, p2)
	local uIGridLayout = self.Instance:FindFirstChild("UIGridLayout")
	uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local tableRepresentationOfSearchParams = self:GetTableRepresentationOfSearchParams(catalogSearchParams)

	if tableRepresentationOfSearchParams then
		local count2 = 0
		local v5 = true
		local v6 = 1
		local v7 = false

		while count2 <= 500 and v2 and v4 == count and v5 do
			v5 = Remotes.invokeServer("PerformCatalogSearch", tableRepresentationOfSearchParams, v6)

			if (not v5 or typeof(v5) ~= "table") and (not v5 or typeof(v5) ~= "table") or not self.Instance.Visible or not v2 or v4 ~= count or not self.avatarEditorMenu.Instance.Visible then
				break
			end

			local v8 = true

			for _, v10 in v5 do
				if v2 and v4 == count and self:ProcessSearchResult(v10) then
					instantiableComponent:Destroy()
					v7 = true
				else
					v8 = false
					break
				end
			end

			if not v8 then
				break
			end

			count2 += 1

			if not self.Instance.Visible or not v2 or v4 ~= count then
				break
			end

			if not self:ShouldLoadMoreItems() then
				local v10

				repeat
					task.wait(0.1)
					v10 = not self.Instance.Visible or not v2 or v4 ~= count
				until self:ShouldLoadMoreItems() or v10

				if v10 then
					break
				end
			end

			v6 += 1
		end

		if v4 == count then
			v2 = false
		end

		instantiableComponent:Destroy()

		if count2 < 1 then
			warn("Error loading catalog search results...")
			NotificationController.NotifyEditor("PLEASE TRY AGAIN IN A FEW SECONDS.")
		else
			if v4 ~= count or v7 then
				return
			end

			NotificationController.NotifyEditor("No results found")
		end
	else
		instantiableComponent:Destroy()
		NotificationController.NotifyEditor("PLEASE TRY AGAIN IN A FEW SECONDS.")
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self.selectDebounce = false
	WearingController.OnWearingUpdated:Connect(function(_)
		if not self.Instance.Visible then
			return
		end

		for _, button in self.Instance:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local name = tonumber(button.Name)
			UIAnimationEffects.SetVisibilityWithPopInOutFX(button.SelectedIcon, self:IsWearing(name))
		end
	end)
end

function v.Refresh(p)
	p.Instance.Visible = false
	p.Instance.Visible = true
end

function v:Build(p)
	local clone = self.templateButton:Clone()
	clone.Name = p.Id
	clone.Icon.Image = "rbxthumb://type=Asset&id=" .. p.Id .. "&w=150&h=150"

	if p.Premium then
		clone.PremiumMesh.Visible = true
	end

	UIAnimationEffects.SetVisibilityWithPopInOutFX(clone.SelectedIcon, self:IsWearing(p.Id))

	local function onActivated()
		if self.selectDebounce then
			return
		end

		self.selectDebounce = true
		task.delay(0.5, function()
			self.selectDebounce = false
		end)
		WearingController.WearAsset(p.Id, true)
	end

	clone.Parent = self.Instance
	self._clickJanitor:Add(clone.Activated:Connect(onActivated))
end

function v:Destroy()
	v2 = false
	count += 1
	self:CleanupSearch()
	self.Instance.Visible = false
end

function v:Start()
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	self.avatarEditorMenu = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"AvatarEditorMenu",
		AvatarEditorMenu
	)
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if not self.Instance.Visible then
			self:Destroy()
			return
		end

		local searchText = self.Instance:GetAttribute("SearchText")
		local searchCategory = self.Instance:GetAttribute("SearchCategory")
		self.avatarEditorMenu:SetLastOpenedSubcategory("SearchResultsList")

		if searchCategory == "All" then
			self.avatarEditorMenu:UnsetCurrentSubcategory()
		end

		self:LoadCatalogSearchResults(searchText, searchCategory)
	end))
end

return v