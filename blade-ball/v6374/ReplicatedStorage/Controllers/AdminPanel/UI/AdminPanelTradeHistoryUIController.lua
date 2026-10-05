local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
local v = require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Shared.DynArgs)
local v3 = require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.Action)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
local v5 = require3(ReplicatedStorage2.Shared.StatableCleaner)
require3(ReplicatedStorage2.Packages.Replion)
local v6 = require3(ReplicatedStorage2.Shared.DeepCopy)
local v7 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v8 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v9 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v10 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local v11 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local v12 = require3(ReplicatedStorage2.Shared.AdminPanel)
local trading = v10.AdminPanelUI.Window.Content.Pages.Trading
local _ = Players.LocalPlayer
local tradeHistory = trading.Pages.TradeHistory.TradeHistory
local tradeItemsHistory = trading.Pages.TradeHistory.TradeItemsHistory
local itemsReceived = tradeItemsHistory.Label.ItemsReceived
local itemsSent = tradeItemsHistory.Label.ItemsSent
local v13 = {
	{
		key = "Last 7 Days",
		filterTime = 604800
	},
	{
		key = "Last 14 Days",
		filterTime = 1209600
	},
	{
		key = "Last 30 Days",
		filterTime = 2592000
	},
	{
		key = "Last 60 Days",
		filterTime = 5184000
	},
	{
		key = "All",
		filterTime = 1e999
	}
}
local state = v2.State("TradeHistory")
local state2 = v2.State(v13[5])
local state3 = v2.State("")
local maid = v4.new()
local maid2 = v4.new()
local state4 = v2.State(nil)
local state5 = v2.State(nil)
local state6 = v2.State("")
local AdminPanelTradeHistoryUIController = {}

