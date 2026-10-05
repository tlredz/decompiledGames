local v = nil
local import = _G.import("dictUtil")
local import2 = _G.import("itemModules")
local RunService = game:GetService("RunService")
local v2 = RunService:IsServer() and "Server" or "Client"
local v3 = import.set("Add", "Remove", "Equip", "Unequip", "Select", "Deselect", "Activate")
local v4 = {
	Add = function(_, p, p2)
		return p2, p
	end,
	Unequip = function(p, p2, p3)
		local v5 = p.Equip[p2][p3]

		if v5 then
			return v5.Config.Id, p2
		end
	end
}

for _, v5 in pairs({
	"Remove",
	"Equip",
	"Select",
	"Deselect",
	"Activate"
}) do
	v4[v5] = function(p, p2, p3)
		local v6 = p.Inventory[p2][p3]

		if v6 then
			return v6.Config.Id, p2
		end
	end
end

local Item = {}
local runNode

runNode = function(p, p2, p3, p4, p5, ...)
	local v5 = p5 .. (p and "Validation" or "")
	local parent = p4.Parent

	if parent then
		local v6 = runNode(p, p2, p3, parent, p5, ...)

		if p and v6 ~= true then
			return false
		end
	end

	if p4.Value[v5] then
		return p4.Value[v5](p2, p3.Value, ...)
	end

	return true
end

local function item(p, p2, p3, p4, ...)
	if not v3[p4] then
		return false
	end

	local v5 = v2 .. p4
	local v6, v7 = v4[p4](p2, ...)

	if not v6 then
		return false
	end

	local v8 = import2.penultimateNodes[v7].Content[v6]

	if not runNode(true, p, v8, v8, p4, p2, p3, v6, ...) then
		return false
	end

	runNode(false, p, v8, v8, p4, p2, p3, v6, ...)
	runNode(false, p, v8, v8, v5, p2, p3, v6, ...)
	return true
end

function Item.item(...)
	return item(...)
end

local recurseSetAutoRepl

recurseSetAutoRepl = function(object, p)
	rawset(object, "_auto_repl", p)

	for _, v5 in object:pairs() do
		if type(v5) == "table" then
			recurseSetAutoRepl(v5, p)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setAutoRepl(_, p, p2, p3)
	if v2 == "Server" then
		recurseSetAutoRepl(p, p3)
		recurseSetAutoRepl(p2, p3)
	end
end

function Item.itemRepl(p, p2, p3, p4, p5, ...)
	setAutoRepl(nil, p2, p3, true) -- equivalent call inferred; original call site unknown
	local v5 = item(p, p2, p3, p4, p5, ...)
	setAutoRepl(nil, p2, p3, false) -- equivalent call inferred; original call site unknown
	return v5
end

local function items(p, p2, _, _, items2, ...)
	v = v or _G.import("sync")

	for _, item2 in pairs(items2) do
		if v3[item2] then
			if v.common(p2, p, item2, ...) ~= true then
				return false
			end
		else
			warn("attempted to call inexistant item action in multi item")
		end
	end

	return true
end

function Item.items(p, p2, p3, p4, ...)
	return items("item", p, p2, p3, p4, ...)
end

function Item.itemsRepl(p, p2, p3, p4, ...)
	return items("itemRepl", p, p2, p3, p4, ...)
end

return Item