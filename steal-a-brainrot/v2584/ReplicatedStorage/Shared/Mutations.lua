local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = {
	{ "EclipseEvent", "Eclipse" },
	{ "CrystalEvent", "Crystal" },
	{ "PhantomEvent", "Phantom" },
	{ "CyberEvent", "Cyber" },
	{ "DivineEvent", "Divine" },
	{ "CursedEvent", "Cursed" },
	{ "RadioactiveEvent", "Radioactive" },
	{ "YinYangEvent", "YinYang" },
	{ "GalaxyEvent", "Galaxy" },
	{ "MoltenEvent", "Lava" },
	{ "CandyEvent", "Candy" },
	{ "BloodmoonEvent", "Bloodrot" }
}

local function getList()
	local result = {}

	for _, v2 in v do
		if ReplicatedStorage:GetAttribute(v2[1]) then
			table.insert(result, v2[2])
		end
	end

	return result
end

local v2 = {}

for _, v3 in v do
	v2[v3[2]] = true
end

local function shallowEquals(list, list2)
	if #list ~= #list2 then
		return false
	end

	for k, v3 in list do
		if list2[k] ~= v3 then
			return false
		end
	end

	return true
end

local Mutations = {}
Mutations.getList = getList

function Mutations.get()
	return getList()[1]
end

function Mutations.watch(callback)
	local list = getList()

	local function tryUpdate()
		local list2 = getList()
		local v3 = list
		local flag

		if #v3 == #list2 then
			local flag2 = true

			for k, v4 in v3 do
				if list2[k] == v4 then
					continue
				end

				flag = false
				flag2 = false
				break
			end

			if flag2 then
				flag = true
			end
		else
			flag = false
		end

		if flag then
			return
		end

		list = list2
		callback()
	end

	local maid = Trove.new()

	for _, v3 in v do
		maid:Add(ReplicatedStorage:GetAttributeChangedSignal(v3[1]):Connect(tryUpdate))
	end

	return maid:WrapClean()
end

function Mutations.isEventMutation(p: string)
	return v2[p] == true
end

return Mutations