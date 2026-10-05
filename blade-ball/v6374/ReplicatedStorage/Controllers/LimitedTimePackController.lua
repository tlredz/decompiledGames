local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3("@game/ReplicatedStorage/Packages/Charm")
require3("@game/ReplicatedStorage/Packages/Net")
local v2 = require3("@game/ReplicatedStorage/Packages/Replion")
local v3 = require3("@game/ReplicatedStorage/ClientGameModules/GuiHandler")
local v4 = require3("@game/ReplicatedStorage/Shared/LimitedTimePackData")
local v5 = require3("@game/ReplicatedStorage/Common/Utils")
require3("@game/ReplicatedStorage/Shared/ReplionUtils")
local _ = v5.Spring
local v6 = require3("./HoverInfoController")
require3("./NotificationController")
local v7 = require3("./Trading/TradeTokensController")
local v8 = require3("./GiftingController")
local playerGui = Players.LocalPlayer.PlayerGui
local dreamySetUI = playerGui.DreamySetUI
local rightHUD = playerGui.RightHUD
local page = dreamySetUI.Page
local items = page.Items
local v9 = nil
local atom = v.atom(nil)
local atom2 = v.atom(nil)
local atom3 = v.atom(nil)
local atom4 = v.atom(nil)
local LimitedTimePackController = {
	GetTimeLeft = function(self)
		return atom4() or -1
	end
}

function LimitedTimePackController.IsActive(_)
	return atom() ~= nil and LimitedTimePackController:GetTimeLeft() > 0
end

