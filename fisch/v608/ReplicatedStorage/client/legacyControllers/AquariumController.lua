function comma_value(p)
	local v = math.ceil(p)

	repeat
		local v2
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")
game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local legacyControllers = ReplicatedStorage.client.legacyControllers
local localPlayer2 = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local modules = shared.modules
local aquarium = localPlayer2.PlayerGui:WaitForChild("hud"):WaitForChild("safezone").Aquarium
local container = aquarium.Container.ItemList.List.Container
local list = aquarium.Container.YourListing.List
local pricePrompt = aquarium.PricePrompt
local template = container.Template
template.Parent = nil
local add = list.Add
add.Parent = nil
local item = list.Item
item.Parent = nil
local Monetization = require(shared.Monetization)
local DataController = require(legacyControllers.DataController)
local GeneralUtils = require(shared.utils.GeneralUtils)
local Net = require(packages.Net)
require(packages.Observers)
local Trove = require(packages.Trove)
require(packages.Timer)
require(ReplicatedStorage.shared.utils.RomanNumerals)
require(ReplicatedStorage.client.modules.ViewportModule)
local NotificationController = require(legacyControllers.NotificationController)
local FishRoamer = require(script.FishRoamer)
require(ReplicatedStorage.shared.utils.assets)
local viewportModule = require(script.viewportModule)
local fish = require(modules.library.fish)
require(modules.fishing.mutations)
local ConfirmationController = require(legacyControllers.ConfirmationController)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
require(legacyControllers.WorldController)
local FishModel = require(ReplicatedStorage.shared.modules.FishModel)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local remoteEvent = Net:RemoteEvent("Aquarium/PlaceFish")
local remoteEvent2 = Net:RemoteEvent("Aquarium/RemoveFish")
local remoteEvent3 = Net:RemoteEvent("Aquarium/PurchaseFish")
local remoteEvent4 = Net:RemoteEvent("Aquarium/FishUpdated")
local remoteFunction = Net:RemoteFunction("Aquarium/GetFish")
local remoteEvent5 = Net:RemoteEvent("Aquarium/Open")
local AquariumController = {
	_openTrove = Trove.new()
}

local function getDisplayName(fishData)
	return (`{FischUtils.ItemDisplay(fishData, {
		rich = true,
		disable_newlines = true,
		rarity_color = true
	})} <font color='#b3b3b3'><b>({NumberUtils:Comma(fishData.sub.Weight or 0)}kg)</b></font>`)
end

function AquariumController:TogglePriceScreen(visible)
	if not self.SelectedGUID then
		return
	end

	pricePrompt.Visible = visible
	aquarium.Container.Visible = not visible
	DataController.InventoryReplicator:WaitForLoaded()
	local v = DataController.InventoryReplicator:TryIndex({ "Inventory", self.SelectedGUID })

	if not v then
		return
	end

	pricePrompt.title.Text = `List {v.name} for Sale?`
	pricePrompt.question.Text = `How much would you like to list {v.name} for sale for?`
end

