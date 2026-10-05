local Modification = require(game.ReplicatedStorage.Util.Modification)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local v = {}
local v2 = {
	EclipseChromaticDragon = {
		RectX = 0,
		East = "ESTDSKINeclipse",
		West = "WSTDSKINeclipse"
	},
	VioletNightChromaticDragon = {
		RectX = 300,
		East = "ESTDSKINvioletnight",
		West = "WSTDSKINvioletnight"
	},
	BloodmoonChromaticDragon = {
		RectX = 450,
		East = "ESTDSKINbloodmoon",
		West = "WSTDSKINbloodmoon"
	},
	EmberChromaticDragon = {
		RectX = 150,
		East = "ESTDSKINember",
		West = "WSTDSKINember"
	},
	PhoenixSkyChromaticDragon = {
		RectX = 600,
		East = "ESTDSKINphoenixsky",
		West = "WSTDSKINphoenixsky"
	}
}
local v3 = nil

for _, v4 in ItemConfig.map(Modification.getAllModifications(IdMap.Moveset["Eagle-Eagle"], "Skin")) do
	if v4.Quality.Rarity == "Premium" then
		v[v4.Index.StorageKey] = true
	end
end

local v4 = {
	Unredeemed = 0,
	RedeemWest = 150,
	RedeemEast = 300
}

local function dragon(p: string)
	local v5 = nil
	local v6

	if p then
		v6 = v2[p]

		if v6 then
			v5 = "Unredeemed"
		else
			for _, v8 in pairs(v2) do
				if v8 and v8.East == p then
					v6 = v8
					v5 = "RedeemEast"
					break
				elseif v8 and v8.West == p then
					v6 = v8
					v5 = "RedeemWest"
					break
				end
			end
		end
	end

	if not (v6 and v5) then
		return nil
	end

	local vector = Vector2.new(v6.RectX, v4[v5])
	local imageRectSize = Vector2.one * 150

	local function newImage(image: string)
		return {
			Loaded = true,
			Icon = {
				Image = image,
				ImageRectOffset = vector,
				ImageRectSize = imageRectSize,
				ImageTransparency = 0,
				ImageColor3 = Color3.new(1, 1, 1)
			},
			Hidden = {
				Image = image,
				ImageRectOffset = vector,
				ImageRectSize = imageRectSize,
				ImageTransparency = 0,
				ImageColor3 = Color3.new(1, 1, 1)
			}
		}
	end

	return newImage("rbxassetid://116815022926368"), (newImage("rbxassetid://79361588247465"))
end

local v5 = {
	Dragon = dragon,
	Eagle = function(p: string)
		local formatted = `ChromaticFruit{p}`
		return v3.getAssetSprite(p), v3.getAssetSprite(formatted)
	end
}
local v6 = {}

for k in pairs(v) do
	v6[k] = "Eagle"
end

for k, v7 in pairs(v2) do
	v6[k] = "Dragon"
	v6[v7.West] = "Dragon"
	v6[v7.East] = "Dragon"
end

return {
	Try = function(p: string)
		v3 = v3 or require(game.ReplicatedStorage.Modules.Asset.ImageUtil)

		if v6[p] then
			return v5[v6[p]](p)
		end

		return nil
	end
}