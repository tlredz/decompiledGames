local Create = {}

function Create.Template(childName: string)
	return (assert(script.Templates:FindFirstChild(childName)):Clone())
end

function Create.new(className: string, items, list)
	local instance = Instance.new(className)

	if items then
		for k, item in pairs(items) do
			if item == nil then
				continue
			end

			local v = k
			local v2 = item
			local success, result = pcall(function(...)
				instance[v] = v2
			end)

			if not success then
				task.spawn(error, result)
			end
		end
	end

	if list then
		for _, v in ipairs(list) do
			if v and typeof(v) == "Instance" then
				v.Parent = instance
			end
		end
	end

	return instance
end

return Create