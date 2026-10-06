local v = {
	Computer = {
		B = true,
		C = true,
		F = true,
		G = true,
		H = true,
		J = true,
		K = true,
		L = true,
		N = true,
		P = true,
		R = true,
		T = true,
		U = true,
		X = true,
		Y = true,
		Z = true
	},
	Console = {
		ButtonX = true,
		ButtonY = true,
		ButtonR1 = true,
		DPadUp = true,
		DPadRight = true,
		DPadDown = true
	}
}
local v2 = {
	List = {
		{
			Name = "Bag",
			Frame = "Backpack",
			Computer = "R",
			Console = "DPadUp"
		},
		{
			Name = "Fighters",
			Frame = "Fighters",
			Computer = "F",
			Console = "DPadRight"
		},
		{
			Name = "Worlds",
			Frame = "Teleport",
			Computer = "T",
			Console = "DPadDown"
		},
		{
			Name = "Skill",
			Action = "Skill",
			Computer = "Z",
			Console = "ButtonX"
		}
	},
	Settings = {},
	IsAllowed = function(p: string, value)
		local v3 = v[p]
		return v3 ~= nil and typeof(value) == "string" and v3[value] == true
	end
}

function v2.Resolve(p, p2: string)
	local result = {}
	local v3 = {}
	local v4 = v[p2]

	if not v4 then
		return result
	end

	for _, v5 in v2.List do
		local formatted = `{v5.Name} Keybind {p2}`
		local v6

		if typeof(p) == "table" then
			v6 = p[formatted]
		else
			v6 = false
		end

		if not v2.IsAllowed(p2, v6) or v3[v6] then
			continue
		end

		result[formatted] = v6
		v3[v6] = true
	end

	local v5 = {}

	for k in v4 do
		table.insert(v5, k)
	end

	table.sort(v5)

	for _, v6 in v2.List do
		local formatted = `{v6.Name} Keybind {p2}`

		if result[formatted] then
			continue
		end

		local v7 = v6[p2]

		if v3[v7] then
			for _, v9 in v5 do
				if v3[v9] then
					continue
				end

				v7 = v9
				break
			end
		end

		result[formatted] = v7
		v3[v7] = true
	end

	return result
end

function v2.GetValue(p, p2: string)
	local setting = v2.Settings[p2]

	if setting then
		return v2.Resolve(p, setting.Device)[p2]
	end

	return nil
end

function v2.Validate(p, p2: string, p3)
	local setting = v2.Settings[p2]

	if not setting then
		return false, "This shortcut is unavailable."
	end

	if not v2.IsAllowed(setting.Device, p3) then
		return false, "This key is reserved or unavailable. Choose another."
	end

	for k, setting2 in v2.Settings do
		if k ~= p2 and setting2.Device == setting.Device and v2.GetValue(p, k) == p3 then
			return false, (`This key is already assigned to {setting2.DisplayName}.`)
		end
	end

	return true
end

for k, list in v2.List do
	for _, device in { "Computer", "Console" } do
		local formatted = `{list.Name} Keybind {device}`
		v2.Settings[formatted] = table.freeze({
			Name = formatted,
			DisplayName = list.Name,
			Action = list.Action or list.Frame,
			Device = device,
			Default = list[device],
			Index = k
		})
	end

	table.freeze(list)
end

table.freeze(v2.List)
table.freeze(v2.Settings)
return table.freeze(v2)