local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local FruitSkills = require(game.ReplicatedStorage.FruitSkills)
local FruitInfo = require(game.ReplicatedStorage.FruitInfo)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local RaritySprites = require(game.ReplicatedStorage.Modules.Create.AssetComponent.RaritySprites)
local Shop = require(game.ReplicatedStorage.Shop)
local Types = require(game.ReplicatedStorage.React.Components.FruitShop.Types)
require(game.ReplicatedStorage.FruitSpritesheets)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Data = {}

for _, v in ipairs(ItemConfig.Query.select({
	Moveset = {
		Type = "Fruit",
		Physical = {
			Operation = "NEQ",
			Value = nil
		},
		SkillRedirect = {
			Operation = "EQ",
			Value = nil
		}
	},
	Variant = {
		IsFoundation = true,
		VariantOf = {
			Operation = "EQ",
			Value = nil
		}
	}
})) do
	local nullable = ItemConfig.match("Permanent " .. v.Index.StorageKey, "Redeemable"):asNullable()

	if not (nullable and nullable.Economy and nullable.Economy.ProductId) then
		continue
	end

	local v2

	if v.Moveset == nil then
		v2 = false
	else
		v2 = v.Moveset.Physical ~= nil
	end

	assert(v2, "bad phys")
	local unwrapped = ItemConfig.match(v.Moveset.Physical):unwrap()
	local unwrapped2 = RarityUtil.matchRarity(unwrapped.Quality.Rarity):unwrap()
	local background = RaritySprites.Backgrounds[v.Quality.RarityValue]
	local v3 = {
		Name = v.Index.StorageKey,
		AssetId = nullable.Economy.ProductId,
		DisplayName = unwrapped.Display.Name or unwrapped.Index.StorageKey,
		Icon = unwrapped.Display.Sprite,
		Item = Shop.match(nullable.Index.ItemId):unwrap(),
		Rarity = {
			Name = unwrapped2.Name,
			Color = unwrapped2.Color,
			Value = unwrapped2.Value,
			IdleBackground = table.freeze({
				Image = "rbxassetid://120434692968914",
				ImageRectOffset = background.idle,
				ImageRectSize = RaritySprites.BACKGROUND_RECT_SIZE
			}),
			HoverBackground = table.freeze({
				Image = "rbxassetid://120434692968914",
				ImageRectOffset = background.hover,
				ImageRectSize = RaritySprites.BACKGROUND_RECT_SIZE
			})
		},
		PermanentOnly = false,
		ArtworkIcon = v.Display.Sprite,
		IsAnimatedBackground = v.Index.StorageKey == "Dragon-Dragon",
		Description = v.Display.Description,
		Price = unwrapped.Quality.MoneyPrice,
		PermanentRobuxPrice = nullable.Economy.RobuxPrice,
		HasMutations = #ItemConfig.Query.select({
			Variant = {
				VariantOf = v.Index.ItemId,
				Mutation = {
					Operation = "NEQ",
					Value = nil
				}
			}
		}) > 0,
		Skills = 0,
		Facts = 0
	}
	local fruitSkill = FruitSkills[v.Index.StorageKey]
	assert(typeof(fruitSkill) == "table", (`bad skillSets at "{v.Index.StorageKey}"`))
	local v4 = fruitSkill[1]
	assert(typeof(v4) == "table", (`bad skillSet[1] at "{v.Index.StorageKey}"`))
	local skills = {}

	for i, v6 in ipairs(v4) do
		local v7 = v6[1]
		assert(typeof(v7) == "string", (`bad keyCode[{i}] str at "{v.Index.StorageKey}"`))
		assert(v7:len() == 1, (`long keycode? {v.Index.StorageKey}`))
		local v8 = nil

		for _, v10 in ipairs(Enum.KeyCode:GetEnumItems()) do
			if v7:lower():sub(1, 1) ~= v10.Name:lower() then
				continue
			end

			v8 = v10
			break
		end

		assert(v8, (`keyCodeStr[{i}]="{v7}" couldn't be mapped to keyCode`))
		local starCount = v6[2]
		assert(typeof(starCount) == "number", (`bad skill[i] value="{starCount}"`))
		local displayName = v6[3]
		assert(typeof(displayName) == "string", (`bad skill{i} name="{displayName}"`))
		local v12 = {
			DisplayName = displayName,
			Key = v8,
			StarCount = starCount
		}
		table.freeze(v12)
		assert(Types.Types.FruitSkill(v12))
		skills[i] = v12
	end

	table.freeze(skills)
	v3.Skills = skills
	local v6 = FruitInfo.tryGet(v.Index.StorageKey)
	assert(v6, "bad fruitInfo")
	local facts = {}

	for _, element in pairs(v6.Elements) do
		local text = element.Text
		local images = element.Images
		local icon

		if images then
			icon = images["34x34"] or images["100x100"] or images["845x845"]
		end

		local v9 = {
			Text = text,
			Icon = icon
		}
		table.freeze(v9)
		table.insert(facts, v9)
	end

	v3.Facts = facts
	local frozen = table.freeze(v3)
	TableUtil.deepFreeze(frozen)
	assert(Types.Types.FruitData(frozen))
	Data[v.Index.StorageKey] = frozen
end

return Data