local RunService = game:GetService("RunService")
local PlaceRegistry = {
	ProdGroup = "Prod",
	Groups = {
		Prod = {
			{ 95082159892680, 122256965926456, 111678427706543 },
			{
				118941584817777,
				96482048415123,
				98382274944853,
				72332128343708
			},
			{ 93411036959889 },
			{ 75012837977315 }
		},
		CCWorlds = {
			{ 81303879367868 },
			{ 99530175154248 },
			{ 96894512865539 },
			{ 74908498682986 }
		},
		Test = {
			{ 82659363268176 },
			{ 118283647543447 },
			{ 118595156473600 },
			{ 128943850783743 }
		},
		Sano = {
			{ 128290329179894 },
			{ 114452296004057 },
			{},
			{ 136394691264600 }
		},
		FoeCakes = {
			{ 113315188437529 },
			{ 126760973685345 },
			{ 89019996789449 },
			{ 88205516504728 }
		},
		Lyzrinn = {
			{ 75225381217080 },
			{ 130568239357796 },
			{ 92516083343635 },
			{ 116564837871437 }
		},
		Fab = {
			{ 133270854332262 },
			{ 84319349014360 },
			{ 72459852444489 },
			{ 100813685360193 }
		},
		Chad = {
			{},
			{},
			{},
			{ 87803031261132 }
		}
	},
	GroupOrder = {
		"Prod",
		"Test",
		"CCWorlds",
		"Sano",
		"FoeCakes",
		"Lyzrinn",
		"Fab",
		"Chad"
	},
	SpecialPlaces = {
		TradingHub = {
			Prod = 101521033763856,
			Test = 100888607910537,
			Lyzrinn = 73726211869345,
			FoeCakes = 72068396604302
		}
	}
}
local v = {}

for _, groupName in ipairs(PlaceRegistry.GroupOrder) do
	for i, list in ipairs(PlaceRegistry.Groups[groupName]) do
		for _, v3 in ipairs(list) do
			if v[v3] == nil then
				v[v3] = {
					groupName = groupName,
					worldIndex = i
				}
			end
		end
	end
end

for k, specialPlace in pairs(PlaceRegistry.SpecialPlaces) do
	for k2, v2 in pairs(specialPlace) do
		if v[v2] == nil then
			v[v2] = {
				groupName = k2,
				specialKey = k
			}
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolvePlaceId(p: number?)
	return p or game.PlaceId
end

function PlaceRegistry.locate(p: number?)
	local v2 = v[p or game.PlaceId] or {}
	return v2.groupName, v2.worldIndex, v2.specialKey
end

function PlaceRegistry.getSpecialPlaceKey(p: number?)
	local _, _, v2 = PlaceRegistry.locate(p)
	return v2
end

function PlaceRegistry.isSpecialPlaceKey(value)
	return type(value) == "string" and PlaceRegistry.SpecialPlaces[value] ~= nil
end

function PlaceRegistry.getSpecialPlaceKeys()
	local result = {}

	for k in pairs(PlaceRegistry.SpecialPlaces) do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

function PlaceRegistry.getSpecialPlaceId(p: string, p2: string)
	return PlaceRegistry.SpecialPlaces[p][p2]
end

function PlaceRegistry.getPlaceIdInCurrentGroup(p)
	if not PlaceRegistry.isSpecialPlaceKey(p) then
		return PlaceRegistry.getWorlds()[p]
	end

	local groupName = PlaceRegistry.getGroupName()

	if groupName then
		return (PlaceRegistry.getSpecialPlaceId(p, groupName))
	end

	return nil
end

function PlaceRegistry.getWorldIndex(p: number?)
	local _, v2 = PlaceRegistry.locate(p)
	return v2 or 1
end

function PlaceRegistry.getWorldStatus(p: number?)
	local _, v2 = PlaceRegistry.locate(p)
	return v2 or -1
end

function PlaceRegistry.getGroupName(p: number?)
	return (PlaceRegistry.locate(p))
end

function PlaceRegistry.getPrimaryPlaceId(p: string, p2: number)
	local group = PlaceRegistry.Groups[p]
	local v2 = group and group[p2]
	return v2 and v2[1] or nil
end

function PlaceRegistry.getGroupPrimaries(p: string)
	local result = {}
	local group = PlaceRegistry.Groups[p]

	if group then
		for i, v2 in ipairs(group) do
			result[i] = v2[1]
		end
	end

	return result
end

function PlaceRegistry.getWorlds(p: number?)
	local placeId = resolvePlaceId(p) -- equivalent call inferred; original call site unknown
	local groupName = PlaceRegistry.getGroupName(placeId)

	if groupName then
		return PlaceRegistry.getGroupPrimaries(groupName)
	end

	if RunService:IsStudio() or placeId == 108879839306227 then
		return { placeId, placeId }
	end

	error("[PlaceRegistry] Aucun groupe de monde trouvé pour la place " .. tostring(placeId))
end

function PlaceRegistry.isTestPlace(p: number?)
	local groupName = PlaceRegistry.getGroupName(p)
	return groupName ~= nil and groupName ~= PlaceRegistry.ProdGroup
end

function PlaceRegistry.getWorldCount()
	return #PlaceRegistry.Groups[PlaceRegistry.ProdGroup]
end

return PlaceRegistry