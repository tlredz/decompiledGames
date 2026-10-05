local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local clientGameModules = ReplicatedStorage2.ClientGameModules
local _ = ReplicatedStorage2.Common
local _ = ReplicatedStorage2.Packages
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Common.Utils)
require3(clientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.TournamentEvent.TournamentEventData)
local v4 = require3(ReplicatedStorage2.Shared.TournamentEvent.TournamentEventShop)
require3(ReplicatedStorage2.Controllers.Tournaments.Event.TournamentEventController)
local v5 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v6 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v8 = nil
local remoteFunction = v2:RemoteFunction("PurchaseTournamentEventItem")
local localPlayer = Players.LocalPlayer
local container = localPlayer.PlayerGui.TournamentEvent.MainFrame.Frame.Views.Shop.Container
local template = container.UIGridLayout.Template
local TournamentEventShopController = {}

function TournamentEventShopController:_update()
	for childName, v9 in v4 do
		local child = container:FindFirstChild(childName)

		if not child then
			continue
		end

		local playerOwnsItem = v3.RewardInfo.playerOwnsItem(localPlayer, v9.Reward)
		child.Owned.Visible = playerOwnsItem
		child.Active = not playerOwnsItem
	end
end

function TournamentEventShopController:Start()
	v8 = v.Client:WaitReplion("Data")
	local v9 = v.Client:WaitReplion("LimitedStockItems")

	for _, guiObject in container:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for k, v10 in v4 do
		local clone = template:Clone()
		clone.Name = k
		clone.LayoutOrder = k
		clone.ItemName.Text = v10.Reward.DisplayName
		clone.Vector.Image = v10.Reward.Icon or ""
		clone.Price.Text = v10.Price
		local v11 = k
		clone.Activated:Connect(function()
			local v12, v13 = remoteFunction:InvokeServer(v11)

			if v12 then
				v3.Sounds:Play("Purchase")
				return
			end

			v3.Sounds:Play("error")

			if v13 then
				v5:SendNotification(v13)
			end
		end)
		v6:AddFromRewardInfo(clone, v10.Reward)
		clone.Inspect.Visible = v7:CanPreview(v10.Reward)
		local v12 = v10
		clone.Inspect.Activated:Connect(function()
			v7:PreviewReward(v12.Reward)
		end)
		local stockLeft = clone:FindFirstChild("StockLeft")

		if stockLeft then
			stockLeft.Visible = v10.LimitedStockId ~= nil
		end

		if v10.LimitedStockId then
			assert(stockLeft, "Missing stock label for " .. v10.Reward.DisplayName)
			local v13 = v10
			local v14 = stockLeft

			local function updateStock()
				local v15 = v9:Get({ "Stock", v13.LimitedStockId })
				local v16 = v9:Get({ "InitialStock", v13.LimitedStockId })
				v14.Text = `{v3.ValueConvertor:AddCommas(v15 or 0)}/{v3.ValueConvertor:ShrinkNumber(v16 or 0)} LEFT`
			end

			v9:OnChange({ "Stock", v10.LimitedStockId }, updateStock)
			v9:OnChange({ "InitialStock", v10.LimitedStockId }, updateStock)
			updateStock()
		end

		clone.Parent = container
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		self:_update()
	end

	update() -- equivalent call inferred; original call site unknown
	v8:OnChange("SwordSkins.Unlocked", update)
	v8:OnChange("Emotes.Unlocked", update)
	v8:OnChange("ExplosionSkins.Unlocked", update)
end

return TournamentEventShopController