local createVector = vector.create
game:GetService("RunService")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local v = {
	Wander = {
		Chance = 25,
		Interval = 18
	},
	Sunbath = {
		Chance = 20,
		Interval = 25
	}
}
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
local GaryGator = {}
GaryGator.__index = GaryGator
setmetatable(GaryGator, CompanionBehavior)

function GaryGator.new(p)
	local v2 = CompanionBehavior.new(p)
	setmetatable(v2, GaryGator)
	v2:RegisterMoods(v)
	v2.wanderPhaseGen = 0
	v2.wanderSpots = {}
	v2.wanderSpotIndex = 0
	v2._wanderEnded = false
	v2.sunbathPhaseGen = 0
	v2._sunbathEnded = false
	v2.sunbathOrigin = createVector(0, 0, 0)
	v2.snapPhaseGen = 0
	v2._snapEnded = false
	v2.snapOrigin = createVector(0, 0, 0)
	v2.deathRollPhaseGen = 0
	v2._deathRollEnded = false
	v2._isRolling = false
	v2._deathRollAngle = 0
	v2.deathRollOrigin = createVector(0, 0, 0)
	return v2
end

function GaryGator:_GetBobberPosition()
	local character = self.companion.Owner.Character

	if not character then
		return nil
	end

	local tool = character:FindFirstChildWhichIsA("Tool")

	if not tool then
		return
	end

	local bobber = tool:FindFirstChild("bobber")

	if bobber and bobber:IsA("BasePart") then
		return bobber.Position
	end

	return nil
end

function GaryGator:_FindNearbyWater()
	local rootPart = self.companion.RootPart

	if not rootPart then
		return nil
	end

	local zones = workspace:FindFirstChild("zones")
	local fishing = zones and zones:FindFirstChild("fishing")

	if not fishing then
		return nil
	end

	overlapParams.FilterDescendantsInstances = { fishing }
	local position = rootPart.Position
	local partBoundsInRadius = workspace:GetPartBoundsInRadius(position, 12, overlapParams)
	local v2 = 1e999
	local v3 = nil

	for _, v4 in partBoundsInRadius do
		local magnitude = (v4.Position - position).Magnitude

		if not (magnitude < v2) then
			continue
		end

		v3 = v4
		v2 = magnitude
	end

	if v3 then
		return v3.Position
	end

	return nil
end

function GaryGator:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function GaryGator.Update(object, p: number)
	if object.activeMood then
		return nil
	end

	local state = object.companion.State

	if state == "Walking" or state == "Jumping" then
		return nil
	end

	return object:RollMoods(p)
end

function GaryGator:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self._wanderEnded = false
	self._sunbathEnded = false
	self._snapEnded = false
	self._deathRollEnded = false
	self._isRolling = false
	self._deathRollAngle = 0

	if activeMood == "Wander" then
		self:StartWander(p)
	elseif activeMood == "Sunbath" then
		self:StartSunbath()
	elseif activeMood == "Snap" then
		self:StartSnap()
	elseif activeMood == "DeathRoll" then
		self:StartDeathRoll()
	end
end

function GaryGator:UpdateMood(p: number)
	self:_TickMovement(p)

	if self._isRolling then
		self._deathRollAngle = (self._deathRollAngle + p * 12.566370614359172) % 6.283185307179586
		self.companion.MoodRotationTilt = CFrame.Angles(0, 0, self._deathRollAngle)
	end

	if self._wanderEnded or self._sunbathEnded or self._snapEnded or self._deathRollEnded then
		return true
	end

	return false
end

function GaryGator:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Wander" then
		self:CleanupWander()
	elseif self.activeMood == "Sunbath" then
		self:CleanupSunbath()
	elseif self.activeMood == "Snap" then
		self:CleanupSnap()
	elseif self.activeMood == "DeathRoll" then
		self:CleanupDeathRoll()
	end

	self.activeMood = nil
end

function GaryGator:StartWander(p)
	self:SetState("MoodAction")
	self.wanderSpots = p.WanderSpots or {}
	self.wanderSpotIndex = 0

	if #self.wanderSpots == 0 then
		self._wanderEnded = true
	else
		self:EnterWanderPhase("WalkToNextSpot")
	end
