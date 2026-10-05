local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ragdoll = require(ReplicatedStorage.Shared.Flags.GameplayBalance).Ragdoll
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local RagdollJoints = require(ReplicatedStorage2.Shared.Modules.RagdollJoints)
local Remotes = require(ReplicatedStorage2.Shared.Remotes)
local t = require(ReplicatedStorage2.Packages.t)
local ClientCharacterAction

if RunService:IsServer() then
	ClientCharacterAction = require(ServerScriptService.Library.Modules.ClientCharacterAction)
else
	ClientCharacterAction = nil
end

local physics = Enum.HumanoidStateType.Physics
local gettingUp = Enum.HumanoidStateType.GettingUp
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))

local function fn(data)
	return typeof(data) == "Vector3" and intersection(data.X) and intersection(data.Y) and intersection(data.Z)
end

local v = {}
local count = 0
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function heldBody(instance)
	return instance:FindFirstChildOfClass("Humanoid")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isLimp(object)
	return object:GetState() == physics
end

-- equivalent calls inferred from this helper; original call sites unknown
local function goLimp(object, vector: Vector3?)
	local rootPart = object.RootPart

	if rootPart then
		object:ChangeState(physics)

		if vector and typeof(vector) == "Vector3" then
			rootPart:ApplyImpulse(vector)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function standUp(object)
	local rootPart = object.RootPart

	if rootPart then
		object:ChangeState(gettingUp)
		rootPart.CanCollide = true
	end
end

local function beginFor(character, object, p: number, vector: Vector3?)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if playerFromCharacter then
		assert(ClientCharacterAction, "ClientCharacterAction is only available on the server").BeginRagdoll(
			playerFromCharacter,
			character,
			p,
			vector
		)
		return
	end

	goLimp(object, vector) -- equivalent call inferred; original call site unknown
end

local function endFor(character, object)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if playerFromCharacter then
		assert(ClientCharacterAction, "ClientCharacterAction is only available on the server").EndRagdoll(
			playerFromCharacter,
			character
		)
		return
	end

	local rootPart = object and object.RootPart

	if rootPart then
		object:ChangeState(gettingUp)
		rootPart.CanCollide = true
	end
end

v2 = {
	ClientRagdollRemote = Remotes.Limpness.WriteLimpness,
	IsRagdolled = function(instance)
		t.strict(t.instanceIsA("Model"))(instance)
		local v3 = heldBody(instance) -- equivalent call inferred; original call site unknown

		if v[instance] == nil then
			if v3 == nil then
				return false
			else
				return v3:GetState() == physics
			end
		else
			return true
		end
	end,
	Ragdoll = function(instance)
		local humanoid = instance:WaitForChild("Humanoid")

		if humanoid:GetState() ~= physics then
			humanoid.BreakJointsOnDeath = false
			local PLAYER_RAGDOLL_SECONDS = ragdoll.PLAYER_RAGDOLL_SECONDS
			local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

			if playerFromCharacter then
				assert(ClientCharacterAction, "ClientCharacterAction is only available on the server").BeginRagdoll(
					playerFromCharacter,
					instance,
					PLAYER_RAGDOLL_SECONDS,
					nil
				)
			elseif humanoid.RootPart then
				humanoid:ChangeState(physics)
			end

			RagdollJoints.Bind(instance)
		end
	end,
	NpcRagdoll = function(instance, duration: number)
		local humanoid = instance:FindFirstChild("Humanoid")

		if humanoid then
			humanoid.BreakJointsOnDeath = false
		end

		if not humanoid or humanoid:GetState() == physics then
			return
		end

		humanoid.PlatformStand = true
		humanoid:ChangeState(physics)
		RagdollJoints.Bind(instance)
		task.wait(duration)

		if instance and instance.Parent then
			humanoid.PlatformStand = false
			humanoid:ChangeState(gettingUp)
			RagdollJoints.Release(instance)
		end
	end,
	TimedRagdoll = function(instance, duration: number, vector: Vector3?)
		t.strict(intersection)(duration)
		assert(duration >= 0, "Ragdoll duration must be non-negative")
		t.strict(t.optional(fn))(vector)
		local humanoid = instance:WaitForChild("Humanoid")
		humanoid.BreakJointsOnDeath = false
		local limp = isLimp(humanoid) -- equivalent call inferred; original call site unknown
		local v3 = v[instance]
		count += 1
		local token = count
		local ownsConstraints

		if v3 then
			ownsConstraints = v3.OwnsConstraints
		else
			ownsConstraints = not limp
		end

		v[instance] = {
			Token = token,
			OwnsConstraints = ownsConstraints
		}

		if v3 == nil and not limp then
			RagdollJoints.Bind(instance)
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

		if playerFromCharacter then
			assert(ClientCharacterAction, "ClientCharacterAction is only available on the server").BeginRagdoll(
				playerFromCharacter,
				instance,
				duration,
				vector
			)
		else
			goLimp(humanoid, vector) -- equivalent call inferred; original call site unknown
		end

		task.wait(duration)
		local v6 = v[instance]

		if not v6 or v6.Token ~= token then
			return
		end

		v[instance] = nil
		local playerFromCharacter2 = Players:GetPlayerFromCharacter(instance)

		if playerFromCharacter2 then
			assert(ClientCharacterAction, "ClientCharacterAction is only available on the server").EndRagdoll(
				playerFromCharacter2,
				instance
			)
		else
			local rootPart = humanoid and humanoid.RootPart

			if rootPart then
				humanoid:ChangeState(gettingUp)
				rootPart.CanCollide = true
			end
		end

		if v6.OwnsConstraints then
			RagdollJoints.Release(instance)
		end
	end,
	TimedRagdollAsync = function(p, p2: number, vector: Vector3?)
		task.spawn(v2.TimedRagdoll, p, p2, vector)
	end,
	ApplyClientRagdoll = function(instance, vector: Vector3?)
		local v3 = heldBody(instance) -- equivalent call inferred; original call site unknown
		assert(v3 ~= nil, (`{instance:GetFullName()} has no Humanoid to ragdoll`))
		v3.BreakJointsOnDeath = false
		local limp = isLimp(v3) -- equivalent call inferred; original call site unknown
		goLimp(v3, vector) -- equivalent call inferred; original call site unknown

		if not limp then
			RagdollJoints.Bind(instance)
		end
	end,
	ClearClientRagdoll = function(instance)
		local v3 = heldBody(instance) -- equivalent call inferred; original call site unknown
		assert(v3 ~= nil, (`{instance:GetFullName()} has no Humanoid to stand up`))
		standUp(v3) -- equivalent call inferred; original call site unknown
		RagdollJoints.Release(instance)
	end,
	Unragdoll = function(character)
		v[character] = nil
		local v3 = heldBody(character) -- equivalent call inferred; original call site unknown
		local playerFromCharacter = Players:GetPlayerFromCharacter(character)

		if playerFromCharacter then
			assert(ClientCharacterAction, "ClientCharacterAction is only available on the server").EndRagdoll(
				playerFromCharacter,
				character
			)
		else
			local rootPart = v3 and v3.RootPart

			if rootPart then
				v3:ChangeState(gettingUp)
				rootPart.CanCollide = true
			end
		end

		RagdollJoints.Release(character)
	end
}
return v2