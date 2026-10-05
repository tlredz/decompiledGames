_G.import("sync")
local v2 = {
	Ball = 1,
	Emote = 2,
	ScoreEffect = 1,
	Title = 1,
	Card = 1,
	Skin = 1
}
local v3 = _G.import("modules")(script, {
	AddValidation = function()
		return true
	end,
	RemoveValidation = function(_, _, object, _, p)
		if object:has("Inventory", p) then
			return true
		end

		return false
	end,
	EquipValidation = function(_, p, object, _, p2)
		return not (p.UniqueEquip and object:has("Equip", p2))
	end,
	UnequipValidation = function(_, p, object, _, p2)
		if object:has("Equip", p.Type, p2) then
			return true
		end

		return false
	end,
	SelectValidation = function(_, _, object, _, p)
		if object:has("Equip", p) then
			return true
		end

		return false
	end,
	DeselectValidation = function(_, _, object, player, p)
		return object:get("Equip", "itemModules", player.Character.Selected).Id == p
	end,
	ActivationValidation = function(_, _, object, player, p)
		return object:get("Equip", "itemModules", player.Character.Selected).Id == p
	end,
	Add = function(_, _, object, _, p, p2)
		object:add("Inventory", p2, p)
	end,
	Remove = function(_, _, object, _, p, p2)
		object:remove("Inventory", p, p2)
	end,
	Equip = function(_, _, value, object, id, p2, _)
		if value:find("Equip", p2, {
			Id = id
		}) then
			return
		end

		local v3 = v2[p2] or 1

		if p2 == "Pet" and object:hasVip() then
			v3 += 1
		end

		if #value.Equip[p2] == v3 then
			value:remove("Equip", p2, 1)
		end

		value:add("Equip", p2, id)
	end,
	Unequip = function(_, _, object, player, _, p, p2)
		local _ = player.Character.Selected == p2
		object:remove("Equip", p, p2)
	end,
	Select = function(_, _, _, player, _, selected)
		player.Character.Selected = selected
	end,
	Deselect = function(_, _, _, player, _)
		player.Character.Selected = nil
	end,
	Activate = function(_, p, object, _, _, p2, p3)
		if p.Fragile then
			object:remove("Inventory", p2, p3)
		end
	end
})

function v3.getItem(object, p, p2)
	local leafOfParent = object:getLeafOfParent(p, p2)
	return leafOfParent and leafOfParent.Value
end

return v3