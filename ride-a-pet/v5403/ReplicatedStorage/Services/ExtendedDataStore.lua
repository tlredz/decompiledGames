local ExtendedDataStore = {}

function ExtendedDataStore.SetDatastore(_, p, cframe, object)
	local success, result = pcall(function()
		if typeof(cframe) == "CFrame" then
			cframe = { cframe:GetComponents() }
		end

		object:SetAsync(p, cframe)
	end)

	if success then
		return
	end

	warn(string.format("%s:%s | %s", tostring(p), typeof(cframe), result))
end

function ExtendedDataStore.FetchDatastore(_, p, object)
	local async = nil
	local success, result = pcall(function()
		async = object:GetAsync(p)
	end)

	if success then
		return async
	end

	warn(result)
	return false
end

function ExtendedDataStore:InstanceToTable(instance)
	local result = {}

	for _, child in ipairs(instance:GetChildren()) do
		if child:IsA("Folder") then
			result[child.Name] = self:InstanceToTable(child)
		elseif child:IsA("ValueBase") then
			result[child.Name] = child.Value
		end
	end

	return result
end

function ExtendedDataStore:SetData(parent, items, options)
	local result = options or {}

	for childName, item in pairs(items) do
		if childName == "Backpack" then
			continue
		end

		if type(item) == "table" then
			local v = parent:FindFirstChild(childName)

			if not v then
				v = Instance.new("Folder")
				v.Name = childName
				v.Parent = parent
			end

			self:SetData(v, item, result)
		else
			if childName == "LastLoginTime" then
				result.PreviousLoginTime = item
			end

			local valueBase = parent:FindFirstChild(childName)

			if valueBase then
				if valueBase:IsA("ValueBase") then
					valueBase.Value = item
				else
					warn(("Found non-Value instance named %q under %q; skipping"):format(
						childName,
						parent:GetFullName()
					))
				end
			else
				local v

				if type(item) == "boolean" then
					v = "BoolValue"
				elseif type(item) == "string" then
					v = "StringValue"
				elseif type(item) == "number" then
					v = item % 1 == 0 and "IntValue" or "NumberValue"
				else
					warn(("Unsupported type for key %q: %s"):format(childName, (type(item))))
					continue
				end

				local instance = Instance.new(v)
				instance.Name = childName
				instance.Value = item
				instance.Parent = parent
			end
		end
	end

	return result
end

return ExtendedDataStore