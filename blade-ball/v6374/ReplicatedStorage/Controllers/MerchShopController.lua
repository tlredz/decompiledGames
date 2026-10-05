local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local CommerceService = game:GetService("CommerceService")
game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("PolicyService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local controllers = ReplicatedStorage2.Controllers
local packages = ReplicatedStorage2.Packages
local shared = ReplicatedStorage2.Shared
local playerGui = Players.LocalPlayer.PlayerGui
local main = playerGui:WaitForChild("OfficialCommerce").MainFrame.Main
local scrollingFrame = main.Content.Items.ScrollingFrame
require3(ReplicatedStorage2.ServerInfo)
playerGui:WaitForChild("Shop")
local imageButton = scrollingFrame.Top:FindFirstChildWhichIsA("ImageButton")
local v = imageButton
local buttons = { imageButton }

for _, button in scrollingFrame.Bottom:GetChildren() do
	if button:IsA("ImageButton") then
		table.insert(buttons, button)
	end
end

require3(shared.FastUtils)
local v2 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(shared.CommerceProducts)
local v6 = require3(controllers.Trading.IndexController)
local v7 = require3(packages.Net)
require3(packages.Observers)
local v8 = require3(packages.Replion)
local v9 = require3(packages.Trove)
v7:RemoteEvent("Commerce/OpenGui")
local remoteEvent = v7:RemoteEvent("Commerce/TryBuy")
local MerchShopController = {}
local v10 = {}

function MerchShopController.GetFrameByName(p: string)
	if not p then
		return
	end

	for _, v12 in buttons do
		if v12.Name == p then
			return v12
		end
	end

	return nil
end

function MerchShopController:UpdateFeatured()
	local v11 = v8.Client:WaitReplion("LimitedStockItems")

	if v11:Get("Loaded") ~= true then
		return
	end

	local v12 = {}

	for _, frame in buttons do
		local v14 = v5[frame.Name]

		if not (v14 and v14.LimitedStockKey ~= nil) then
			continue
		end

		local v15 = v11:Get({ "Stock", v14.LimitedStockKey })
		local v16 = v11:Get({ "InitialStock", v14.LimitedStockKey })

		if not (v16 and v15) then
			continue
		end

		local sold = v16 - v15

		if sold < v16 and sold ~= 0 then
			table.insert(v12, {
				frame = frame,
				sold = sold
			})
		end
	end

	table.sort(v12, function(a, b)
		return a.sold > b.sold
	end)
	local v13 = v4.FFlag.GetInstantFFlag("MerchShopFeaturedOverride") or v12[1] and v12[1].frame.Name or "Sorry Ladies Hoodie"

	if v13 and (not v or v ~= v13) then
		self:LoadFeatured(v13)
	end
end

function MerchShopController:UpdateStock(p2)
	local v11 = v5[p2]

	if not v11 then
		return
	end

	local v12 = v8.Client:WaitReplion("LimitedStockItems")
	local frame = self.GetFrameByName(p2)

	if not frame then
		return
	end

	frame.Left.Visible = v12:Get("Loaded") == true
	pcall(function()
		local v13 = v12:Get({ "Stock", v11.LimitedStockKey }) or 0
		local expect = v12:GetExpect({ "InitialStock", v11.LimitedStockKey })
		frame.Left.Text = `{v13}/{expect} Left`
		local v14 = v13 <= 0
		frame.Buy.Visible = not (v14 and v4.FFlag.GetFFlag("MerchOffsaleWhenSoldOut", true))
		frame.SoldOut.Visible = v14 and v4.FFlag.GetFFlag("MerchOffsaleWhenSoldOut", true)

		if v14 then
			frame:SetAttribute("Disabled", true)
			frame.LayoutOrder = 100
		else
			frame:SetAttribute("Disabled", nil)
			frame.LayoutOrder = 0
		end
	end)
end

function MerchShopController:LoadFeatured(p)
	if not v or v == p then
		return
	end

	local frame = MerchShopController.GetFrameByName(p)

	if not frame then
		return
	end

	local name = imageButton.Name
	local image = imageButton.RewardIcon.Image
	local image2 = imageButton.Icons.Default.Image
	local image3 = imageButton.Icons.Hovered.Image
	local visible = imageButton.Icons.Hovered.Visible
	imageButton.Name = frame.Name
	imageButton.RewardIcon.Image = frame.RewardIcon.Image
	imageButton.Icons.Default.Image = frame.Icons.Default.Image
	imageButton.Icons.Hovered.Image = frame.Icons.Hovered.Image
	imageButton.Icons.Hovered.Visible = frame.Icons.Hovered.Visible
	frame.Name = name
	frame.RewardIcon.Image = image
	frame.Icons.Default.Image = image2
	frame.Icons.Hovered.Image = image3
	frame.Icons.Hovered.Visible = visible
	frame.Visible = v5[name] ~= nil
	self:LoadInformation(imageButton)
	self:LoadInformation(frame)
	v = p
end

local v11 = {}

function MerchShopController:LoadInformation(instance)
	local v12 = instance and v5[instance.Name]

	if not v12 then
		return
	end

	local commerceProductId = v12.CommerceProductId
	local result = v10[commerceProductId]

	if not result then
		local success
		success, result = pcall(function()
			return CommerceService:GetCommerceProductInfoAsync(commerceProductId)
		end)

		if not (success and result) then
			if RunService:IsStudio() then
				result = {
					IsForSale = true,
					Item = {
						DisplayPrice = "$9.99"
					}
				}
			else
				warn(`Failed to load CommerceProductInfo for {instance.Name}:`, result)
			end
		end

		v10[commerceProductId] = result
	end

	if not result.IsForSale then
		instance.Left.Text = "SOLD OUT!"
		instance.LayoutOrder += 100
		instance:SetAttribute("Disabled", true)
	end

	if v11[instance] then
		v11[instance]:Clean()
	else
		v11[instance] = v9.new()
	end

	instance.Visible = true
	v11[instance]:Connect(instance.Activated, function()
		if instance:GetAttribute("Disabled") and v4.FFlag.GetFFlag("MerchOffsaleWhenSoldOut", true) then
			return
		end

		remoteEvent:FireServer(commerceProductId)
	end)
	local buy = instance:FindFirstChild("Buy")

	if buy then
		v11[instance]:Connect(buy.Activated, function()
			if instance:GetAttribute("Disabled") and v4.FFlag.GetFFlag("MerchOffsaleWhenSoldOut", true) then
				return
			end

			remoteEvent:FireServer(commerceProductId)
		end)
		local label = buy:FindFirstChild("Label")

		if label and result.Item and result.Item.DisplayPrice then
			label.Text = result.Item.DisplayPrice
		else
			result.Item.DisplayPrice = ""
		end
	end

	local reward = v12.Reward
	v2:AddFromRewardInfo(instance, reward)
	v11[instance]:Add(function()
		v2:Remove(instance)
	end)
	local view = instance:FindFirstChild("View")

	if view then
		if reward and v6:CanPreview(reward) then
			view.Visible = true
			v11[instance]:Connect(view.Activated, function()
				v6:Preview(reward.Type, reward.Value, "OfficialCommerce", v3:Open("OfficialCommerce"))
			end)
		else
			view.Visible = false
		end
	end

	instance.Title.Text = instance.Name
	self:UpdateStock(instance.Name)
end

function MerchShopController.Start(_)
	v4.GuiUtils.getActivatedSignal(main.Close):Connect(function()
		v3:Close("OfficialCommerce")
	end)
end

return MerchShopController