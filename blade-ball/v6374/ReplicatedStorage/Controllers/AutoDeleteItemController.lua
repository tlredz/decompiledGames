local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
local v4 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v5 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v6 = require3(ReplicatedStorage2.Shared.AutoDeleteContainers)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Common.Utils)
local frame = Players.LocalPlayer.PlayerGui.AutoDelete.Frame
local scrollingFrame = frame.ItemsList.ScrollingFrame
local remoteEvent = v3:RemoteEvent("ToggleAutoDelete")
local maid = v2.new()
local AutoDeleteItemController = {}
AutoDeleteItemController.Trove = maid

function AutoDeleteItemController:Prompt(current, p2)
	maid:Clean()
	self.Current = current
	maid:Add(function()
		self.Current = nil
	end)

	if not v6[current] then
		return
	end

	local parent = p2 or scrollingFrame
	local v9 = v.Client:WaitReplion("Data")
	local v10 = v6[current](v9)

	for _, v11 in v10 do
		local v13

		if v11.Type == "Rarity" then
			v13 = parent.UIListLayout.Rarity
		else
			v13 = parent.UIListLayout.Item
		end

		local clone = maid:Clone(v13)
		local v14 = v4[v11.Type] and v4[v11.Type][v11.Value]
		clone.Title.Text = v14 and v14.DisplayName or v11.Value or v11.DisplayName
		clone.LayoutOrder = v5.RarityOrder[v14 and v14.Rarity or v11.Value] or 0

		if v11.Type ~= "Rarity" and v14 and v14.Icon then
			clone.ItemGlow.Item.Image = v14.Icon
		end

		clone.Parent = parent
		local v15 = v11

		local function onUpdate()
			local visible = v9:Get({
				"AutoDelete",
				current,
				v15.Type,
				v15.Value
			})
			clone.OffButton.Visible = not visible
			clone.OnButton.Visible = visible
		end

		maid:Add(v9:OnChange({ "AutoDelete", current }, onUpdate))
		task.spawn(onUpdate)
		local v17 = v11

		local function toggle()
			remoteEvent:FireServer({
				Container = current,
				Type = v17.Type,
				Name = v17.Value
			})
		end

		maid:Add(clone.Activated:Connect(toggle))
		maid:Add(clone.OnButton.Activated:Connect(toggle))
		maid:Add(clone.OnButton.Inner.Activated:Connect(toggle))
		maid:Add(clone.OffButton.Activated:Connect(toggle))
		maid:Add(clone.OffButton.Inner.Activated:Connect(toggle))
	end

	if parent == scrollingFrame then
		v7:Open("AutoDelete")
	end
end

function AutoDeleteItemController:Start()
	frame.Close.Activated:Connect(function()
		maid:Destroy()
		v7:Close("AutoDelete")
	end)
	v3:Connect("PromptAutoDelete", function(p: string)
		self:Prompt(p)
	end)
end

return AutoDeleteItemController