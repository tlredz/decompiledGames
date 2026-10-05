local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local TweenService = game:GetService("TweenService")
local ItemModule = require(script.Parent.ItemModule)
local mysteryBox = Sync.MysteryBox
local weapons = Sync.Weapons
local pets = Sync.Pets
local _ = {
	Min = 20,
	Max = 25
}

local function GetRarityFromRoll(rarityChances)
	local total = 0

	for _, v in rarityChances do
		total += v.Chance
	end

	assert(total == 100)
	assert(rarityChances[1].Rarity == "Common")
	assert(rarityChances[2].Rarity == "Uncommon")
	assert(rarityChances[3].Rarity == "Rare")
	assert(rarityChances[4].Rarity == "Legendary")
	assert(#rarityChances == 4)
	local number = Random.new():NextNumber(1, 100)
	local total2 = 0

	for _, v in rarityChances do
		total2 += v.Chance

		if number <= total2 then
			return v.Rarity
		end
	end
end

local BoxModule = {
	OpenBox = function(p, p2)
		local random = Random.new()
		local clone = script:WaitForChild("Unboxing2"):Clone()
		local offsetContainer = clone.Container.Main.Container.Background.ItemContainer.OffsetContainer
		local mainContainer = offsetContainer.MainContainer
		local v = mysteryBox[p]
		local integer = random:NextInteger(20, 25)
		local v2 = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Legendary = {}
		}

		for _, content in pairs(v.Contents) do
			table.insert(v2[weapons[content].Rarity], content)
		end

		mainContainer:ClearAllChildren()
		local clone2 = script.UIGridLayout:Clone()
		clone2.Parent = mainContainer
		local offset = clone2.CellSize.X.Offset
		offsetContainer.Size = UDim2.new(0, clone2.CellSize.X.Offset * (integer + 5), 1, 0)
		offsetContainer.Position = UDim2.new(0.5, offset / 2, 0, 0)

		local function GetRandomItemFromBox()
			local v3, godlyCover

			if random:NextInteger(1, 500) == 500 then
				v3 = "Godly"

				if v.GodlyCover then
					godlyCover = v.GodlyCover
				elseif v.Godly then
					godlyCover = v.Godly
				end

				if godlyCover and random:NextInteger(1, 50) == 50 then
					local v4 = godlyCover .. "Chroma"

					if Sync.Weapons[v4] then
						godlyCover = v4
					end
				end
			end

			if not godlyCover then
				v3 = GetRarityFromRoll(v.RarityChances)
				godlyCover = v2[v3][random:NextInteger(1, #v2[v3])]
			end

			return godlyCover, weapons[godlyCover], v3
		end

		for i = 1, integer + 5 do
			local v3

			if i == integer then
				if Sync.Weapons[p2].Rarity == "Godly" and v.GodlyCover then
					if Sync.Weapons[p2].Chroma == true and v.GodlyCover then
						local v4 = v.GodlyCover .. "Chroma"
						v3 = Sync.Weapons[v4]
						local _ = v3.Rarity
					else
						local _ = v.GodlyCover
						v3 = Sync.Weapons[v.GodlyCover]
						local _ = v3.Rarity
					end
				else
					v3 = Sync.Weapons[p2]
					local _ = v3.Rarity
				end
			else
				local v4, v5
				v4, v3, v5 = GetRandomItemFromBox()
			end

			local clone3 = script.NewItem:Clone()
			ItemModule.DisplayItem(clone3, v3)
			clone3.LayoutOrder = i
			clone3.Parent = mainContainer
		end

		local _, v3, _ = GetRandomItemFromBox()
		ItemModule.DisplayItem(offsetContainer["PreItem" .. 1], v3)
		local _, v4, _ = GetRandomItemFromBox()
		ItemModule.DisplayItem(offsetContainer["PreItem" .. 2], v4)
		clone.Parent = game.Players.LocalPlayer.PlayerGui
		local v5 = 3 + random:NextNumber()
		local v6 = -(offset * integer) + random:NextInteger(-(offset / 2 - 5), offset / 2 - 5) + offset - offset / 2
		TweenService:Create(offsetContainer, TweenInfo.new(v5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, v6, 0, 0)
		}):Play()
		task.wait(v5 + 1)
		clone:Destroy()
	end
}
local TweenService2 = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

function BoxModule.HatchEgg(_, p)
	local clone = script.Hatching:Clone()
	clone.Parent = game.Players.LocalPlayer.PlayerGui
	local pet = pets[p]
	clone.Cracked.PetIcon.Image = ItemModule.GetImage(pet.Image)
	wait(1)
	local egg = clone.Uncracked.Egg
	local v = {
		TweenService2:Create(egg, tweenInfo, {
			Rotation = 10
		}),
		TweenService2:Create(egg, tweenInfo, {
			Rotation = -10
		}),
		TweenService2:Create(egg, tweenInfo, {
			Rotation = 10
		}),
		TweenService2:Create(egg, tweenInfo, {
			Rotation = -10
		}),
		TweenService2:Create(egg, tweenInfo, {
			Rotation = 0
		}),
		TweenService2:Create(egg, tweenInfo, {
			Rotation = 10
		}),
		TweenService2:Create(egg, tweenInfo, {
			Rotation = -10
		}),
		TweenService2:Create(egg, tweenInfo, {
			Rotation = 10
		}),
		TweenService2:Create(egg, tweenInfo, {
			Rotation = -10
		}),
		TweenService2:Create(egg, tweenInfo, {
			Rotation = 0
		})
	}

	for _, v2 in pairs(v) do
		v2:Play()
		wait(0.125)
	end

	wait(0.5)
	clone.Uncracked.Visible = false
	clone.Cracked.Visible = true
	wait(1)
	clone:Destroy()
end

local images = {}

for _, image in script:GetDescendants() do
	if image:IsA("ImageLabel") then
		table.insert(images, image)
	end
end

task.spawn(function()
	local ContentProvider = game:GetService("ContentProvider")
	ContentProvider:PreloadAsync(images)
end)
return BoxModule