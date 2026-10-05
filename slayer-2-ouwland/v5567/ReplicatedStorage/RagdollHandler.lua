local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local v = {
	[Enum.HumanoidStateType.Physics] = true
}
local v2 = {}
local v3 = {}

function setRagdollEnabled(p, p2)
	if v3[p] == nil then
		v3[p] = not p2
	end

	if v3[p] ~= p2 then
		v3[p] = p2
		local ragdollConstraints = p.Parent:FindFirstChild("RagdollConstraints")

		if ragdollConstraints ~= nil then
			for _, constraint in pairs(ragdollConstraints:GetChildren()) do
				if not (constraint:IsA("Constraint") and constraint:FindFirstChild("RigidJoint") ~= nil) then
					continue
				end

				local value = constraint.RigidJoint.Value
				local parent

				if not (p2 or constraint == nil or constraint.Attachment1 == nil or constraint.Attachment1.Parent == nil) then
					parent = constraint.Attachment1.Parent or nil
				end

				if value ~= nil and value.Part1 ~= parent then
					value.Part1 = parent
				end
			end
		end
	end
end

local v4 = {
	"RagDoll",
	"ragdoll",
	"Ragdoll",
	"ragDoll"
}

local function followsState(object, p)
	local playerFromCharacter = Players:GetPlayerFromCharacter(object.Parent)

	if playerFromCharacter == nil then
		return true
	end

	if not isServer then
		return playerFromCharacter == Players.LocalPlayer
	end

	if not p then
		return true
	end

	local player_Service = ReplicatedStorage:FindFirstChild("Player_Service")
	local child = player_Service ~= nil and player_Service.Values:FindFirstChild(playerFromCharacter.Name) or nil

	if child == nil or child:FindFirstChild("noragdoll") ~= nil then
		return false
	end

	for _, childName in v4 do
		if child:FindFirstChild(childName) ~= nil then
			return true
		end
	end

	return false
end

function ragdollAdded(object)
	v2[object] = object.StateChanged:Connect(function()
		local v5 = v[object:GetState()] == true

		if followsState(object, v5) then
			setRagdollEnabled(object, v5)
		end
	end)
end

function ragdollRemoved(p)
	v2[p]:Disconnect()
	v2[p] = nil
	v3[p] = nil
end

CollectionService:GetInstanceAddedSignal("Ragdoll"):Connect(ragdollAdded)
CollectionService:GetInstanceRemovedSignal("Ragdoll"):Connect(ragdollRemoved)

for _, v5 in pairs(CollectionService:GetTagged("Ragdoll")) do
	ragdollAdded(v5)
end

return nil