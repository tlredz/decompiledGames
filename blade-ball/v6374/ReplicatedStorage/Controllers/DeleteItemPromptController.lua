local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Common.MarketplaceService)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v2 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v4 = require3(ReplicatedStorage2.Packages.Freeze)
local v5 = require3(ReplicatedStorage2.Packages.Trove)
local confirmationPrompt = ReplicatedStorage2.Assets.UI.Delete.ConfirmationPrompt
local deleteConfirmation = Players.LocalPlayer.PlayerGui.DeleteConfirmation
return {
	PromptConfirmation = function(p, data, callback)
		if v2:GetKey("DisableItemDelete") then
			task.spawn(callback, false, "Delete disabled!")
			return
		end

		if p._currentConfirmationPrompt then
			task.spawn(callback, false, "Processing other delete!")
			return
		end

		local maid = v5.new()

		if data.PromptType == "Selector" then
			if client:KeyToItem((assert(data.ItemKey, "PromptType Selector requires ItemKey"))) then
				assert(
					table.find(
						client.InventoryTypes,
						(assert(data.InventoryType, "PromptType Selector requires InventoryType"))
					),
					"Invalid InventoryType"
				)
			else
				task.spawn(callback, false, "Invalid item")
				return
			end
		end

		local clone = confirmationPrompt:Clone()
		clone[data.PromptType].Title.Text = data.Description
		clone[data.PromptType].Visible = true
		local text = 1

		if data.PromptType == "Selector" then
			assert(data.ItemKey)
			assert(data.InventoryType)

			local function updateSelector()
				local count = #client:FindItemsWithKey(data.InventoryType, data.ItemKey)
				text = math.clamp(text, 1, count)
				clone.Selector.Counter.Amount.Text = text

				if text == 1 then
					clone.Selector.Counter.Minus.Image = "rbxassetid://18948526144"
					clone.Selector.Counter.Minus.HoverImage = "rbxassetid://18948573262"
				else
					clone.Selector.Counter.Minus.Image = "rbxassetid://18948593939"
					clone.Selector.Counter.Minus.HoverImage = "rbxassetid://18948596162"
				end

				if text == count then
					clone.Selector.Counter.Add.Image = "rbxassetid://18948588224"
					clone.Selector.Counter.Add.HoverImage = "rbxassetid://18948582588"
				else
					clone.Selector.Counter.Add.Image = "rbxassetid://18948517903"
					clone.Selector.Counter.Add.HoverImage = "rbxassetid://18948575339"
				end
			end

			maid:Add(client:OnInventoryChange(data.InventoryType, updateSelector))
			task.spawn(updateSelector)
			maid:Add(clone.Selector.Counter.Add.Activated:Connect(function()
				text += 1
				updateSelector()
			end))
			maid:Add(clone.Selector.Counter.Minus.Activated:Connect(function()
				text -= 1
				updateSelector()
			end))
		end

		p._currentConfirmationPrompt = clone

		local function onClick(p2)
			maid:Destroy()
			task.spawn(callback, p2)

			if p._currentConfirmationPrompt then
				p._currentConfirmationPrompt:Destroy()
				p._currentConfirmationPrompt = nil
			end

			deleteConfirmation.Enabled = false

			if data.ItemKey and data.InventoryType and p2 then
				local v9, v10 = v:Invoke("RequestDelete", {
					[data.InventoryType] = v4.List.take(client:FindItemsWithKey(data.InventoryType, data.ItemKey), text)
				})

				if not v9 and v10 then
					v3:SendNotification(v10)
				end
			end
		end

		clone[data.PromptType].Buttons.No.Activated:Connect(function()
			onClick(false)
		end)
		clone[data.PromptType].Buttons.Yes.Activated:Connect(function()
			onClick(true)
		end)
		clone.Close.Activated:Connect(function()
			onClick(false)
		end)
		clone.Parent = deleteConfirmation
		deleteConfirmation.Enabled = true
	end
}