function LimitedTimePackController.Start(_)
	v9 = v2.Client:WaitReplion("LimitedStockItems")
	v.effect(function()
		local v10 = atom()

		if not v10 then
			return
		end

		local v11 = v4[v10]

		if v11 then
			local reward = v11.rewards[1]
			local reward2 = v11.rewards[2]
			local reward3 = v11.rewards[3]
			items.Big.Vector.Image = reward.Icon
			items.Big.Label.Text = reward.DisplayName
			items.Medium.Vector.Image = reward2.Icon
			items.Medium.Label.Text = reward2.DisplayName
			items.Small.Vector.Image = reward3.Icon
			items.Small.Label.Text = reward3.DisplayName
			v6:AddFromRewardInfo(items.Big, reward)
			v6:AddFromRewardInfo(items.Medium, reward2)
			v6:AddFromRewardInfo(items.Small, reward3)
		else
			v6:Remove(items.Big)
			v6:Remove(items.Medium)
			v6:Remove(items.Small)
		end
	end)
	v.effect(function()
		local v10 = atom4()

		if not v10 then
			return
		end

		if v10 <= 0 then
			v3:Close(dreamySetUI.Name, true)
			atom(nil)
			atom2(nil)
			page.Time.Clock.TimeLeft.Text = "ENDED!"
		else
			page.Time.Clock.TimeLeft.Text = v5.ValueConvertor:FormatTimeWithDaysFull(v10)
			rightHUD.List.LimitedTimePack.Timer.Timer.Text = v5.ValueConvertor:FormatShortTimeFull(v10)
		end
	end)
	v.effect(function()
		local v10 = atom()
		local v11 = v10 and v4[v10]

		if not (v10 and v11) then
			return
		end

		local function updateActiveOption()
			if not v9.Data.Loaded then
				return
			end

			local stock = v9.Data.Stock or {}
			local _ = v9.Data.InitialStock

			for k, _ in v11.options do
				local v12 = stock[`{v10}_{k}`]

				if not v12 or v12 <= 0 then
					continue
				end

				atom3(v12)
				atom2(k)
				return
			end

			atom2(nil)
			atom3(nil)
		end

		local connection = v9:OnDataChange(updateActiveOption)
		updateActiveOption()
		return function()
			connection:Disconnect()
		end
	end)
	v.effect(function()
		local v10 = atom()
		local v11 = v10 and v4[v10]

		if not v11 then
			return
		end

		local v12 = atom2()
		local v13 = v12 and v11.options[v12]

		if v12 and v13 then
			local option = v11.options[v12 - 1]
			local option2 = v11.options[v12 + 1]

			if option then
				page.Buttons.Purchasing.BeforePrice.Price:SetAttribute("ProductId", option.product)
				page.Buttons.Purchasing.BeforePrice.Price:AddTag("ProductPriceLabel")
				page.Buttons.Purchasing.BeforePrice.Visible = true
			else
				page.Buttons.Purchasing.BeforePrice.Visible = false
				page.Buttons.Purchasing.BeforePrice.Price:RemoveTag("ProductPriceLabel")
				page.Buttons.Purchasing.BeforePrice.Price:SetAttribute("ProductId", nil)
			end

			if option2 then
				page.Buttons.Purchasing.NextPrice.Price:SetAttribute("ProductId", option2.product)
				page.Buttons.Purchasing.NextPrice.Price:AddTag("ProductPriceLabel")
				page.Buttons.Purchasing.NextPrice.Visible = true
			else
				page.Buttons.Purchasing.NextPrice.Visible = false
				page.Buttons.Purchasing.NextPrice.Price:RemoveTag("ProductPriceLabel")
				page.Buttons.Purchasing.NextPrice.Price:SetAttribute("ProductId", nil)
			end

			page.Buttons.Purchasing.Buy.Price:SetAttribute("ProductId", v13.product)
			page.Buttons.Purchasing.Buy.Price:AddTag("ProductPriceLabel")
			page.Buttons.Purchasing.Visible = true
		else
			page.Bottom.Title.Text = "Out of stock!"
			page.Buttons.Purchasing.Visible = false
			page.Buttons.Purchasing.Buy.Price:RemoveTag("ProductPriceLabel")
			page.Buttons.Purchasing.Buy.Price:SetAttribute("ProductId", nil)
		end
	end)
	v.effect(function()
		local v10 = atom()
		local v11 = v10 and v4[v10]

		if not v11 then
			return
		end

		local v12 = atom2()
		local v13 = atom3()

		if not (v12 and v13) then
			return
		end

		local v14 = v12 == #v11.options
		local v15 = v5.ValueConvertor:AddCommas(v13)
		local title = page.Bottom.Title
		local text

		if v14 then
			text = `Only {v15} more copies left!`
		else
			text = `Only {v15} Left at this Price!`
		end

		title.Text = text
		page.Buttons.Purchasing.Stock.Title.Text = `{v15} Left!`
	end)
	page.Buttons.Purchasing.Buy.Activated:Connect(function()
		local v10 = atom2()
		local v11 = atom()
		local v12 = v11 and v4[v11]

		if not (v10 and v11 and v12) then
			ReplicatedStorage2.Misc.error:Play()
			return
		end

		local v13 = v12 and v12.options[v10]

		if not v13 then
			return
		end

		v7:PromptPurchase(v13.product, Enum.InfoType.Product)
	end)
	page.Buttons.Purchasing.Gift.Activated:Connect(function()
		local v10 = atom2()
		local v11 = atom()
		local v12 = v11 and v4[v11]

		if not (v10 and v11 and v12) then
			ReplicatedStorage2.Misc.error:Play()
		elseif v12 and v12.options[v10] then
			v8:SetGift((`{v11}_{v10}`))
		end
	end)
	page.CloseButton.Activated:Connect(function()
		v3:Close(dreamySetUI.Name)
	end)
	rightHUD.List.LimitedTimePack.Activated:Connect(function()
		local v10 = atom4()

		if not v10 or v10 <= 0 then
			return
		end

		v3:Open(dreamySetUI.Name)
	end)
	task.defer(function()
		while true do
			local serverTimeNow = workspace:GetServerTimeNow()

			for k, v10 in v4 do
				if serverTimeNow < v10.startTimestamp or v10.endTimestamp < serverTimeNow then
					continue
				end

				atom(k)
				atom4(v10.endTimestamp - serverTimeNow)
			end

			task.wait(1)
		end
	end)
end

return LimitedTimePackController