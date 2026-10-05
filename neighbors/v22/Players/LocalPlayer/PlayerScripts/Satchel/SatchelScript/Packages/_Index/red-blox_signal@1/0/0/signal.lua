local Promise = require(script.Parent.Promise)
local Spawn = require(script.Parent.Spawn)
local class = {}
class.__index = class

function class:Connect(callback)
	local root2 = {
		Next = self.Root,
		Callback = callback
	}
	self.Root = root2
	return function()
		if self.Root == root2 then
			self.Root = root2.Next
			return
		end

		local root = self.Root

		while root do
			if root.Next == root2 then
				root.Next = root2.Next
				break
			else
				root = root.Next
			end
		end
	end
end

function class:Wait()
	return Promise.new(function(callback)
		local connection = nil
		connection = self:Connect(function(...)
			connection()
			callback((...))
		end)
	end)
end

function class.Fire(p, ...)
	local root = p.Root

	while root do
		Spawn(root.Callback, ...)
		root = root.Next
	end
end

function class:DisconnectAll()
	self.Root = nil
end

return function()
	return (setmetatable({
		Root = nil
	}, class))
end