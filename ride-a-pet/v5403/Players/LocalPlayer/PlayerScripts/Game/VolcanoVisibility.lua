local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local connections = {}
local volcanoValidated = localPlayer:GetAttribute("VolcanoValidated") == true

-- equivalent calls inferred from this helper; original call sites unknown
local function IsCover(part)
	return part:IsA("BasePart") and part:FindFirstAncestor("Volcano_Hide") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Restore(p)
	local v3 = v2[p]

	if not v3 then
		return
	end

	v2[p] = nil
	p.LocalTransparencyModifier = v3.Transparency
	p.CanCollide = v3.CanCollide
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Apply(state)
	if volcanoValidated then
		if not v2[state] then
			v2[state] = {
				Transparency = state.LocalTransparencyModifier,
				CanCollide = state.CanCollide
			}
		end

		state.LocalTransparencyModifier = 1
		state.CanCollide = false
	else
		Restore(state) -- equivalent call inferred; original call site unknown
	end
end

local function Track(part)
	if not IsCover(part) or v[part] then
		return
	end

	v[part] = part.AncestryChanged:Connect(function()
		local v3, v4, connection

		if part:IsDescendantOf(workspace) then
			local part2 = part

			if not part2:IsA("BasePart") or part2:FindFirstAncestor("Volcano_Hide") == nil then
				v3 = part
				v4 = v2[v3]

				if v4 then
					v2[v3] = nil
					v3.LocalTransparencyModifier = v4.Transparency
					v3.CanCollide = v4.CanCollide
				end

				connection = v[part]
				v[part] = nil

				if connection then
					connection:Disconnect()
				end
			end
		else
			v3 = part
			v4 = v2[v3]

			if v4 then
				v2[v3] = nil
				v3.LocalTransparencyModifier = v4.Transparency
				v3.CanCollide = v4.CanCollide
			end

			connection = v[part]
			v[part] = nil

			if connection then
				connection:Disconnect()
			end
		end
	end)
	Apply(part) -- equivalent call inferred; original call site unknown
end

table.insert(connections, workspace.DescendantAdded:Connect(Track))
table.insert(connections, localPlayer:GetAttributeChangedSignal("VolcanoValidated"):Connect(function()
	volcanoValidated = localPlayer:GetAttribute("VolcanoValidated") == true

	for k in v do
		Apply(k) -- equivalent call inferred; original call site unknown
	end
end))

for _, descendant in workspace:GetDescendants() do
	Track(descendant)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Observers"))
local VolcanoScale = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("VolcanoScale"))
local v3 = Observers.observeAttribute(localPlayer, "VolcanoValidated", function()
	return Observers.observeTag(VolcanoScale.MeshDisableTag, function(part)
		if not part:IsA("BasePart") or part:IsA("BasePart") and part:FindFirstAncestor("Volcano_Hide") ~= nil then
			return nil
		end

		local canCollide = part.CanCollide
		part.CanCollide = false
		return function()
			part.CanCollide = canCollide
		end
	end, { workspace })
end, function(p)
	return p == true
end)
script.Destroying:Connect(function()
	v3()

	for _, connection in connections do
		connection:Disconnect()
	end

	for k, connection in v do
		connection:Disconnect()
		Restore(k) -- equivalent call inferred; original call site unknown
	end

	table.clear(v)
end)