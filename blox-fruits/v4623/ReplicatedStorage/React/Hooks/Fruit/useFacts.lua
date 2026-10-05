local React = require(game.ReplicatedStorage.Packages.React)
local Type = require(game.ReplicatedStorage.Packages.Type)
local FruitInfo = require(game.ReplicatedStorage.FruitInfo)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local intersection = Type.intersection(TypeUtil.Types.FrozenTable, Type.strictInterface({
	Text = Type.optional(Type.string),
	Icon = Type.optional(Type.string)
}))
local v = {}

function getCache(p: string)
	return v[p]
end

function setCache(p: string, p2)
	v[p] = p2
end

return function(p: string?)
	return React.useMemo(function()
		if p == nil then
			return {}
		end

		local cache = getCache(p)

		if cache ~= nil then
			return cache
		end

		local result = {}
		local v2 = FruitInfo:TryGet(p)

		if v2 then
			for _, element in pairs(v2.Elements) do
				local text = element.Text
				local images = element.Images
				local _34x34

				if images then
					_34x34 = images["34x34"] or images["100x100"] or images["845x845"]
				end

				if not (_34x34 ~= nil or text ~= nil) then
					continue
				end

				local v3 = {
					Text = text,
					Icon = _34x34
				}
				table.freeze(v3)
				assert(intersection(v3))
				table.insert(result, v3)
			end
		end

		table.freeze(result)
		setCache(p, result)
		return result
	end, { p })
end