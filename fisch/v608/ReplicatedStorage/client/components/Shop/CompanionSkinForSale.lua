local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local modules = shared.modules
local Monetization = require(shared.Monetization)
local Component = require(packages.Component)
local Replion = require(packages.Replion)
local Timer = require(packages.Timer)
local Trove = require(packages.Trove)
local GiftController = require(legacyControllers.Shop.GiftController)
local DataController = require(legacyControllers.DataController)
local ShowroomController = require(legacyControllers.Shop.ShowroomController)
local HudController = require(legacyControllers.HudController)
local FFlags = require(modules.FFlags)
local skins = require(modules.library.companions.skins)
local _ = Players.LocalPlayer
local _ = DataController.PlayerDataReplicator
local v = Replion.Client:WaitReplion("LimitedStockItems")
local v2 = Component.new({
	Tag = "CompanionSkinForSale"
})

function v2:Construct()
	self.Trove = Trove.new()
	self.Skin = self.Instance.Name
	self.SkinData = skins.Skins[self.Skin]
end

function v2.Start(data)
	task.wait(5)
	MarketplaceService:GetProductInfo(data.SkinData.ProductId, Enum.InfoType.Product)
	local expect = nil
	local expect2 = nil
	local success, _ = pcall(function()
		expect = v:GetExpect({ "Stocks", data.Skin })
		expect2 = v:GetExpect({ "InitialStocks", data.Skin })
	end)
	local v3 = true
	local v4 = true
	local v5 = nil

	local function UpdateVisuals()
		local v6 = nil

		if success then
			expect = v:GetExpect({ "Stocks", data.Skin })
			expect2 = v:GetExpect({ "InitialStocks", data.Skin })
			data.Instance.Amount.Text = `{expect} / {expect2}`

			if expect <= 0 then
				v4 = false

				if v3 == true then
					v3 = false
					v6 = "Out of Stock!"
				else
					v6 = v3 == false and v6 == nil and "Out of Stock!" or v6
				end
			end

			local showLimitedStock = FFlags:Get("ShowLimitedStock", true)
			data.Instance.Amount.Visible = showLimitedStock
		end

		if data.SkinData.EndTime and workspace:GetServerTimeNow() > data.SkinData.EndTime then
			v3 = false
			v4 = false
			v6 = "Expired"
		end

		local v7 = v5 or Monetization:GetRobuxPrice(data.SkinData.ProductId)

		if v3 and v7 then
			v5 = v7
			data.Instance.BuyButton.Text = utf8.char(57346) .. tostring(v7)
		else
			data.Instance.BuyButton.Text = v6 or "FAILED TO LOAD PRICE!"
		end
	end

	data.Trove:Add(data.Instance.BuyButton.Activated:Connect(function()
		if not v3 then
			return
		end

		Monetization.BuyProduct:FireServer(data.SkinData.ProductId)
	end))
	data.Trove:Add(data.Instance.Gift.Activated:Connect(function()
		if not v4 then
			return
		end

		GiftController:PromptGift(data.SkinData.ProductId, data.Skin, data.SkinData.Description, data.SkinData.Icon)
	end))

	if data.Instance:FindFirstChild("View") then
		data.Trove:Add(data.Instance.View.Activated:Connect(function()
			ShowroomController:ShowBundle(data.Skin)
		end))
	end

	local shopNEW = HudController:GetSafeZone():FindFirstChild("shopNEW")

	if not (shopNEW and data.Instance:IsDescendantOf(shopNEW)) then
		ShowroomController:AddBundle({
			Name = data.Skin,
			ProductId = data.SkinData.ProductId,
			Order = 5,
			Contains = {
				{
					Name = data.Skin,
					Icon = data.SkinData.Icon,
					Type = "CompanionSkin",
					ShowcaseOffset = data.SkinData.ShowcaseOffset
				}
			}
		}, data.Instance)
	end

	local v6 = Timer.new(1)
	data.Trove:Add(v6, "Destroy")
	data.Trove:Add(v6.Tick:Connect(function()
		UpdateVisuals()
	end))
	v6:StartNow()
end

function v2.Stop(p)
	p.Trove:Destroy()
end

return v2