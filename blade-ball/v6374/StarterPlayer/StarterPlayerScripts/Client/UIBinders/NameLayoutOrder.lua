local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Common.Utils)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function sortContainer(list)
	table.sort(list, function(a, b)
		local name = a.Name
		local name2 = b.Name
		local v2 = tonumber(name) ~= nil
		local v3 = tonumber(name2) ~= nil

		if v2 and v3 then
			return tonumber(name) < tonumber(name2)
		end

		if v2 then
			return true
		end

		if v3 then
			return false
		end

		local match = name:match("(%d+)$")
		local match2 = name2:match("(%d+)$")
		local v4 = name:gsub("(%d+)$", "")
		local v5 = name2:gsub("(%d+)$", "")
		local v6 = match and tonumber(match) or nil
		local v7 = match2 and tonumber(match2) or nil

		if v4:lower() == v5:lower() then
			return v6 and not v7 or v6 and v7 and v6 < v7
		end

		return v4:lower() < v5:lower()
	end)

	for k, v2 in pairs(list) do
		v2.LayoutOrder = k
	end
end

local maid = Utils.Maid.new()
return {
	Binder = function(instance)
		local maid2 = Utils.Maid.new()
		local parent = nil

		local function queueSort(list)
			if maid[list] then
				maid[list] = Utils.Thread.Delay(0.1, function()
					sortContainer(list) -- equivalent call inferred; original call site unknown
					maid[list] = nil
				end)
				return
			end

			sortContainer(list) -- equivalent call inferred; original call site unknown
			maid[list] = Utils.Thread.Delay(0.1, function()
				maid[list] = nil
			end)
		end

		local function updateContainer()
			local v2 = parent and v[parent]

			if v2 then
				for k, v3 in pairs(v2) do
					if v3 ~= instance then
						continue
					end

					table.remove(v2, k)
					break
				end
			end

			parent = instance.Parent
			local instances = v[parent]

			if not instances then
				instances = {}
				v[parent] = instances
			end

			if not table.find(instances, instance) then
				table.insert(instances, instance)
			end

			queueSort(instances)
		end

		updateContainer()

		local function update()
			if parent then
				queueSort(v[parent])
			end
		end

		maid2:GiveTask(instance:GetPropertyChangedSignal("Parent"):Connect(update))
		maid2:GiveTask(instance:GetPropertyChangedSignal("LayoutOrder"):Connect(update))
		maid2:GiveTask(instance:GetPropertyChangedSignal("Name"):Connect(update))
		maid2:GiveTask(function()
			if not parent then
				return
			end

			local v2 = v[parent]

			if v2 then
				for k, v3 in pairs(v2) do
					if v3 ~= instance then
						continue
					end

					table.remove(v2, k)
					return
				end
			end
		end)
		return maid2
	end
}