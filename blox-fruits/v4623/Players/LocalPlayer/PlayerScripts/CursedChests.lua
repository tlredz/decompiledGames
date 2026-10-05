local cursedChest = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CursedChest", 10)

if not cursedChest then
	return
end

local v = {}

function UpdateChests()
	for k, v2 in pairs(v) do
		local v3 = {}

		for _, v4 in pairs(v2) do
			if tick() < v4 then
				table.insert(v3, v4)
			end
		end

		if #v3 > 0 then
			v[k] = v3
			k.Transparency = 1
			k.CanQuery = false
			k.CanTouch = false
			k.CanCollide = false
		else
			v[k] = nil
			k.Transparency = 0
			k.CanQuery = true
			k.CanTouch = true
			k.CanCollide = true
		end
	end
end

local connection = nil
local v2 = nil
cursedChest.OnClientEvent:Connect(function(p)
	local Global = require(game.ReplicatedStorage.Global)
	local encoded = Global.Encode(p)

	if connection then
		connection:Disconnect()
		connection = nil
	end

	if v2 then
		for k, v4 in pairs(v[v2] or {}) do
			if v4 ~= 1e999 then
				continue
			end

			v[v2][k] = tick() + 10
			break
		end
	end

	if encoded then
		v[encoded] = v[encoded] or {}
		table.insert(v[encoded], 1e999)
	end

	UpdateChests()
	v2 = encoded
end)

function updateCursedChest(instance)
	if instance.Name ~= "CursedTreasure" then
		return
	end

	if instance:GetAttribute("Owner") == game.Players.LocalPlayer.Name then
		if not instance:GetAttribute("Tagged") then
			instance:SetAttribute("Tagged", true)
			instance:GetPropertyChangedSignal("Parent"):Connect(function()
				if not instance.Parent and v2 then
					for k, v3 in pairs(v[v2] or {}) do
						if v3 ~= 1e999 then
							continue
						end

						v[v2][k] = tick() + 10
						break
					end

					v2 = nil
					UpdateChests()
				end
			end)
			instance.CanQuery = true
			instance.CanCollide = true
			instance.Transparency = 0

			for _, emitter in pairs(instance:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			instance.ChildAdded:Connect(function(emitter)
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end)
		end
	else
		instance.CanTouch = false
	end
end

for _, child in pairs(workspace.Map:GetChildren()) do
	updateCursedChest(child)
end

workspace.Map.ChildAdded:Connect(updateCursedChest)

while task.wait(1) do
	UpdateChests()
end