local GeneratedSource = require(script.GeneratedSource)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local v = {
	__index = function(p, p2)
		local v2 = rawget(p, p2)

		if v2 ~= nil then
			return v2
		end

		local v3 = nil

		for k, v5 in GeneratedSource do
			if v5 ~= p then
				continue
			end

			v3 = k
			break
		end

		if v3 then
			return ItemId.getId(p2, v3):unwrap()
		end

		error((`attempt to index non-existent key {p2} in IdMap`))
	end,
	__newindex = function()
		error("IdMap is read-only")
	end
}
local makeStrictStatic

makeStrictStatic = function(list)
	for _, v2 in pairs(list) do
		if type(v2) == "table" then
			makeStrictStatic(v2)
		end
	end

	setmetatable(list, v)
	table.freeze(list)
end

makeStrictStatic(GeneratedSource)
return GeneratedSource