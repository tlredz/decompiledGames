local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v3 = require3(ReplicatedStorage2.Shared.FastUtils)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v6 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v7 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v8 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v9 = require3(ReplicatedStorage2.Shared.Merchant.MerchantFinisherData)
local v10 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v11 = require3(ReplicatedStorage2.Packages.Observers)
local v12 = require3(ReplicatedStorage2.Controllers.PromptController)
local v13 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local playerGui = Players.LocalPlayer.PlayerGui
local indexScreenBlackout = playerGui.IndexScreenBlackout
local flag = false
local v14 = nil
local v15 = nil
local merchantFinisher = playerGui.MerchantFinisher
local template = merchantFinisher.Page.Frame.Items.UIGridLayout.Template

-- equivalent calls inferred from this helper; original call sites unknown
local function getTodayTimestamp()
	local universalTime = DateTime.now():ToUniversalTime()
	return DateTime.fromUniversalTime(universalTime.Year, universalTime.Month, universalTime.Day).UnixTimestamp
end

local MerchantFinisherController = {}

function MerchantFinisherController:_updateItems()
	if not self:IsActive() then
		return
	end

	local v16 = v14:Get("MerchantFinisher.Items")

	if not v16 then
		return
	end

	local todayTimestamp = getTodayTimestamp() -- equivalent call inferred; original call site unknown

	for childName, v17 in v16 do
		local child = merchantFinisher.Page.Frame.Items:FindFirstChild(childName)

		if not child then
			continue
		end

		local item = v9.Items[v17]

		if not item then
			continue
		end

		local v18 = #client:FindItems("Sword", item.Reward.Value, {
			Finisher = client.None
		}) > 0
		local v19 = #client:FindItems("Sword", item.Reward.Value, {
			Finisher = true
		}) > 0
		local active = v19 or v18
		local formatted = `{item.Reward.Value} {item.Reward.Type}-{todayTimestamp}`
		local v21 = v15:Get({ "InitialStock", formatted })
		local v22 = v15:Get({ "Stock", formatted })
		local v23 = v22 or 0
		child.ItemName.Text = item.Reward.DisplayName
		child.Icon.Image = item.Reward.Icon
		child.Active = active
		child.ItemRemaning.Text = `{v22 or "???"}/{v21 or "???"} Left`
		child.FindSeller.Visible = not active
		child.Buy.Visible = v18 and v23 > 0
		v13(child.Buy.Price.CurrentPrice, item.DevProduct, "DevProduct", ":robux:%s")
		child.SoldOut.Visible = v23 <= 0
		child.DontOwnLimited.Visible = not active
		child.Owned.Visible = v19 and not v18
		child.Gift.Visible = v23 > 0
		local findSeller = child.FindSeller
		local position

		if child.Gift.Visible then
			position = UDim2.fromScale(0.375, 0.827)
		else
			position = UDim2.fromScale(0.5, 0.827)
		end

		findSeller.Position = position
		child.Visible = true
	end
end

function MerchantFinisherController:_findSeller(p)
	if flag then
		return false
	end

	flag = true
	indexScreenBlackout.Blackout.BackgroundTransparency = 1
	indexScreenBlackout.Spinner.ImageTransparency = 0
	indexScreenBlackout.Spinner.Rotation = 0
	indexScreenBlackout.Enabled = true
	v3.fastTween(indexScreenBlackout.Blackout, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.2
	})
	v3.fastTween(indexScreenBlackout.Spinner, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
		Rotation = 360
	})
	return v:Invoke("MerchantFinisher/FindSeller", p.Reward.Value)
end

function MerchantFinisherController:IsActive()
	return workspace:GetServerTimeNow() < v4.FFlag.GetFFlag("MerchantFinisherEndTime", v9.EndTime)
end

