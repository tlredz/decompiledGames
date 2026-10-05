local Players = game:GetService("Players")
local PlayerLookup = {}
local v = {}
local v2 = {}

local function onPlayerAdded(data)
	local connections = v2[data.UserId]

	if connections == nil then
		v2[data.UserId] = {}
		connections = v2[data.UserId]
	end

	table.insert(connections, data.CharacterAdded:Connect(function(folder)
		local parts = {}

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			PlayerLookup[part] = data
			table.insert(parts, part)
		end

		v[data] = parts
	end))
	table.insert(connections, data.CharacterRemoving:Connect(function()
		if v[data] ~= nil then
			for _, v3 in v[data] do
				PlayerLookup[v3] = nil
			end

			v[data] = nil
		end
	end))
end

local function onPlayerRemoving(p)
	if v[p] ~= nil then
		for _, v3 in v[p] do
			PlayerLookup[v3] = nil
		end

		v[p] = nil
	end

	if v2[p.UserId] ~= nil then
		for _, connection in v2[p.UserId] do
			connection:Disconnect()
		end

		v2[p.UserId] = nil
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, v3 in Players:GetPlayers() do
	onPlayerAdded(v3)
end

return PlayerLookup