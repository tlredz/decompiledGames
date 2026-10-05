local parentModule = require(script.Parent)
local Display = require(game.ReplicatedStorage.Packages.Display)
local Result = require(game.ReplicatedStorage.Packages.Result)
local Option = require(game.ReplicatedStorage.Packages.Option)
local v = Display.JSON.new():setUseMetatable(false):setOverride(function(object, p: number, object2, p2)
	if Option.isOption(object) or Result.isResult(object) then
		return object2:display(object:asNullable(), p, p2)
	end

	if typeof(object) == "DateTime" then
		return (`"DateTime({object:ToIsoDate()})"`)
	end

	return nil
end):build()
local clone = table.clone(parentModule.ALL)
table.sort(clone, function(a, b)
	return a.ItemId < b.ItemId
end)
local Lune = {}

for k, v2 in clone do
	Lune[k] = v:display(v2)
end

return Lune