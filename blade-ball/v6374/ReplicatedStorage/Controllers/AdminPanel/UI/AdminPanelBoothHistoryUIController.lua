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
game:GetService("Players")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Packages.Observers)
local v2 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v3 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v4 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local v5 = require3(ReplicatedStorage2.Shared.AdminPanel)
local v6 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v7 = require3(ReplicatedStorage2.Shared.StatableCleaner)
require3(ReplicatedStorage2.Packages.Trove)
local v8 = require3(ReplicatedStorage2.Shared.DeepCopy)
local v9 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.ServerInfo)
local v10 = require3(ReplicatedStorage2.Shared.Statable)
local v11 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v12 = require3(ReplicatedStorage2.Shared.ItemInfo)
local boothHistory = v4.AdminPanelUI.Window.Content.Pages.Trading.Pages.BoothHistory
local state = v10.State("All")
local state2 = v10.State("")
return {
	Start = function(_)
		v4.LoadUserAction.Signal:Connect(function(p)
			local replion = p.Replion
			local maid = v4.UserTrove:Extend()

			local function requestLoadBoothHistory()
				maid:Clean()
				state:Set("All")
				state2:Set("")

				if not (replion:Get("Inventory") and replion:Get("Exists")) then
					return
				end

				local maid2 = maid:Add(v7.new())
				local template = boothHistory.ScrollingFrame.UIListLayout.Template
				local clonesById = {}
				local v13 = maid2:Add(v10.State({}))
				local v14 = maid2:Add(v10.Computed(function(callback)
					local v15 = callback((v10.getReplionPathState(replion, "Inventory.BoothSalesPage")))
					local v16 = callback((v10.getReplionPathState(replion, "Inventory.BoothSalesIds")))
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

							if (v2.TradeIdToStatus[v20.Status] or v20.Status) ~= "Completed" then
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
				end))

				local function getTradeState(p2)
					return v10.Computed(function(callback)
						local v15 = callback(v13)

						if not v15[p2.Page] then
							return nil
						end

						for _, v16 in v15[p2.Page] do
							if v16.Id == p2.Id then
								return v16
							end
						end

						return nil
					end)
				end

				maid2:Add(v10.Computed(function(callback)
					local v15 = callback(v14)

					for _, v16 in v15 do
						if clonesById[v16.Id] then
							continue
						end

						local extended = maid:Extend()
						local maid3 = maid2:Add(v7.new())
						local v17 = maid3:Add(getTradeState(v16))
						local clone = template:Clone()
						extended:Add(clone)
						clone.Name = v16.Id
						clonesById[v16.Id] = clone
						local time = v16.Time or 0
						local dateTime = DateTime.fromUnixTimestamp(time)
						local v18 = ""
						local serverTimeNow = workspace:GetServerTimeNow()
						local v19 = DateTime.fromUnixTimestamp(serverTimeNow):ToLocalTime().Day - dateTime:ToLocalTime().Day
						local v20

						if serverTimeNow - dateTime.UnixTimestamp <= 172800 and (v19 == 0 or v19 == 1) then
							v20 = "LT"

							if v19 == 1 then
								v18 = "Yesterday "
							end
						else
							v20 = "l LT"
						end

						clone.Time.Text = `{v18}{dateTime:FormatLocalTime(v20, LocalizationService.SystemLocaleId)}`
						local v22 = maid3:Add(v10.Computed(function(callback2)
							local v23 = callback2(v17)

							if v23 then
								return v23.From == p.UserId
							end

							return nil
						end))
						local v23 = v17
						local v24 = maid3:Add(v10.Computed(function(callback2)
							local v25 = callback2(v23)

							if not v25 then
								return nil
							end

							local to, toUsername

							if v25.From == p.UserId then
								to = v25.To
								toUsername = v25.ToUsername
							else
								to = v25.From
								toUsername = v25.FromUsername
							end

							if to then
								return {
									userId = to,
									username = toUsername
								}
							end

							return nil
						end))
						local v25 = nil
						local v26 = v10.State(nil)
						local v31 = maid3:Add(v10.Computed(function(callback2)
							local v30 = callback2(v26)

							if v30 then
								return v30
							end

							local v31 = callback2(v24)

							if not v31 then
								return nil
							end

							if v31.username then
								return v31.username
							end

							if not v25 then
								v25 = extended:AddPromise(v11:GetUser(v31.userId):andThen(function(p2)
									v26:Set(p2.Username)
								end))
							end

							return nil
						end))
						local v32 = v24
						local v33 = v17
						maid3:Add(v10.Computed(function(callback2)
							local v35 = callback2(v22)
							local v36 = callback2(v31)
							local v37 = callback2(v32)
							local v38 = callback2(v33)
							local v39

							if v38 then
								v39 = math.floor(v38.Listing.Price * (not v35 and 1 or 1 - v2.TradeBoothTax))
							end

							local color

							if v35 == nil then
								color = Color3.fromRGB(255, 255, 255)
							elseif v35 then
								color = Color3.fromRGB(108, 230, 102)
							else
								color = Color3.fromRGB(227, 77, 77)
							end

							local color2

							if v35 == nil then
								color2 = Color3.fromRGB(18, 70, 151)
							elseif v35 then
								color2 = Color3.fromRGB(0, 91, 0)
							else
								color2 = Color3.fromRGB(86, 0, 0)
							end

							clone.Top.PlayerName.Text = `@{v36 or "[LOADING]"}`
							clone.Top.Label.Text = v35 == nil and "Loading..." or v35 and "Sold to" or "Purchased"
							clone.Top.Label.TextColor3 = color
							clone.Top.PlayerProfile.Headshot.Image = not v37 and "" or `rbxthumb://type=AvatarHeadShot&id={v37.userId}&w=150&h=150`
							clone.Top.PlayerName.Visible = v35 ~= nil
							clone.Top.PlayerProfile.Visible = v35 ~= nil
							clone.Tokens.Amount.Text = not v39 and "???" or v9.ValueConvertor:AddCommas(v39)
							clone.Tokens.Amount.TextColor3 = color
							clone.Tokens.Amount.UIStroke.Color = color2

							if not v38 then
								return nil
							end

							local type2 = v38.Listing.Type
							local item = v38.Item or {
								Name = v38.Listing.ItemName
							}
							v6:Add(clone.ItemTemplate, type2, item)
							local itemInfo = v3:GetItemInfo(type2, item.Name)
							clone.Title.Text = itemInfo and itemInfo.DisplayName or item.Name

							if not itemInfo then
								warn((`Failed to find info for {type2}: "{item.Name}"`))
								return nil
							end

							clone.ItemTemplate.Vector.Image = itemInfo.Icon or v9.Icons:GetIcon("DEFAULT_MISSING")
							local rarity = itemInfo.Rarity

							if rarity then
								local v40 = v2.SmallerSlotColors[rarity] or v2.SmallerSlotColors.Default
								clone.ItemTemplate.Image = v40.Image
								clone.ItemTemplate.HoverImage = v40.HoverImage
							end

							return nil
						end))
						local v35 = v22
						local v36 = v17
						maid3:Add(v10.setPropertyComputed(clone, "Visible", function(callback2)
							local v37 = callback2(state)
							local v38 = callback2(v35)

							if v37 ~= "All" and (v37 ~= "Sales" and v38 == true or v37 ~= "Purchases" and v38 == false) then
								return false
							end

							local v39 = callback2(v36)
							local v40 = string.lower(callback2(state2))

							if #v40 <= 0 or #v40 > 0 and v39 == nil then
								return true
							end

							local v41 = v12[v39.Listing.Type][v39.Listing.ItemName]
							local displayName = string.lower(v41 and v41.DisplayName or v39.Listing.ItemName)
							return displayName == v40 or string.sub(displayName, 1, #v40) == v40 or string.find(
								displayName,
								v40,
								1,
								true
							) ~= nil
						end))
						clone.LayoutOrder = -time
						clone.Parent = boothHistory.ScrollingFrame
					end

					return nil
				end))

				local function tryFetchPage(p2: string)
					local v15, v16, v17 = xpcall(function()
						return v5.Actions.Trade.History:Call({
							Type = "Booth",
							Page = tonumber(p2)
						})
					end, warn)

					if v15 or typeof(v17) ~= "string" then
						if v15 then
							if v16 and type(v17) == "table" then
								v13:Set(v.Dictionary.set(v13:Get(), p2, v17))
								return v16, v17
							end

							if not v16 then
								task.wait(10)
							end

							return v16, v17
						else
							warn((`Unexpected error, failed to view {p2} history: {v16} {v17}`))
							v4:PromptError((`Unexpected error, failed to view {p2} history: {v16} {v17}`))
							return false, v16
						end
					else
						v4:PromptError((`Failed to view {p2} history: {v17}`))
						warn(`Failed to view {p2} history:`, v17)
						return false
					end
				end

				maid:Add(task.spawn(function()
					local v15 = replion:Get("Inventory.BoothSalesPage") or 1
					local v16 = 500

					for i = v15, math.max(v15 - 3, 1), -1 do
						while not tryFetchPage(tostring(i)) do
							task.wait(10)
						end

						local v17 = v13:Get()[tostring(i)]
						v16 -= v.Dictionary.count(v17 or {})

						if v16 <= 0 then
							break
						end
					end
				end))

				for _, button in boothHistory.FilterPopUp:GetChildren() do
					if not button:IsA("ImageButton") then
						continue
					end

					local v15 = button
					maid:Add(button.Activated:Connect(function()
						state:Set(v15.Label.Text)
						boothHistory.FilterPopUp.Visible = false
					end))
				end

				maid2:Add(v10.setPropertyComputed(boothHistory.Filter.Label, "Text", function(callback)
					return callback(state)
				end))
				maid:Add(boothHistory.Filter.Activated:Connect(function()
					boothHistory.FilterPopUp.Visible = not boothHistory.FilterPopUp.Visible
				end))
				local itemSearch = boothHistory.ItemSearch
				maid:Add(itemSearch.SearchBox.FocusLost:Connect(function(flag: boolean)
					if flag then
						state2:Set(itemSearch.SearchBox.Text)
					end
				end))
				maid:Add(itemSearch.Search.Activated:Connect(function()
					state2:Set(itemSearch.SearchBox.Text)
				end))
			end

			local function onLoad()
				if not boothHistory.Visible then
					boothHistory:GetPropertyChangedSignal("Visible"):Wait()
				end

				requestLoadBoothHistory()
			end

			if replion:Get("Loaded") then
				v4.UserTrove:Add(task.spawn(onLoad))
			else
				v4.UserTrove:Add(replion:OnChange("Loaded", onLoad))
			end
		end)
	end
}