local import = _G.import("dictUtil")

local function collect(p, module, rootDirectory)
	local module2 = require(module)
	assert(
		type(module2) == "table",
		"Attempted to collect non-library module " .. module.Name .. " in directory " .. rootDirectory.Name
	)

	for k, v in pairs(module2) do
		assert(not p.Data[k], "Data " .. k .. " already assigned to this collection")

		if type(v) == "table" then
			v.DataId = k
			v.DataType = p.DataType
			v.Module = module
			v.RootDirectory = rootDirectory
		end

		p.Data[k] = v
	end
end

local v = _G.import("class").new()

function v:require(p)
	self:run(p)
end

function v.get(p, p2)
	return p.Data[p2]
end

function v:run(callback)
	for k, v2 in pairs(self.Data) do
		callback(k, v2)
	end
end

function v:new(dataType, ...)
	self.Data = {}
	self.DataType = dataType

	for _, v2 in pairs({ ... }) do
		local rootDirectory = v2
		import.runDescendantsOfType(v2, "ModuleScript", function(module)
			if module.Name:sub(1, 1) == "_" then
				return
			end

			collect(self, module, rootDirectory)
		end)
	end
end

return v