local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local modules = shared.modules
local Monetization = require(shared.Monetization)
local Component = require(packages.Component)
require(packages.Net)
local Replion = require(packages.Replion)
local Timer = require(packages.Timer)
local Trove = require(packages.Trove)
local DataController = require(legacyControllers.DataController)
local GiftController = require(legacyControllers.Shop.GiftController)
local ShowroomController = require(legacyControllers.Shop.ShowroomController)
local HudController = require(legacyControllers.HudController)
require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local RodSkins = require(modules.RodSkins)
local FFlags = require(modules.FFlags)
local playerDataReplicator = DataController.PlayerDataReplicator
local _ = Players.LocalPlayer
local v = Replion.Client:WaitReplion("LimitedStockItems")
local v2 = Component.new({
	Tag = "SkinForSale"
})

local function ToTime(p: number)
	local v3 = math.floor(p / 86400)
	local v4 = p % 86400
	local v5 = math.floor(v4 / 3600)
	local v6 = v4 % 3600
	local v7 = math.floor(v6 / 60)
	local v8 = v6 % 60
	local v9 = ""

	if v3 > 0 then
		v9 ..= `{v3}d `
	end

	if v5 > 0 or v3 > 0 then
		v9 ..= `{v5}h `
	end

	if v7 > 0 or v5 > 0 then
		v9 ..= `{v7}m `
	end

	if v5 < 0 and v3 < 0 then
		return v9 .. `{v8}s`
	end

	return v9
end

function v2:Construct()
	self.Trove = Trove.new()
	self.Skin = self.Instance.Name
	self.SkinData = RodSkins.Skins[self.Skin]
	self.HasRod = false
	self.TargetRod = self.SkinData.TargetRod
end

