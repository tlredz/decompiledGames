local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local clientdialog = ReplicatedStorage.events.clientdialog
local v = {
	ShoutRarity = {
		Chance = 0,
		Interval = 1e999
	},
	ShoutGold = {
		Chance = 0,
		Interval = 1e999
	},
	Dance = {
		Chance = 0,
		Interval = 1e999
	},
	FlyToChest = {
		Chance = 0,
		Interval = 1e999
	}
}
local v2 = {
	Fly = 0.7,
	Grounded = 0.25,
	Perch = 0.05
}
local v3 = {
	Fly = 0.3,
	Grounded = 0.3,
	Perch = 0.4
}
local _ = {
	Common = "Common",
	Uncommon = "Uncommon",
	Unusual = "Unusual",
	Rare = "Rare",
	Legendary = "Legendary",
	Mythical = "Mythical",
	Exotic = "Exotic",
	Secret = "Secret"
}
local Plunderbeak = {}
Plunderbeak.__index = Plunderbeak
setmetatable(Plunderbeak, CompanionBehavior)

function Plunderbeak.new(p)
	local v4 = CompanionBehavior.new(p)
	setmetatable(v4, Plunderbeak)
	v4:RegisterMoods(v)
	v4.ambientMode = "Grounded"
	v4.ambientSwapTimer = 0
	v4.ambientSwapDuration = 6
	v4.perchSide = "right"
	v4._lastAmbientTarget = nil
	v4._lastOwnerPos = nil
	v4._perchWeld = nil
	v4._perchWalkTimer = 0
	v4.ambientSquawkTimer = 0
	v4.ambientSquawkDuration = math.random(120, 355)
	v4.shoutPhaseGen = 0
	v4._shoutEnded = false
	v4.dancePhaseGen = 0
	v4._danceEnded = false
	v4.danceVocalThread = nil
	v4.chestScanTimer = 0
	v4.chestPhaseGen = 0
	v4._chestEnded = false
	v4.chestTargetPart = nil
	v4.chestCooldowns = {}
	v4.companion.AlwaysTickUpdate = true
	v4:_ApplyAmbientMode(false)
	v4.trove:Connect(RunService.Heartbeat, function(p2)
		if v4.activeMood then
			return
		end

		v4:_TickAmbient(p2)
	end)
	v4.trove:Add(function()
		v4:_DetachPerch()
	end)
	return v4
end

function Plunderbeak:_HasAnim(p2: string)
	return self.companion.Animations and self.companion.Animations[p2] ~= nil
end

function Plunderbeak:_PlayIfExists(p: string)
	if self:_HasAnim(p) then
		self:PlayAnimation(p)
	end
end

function Plunderbeak:_PlayAnimIfDifferent(p: string)
	if not self:_HasAnim(p) then
		return
	end

	local animation = self.companion.Animations[p]

	if self.companion.CurrentAnimation ~= animation then
		self:PlayAnimation(p)
	end
end

function Plunderbeak:_GetOwnerHRP()
	local character = self.companion.Owner.Character

	if character then
		return (character:FindFirstChild("HumanoidRootPart"))
	end

	return nil
end

function Plunderbeak:_GetOwnerHumanoid()
	local character = self.companion.Owner.Character

	if character then
		return character:FindFirstChildOfClass("Humanoid")
	end

	return nil
end

function Plunderbeak:_OwnerIsMoving()
	local _GetOwnerHumanoid = self:_GetOwnerHumanoid()

	if _GetOwnerHumanoid then
		return _GetOwnerHumanoid.MoveDirection.Magnitude > 0.1
	end

	return false
end

function Plunderbeak:_GetOwnerSpeed()
	local _GetOwnerHumanoid = self:_GetOwnerHumanoid()

	if _GetOwnerHumanoid then
		return _GetOwnerHumanoid.WalkSpeed * _GetOwnerHumanoid.MoveDirection.Magnitude
	end

	return 0
end

function Plunderbeak:_OwnerMovedSignificantly()
	local _GetOwnerHRP = self:_GetOwnerHRP()

	if not _GetOwnerHRP then
		return false
	end

	local position = _GetOwnerHRP.Position
	local _lastOwnerPos = self._lastOwnerPos

	if not _lastOwnerPos then
		self._lastOwnerPos = position
		return true
	end

	if (position - _lastOwnerPos).Magnitude >= 0.15 then
		self._lastOwnerPos = position
		return true
	else
		return false
	end
end

function Plunderbeak:_PickRandomSide()
	if math.random() < 0.5 then
		return "left"
	end

	return "right"
end