function MerchantFinisherController:Start()
	v14 = v2.Client:WaitReplion("Data")
	v15 = v2.Client:WaitReplion("LimitedStockItems")

	for i = 1, v9.MaxItemsPerPool do
		local clone = template:Clone()
		local v16 = i

		local function purchase()
			local v17 = v14:Get("MerchantFinisher.Items")
			local v18

			if v17 then
				v18 = v17[v16]
			end

			if not v18 then
				return
			end

			local v19, v20 = v:Invoke("PurchaseMerchantFinisher", v18)

			if not v19 then
				if v20 then
					v7:SendNotification(v20)
				end

				ReplicatedStorage2.Misc.error:Play()
			end
		end

		clone.Activated:Connect(purchase)
		clone.Buy.Activated:Connect(purchase)
		local v17 = i
		clone.Gift.Activated:Connect(function()
			local v18 = v14:Get("MerchantFinisher.Items")
			local v19

			if v18 then
				v19 = v18[v17]
			end

			local v20

			if v19 then
				v20 = v9.Items[v19]
			end

			if not v20 then
				return
			end

			local todayTimestamp = getTodayTimestamp() -- equivalent call inferred; original call site unknown
			local v21 = { "Stock", (`{v20.Reward.Value} {v20.Reward.Type}-{todayTimestamp}`) }
			local v22 = v15:Get(v21)

			if v22 and not (v22 <= 0) then
				v10:SetGift(v20.Reward.DisplayName)
			else
				ReplicatedStorage2.Misc.error:Play()
			end
		end)
		local v18 = i
		clone.Inspect.Activated:Connect(function()
			local v19 = v14:Get("MerchantFinisher.Items")
			local v20

			if v19 then
				v20 = v19[v18]
			end

			if not v20 then
				return
			end

			v6:PreviewReward(v9.Items[v20].Reward, "MerchantFinisher")
		end)
		local v19 = i
		clone.FindSeller.Activated:Connect(function()
			local v20 = v14:Get("MerchantFinisher.Items")
			local v21

			if v20 then
				v21 = v20[v19]
			end

			if not v21 or flag then
				return
			end

			local lastTime = os.clock()
			local item = v9.Items[v21]
			local _findSeller, v22 = self:_findSeller(item)

			if not _findSeller then
				v12:CreatePrompt({
					PromptType = "Ok",
					Description = "Internal server error [1]"
				})
				ReplicatedStorage2.Misc.error:Play()
			end

			flag = false
			task.wait(1 - (os.clock() - lastTime))

			if _findSeller then
				if v22 then
					v12:CreatePrompt({
						PromptType = "Accept",
						Description = "A seller has been found!\nWould you like to teleport to their server?",
						AcceptButtonText = "Yes",
						DeclineButtonText = "No"
					}, function(flag2: boolean)
						if flag2 then
							local v23, v24 = v:Invoke("MerchantFinisher/TeleportToListing", item.Reward.Value, v22)

							if not v23 then
								warn((`Failed to teleport to listing!\n{v24 or "No data"}`))
							end
						end
					end)
				else
					v12:CreatePrompt({
						PromptType = "Ok",
						Description = "No users selling this item are online :("
					})
				end
			end

			v3.fastTween(
				indexScreenBlackout.Blackout,
				TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					BackgroundTransparency = 1
				}
			)
			v3.fastTween(
				indexScreenBlackout.Spinner,
				TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					ImageTransparency = 1
				}
			).Completed:Once(function()
				indexScreenBlackout.Enabled = false
			end)
		end)
		clone.Name = i
		clone.LayoutOrder = i
		clone.Visible = false
		clone.Parent = merchantFinisher.Page.Frame.Items
	end

	merchantFinisher.Page.Frame.Close.Activated:Connect(function()
		v5:Close("MerchantFinisher")
	end)
	v8.observeReplionPath(v14, "MerchantFinisher.Items", function()
		if not self:IsActive() then
			return
		end

		self:_updateItems()
	end)
	v8.observeReplionPath(v15, "Stock", function()
		if not self:IsActive() then
			return
		end

		self:_updateItems()
	end)
	v8.observeReplionPath(v15, "InitialStock", function()
		if not self:IsActive() then
			return
		end

		self:_updateItems()
	end)
	client:OnChange("Sword", function()
		if not self:IsActive() then
			return
		end

		self:_updateItems()
	end)
	v11.observeTag("MerchantFinisherEndtime", function(instance)
		local function updateEndTime()
			instance:SetAttribute("EndTime", v4.FFlag.GetFFlag("MerchantFinisherEndTime", v9.EndTime))
		end

		task.defer(updateEndTime)
		return v4.FFlag.OnChange(updateEndTime)
	end)
	local v16 = {}
	v11.observeTag("MerchantFinisherTimer", function(p)
		table.insert(v16, p)
		return function()
			local index = table.find(v16, p)

			if index then
				table.remove(v16, index)
			end
		end
	end)
	task.spawn(function()
		while true do
			local serverTimeNow = workspace:GetServerTimeNow()
			local v17 = getTodayTimestamp() + 86400
			merchantFinisher.Page.Frame.TimerBox.Timer.Text = `{v4.ValueConvertor:FormatTimeHHMMSS(v17 - serverTimeNow)}`
			local fFlag = v4.FFlag.GetFFlag("MerchantFinisherEndTime", v9.EndTime)
			local formatted = `{v4.ValueConvertor:FormatTimeWithDaysFull(fFlag - serverTimeNow)}`

			for _, v18 in v16 do
				v18.Text = formatted
			end

			task.wait(1)
		end
	end)
end

return MerchantFinisherController