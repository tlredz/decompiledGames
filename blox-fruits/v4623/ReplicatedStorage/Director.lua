local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local GlobalUtil = require(ReplicatedStorage:WaitForChild("GlobalUtil"))
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local connectionsByName = {}
local connectionsByName2 = {}
local recurseClear

recurseClear = function(list)
	for _, v5 in list do
		if type(v5) == "table" then
			recurseClear(v5)
		end
	end

	table.clear(list)
end

local function destroy(instance)
	if instance.Destroying or instance.Destroy == nil then
		return
	end

	instance.Destroying = true
	instance:Destroy()
	recurseClear(instance)
end

return {
	Register = function(p, callback, instance)
		if GlobalUtil.FFlags.IsUnitTest == true then
			return "N/A"
		end

		local name = p.Name

		if v[p] then
			error((`{name} has already been registered as a Director component.`))
		end

		v[p] = true
		v2[p] = {}
		local v5 = {}
		local added

		added = function(instance2)
			if v5[instance2] then
				return
			end

			if instance == nil or instance:IsAncestorOf(instance2) ~= false then
				v5[instance2] = true
				local v6 = callback(instance2)

				if v4[name] == nil then
					v4[name] = {}
				end

				if v3[instance2] == nil then
					v3[instance2] = {}
				end

				v4[name][instance2] = v6
				v3[instance2][name] = v6
				task.spawn(v6.Init, v6)
			elseif v2[p][instance2] == nil then
				local ancestryChangedConnection = instance2.AncestryChanged:Connect(function()
					if instance2:IsDescendantOf(instance) then
						local v6 = v2[p][instance2]

						if v6 then
							v6.Destroying:Disconnect()
							v6.Ancestry:Disconnect()
							v6.TagRemoved:Disconnect()
							table.clear(v6)
							v2[p][instance2] = nil
						end

						added(instance2)
					end
				end)
				local destroyingConnection = instance2.Destroying:Connect(function()
					local v6 = v2[p][instance2]

					if v6 then
						v6.Destroying:Disconnect()
						v6.Ancestry:Disconnect()
						v6.TagRemoved:Disconnect()
						table.clear(v6)
						v2[p][instance2] = nil
					end
				end)
				local connection = CollectionService:GetInstanceRemovedSignal(name):Connect(function(p2)
					local v6 = p2 == instance2 and v2[p][instance2]

					if v6 then
						v6.Destroying:Disconnect()
						v6.Ancestry:Disconnect()
						v6.TagRemoved:Disconnect()
						table.clear(v6)
						v2[p][instance2] = nil
					end
				end)
				v2[p][instance2] = {
					Ancestry = ancestryChangedConnection,
					Destroying = destroyingConnection,
					TagRemoved = connection
				}
			end
		end

		local function removed(p2)
			local v6 = v4[name] and v4[name][p2]

			if v6 then
				task.spawn(destroy, v6)
				v4[name][p2] = nil
				v3[p2][name] = nil

				if next(v3[p2]) == nil then
					v3[p2] = nil
				end

				if next(v4[name]) == nil then
					v4[name] = nil
				end
			end

			v5[p2] = nil
		end

		connectionsByName[name] = CollectionService:GetInstanceAddedSignal(name):Connect(added)
		connectionsByName2[name] = CollectionService:GetInstanceRemovedSignal(name):Connect(removed)

		for _, v6 in CollectionService:GetTagged(name) do
			task.spawn(added, v6)
		end

		return name
	end
}