function v2:Start()
	task.wait(5)
	playerDataReplicator:WaitForLoaded()
	self.Instance:WaitForChild("Title")
	self.Instance:WaitForChild("SkinType")
	self.Instance:WaitForChild("Gift")
	self.Instance:WaitForChild("BuyButton")
	self.HasRod = playerDataReplicator.Data.Rods[self.TargetRod] ~= nil

	if not self.HasRod then
		self.Trove:Add(playerDataReplicator:ObserveKeys({ "Rods" }, function(p)
			if p ~= self.TargetRod then
				return
			end

			self.HasRod = true
		end))
	end

	local expect = nil
	local expect2 = nil
	local success, _ = pcall(function()
		expect = v:GetExpect({ "Stocks", self.Skin })
		expect2 = v:GetExpect({ "InitialStocks", self.Skin })
	end)

	if self.SkinData.Icon then
	end

	self.Instance:FindFirstChild("Icon")
	self.Instance.Title.Text = self.SkinData.DisplayText or self.Skin

	if self.Instance:FindFirstChild("Description") then
		self.Instance.Description.Text = self.SkinData.Description or ""
	end

	self.Instance.SkinType.Text = "For " .. self.TargetRod
	local v3 = true
	local v4 = true
	local v5 = nil

	local function UpdateVisuals()
		local v6

		if self.SkinData.TimeToExpire then
			v6 = math.clamp(self.SkinData.TimeToExpire - workspace:GetServerTimeNow(), 0, 1e999)
		end

		local expiresIn = self.Instance:FindFirstChild("ExpiresIn")

		if expiresIn then
			expiresIn.Text = (v6 == nil or not (v6 > 0)) and "Expired!" or `{ToTime(v6)}` or "Expired!"
			expiresIn.Visible = v6 ~= nil
		end

		local v7 = nil

		if success then
			local label = self.Instance:FindFirstChild("Amount") and self.Instance.Amount:FindFirstChild("Label")
			expect = v:GetExpect({ "Stocks", self.Skin })
			expect2 = v:GetExpect({ "InitialStocks", self.Skin })

			if label then
				label.Text = expect .. " / " .. expect2 .. " Left"
				local showLimitedStock = FFlags:Get("ShowLimitedStock", true)
				label.Parent.Visible = showLimitedStock
				FFlags:OnChange("ShowLimitedStock", function(visible)
					label.Parent.Visible = visible
				end)
			end

			if expect <= 0 then
				v4 = false

				if v3 == true then
					v3 = false
					v7 = "Out of Stock!"
				else
					v7 = v3 == false and v7 == nil and "Out of Stock!" or v7
				end
			end
		else
			local amount = self.Instance:FindFirstChild("Amount")

			if amount then
				amount.Visible = false
			end
		end

		if v6 and v6 <= 0 then
			v4 = false

			if v3 == true then
				v3 = false
				v7 = "Out of Stock!"
			end
		end

		local robuxPrice = v5

		if not robuxPrice then
			local rodSkin = Monetization.products.RodSkins[self.Skin]
			robuxPrice = rodSkin and Monetization:GetRobuxPrice(rodSkin.ProductId)
		end

		if v3 and robuxPrice then
			v5 = robuxPrice
			self.Instance.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
		else
			self.Instance.BuyButton.Text = v7 or "FAILED TO LOAD PRICE!"
		end
	end

	self.Trove:Add(self.Instance.BuyButton.Activated:Connect(function()
		if v3 == false then
			return
		end

		local rodSkin = Monetization.products.RodSkins[self.Skin]

		if self.HasRod == false then
			self.Instance.DontHave.TextLabel.Text = "You don't  own " .. self.TargetRod .. " are you sure you want to buy this?"
			self.Instance.DontHave.Visible = true
			local v6 = nil
			local activatedConnection = nil
			local activatedConnection2 = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function CleanConnections()
				if activatedConnection then
					activatedConnection:Disconnect()
					self.Trove:Remove(activatedConnection)
				end

				if activatedConnection2 then
					activatedConnection2:Disconnect()
					self.Trove:Remove(activatedConnection2)
				end
			end

			activatedConnection = self.Instance.DontHave.Yes.Activated:Connect(function()
				v6 = true
				CleanConnections() -- equivalent call inferred; original call site unknown
			end)
			activatedConnection2 = self.Instance.DontHave.No.Activated:Connect(function()
				v6 = false
				CleanConnections() -- equivalent call inferred; original call site unknown
			end)
			self.Trove:Add(activatedConnection)
			self.Trove:Add(activatedConnection2)

			while v6 == nil do
				task.wait()
			end

			self.Instance.DontHave.Visible = false

			if v6 == true and rodSkin then
				Monetization.BuyProduct:FireServer(rodSkin.ProductId)
			end
		else
			self.Instance.DontHave.Visible = false

			if rodSkin then
				Monetization.BuyProduct:FireServer(rodSkin.ProductId)
			end
		end
	end))
	self.Trove:Add(self.Instance.Gift.Activated:Connect(function()
		if v4 == false then
			return
		end

		GiftController:PromptGift(
			self.SkinData.DevProduct,
			self.SkinData.DisplayText,
			`Skin for {self.TargetRod}`,
			self.SkinData.Icon
		)
	end))

	if self.Instance:FindFirstChild("View") then
		self.Trove:Add(self.Instance.View.Activated:Connect(function()
			ShowroomController:ShowBundle(self.Skin)
		end))
	end

	local shopNEW = HudController:GetSafeZone():FindFirstChild("shopNEW")

	if not (shopNEW and self.Instance:IsDescendantOf(shopNEW)) then
		local rodSkin = Monetization.products.RodSkins[self.Skin]
		ShowroomController:AddBundle({
			Name = self.Skin,
			ProductId = rodSkin.ProductId,
			Order = success and 2 or 4,
			Contains = {
				{
					Name = self.Skin,
					Icon = self.SkinData.Icon,
					Type = "RodSkin",
					ShowcaseOffset = self.SkinData.ShowcaseOffset
				}
			}
		}, self.Instance)
	end

	local v6 = Timer.new(1)
	self.Trove:Add(v6, "Destroy")
	self.Trove:Add(v6.Tick:Connect(function()
		UpdateVisuals()
	end))
	v6:StartNow()
end

function v2.Stop(p)
	p.Trove:Destroy()
end

return v2