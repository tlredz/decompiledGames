local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local parentModule = require(script.Parent)

function noPhysicals(p)
	for _, v in ItemConfig.map(p) do
		assert(
			v.Index.IdType ~= "PhysicalMoveset",
			(`you can't use physical movesets in modification / adornee data: {v.Index.DebugLabel}`)
		)
	end
end

function newTestData(label: string, p2, p3, items, items2)
	noPhysicals(p2)
	noPhysicals(p3)
	noPhysicals(items)
	noPhysicals(items2)
	local empty = parentModule.Data.Modification.empty()

	for _, item in items do
		empty = parentModule.Data.Modification.setUnlock(item, empty, true)
	end

	for _, item in items2 do
		empty = parentModule.Data.Modification.setPreferred(item, empty, true)
	end

	return {
		Label = label,
		Adornee = parentModule.Data.Adornee.new(p2, p3),
		Modification = empty
	}
end

function newEdible(physicalMoveset: number, p2, shouldBeEdible: boolean)
	return {
		Method = "getIfCanEat",
		PhysicalMoveset = physicalMoveset,
		Data = p2,
		ShouldBeEdible = shouldBeEdible
	}
end

local v = {}
local empyreanKitsuneEmpyreanKitsune = IdMap.PhysicalMoveset["Empyrean (Kitsune)-Empyrean (Kitsune)"]
local memeMeme = IdMap.PhysicalMoveset["Meme-Meme"]
local yetiYeti = IdMap.PhysicalMoveset["Yeti-Yeti"]
local galaxyEmpyreanKitsune = IdMap.PhysicalMoveset["Galaxy Empyrean Kitsune"]
local fiendYetiFiendYeti = IdMap.PhysicalMoveset["Fiend (Yeti)-Fiend (Yeti)"]
local kitsuneKitsune = IdMap.PhysicalMoveset["Kitsune-Kitsune"]
local kitsuneKitsune2 = IdMap.Moveset["Kitsune-Kitsune"]
local memeMeme2 = IdMap.Moveset["Meme-Meme"]
local empyreanKitsuneEmpyreanKitsune2 = IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"]
local yetiYeti2 = IdMap.Moveset["Yeti-Yeti"]
local fiendYetiFiendYeti2 = IdMap.Moveset["Fiend (Yeti)-Fiend (Yeti)"]
local yETIMUTFiend = IdMap.Mutation.YETIMUTFiend
local yETIMUTYeti = IdMap.Mutation.YETIMUTYeti
local kYUKONSKINgalaxy = IdMap.Skin.KYUKONSKINgalaxy
table.insert(v, newEdible(memeMeme, newTestData("NoMemeMeme", {}, {}, {}, {}), true))
table.insert(v, newEdible(memeMeme, newTestData("equippedMeme_Meme", {}, { memeMeme2 }, {}, {}), true))
table.insert(v, newEdible(kitsuneKitsune, newTestData("hasKitsune_Kitsune", { kitsuneKitsune2 }, {}, {}, {}), true))
table.insert(v, newEdible(kitsuneKitsune, newTestData("youCanEatWithNothing", {}, {}, {}, {}), true))
table.insert(
	v,
	newEdible(empyreanKitsuneEmpyreanKitsune, newTestData("hasKitsune_Empy", { kitsuneKitsune2 }, {}, {}, {}), true)
)
table.insert(
	v,
	newEdible(galaxyEmpyreanKitsune, newTestData("hasKitsune_EmpyGalaxy", { kitsuneKitsune2 }, {}, {}, {}), true)
)
table.insert(
	v,
	newEdible(galaxyEmpyreanKitsune, newTestData("hasEmpy_EmpyGalaxy", { kitsuneKitsune2 }, {}, {}, {}), true)
)
table.insert(
	v,
	newEdible(
		galaxyEmpyreanKitsune,
		newTestData("hasEmpyMut_EmpyGalaxy", { kitsuneKitsune2, empyreanKitsuneEmpyreanKitsune2 }, {}, {}, {}),
		true
	)
)
table.insert(
	v,
	newEdible(
		galaxyEmpyreanKitsune,
		newTestData(
			"hasEmpyMutAndGalaxySkin_EmpyGalaxy",
			{ kitsuneKitsune2, empyreanKitsuneEmpyreanKitsune2 },
			{},
			{ kYUKONSKINgalaxy },
			{}
		),
		false
	)
)
table.insert(v, newEdible(yetiYeti, newTestData("hasNothing_Yeti", {}, {}, {}, {}), true))
table.insert(v, newEdible(fiendYetiFiendYeti, newTestData("hasYeti_Fiend", { yetiYeti2 }, {}, {}, {}), true))
table.insert(v, newEdible(fiendYetiFiendYeti, newTestData("hasFiendMut_Fiend", {}, {}, { yETIMUTFiend }, {}), false))
table.insert(v, newEdible(yetiYeti, newTestData("hasFiendMut_Yeti", {}, {}, {}, { yETIMUTFiend }), true))
table.insert(
	v,
	newEdible(
		yetiYeti,
		newTestData("blockBase_Yeti", {}, { fiendYetiFiendYeti2, yetiYeti2 }, { yETIMUTFiend }, {}),
		true
	)
)
table.insert(
	v,
	newEdible(
		yetiYeti,
		newTestData(
			"unlockedDefaultYetiSkin",
			{},
			{ fiendYetiFiendYeti2, yetiYeti2 },
			{ yETIMUTFiend, yETIMUTYeti },
			{}
		),
		true
	)
)
return SimpleTest.Test.new({ SimpleTest.Parameter.Choose.new("TestCase", v, function(p)
		local clone = table.clone(p)

		if clone.PhysicalMoveset then
			clone.PhysicalMoveset = ItemConfig.match(clone.PhysicalMoveset):unwrap().Index.DebugLabel
		end

		if clone.Data then
			clone.Data = {
				Modification = parentModule.Data.Modification.debug(p.Data.Modification),
				Adornee = parentModule.Data.Adornee.debug(p.Data.Adornee)
			}
			clone.Case = `{clone.Method}:{p.Data.Label}`
			clone.Method = nil
		end

		return clone
	end) }, function(data)
	if data.Method == "getIfCanEat" then
		return parentModule.getIfCanEat(data.PhysicalMoveset, data.Data.Modification, data.Data.Adornee, false) == data.ShouldBeEdible
	end

	error((`unknown case: {data.Method}`))
end, #v + 1)