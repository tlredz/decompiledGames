local Nav = {}
local v = {}
local v2 = {}
local bindableEvent = Instance.new("BindableEvent")
Nav.Changed = bindableEvent

-- equivalent calls inferred from this helper; original call sites unknown
local function fire(p, p2)
	bindableEvent:Fire(p, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isOpen(p)
	return p and p.panel and p.panel.IsOpen == true
end

local closeChildren

closeChildren = function(p)
	for k, v3 in pairs(v) do
		if not (v3.parent == p and v3 and v3.panel and v3.panel.IsOpen == true) then
			continue
		end

		closeChildren(k)
		v3.panel:Close()
	end
end

function Nav.register(p, panel, options)
	local v3 = options or {}
	local group = v3.Group
	v[p] = {
		panel = panel,
		group = group == nil and "Window" or group,
		parent = v3.Parent
	}
	local v4 = v2[p]
	v2[p] = nil

	if v4 and os.clock() <= v4 then
		Nav.open(p)
	end

	return panel
end

function Nav.unregister(p)
	v[p] = nil
end

function Nav.get(p)
	local v3 = v[p]
	return v3 and v3.panel or nil
end

function Nav.isOpen(p)
	return isOpen(v[p])
end

function Nav.current(p)
	local v3 = p == nil and "Window" or p

	for k, v4 in pairs(v) do
		if v4.group == v3 and v4 and v4.panel and v4.panel.IsOpen == true then
			return k
		end
	end

	return nil
end

function Nav.open(p)
	local v3 = v[p]

	if not v3 then
		v2[p] = os.clock() + 5
		return false
	end

	if v3 and v3.panel and v3.panel.IsOpen == true or Nav.gate and Nav.gate(p, v3.group) == false then
		return false
	end

	if v3.group then
		for k, v4 in pairs(v) do
			if not (k ~= p and v4.group == v3.group and v4 and v4.panel) then
				continue
			end

			if not (v4.panel.IsOpen == true and k ~= v3.parent) then
				continue
			end

			closeChildren(k)
			v4.panel:Close()
		end
	end

	v3.panel:Open()
	fire(p, v3.group) -- equivalent call inferred; original call site unknown
	return true
end

function Nav.close(p)
	local v3 = v[p]

	if not v3 or not v3.panel or v3.panel.IsOpen ~= true then
		return false
	end

	closeChildren(p)
	v3.panel:Close()
	fire(nil, v3.group) -- equivalent call inferred; original call site unknown
	return true
end

function Nav.toggle(p)
	if Nav.isOpen(p) then
		Nav.close(p)
		return false
	end

	Nav.open(p)
	return true
end

function Nav.closeAll(p)
	for _, v3 in pairs(v) do
		if (p == nil or v3.group == p) and v3 and v3.panel and v3.panel.IsOpen == true then
			v3.panel:Close()
		end
	end

	fire(nil, p) -- equivalent call inferred; original call site unknown
end

function Nav.onChange(onEvent)
	return bindableEvent.Event:Connect(onEvent)
end

function Nav.names()
	local result = {}

	for k in pairs(v) do
		result[#result + 1] = k
	end

	table.sort(result)
	return result
end

return Nav