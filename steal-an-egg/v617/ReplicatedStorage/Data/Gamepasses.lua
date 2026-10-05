local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local interface = t.interface({
	Name = t.string,
	DisplayName = t.string,
	Desc = t.string,
	Icon = t.string,
	ProductId = t.intersection(t.integer, t.numberPositive),
	Precheck = t.optional(t.callback)
})
local modulesByProductId = {}
local modulesByName = {}

for _, moduleScript in script.Configs:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	local v, v2 = interface(module)

	if not v then
		error((`gamepass config {moduleScript.Name} is malformed: {v2}`))
	end

	if module.Name ~= moduleScript.Name then
		error((`gamepass config {moduleScript.Name} calls itself "{module.Name}"`))
	end

	local v3 = modulesByProductId[module.ProductId]

	if v3 ~= nil then
		error((`gamepasses "{v3.Name}" and "{module.Name}" share ProductId {module.ProductId}`))
	end

	modulesByName[module.Name] = module
	modulesByProductId[module.ProductId] = module
end

table.freeze(modulesByName)
table.freeze(modulesByProductId)
return table.freeze({
	Directory = modulesByName,
	FromProductId = function(p: number)
		return modulesByProductId[p]
	end
})