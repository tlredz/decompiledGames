local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Controllers.UI.TopBarController)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v5 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v6 = require3(ReplicatedStorage2.Shared.GiftProductsId)
local localPlayer = Players.LocalPlayer
local v7 = nil
local playerGui = nil
local giftInventory = nil
local main = nil
local scrollingFrame = nil
local clone = nil
local giftInventory2 = nil
local v8 = {}
local v9 = 0
local GiftInventoryController = {}

function GiftInventoryController:_updateVisibility()
	local giftInventory3 = v7:Get("GiftInventory")
	local total = 0

	for _, v10 in giftInventory3 do
		local count = #v10

		if count > 0 then
			total += count
		end
	end

	local v10 = total > 0
	giftInventory2:setEnabled(v10)

	if not v10 then
		v3:Close("GiftInventory")
	end

	if v9 < total then
		giftInventory2:notify()
	end

	v9 = total
end

function GiftInventoryController:_updateGifts()
	local giftInventory3 = v7:Get("GiftInventory")

	for childName, v10 in giftInventory3 do
		local count = #v10
		local v11 = v8[childName]

		if not v11 then
			continue
		end

		local v12 = v6[v11]
		local clone2 = scrollingFrame:FindFirstChild(childName)

		if not clone2 then
			clone2 = clone:Clone()
			clone2.Name = childName
			clone2.Title.Text = v12.DisplayName or v12.name or v11
			local icon = v12.Icon

			if v12.type == "Sword" then
				local sword = v5:GetSword(v12.name)

				if sword then
					icon = sword.Icon
				end
			end

			clone2.Icon.Image = icon or "rbxassetid://15798994355"
			local v13 = v11
			clone2.Activated:Connect(function()
				v4:SetGift(v13)
			end)
			clone2.Parent = scrollingFrame
		end

		clone2.Amount.Text = `x{count}`
		clone2.Visible = count > 0
	end

	for _, guiObject in scrollingFrame:GetChildren() do
		if not guiObject:IsA("GuiObject") or giftInventory3[guiObject.Name] then
			continue
		end

		guiObject:Destroy()
	end
end

function GiftInventoryController:Start()
	for k, v10 in pairs(v6) do
		if v10.productId then
			v8[tostring(v10.productId)] = k
		end
	end

	playerGui = localPlayer:WaitForChild("PlayerGui")
	giftInventory = playerGui:WaitForChild("GiftInventory")
	main = giftInventory:WaitForChild("Main")
	scrollingFrame = main.ScrollingFrame
	main.Close.Activated:Connect(function()
		v3:Close("GiftInventory")
	end)
	clone = scrollingFrame:WaitForChild("Template"):Clone()

	for _, guiObject in scrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	giftInventory2 = v2:WaitForIcon("GiftInventory")
	giftInventory2.toggled:Connect(function(_, p)
		if p ~= "User" then
			return
		end

		if v3:IsOpen("GiftInventory") then
			v3:Close("GiftInventory")
		else
			v3:Open("GiftInventory")
		end
	end)
	v3:OnGuiClose("GiftInventory", function()
		giftInventory2:deselect()
	end)
	v3:OnGuiOpen("GiftInventory", function()
		giftInventory2:select()
		giftInventory2:clearNotices()
	end)
	v7 = v.Client:WaitReplion("Data")
	v7:OnChange("GiftInventory", function()
		self:_updateGifts()
		self:_updateVisibility()
	end)
	self:_updateGifts()
	self:_updateVisibility()
end

return GiftInventoryController