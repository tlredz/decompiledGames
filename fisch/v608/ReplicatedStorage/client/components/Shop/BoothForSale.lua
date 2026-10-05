local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local modules = shared.modules
local Monetization = require(shared.Monetization)
local Component = require(packages.Component)
require(packages.Replion)
local Timer = require(packages.Timer)
local Trove = require(packages.Trove)
require(legacyControllers.Shop.GiftController)
local DataController = require(legacyControllers.DataController)
local ShowroomController = require(legacyControllers.Shop.ShowroomController)
local HudController = require(legacyControllers.HudController)
local SalesBooth = require(modules.SalesBooth)
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "BoothForSale"
})

function v:Construct()
	self.Trove = Trove.new()
	self.Booth = self.Instance.Name
	self.BoothData = SalesBooth.Items[self.Booth]
end

function v.Start(data)
	task.wait(5)
	MarketplaceService:GetProductInfo(data.BoothData.ProductId, Enum.InfoType.Product)
	local v2 = true
	local v3 = nil

	local function UpdateVisuals()
		local v4 = nil

		if data.BoothData.EndTime and workspace:GetServerTimeNow() > data.BoothData.EndTime then
			v2 = false
			data.Instance.Visible = false
			v4 = "Expired"
		else
			data.Instance.Visible = true
		end

		DataController.PlayerDataReplicator:WaitForLoaded()

		if DataController.PlayerDataReplicator:TryIndex({ "SalesBooth", data.Booth }) then
			v2 = false
			v4 = "Owned"
		end

		local v5 = v3 or Monetization:GetRobuxPrice(data.BoothData.ProductId)

		if v2 ~= true or not v5 then
			data.Instance.BuyButton.Text = v4 or "FAILED TO LOAD PRICE!"
			return
		end

		v3 = v5
		data.Instance.BuyButton.Text = utf8.char(57346) .. tostring(v5)
	end

	data.Trove:Add(data.Instance.BuyButton.Activated:Connect(function()
		if v2 == false then
			return
		end

		Monetization.BuyProduct:FireServer(data.BoothData.ProductId)
	end))

	if data.Instance:FindFirstChild("View") then
		data.Trove:Add(data.Instance.View.Activated:Connect(function()
			ShowroomController:ShowBundle(data.Booth)
		end))
	end

	local shopNEW = HudController:GetSafeZone():FindFirstChild("shopNEW")

	if not (shopNEW and data.Instance:IsDescendantOf(shopNEW)) then
		ShowroomController:AddBundle({
			Name = data.Booth,
			ProductId = data.BoothData.ProductId,
			Order = 7,
			Contains = {
				{
					Name = data.Booth,
					Icon = data.BoothData.Icon,
					Type = "BoothSkin",
					ShowcaseOffset = data.BoothData.ShowcaseOffset
				}
			}
		}, data.Instance)
	end

	local v4 = Timer.new(1)
	data.Trove:Add(v4, "Destroy")
	data.Trove:Add(v4.Tick:Connect(function()
		UpdateVisuals()
	end))
	v4:StartNow()
end

function v.Stop(p)
	p.Trove:Destroy()
end

return v