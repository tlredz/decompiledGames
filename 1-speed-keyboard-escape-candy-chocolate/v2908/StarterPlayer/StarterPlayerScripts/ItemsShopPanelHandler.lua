local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

if localPlayer.UserId ~= 3845375404 then
	return
end

local itemsShopPanelAction = ReplicatedStorage:WaitForChild("ItemsShopPanelAction")
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = {
	{
		Action = "restock",
		Scope = "server"
	},
	{
		Action = "restock",
		Scope = "global"
	},
	{
		Action = "restockmythic",
		Scope = "server"
	},
	{
		Action = "restockmythic",
		Scope = "global"
	},
	{
		Action = "giveitem"
	},
	{
		Action = "removeitem"
	},
	{
		Action = "listitems"
	},
	{
		Action = "clearitems"
	}
}

local function wirePanel(itemsShopPanel)
	local background = itemsShopPanel:WaitForChild("Background")
	local panel = background:WaitForChild("Panel")
	local playerInput = panel:WaitForChild("InputFrame"):WaitForChild("PlayerInput")
	local itemInput = panel:WaitForChild("ItemFrame"):WaitForChild("ItemInput")
	local qtyInput = panel:WaitForChild("QtyFrame"):WaitForChild("QtyInput")
	local closeBtn = panel:WaitForChild("CloseBtn")
	local buttonScroll = panel:WaitForChild("ButtonScroll")
	closeBtn.MouseButton1Click:Connect(function()
		itemsShopPanel:Destroy()
	end)
	background.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local absolutePosition = panel.AbsolutePosition
			local absoluteSize = panel.AbsoluteSize
			local position = input.Position

			if position.X < absolutePosition.X or position.X > absolutePosition.X + absoluteSize.X or position.Y < absolutePosition.Y or position.Y > absolutePosition.Y + absoluteSize.Y then
				itemsShopPanel:Destroy()
			end
		end
	end)

	for _, button in ipairs(buttonScroll:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v2 = button
		button.MouseButton1Click:Connect(function()
			local v3 = tonumber(string.match(v2.Name, "%d+"))

			if not v3 then
				return
			end

			local v4 = v[v3]

			if not v4 then
				return
			end

			itemsShopPanelAction:FireServer({
				Action = v4.Action,
				Scope = v4.Scope,
				PlayerName = playerInput.Text,
				ItemKey = itemInput.Text,
				Quantity = qtyInput.Text
			})
		end)
	end
end

playerGui.ChildAdded:Connect(function(screenGui)
	if screenGui.Name == "ItemsShopPanel" and screenGui:IsA("ScreenGui") then
		task.defer(wirePanel, screenGui)
	end
end)
local itemsShopPanel = playerGui:FindFirstChild("ItemsShopPanel")

if itemsShopPanel then
	wirePanel(itemsShopPanel)
end