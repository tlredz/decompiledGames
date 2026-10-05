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
local localPlayer = Players.LocalPlayer
local puppyPlushUI = localPlayer.PlayerGui:WaitForChild("PuppyPlushUI")
require3(ReplicatedStorage2.ServerInfo)
local v = require3("@game/ReplicatedStorage/Packages/Net")
require3("@game/ReplicatedStorage/Packages/Observers")
local v2 = require3("@game/ReplicatedStorage/Packages/Replion")
require3("@game/ReplicatedStorage/Packages/Trove")
local v3 = require3("@game/ReplicatedStorage/Common/Utils")
local v4 = require3("@game/ReplicatedStorage/Shared/CommerceProducts")
local v5 = require3("@game/ReplicatedStorage/ClientGameModules/GuiHandler")
local v6 = require3("@game/ReplicatedStorage/Controllers/HoverInfoController")
local v7 = require3("@game/ReplicatedStorage/Controllers/Trading/IndexController")
local remoteEvent = v:RemoteEvent("Commerce/TryBuy")
local bladeBallPuppy = v4["Blade Ball Puppy"]
return {
	Start = function(_)
		v3.GuiUtils.getActivatedSignal(puppyPlushUI.Inner.Close):Connect(function()
			v5:Close(puppyPlushUI.Name)
		end)
		local v8 = v2.Client:WaitReplion("LimitedStockItems")
		local flag = false

		local function fn() end

		local function setupPuppy()
			if flag then
				return
			end

			flag = true

			if v7:CanPreview(bladeBallPuppy.Reward) then
				puppyPlushUI.Inner.DLC.Try.Activated:Connect(function()
					v7:Preview(
						bladeBallPuppy.Reward.Type,
						bladeBallPuppy.Reward.Value,
						puppyPlushUI.Name,
						v5:Open(puppyPlushUI.Name)
					)
				end)
			else
				puppyPlushUI.Inner.DLC.Try.Visible = false
			end

			puppyPlushUI.Inner.Purchase.Activated:Connect(function()
				if not (localPlayer:GetAttribute("PolicyCommerceProduct") and puppyPlushUI.Inner.Purchase.Visible) then
					return
				end

				if puppyPlushUI.Inner.Purchase:GetAttribute("Disabled") and v3.FFlag.GetFFlag(
					"MerchOffsaleWhenSoldOut",
					true
				) then
					return
				end

				remoteEvent:FireServer(bladeBallPuppy.CommerceProductId)
			end)
			local flag2 = true

			fn = function()
				puppyPlushUI.Inner.Purchase.Stock.Visible = v8:Get("Loaded") == true
				local v9 = v8:Get({ "Stock", bladeBallPuppy.LimitedStockKey }) or 0
				local expect = v8:GetExpect({ "InitialStock", bladeBallPuppy.LimitedStockKey })
				puppyPlushUI.Inner.Purchase.Stock.Text = `{v9}/{expect} Left`
				local v10 = v9 <= 0
				local v11 = not flag2 or v10
				local fFlag = v3.FFlag.GetFFlag("MerchOffsaleWhenSoldOut", true)
				puppyPlushUI.Inner.Purchase.Visible = not (v11 and fFlag)
				puppyPlushUI.Inner.SoldOut.Visible = v11 and fFlag
				puppyPlushUI.Inner.Purchase:SetAttribute("Disabled", v11 and true or nil)
			end

			v8:OnChange({ "Stock", bladeBallPuppy.LimitedStockKey }, fn)
			local success, result = pcall(function()
				return CommerceService:GetCommerceProductInfoAsync(bladeBallPuppy.CommerceProductId)
			end)

			if not (success and result) then
				if RunService:IsStudio() then
					result = {
						IsForSale = true,
						Item = {
							DisplayPrice = "$79.99"
						}
					}
				else
					warn("Failed to load CommerceProductInfo for Puppy Plush:", result)
					result = {
						IsForSale = false,
						Item = {
							DisplayPrice = "$79.99"
						}
					}
				end
			end

			puppyPlushUI.Inner.Purchase.Price.Text = not result.Item and "???" or result.Item.DisplayPrice or "???"

			if result.IsForSale == true then
				flag2 = true
			else
				flag2 = false
			end

			if flag2 then
				v6:AddFromRewardInfo(puppyPlushUI.Inner.DLC.Dog, bladeBallPuppy.Reward)
			else
				puppyPlushUI.Inner.Purchase.Txt.Text = "SOLD OUT!"
				puppyPlushUI.Inner.Purchase.Price.Visible = false
			end

			fn()
		end

		if localPlayer:GetAttribute("PolicyCommerceProduct") then
			task.spawn(setupPuppy)
		end

		localPlayer:GetAttributeChangedSignal("PolicyCommerceProduct"):Connect(function()
			if localPlayer:GetAttribute("PolicyCommerceProduct") then
				setupPuppy()
			end
		end)

		local function updateFFlags()
			if v3.FFlag.GetFFlag("NewMerchShopDisabled", false) and v5:IsOpen(puppyPlushUI.Name) then
				v5:Close(puppyPlushUI.Name)
			end

			fn()
		end

		v3.FFlag.OnChange(updateFFlags)
		task.defer(updateFFlags)
	end
}