function AdminPanelTradeHistoryUIController:ShowTrade(p: number, p2)
	if state5:Get() == p2 then
		if state:Get() ~= "TradeItemsHistory" then
			state:Set("TradeItemsHistory")
		end
	else
		maid:Clean()
		state6:Set("")
		state5:Set(p2)

		if p2 == nil then
			return
		end

		local v14 = nil
		local username = nil

		for k, user in p2.Users do
			if k == tostring(p) then
				continue
			end

			v14 = tonumber(k)
			username = user.Username
			break
		end

		if not v14 then
			return
		end

		local user = p2.Users[tostring(v14)]
		local user2 = p2.Users[tostring(p)]
		tradeItemsHistory.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v14}&w=150&h=150`
		local state7 = v2.State(username)

		if not state7:Get() then
			maid:AddPromise(v:GetUser(v14):andThen(function(p3)
				state7:Set(p3.Username)
			end))
		end

		maid:Add(v2.setPropertyComputed(tradeItemsHistory.Username, "Text", function(callback)
			return (`@{callback(state7) or "[LOADING]"}`)
		end))

		for k, v16 in { user2, user } do
			local v17 = {}
			local clonesByItemToKey = {}
			local v18

			if k == 1 then
				v18 = itemsSent
			else
				v18 = itemsReceived
			end

			v18.Tokens.Amount.Text = v7.ValueConvertor:AddCommas(v16.Tokens)

			for k2, item in v16.Items do
				for _, v19 in item do
					local itemToKey = client:ItemToKey(k2, v19, { "Id" })

					if v17[itemToKey] then
						v17[itemToKey] += 1
					else
						local itemInfo = v8:GetItemInfo(k2, v19.Name)

						if itemInfo then
							local clone = maid:Clone(itemsReceived.ScrollingFrame.UIGridLayout.Template)
							clone.ItemName.Text = itemInfo.DisplayName or itemInfo.Name
							clone.Vector.Image = itemInfo.Icon or v7.Icons:GetIcon("DEFAULT_MISSING")
							local rarity = itemInfo.Rarity

							if rarity then
								local v20 = v11.SlotColors[rarity] or v11.SlotColors.Default
								clone.Image = v20.Image
								clone.HoverImage = v20.HoverImage
								clone.ItemName.UIStroke.Color = v20.StrokeColor
							end

							v9:Add(clone, k2, v19, itemToKey)

							if k == 1 then
								local v20 = string.lower(itemInfo.DisplayName or v19.Name)
								maid:Add(v2.setPropertyComputed(clone, "Visible", function(callback)
									local v21 = string.lower(callback(state6))
									return #v21 <= 0 or v20 == v21 or string.sub(v20, 1, #v21) == v21 or string.find(
										v20,
										v21,
										1,
										true
									) ~= nil
								end))
							end

							clone.Parent = v18.ScrollingFrame
							local stack = clone:FindFirstChild("Stack")
							local finisher = clone:FindFirstChild("Finisher")

							if k2 == "Sword" then
								finisher.Visible = v19 and v19.Finisher ~= nil

								if finisher.Visible then
									local child = ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(v19.Name)
									finisher.Icon.Image = child and child:GetAttribute("Icon") or v7.Icons:GetIcon("DEFAULT_MISSING")
								end
							end

							local v20 = { stack, finisher }

							for i = #v20, 1, -1 do
								if v20[i] == nil then
									table.remove(v20, i)
								end
							end

							local positions = {}

							for k3, v21 in v20 do
								local position = v21:GetAttribute("Position")

								if not position then
									position = v21.Position
									v21:SetAttribute("Position", position)
								end

								positions[k3] = position
							end

							local v21 = 1

							for _, v22 in v20 do
								if not v22.Visible then
									continue
								end

								v22.Position = positions[v21] or v22.Position
								v21 += 1
							end

							v17[itemToKey] = 1
							clonesByItemToKey[itemToKey] = clone
						else
							warn((`Failed to find info for {k2}: "{v19.Name}"`))
						end
					end
				end
			end

			for k2, v19 in v17 do
				clonesByItemToKey[k2].Stack.Label.Text = `x{v19}`
				clonesByItemToKey[k2].Stack.Visible = v19 > 1
			end
		end

		state:Set("TradeItemsHistory")
	end
end

function AdminPanelTradeHistoryUIController:Start()
	v10.LoadUserAction.Signal:Connect(function(p)
		local replion = p.Replion
		v10.UserTrove:Add(v2.Computed(function(callback)
			local v14 = callback(state)
			tradeHistory.Visible = v14 == "TradeHistory"
			tradeItemsHistory.Visible = v14 == "TradeItemsHistory"
			return nil
		end))
		v10.UserTrove:Add(tradeItemsHistory.Close.Activated:Connect(function()
			state:Set("TradeHistory")
		end))
		v10.UserTrove:Add(maid2)
		v10.UserTrove:Add(maid)

		local function requestLoadTradeHistory()
			if not (replion:Get("Inventory") and replion:Get("Exists")) then
				return
			end

			local maid3 = maid2:Add(v5.new())
			local template = tradeHistory.ScrollingFrame.UIListLayout.Template
			local templateExpanded = tradeHistory.ScrollingFrame.UIListLayout.TemplateExpanded
			local v14 = {}
			local v15 = maid3:Add(v2.State({}))
			local v16 = maid3:Add(v2.Computed(function(callback)
				local v17 = callback((v2.getReplionPathState(replion, "Inventory.TradeHistoryPage")))
				local v18 = callback((v2.getReplionPathState(replion, "Inventory.TradeHistoryIds")))
				local v19 = 500
				local result = {}

				for i = v17, math.max(v17 - 3, 1), -1 do
					local v20 = v18[tostring(i)]

					if not v20 then
						break
					end

					for k, v22 in v20 do
						if v19 <= 0 then
							break
						end

						local v23 = v11.TradeIdToStatus[v22.Status] or v22.Status

						if not (v23 == "Completed" or v23 == "Pending") then
							continue
						end

						local v24 = v6(v22)
						v24.Id = k
						v24.Page = tostring(i)
						table.insert(result, v24)
						v19 -= 1
					end
				end

				return result
			end))
			maid3:Add(v2.Computed(function(callback)
				local v17 = callback(v16)

				for _, v18 in v17 do
					if v14[v18.Id] then
						continue
					end

					local maid4 = maid2:Add(v4.new())
					local maid5 = maid3:Add(v5.new())
					local v19 = v18
					local v20 = maid5:Add(v2.Computed(function(callback2)
						local v21 = callback2(v15)

						if not v21[v19.Page] then
							return nil
						end

						for k, v22 in v21[v19.Page] do
							if v22.Id == v19.Id then
								return v22
							end
						end

						return nil
					end))
					local v21 = maid2:Add(template:Clone())
					v21.Name = v18.Id
					v14[v18.Id] = v21
					local dateTime = DateTime.fromUnixTimestamp(v18.Time)
					local v22 = ""
					local serverTimeNow = workspace:GetServerTimeNow()
					local v23 = DateTime.fromUnixTimestamp(serverTimeNow):ToLocalTime().Day - dateTime:ToLocalTime().Day
					local v24

					if serverTimeNow - dateTime.UnixTimestamp <= 172800 and (v23 == 0 or v23 == 1) then
						v24 = "LT"

						if v23 == 1 then
							v22 = "Yesterday "
						end
					else
						v24 = "l LT"
					end

					v21.Time.Text = `{v22}{dateTime:FormatLocalTime(v24, LocalizationService.SystemLocaleId)}`
					local v26 = maid5:Add(v2.Computed(function(callback2)
						local v27 = callback2(v20)

						if not v27 then
							return nil
						end

						local userId = nil
						local username = nil

						for k, user in v27.Users do
							if k == tostring(replion.Data.UserId) then
								continue
							end

							userId = tonumber(k)
							username = user.Username
							break
						end

						if userId then
							return {
								userId = userId,
								username = username
							}
						end

						return nil
					end))
					local v27 = v20
					local v28 = maid5:Add(v2.Computed(function(callback2)
						local v29 = callback2(v27)

						if v29 then
							return v29.Users[tostring(replion.Data.UserId)]
						end

						return nil
					end))
					local v29 = v20
					local v31 = maid5:Add(v2.Computed(function(callback2)
						local v32 = callback2(v29)
						local v33 = callback2(v26)

						if v33 and v32 then
							return v32.Users[tostring(v33.userId)]
						end

						return nil
					end))
					local v32 = nil
					local v34 = maid5:Add(v2.State(nil))
					local v35 = v26
					local v37 = maid5:Add(v2.Computed(function(callback2)
						local v38 = callback2(v34)

						if v38 then
							return v38
						end

						local v39 = callback2(v35)

						if not v39 then
							return nil
						end

						if v39.username then
							return v39.username
						end

						if not v32 then
							v32 = maid4:AddPromise(v:GetUser(v39.userId):andThen(function(p2)
								v34:Set(p2.Username)
							end))
						end

						return nil
					end))
					maid5:Add(v2.setPropertyComputed(v21.TextLabel, "Text", function(callback2)
						return (`Trade with @{callback2(v37) or "[LOADING]"}`)
					end))
					maid5:Add(v2.setPropertyComputed(v21.Tokens.Amount, "Text", function(callback2)
						local v41 = callback2(v31)
						local v42 = callback2(v28)

						if v42 and v41 then
							local v43 = math.floor(v41.Tokens - v42.Tokens)
							return (`{v43 > 0 and "+" or v43 < 0 and "-" or ""}{v7.ValueConvertor:AddCommas((math.abs(v43)))}`)
						else
							return "+???"
						end
					end))
					local v41 = v26
					maid5:Add(v2.setPropertyComputed(v21.ProfilePicture.Headshot, "Image", function(callback2)
						local v42 = callback2(v41)

						if v42 then
							return (`rbxthumb://type=AvatarHeadShot&id={v42.userId}&w=150&h=150`)
						end

						return ""
					end))
					local v42 = v31
					local v43 = v28
					local v45 = maid4
					maid5:Add(v2.Computed(function(callback2)
						local v46 = callback2(v42)
						local v47 = callback2(v43)

						if not (v47 and v46) then
							return nil
						end

						for i, child in v21.ItemsHistory:GetChildren() do
							if child.Name == "Item" then
								child:Destroy()
							end
						end

						for k, v48 in { v47, v46 } do
							local v49 = 5
							local v50 = {}
							local clonesByItemToKey = {}

							for k2, item in v48.Items do
								local layoutOrder = (k - 1) * 2

								for k3, v53 in item do
									if v49 <= 0 then
										break
									end

									local itemToKey = client:ItemToKey(k2, v53, { "Id" })

									if v50[itemToKey] then
										v50[itemToKey] += 1
									else
										local itemInfo = v8:GetItemInfo(k2, v53.Name)

										if itemInfo then
											local clone = v45:Clone(v21.ItemsHistory.UIListLayout.Template)
											clone.Name = "Item"
											clone.LayoutOrder = layoutOrder
											clone.Icon.Image = itemInfo.Icon or v7.Icons:GetIcon("DEFAULT_MISSING")
											local rarity = itemInfo.Rarity

											if rarity then
												local v54 = v11.SmallerSlotColors[rarity] or v11.SmallerSlotColors.Default
												clone.Image = v54.Image
												clone.HoverImage = v54.HoverImage
											end

											v9:Add(clone, k2, v53, itemToKey)
											clone.Parent = v21.ItemsHistory
											local stack = clone:FindFirstChild("Stack")
											local finisher = clone:FindFirstChild("Finisher")

											if k2 == "Sword" then
												finisher.Visible = v53 and v53.Finisher ~= nil

												if finisher.Visible then
													local child = ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(v53.Name)
													finisher.Icon.Image = child and child:GetAttribute("Icon") or v7.Icons:GetIcon("DEFAULT_MISSING")
												end
											end

											local v54 = { stack, finisher }

											for i = #v54, 1, -1 do
												if v54[i] == nil then
													table.remove(v54, i)
												end
											end

											local positions = {}

											for k4, v55 in v54 do
												local position = v55:GetAttribute("Position")

												if not position then
													position = v55.Position
													v55:SetAttribute("Position", position)
												end

												positions[k4] = position
											end

											local v55 = 1

											for k4, v56 in v54 do
												if not v56.Visible then
													continue
												end

												v56.Position = positions[v55] or v56.Position
												v55 += 1
											end

											v50[itemToKey] = 1
											clonesByItemToKey[itemToKey] = clone
											v49 -= 1
										else
											warn((`Failed to find info for {k2}: "{v53.Name}"`))
										end
									end
								end

								if v49 <= 0 then
									break
								end
							end

							for k2, v52 in v50 do
								clonesByItemToKey[k2].Stack.Label.Text = `x{v52}`
								clonesByItemToKey[k2].Stack.Visible = v52 > 1
							end
						end

						return nil
					end))
					local v46 = v18
					local v47 = v37
					maid5:Add(v2.setPropertyComputed(v21, "Visible", function(callback2)
						local v48 = callback2(state2)

						if workspace:GetServerTimeNow() - v48.filterTime > v46.Time then
							return false
						end

						local v49 = callback2(v47)
						local v50 = string.lower(callback2(state3))

						if #v50 <= 0 or #v50 > 0 and v49 == nil then
							return true
						end

						local v51 = string.lower(v49)
						return v51 == v50 or string.sub(v51, 1, #v50) == v50 or string.find(v51, v50, 1, true) ~= nil
					end))
					local children = v21:GetChildren()
					table.insert(children, v21)
					local v48 = { "Image", "Position", "Size" }

					for _, v49 in children do
						local child

						if v49 == v21 then
							child = templateExpanded
						else
							child = templateExpanded:FindFirstChild(v49.Name)
						end

						local child2

						if v49 == v21 then
							child2 = template
						else
							child2 = template:FindFirstChild(v49.Name)
						end

						if child then
							for _, v50 in v48 do
								local v51 = v49
								local v52 = v50

								if not pcall(function()
									return v51[v52]
								end) then
									continue
								end

								local v53 = v18
								local v54 = child
								local v55 = v50
								local v56 = child2
								maid5:Add(v2.setPropertyComputed(v49, v50, function(callback2)
									if callback2(state4) == v53.Id then
										return v54[v55]
									end

									return v56[v55]
								end))
							end
						else
							local v50 = v18
							maid5:Add(v2.setPropertyComputed(v49, "Visible", function(callback2)
								return callback2(state4) == v50.Id
							end))
						end
					end

					v21.LayoutOrder = -v18.Time
					v21.Visible = true
					v21.Parent = tradeHistory.ScrollingFrame
					maid4:AttachToInstance(v21)
					local v49 = v20
					maid4:Add(v21.View.Activated:Connect(function()
						local v50 = v49:Get()

						if v50 then
							self:ShowTrade(replion.Data.UserId, v50)
						end
					end))
					local v50 = v20
					local v51 = v18
					maid4:Add(v21.Activated:Connect(function()
						if v50:Get() then
							local v53

							if state4:Get() ~= v51.Id then
								v53 = v51.Id
							end

							state4:Set(v53)
						end
					end))
				end

				return nil
			end))

			local function tryFetchPage(p2: string)
				local v17, v18, v19 = xpcall(function()
					return v12.Actions.Trade.History:Call({
						Type = "Trade",
						Page = tonumber(p2)
					})
				end, warn)

				if v17 or typeof(v19) ~= "string" then
					if v17 then
						if v18 and type(v19) == "table" then
							v15:Set(v3.Dictionary.set(v15:Get(), p2, v19))
							return v18, v19
						end

						if not v18 then
							task.wait(10)
						end

						return v18, v19
					else
						warn((`Unexpected error, failed to view {p2} history: {v18} {v19}`))
						v10:PromptError((`Unexpected error, failed to view {p2} history: {v18} {v19}`))
						return false, v18
					end
				else
					v10:PromptError((`Failed to view {p2} history: {v19}`))
					warn(`Failed to view {p2} history:`, v19)
					return false
				end
			end

			maid2:Add(task.spawn(function()
				local v17 = replion:Get("Inventory.TradeHistoryPage") or 1
				local v18 = 500

				for i = v17, math.max(v17 - 3, 1), -1 do
					while not tryFetchPage(tostring(i)) do
						task.wait(10)
					end

					local v19 = v15:Get()[tostring(i)]
					v18 -= v3.Dictionary.count(v19 or {})

					if v18 <= 0 then
						break
					end
				end
			end))

			for _, v17 in v13 do
				local v18 = maid2:Add(tradeHistory.Top.FilterPopUp.UIListLayout.Template:Clone())
				v18.Label.Text = v17.key
				v18.Parent = tradeHistory.Top.FilterPopUp
				local v19 = v17
				maid2:Add(v18.Activated:Connect(function()
					state2:Set(v19)
					tradeHistory.Top.FilterPopUp.Visible = false
				end))
			end

			maid3:Add(v2.setPropertyComputed(tradeHistory.Top.Filter.Label, "Text", function(callback)
				return callback(state2).key
			end))
			maid2:Add(tradeHistory.Top.Filter.Activated:Connect(function()
				tradeHistory.Top.FilterPopUp.Visible = not tradeHistory.Top.FilterPopUp.Visible
			end))
			local searchPlayer = tradeHistory.Top.SearchPlayer
			maid2:Add(searchPlayer.TextBox.FocusLost:Connect(function(flag: boolean)
				if flag then
					state3:Set(searchPlayer.TextBox.Text)
				end
			end))
			maid2:Add(searchPlayer.SearchButton.Activated:Connect(function()
				state3:Set(searchPlayer.TextBox.Text)
			end))
		end

		local function onLoad()
			if not trading.Pages.TradeHistory.Visible then
				trading.Pages.TradeHistory:GetPropertyChangedSignal("Visible"):Wait()
			end

			requestLoadTradeHistory()
		end

		if replion:Get("Loaded") then
			v10.UserTrove:Add(task.spawn(onLoad))
		else
			v10.UserTrove:Add(replion:OnChange("Loaded", onLoad))
		end
	end)
end

return AdminPanelTradeHistoryUIController