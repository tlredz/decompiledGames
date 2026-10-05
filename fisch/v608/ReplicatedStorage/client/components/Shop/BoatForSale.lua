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
local ShowroomController = require(legacyControllers.Shop.ShowroomController)
local HudController = require(legacyControllers.HudController)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local vessels = require(modules.vessels)
local FFlags = require(modules.FFlags)
local _ = Players.LocalPlayer
legacyLocalPlayerData.fetch():WaitForChild("Boats")
local v = Replion.Client:WaitReplion("LimitedStockItems")
local v2 = Component.new({
	Tag = "BoatForSale"
})

function v2:Construct()
	self.Trove = Trove.new()
	self.Boat = self.Instance.Name
	self.BoatData = vessels.library[self.Boat]
end

function v2.Start(data)
	task.wait(5)
	MarketplaceService:GetProductInfo(data.BoatData.ProductId, Enum.InfoType.Product)
	local expect = nil
	local expect2 = nil
	local success, _ = pcall(function()
		expect = v:GetExpect({ "Stocks", data.Boat })
		expect2 = v:GetExpect({ "InitialStocks", data.Boat })
	end)
	data.Instance.Title.Text = data.Boat
	data.Instance.Amount.Visible = success
	data.Instance.Info.Speed.Text = `Speed: {data.BoatData.MaxSpeed}S/ps`
	data.Instance.Info.Steering.Text = `Steering: {math.round(data.BoatData.TurningSpeed * 100)}°`
	data.Instance.Info.Acceleration.Text = `Acceleration: {data.BoatData.Accel}S/ps`
	local v3 = true
	local v4 = true
	local v5 = nil

	local function UpdateVisuals()
		local v6 = nil

		if success then
			expect = v:GetExpect({ "Stocks", data.Boat })
			expect2 = v:GetExpect({ "InitialStocks", data.Boat })
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

		local robuxPrice = v5

		if not robuxPrice then
			local vessel = Monetization.products.Vessels.vessels[data.Boat]
			robuxPrice = vessel and Monetization:GetRobuxPrice(vessel.ProductId)
		end

		if v3 ~= true or not robuxPrice then
			data.Instance.BuyButton.Text = v6 or "FAILED TO LOAD PRICE!"
			return
		end

		v5 = robuxPrice
		data.Instance.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
	end

	if success then
		data.Trove:Add(FFlags:OnChange("ShowLimitedStock", function(visible)
			data.Instance.Amount.Visible = visible
		end))
	end

	data.Trove:Add(data.Instance.BuyButton.Activated:Connect(function()
		if v3 == false then
			return
		end

		local vessel = Monetization.products.Vessels.vessels[data.Boat]

		if vessel then
			Monetization.BuyProduct:FireServer(vessel.ProductId)
		end
	end))
	data.Trove:Add(data.Instance.Gift.Activated:Connect(function()
		if v4 == false then
			return
		end

		GiftController:PromptGift(data.BoatData.ProductId, data.Boat, data.BoatData.Description, data.BoatData.Icon)
	end))

	if data.Instance:FindFirstChild("View") then
		data.Trove:Add(data.Instance.View.Activated:Connect(function()
			ShowroomController:ShowBundle(data.Boat)
		end))
	end

	local shopNEW = HudController:GetSafeZone():FindFirstChild("shopNEW")

	if not (shopNEW and data.Instance:IsDescendantOf(shopNEW)) then
		ShowroomController:AddBundle({
			Name = data.Boat,
			ProductId = data.BoatData.ProductId,
			Order = 3,
			Contains = {
				{
					Name = data.Boat,
					Icon = data.BoatData.Icon,
					Type = "Boat",
					ShowcaseOffset = data.BoatData.ShowcaseOffset
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