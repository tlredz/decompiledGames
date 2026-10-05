require(game.ReplicatedStorage.Util)
local v = {}

local function set(instance, value, items)
	local v2 = value:gsub(" ", "")

	if typeof(items) ~= "table" then
		instance:SetAttribute(v2, items)
		return
	end

	local v3 = {}

	for k, item in pairs(items) do
		v3[v2 .. k:gsub(" ", "")] = true
		instance:SetAttribute(v2 .. k:gsub(" ", ""), item)
	end

	for k, _ in pairs(instance:GetAttributes()) do
		if v3[k] or not k:match(v2 .. "%u%l+") then
			continue
		end

		instance:SetAttribute(k, nil)
	end
end

game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Stats").OnClientEvent:Connect(function(p, p2, p3)
	v[p2] = p3

	if p == nil then
		p = game.Players.LocalPlayer.CharacterAdded:Wait()
	end

	set(p, p2, v[p2])
end)