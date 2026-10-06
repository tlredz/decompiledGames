local function observeProperty(instance, propertyName: string, callback)
	local v = nil
	local connection = nil
	local count = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function OnPropertyChanged()
		if v ~= nil then
			task.spawn(v)
			v = nil
		end

		count += 1
		local v2 = count
		local v3 = instance[propertyName]
		task.spawn(function()
			local v4 = callback(v3)

			if typeof(v4) == "function" then
				if v2 == count and connection.Connected then
					v = v4
				else
					task.spawn(v4)
				end
			end
		end)
	end

	connection = instance:GetPropertyChangedSignal(propertyName):Connect(OnPropertyChanged)
	task.defer(function()
		if not connection.Connected then
			return
		end

		OnPropertyChanged() -- equivalent call inferred; original call site unknown
	end)
	return function()
		connection:Disconnect()

		if v ~= nil then
			task.spawn(v)
			v = nil
		end
	end
end

return observeProperty