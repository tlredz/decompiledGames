local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local fx = require(ReplicatedStorage.shared.modules.fx)
local WitcherPotions = require(ReplicatedStorage.shared.modules.WitcherPotions)
local potions = WitcherPotions.Potions
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local Net = require(packages.Net)
local v = Trove.new()
local potions2 = game.Players.LocalPlayer.PlayerGui.Potions
local main = potions2.Main
local scrollingFrame = main.List.ScrollingFrame
local sample = scrollingFrame.Sample
local tiers = main.Details.Tiers
local sample2 = tiers.Sample
local ingredients = main.Details.Ingredients
local sample3 = ingredients.Sample
local item = main.Details.Item
local potion = main.Details.Potion
local description = main.Details.Description
local select = main.Details.Select
local v2 = ""
local v3 = Replion.Client:WaitReplion("PotionsList")

local function formatTime(p)
	local v4 = math.floor(p / 3600)
	local v5 = math.floor(p % 3600 / 60)
	local v6 = p % 60
	local v7 = ""

	if v4 > 0 then
		v7 ..= v4 .. "h"
	end

	if v5 > 0 then
		v7 ..= v5 .. "m"
	end

	if v6 > 0 or v7 == "" then
		return v7 .. v6 .. "s"
	end

	return v7
end

local WitcherPotionsController = {
	LoadDetails = function()
		v:Clean()
		local child = scrollingFrame:FindFirstChild(v2)

		if child then
			for _, button in scrollingFrame:GetChildren() do
				if button:IsA("ImageButton") and button.Name ~= "Sample" and button ~= child then
					button.UIStroke.Color = Color3.fromRGB(0, 0, 0)
				end
			end

			child.UIStroke.Color = Color3.fromRGB(255, 255, 255)
		end

		item.Image = potions[v2].Icon

		if potions[v2].IconColor then
			item.ImageColor3 = potions[v2].IconColor
		else
			item.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end

		potion.Text = potions[v2].DisplayName
		description.Text = potions[v2].Description
		local color = v3:Get((`Potions.{v2}`)) and Color3.fromRGB(162, 234, 166) or Color3.fromRGB(197, 197, 197)
		select.Label.Text = v3:Get((`Potions.{v2}`)) and "Select" or "Unavailable"
		select.Label.TextColor3 = color
		select.UIStroke.Color = color
		select.corner.ImageColor3 = color

		for k, v4 in potions[v2].TiersChance do
			local clone = sample2:Clone()
			clone.Name = k
			clone.LayoutOrder = k
			local description2 = clone.Description
			local v6 = potions[v2].TiersCraftDelay[k]
			local v7 = math.floor(v6 / 3600)
			local v8 = math.floor(v6 % 3600 / 60)
			local v9 = v6 % 60
			local v10 = ""

			if v7 > 0 then
				v10 ..= v7 .. "h"
			end

			if v8 > 0 then
				v10 ..= v8 .. "m"
			end

			if v9 > 0 or v10 == "" then
				v10 ..= v9 .. "s"
			end

			description2.Text = `- Craft Delay: {v10}`
			clone.Header.Text = `Tier {k} [{v4}% Chance]`
			clone.Visible = true
			clone.Parent = tiers
			v:Add(clone)
		end

		for _, possiblesIngredient in potions[v2].PossiblesIngredients do
			local clone = sample3:Clone()
			clone.Name = possiblesIngredient
			clone.Amount.Text = "x1"
			clone.Icon.Image = fish[possiblesIngredient] and fish[possiblesIngredient].Icon or ""
			clone.Visible = true
			clone.Parent = ingredients
			v:Add(clone)
		end
	end
}

function WitcherPotionsController.SelectPotion(p: string)
	v2 = p
	WitcherPotionsController.LoadDetails()
end

function WitcherPotionsController.Load()
	local layoutOrder = 1
	local v5 = nil

	for k, potion2 in potions do
		local clone = sample:Clone()
		clone.LayoutOrder = layoutOrder
		clone.Name = k
		clone.Label.Text = potion2.DisplayName
		clone.Label.TextColor3 = potion2.Color
		clone.Icon.Image = potion2.Icon

		if potion2.IconColor then
			clone.Icon.ImageColor3 = potion2.IconColor
		end

		clone.Label.Flare.ImageColor3 = potion2.Color
		clone.Parent = scrollingFrame
		clone.Visible = true
		local v6 = k
		clone.Activated:Connect(function()
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click2, game.Players.LocalPlayer.PlayerGui, false)
			WitcherPotionsController.SelectPotion(v6)
		end)

		if layoutOrder == 1 then
			v5 = k
		end

		layoutOrder += 1
	end

	WitcherPotionsController.SelectPotion(v5)
end

function WitcherPotionsController.init(_)
	main.Close.MouseButton1Click:Connect(function()
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click2, game.Players.LocalPlayer.PlayerGui, false)
		potions2.Enabled = not potions2.Enabled
	end)
	select.MouseButton1Click:Connect(function()
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click2, game.Players.LocalPlayer.PlayerGui, false)

		if v3:Get((`Potions.{v2}`)) then
			Net:RemoteEvent("WitcherPotion/SelectRecipe"):FireServer(v2)
			potions2.Enabled = false
		end
	end)

	if not v3:Get("IsLoaded") then
		repeat
			task.wait(2)
		until v3:Get("IsLoaded")
	end

	v3:OnChange("Potions", function(_, _)
		WitcherPotionsController.LoadDetails()
	end)
	WitcherPotionsController.Load()
end

return WitcherPotionsController