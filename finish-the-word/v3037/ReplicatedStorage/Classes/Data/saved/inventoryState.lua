local import = _G.import("global")
local import2 = _G.import("class")
local import3 = _G.import("itemModules")
local import4 = _G.import("dictUtil")
local v = import2.new()

function v:getTypeSection(p2, p3, p4)
	local v2 = self[p2]
	import3:getItem(p3, p4)
	v2[p3] = v2[p3] or {}
	return v2[p3], p3
end

function v:find(p, p2, p3)
	for _, v2 in self:items(p, p2) do
		if import4.match(v2.Config._State, p3) then
			return v2
		end
	end
end

function v:findId(p, p2, p3)
	for _, v2 in self:items(p, p2) do
		if v2.Config.Id == p3 then
			return v2
		end
	end
end

function v:add(p, p2, id2, value, p4)
	import.get("playerSession", game.Players:GetPlayerByUserId(self.UserId))
	local id = self:findId(p, p2, id2)

	if id then
		id.Quantity += value or 1
		return
	end

	local typeSection, _ = self:getTypeSection(p, p2, id2)
	local v2 = {
		Config = import4.merge({
			Id = id2
		}, p4),
		Quantity = value or 1
	}
	typeSection:table_insert(#typeSection + 1, v2)
	local _ = typeSection[#typeSection]
end

function v:remove(p2, p3, p4)
	local v2 = self[p2][p3]
	local v3 = v2[p4]

	if v3.Quantity ~= 1 then
		v3.Quantity -= 1
		return
	end

	import.get("playerSession", game.Players:GetPlayerByUserId(self.UserId))
	v2:table_remove(p4)
end

function v:clear(p, p2)
	while #self[p][p2] > 0 do
		self:remove(p, p2, 1)
	end
end

function v:has(p, p2, p3)
	if self:findId(p, p2, p3) then
		return true
	end

	return false
end

function v.get(p, p2, p3, p4)
	return p[p2][p3][p4]
end

function v:getValue(p, p2, p3)
	return self:get(p, p2, p3).Config
end

function v:items(p2, p3)
	return self[p2][p3]:pairs()
end

function v:getEquippedItemOfClass(p, p2)
	for _, v2 in self:items("Equip", p) do
		local leaf = import3:getLeaf(v2.Id)

		if table.find(leaf.Value.TypeChain, p2) then
			return leaf
		end
	end
end

function v:getEquippedItemOfType(p, p2)
	for _, v2 in self:items("Equip", p) do
		local leafOfParent = import3:getLeafOfParent(p2, v2.Config.Id)

		if leafOfParent.Value.Type == p2 then
			return leafOfParent
		end
	end
end

function v:new()
	self.Inventory = {}
	self.Equip = {}

	for k, _ in pairs(_G.import("itemModules").penultimateNodes) do
		self.Inventory[k] = {
			_Insertable = true
		}
		self.Equip[k] = {
			_Insertable = true
		}
	end

	self.Inventory.Chair = {
		_Insertable = true,
		{
			Config = {
				Id = "Wooden"
			},
			Quantity = 1
		}
	}
	self.Equip.Chair = {
		_Insertable = true,
		{
			Config = {
				Id = "Wooden"
			},
			Quantity = 1
		}
	}
end

return v