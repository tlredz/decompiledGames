local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Common.Utils.Utilities.Icons)
local v4 = require3(ReplicatedStorage2.Shared.Statable)
local v5 = require3(script.Parent.Parent)
require3(ReplicatedStorage2.Shared.ItemInfo)
local holder = localPlayer.PlayerGui:WaitForChild("NewShop").Holder
local favoritedTemplate = script.FavoritedTemplate
local swords = holder.Pages.Swords
local info = swords.Info
local _ = swords.List.Template.Normal
local explosions = holder.Pages.Explosions
local info2 = explosions.Info
local explosionTemplate = script.ExplosionTemplate
local v6 = {
	Sword = v4.State(),
	Explosion = v4.State()
}
local state = v4.State("Swords")
local v7 = {
	Normal = 0,
	Rare = 1,
	Legendary = 2,
	Limited = 3,
	LimitedU = 4,
	Unique = 5
}
local v8 = {
	[true] = {
		Image = "rbxassetid://15697987058",
		HoverImage = "rbxassetid://15697983062"
	},
	[false] = {
		Image = "rbxassetid://15697981750",
		HoverImage = "rbxassetid://15697987058"
	}
}
local v9 = {
	[true] = {
		Image = "rbxassetid://14782680596",
		HoverImage = "rbxassetid://14782685409"
	},
	[false] = {
		Image = "rbxassetid://14782684812",
		HoverImage = "rbxassetid://14782685409"
	}
}

local function applyColor(instance, color)
	if typeof(color) == "Color3" then
		instance.TextColor3 = color
		return
	end

	instance.TextColor3 = Color3.new(1, 1, 1);
	(instance:FindFirstChildWhichIsA("UIGradient") or Instance.new("UIGradient", instance)).Color = color
end

local Default = {}

function Default:Open()
	v:Open("NewShop")
end

function Default:Close()
	v:Close("NewShop")
end

function Default.SwitchPage(_) end

function Default:RenderSlot(data)
	local itemInfo = data.ItemInfo
	local maid = v2.new()
	local clone = nil

	if itemInfo.ItemType == "Sword" then
		local itemInfo2 = data.ItemInfo
		clone = maid:Add(swords.List.Template:FindFirstChild(itemInfo2.Rarity):Clone())
		local v10 = maid:Add(favoritedTemplate:Clone())
		v10.Name = "Favorited"
		v10.Visible = false
		v10.Parent = clone
		clone.NameOfWeapon.Text = itemInfo2.DisplayName
		maid:Add(v4.Computed(function(callback)
			clone.Parent = callback(data.Owns) and swords.List.Owned or swords.List.Unowned
			return nil
		end))
		maid:Add(clone.Activated:Connect(function()
			v6.Sword:Set(data)
		end))
		maid:Add(v4.Computed(function(callback)
			v10.Visible = callback(data.IsFavorited)
			return nil
		end))
		maid:Add(v4.Computed(function(callback)
			clone.LayoutOrder = callback(data.IsFavorited) and -1000 or itemInfo2.Name == "Base Sword" and -1 or v7[itemInfo2.Rarity]
			return nil
		end))
		maid:Add(v4.setPropertyComputed(clone, "Visible", function(callback)
			return not itemInfo2.Hidden or callback(data.Owns) or itemInfo2.AlwaysVisible
		end))
		v3:SetSwordIconAsViewportByName(clone.ViewportFrame, itemInfo2.Name)
	elseif itemInfo.ItemType == "Explosion" then
		local itemInfo2 = data.ItemInfo
		clone = explosionTemplate:Clone()
		clone.Visible = true
		clone.LayoutOrder = itemInfo2.Order
		clone.NameOfExplosion.Text = itemInfo2.Title.Text
		applyColor(clone.NameOfExplosion, itemInfo2.Title.Color)
		clone.NameOfExplosion.TextStrokeColor3 = itemInfo2.Title.StrokeColor
		applyColor(clone.SubText, itemInfo2.SubText.Color)
		clone.SubText.Text = itemInfo2.SubText.Text
		clone.SubText.TextStrokeColor3 = itemInfo2.SubText.StrokeColor
		maid:Add(v4.Computed(function(callback)
			clone.Parent = callback(data.Owns) and explosions.List.Owned or explosions.List.Unowned
			return nil
		end))
		maid:Add(clone.Activated:Connect(function()
			v6.Explosion:Set(data)
		end))
		clone.ImageLabel.Image = itemInfo.Icon
	end

	return clone, function()
		maid:Destroy()
	end
