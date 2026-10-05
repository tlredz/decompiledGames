local MaidTaskUtils = {
	isValidTask = function(value)
		if type(value) == "function" or typeof(value) == "RBXScriptConnection" then
			return true
		elseif type(value) == "table" then
			return type(value.Destroy) == "function"
		else
			return false
		end
	end,
	doTask = function(parent, p)
		if type(parent) == "function" then
			parent()
		elseif typeof(parent) == "RBXScriptConnection" then
			parent:Disconnect()
		elseif typeof(parent) == "Instance" then
			local function isDestroyed(parent2)
				local _, result = pcall(function()
					parent2.Parent = parent2
				end)

				if result:match("locked") then
					return true
				end

				return false
			end

			local _, result = pcall(function()
				parent.Parent = parent
			end)

			if not result:match("locked") then
				pcall(function()
					parent:Destroy()
				end)
			end
		elseif type(parent) == "table" and type(parent.Destroy) == "function" then
			parent:Destroy()
		else
			print("Job info:", (typeof(parent)))
			print("Key", p)

			if typeof(parent) == "table" then
				for k, item in pairs(parent) do
					print("\t" .. tostring(k) .. ": " .. tostring(item))
				end
			end

			error("Bad job")
		end

		return nil
	end
}

function MaidTaskUtils.delayed(duration, p)
	assert(type(duration) == "number", "Bad time")
	assert(MaidTaskUtils.isValidTask(p), "Bad job")
	return function()
		task.delay(duration, function()
			MaidTaskUtils.doTask(p)
		end)
	end
end

return MaidTaskUtils