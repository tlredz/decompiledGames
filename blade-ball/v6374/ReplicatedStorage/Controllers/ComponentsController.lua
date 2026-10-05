local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Observers)
local ComponentsController = {}

function ComponentsController:HandleComponent(data)
	if data.Tags then
		for _, tag in data.Tags do
			v.observeTag(tag, function(p)
				return data.Callback(p)
			end)
		end
	end

	if data.ChildrenOf then
		for _, v2 in data.ChildrenOf do
			v.observeChildren(v2, function(p)
				return data.Callback(p)
			end)
		end
	end
end

function ComponentsController:Start()
	for _, child in script:GetChildren() do
		self:HandleComponent((require3(child)))
	end

	script.ChildAdded:Connect(function(child)
		self:HandleComponent((require3(child)))
	end)
end

return ComponentsController