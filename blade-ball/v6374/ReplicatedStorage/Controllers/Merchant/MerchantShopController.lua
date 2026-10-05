local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Controllers.GiftingController)
local v2 = require3(ReplicatedStorage2.Shared.Merchant.MerchantShopData)
local v3 = require3(ReplicatedStorage2.Shared.Merchant.MerchantCrate)
local v4 = require3(ReplicatedStorage2.Shared.ReplionUtils)
require3(ReplicatedStorage2.ServerInfo)
local v5 = require3(ReplicatedStorage2.Shared.FastUtils)
local v6 = require3(ReplicatedStorage2.Shared.Statable)
local v7 = require3(ReplicatedStorage2.Common.Utils)
local v8 = require3(ReplicatedStorage2.Packages.Replion)
local v9 = require3(ReplicatedStorage2.Shared.Policy)
local v10 = require3(ReplicatedStorage2.Packages.Net)
local v11 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v12 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v13 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local remoteEvent = v10:RemoteEvent("SetMerchantShopVisibility")
local localPlayer = Players.LocalPlayer
local frame = localPlayer.PlayerGui:WaitForChild("Merchant").Page.Frame
return {
	ReplionState = v6.State(nil),
	IsActiveState = v6.State(false),
	IsWaitingToDisplayRewards = v6.State(false),
	Start = function(state)
		local v14 = v8.Client:WaitReplion("Data")
		local v15 = v8.Client:WaitReplion("LimitedStockItems")
		local v16 = v8.Client:WaitReplion("MerchantShop")
		local state2 = v6.State(false)
		v12:OnGuiOpen("Merchant", function()
			remoteEvent:FireServer(true)
		end)
		v12:OnGuiClose("Merchant", function()
			remoteEvent:FireServer(false)
		end)
		v4.observeClientReplion("MerchantShop", function(p)
			state.ReplionState:Set(p)
			return function()
				if state.ReplionState:Get() ~= p then
					state.ReplionState:Set(nil)
				end
			end
		end)
		state.IsActiveState = v6.Computed(function(callback)
			local v17 = callback(state.ReplionState)

			if not v17 then
				return false
			end

			state.IsWaitingToDisplayRewards:Set(true)
			return callback((v6.getReplionPathState(v17, "Active")))
		end)
		task.spawn(function()
			while true do
				v6.ConditionSync(function(callback)
					local v17 = callback(state.ReplionState)

					if not v17 then
						return false
					end

					return callback(v12.CurrentGuiState) == "Merchant" and not callback((v6.getReplionPathState(
						v14,
						{ "MerchantShop", "Opened", (tostring(callback((v6.getReplionPathState(v17, "ArrivalTime"))))) }
					)))
				end)
				state.IsWaitingToDisplayRewards:Set(false)

				for i = 1, 7 do
					local findFirstChild = frame.Main:FindFirstChild(`Item{i}`, true)
					findFirstChild.Visible = false
				end

				for i = 1, 7 do
					task.wait(i <= 6 and 0.5 or 1)
					local child = frame.Main:FindFirstChild(`Item{i}`, true)
					child.Highlight.Visible = true
					child.Highlight.ImageTransparency = 0
					child.Visible = true
					v5.fastTween(child.Highlight, TweenInfo.new(0.15), {
						ImageTransparency = 1
					}).Completed:Wait()
					child.Highlight.ImageTransparency = 1
					child.Highlight.Visible = false
				end
			end
		end)
		v6.Computed(function(callback)
			if callback(v12.CurrentGuiState) == "Merchant" and not callback(state.IsActiveState) then
				v12:Close("Merchant")
			end

			return true
		end)
		frame.Close.Activated:Connect(function()
			v12:Close("Merchant")
		end)
		v7.Thread.Every(1, function()
			local v17 = state.ReplionState:Get()

			if not v17 then
				return
			end

			local v18 = v17:Get("ArrivalTime") + v2.Duration - workspace:GetServerTimeNow()
			frame.TimerBox.Timer.Text = v7.ValueConvertor:FormatTimeHHMMSS(v18)
		end)
		v4.observeReplionPath(v14, "Credits", function(p)
			frame.CurrencyDisplay.Label.Text = v7.ValueConvertor:AddCommas((math.floor(p)))
		end)
		frame.CurrencyDisplay.Plus.Activated:Connect(function()
			v11:OpenCoinsPurchase()
		end)

		for i = 1, 7 do
			local child = frame.Main:FindFirstChild(`Item{i}`, true)
			local item = v2.Items[i]
			local v17 = i
			local computed = v6.Computed(function(callback)
				local v18 = callback(state.ReplionState)

				if not v18 then
					return nil
				end

				local v19 = callback((v6.getReplionPathState(v18, "Items")))[v17]
				state.IsWaitingToDisplayRewards:Set(true)
				return v19
			end)
			local v18 = { child.BuyButton }
			local buyButtonSmall = i >= 7 and child:FindFirstChild("BuyButtonSmall")

			if buyButtonSmall then
				table.insert(v18, buyButtonSmall)
				local v19 = v18[1]
				-- equivalent calls inferred from this helper; original call sites unknown
				local v20 = buyButtonSmall

				local function copyButtonProperties()
					v20.Price.CurrentPrice.Text = v19.Price.CurrentPrice.Text
					v20.Price.Icon.Image = v19.Price.Icon.Image
					v20.Price.Icon.Visible = v19.Price.Icon.Visible
					v20.Loading.Visible = v19.Loading.Visible
				end

				v19.Price.CurrentPrice:GetPropertyChangedSignal("Text"):Connect(copyButtonProperties)
				v19.Price.Icon:GetPropertyChangedSignal("Image"):Connect(copyButtonProperties)
				v19.Price.Icon:GetPropertyChangedSignal("Visible"):Connect(copyButtonProperties)
				v19.Loading:GetPropertyChangedSignal("Visible"):Connect(copyButtonProperties)
				copyButtonProperties() -- equivalent call inferred; original call site unknown
				local gift = child:FindFirstChild("Gift")

				if gift then
					table.insert(v18, gift)
				end
			end

			for _, v19 in v18 do
				local v20 = computed
				local v21 = v19
				local v22 = i
				local v23 = item
				v19.Activated:Connect(function()
					local v24 = v20:Get()

					if not v24 then
						return
					end

					v21.Loading.Visible = true
					local v25 = v21.Name == "Gift"
					local v26, v27 = v10:Invoke("BuyMerchantShopItem", v22, v24.ItemID, v25)
					v21.Loading.Visible = false

					if not v26 then
						ReplicatedStorage2.Misc.error:Play()
						return
					end

					local v28 = v23[v24.ItemID]

					if not v28 then
						return
					end

					if v25 and v28.GiftName then
						v:SetGift(v28.GiftName)
					end
				end)
			end

			local v22 = i
			v6.Computed(function(callback)
				local v23 = callback(computed)
				child.Visible = v23 ~= nil

				if not v23 then
					return false
				end

				local itemID = v23.ItemID
				local v24 = item[itemID]
				child.ItemName.Text = v24.Reward.DisplayName
				child.Icon.Image = v24.Reward.Icon or ""
				child.BuyButton.Price.Icon.Visible = v24.Currency == nil
				local text = v7.ValueConvertor:AddCommas(v24.Cost)

				if v24.Currency == "Robux" and v24.ProductId then
					v13(child.BuyButton.Price.CurrentPrice, v24.ProductId, "DevProduct", ":robux:%s")
				else
					child.BuyButton.Price.CurrentPrice:RemoveTag("ProductPriceLabel")
					child.BuyButton.Price.CurrentPrice.Text = text
				end

				if v24.Description then
					child.ItemDescription.Text = v24.Description
				end

				if not (v22 >= 7) then
					return true
				end

				child.Odds.Visible = v24.HasPaidRandomItems
				local uIGradient = child.ItemName:FindFirstChildWhichIsA("UIGradient")

				if uIGradient then
					uIGradient:Destroy()
				end

				local child2 = ReplicatedStorage2.Assets.UI.MerchantShopGradients:FindFirstChild(itemID)

				if child2 then
					local clone = child2:Clone()
					clone.Parent = child.ItemName
				end

				return true
			end)
			local itemStock = child:FindFirstChild("ItemStock") or child.Fade.Remaining
			local v23 = computed
			local v25 = child
			local v26 = item
			local v27 = i
			v6.Computed(function(callback)
				local v28 = callback(v23)
				local v29 = callback(state.ReplionState)

				if not (v28 and v29) then
					itemStock.Text = ""
					return true
				end

				v25.Visible = v28 ~= nil

				if not v28 then
					itemStock.Text = ""
					return true
				end

				local itemID = v28.ItemID
				local v30 = v26[itemID]
				local v31 = 0
				local maxPurchases = 0
				local v32 = v30.LimitedStockKey and `{v30.LimitedStockKey}-{callback((v6.getReplionPathState(v16, "ArrivalTime")))}`

				if v30.GloballyLimitedStock then
					if v32 then
						v31 = callback((v6.getReplionPathState(v15, { "Stock", v32 }))) or 0
						maxPurchases = callback((v6.getReplionPathState(v15, { "InitialStock", v32 }))) or 0
					end
				else
					local v33 = callback((v6.getReplionPathState(v14, {
						"MerchantShop",
						"Purchases",
						tostring(callback((v6.getReplionPathState(v29, "ArrivalTime")))),
						itemID
					})))
					maxPurchases = v30.MaxPurchases
					v31 = v30.MaxPurchases - (v33 or 0)
				end

				local v33 = v30.MaxPurchaseTime and callback((v7.Statable.getAlarmState(callback((v6.getReplionPathState(
					v29,
					"ArrivalTime"
				))) + v30.MaxPurchaseTime))) and 0 or v31
				local itemOwnershipState = v7.RewardInfo.getItemOwnershipState(localPlayer, v30.Reward)
				local visible

				if itemOwnershipState then
					visible = callback(itemOwnershipState)
				else
					visible = false
				end

				v25.Owned.Visible = visible
				local v35

				if v33 > 0 then
					v35 = not visible
				else
					v35 = false
				end

				local v36 = v35 and (not v30.HasPaidRandomItems or not v9:GetPolicyInfo().ArePaidRandomItemsRestricted)
				local v37 = v30.GiftName ~= nil
				v25.BuyButton.Visible = v36 and not v37
				local buyButtonSmall2 = v25:FindFirstChild("BuyButtonSmall")

				if buyButtonSmall2 then
					buyButtonSmall2.Visible = v36 and v37
					v25.Gift.Visible = buyButtonSmall2.Visible
				end

				itemStock.Visible = v35 or v30.GloballyLimitedStock ~= nil
				local soldOut = v25.SoldOut
				soldOut.Visible = v33 <= 0 and not visible
				local v39 = math.max(0, v33)

				if v27 <= 6 then
					itemStock.Text = `{v39} Left`
				elseif v30.Reward.Value == "Coin" then
					itemStock.Text = `{v39} Left`
				else
					itemStock.Text = `{v39}/{maxPurchases}`
				end

				return true
			end)

			if i ~= 7 then
				continue
			end

			local v28 = computed
			local v29 = item
			local v30 = child
			v6.Computed(function(callback)
				local v31 = callback(v28)

				if not v31 then
					return true
				end

				local v32 = v29[v31.ItemID]
				state2:Set(false)

				if v32.Reward.Type == "MerchantCrate" then
					v30.Odds.Visible = true

					for i2, guiObject in frame.Odds.List:GetChildren() do
						if guiObject:IsA("GuiObject") then
							guiObject:Destroy()
						end
					end

					for k, v33 in v3[v32.Reward.Value] do
						local clone = frame.Odds.List.UIGridLayout.OddTemplate:Clone()
						clone.Label.Text = v33.Reward.DisplayName
						clone.Vector.Image = v33.Reward.Icon or ""
						clone.Percentage.Text = `{v33.Chance}%`
						clone.LayoutOrder = math.floor(v33.Chance * 1000)

						if v33.TweenColorConfig then
							clone:SetAttribute("IgnoreChangeColor", true)

							for i2, descendant in clone:GetDescendants() do
								if descendant:IsA("UIStroke") or descendant:IsA("UIGradient") then
									descendant:SetAttribute("IgnoreChangeColor", true)
								end
							end

							clone:SetAttribute("ColorConfig", v33.TweenColorConfig)
							clone:AddTag("TweenColor")
						end

						clone.Parent = frame.Odds.List
					end
				else
					v30.Odds.Visible = false
				end

				return true
			end)
		end

		v6.setPropertyState(frame.Odds, "Visible", state2)
		frame.Main.Item7.Odds.Activated:Connect(function()
			state2:Set(not state2:Get())
		end)
	end
}