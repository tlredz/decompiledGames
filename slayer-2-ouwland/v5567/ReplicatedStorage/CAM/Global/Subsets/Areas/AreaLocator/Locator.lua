local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Locator = {
	Areas = {},
	Biomes = {}
}

function Locator.DefaultAreaName(vector: Vector3?)
	if gameSettings.IsMinigame then
		return workspace:GetAttribute("Minigame") or "Minigame"
	end

	if vector ~= nil then
		local biome = Locator.FindBiome(vector)

		if biome ~= nil then
			return biome
		end
	end

	return "Wilderness"
end

function Locator.FindBiome(vector: Vector3)
	local _, v = Locator.Find(Vector2.new(vector.X, vector.Z), Locator.Biomes, vector.Y)
	return v
end

function Locator.Find(point: Vector2, items, p: number)
	if point == nil or items == nil then
		return
	end

	for k, item in items do
		local silent = item.Silent
		local independentMarkers = item.IndependentMarkers
		local cave = item.Cave
		local village = item.Village
		local noPvpSwitch = item.NoPvpSwitch
		local v = k
		local v2 = false

		for _, v4 in item.Grid do
			local v5 = false
			local v6 = point - v4.Center

			if v4.Type == Menum.AreaType.Rectangle then
				if math.abs(v6.X) < v4.Radius.X and math.abs(v6.Y) < v4.Radius.Y then
					v2 = true
					v5 = true
				end
			elseif (typeof(v4.Radius) == "number" and v4.Radius or (v4.Radius.X + v4.Radius.Y) / 2) >= v6.Magnitude then
				v2 = true
				v5 = true
			end

			if v2 == true and v4.YLimits and not (v4.YLimits.X <= p and p <= v4.YLimits.Y) then
				v2 = false
			end

			if v2 == true and v4.YRange and not (v4.YRange[1] <= p and p <= v4.YRange[2]) then
				v2 = false
			end

			if v2 == true and v4.IsParent == true then
				local v7, _, v8, v9, v10, v11, v12 = Locator.Find(point, v4.ChildAreas, p)

				if v7 then
					silent = v8 and true or silent
					independentMarkers = v9 and true or independentMarkers
					noPvpSwitch = v12 and true or noPvpSwitch

					if v10 or v11 then
						village = v11
						cave = v10
					end

					v = v7
				end
			end

			if v5 == true then
				break
			end
		end

		if v2 == true then
			return v, k, silent, independentMarkers, cave, village, noPvpSwitch
		end
	end
end

function Locator.Locate(vector: Vector3)
	local v, v2 = Locator.Find(Vector2.new(vector.X, vector.Z), Locator.Areas, vector.Y)

	if v ~= nil and v2 ~= nil then
		return v2, v
	end

	local defaultAreaName = Locator.DefaultAreaName(vector)
	return defaultAreaName, defaultAreaName
end

return Locator