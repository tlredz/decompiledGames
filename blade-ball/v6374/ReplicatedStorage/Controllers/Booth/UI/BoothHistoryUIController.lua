local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("StarterGui")
game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Freeze)
local v3 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Packages.Observers)
local v4 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v5 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v6 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v7 = require3(ReplicatedStorage2.Packages.Trove)
local v8 = require3(ReplicatedStorage2.Shared.DeepCopy)
local v9 = require3(ReplicatedStorage2.Common.Utils)
local v10 = require3(ReplicatedStorage2.ServerInfo)
local v11 = require3(ReplicatedStorage2.Shared.Statable)
local v12 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v13 = require3(ReplicatedStorage2.Shared.ItemInfo)
local localPlayer = Players.LocalPlayer
local history = localPlayer.PlayerGui.Booth.History
local state = v11.State("All")
local state2 = v11.State("")
return {
	Start = function(_)
		if not v10.isTradingPlazaServer() then
			return
		end

		v.Client:WaitReplion("Data")
		local v14 = v.Client:WaitReplion("Inventory")
		local template = history.List.ScrollingFrame.UIListLayout.Template
		local clonesById = {}
		local state3 = v11.State({})
		local computed = v11.Computed(function(callback)
			local v15 = callback((v11.getReplionPathState(v14, "BoothSalesPage")))
			local v16 = callback((v11.getReplionPathState(v14, "BoothSalesIds")))
			local v17 = 500
			local result = {}

			for i = v15, math.max(v15 - 3, 1), -1 do
				local v18 = v16[tostring(i)]

				if not v18 then
					break
				end

				for k, v20 in v18 do
					if v17 <= 0 then
						break
					end

					if (v4.TradeIdToStatus[v20.Status] or v20.Status) ~= "Completed" then
						continue
					end

					local v21 = v8(v20)
					v21.Id = k
					v21.Page = tostring(i)
					table.insert(result, v21)
					v17 -= 1
				end
			end

			return result
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getTradeState(p)
			return v11.Computed(function(callback)
				local v15 = callback(state3)

				if not v15[p.Page] then
					return nil
				end

				for _, v16 in v15[p.Page] do
					if v16.Id == p.Id then
						return v16
					end
				end

				return nil
			end)
		end

		v11.Computed(function(callback)
			local v15 = callback(computed)

			for _, v16 in v15 do
				if clonesById[v16.Id] then
					continue
				end

				local tradeState = getTradeState(v16) -- equivalent call inferred; original call site unknown
				local maid = v7.new()
				local clone = template:Clone()
				clone.Name = v16.Id
				clonesById[v16.Id] = clone
				local time = v16.Time or 0
				local dateTime = DateTime.fromUnixTimestamp(time)
				local v17 = ""
				local serverTimeNow = workspace:GetServerTimeNow()
				local v18 = DateTime.fromUnixTimestamp(serverTimeNow):ToLocalTime().Day - dateTime:ToLocalTime().Day
				local v19

				if serverTimeNow - dateTime.UnixTimestamp <= 172800 and (v18 == 0 or v18 == 1) then
					v19 = "LT"

					if v18 == 1 then
						v17 = "Yesterday "
					end
				else
					v19 = "l LT"
				end

				clone.Time.Text = `{v17}{dateTime:FormatLocalTime(v19, LocalizationService.SystemLocaleId)}`
				local computed2 = v11.Computed(function(callback2)
					local v21 = callback2(tradeState)

					if v21 then
						return v21.From == localPlayer.UserId
					end

					return nil
				end)
				local v21 = tradeState
				local v22 = maid:Add(v11.Computed(function(callback2)
					local v23 = callback2(v21)

					if not v23 then
						return nil
					end

					local to, toUsername

					if v23.From == localPlayer.UserId then
						to = v23.To
						toUsername = v23.ToUsername
					else
						to = v23.From
						toUsername = v23.FromUsername
					end

					if to then
						return {
							userId = to,
							username = toUsername
						}
					end

					return nil
				end))
				local v23 = nil
				local v24 = v11.State(nil)
				local v29 = maid:Add(v11.Computed(function(callback2)
					local v28 = callback2(v24)

					if v28 then
						return v28
					end

					local v29 = callback2(v22)

					if not v29 then
						return nil
					end

					if v29.username then
						return v29.username
					end

					if not v23 then
						v23 = maid:AddPromise(v12:GetUser(v29.userId):andThen(function(p)
							v24:Set(p.Username)
						end))
					end

					return nil
				end))
				local v30 = v22
				local v31 = tradeState
				maid:Add(v11.Computed(function(callback2)
					local v33 = callback2(computed2)
					local v34 = callback2(v29)
					local v35 = callback2(v30)
					local v36 = callback2(v31)
					local v37

					if v36 then
						v37 = math.floor(v36.Listing.Price * (not v33 and 1 or 1 - v4.TradeBoothTax))
					end

					local color

					if v33 == nil then
						color = Color3.fromRGB(255, 255, 255)
					elseif v33 then
						color = Color3.fromRGB(108, 230, 102)
					else
						color = Color3.fromRGB(227, 77, 77)
					end

					local color2

					if v33 == nil then
						color2 = Color3.fromRGB(18, 70, 151)
					elseif v33 then
						color2 = Color3.fromRGB(0, 91, 0)
					else
						color2 = Color3.fromRGB(86, 0, 0)
					end

					clone.Top.PlayerName.Text = `@{v34 or "[LOADING]"}`
					clone.Top.Label.Text = v33 == nil and "Loading..." or v33 and "Sold to" or "Purchased"
					clone.Top.Label.TextColor3 = color
					clone.Top.PlayerProfile.Headshot.Image = not v35 and "" or `rbxthumb://type=AvatarHeadShot&id={v35.userId}&w=150&h=150`
					clone.Top.PlayerName.Visible = v33 ~= nil
					clone.Top.PlayerProfile.Visible = v33 ~= nil
					clone.Tokens.Amount.Text = not v37 and "???" or v9.ValueConvertor:AddCommas(v37)
					clone.Tokens.Amount.TextColor3 = color
					clone.Tokens.Amount.UIStroke.Color = color2

					if not v36 then
						return nil
					end

					local type2 = v36.Listing.Type
					local item = v36.Item or {
						Name = v36.Listing.ItemName
					}
					v6:Add(clone.ItemTemplate, type2, item)
					local itemInfo = v5:GetItemInfo(type2, item.Name)
					clone.Title.Text = itemInfo and itemInfo.DisplayName or item.Name

					if not itemInfo then
						warn((`Failed to find info for {type2}: "{item.Name}"`))
						return nil
					end

					clone.ItemTemplate.Vector.Image = itemInfo.Icon or v9.Icons:GetIcon("DEFAULT_MISSING")
					local rarity = itemInfo.Rarity

					if rarity then
						local v38 = v4.SmallerSlotColors[rarity] or v4.SmallerSlotColors.Default
						clone.ItemTemplate.Image = v38.Image
						clone.ItemTemplate.HoverImage = v38.HoverImage
					end

					return nil
				end))
				local v33 = computed2
				local v34 = tradeState
				maid:Add(v11.setPropertyComputed(clone, "Visible", function(callback2)
					local v35 = callback2(state)
					local v36 = callback2(v33)

					if v35 ~= "All" and (v35 ~= "Sales" and v36 == true or v35 ~= "Purchases" and v36 == false) then
						return false
					end

					local v37 = callback2(v34)
					local v38 = string.lower(callback2(state2))

					if #v38 <= 0 or #v38 > 0 and v37 == nil then
						return true
					end

					local v39 = v13[v37.Listing.Type][v37.Listing.ItemName]
					local displayName = string.lower(v39 and v39.DisplayName or v37.Listing.ItemName)
					return displayName == v38 or string.sub(displayName, 1, #v38) == v38 or string.find(
						displayName,
						v38,
						1,
						true
					) ~= nil
				end))
				clone.LayoutOrder = -time
				clone.Parent = history.List.ScrollingFrame
				maid:AttachToInstance(clone)
			end

			return nil
		end)

		local function tryFetchPage(p: string)
			local v15, v16, v17 = xpcall(function()
				return v3:Invoke("GetBoothHistoryPage", p)
			end, warn)

			if not v15 then
				return false, v16
			end

			if v16 and type(v17) == "table" then
				state3:Set(v2.Dictionary.set(state3:Get(), p, v17))
				return v16, v17
			end

			if not v16 then
				task.wait(10)
			end

			return v16, v17
		end

		task.spawn(function()
			while not history.Visible do
				history:GetPropertyChangedSignal("Visible"):Wait()
			end

			local boothSalesPage = v14:Get("BoothSalesPage") or 1
			local v15 = 500

			for i = boothSalesPage, math.max(boothSalesPage - 3, 1), -1 do
				while not tryFetchPage(tostring(i)) do
					task.wait(10)
				end

				local v16 = state3:Get()[tostring(i)]
				v15 -= v2.Dictionary.count(v16 or {})

				if v15 <= 0 then
					break
				end
			end
		end)
		v3:Connect("AddToBoothHistory", function(p: string, p2)
			if not state3:Get()[p] then
				state3:Set(v2.Dictionary.set(state3:Get(), p, {}))
			end

			local clone = table.clone(state3:Get())
			table.insert(clone[p], p2)
			state3:Set(clone)
		end)

		for _, button in history.List.FilterPopUp:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local v15 = button
			button.Activated:Connect(function()
				state:Set(v15.Label.Text)
				history.List.FilterPopUp.Visible = false
			end)
		end

		v11.setPropertyComputed(history.List.Filter.Label, "Text", function(callback)
			return callback(state)
		end)
		history.List.Filter.Activated:Connect(function()
			history.List.FilterPopUp.Visible = not history.List.FilterPopUp.Visible
		end)
		local itemSearch = history.List.ItemSearch
		itemSearch.SearchBox.FocusLost:Connect(function(flag: boolean)
			if flag then
				state2:Set(itemSearch.SearchBox.Text)
			end
		end)
		itemSearch.Search.Activated:Connect(function()
			state2:Set(itemSearch.SearchBox.Text)
		end)
	end
}