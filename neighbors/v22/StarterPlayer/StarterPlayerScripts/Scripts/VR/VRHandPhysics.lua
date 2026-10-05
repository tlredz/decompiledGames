local v = { "RightHand", "LeftHand" }

-- equivalent calls inferred from this helper; original call sites unknown
local function is_valid_physics_part(part)
	return part:IsA("BasePart") and table.find(v, part.Name)
end

local function create_physics_object(part)
	local clone = script.Collider:Clone()
	clone.Name = part.Name .. "/VR_COLLIDER"
	clone.Size = part.Size
	clone.CFrame = part.CFrame
	clone.AlignPosition.Position = part.Position
	clone.AlignOrientation.CFrame = part.CFrame
	local RunService = game:GetService("RunService")
	local heartbeatConnection = RunService.Heartbeat:connect(function(_)
		clone.AlignPosition.Position = part.Position
		clone.AlignOrientation.CFrame = part.CFrame

		if (clone.Position - part.Position).Magnitude > 10 then
			clone.CFrame = part.CFrame
		end
	end)
	part:GetPropertyChangedSignal("Size"):connect(function()
		clone.Size = part.Size
	end)
	part.AncestryChanged:connect(function(_, p)
		if not p then
			clone:Destroy()
		end
	end)
	clone.AncestryChanged:connect(function(_, p)
		if not p then
			heartbeatConnection:disconnect()
			heartbeatConnection = nil
		end
	end)
	clone.Parent = part.Parent
	print("physics part", part.Name)
	return clone
end

local function register_character(character)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)
	print("character added")

	if not playerFromCharacter:GetAttribute("VR") then
		return
	end

	print("character has vr")
	character.ChildAdded:connect(function(part)
		if is_valid_physics_part(part) then
			return (create_physics_object(part))
		end
	end)

	for _, part in character:GetChildren() do
		if is_valid_physics_part(part) then
			create_physics_object(part)
		end
	end
end

local function register_player(player)
	player:GetAttributeChangedSignal("VR"):connect(function()
		if player:GetAttribute("VR") and player.Character then
			return register_character(player.Character)
		end
	end)
	player.CharacterAdded:connect(register_character)

	if player.Character then
		return register_character(player.Character)
	end
end

game.Players.PlayerAdded:connect(function(p)
	return register_player(p)
end)

for _, v2 in game.Players:GetPlayers() do
	task.spawn(register_player, v2)
end