local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if script:IsDescendantOf(ReplicatedStorage) then
	return
end

local parent = script.Parent
local instances = {}
local instances2 = {}

local function onDescendant(descendant)
	if descendant:IsA("BasePart") then
		descendant.Material = Enum.Material.Neon
		table.insert(instances, descendant)
	elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
		table.insert(instances2, descendant)
	end
end

parent.DescendantAdded:Connect(onDescendant)

for _, descendant in parent:GetDescendants() do
	onDescendant(descendant)
end

parent.DescendantRemoving:Connect(function(descendant)
	if descendant:IsA("BasePart") then
		local index = table.find(instances, descendant)

		if index then
			table.remove(instances, index)
		end
	else
		local index = (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail")) and table.find(
			instances2,
			descendant
		)

		if index then
			table.remove(instances2, index)
		end
	end
end)
local v = 0
local now = 0
RunService.Heartbeat:Connect(function(dt)
	v = (v + dt * 0.1) % 1

	if tick() < now + 0.08333333333333333 then
		return
	end

	now = tick()
	local color = Color3.fromHSV(v, 0.4, 1)
	local colorSequence = ColorSequence.new(color)

	for _, v2 in instances do
		if v2.Parent then
			v2.Color = color
		end
	end

	for _, v2 in instances2 do
		if v2.Parent then
			v2.Color = colorSequence
		end
	end
end)