end

function Default:Start()
	for _, frame in holder.Pages:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local name = frame.Name
		local tab = holder.Tabs[name]
		local v12 = frame
		v4.Computed(function(callback)
			local visible = callback(state) == name

			for k, v14 in v9[visible] do
				tab[k] = v14
			end

			tab.Active = not visible
			v12.Visible = visible
			return nil
		end)
		local name2 = name
		tab.Activated:Connect(function()
			state:Set(name2)
		end)
	end

	local maid = v2.new()
	local itemsList = v5:GetItemsList(function(p)
		return p.ItemType == "Sword"
	end)
	local v10 = {}

	for _, v11 in itemsList do
		v10[v11] = self:RenderSlot(v5:GetItemData(v11))
	end

	info.Equip.Activated:Connect(function()
		local v11 = v6.Sword:Get()

		if v11 then
			v5:SetEquipped(v11.ItemInfo)
		end
	end)
	info.View.Favorite.Activated:Connect(function()
		local v11 = v6.Sword:Get()

		if v11 then
			v5:ToggleFavorited(v11.ItemInfo)
		end
	end)
	info.Upgrade.Activated:Connect(function()
		local v11 = v6.Sword:Get()

		if v11 then
			local upgrade = v11.ItemInfo.Upgrade

			if upgrade and upgrade.TargetPage then
				v:Open(upgrade.TargetPage)
			end
		end
	end)
	v4.Computed(function(callback)
		maid:Destroy()
		local v11 = callback(v6.Sword)

		if v11 then
			local itemInfo = v11.ItemInfo
			info.Title.Text = itemInfo.DisplayName
			info.Description.Text = itemInfo.Description
			local v12 = v10[itemInfo]
			local viewportFrame = v12.ViewportFrame.Visible and v12.ViewportFrame or v12.IconLabel
			local v13 = maid:Add(viewportFrame:Clone())
			v13.Size = UDim2.new(1, 0, 1, 0)
			v13.Parent = info.View
		end

		info.Visible = v11 and true or false
		return v11
	end)
	v4.Computed(function(callback)
		local v11 = callback(v6.Sword)

		if v11 then
			local itemInfo = v11.ItemInfo

			for k, v12 in v8[callback(v11.IsFavorited)] do
				info.View.Favorite[k] = v12
			end

			info.Equip.PriceTag.TextLabel.Text = callback(v11.IsEquipped) and "Equipped" or "Equip"
			local upgrade = itemInfo.Upgrade

			if upgrade and callback(v11.Owns) then
				local v12 = callback(v11.UpgradeLevel)
				local upgrade2 = info.Upgrade
				upgrade2.Active = v12 < upgrade.Upgrades and upgrade.TargetPage
				info.Upgrade.Label.Text = upgrade.Upgrades <= v12 and "MAX" or "Upgrade"
			end
		end

		info.Equip.Visible = v11 and callback(v11.Owns)
		info.Upgrade.Visible = v11 and v11.ItemInfo.Upgrade and callback(v11.Owns)
		return v11
	end)
	local v11 = v2.new()
	local itemsList2 = v5:GetItemsList(function(p)
		return p.ItemType == "Explosion"
	end)
	local v12 = {}

	for _, v13 in itemsList2 do
		v12[v13] = self:RenderSlot(v5:GetItemData(v13))
	end

	info2.Equip.Activated:Connect(function()
		local v13 = v6.Explosion:Get()

		if v13 then
			v5:SetEquipped(v13.ItemInfo)
		end
	end)
	v4.Computed(function(callback)
		v11:Destroy()
		local v13 = callback(v6.Explosion)

		if v13 then
			local itemInfo = v13.ItemInfo
			info2.Title.Text = itemInfo.Title.Text
			info2.Description.Text = itemInfo.SubText.Text
			info2.View.Image = itemInfo.Icon
		end

		info2.Visible = v13 and true or false
		return v13
	end)
	v4.Computed(function(callback)
		local v13 = callback(v6.Explosion)

		if v13 then
			local _ = v13.ItemInfo
			info2.Equip.PriceTag.TextLabel.Text = callback(v13.IsEquipped) and "Equipped" or "Equip"
		end

		info2.Equip.Visible = v13 and callback(v13.Owns)
		info2.Upgrade.Visible = false
		return v13
	end)
end

return Default