function Plunderbeak:_WeightedPick(items)
	local total = 0

	for _, item in items do
		total += item
	end

	local v4 = math.random() * total
	local total2 = 0

	for k, item in items do
		total2 += item

		if v4 <= total2 then
			return k
		end
	end

	return "Fly"
end

function Plunderbeak:_SetAmbientTarget(vector2: Vector3, moodSmoothTime: number)
	self._lastAmbientTarget = vector2
	self.companion.MoodPositionOverride = vector2
	self.companion.MoodSmoothTime = moodSmoothTime
end

function Plunderbeak:_GetGroundedPosition()
	local _GetOwnerHRP = self:_GetOwnerHRP()

	if not _GetOwnerHRP then
		return nil
	end

	local v4 = _GetOwnerHRP.CFrame.LookVector * -4
	local v5 = self.perchSide == "left" and -1 or 1
	local v6 = _GetOwnerHRP.CFrame.RightVector * (v5 * 3)
	local v7 = _GetOwnerHRP.Position + v4 + v6
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { self.companion.Model, self.companion.Owner.Character }
	raycastParams.IgnoreWater = false
	raycastParams.RespectCanCollide = true
	local raycastResult = workspace:Raycast(v7 + createVector(0, 10, 0), createVector(0, -50, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position + createVector(0, 1, 0)
	end

	return nil
end

function Plunderbeak:_Say(text: string)
	local v4 = {
		locked = false,
		npc = self.companion.Model,
		dialog = {
			{
				text = text,
				t = 0.1
			}
		}
	}
	clientdialog:Fire(v4, self.companion.RootPart, {
		dialog = v4.dialog
	}, nil, true)
end

function Plunderbeak:_AttachPerch()
	self:_DetachPerch()
	local _GetOwnerHRP = self:_GetOwnerHRP()
	local rootPart = self.companion.RootPart

	if not (_GetOwnerHRP and rootPart) then
		return
	end

	local vector2 = Vector3.new(1.2 * (self.perchSide == "left" and -1 or 1), 1.6, 0)
	local modelOffset = self.companion.ModelOffset or createVector(0, 0, 0)
	local attachment = Instance.new("Attachment")
	attachment.Name = "PerchA0"
	attachment.Parent = rootPart
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "PerchA1"
	attachment2.Position = vector2 - modelOffset
	attachment2.Parent = _GetOwnerHRP
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = attachment
	alignPosition.Attachment1 = attachment2
	alignPosition.RigidityEnabled = false
	alignPosition.MaxForce = 50000
	alignPosition.MaxVelocity = 1e999
	alignPosition.Responsiveness = 35
	alignPosition.Parent = rootPart
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = attachment
	alignOrientation.Attachment1 = attachment2
	alignOrientation.RigidityEnabled = false
	alignOrientation.MaxTorque = 50000
	alignOrientation.MaxAngularVelocity = 1e999
	alignOrientation.Responsiveness = 35
	alignOrientation.Parent = rootPart
	self.companion.SuppressPositionUpdates = true
	rootPart.Anchored = false
	self._perchWeld = {
		attachment,
		attachment2,
		alignPosition,
		alignOrientation
	}
end

function Plunderbeak:_DetachPerch()
	self.companion.SuppressPositionUpdates = false

	if self._perchWeld then
		for _, v4 in self._perchWeld do
			v4:Destroy()
		end

		self._perchWeld = nil
	end

	local rootPart = self.companion.RootPart

	if rootPart then
		rootPart.Anchored = true
	end
end

function Plunderbeak:Update(p: number)
	if self.activeMood then
		return nil
	end

	self.ambientSquawkTimer += p

	if self.ambientSquawkTimer >= self.ambientSquawkDuration then
		self.ambientSquawkTimer = 0
		self.ambientSquawkDuration = math.random(120, 355)
		self:PlaySound("Squawk" .. math.random(1, 3), true)
		self:_Say("SQUAWK!")
	end

	self.chestScanTimer += p

	if self.chestScanTimer >= 2 then
		self.chestScanTimer = 0
		local _FindNearbyChest = self:_FindNearbyChest()

		if _FindNearbyChest then
			self.chestTargetPart = _FindNearbyChest
			return "FlyToChest"
		end
	end

	return nil
end

function Plunderbeak:StartMood(activeMood: string, p)
	self.companion.MoodUninterruptible = false
	self.activeMood = activeMood
	self._shoutEnded = false
	self._danceEnded = false
	self._chestEnded = false

	if self.ambientMode == "Perch" then
		self:_DetachPerch()
	end

	if activeMood == "ShoutRarity" then
		self:StartShout(p, false)
	elseif activeMood == "ShoutGold" then
		self:StartShout(p, true)
	elseif activeMood == "Dance" then
		self:StartDance()
	elseif activeMood == "FlyToChest" then
		self:StartFlyToChest()
	end
end

function Plunderbeak:UpdateMood(p: number)
	self:_TickMovement(p)

	if self._shoutEnded or self._danceEnded or self._chestEnded then
		return true
	end

	return false
end

function Plunderbeak:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "ShoutRarity" or self.activeMood == "ShoutGold" then
		self:CleanupShout()
	elseif self.activeMood == "Dance" then
		self:CleanupDance()
	elseif self.activeMood == "FlyToChest" then
		self:CleanupFlyToChest()
	end

	self.activeMood = nil
	self._lastAmbientTarget = nil
	self._lastOwnerPos = nil
	self:_ApplyAmbientMode(true)
end

function Plunderbeak:_TickAmbient(p: number)
	self.ambientSwapTimer += p

	if self.ambientSwapTimer >= self.ambientSwapDuration then
		self:_SwapAmbient()
	end

	local _OwnerMovedSignificantly = self:_OwnerMovedSignificantly()

	if self.ambientMode == "Fly" then
		local v4 = (_OwnerMovedSignificantly or not self._lastAmbientTarget) and self:_GetOwnerHRP()

		if v4 then
			local followOffset = self.companion.FollowOffset or createVector(-4, 2, 0)
			self:_SetAmbientTarget(
				v4.Position + Vector3.new(followOffset.X, math.max(followOffset.Y, 3), followOffset.Z),
				0.15
			)
		end

		self:_PlayAnimIfDifferent(self:_OwnerIsMoving() and self:_HasAnim("FlyFast") and "FlyFast" or "Fly")
	elseif self.ambientMode == "Grounded" then
		local v4 = (_OwnerMovedSignificantly or not self._lastAmbientTarget) and self:_GetGroundedPosition()

		if v4 then
			self:_SetAmbientTarget(v4, 0.35)
		end

		local _GetOwnerSpeed = self:_GetOwnerSpeed()
		local v5

		if _GetOwnerSpeed > 8 then
			v5 = self:_HasAnim("Run") and "Run" or "Walk"
		else
			v5 = _GetOwnerSpeed > 2 and "Walk" or "Idle"
		end

		self:_PlayAnimIfDifferent(v5)
	elseif self.ambientMode == "Perch" then
		if self:_OwnerIsMoving() then
			self._perchWalkTimer += p

			if self._perchWalkTimer >= 2.5 then
				self:_SwapAmbient()
				return
			end
		else
			self._perchWalkTimer = 0
		end

		self:_PlayAnimIfDifferent("Perch")
	end
end

function Plunderbeak:_SwapAmbient()
	if self._lastAmbientTarget and self.ambientMode ~= "Perch" and (self.companion.RootPart.Position - self._lastAmbientTarget).Magnitude > 3 then
		return
	end

	self.ambientSwapTimer = 0
	self.ambientSwapDuration = math.random() * 8 + 6
	local v4

	if self:_OwnerIsMoving() then
		v4 = v2
	else
		v4 = v3
	end

	local _WeightedPick = self:_WeightedPick(v4)
	local ambientMode = _WeightedPick == "Perch" and self.ambientMode == "Perch" and "Fly" or _WeightedPick

	if ambientMode == "Perch" then
		self.perchSide = self:_PickRandomSide()
	end

	if ambientMode == self.ambientMode then
		return
	end

	if self.ambientMode == "Perch" then
		self:_DetachPerch()
	end

	self.ambientMode = ambientMode
	self._perchWalkTimer = 0
	self._lastAmbientTarget = nil
	self._lastOwnerPos = nil
	self:_ApplyAmbientMode(false)
end

function Plunderbeak:_ApplyAmbientMode(_: boolean)
	self.companion.MoodIgnoreGroundClamp = self.ambientMode == "Fly" or self.ambientMode == "Perch"

	if self.ambientMode == "Fly" then
		self:_PlayIfExists(self:_OwnerIsMoving() and self:_HasAnim("FlyFast") and "FlyFast" or "Fly")
	elseif self.ambientMode == "Grounded" then
		self:_PlayIfExists("Idle")
	elseif self.ambientMode == "Perch" then
		self:_PlayIfExists("Perch")
		self:_AttachPerch()
	end
end

function Plunderbeak:StartShout(p, flag: boolean)
	self:SetState("MoodAction")
	self:SetFaceOwner(true)
	self:_PlayIfExists("Squawk")
	self:PlaySound("Squawk" .. math.random(1, 3), true)

	if flag then
		self:_Say("GOLD!")
	elseif p.Rarity then
		self:_Say((`{string.upper(p.Rarity)}!`))
	end

	self.shoutPhaseGen += 1
	local shoutPhaseGen = self.shoutPhaseGen
	task.delay(1.6, function()
		if self.activeMood and (self.activeMood == "ShoutRarity" or self.activeMood == "ShoutGold") and self.shoutPhaseGen == shoutPhaseGen then
			self._shoutEnded = true
		end
	end)
end

function Plunderbeak:CleanupShout()
	self:SetFaceOwner(false)
end

function Plunderbeak:StartDance()
	self:SetState("MoodAction")
	self:SetFaceOwner(true)
	self:_PlayIfExists("Happy")
	self.dancePhaseGen += 1
	local dancePhaseGen = self.dancePhaseGen
	self.danceVocalThread = task.spawn(function()
		while self.activeMood == "Dance" and self.dancePhaseGen == dancePhaseGen do
			local v4 = math.random() * 0.7000000000000001 + 0.9
			task.wait(v4)

			if self.activeMood ~= "Dance" or self.dancePhaseGen ~= dancePhaseGen then
				break
			end

			self:PlaySound("Squawk" .. math.random(1, 3), true)
			self:_Say("I Feel a Song Coming On!")
		end
	end)
	task.delay(4.5, function()
		if self.activeMood == "Dance" and self.dancePhaseGen == dancePhaseGen then
			self._danceEnded = true
		end
	end)
end

function Plunderbeak:CleanupDance()
	self:SetFaceOwner(false)
	self.danceVocalThread = nil
end

function Plunderbeak:_FindNearbyChest()
	local _GetOwnerHRP = self:_GetOwnerHRP()

	if not _GetOwnerHRP then
		return nil
	end

	local now = tick()

	for k, chestCooldown in self.chestCooldowns do
		if chestCooldown <= now or not k.Parent then
			self.chestCooldowns[k] = nil
		end
	end

	local v4 = 80
	local v5 = nil

	for _, instance in CollectionService:GetTagged("TreasureChest") do
		local primaryPart = nil

		if instance:IsA("BasePart") then
			primaryPart = instance
		elseif instance:IsA("Model") then
			primaryPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
		end

		if not primaryPart or self.chestCooldowns[primaryPart] then
			continue
		end

		local magnitude = (primaryPart.Position - _GetOwnerHRP.Position).Magnitude

		if not (magnitude < v4) then
			continue
		end

		v5 = primaryPart
		v4 = magnitude
	end

	return v5
end

function Plunderbeak:StartFlyToChest()
	self:SetState("MoodAction")
	self.companion.MoodUninterruptible = true
	self.companion.MoodIgnoreGroundClamp = true
	self:_PlayIfExists("FlyFast")
	self.chestPhaseGen += 1
	local chestPhaseGen = self.chestPhaseGen
	local chestTargetPart = self.chestTargetPart

	local function stillValid()
		return self.activeMood == "FlyToChest" and self.chestPhaseGen == chestPhaseGen
	end

	if chestTargetPart and chestTargetPart.Parent then
		self.chestCooldowns[chestTargetPart] = tick() + 15
		self:MoveTo(chestTargetPart.Position + createVector(0, 6, 0), {
			speed = 28,
			animation = self:_HasAnim("FlyFast") and "FlyFast" or "Fly",
			arriveRadius = 4,
			freeYMovement = true,
			smoothTime = 0.15,
			trackFn = function()
				if chestTargetPart and chestTargetPart.Parent then
					return chestTargetPart.Position + createVector(0, 6, 0)
				end

				return nil
			end,
			onArrive = function()
				local v4

				if self.activeMood == "FlyToChest" then
					v4 = self.chestPhaseGen == chestPhaseGen
				else
					v4 = false
				end

				if not v4 then
					return
				end

				self:_PlayIfExists("Fly")
				self:PlaySound("Squawk" .. math.random(1, 3), true)
				task.delay(4, function()
					local v5

					if self.activeMood == "FlyToChest" then
						v5 = self.chestPhaseGen == chestPhaseGen
					else
						v5 = false
					end

					if v5 then
						self._chestEnded = true
					end
				end)
			end
		})
	else
		self._chestEnded = true
	end
end

function Plunderbeak:CleanupFlyToChest()
	self:StopMoving()
	self.chestTargetPart = nil
end

function Plunderbeak:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	self:_DetachPerch()
	CompanionBehavior.Destroy(self)
end

return Plunderbeak