function AquariumController:UpdateMyFish()
	if self.MyFishTrove then
		self.MyFishTrove:Destroy()
	end

	local v = self.ActiveFish[tostring(localPlayer.UserId)] or {}
	local maid = self._openTrove:Extend()
	self.MyFishTrove = maid

	local function createAddButton(i)
		local clone = add:Clone()
		clone.Parent = list
		local visible = false
		clone.Locked.Visible = visible
		maid:Add(clone)
		maid:Add(DataController.PlayerDataReplicator:Observe({ "ReplicatedNumbers", "ExtraAquariumSlots" }, function(p)
			if not p then
				return
			end

			visible = p < (i > 2 and i - 2 or 0)
			clone.Locked.Visible = visible
		end))
		maid:Connect(clone.Activated, function()
			if visible then
				MarketplaceService:PromptProductPurchase(localPlayer, Monetization.products.AquariumSlot.ProductId)
				return
			end

			local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
			local link = tool and tool:FindFirstChild("link")

			if not link then
				NotificationController:Notify("You don't have a fish in your hand!", 3)
				return
			end

			DataController.InventoryReplicator:WaitForLoaded()
			local v3 = DataController.InventoryReplicator:TryIndex({ "Inventory", link.Value })

			if not v3 then
				NotificationController:Notify("You don't have a fish in your hand!", 3)
				return
			end

			local v4 = fish[v3.name]

			if v4 and not (v4.IsCrate or v4.Untradeable) then
				self.SelectedGUID = link.Value
				self:TogglePriceScreen(true)
			else
				NotificationController:Notify("This fish cannot be sold!", 3)
			end
		end)
	end

	local function createItemButton(i, p)
		if not (p and p.fishData) then
			return
		end

		local clone = item:Clone()
		clone.Parent = list
		maid:Add(clone)
		maid:Connect(clone.Activated, function()
			remoteEvent2:FireServer(i)
		end)
		local camera = Instance.new("Camera")
		camera.Parent = clone.vpbg.vp
		clone.vpbg.vp.CurrentCamera = camera
		maid:Add(camera)
		local folder = FishModel.Create({
			Name = p.fishData.name,
			ItemData = p.fishData.sub,
			ResizeArgs = {
				MaxSize = 14
			},
			CastShadow = false,
			RemoveScripts = true
		})

		if not folder.PrimaryPart or folder.PrimaryPart.Name ~= "Center" then
			folder.PrimaryPart = folder:FindFirstChild("Center") or folder.PrimaryPart
		end

		folder:PivotTo(CFrame.identity)
		folder.Parent = clone.vpbg.vp
		maid:Add(folder)

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
				part.Material = Enum.Material.Plastic
			end
		end

		local v2 = viewportModule.new(clone.vpbg.vp, camera)
		local boundingBox, _ = folder:GetBoundingBox()
		v2:SetModel(folder)
		local v3 = not fish[p.fishData.name].ViewportSizeOffset and 1 or fish[p.fishData.name].ViewportSizeOffset
		local v4 = v2:GetFitDistance(boundingBox.Position) * v3
		local cframe = CFrame.new()
		camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, v4)
		clone.Label.Text = getDisplayName(p.fishData)
		clone.YourCurrency.TextBox.Text = comma_value(p.price)
	end

	for i = 1, 3 do
		if v[i] then
			createItemButton(i, v[i])
		else
			createAddButton(i)
		end
	end
end

function AquariumController:UpdateAquariumUI()
	local v = {}

	for _, v2 in self.ActiveFish do
		for _, v3 in v2 do
			v[v3.listingId] = v3
		end
	end

	for _, button in container:GetChildren() do
		if not button:IsA("ImageButton") or v[button.Name] then
			continue
		end

		button:Destroy()
	end

	for childName, v2 in v do
		if container:FindFirstChild(childName) then
			continue
		end

		local clone = template:Clone()
		clone.Name = childName
		clone.Parent = container
		self._openTrove:Add(clone)
		local extended = self._openTrove:Extend()
		extended:AttachToInstance(clone)
		local camera = Instance.new("Camera")
		camera.Parent = clone.vpbg.vp
		clone.vpbg.vp.CurrentCamera = camera
		extended:Add(camera)
		local folder = FishModel.Create({
			Name = v2.fishData.name,
			ItemData = v2.fishData.sub,
			ResizeArgs = {
				MaxSize = 14
			},
			CastShadow = false
		})

		if not folder.PrimaryPart or folder.PrimaryPart.Name ~= "Center" then
			folder.PrimaryPart = folder:FindFirstChild("Center") or folder.PrimaryPart
		end

		folder:PivotTo(CFrame.identity)
		folder.Parent = clone.vpbg.vp
		extended:Add(folder)

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
				part.Material = Enum.Material.Plastic
			end
		end

		local v3 = viewportModule.new(clone.vpbg.vp, camera)
		local boundingBox, _ = folder:GetBoundingBox()
		v3:SetModel(folder)
		local v4 = not fish[v2.fishData.name].ViewportSizeOffset and 1 or fish[v2.fishData.name].ViewportSizeOffset
		local v5 = v3:GetFitDistance(boundingBox.Position) * v4
		local total = 0
		local cframe = CFrame.new()
		extended:Connect(RunService.RenderStepped, function(p2)
			total += math.rad(20 * p2)
			cframe = CFrame.fromEulerAnglesYXZ(0, total, 0.4363323129985824)
			camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, v5)
		end)
		clone.Label.Text = getDisplayName(v2.fishData)
		clone.YourCurrency.TextBox.Text = comma_value(v2.price)
		local v9 = v2
		local v10 = childName
		extended:Connect(clone.Activated, function()
			if ConfirmationController.new({
				header = "Purchase?",
				text = `Are you sure you want to purchase {v9.fishData.name} for S$ {comma_value(v9.price)}?`,
				options = {
					{
						text = "No",
						color = Color3.fromRGB(255, 120, 122)
					},
					{
						text = "Yes"
					}
				}
			}) == 1 then
				return
			end

			remoteEvent3:FireServer(v10, v9.price)
		end)
	end
