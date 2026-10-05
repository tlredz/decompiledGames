local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))

local function bladeMeshes(folder)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") and part.Name == "Plane.010" then
			table.insert(parts, part)
		end
	end

	return parts
end

local function heldUnder(p, p2: string, p3)
	local parent = p.Parent

	while parent and parent ~= p3 do
		if parent.Name == p2 then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function pickHolder(character, items, holder: string)
	if holder == "All" then
		return items
	end

	local result = {}

	for _, item in items do
		local parent = item.Parent
		local flag

		while true do
			if not parent or parent == character then
				flag = false
				break
			end

			if parent.Name == holder then
				flag = true
				break
			else
				parent = parent.Parent
			end
		end

		if flag then
			table.insert(result, item)
		end
	end

	if #result == 0 then
		warn((`ViceAdmiral.KatanaSpark: no sword model named "{holder}"`))
	end

	return result
end

local function sparkOn(parent, spark)
	local katanaSpark = parent:FindFirstChild("KatanaSpark")

	if katanaSpark then
		return katanaSpark
	end

	local clone = spark:Clone()
	clone.Name = "KatanaSpark"

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	clone.Parent = parent
	return clone
end

return function(player)
	local character = player.Character

	if typeof(character) ~= "Instance" or not character:IsA("Model") then
		return
	end

	local spark = script:FindFirstChild("Spark")

	if not spark then
		warn("ViceAdmiral.KatanaSpark: Spark template missing")
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

	if humanoidRootPart and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 700 then
		return
	end

	local v = pickHolder(character, bladeMeshes(character), player.Holder or "All")

	if #v == 0 then
		return
	end

	local color

	if typeof(player.Color) == "Color3" then
		color = player.Color
	end

	for _, v2 in v do
		local folder = sparkOn(v2, spark)

		for _, emitter in folder:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if color then
				emitter.Color = ColorSequence.new(color)
			end

			emitter:Emit(player.Emit or emitter:GetAttribute("EmitCount") or 18)
		end

		Util.Debris:AddItem(folder, 3)
	end
end