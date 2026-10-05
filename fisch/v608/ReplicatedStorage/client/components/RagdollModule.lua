local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RagdollModule = {}
local v = {}

function CreateTemporaryParts(parent, part)
	local part2 = Instance.new("Part", parent)
	part2.Size = part.Size
	part2.Transparency = 1
	part2.CanCollide = true
	part2.CanTouch = false
	part2.CanQuery = false
	part2.CastShadow = false
	part2.Anchored = false
	part2.CFrame = part.CFrame
	local weld = Instance.new("Weld", part2)
	weld.Part0 = part2
	weld.Part1 = part

	if v[parent] then
		table.insert(v[parent], part2)
	end
end

function RagdollModule.Ragdoll(_, instance)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)
	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	humanoid.PlatformStand = true
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)

	if playerFromCharacter then
		ReplicatedStorage.events.RagdollMessage:FireClient(playerFromCharacter, true)
	end
end

function RagdollModule.UnRagdoll(_, instance)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)
	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	humanoid.PlatformStand = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

	if playerFromCharacter then
		ReplicatedStorage.events.RagdollMessage:FireClient(playerFromCharacter, false)
	end
end

return RagdollModule