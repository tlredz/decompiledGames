local SkinCatalog = require(script.Parent.Parent.Weapons.SkinCatalog)
local v = {
	IntroSeconds = 3,
	SpinSeconds = 10,
	ResultSeconds = 6,
	MaxAmount = 1000000,
	EventSeconds = 90
}

function v.validPrize(data)
	if type(data) ~= "table" then
		return false
	end

	if data.kind == "Dagger" then
		return type(data.skin) == "string" and SkinCatalog.get(data.skin) ~= nil
	else
		return (data.kind == "Coins" or data.kind == "Gems" or data.kind == "XP") and type(data.amount) == "number" and data.amount == data.amount and data.amount % 1 == 0 and data.amount >= 1 and data.amount <= v.MaxAmount
	end
end

function v.key(data)
	return data.kind .. ":" .. tostring(data.skin or data.amount)
end

function v.label(data)
	return data.kind == "Dagger" and SkinCatalog.get(data.skin).Name or tostring(data.amount) .. " " .. data.kind:upper()
end

function v.validEvent(data, p, p2)
	if type(data) == "table" and data.version == 1 and data.author == p and type(data.id) == "string" and #data.id == 36 and type(data.issuedAt) == "number" and data.issuedAt == data.issuedAt and data.issuedAt <= p2 + 5 and p2 - data.issuedAt < v.EventSeconds then
		return (v.validPrize(data.prize))
	else
		return false
	end
end

function v.choose(list, object)
	return #list > 0 and list[object:NextInteger(1, #list)] or nil
end

return table.freeze(v)