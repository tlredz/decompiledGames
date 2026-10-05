local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Shared.DynArgs)
local v2 = require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.Action)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Shared.Inventory.Shared)
local v6 = require3(ReplicatedStorage2.Controllers.Trading.InventoryController)
local v7 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v8 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v9 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local v10 = require3(ReplicatedStorage2.Controllers.PromptController)
require3(ReplicatedStorage2.Shared.IndexData)
require3(ReplicatedStorage2.Shared.UntradableItems)
local v11 = require3(ReplicatedStorage2.Shared.ItemInfo)
local actions = require3(ReplicatedStorage2.Shared.AdminPanel).Actions
local v12 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local adminPanelUI = v12.AdminPanelUI
local inventory = adminPanelUI.Window.Content.Pages.Inventory
local frame = adminPanelUI.Window.PromptItem.Frame
local buttons = inventory.Buttons
local addItem = buttons.AddItem
local delete = buttons.Delete
local v13 = require3(ReplicatedStorage2.Shared.DeepCopy)
v.State(nil)
local v14 = {
	"Sword",
	"Explosion",
	"Emote",
	"Ability",
	"Booth"
}
utf8.char(1)
local state = v.State(false)
local state2 = v.State(nil)
local state3 = v.State("Sword")
local state4 = v.State("")
local state5 = v.State("Default")
local state6 = v.State("Most")
local fakeCaller = v8:GetFakeCaller(v14)
local v15 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function updateDefaultTimedTradeLock()
	v15 = math.floor((workspace:GetServerTimeNow())) + 604800
end

local function getDefaultTradeLockValueFor(p: string, p2)
	local v16

	if p2 then
		v16 = p2.TradeLock and p2.TradeLock.Type == p
	end

	if p == "Permanent" then
		return true
	end

	if v16 then
		return p2.TradeLock.Value
	end

	if p == "Date" or p == "Trial" then
		return v15
	end

	if p == "Listing" then
		return ""
	end

	error((`Default Trade Lock Value not found for {p}`))
end