end

function GaryGator:EnterWanderPhase(p: string)
	self.wanderPhaseGen += 1
	local wanderPhaseGen = self.wanderPhaseGen

	local function stillValid()
		return self.activeMood == "Wander" and self.wanderPhaseGen == wanderPhaseGen
	end

	if p == "WalkToNextSpot" then
		self.wanderSpotIndex += 1

		if self.wanderSpotIndex > #self.wanderSpots then
			self._wanderEnded = true
		else
			self:MoveTo(self.wanderSpots[self.wanderSpotIndex], {
				speed = 5,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v2

					if self.activeMood == "Wander" then
						v2 = self.wanderPhaseGen == wanderPhaseGen
					else
						v2 = false
					end

					if v2 then
						self:EnterWanderPhase("PauseAtSpot")
					end
				end
			})
		end
	elseif p == "PauseAtSpot" then
		self:StopMoving()
		self:PlayAnimation("Idle")
		local v2 = 0.8 + math.random() * 1.7
		task.delay(v2, function()
			local v3

			if self.activeMood == "Wander" then
				v3 = self.wanderPhaseGen == wanderPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterWanderPhase("WalkToNextSpot")
			end
		end)
	end
end

function GaryGator:CleanupWander()
	self:StopMoving()
	self.wanderSpots = {}
	self.wanderSpotIndex = 0
end

function GaryGator:StartSunbath()
	self:SetState("MoodAction")
	self.sunbathOrigin = self.companion.RootPart.Position
	self:EnterSunbathPhase("FindWater")
end

function GaryGator:EnterSunbathPhase(p: string)
	self.sunbathPhaseGen += 1
	local sunbathPhaseGen = self.sunbathPhaseGen

	local function stillValid()
		return self.activeMood == "Sunbath" and self.sunbathPhaseGen == sunbathPhaseGen
	end

	local companion = self.companion

	if p == "FindWater" then
		local _FindNearbyWater = self:_FindNearbyWater()

		if _FindNearbyWater then
			self:MoveTo(_FindNearbyWater, {
				speed = 4,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v2

					if self.activeMood == "Sunbath" then
						v2 = self.sunbathPhaseGen == sunbathPhaseGen
					else
						v2 = false
					end

					if v2 then
						self:EnterSunbathPhase("Submerge")
					end
				end
			})
		else
			self:EnterSunbathPhase("RestOnLand")
		end
	elseif p == "Submerge" then
		self:StopMoving()
		companion.MoodIgnoreGroundClamp = true
		local position = companion.RootPart.Position
		companion.MoodPositionOverride = Vector3.new(position.X, position.Y + -1.4, position.Z)
		companion.MoodSmoothTime = 0.12
		self:PlayAnimation("Idle")
		local v2 = 8 + math.random() * 10
		task.delay(v2, function()
			local v3

			if self.activeMood == "Sunbath" then
				v3 = self.sunbathPhaseGen == sunbathPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterSunbathPhase("Emerge")
			end
		end)
	elseif p == "RestOnLand" then
		self:StopMoving()
		self:PlayAnimation("Idle")
		local v2 = 8 + math.random() * 10
		task.delay(v2, function()
			local v3

			if self.activeMood == "Sunbath" then
				v3 = self.sunbathPhaseGen == sunbathPhaseGen
			else
				v3 = false
			end

			if v3 then
				self._sunbathEnded = true
			end
		end)
	elseif p == "Emerge" then
		companion.MoodIgnoreGroundClamp = false
		companion.MoodPositionOverride = nil
		companion.MoodSmoothTime = nil
		self._sunbathEnded = true
	end
end

function GaryGator:CleanupSunbath()
	self:StopMoving()
	local companion = self.companion
	companion.MoodIgnoreGroundClamp = false
	companion.MoodPositionOverride = nil
	companion.MoodSmoothTime = nil
end

function GaryGator:StartSnap()
	self:SetState("MoodAction")
	self.snapOrigin = self.companion.RootPart.Position
	self:EnterSnapPhase("Lunge")
end

