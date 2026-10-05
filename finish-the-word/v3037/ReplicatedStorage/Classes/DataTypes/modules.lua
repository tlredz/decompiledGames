local import = _G.import("class")
local import2 = _G.import("dictUtil")
local v = import.new()

function v:get(p2)
	return self.Content[p2]
end

function v:new(p, instance, p2, options)
	local copy = import2.deepCopy(options or {})
	self.Value = p
	self.Content = {}
	self.Name = instance.Name
	p.TypeChain = copy
	p.Type = copy[#copy]
	p.RootType = copy[1]
	table.insert(copy, instance.Name)

	for k, v2 in pairs(p.Content or {}) do
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = k
		self.Content[k] = v(v2, moduleScript, p2, copy)
	end

	for _, moduleScript in pairs(instance:GetChildren()) do
		local content = self.Content
		local name = moduleScript.Name
		local module = require(moduleScript)
		content[name] = v(module, moduleScript, p2, copy)
	end

	for k, v2 in pairs(self.Content) do
		v2.Parent = self

		if p2.leaves[k] then
			p2.penultimateNodes[instance.Name] = self
		end
	end

	if import2.count(self.Content) == 0 then
		p2.leaves[instance.Name] = self
	end
end

local v2 = import.new()

function v2:new(p2, p3)
	self.leaves = {}
	self.penultimateNodes = {}
	self.rootNode = v(p3, p2, self)
end

function v2:get(p2)
	return self.rootNode:get(p2)
end

function v2.getLeaf(p, p2)
	return p.leaves[p2]
end

function v2.getLeafOfParent(p, p2, p3)
	return p.penultimateNodes[p2].Content[p3]
end

function v2.getPenultimateNode(p, p2)
	return p.penultimateNodes[p2]
end

return v2