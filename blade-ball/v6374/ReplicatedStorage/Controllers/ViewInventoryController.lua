local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v3 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v4 = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Shared.ItemInfo)
require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v5 = require3(ReplicatedStorage2.Controllers.Trading.InventoryController)
local v6 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Common.Utils)
local main = Players.LocalPlayer.PlayerGui.ViewInventory.Main
local state = v4.State(nil)
local state2 = v4.State("Sword")
local state3 = v4.State("")
local state4 = v4.State("Default")
local state5 = v4.State("Most")
local maid = v2.new()
local v7 = {}
local v8 = {}
local ViewInventoryController = {}

function ViewInventoryController.ViewInventory(_, instance)
	local v9 = state:Get()

	if instance == nil then
		if v9 then
			state:Set(nil)
		end
	elseif v9 and v9.Player == instance then
		if v6:IsOpen("ViewInventory") then
			return
		end

		v6:Open("ViewInventory", nil, true)
		return true
	else
		local v10 = v7[instance] ~= nil
		local inventory = v7[instance]

		if not (v8[instance] and v10) then
			local viewInventory = v3.Remotes.ViewInventory
			local v12

			if typeof(instance) == "Instance" then
				v12 = instance
			end

			v10, inventory = viewInventory:InvokeServer(v12)

			if not v8[instance] then
				v8[instance] = true
				task.delay(v3.ViewInventoryCooldownPerPlayer, function()
					v8[instance] = nil
				end)
			end

			if not v10 and v7[instance] then
				inventory = v7[instance]
				v10 = true
			end
		end

		if v10 then
			v7[instance] = inventory
			maid:Clean()
			state2:Set("Sword")
			state3:Set("")
			state4:Set("Default")
			state5:Set("Most")
			state:Set({
				Player = instance,
				Inventory = inventory
			})
			main.Username.Text = `@{instance.Name}'s Inventory`
			main.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={instance.UserId}&w=150&h=150`
			local _ = {
				Inventory = inventory
			}
			local defaults = {
				ItemTemplate = main.ScrollingFrame.UIGridLayout.Template,
				Container = main.ScrollingFrame,
				Caller = {
					Type = "FakeCaller",
					CustomType = "ViewInventory",
					Replion = client:CreateFakeReplion({
						Inventory = inventory
					})
				},
				SortOption = state4,
				SortOrder = state5,
				SearchFilter = state3,
				WatchOnChange = false
			}

			for _, tradableItemType in v3.TradableItemTypes do
				local v13 = tradableItemType
				local pageVisible = v4.Computed(function(callback)
					return callback(state2) == v13
				end)
				maid:Add(v5:CreateInventory((v.Dictionary.merge(defaults, {
					InventoryType = tradableItemType,
					PageVisible = pageVisible
				}))))
				maid:Add(pageVisible)
			end

			v6:Open("ViewInventory", nil, true)
			return true
		else
			ReplicatedStorage2.Misc.error:Play()

			if inventory then
				warn(inventory)
			end
		end
	end
end

function ViewInventoryController.Start(_)
	v5:CreateSortOptions(main.Sort, state4, state5)
	local itemSearch = main.ItemSearch
	v4.setPropertyState(itemSearch.SearchBox, "Text", state3)
	itemSearch.SearchBox.FocusLost:Connect(function(flag: boolean)
		if flag then
			state3:Set(itemSearch.SearchBox.Text)
		end
	end)
	itemSearch.Search.Activated:Connect(function()
		state3:Set(itemSearch.SearchBox.Text)
	end)
	main.Close.Activated:Connect(function()
		v6:Close("ViewInventory", true)
	end)

	for _, button in main.TopButtons:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v9 = button
		v4.Computed(function(callback)
			local v10 = callback(state2) == v9.Name
			v9.Image = v10 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
			v9.HoverImage = v10 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
			local uIStroke = v9.Label.UIStroke
			local color

			if v10 then
				color = Color3.fromRGB(149, 67, 0)
			else
				color = Color3.fromRGB(21, 56, 169)
			end

			uIStroke.Color = color
			return nil
		end)
		local v10 = button
		button.Activated:Connect(function()
			main.ScrollingFrame.CanvasPosition = Vector2.zero
			state2:Set(v10.Name)
		end)
	end

	Players.PlayerRemoving:Connect(function(player)
		v7[player] = nil
		v8[player] = nil
	end)
end

return ViewInventoryController