return {
	Start = function(_)
		v12.LoadUserAction.Signal:Connect(function(p)
			local replion = p.Replion
			local maid = v12.UserTrove:Add(v3.new())
			local caller = {
				Type = "FakeCaller",
				CustomType = "Panel",
				ModifyPath = function(p2)
					return v2.List.concat({ "Inventory", "Inventory" }, v2.List.shift(p2))
				end,
				Replion = replion
			}

			local function edit(p2, data, p3: string)
				maid:Clean()

				if not v12:HasPermission("Inventory.Write") then
					v12:PromptError("Not enough permission to edit items")
					return
				end

				local v17 = {
					Type = "Permanent",
					Value = true
				}
				local state7 = v.State(v13(data))

				local function transformItem(callback)
					local v18 = state7:Get()

					if type(v18) == "table" then
						v18 = v13(v18)
					end

					state7:Set((callback(v18)))
				end

				adminPanelUI.Window.PromptItemSinkInput.Visible = true
				frame.Parent.Visible = true
				frame.ItemName.Text = data.Name
				local v18

				if p3 == "Edit" then
					v18 = v.State({})

					local function update()
						v18:Set(v5:FindItemsWithKey(caller, p2, v5:ItemToKey(p2, data)))
					end

					maid:Add(v5:OnChange(caller, p2, update))
					maid:Add(task.spawn(update))
				else
					v18 = nil
				end

				local text2 = 1

				-- equivalent calls inferred from this helper; original call sites unknown
				local function getMaxAmount()
					if v18 then
						return #v18:Get()
					end

					return 999
				end

				local v20 = maid:Add(v.Computed(function(callback)
					local v21 = callback(state7)
					local v22 = v11[p2][data.Name]
					local v23 = {}

					local function setVisibility(p4: string, flag: boolean)
						if not flag then
							return
						end

						v23[p4] = flag and true or nil
						return flag
					end

					local kills = v21.Kills
					frame.List.Kills.Visible = kills ~= nil
					local v24 = kills ~= nil

					if v24 then
						v23.Kills = v24 and true or nil
					end

					local placeholderText = v4.ValueConvertor:AddCommas(data.Kills or 0)
					local v26

					if kills then
						v26 = v4.ValueConvertor:AddCommas(kills) or placeholderText
					else
						v26 = placeholderText
					end

					frame.List.Kills.EnterAmount.TextBox.Text = v26 == placeholderText and "" or v26
					frame.List.Kills.EnterAmount.TextBox.PlaceholderText = placeholderText
					local serial = v21.Serial
					local visible

					if p2 == "Sword" then
						visible = v22 and v22.Rarity == "LimitedU"
					else
						visible = false
					end

					if visible then
						v23.Serial = visible and true or nil
					end

					frame.List.SerialCheckbox.Visible = visible
					frame.List.SerialCheckbox.Checkbox.Image = visible and type(serial) == "number" and "rbxassetid://102801840628550" or "rbxassetid://136322377512313"
					local placeholderText2 = tostring(serial or 0)
					local v29

					if serial then
						v29 = tostring(serial) or placeholderText2
					else
						v29 = placeholderText2
					end

					frame.List.Serial.Visible = visible and type(serial) == "number"
					frame.List.Serial.EnterAmount.TextBox.Text = v29 == placeholderText2 and "" or v29
					frame.List.Serial.EnterAmount.TextBox.PlaceholderText = placeholderText2
					local upgrade = v21.Upgrade
					local visible2 = p2 == "Ability"
					local placeholderText3 = tostring(upgrade or 0)
					local text

					if upgrade then
						text = tostring(upgrade) or placeholderText3
					else
						text = placeholderText3
					end

					if visible2 then
						v23.Upgrade = visible2 and true or nil
					end

					frame.List.Upgrade.Visible = visible2
					frame.List.Upgrade.EnterAmount.TextBox.Text = text
					frame.List.Upgrade.EnterAmount.TextBox.PlaceholderText = placeholderText3
					local finisher = v21.Finisher
					local v33 = finisher ~= nil

					if v33 then
						v23.Finisher = v33 and true or nil
					end

					local finisher2 = frame.List.Finisher
					finisher2.Visible = p2 == "Sword" and v22.HasFinisher
					frame.List.Finisher.Checkbox.Image = finisher == true and "rbxassetid://102801840628550" or "rbxassetid://136322377512313"
					local accessory = v21.Accessory
					local v35 = accessory ~= nil

					if v35 then
						v23.Accessory = v35 and true or nil
					end

					local accessory2 = frame.List.Accessory
					accessory2.Visible = p2 == "Sword" and v22.AccessoryUnlockable
					frame.List.Accessory.Checkbox.Image = accessory == true and "rbxassetid://102801840628550" or "rbxassetid://136322377512313"

					if v12:HasPermission("Inventory.TradeLock") then
						local tradeLock = v21.TradeLock
						v23.TradeLock = true
						frame.List.TradeLock.Visible = true
						frame.List.TradeLock.Checkbox.Image = tradeLock == nil and "rbxassetid://136322377512313" or "rbxassetid://102801840628550"
						frame.List.Type.Visible = tradeLock ~= nil
						frame.List.Type.PopUp.TextLabel.Text = not tradeLock and "None" or tradeLock.Type or "None"
						local value = frame.List.Value
						value.Visible = tradeLock ~= nil and tradeLock.Type ~= "Permanent"
						local value2 = tostring(tradeLock and data.TradeLock and data.TradeLock.Type == tradeLock.Type and data.TradeLock.Value or v15)

						if tradeLock ~= nil and tradeLock.Type ~= "Permanent" then
							value2 = tradeLock.Value or value2
						end

						local v38 = tostring(value2)
						frame.List.Value.EnterAmount.TextBox.Text = v38 == tostring(v17) and "" or v38
						frame.List.Value.EnterAmount.TextBox.PlaceholderText = tostring(getDefaultTradeLockValueFor("Date"))
						frame.List.TradeHold.Visible = tradeLock ~= nil
						frame.List.TradeHold.Checkbox.Image = tradeLock and tradeLock.IsTradeHold == true and "rbxassetid://102801840628550" or "rbxassetid://136322377512313"
					else
						frame.List.TradeLock.Visible = false
						frame.List.Type.Visible = false
						frame.List.Value.Visible = false
						frame.List.TradeHold.Visible = false
					end

					frame.Counter.Visible = p3 == "Add" or v18 and #callback(v18) > 1
					frame.List.NothingToEdit.Visible = not next(v23)
					return nil
				end))

				local function updateCounter()
					local maxAmount = getMaxAmount() -- equivalent call inferred; original call site unknown

					if maxAmount == 0 then
						return
					end

					text2 = math.clamp(text2, 1, maxAmount)
					frame.Counter.Amount.Text = text2

					if text2 == 1 then
						frame.Counter.Minus.Image = "rbxassetid://18948526144"
						frame.Counter.Minus.HoverImage = "rbxassetid://18948573262"
					else
						frame.Counter.Minus.Image = "rbxassetid://18948593939"
						frame.Counter.Minus.HoverImage = "rbxassetid://18948596162"
					end

					if text2 == maxAmount then
						frame.Counter.Add.Image = "rbxassetid://18948588224"
						frame.Counter.Add.HoverImage = "rbxassetid://18948582588"
					else
						frame.Counter.Add.Image = "rbxassetid://18948517903"
						frame.Counter.Add.HoverImage = "rbxassetid://18948575339"
					end
				end

				maid:Add(frame.Counter.Add.Activated:Connect(function()
					if text2 + 1 > (v18 and #v18:Get() or 999) then
						return
					end

					text2 += 1
					updateCounter()
				end))
				maid:Add(frame.Counter.Minus.Activated:Connect(function()
					if text2 - 1 < 1 then
						return
					end

					text2 -= 1
					updateCounter()
				end))
				maid:Add(task.spawn(updateCounter))
				local v21 = {
					"k",
					"m",
					"b",
					"t"
				}
				maid:Add(frame.List.Kills.EnterAmount.TextBox.FocusLost:Connect(function()
					local text = string.lower(frame.List.Kills.EnterAmount.TextBox.Text)

					for k, v23 in v21 do
						local v24 = tonumber(string.match(text, (`^([%d%.]*)[{v23}]$`)) or "")

						if not v24 then
							continue
						end

						text = tostring(v24 * 1000 ^ k)
						break
					end

					local kills = tonumber((string.gsub(text, "%D+", "")))
					local v23 = state7:Get()

					if type(v23) == "table" then
						v23 = v13(v23)
					end

					if kills == nil then
						kills = data.Kills or 0
					end

					v23.Kills = kills
					state7:Set(v23)
					v20:Update()
				end))
				maid:Add(frame.List.Finisher.Checkbox.Activated:Connect(function()
					local v22 = state7:Get()

					if type(v22) == "table" then
						v22 = v13(v22)
					end

					v22.Finisher = not v22.Finisher or nil
					state7:Set(v22)
				end))
				maid:Add(frame.List.Accessory.Checkbox.Activated:Connect(function()
					local v22 = state7:Get()

					if type(v22) == "table" then
						v22 = v13(v22)
					end

					v22.Accessory = not v22.Accessory or nil
					state7:Set(v22)
				end))
				maid:Add(frame.List.TradeLock.Checkbox.Activated:Connect(function()
					local v22 = state7:Get()

					if type(v22) == "table" then
						v22 = v13(v22)
					end

					local tradeLock

					if not v22.TradeLock then
						tradeLock = data.TradeLock or v17
					end

					v22.TradeLock = tradeLock
					state7:Set(v22)
				end))
				maid:Add(frame.List.Type.PopUp.Activated:Connect(function()
					frame.List.Type.PopUp.Frame.Visible = not frame.List.Type.PopUp.Frame.Visible
				end))

				for _, button in frame.List.Type.PopUp.Frame.Pop:GetChildren() do
					if not button:IsA("GuiButton") then
						continue
					end

					local v22 = button
					maid:Add(button.Activated:Connect(function()
						local v23 = state7:Get()

						if type(v23) == "table" then
							v23 = v13(v23)
						end

						if v23.TradeLock ~= nil then
							v23.TradeLock.Type = v22.Name
							local tradeLock = v23.TradeLock
							local name = v22.Name
							local v24 = data
							local v25

							if v24 then
								v25 = v24.TradeLock and v24.TradeLock.Type == name
							end

							local value

							if name == "Permanent" then
								value = true
							elseif v25 then
								value = v24.TradeLock.Value
							elseif name == "Date" or name == "Trial" then
								value = v15
							elseif name == "Listing" then
								value = ""
							else
								error((`Default Trade Lock Value not found for {name}`))
							end

							tradeLock.Value = value
						end

						state7:Set(v23)
						frame.List.Type.PopUp.Frame.Visible = false
					end))
				end

				maid:Add(frame.List.Value.EnterAmount.TextBox.FocusLost:Connect(function()
					local text = string.lower(frame.List.Value.EnterAmount.TextBox.Text)
					local value = tonumber((string.gsub(text, "%D+", "")))
					local v22 = state7:Get()

					if type(v22) == "table" then
						v22 = v13(v22)
					end

					if v22.TradeLock ~= nil then
						local tradeLock = v22.TradeLock

						if not value then
							local type2 = v22.TradeLock.Type
							local v23 = data
							local v24

							if v23 then
								v24 = v23.TradeLock and v23.TradeLock.Type == type2
							end

							if type2 == "Permanent" then
								value = true
							elseif v24 then
								value = v23.TradeLock.Value
							elseif type2 == "Date" or type2 == "Trial" then
								value = v15
							elseif type2 == "Listing" then
								value = ""
							else
								error((`Default Trade Lock Value not found for {type2}`))
								value = nil
							end
						end

						tradeLock.Value = value
					end

					state7:Set(v22)
					v20:Update()
				end))
				maid:Add(frame.List.SerialCheckbox.Checkbox.Activated:Connect(function()
					local v22 = state7:Get()

					if type(v22) == "table" then
						v22 = v13(v22)
					end

					v22.Serial = v22.Serial == nil and 0 or nil
					state7:Set(v22)
				end))
				maid:Add(frame.List.Serial.EnterAmount.TextBox.FocusLost:Connect(function()
					local text = string.lower(frame.List.Serial.EnterAmount.TextBox.Text)
					local serial = tonumber((string.gsub(text, "%D+", "")))
					local v22 = state7:Get()

					if type(v22) == "table" then
						v22 = v13(v22)
					end

					if v22.Serial ~= nil then
						if serial == nil then
							serial = data.Serial
						end

						v22.Serial = serial
					end

					state7:Set(v22)
					v20:Update()
				end))

				local function getMaxLevel(name: string)
					local child = ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(name)

					if not child then
						error((`Ability {name} not found`))
					end

					local maxUpgrade = child:GetAttribute("MaxUpgrade") or not child:GetAttribute("NonUpgradable") and 2

					if maxUpgrade then
						return (math.max(maxUpgrade, 0))
					end

					return 0
				end

				maid:Add(frame.List.Upgrade.EnterAmount.TextBox.FocusLost:Connect(function()
					local text = string.lower(frame.List.Upgrade.EnterAmount.TextBox.Text)
					local upgrade = tonumber((string.gsub(text, "%D+", "")))
					local upgrade2 = state7:Get().Upgrade

					if upgrade == nil then
						upgrade = data.Upgrade
					end

					local maxLevel = getMaxLevel(data.Name)

					if maxLevel < upgrade or upgrade < 0 then
						local thread = coroutine.running()
						local v22 = {}
						local v23 = false
						v10:CreatePrompt({
							PromptType = "Confirm",
							Description = not (maxLevel < upgrade) and "The upgrade level entered is lower than 0\nAre you sure you want to do this?" or `The upgrade level entered is above the max level of this ability (Level {maxLevel})\nAre you sure you want to do this?`
						}, function(p4, p5: string?)
							v22 = table.pack(p4, p5)

							if coroutine.status(thread) == "suspended" then
								task.spawn(thread)
							else
								v23 = true
							end
						end)

						if not v23 then
							coroutine.yield()
						end

						local v24, v25 = table.unpack(v22)

						if not v24 then
							if v25 then
								v12:PromptError(v25)
							end

							frame.List.Upgrade.EnterAmount.TextBox.Text = tostring(upgrade2 or 0)
							return
						end
					end

					local v22 = state7:Get()

					if type(v22) == "table" then
						v22 = v13(v22)
					end

					v22.Upgrade = upgrade
					state7:Set(v22)
					v20:Update()
				end))
				maid:Add(frame.List.TradeHold.Checkbox.Activated:Connect(function()
					local v22 = state7:Get()

					if type(v22) == "table" then
						v22 = v13(v22)
					end

					if v22.TradeLock ~= nil then
						v22.TradeLock.IsTradeHold = not v22.TradeLock.IsTradeHold or nil
					end

					state7:Set(v22)
				end))
				maid:Add(frame.Cancel.Activated:Connect(function()
					maid:Clean()
				end))
				maid:Add(frame.Close.Activated:Connect(function()
					maid:Clean()
				end))
				local flag = false
				maid:Add(frame.Confirm.Activated:Connect(function()
					local attributes = state7:Get()

					if not attributes or flag then
						return
					end

					flag = true

					if p3 == "Edit" then
						local v23 = v13(attributes)

						if v2.Dictionary.equals(v23, data) then
							maid:Clean()
							flag = false
							return
						else
							local v24 = {
								[p2] = {}
							}

							for _, v25 in table.move(v18:Get(), 1, text2, 1, {}) do
								v24[p2][v25] = v23
							end

							local v25, v26 = actions.Inventory.BatchModify:Call(v24)

							if not v25 and v26 then
								v12:PromptError(v26)
							end
						end
					elseif p3 == "Add" then
						if text2 <= 0 then
							maid:Clean()
							flag = false
							return
						else
							local v23 = {
								[p2] = {}
							}

							for _ = 1, text2 do
								table.insert(v23[p2], {
									Name = data.Name,
									Attributes = attributes
								})
							end

							local v24, v25 = actions.Inventory.BatchAdd:Call(v23)

							if not v24 and v25 then
								v12:PromptError(v25)
							end
						end
					end

					flag = false
					maid:Clean()
				end))
				maid:Add(function()
					adminPanelUI.Window.PromptItemSinkInput.Visible = false
					frame.Parent.Visible = false
				end)
			end

			local function requestLoadInventory()
				updateDefaultTimedTradeLock() -- equivalent call inferred; original call site unknown

				if not (replion:Get("Exists") and replion:Get("Inventory") and v12:HasPermission("Inventory.Read")) then
					return
				end

				v12.UserTrove:Add(v6:CreateTabOptions(inventory.TopButtons, state3, state4))
				v12.UserTrove:Add(v6:CreateSortOptions(inventory.Sort, state5, state6, {
					"Default",
					"Alphabetical",
					"RAP",
					"Exists",
					"Creation Date"
				}))
				v12.UserTrove:Add(v6:CreateSearchBox(inventory.ItemSearch, state4))
				v12.UserTrove:Add(state4:Connect(function()
					inventory.ScrollingFrame.CanvasPosition = Vector2.zero
				end))
				v12.UserTrove:Add(state3:Connect(function()
					inventory.ScrollingFrame.CanvasPosition = Vector2.zero
					state4:Set("")
				end))
				local hasPermission = v12:HasPermission("Inventory.Write")
				v12.UserTrove:Add(addItem.Activated:Connect(function()
					state2:Set(nil)
					state:Set(not state:Get())
				end))
				v12.UserTrove:Add(inventory.DeleteItems.List.Buttons.Cancel.Activated:Connect(function()
					state2:Set(nil)
				end))
				local flag = false
				v12.UserTrove:Add(inventory.DeleteItems.List.Buttons.Delete.Activated:Connect(function()
					local v17 = state2:Get()

					if not v17 or flag then
						return
					end

					local count = 0
					local v18 = {}

					for k, v19 in v17 do
						local v20 = {}

						for _, v21 in v19 do
							for _, v22 in v21 do
								count += 1
								table.insert(v20, v22)
							end
						end

						v18[k] = v20
					end

					if count == 0 then
						return v12:PromptError("Select items to delete")
					end

					flag = true
					v10:CreatePrompt({
						PromptType = "Confirm",
						Description = `Are you sure you want to delete x{count} items? This cannot be undone.`
					}, function(p2, p3: string?)
						if p2 then
							state2:Set(nil)
							local v19, v20 = actions.Inventory.BatchRemove:Call(v18)

							if not v19 and v20 then
								v12:PromptError(v20)
							end

							flag = false
						else
							flag = false

							if p3 then
								v12:PromptError(p3)
							end
						end
					end)
				end))
				v12.UserTrove:Add(delete.Activated:Connect(function()
					state:Set(false)

					if state2:Get() then
						state2:Set(nil)
					else
						state2:Set({})
					end
				end))
				v12.UserTrove:Add(function()
					state:Set(false)
					state2:Set(nil)
				end)
				v12.UserTrove:Add(v.Computed(function(callback)
					local v17 = callback(state2) ~= nil
					delete.Image = v17 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
					delete.HoverImage = v17 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
					local uIStroke = delete.Label.UIStroke
					local color

					if v17 then
						color = Color3.fromRGB(149, 67, 0)
					else
						color = Color3.fromRGB(21, 56, 169)
					end

					uIStroke.Color = color
					return nil
				end))
				v12.UserTrove:Add(v.Computed(function(callback)
					if callback(state2) == nil then
						inventory.DeleteItems.Visible = false
						inventory.ScrollingFrame.Position = UDim2.fromScale(0.482, 0.485)
						inventory.ScrollingFrame.Size = UDim2.fromScale(0.96, 0.77)
					else
						inventory.DeleteItems.Visible = true
						inventory.ScrollingFrame.Position = UDim2.fromScale(0.43, 0.485)
						inventory.ScrollingFrame.Size = UDim2.fromScale(0.815, 0.77)
					end

					return nil
				end))
				v12.UserTrove:Add(v.Computed(function(callback)
					addItem.Visible = not callback(state2) and hasPermission
					delete.Visible = not callback(state) and hasPermission
					return nil
				end))
				v12.UserTrove:Add(v.Computed(function(callback)
					local v17 = callback(state)
					addItem.Image = v17 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
					addItem.HoverImage = v17 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
					local uIStroke = addItem.Label.UIStroke
					local color

					if v17 then
						color = Color3.fromRGB(149, 67, 0)
					else
						color = Color3.fromRGB(21, 56, 169)
					end

					uIStroke.Color = color
					return nil
				end))
				local v17 = {}

				local function tryDeleteObject(guiObject)
					local itemType = guiObject:GetAttribute("ItemType")
					local name = guiObject.Name
					local v18 = state2:Get()

					if not (v18 and v18[itemType]) or #(v18[itemType][name] or {}) <= 0 then
						guiObject:Destroy()
						local v19 = v17[itemType]

						if v19 then
							local keyToItem = v5:KeyToItem(caller, name)
							v19.TriggerUpdate(keyToItem, "Insert")
							v19.TriggerUpdate(keyToItem, "Change")
						end
					end
				end

				local extended = v12.UserTrove:Extend()
				v12.UserTrove:Add(v.Computed(function(callback)
					local scrollingFrame = inventory.DeleteItems.List.ContentsCanvas.ScrollingFrame
					local v18 = callback(state2)

					for _, guiObject in scrollingFrame:GetChildren() do
						if guiObject:IsA("GuiObject") then
							tryDeleteObject(guiObject)
						end
					end

					if not v18 then
						return nil
					end

					for k, v19 in v18 do
						for childName, v20 in v19 do
							local keyToItem = v5:KeyToItem(caller, childName)
							local clone = scrollingFrame:FindFirstChild(childName)

							if not clone then
								clone = extended:Clone(scrollingFrame.UIListLayout.Template)
								clone.Name = childName
								clone:SetAttribute("ItemType", k)
								clone.Parent = scrollingFrame
								v7:Add(clone, k, keyToItem, childName)
								local v21 = v20
								local v22 = v19
								local v23 = childName
								local v24 = k

								local function removeItem()
									table.remove(v21, 1)

									if #v21 <= 0 then
										v22[v23] = nil
										extended:Remove(clone)

										if v17[v24] then
											v17[v24].TriggerUpdate(v5:KeyToItem(caller, v23), "Insert")
										end
									elseif v17[v24] then
										v17[v24].TriggerUpdate(v5:KeyToItem(caller, v23), "Change")
									end

									state2:Set(table.clone(v18))
								end

								clone.Button.Activated:Connect(removeItem)
								clone.Button.Item.Activated:Connect(removeItem)
							end

							local v21 = v11[k][keyToItem.Name]
							local displayName = v21.DisplayName or keyToItem.Name
							local v22 = v21.Rarity and v9.SmallerSlotColors[v21.Rarity] or v9.SmallerSlotColors.Default
							clone.Button.Item.Image = v22.Image
							clone.Button.Item.HoverImage = v22.HoverImage
							clone.Button.Item.Vector.Image = v21.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
							clone.Button.Item.Label.Text = `x{#v20}`
							clone.Button.Label.Text = displayName
						end
					end

					return nil
				end))

				local function addToMultiDelete(p2, p3)
					local v18 = state2:Get()

					if not v18 then
						return
					end

					local v19 = v18[p2]

					if not v19 then
						v19 = {}
						v18[p2] = v19
					end

					if not v19[p3] then
						v19[p3] = {}
					end

					local items = v5:FindItemsWithKey(caller, p2, p3)

					for _, v20 in v19[p3] do
						local index = table.find(items, v20)

						if index then
							table.remove(items, index)
						end
					end

					if #items <= 0 or table.find(v19[p3], items[1]) then
						return
					end

					table.insert(v19[p3], items[1])
					state2:Set(table.clone(v18))

					if v17[p2] then
						v17[p2].TriggerUpdate(v5:KeyToItem(caller, p3), "Change")
					end
				end

				for _, inventoryType in v14 do
					debug.profilebegin(inventoryType)
					debug.profilebegin("User Inventory")
					local v19 = inventoryType
					v17[inventoryType] = v12.UserTrove:Add(v6:CreateInventory({
						ItemTemplate = inventory.ScrollingFrame.UIGridLayout.Template,
						Container = inventory.ScrollingFrame,
						Caller = caller,
						SortOption = state5,
						SortOrder = state6,
						SearchFilter = state4,
						ShowCreatedAt = true,
						GetVisibleState = function()
							return v.Computed(function(callback)
								return not callback(state) or callback(state2) ~= nil
							end)
						end,
						FindItemsWithKey = function(self, p3: string)
							local items = v5:FindItemsWithKey(caller, self, p3)
							local v20 = state2:Get()
							local v21 = v20 and v20[self]

							if v21 and v21[p3] then
								items = v2.List.removeValue(items, table.unpack(v21[p3]))
							end

							return items
						end,
						OnSlotCreated = function(p2, p3, p4: string, p5, maid2)
							maid2:Add(p5.ActivationButton.Activated:Connect(function()
								if state2:Get() == nil then
									edit(p2, p3, "Edit")
								else
									addToMultiDelete(p2, p4)
								end
							end))
						end,
						InventoryType = inventoryType,
						PageVisible = v.Computed(function(callback)
							return callback(state3) == v19
						end),
						AllowAbilityInfo = true
					}))
					debug.profileend()
					debug.profilebegin("Give Inventory")
					local v20 = inventoryType
					v12.UserTrove:Add(v6:CreateInventory({
						ItemTemplate = inventory.ScrollingFrame.UIGridLayout.Template,
						Container = inventory.ScrollingFrame,
						Caller = fakeCaller,
						SortOption = state5,
						SortOrder = state6,
						SearchFilter = state4,
						GetVisibleState = function()
							return v.Computed(function(callback)
								return callback(state) and not callback(state2)
							end)
						end,
						OnSlotCreated = function(p2, p3, _: string, p4, maid2)
							maid2:Add(p4.ActivationButton.Activated:Connect(function()
								edit(p2, p3, "Add")
							end))
						end,
						InventoryType = inventoryType,
						PageVisible = v.Computed(function(callback)
							return callback(state3) == v20
						end),
						AllowAbilityInfo = true
					}))
					debug.profileend()
					debug.profileend()
				end
			end

			local function onLoad()
				if not inventory.Visible then
					inventory:GetPropertyChangedSignal("Visible"):Wait()
				end

				requestLoadInventory()
			end

			if replion:Get("Loaded") then
				v12.UserTrove:Add(task.spawn(onLoad))
				return
			end

			local v17 = nil
			v17 = v12.UserTrove:Add(replion:OnChange("Loaded", function()
				if v17 then
					v12.UserTrove:Remove(v17)
				end

				v12.UserTrove:Add(task.spawn(onLoad))
			end))
		end)
	end
}