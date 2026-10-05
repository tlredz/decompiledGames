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
require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.ExistCounterController)
local v8 = require3(ReplicatedStorage2.Controllers.Trading.InventoryController)
local v9 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v10 = require3(ReplicatedStorage2.Shared.Inventory.Shared)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v11 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local adminPanelUI = v11.AdminPanelUI
local existCounter = adminPanelUI.Window.Content.Pages.ExistCounter
local template = existCounter.ScrollingFrame.UIGridLayout.Template
local state = v.State("Sword")
local state2 = v.State("")
local state3 = v.State("Exists")
local state4 = v.State("Most")
local remoteEvent = v3:RemoteEvent("RequestExistCountRefresh")
local remoteEvent2 = v3:RemoteEvent("RequestViewExistCount")
return {
	Start = function(_)
		task.spawn(function()
			v11.LoadUserAction.Signal:Wait()

			if not existCounter.Visible then
				existCounter:GetPropertyChangedSignal("Visible"):Wait()
			end

			if not v11:HasPermission("ExistCounter.Read") then
				return
			end

			remoteEvent2:FireServer()
			v8:CreateTabOptions(existCounter.TopButtons, state, state2)
			v8:CreateSortOptions(existCounter.Sort, state3, state4, {
				"Default",
				"Alphabetical",
				"RAP",
				"Exists",
				"Creation Date"
			})
			v8:CreateSearchBox(existCounter.ItemSearch, state2)
			state2:Connect(function()
				existCounter.ScrollingFrame.CanvasPosition = Vector2.zero
			end)
			state:Connect(function()
				existCounter.ScrollingFrame.CanvasPosition = Vector2.zero
				state2:Set("")
			end)
			local v12 = v4.Client:WaitReplion("ExistCount")

			if not v12:Get("Loaded") then
				remoteEvent:FireServer()

				repeat
					task.wait()
				until v12:Get("Loaded") == true
			end

			local v13 = {}

			for k, v14 in v12:GetExpect("Items") do
				if not (k ~= "Finisher" and k ~= "SwordAccessory") then
					continue
				end

				v13[k] = {}

				for k2 in v14 do
					table.insert(v13[k], k2)
				end
			end

			local v14 = {
				"Sword",
				"Explosion",
				"Emote",
				"Ability"
			}
			local clone = table.clone(v14)
			table.insert(clone, "Finisher")
			table.insert(clone, "SwordAccessory")
			local fakeCaller = v9:GetFakeCaller(v14, v13)

			for _, v15 in clone do
				local inventoryType = (v15 == "Finisher" or v15 == "SwordAccessory") and "Sword" or v15
				local v17 = v15
				local v18 = v15
				local v19 = v15
				v8:CreateInventory({
					ItemTemplate = template,
					Container = existCounter.ScrollingFrame,
					Caller = fakeCaller,
					FindItemsWithKey = (v15 == "Finisher" or v15 == "SwordAccessory") and function(p, p2: string)
						local keyToItem = client:KeyToItem(p2)

						if v17 == "Finisher" and not keyToItem.Finisher or v17 == "SwordAccessory" and not keyToItem.Accessory then
							return {}
						end

						return v10:FindItems(fakeCaller, p, keyToItem.Name, {
							Finisher = v17 == "Finisher" or v2.None,
							Accessory = v17 == "SwordAccessory" or v2.None
						})
					end or nil,
					SortOption = state3,
					SortOrder = state4,
					SearchFilter = state2,
					ExistCounterReplionChannel = "ExistCount",
					OnSlotCreated = function(p, p2, p3: string, p4, maid)
						-- equivalent calls inferred from this helper; original call sites unknown
						local function updateCount()
							local existCount = v7:Get(v18, p3, nil, "ExistCount") or 0
							p4.Amount.Text = `{v5.ValueConvertor:AddCommas(existCount)} Exist`
						end

						maid:Add(v7:OnUpdated(v18, p3, updateCount, "ExistCount"))
						updateCount() -- equivalent call inferred; original call site unknown
					end,
					GetVisibleState = (v15 == "Finisher" or v15 == "SwordAccessory") and function()
						return v.Computed(function(callback)
							return callback(state2) == ""
						end)
					end or nil,
					InventoryType = inventoryType,
					PageVisible = v.Computed(function(callback)
						return callback(state) == v19
					end),
					AllowedIcons = { "Finisher", "SwordAccessory" }
				})
			end
		end)
		adminPanelUI.Window.UserInfo.Refresh.Activated:Connect(function()
			if v11.CurrentPage:Get() ~= "Home.ExistCounter" then
				return
			end

			remoteEvent:FireServer()
		end)
		existCounter.Loading.Visible = true
		v6.observeClientReplion("ExistCount", function(p)
			v6.observeReplionPath(p, "Loaded", function(p2, _)
				existCounter.Loading.Visible = not p2
				return nil
			end)
			return nil
		end)
	end
}