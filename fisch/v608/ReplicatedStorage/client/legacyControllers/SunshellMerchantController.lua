local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local legacyControllers = ReplicatedStorage.client.legacyControllers
local library = ReplicatedStorage.shared.modules.library
local Net = require(packages.Net)
local HudController = require(legacyControllers.HudController)
local SunshellMerchantItems = require(ReplicatedStorage.shared.modules.SunshellMerchantItems)
local fish = require(library.fish)
local items = require(library.items)
local rods = require(library.rods)
local bait = require(library.bait)
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local bobbers = require(ReplicatedStorage.shared.modules.fishing.bobbers)
local lanterns = require(library.lanterns)
local personalAquariumFurniture = require(library.personalAquariumFurniture)
local RodSkins = require(ReplicatedStorage.shared.modules.RodSkins)
local _ = game.Players.LocalPlayer
local sunshellMerchant = HudController:GetSafeZone().SunshellMerchant
local remoteEvent = Net:RemoteEvent("SunshellMerchant/Open")
local remoteFunction = Net:RemoteFunction("SunshellMerchant/Purchase")

local function comma_value(price)
	local v = math.ceil(price)

	repeat
		local v2
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

local SunshellMerchantController = {}
local clones = {}
local v = false

function SunshellMerchantController:Toggle(visible: boolean?)
	if visible == nil then
		visible = not sunshellMerchant.Visible
	end

	if visible == sunshellMerchant.Visible then
		return
	end

	sunshellMerchant.Visible = visible
end

local function applyState(p, p2)
	for k, v2 in clones do
		local sunshellMerchantItem = SunshellMerchantItems[k]

		if sunshellMerchantItem.Secret then
			v2.Visible = p2[k] == true
		end

		if not sunshellMerchantItem.Infinite then
			v2.SoldOut.Visible = p[k] == true
		end
	end
end

local function attemptPurchase(p: string, p2)
	if v or p2.SoldOut.Visible then
		return
	end

	v = true

	if remoteFunction:InvokeServer(p) and not SunshellMerchantItems[p].Infinite then
		p2.SoldOut.Visible = true
	end

	task.delay(0.5, function()
		v = false
	end)
end

function SunshellMerchantController.Start(_)
	local list = sunshellMerchant.Container.List
	local item = list.Item
	item.Parent = nil

	for k, sunshellMerchantItem in SunshellMerchantItems do
		local clone = item:Clone()
		clone.Name = k
		clone.ItemName.Text = k
		clone.ItemType.Text = sunshellMerchantItem.Type

		if sunshellMerchantItem.CostItem then
			clone.Price.Text = `×{sunshellMerchantItem.CostAmount} {sunshellMerchantItem.CostItem}`
			clone.Price.TextColor3 = Color3.fromRGB(255, 227, 125)
		else
			clone.Price.Text = `{comma_value(sunshellMerchantItem.Price)} Sunshells`
		end

		clone.ImageLabel.Image = fish[k] and fish[k].Icon or items.Items[k] and items.Items[k].Icon or rods[k] and rods[k].Icon or RodSkins.Skins[k] and RodSkins.Skins[k].Icon or vessels.library[k] and vessels.library[k].Icon or lanterns[k] and lanterns[k].Icon or personalAquariumFurniture[k] and personalAquariumFurniture[k].Icon or bait[k] and bait[k].Icon or not bobbers.Bobbers[k] and "" or bobbers.Bobbers[k].Icon or ""
		clone.SoldOut.Visible = false
		clone.Visible = not sunshellMerchantItem.Secret
		clone.LayoutOrder = not sunshellMerchantItem.Price and -1000000 or -sunshellMerchantItem.Price
		clone.Parent = list
		clones[k] = clone
		local v2 = k
		clone.Activated:Connect(function()
			attemptPurchase(v2, clone)
		end)
	end

	remoteEvent.OnClientEvent:Connect(function(p, p2, p3)
		if typeof(p2) == "table" then
			applyState(p2, typeof(p3) ~= "table" and {} or p3)
		end

		SunshellMerchantController:Toggle(p)
	end)
	sunshellMerchant.Close.Activated:Connect(function()
		SunshellMerchantController:Toggle(false)
	end)
end

return SunshellMerchantController