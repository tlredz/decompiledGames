local class = require(game.ReplicatedStorage:WaitForChild("Classes"):WaitForChild("DataTypes"):WaitForChild("class"))
local v = class.new()

function v:new()
	self.items = {}
end

function v.push(p, p2)
	table.insert(p.items, p2)
end

function v.pop(p)
	return table.remove(p.items)
end

function v.peek(p)
	if #p.items > 0 then
		return p.items[#p.items]
	end

	return nil
end

function v.isEmpty(p)
	return #p.items == 0
end

function v.size(p)
	return #p.items
end

function v:clear()
	self.items = {}
end

return v