require(script.Parent.Parent.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Parent.Parent.Misc.FayeUtility)
local ValueClasses = require(script.Parent.Parent.Parent.Misc.ValueClasses)
local v = {
	NumberValue = true,
	IntConstrainedValue = true,
	IntValue = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanIndividual(p, p2)
	if p[p2] ~= nil then
		FayeUtility.CallDestroy(p[p2])
		p[p2] = nil
	end
end

local function subCompile(flag: boolean, thread, callback, p, class, callback2, p2, p3, p4)
	if p2 == nil or p3 == nil then
		return
	end

	local v2 = p4 or p2
	local thread2

	if flag then
		thread2 = class
	else
		cleanIndividual(class, v2) -- equivalent call inferred; original call site unknown
		thread2 = thread:Extend(true)
	end

	local v4, v5 = callback(p2, p3, thread2, p.Instance)
	local v6 = nil
	local v7

	if v5 == nil and v4 ~= nil then
		v7 = (FayeUtility.tof(v4) ~= FayeUtility.tabletxt or v4.__type ~= nil or not v4) and { v4 } or v4
	else
		v7 = v4 ~= nil and v5 ~= nil and {
			[v4] = v5
		} or v6
	end

	if not flag then
		class[v2] = thread2
	end

	if v7 ~= nil then
		callback2(flag and p or {
			Instance = p.Instance,
			Thread = thread2
		}, v7, thread2)
	end
end

return function(p, _, data, callback)
	local thread = p.Thread

	if thread == nil or thread.Extend == nil then
		warn("Iteterate only works if the entity has a thread and the thread has an :Extend method")
		return
	end

	local v2 = not data.Advanced
	local v3 = nil
	local class = nil

	local function cleanHolder(flag: boolean?)
		if v3 ~= nil then
			v3 = nil
		end

		if v2 then
			if class ~= nil then
				class:Destroy()
				class = nil
			end

			if flag then
				class = thread:Extend(true)
				v3 = {
					Instance = p.Instance,
					Thread = class
				}
			end
		else
			if class ~= nil then
				for _, v4 in pairs(class) do
					if v4 ~= nil and v4.Destroy then
						FayeUtility.CallDestroy(v4)
					end
				end

				FayeUtility.tc(class)
				class = nil
			end

			if flag then
				class = {}
			end
		end
	end

	local v4 = nil
	local v5 = nil
	local v6 = thread
	local Delete

	Delete = function(_: boolean?)
		FayeUtility.RemoveFromThread(v6, Delete)
		FayeUtility.RemoveFromEntity(p, Delete)

		if v4 ~= nil then
			FayeUtility.ClearAllConnections(v4, v5)
		end

		if class ~= nil then
			cleanHolder()
			class = nil
		end
	end

	local v7 = nil
	local mainFunc

	mainFunc = function(instance, value: number?)
		if instance == nil then
			return
		end

		local tof = FayeUtility.tof(instance)
		local v8 = tof == "number"
		local v9 = tof == "table"
		local v10 = not (v8 or v9)

		if v10 then
			if tof == "Instance" then
				v10 = v[instance.ClassName]
			else
				v10 = false
			end
		end

		if not (v8 or v9 or v10) then
			return
		end

		local v11 = value or 1

		if v8 then
			cleanHolder(true)
			v7 = instance

			for i = 1, instance do
				subCompile(v2, thread, data.Function, v3 or p, class, callback, i, i)
			end
		elseif v10 or instance.__type ~= nil and ValueClasses[instance.__type] then
			v5 = v11

			if v4 == nil then
				v4 = {}
			end

			v4[v11] = instance.Changed:Connect(function(p2, p3, p4, p5: number?, flag: boolean?)
				if p3 == nil or p5 == nil or v2 then
					p3 = p2
				end

				if v11 < v5 then
					cleanHolder(true)

					for i = v5, v11 + 1, -1 do
						v4[i]:Disconnect()
						v4[i] = nil
					end
				end

				v5 = v11

				if p4 == nil and p5 == nil or v2 then
					mainFunc(p3, v11 + 1)
				elseif FayeUtility.tof(p3) == "number" and p4 == nil and p5 ~= nil then
					if p3 > 0 then
						local v12 = v7

						if p5 == 2 then
							v7 -= p3

							for i = v12, math.max(v12 - p3 + 1, 1), -1 do
								if class[i] == nil then
									continue
								end

								cleanIndividual(class, i) -- equivalent call inferred; original call site unknown
							end
						else
							v7 += p3

							for i = 1, p3 do
								local v13 = i + v12
								subCompile(v2, thread, data.Function, v3 or p, class, callback, v13, v13, v13)
							end
						end
					end
				else
					local v12 = flag and p4 or p3

					if p5 == 2 then
						if class[v12] == nil then
							if class[p3] ~= nil then
								cleanIndividual(class, p3) -- equivalent call inferred; original call site unknown
							end
						else
							cleanIndividual(class, v12) -- equivalent call inferred; original call site unknown
						end
					else
						subCompile(v2, thread, data.Function, v3 or p, class, callback, p3, p4, v12)
					end
				end
			end, v4)
			mainFunc(v10 and instance.Value or instance:Get(), v11 + 1)
		else
			cleanHolder(true)
			local count = 0

			for k, v12 in pairs(instance) do
				count += 1
				subCompile(v2, thread, data.Function, v3 or p, class, callback, k, v12, k == count and v12 or nil)
			end
		end
	end

	mainFunc(data.Tab)
	FayeUtility.AddToEntity(p, Delete)

	if thread._isCleanAncestor then
		local parentThread = thread

		while parentThread ~= nil and not parentThread._hc do
			parentThread = parentThread.ParentThread
		end

		v6 = parentThread or thread
	end

	if v6 ~= nil then
		FayeUtility.AddToThread(v6, Delete)
	end
end