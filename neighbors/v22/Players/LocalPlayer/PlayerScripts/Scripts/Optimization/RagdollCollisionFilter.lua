local v = {}

for _, v2 in {
	"LeftFoot",
	"LeftHand",
	"LeftLowerArm",
	"LeftLowerLeg",
	"LeftUpperArm",
	"LeftUpperLeg",
	"LowerTorso",
	"RightFoot",
	"RightHand",
	"RightLowerArm",
	"RightLowerLeg",
	"RightUpperArm",
	"RightUpperLeg",
	"UpperTorso",
	"Head",
	"HumanoidRootPart"
} do
	v[v2] = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function get_collision_group(instance)
	if instance:GetAttribute("Carried") or instance:GetAttribute("PropMorphed") then
		return "Carried"
	end

	if instance:GetAttribute("Tied") then
		return "RopedRagdoll"
	end

	if instance:GetAttribute("Tripped") then
		return "RagdollInstance"
	end

	return "Player"
end

local function register_character(instance)
	local function update()
		local collisionGroup = get_collision_group(instance) -- equivalent call inferred; original call site unknown

		for _, part in instance:GetChildren() do
			if part:IsA("BasePart") and v[part.Name] then
				part.CollisionGroup = collisionGroup
			end
		end
	end

	instance:GetAttributeChangedSignal("Carried"):connect(update)
	instance:GetAttributeChangedSignal("Tripped"):connect(update)
	instance:GetAttributeChangedSignal("Tied"):connect(update)
	instance:GetAttributeChangedSignal("PropMorphed"):connect(update)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function register_player(player)
	player.CharacterAdded:connect(register_character)

	if player.Character then
		task.spawn(register_character, player.Character)
	end
end

for _, v2 in game.Players:GetPlayers() do
	register_player(v2) -- equivalent call inferred; original call site unknown
end

game.Players.PlayerAdded:connect(register_player)