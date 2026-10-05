local Catalog = {}
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local AvatarEditorService = game:GetService("AvatarEditorService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local frame = script.Parent:WaitForChild("Frame")
local inventory = frame:WaitForChild("Inventory")
local viewport = frame:WaitForChild("Viewport")
local image = viewport:WaitForChild("Image")
local clone = image:WaitForChild("Dummy"):Clone()
local Descriptors = require(script.Descriptors)
local Bundles = require(script.Bundles)
local Outfit = require(script.Outfit)
local UI = require(game.ReplicatedStorage.Modules.UI)
local Money = require(game.ReplicatedStorage.Modules.Money)
local Network = require(game.ReplicatedStorage.Modules.Network)
local Gamepad = require(game.ReplicatedStorage.Modules.Gamepad)
local v = {}
image.Dummy:Destroy()
clone.Parent = image
Gamepad:CreateGroup(frame)

function Catalog:Update()
	if not (self.Target and self.Target.Character and self.Target.Character:FindFirstChild("Humanoid")) then
		return
	end

	local appliedDescription = self.Target.Character.Humanoid:GetAppliedDescription()

	if not appliedDescription then
		return
	end

	self.Description = appliedDescription
	self:Clear()
	self:UpdateViewport(appliedDescription)
	frame.Visible = true
	self:AddItemsFromDescription(appliedDescription)
	viewport.Title.Text = self.Target.Name .. "'s Avatar"
end

function Catalog:Test(p)
	local humanoidDescriptionFromUserId = game.Players:GetHumanoidDescriptionFromUserId(p)
	self.Description = humanoidDescriptionFromUserId
	self:Clear()
	self:UpdateViewport(humanoidDescriptionFromUserId)
	self:AddItemsFromDescription(humanoidDescriptionFromUserId)
	viewport.Title.Text = p .. " USER"
end

function Catalog:SetTarget(target)
	self.Target = target
end

function Catalog:Clear()
	for _, frame2 in inventory:GetChildren() do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end

	viewport.Title.Text = "Loading..."
	viewport.Worth.Text = ""
end

function Catalog:ResolvePrice(p, p2, p3)
	if p3 and p3.PriceStatus == "Off Sale" then
		p2 = nil
	end

	p.Text = p2 == 0 and "FREE" or not p2 and "OFFSALE" or "" .. Money(p2, true) or "OFFSALE"
	p.TextColor3 = p2 and Color3.fromRGB(135, 255, 173) or Color3.fromRGB(255, 61, 61)
end

function Catalog:AddItemFromAssetId(state, names)
	local v2 = true
	local v3 = "normal"
	local clone2 = script.Sample:Clone()
	local lowestPrice = state.LowestPrice or state.Price
	local index = state.ItemRestrictions and table.find(state.ItemRestrictions, "Limited") or state.ItemRestrictions and table.find(
		state.ItemRestrictions,
		"LimitedUnique"
	)

	if state.Name == "Headless Head" then
		state.PriceStatus = nil
		lowestPrice = 31000
	end

	clone2.Name = state.Id
	clone2.Title.Text = state.Name
	clone2.Icon.Image = UI:FormatAvatarDecal(state.Id)
	clone2.LayoutOrder = -(lowestPrice or -10)
	clone2:SetAttribute("AssetId", state.Id)
	self:ResolvePrice(clone2.Price, lowestPrice, state)
	clone2.Limited.Visible = index

	if state.PriceStatus == "Off Sale" then
		clone2.LayoutOrder += 500
	end

	task.spawn(function()
		if self:DoesPlayerOwnAsset(state.Id) then
			clone2.Owned.Visible = true
			clone2.LayoutOrder = math.abs(clone2.LayoutOrder) + 1000
		end
	end)
	local id = state.Id

	if (lowestPrice == 0 or not lowestPrice) and table.find(Bundles.AssetTypes, Enum.AvatarAssetType[state.AssetType]) and not v[state.Id] then
		local bundleFromAsset = self:GetBundleFromAsset(state.Name)

		if bundleFromAsset then
			lowestPrice = bundleFromAsset.Price

			if table.find(names, bundleFromAsset.Name) then
				v2 = false
			else
				table.insert(names, bundleFromAsset.Name)
			end

			self:ResolvePrice(clone2.Price, lowestPrice)
			clone2.LayoutOrder -= 500
			clone2:SetAttribute("BundleId", bundleFromAsset.Id)
			id = bundleFromAsset.Id
			v3 = "bundle"
		else
			v[state.Id] = true
		end
	end

	UI:Bind(clone2.Button)
	clone2.Button.MouseEnter:connect(function()
		TweenService:Create(clone2.Overlay, TweenInfo.new(0.2), {
			BackgroundTransparency = 0.7
		}):Play()
		TweenService:Create(clone2.Title, TweenInfo.new(0.2), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(clone2.Title.UIStroke, TweenInfo.new(0.2), {
			Transparency = 0.2
		}):Play()
	end)
	clone2.Button.MouseLeave:connect(function()
		TweenService:Create(clone2.Overlay, TweenInfo.new(0.2), {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(clone2.Title, TweenInfo.new(0.2), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(clone2.Title.UIStroke, TweenInfo.new(0.2), {
			Transparency = 1
		}):Play()
	end)
	clone2.Button.MouseButton1Click:connect(function()
		if clone2.Owned.Visible then
			return self:Error("You already own this item!")
		end

		if clone2.Price.Text == "OFFSALE" then
			return self:Error("This item is off sale!")
		end

		if v3 == "normal" then
			if index then
				return self:Error("You cannot buy limiteds currently.")
			end

			MarketplaceService:PromptPurchase(localPlayer, id)
		elseif v3 == "bundle" then
			MarketplaceService:PromptBundlePurchase(localPlayer, id)
		end
	end)
	clone2.Parent = inventory
	return clone2, v2 and lowestPrice or 0
end

function Catalog:AddItemsFromDescription(object2)
	local v2 = {}
	local v3 = {}
	local total = 0

	for _, descriptor in Descriptors do
		local v4 = tonumber(object2[descriptor])

		if v4 and v4 ~= 0 then
			table.insert(v2, v4)
		end
	end

	for _, v4 in object2:GetAccessories(true) do
		table.insert(v2, v4.AssetId)
	end

	local success, result = pcall(function()
		return AvatarEditorService:GetBatchItemDetails(v2, Enum.AvatarItemType.Asset)
	end)

	if not success then
		return self:Error("Failed to fetch items")
	end

	for _, v4 in result do
		local _, v5 = self:AddItemFromAssetId(v4, v3)
		total += v5
	end

	viewport.Worth.Text = "Worth: " .. Money(total, true)
end

function Catalog:FormatBundleName(value)
	for _, v2 in Bundles.Filter do
		value = value:gsub(v2, "")
	end

	local v2 = value:gsub("-", " "):gsub("  ", "")

	if v2:sub(-1) == " " then
		return (v2:sub(1, -2))
	end

	return v2
end

function Catalog:GetBundleFromAsset(p)
	local formatBundleName = self:FormatBundleName(p)

	if not formatBundleName then
		return
	end

	if Bundles.Cache[formatBundleName] then
		return Bundles.Cache[formatBundleName]
	end

	local catalogSearchParams = CatalogSearchParams.new()
	catalogSearchParams.BundleTypes = { Enum.BundleType.BodyParts }
	catalogSearchParams.SearchKeyword = formatBundleName
	catalogSearchParams.SortType = Enum.CatalogSortType.Relevance
	local success, result = pcall(function()
		local catalog = AvatarEditorService:SearchCatalog(catalogSearchParams)
		local _, v2 = next(catalog:GetCurrentPage())

		if v2 then
			Bundles.Cache[formatBundleName] = v2
			return v2
		else
			Bundles.Cache[formatBundleName] = false
		end
	end)

	if success and result then
		return result
	end

	return self:Error("Catalog error while trying to fetch bundle")
end

function Catalog:DoesPlayerOwnAsset(p)
	local success, result = pcall(function()
		return MarketplaceService:PlayerOwnsAsset(localPlayer, p)
	end)

	if success then
		return result
	end

	warn("[PlayerOwnAsset error]", result)
end

function Catalog:ConstructSafeOutfit(instance)
	local humanoidDescriptionFromUserId = game.Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
	local clone2 = instance:Clone()
	local v2 = {}

	for _, v3 in instance:GetAccessories(true) do
		if self:DoesPlayerOwnAsset(v3.AssetId) then
			table.insert(v2, v3)
		end
	end

	clone2:SetAccessories(v2, true)

	for _, property in Outfit.Properties do
		local v3 = instance[property]

		if v3 == 0 or self:DoesPlayerOwnAsset(v3) then
			continue
		end

		clone2[property] = 0
	end

	clone2:SetEmotes(humanoidDescriptionFromUserId:GetEmotes())
	clone2:SetEquippedEmotes(humanoidDescriptionFromUserId:GetEquippedEmotes())
	return clone2
end

function Catalog:Init()
	self:SetupViewport()
	self:InitInventoryScrolling()
	self:InitMarketHandler()
	self:InitButtons()
	self:InitUI()
end

function Catalog:GetViewportCenter()
	return clone.HumanoidRootPart.CFrame
end

function Catalog:GetDefaultZoom()
	return 5 + clone:GetExtentsSize().Y
end

function Catalog:RefreshViewport()
	self.ViewportZoom = self:GetDefaultZoom()
	self.ViewportAngle = Vector2.new(0, 0)
end

function Catalog:UpdateViewport(p)
	clone.Parent = workspace
	clone.Humanoid:ApplyDescription(p)
	clone.Parent = image
	self:RefreshViewport()
end

function Catalog:SetupViewport()
	self.ViewportZoom = 10
	self.ViewportAngle = Vector2.new(0, 0)
	local camera = Instance.new("Camera")
	camera.Name = "ViewportCamera"
	camera.Parent = image
	image.CurrentCamera = camera
	camera.CFrame = CFrame.new(
		clone.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10).Position,
		clone.HumanoidRootPart.Position
	)
	camera.FieldOfView = 40
	local flag = false
	local vector = Vector2.new(0, 0)
	image.InputBegan:connect(function(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			vector = Vector2.new(p.Position.X, p.Position.Y)
			flag = true
		end
	end)
	image.InputEnded:connect(function(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			flag = false
		end
	end)
	image.InputChanged:connect(function(p)
		if p.UserInputType == Enum.UserInputType.MouseWheel then
			self.ViewportZoom += -p.Position.Z * 3
		end
	end)
	viewport:WaitForChild("Reset").MouseButton1Click:connect(function()
		self:RefreshViewport()
	end)
	UI:Bind(viewport.Reset)
	local RunService = game:GetService("RunService")
	RunService.Heartbeat:connect(function(p)
		if not frame.Visible then
			return
		end

		if flag then
			local absoluteSize = frame.Parent.AbsoluteSize
			local vector2 = Vector2.new(mouse.X, mouse.Y)
			local v2 = vector2 - vector
			self.ViewportAngle += v2 / absoluteSize * 15
			vector = vector2
		end

		self.ViewportAngle = Vector2.new(
			self.ViewportAngle.X % 6.283185307179586,
			(math.clamp(self.ViewportAngle.Y, -1.2707963267948965, 1.2707963267948965))
		)
		self.ViewportZoom = math.clamp(self.ViewportZoom, 3, self:GetDefaultZoom() + 10)
		local viewportCenter = self:GetViewportCenter()
		local cframe = CFrame.new(
			viewportCenter * CFrame.Angles(0, -self.ViewportAngle.X, 0) * CFrame.Angles(self.ViewportAngle.Y, 0, 0) * CFrame.new(
				0,
				0,
				-self.ViewportZoom
			).Position,
			viewportCenter.Position
		)
		camera.CFrame = camera.CFrame:lerp(cframe, p * 15)
	end)
end

function Catalog:InitInventoryScrolling()
	inventory:WaitForChild("Grid"):GetPropertyChangedSignal("AbsoluteContentSize"):connect(function()
		local v2 = inventory.Grid.AbsoluteCellCount.Y * (inventory.Grid.CellSize.Y.Offset + inventory.Grid.CellPadding.Y.Offset)
		inventory.CanvasSize = UDim2.new(0, 0, 0, v2 + 10)
	end)
end

function Catalog:InitMarketHandler()
	MarketplaceService.PromptBundlePurchaseFinished:connect(function(_, p, p2)
		if p2 then
			for _, frame2 in inventory:GetChildren() do
				if not (frame2:IsA("Frame") and frame2:GetAttribute("BundleId") == p) then
					continue
				end

				frame2.Owned.Visible = true
				frame2.LayoutOrder = math.abs(frame2.LayoutOrder) + 1000
			end
		end
	end)
	MarketplaceService.PromptPurchaseFinished:connect(function(_, p, p2)
		if p2 then
			for _, frame2 in inventory:GetChildren() do
				if not (frame2:IsA("Frame") and frame2:GetAttribute("AssetId") == p) then
					continue
				end

				frame2.Owned.Visible = true
				frame2.LayoutOrder = math.abs(frame2.LayoutOrder) + 1000
			end
		end
	end)
end

local v2 = {
	"Head",
	"LeftArm",
	"LeftLeg",
	"RightArm",
	"RightLeg",
	"Torso"
}

function Catalog:InitButtons()
	frame:WaitForChild("Wear").MouseButton1Click:connect(function()
		if self.Description then
			AvatarEditorService:PromptSaveAvatar(self.Description, Enum.HumanoidRigType.R15)
		end
	end)
	frame:WaitForChild("Buy").MouseButton1Click:connect(function()
		if self.Description then
			local v3 = {}

			for _, v4 in self.Description:GetAccessories(true) do
				table.insert(v3, {
					Id = tostring(v4.AssetId),
					Type = Enum.MarketplaceProductType.AvatarAsset
				})
			end

			table.insert(v3, {
				Id = tostring(self.Description.Shirt),
				Type = Enum.MarketplaceProductType.AvatarAsset
			})
			table.insert(v3, {
				Id = tostring(self.Description.Pants),
				Type = Enum.MarketplaceProductType.AvatarAsset
			})
			local v4 = {}
			local ids = {}

			for _, v5 in v2 do
				local v6 = self.Description[v5]

				if v6 ~= 0 then
					table.insert(v4, v6)
				end
			end

			local success, result = pcall(function()
				return AvatarEditorService:GetBatchItemDetails(v4, Enum.AvatarItemType.Asset)
			end)

			if not success then
				return self:Error("Failed to fetch items")
			end

			for _, v5 in result do
				local id = self:GetBundleFromAsset(v5.Name).Id

				if not table.find(ids, id) then
					table.insert(ids, id)
				end
			end

			for _, v5 in ids do
				table.insert(v3, {
					Id = tostring(v5),
					Type = Enum.MarketplaceProductType.AvatarBundle
				})
			end

			Network:fire("PromptBulkPurchase", v3)
		end
	end)
	frame:WaitForChild("CopyOutfit").MouseButton1Click:connect(function()
		if self.Description then
			AvatarEditorService:PromptCreateOutfit(self:ConstructSafeOutfit(self.Description), Enum.HumanoidRigType.R15)
		end
	end)
	AvatarEditorService.PromptSaveAvatarCompleted:connect(function(p)
		if p == Enum.AvatarPromptResult.Success then
			Network:fire("RefreshCharacter")
			return self:Notify("You successfully wore this outfit!")
		end

		if p == Enum.AvatarPromptResult.Failed then
			return self:Error("You failed to wear this outfit!")
		end

		local _ = p == Enum.AvatarPromptResult.PermissionDenied
	end)
	AvatarEditorService.PromptCreateOutfitCompleted:connect(function(p)
		if p == Enum.AvatarPromptResult.Success then
			return self:Notify("You successfully copied this outfit!")
		end

		if p == Enum.AvatarPromptResult.Failed then
			return self:Error("You failed to copy this outfit!")
		end

		local _ = p == Enum.AvatarPromptResult.PermissionDenied
	end)
	UI:Bind(frame.Wear)
	UI:Bind(frame.CopyOutfit)
end

function Catalog:InitUI()
	frame:WaitForChild("Close").MouseButton1Click:connect(function()
		frame.Visible = false
	end)
	frame:GetPropertyChangedSignal("Visible"):connect(function()
		if frame.Visible then
			script.Open:Play()
		end
	end)
	UI:Bind(frame.Close)
end

function Catalog:Error(p)
	return _G.DisplayError(p, 5)
end

function Catalog:Notify(p)
	return _G.DisplayText(p, 5)
end

Catalog:Init()
return Catalog