end

function AquariumController:UpdateAquarium()
	local v = {}

	for _, v2 in self.ActiveFish do
		for _, v3 in v2 do
			v[v3.listingId] = v3
		end
	end

	for k, v2 in self.RoamingFish do
		if v[k] then
			continue
		end

		v2.Model:Destroy()
		v2.Roamer.Water = nil
		v2.Roamer.PrimaryPart = nil
		v2.Roamer.Fish = nil
		self.RoamingFish[k] = nil
	end

	for k, v2 in v do
		if self.RoamingFish[k] then
			continue
		end

		local tank = v2.tank

		if not tank then
			local tagged = CollectionService:GetTagged("AquariumTank")
			local children = tagged[math.random(1, #tagged)]:GetChildren()
			tank = children[math.random(1, #children)]
		end

		local model = FishModel.Create({
			Name = v2.fishData.name,
			ItemData = v2.fishData.sub,
			ResizeArgs = {
				MaxSize = 14
			},
			CastShadow = false
		})
		model.Parent = tank
		local v4 = {
			Roamer = FishRoamer.new(model, tank),
			Model = model
		}
		self.RoamingFish[k] = v4
	end
end

function AquariumController:CreateOpenConnections()
	self:UpdateMyFish()
	self:UpdateAquariumUI()
	self._openTrove:Connect(remoteEvent4.OnClientEvent, function(activeFish)
		self.ActiveFish = activeFish
		self:UpdateMyFish()
		self:UpdateAquariumUI()
	end)
	self._openTrove:Connect(pricePrompt.confirm.Activated, function()
		if not self.SelectedGUID then
			return
		end

		self:TogglePriceScreen(false)
		remoteEvent:FireServer(self.SelectedGUID, pricePrompt.amount.Text)
	end)
	self._openTrove:Connect(pricePrompt.deny.Activated, function()
		self:TogglePriceScreen(false)
	end)
end

function AquariumController:Start()
	self.ActiveFish = remoteFunction:InvokeServer()
	self.MyFishTrove = nil
	self.RoamingFish = {}
	local total = 0
	local count = 0
	RunService.RenderStepped:Connect(function(dt)
		total += dt
		count += 1

		if count == 1 then
			count = 0

			for _, v in self.RoamingFish do
				v.Roamer:Update(total)
			end

			total = 0
		end
	end)
	remoteEvent5.OnClientEvent:Connect(function()
		aquarium.Visible = true
	end)
	aquarium.Container.Close.Activated:Connect(function()
		aquarium.Visible = false
	end)
	aquarium:GetPropertyChangedSignal("Visible"):Connect(function()
		if aquarium.Visible then
			GeneralUtils.fastTween(
				workspace.CurrentCamera,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					FieldOfView = 60
				}
			)
			GeneralUtils.fastTween(
				Lighting:WaitForChild("uiblur"),
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Size = 10
				}
			)
			GeneralUtils.fastTween(
				Lighting:WaitForChild("uicc"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Brightness = -0.07,
					TintColor = Color3.fromRGB(184, 184, 184),
					Saturation = -0.3
				}
			)
			self:TogglePriceScreen(false)
			self:CreateOpenConnections()
		else
			self._openTrove:Clean()
			GeneralUtils.fastTween(
				workspace.CurrentCamera,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					FieldOfView = 70
				}
			)
			GeneralUtils.fastTween(
				Lighting:WaitForChild("uiblur"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Size = 0
				}
			)
			GeneralUtils.fastTween(
				Lighting:WaitForChild("uicc"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255),
					Saturation = 0
				}
			)
		end
	end)
	local shadyScrip = legacyLocalPlayerData.fetch():WaitForChild("LocalCurrencies"):WaitForChild("Shady Scrip")
	aquarium.Container.YourCurrency.TextBox.Text = shadyScrip.Value
	shadyScrip:GetPropertyChangedSignal("Value"):Connect(function()
		aquarium.Container.YourCurrency.TextBox.Text = shadyScrip.Value
	end)
	self:UpdateAquarium()
	remoteEvent4.OnClientEvent:Connect(function(activeFish)
		self.ActiveFish = activeFish
		self:UpdateAquarium()
	end)
end

return AquariumController