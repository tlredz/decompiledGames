local createVector = vector.create
local Debris = game:GetService("Debris")
local Config = require(script.Parent.Config)
require(script.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function randomSpin(object)
	return Vector3.new(object:NextNumber(-1, 1), object:NextNumber(-1, 1), object:NextNumber(-1, 1)) * Config.flingAngularSpeed
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playHitSound(parent)
	local sound = Instance.new("Sound")
	sound.SoundId = Config.hitSoundId
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMinDistance = 12
	sound.RollOffMaxDistance = 220
	sound.Parent = parent
	sound:Play()
	Debris:AddItem(sound, Config.hitSoundLifetimeSeconds)
end

local function getUp(p)
	if p.humanoid.Parent and p.humanoid.Health > 0 then
		p.humanoid.PlatformStand = false
		p.humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	if p.root.Parent then
		p.root.AssemblyAngularVelocity = createVector(0, 0, 0)
	end

	if p.root:CanSetNetworkOwnership() then
		p.root:SetNetworkOwnershipAuto()
	end
end

return {
	start = function()
		local random = Random.new()
		local v = {}
		local v2 = {}

		local function endTrip(p, p2)
			if v[p] == p2 then
				v[p] = nil
				getUp(p2)
			end
		end

		return {
			fling = function(p, root, object2, vector2: Vector3)
				local vector3 = Vector3.new(vector2.X, 0, vector2.Z)
				local v3 = not (vector3.Magnitude > 0.001) and createVector(1, 0, 0) or vector3.Unit
				local v4 = 1 + random:NextNumber(-Config.flingSpeedJitter, Config.flingSpeedJitter)
				local v5 = {
					humanoid = object2,
					root = root
				}
				v[p] = v5
				v2[p] = os.clock() + Config.tripSeconds + Config.immunityGraceSeconds

				if root:CanSetNetworkOwnership() then
					root:SetNetworkOwner(nil)
				end

				object2.PlatformStand = true
				object2:ChangeState(Enum.HumanoidStateType.Physics)
				root.AssemblyLinearVelocity = v3 * Config.flingHorizontalSpeed * v4 + createVector(0, 1, 0) * Config.flingVerticalSpeed * v4
				root.AssemblyAngularVelocity = randomSpin(random)
				playHitSound(root) -- equivalent call inferred; original call site unknown
				task.delay(Config.tripSeconds, endTrip, p, v5)
			end,
			isImmune = function(p)
				local v3 = v2[p]
				return v3 ~= nil and os.clock() < v3
			end,
			stop = function()
				for _, v3 in v do
					getUp(v3)
				end

				table.clear(v)
				table.clear(v2)
			end
		}
	end
}