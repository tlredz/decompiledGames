local ValueClasses = require(script.Parent.Parent.Parent.Misc.ValueClasses)
require(script.Parent.Parent.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Parent.Parent.Misc.FayeUtility)
return function(data, p, instance)
	local instance2 = data.Instance or data
	local v = 0
	local v2 = {}
	local fn

	fn = function(instance3, value: number?)
		local tof = FayeUtility.tof(instance3)
		local v3 = tof == "table"
		local v4 = not v3

		if v4 then
			if tof == "Instance" then
				v4 = instance3:IsA("ValueBase")
			else
				v4 = false
			end
		end

		local v5 = value or 1

		if v4 or v3 and instance3.__type ~= nil and ValueClasses[instance3.__type] then
			v = v5
			v2[v5] = instance3.Changed:Connect(function(p2)
				if v5 < v then
					for i = v, v5 + 1, -1 do
						v2[i]:Disconnect()
						v2[i] = nil
					end
				end

				v = v5
				fn(p2, v5 + 1)
			end, v2)
			fn(v4 and instance3.Value or instance3:Get(), v5 + 1)
		elseif data ~= nil and instance2 ~= nil then
			if v3 then
				instance3 = instance3.Instance or instance3
			end

			local tof2 = FayeUtility.tof(instance2[p])
			local tof3 = FayeUtility.tof(instance3)

			if tof2 == tof3 or tof2 == "nil" and tof3 ~= nil or (tof2 == "number" or tof2 == "string") and (tof3 == "number" or tof3 == "string") then
				instance2[p] = instance3
			end
		end
	end

	fn(instance)
	local cleanThread = data.CleanThread or data.Thread
	local parentChangedConnection = nil
	local fn2

	fn2 = function()
		if parentChangedConnection ~= nil then
			parentChangedConnection:Disconnect()
			parentChangedConnection = nil
		end

		FayeUtility.RemoveFromEntity(data, fn2)

		if cleanThread ~= nil then
			FayeUtility.RemoveFromThread(cleanThread, fn2)
		end

		cleanThread = nil

		if v2 ~= nil then
			FayeUtility.ClearAllConnections(v2, v)
			FayeUtility.tc(v2)
			v2 = nil
		end
	end

	if instance.ClassName ~= nil then
		parentChangedConnection = instance:GetPropertyChangedSignal("Parent"):Connect(function()
			if instance == nil or instance.Parent == nil then
				fn2()
			end
		end)
	end

	if cleanThread ~= nil then
		FayeUtility.AddToThread(cleanThread, fn2)
	end

	FayeUtility.AddToEntity(data, fn2)
end