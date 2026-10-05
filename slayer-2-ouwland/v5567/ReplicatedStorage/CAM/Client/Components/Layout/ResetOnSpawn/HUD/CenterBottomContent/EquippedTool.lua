local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local faye = require(ReplicatedStorage.Packages.faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local data = Utility.GetData(localPlayer, true)
local equipped = localPlayer:WaitForChild("Items_Config"):WaitForChild("Equipped")
local info = faye.Info(0.225)
local info2 = faye.Info(0.5)
local v = {
	"One",
	"Two",
	"Three",
	"Four",
	"Five"
}
return function(object, parent)
	local value = object:Value(false)
	local value2 = object:Value(0)
	local connection = nil
	local connection2 = nil
	local connection3 = nil
	local value3 = object:Value(Color3.new(0.15, 0.15, 0.15))
	local updTool

	updTool = function()
		local get_equipped_tool = Character_info_provider.Get_equipped_tool(localPlayer)

		if connection ~= nil then
			object:Remove(connection)
			connection:Disconnect()
			connection = nil
		end

		if connection2 ~= nil then
			object:Remove(connection2)
			connection2:Disconnect()
			connection2 = nil
		end

		if connection3 ~= nil then
			object:Remove(connection3)
			connection3:Disconnect()
			connection3 = nil
		end

		local value4 = equipped.Value
		local v2 = value4 > 0 and data.Inventory.Toolbar[v[value4]]

		if v2 then
			connection3 = object:Connect(v2.Changed, updTool)
		end

		local showRemainder

		if not (get_equipped_tool == nil or not Items[get_equipped_tool.Name]) then
			showRemainder = Items[get_equipped_tool.Name].ShowRemainder or nil
		end

		value:Set(showRemainder)

		if showRemainder and get_equipped_tool ~= nil then
			local heldItem = Utility.HeldItem(data, get_equipped_tool.Name)

			if heldItem == nil then
				value2:Set(0)
			else
				local amount = heldItem:FindFirstChild("Amount")

				if amount == nil then
					value2:Set(1)
					connection = object:Connect(heldItem.ChildAdded, function(data2)
						if data2.Name == "Amount" then
							if connection then
								object:Remove(connection)
								connection:Disconnect()
								connection = nil
							end

							value2:Set(data2.Value)
							connection2 = object:Connect(data2.Changed, function(p2)
								value2:Set(p2)
								value3:Refresh()
							end)
						end
					end)
				else
					value2:Set(amount.Value)
					connection2 = object:Connect(amount.Changed, function(p2)
						value2:Set(p2)
						value3:Refresh()
					end)
				end
			end
		end
	end

	updTool()
	object:Connect(equipped.Changed, updTool)
	local v2 = nil

	local function upd()
		if v2 then
			v2:Destroy()
			v2 = nil
		end

		if value.Value == true then
			v2 = object:Extend()
			v2:Create("CanvasGroup")({
				Parent = parent,
				BackgroundColor3 = object:Animation(value3, info2, {
					AlwaysFrom = Color3.new(1, 1, 1),
					From = value3.Value
				}),
				Size = UDim2.fromScale(0.115, 0.15),
				v2:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				v2:Create("TextLabel")({
					Size = UDim2.fromScale(2, 0.86),
					AnchorPoint = Vector2.new(0.5, 0.5),
					TextScaled = true,
					TextColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.SourceSansSemibold,
					Position = UDim2.fromScale(0.5, 0.5),
					Text = v2:Do(function(callback, _, _)
						return (`x{callback(value2) or 0}`)
					end),
					BackgroundTransparency = 1
				}),
				v2:Create("UIStroke")({
					Color = Color3.new(1, 1, 1),
					BorderOffset = UDim.new(0, -2),
					Transparency = v2:Animation(0.775, info, {
						From = 1
					}),
					OnClean = function()
						return {
							Transparency = v2:Animation(1, info)
						}
					end
				}),
				BackgroundTransparency = 0.35,
				GroupTransparency = v2:Animation(0, info, {
					From = 1
				}),
				OnClean = function()
					return {
						GroupTransparency = v2:Animation(1, info)
					}
				end
			})
		end
	end

	value.Changed:Connect(upd)
	upd()
end