function GaryGator:EnterSnapPhase(p: string)
	self.snapPhaseGen += 1
	local snapPhaseGen = self.snapPhaseGen

	local function stillValid()
		return self.activeMood == "Snap" and self.snapPhaseGen == snapPhaseGen
	end

	if p == "Lunge" then
		local _GetBobberPosition = self:_GetBobberPosition()

		if _GetBobberPosition then
			self:MoveTo(_GetBobberPosition, {
				speed = 16,
				animation = self:GetWalkAnimation(),
				arriveRadius = 2.5,
				onArrive = function()
					local v2

					if self.activeMood == "Snap" then
						v2 = self.snapPhaseGen == snapPhaseGen
					else
						v2 = false
					end

					if v2 then
						self:EnterSnapPhase("Bite")
					end
				end
			})
		else
			self._snapEnded = true
		end
	elseif p == "Bite" then
		self:StopMoving()
		self:PlayAnimation("Jump")
		self:PlaySound("Snap", true)
		task.delay(0.4, function()
			local v2

			if self.activeMood == "Snap" then
				v2 = self.snapPhaseGen == snapPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterSnapPhase("Return")
			end
		end)
	elseif p == "Return" then
		self:MoveTo(self.snapOrigin, {
			speed = 10,
			animation = self:GetWalkAnimation(),
			arriveRadius = 1.5,
			onArrive = function()
				local v2

				if self.activeMood == "Snap" then
					v2 = self.snapPhaseGen == snapPhaseGen
				else
					v2 = false
				end

				if v2 then
					self._snapEnded = true
				end
			end
		})
	end
end

function GaryGator:CleanupSnap()
	self:StopMoving()
end

function GaryGator:StartDeathRoll()
	self:SetState("MoodAction")
	local companion = self.companion
	companion.MoodUninterruptible = true
	self.deathRollOrigin = companion.RootPart.Position
	self:EnterDeathRollPhase("Lunge")
end

function GaryGator:EnterDeathRollPhase(p: string)
	self.deathRollPhaseGen += 1
	local deathRollPhaseGen = self.deathRollPhaseGen

	local function stillValid()
		return self.activeMood == "DeathRoll" and self.deathRollPhaseGen == deathRollPhaseGen
	end

	local companion = self.companion

	if p == "Lunge" then
		local _GetBobberPosition = self:_GetBobberPosition()

		if _GetBobberPosition then
			self:MoveTo(_GetBobberPosition, {
				speed = 20,
				animation = self:GetWalkAnimation(),
				arriveRadius = 2.5,
				onArrive = function()
					local v2

					if self.activeMood == "DeathRoll" then
						v2 = self.deathRollPhaseGen == deathRollPhaseGen
					else
						v2 = false
					end

					if v2 then
						self:EnterDeathRollPhase("Roll")
					end
				end
			})
		else
			self:EnterDeathRollPhase("Roll")
		end
	elseif p == "Roll" then
		self:StopMoving()
		self._isRolling = true
		self._deathRollAngle = 0
		self:PlayAnimation("BiteDeathRoll")
		self:PlaySound("Snap", true)
		task.delay(1.5, function()
			local v2

			if self.activeMood == "DeathRoll" then
				v2 = self.deathRollPhaseGen == deathRollPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterDeathRollPhase("Return")
			end
		end)
	elseif p == "Return" then
		self._isRolling = false
		companion.MoodRotationTilt = nil
		self:MoveTo(self.deathRollOrigin, {
			speed = 10,
			animation = self:GetWalkAnimation(),
			arriveRadius = 1.5,
			onArrive = function()
				local v2

				if self.activeMood == "DeathRoll" then
					v2 = self.deathRollPhaseGen == deathRollPhaseGen
				else
					v2 = false
				end

				if v2 then
					self:EnterDeathRollPhase("Settle")
				end
			end
		})
	elseif p == "Settle" then
		self:StopMoving()
		companion.MoodUninterruptible = false
		self._deathRollEnded = true
	end
end

function GaryGator:CleanupDeathRoll()
	self._isRolling = false
	local companion = self.companion
	companion.MoodRotationTilt = nil
	companion.MoodUninterruptible = false
	self:StopMoving()
end

function GaryGator:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return GaryGator