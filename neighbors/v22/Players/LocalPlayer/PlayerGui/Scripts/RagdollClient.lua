local character = game.Players.LocalPlayer.Character
local humanoid = character:WaitForChild("Humanoid")
require(game.ReplicatedStorage.Modules.Network)
local RunService = game:GetService("RunService")
game:GetService("PhysicsService")
local v = {
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
	"Head"
}
local folder = Instance.new("Folder", character)
folder.Name = "LocalRagdollCollision"

-- equivalent calls inferred from this helper; original call sites unknown
local function is_valid_part(part)
	if part:IsA("BasePart") then
		return table.find(v, part.Name) and true or false
	end
end

local function register_part(part)
	-- equivalent call inferred; original call site unknown
	if not is_valid_part(part) then
		return
	end

	local part2 = Instance.new("Part")
	part2.Name = "Collider"
	part2.Transparency = 1
	part2.CanCollide = false
	part2.Massless = true
	part2.CFrame = part.CFrame
	part2.CollisionGroup = "RagdollCollider"
	local weldConstraint = Instance.new("WeldConstraint", part2)
	weldConstraint.Part0 = part
	weldConstraint.Part1 = part2

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		part2.Size = part.Size * 0.5
	end

	update() -- equivalent call inferred; original call site unknown
	part:GetPropertyChangedSignal("Size"):connect(function()
		return update()
	end)
	character:GetAttributeChangedSignal("Ragdoll"):connect(function()
		part2.CanCollide = character:GetAttribute("Ragdoll") or humanoid:GetState() == Enum.HumanoidStateType.Dead
	end)
	humanoid.Died:connect(function()
		part2.CanCollide = false
	end)
	part2.Parent = folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function is_character_down()
	return character:GetAttribute("Tripped") or character:GetAttribute("Carried")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function is_character_dead()
	return humanoid:GetState() == Enum.HumanoidStateType.Dead or humanoid.Health < 1
end

local function update_humanoid_state()
	if character:GetAttribute("Tripped") or character:GetAttribute("Carried") then
		while is_character_down() and humanoid:GetState() ~= Enum.HumanoidStateType.Dead and not (humanoid.Health < 1) do
			humanoid.PlatformStand = true
			task.wait()
		end

		if is_character_dead() then
			humanoid.PlatformStand = false
		end
	else
		humanoid.PlatformStand = false
		RunService.Heartbeat:wait()
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

for _, child in character:GetChildren() do
	task.spawn(register_part, child)
end

character.ChildAdded:connect(function(part)
	return register_part(part)
end)
character:GetAttributeChangedSignal("Tripped"):connect(function()
	update_humanoid_state()
end)
character:GetAttributeChangedSignal("Carried"):connect(function()
	update_humanoid_state()
end)