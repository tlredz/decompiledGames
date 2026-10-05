local DataSerializer = {}
local v = {
	string = "StringValue",
	number = "NumberValue",
	boolean = "BoolValue",
	Vector3 = "Vector3Value",
	CFrame = "CFrameValue",
	Color3 = "Color3Value",
	BrickColor = "BrickColorValue",
	Ray = "RayValue"
}

function DataSerializer.totable(instance, p)
	local result = {}

	for _, child in instance:GetChildren() do
		local v2

		if not (p == nil or not p[child.Name]) then
			v2 = p[child.Name](child) or nil
		end

		if v2 == nil then
			if child:IsA("Folder") or child:IsA("Configuration") then
				result[child.Name] = {
					_T = child.ClassName,
					_C = DataSerializer.totable(child, p)
				}
			elseif child:IsA("ValueBase") then
				result[child.Name] = {
					_T = child.ClassName,
					_V = child.Value
				}
			end
		else
			result[child.Name] = v2
		end
	end

	return result
end

function DataSerializer.tofold(items, p, p2, p3)
	local parent = p or Instance.new("Folder")

	if not p then
		parent.Name = "Data"
	end

	if not items then
		return parent
	end

	for k, item in items do
		local v3 = false

		if p3 ~= nil and p3[k] then
			local v4 = p3[k](item, parent)

			if v4 == true then
				v3 = true
			elseif v4 ~= nil then
				local v5 = v[typeof(v4)]

				if v5 then
					local instance = Instance.new(v5)
					instance.Name = k
					instance.Value = v4
					instance.Parent = parent
				end

				v3 = true
			end
		end

		if v3 then
			continue
		end

		if type(item) == "table" then
			if item._T then
				if item._C then
					local instance = Instance.new(item._T)
					instance.Name = k
					instance.Parent = parent
					DataSerializer.tofold(item._C, instance, nil, p3)
				elseif item._V ~= nil then
					local instance = Instance.new(item._T)
					instance.Name = k
					instance.Value = item._V
					instance.Parent = parent
				end
			else
				local folder = Instance.new("Folder")
				folder.Name = k
				folder.Parent = parent
				DataSerializer.tofold(item, folder, p2, p3)
			end
		else
			local v4 = p2 and p2[k] or v[typeof(item)]

			if v4 then
				local instance = Instance.new(v4)
				instance.Name = k
				instance.Value = item
				instance.Parent = parent
			end
		end
	end

	return parent
end

function DataSerializer:overwrite(items, p)
	if typeof(self) == "Instance" then
		local v2 = {}

		for _, child in self:GetChildren() do
			v2[child.Name] = child
		end

		for k, v3 in v2 do
			if items[k] ~= nil then
				continue
			end

			v3:Destroy()
			v2[k] = nil
		end

		for k, item in items do
			if type(item) == "table" then
				local instance = v2[k]

				if instance and (instance:IsA("Folder") or instance:IsA("Configuration")) then
					DataSerializer.overwrite(instance, item, p)
				else
					if instance then
						instance:Destroy()
					end

					local folder = Instance.new("Folder")
					folder.Name = k
					folder.Parent = self
					DataSerializer.tofold(item, folder, p)
				end
			else
				local v3 = p and p[k] or v[typeof(item)]

				if v3 then
					local valueBase = v2[k]

					if valueBase and valueBase:IsA("ValueBase") and valueBase.ClassName == v3 then
						valueBase.Value = item
					else
						if valueBase then
							valueBase:Destroy()
						end

						local instance = Instance.new(v3)
						instance.Name = k
						instance.Value = item
						instance.Parent = self
					end
				end
			end
		end
	else
		for k in self do
			if items[k] == nil then
				self[k] = nil
			end
		end

		for k, item in items do
			if type(item) == "table" and type(self[k]) == "table" then
				DataSerializer.overwrite(self[k], item, p)
			else
				self[k] = item
			end
		end
	end
end

function DataSerializer.toraw(instance, p)
	if typeof(instance) == "Instance" then
		instance = DataSerializer.totable(instance, p)
	end

	local result = {}

	for k, v2 in instance do
		if type(v2) == "table" and v2._T then
			if v2._C then
				result[k] = DataSerializer.toraw(v2._C, p)
			elseif v2._V ~= nil then
				result[k] = v2._V
			end
		else
			result[k] = v2
		end
	end

	return result
end

return DataSerializer