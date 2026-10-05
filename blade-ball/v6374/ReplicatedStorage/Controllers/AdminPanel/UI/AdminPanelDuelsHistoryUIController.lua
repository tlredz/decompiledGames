local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Shared.DynArgs)
require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.Action)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Shared.StatableCleaner)
require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Shared.DeepCopy)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v6 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v7 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v8 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local v9 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
require3(ReplicatedStorage2.Shared.AdminPanel)
local duelsHistory = v8.AdminPanelUI.Window.Content.Pages.DuelsHistory
local _ = Players.LocalPlayer
local template = duelsHistory.Frame.DuelsHistory.ScrollingFrame.UIListLayout.Template
local templateExpanded = duelsHistory.Frame.DuelsHistory.ScrollingFrame.UIListLayout.TemplateExpanded
local state = v.State(nil)
local maid = v2.new()

local function renderMatch(p, layoutOrder: number, id: string, p2)
	if duelsHistory.Frame.DuelsHistory.ScrollingFrame:FindFirstChild(id) then
		return
	end

	local maid2 = maid:Add(v2.new())
	local maid3 = maid:Add(v3.new())
	local v10 = maid2:Add(template:Clone())
	v10.Name = id
	v10.LayoutOrder = layoutOrder
	v10.Parent = duelsHistory.Frame.DuelsHistory.ScrollingFrame
	v10.Visible = true
	local dateTime = DateTime.fromUnixTimestamp(p2.Time)
	local v11 = ""
	local serverTimeNow = workspace:GetServerTimeNow()
	local v12 = DateTime.fromUnixTimestamp(serverTimeNow):ToLocalTime().Day - dateTime:ToLocalTime().Day
	local v13

	if serverTimeNow - dateTime.UnixTimestamp <= 172800 and (v12 == 0 or v12 == 1) then
		v13 = "LT"

		if v12 == 1 then
			v11 = "Yesterday "
		end
	else
		v13 = "l LT"
	end

	v10.Time.Text = `{v11}{dateTime:FormatLocalTime(v13, LocalizationService.SystemLocaleId)}`

	for k, user in p2.Users do
		local v14 = k == tostring(p.Replion.Data.UserId)

		if not v14 then
			v10.TextLabel.Text = `Duel against @{user.Username}`
		end

		local type = user.Item.Type
		local name = user.Item.Name
		local v15 = {
			Name = name
		}
		local itemToKey = client:ItemToKey(type, v15)
		local itemInfo = v6:GetItemInfo(type, name)

		if itemInfo then
			local clone = maid2:Clone(v10.ItemsHistory.UIListLayout.Template)
			clone.Name = "Item"
			clone.Icon.Image = itemInfo.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
			clone.LayoutOrder = v14 and 0 or 2
			local rarity = itemInfo.Rarity

			if rarity then
				local v16 = v9.SmallerSlotColors[rarity] or v9.SmallerSlotColors.Default
				clone.Image = v16.Image
				clone.HoverImage = v16.HoverImage
			end

			v7:Add(clone, type, v15, itemToKey)
			clone.Parent = v10.ItemsHistory
		else
			warn((`Failed to find info for {type}: "{name}"`))
		end
	end

	local children = v10:GetChildren()
	table.insert(children, v10)
	local v14 = { "Image", "Position", "Size" }

	for _, v15 in children do
		local child

		if v15 == v10 then
			child = templateExpanded
		else
			child = templateExpanded:FindFirstChild(v15.Name)
		end

		local child2

		if v15 == v10 then
			child2 = template
		else
			child2 = template:FindFirstChild(v15.Name)
		end

		if child then
			for _, v16 in v14 do
				local v17 = v15
				local v18 = v16

				if not pcall(function()
					return v17[v18]
				end) then
					continue
				end

				local v19 = child
				local v20 = v16
				local v21 = child2
				maid3:Add(v.setPropertyComputed(v15, v16, function(callback)
					if callback(state) == id then
						return v19[v20]
					end

					return v21[v20]
				end))
			end
		else
			maid3:Add(v.setPropertyComputed(v15, "Visible", function(callback)
				return callback(state) == id
			end))
		end
	end

	maid2:AttachToInstance(v10)
	maid2:Add(v10.Activated:Connect(function()
		local v16

		if state:Get() ~= id then
			v16 = id
		end

		state:Set(v16)
	end))
end

local function fetchPage(p, p2: number)
	local v10, v11 = v5:Invoke("DuelsHistory/Get", (tostring(p2)))
	assert(v10, v11)

	for k, v12 in v11 do
		renderMatch(p, k, v12.Id, v12)
	end
end

return {
	Start = function(_)
		v8.LoadUserAction.Signal:Connect(function(p)
			maid:Clean()
			state:Set(nil)
			v8.UserTrove:Add(maid)

			local function onLoad()
				if not duelsHistory.Visible then
					duelsHistory:GetPropertyChangedSignal("Visible"):Wait()
				end

				fetchPage(p, 1)
			end

			if p.Replion:Get("Loaded") then
				v8.UserTrove:Add(task.spawn(onLoad))
			else
				v8.UserTrove:Add(p.Replion:OnChange("Loaded", onLoad))
			end
		end)
	end
}