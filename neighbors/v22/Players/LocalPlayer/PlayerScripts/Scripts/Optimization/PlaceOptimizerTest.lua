local Players = game:GetService("Players")
local v = {}

local function UpdateHouse(folder, flag: boolean)
	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Name ~= "Baseplate") then
			continue
		end

		if not v[part] then
			v[part] = {
				CanCollide = part.CanCollide,
				CastShadow = part.CastShadow,
				CanQuery = part.CanQuery,
				CanTouch = part.CanTouch
			}
		end

		for k, _ in v[part] do
			local v2

			if flag then
				v2 = v[part][k]
			else
				v2 = false
			end

			part[k] = v2
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Update()
	local currentInternalMap = Players.LocalPlayer:GetAttribute("CurrentInternalMap")

	for _, child in workspace.Places:GetChildren() do
		if child.Name == currentInternalMap then
			UpdateHouse(child, true)
		else
			UpdateHouse(child, false)
		end
	end
end

Update()
Players.LocalPlayer:GetAttributeChangedSignal("CurrentInternalMap"):Connect(function()
	Update() -- equivalent call inferred; original call site unknown
end)