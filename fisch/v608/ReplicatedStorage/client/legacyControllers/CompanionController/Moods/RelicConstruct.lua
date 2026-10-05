local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local Signal = require(ReplicatedStorage.packages.Signal)
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
require(ReplicatedStorage.shared.utils.assets)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local InventoryController = require(ReplicatedStorage.client.legacyControllers.InventoryController)
local remoteEvent = Net:RemoteEvent("RelicConstruct/ConsumeRelic")
local v = {
	Hug = {
		Chance = 2,
		Interval = 10
	},
	Wander = {
		Chance = 40,
		Interval = 15
	},
	Sleep = {
		Chance = 30,
		Interval = 18
	}
}
local v2 = CFrame.new(1.396, -2.489, -0.071) * CFrame.fromOrientation(0, 1.5707963267948966, 0)
local color = Color3.fromRGB(255, 255, 255)
local RelicConstruct = {}
RelicConstruct.__index = RelicConstruct
setmetatable(RelicConstruct, CompanionBehavior)

function RelicConstruct.new(p)
	local v3 = CompanionBehavior.new(p)
	setmetatable(v3, RelicConstruct)
	v3.StateDataChanged = Signal.new()
	v3:RegisterMoods(v)
	v3.moodStartTime = 0
	v3.idleTimer = 0
	v3.hugPhaseGen = 0
	v3._hugEnded = false
	v3.roamPhaseGen = 0
	v3.roamSpots = {}
	v3.roamSpotIndex = 0
	v3.roamNapSpot = nil
	v3.roamShouldNap = false
	v3._roamEnded = false
	v3.divePhaseGen = 0
	v3.diveOrigin = createVector(0, 0, 0)
	v3.diveFishName = nil
	v3.diveMutation = nil
	v3._diveEnded = false
	v3:SetupPrompt()
	v3:SetupChangeVFX()
	v3:UpdateModel()
	return v3
end

function RelicConstruct:GetWalkAnimation()
	local humanoidRootPart = self.companion.Owner and self.companion.Owner.Character and self.companion.Owner.Character:FindFirstChild("HumanoidRootPart")
	local rootPart = self.companion.RootPart

	if humanoidRootPart and rootPart and (humanoidRootPart.Position - rootPart.Position).Magnitude > 32 then
		return "Run"
	end

	return "Walk"
end

function RelicConstruct:GetFrontOfCharacterPosition()
	local character = self.companion.Owner.Character

	if not character then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return (humanoidRootPart.CFrame * v2).Position
	end

	return nil
end

function RelicConstruct:Update(p: number)
	if self.activeMood then
		return nil
	end

	local state = self.companion.State

	if state == "Walking" or state == "Jumping" then
		self.idleTimer = 0
		return nil
	end

	self.idleTimer += p

	if self.idleTimer >= 300 then
		self.idleTimer = 0
		return "IdleSleep"
	end

	local rollMoods = self:RollMoods(p)

	if not rollMoods then
		return nil
	end

	self.idleTimer = 0
	return rollMoods
end

function RelicConstruct:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._hugEnded = false
	self._roamEnded = false
	self._diveEnded = false

	if activeMood == "Hug" then
		self:StartHug()
	elseif activeMood == "Wander" then
		self:StartRoam(p, false)
	elseif activeMood == "Sleep" then
		self:StartRoam(p, true)
	elseif activeMood == "IdleSleep" then
		self:StartIdleSleep()
	elseif activeMood == "Dive" then
		self:StartDive(p)
	end
end

function RelicConstruct:UpdateMood(p: number)
	self:_TickMovement(p)

	if self._hugEnded or self._roamEnded or self._diveEnded then
		return true
	end

	return false
end

function RelicConstruct:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Hug" then
		self:CleanupHug()
	elseif self.activeMood == "Wander" or self.activeMood == "Sleep" then
		self:CleanupRoam()
	elseif self.activeMood == "IdleSleep" then
		self:CleanupIdleSleep()
	elseif self.activeMood == "Dive" then
		self:CleanupDive()
	end

	self.activeMood = nil
end

function RelicConstruct:RequestInterrupt()
	self.idleTimer = 0
	CompanionBehavior.RequestInterrupt(self)
end

function RelicConstruct:StartHug()
	self:SetState("MoodAction")
	self:EnterHugPhase("RunToPlayer")
	self.companion.MoodUninterruptible = true
end

function RelicConstruct:EnterHugPhase(p: string)
	self.hugPhaseGen += 1
	local hugPhaseGen = self.hugPhaseGen

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stillValid()
		return self.activeMood == "Hug" and self.hugPhaseGen == hugPhaseGen
	end

	if p == "RunToPlayer" then
		self:MoveTo(createVector(0, 0, 0), {
			speed = 10,
			animation = "Walk",
			arriveRadius = 0.5,
			trackFn = function()
				return self:GetFrontOfCharacterPosition()
			end,
			onArrive = function()
				local v3

				if self.activeMood == "Hug" then
					v3 = self.hugPhaseGen == hugPhaseGen
				else
					v3 = false
				end

				if v3 then
					self:EnterHugPhase("PlayHugAnim")
				end
			end
		})
	elseif p == "PlayHugAnim" then
		self:SetFaceOwner(true)
		local v3 = true
		local character

		if self.companion.IsOwner then
			character = self.companion.Owner.Character

			if not (character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid")) then
				return
			end

			character:SetAttribute("RelicConstructHug", 0)
		else
			character = nil
		end

		self:MoveTo(createVector(0, 0, 0), {
			speed = 100,
			animation = "Hug",
			arriveRadius = 0.5,
			arriveCondition = function()
				local v4 = not v3
				return v4 or not stillValid()
			end,
			trackFn = function()
				return self:GetFrontOfCharacterPosition()
			end,
			onArrive = function()
				self:StopMoving()
			end
		})
		task.delay(2, function()
			v3 = false

			if character then
				character:SetAttribute("RelicConstructHug", nil)
			end

			local v4

			if self.activeMood == "Hug" then
				v4 = self.hugPhaseGen == hugPhaseGen
			else
				v4 = false
			end

			if v4 then
				self:EnterHugPhase("WalkAway")
			end
		end)
	elseif p == "WalkAway" then
		self:SetFaceOwner(false)
		local character = self.companion.Owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local v3 = humanoidRootPart.CFrame.RightVector * (math.random() > 0.5 and 1 or -1)
			self:MoveTo(self.companion.RootPart.Position + v3 * 5, {
				speed = 5,
				animation = "Walk",
				arriveRadius = 1.5,
				onArrive = function()
					local v4

					if self.activeMood == "Hug" then
						v4 = self.hugPhaseGen == hugPhaseGen
					else
						v4 = false
					end

					if v4 then
						self._hugEnded = true
					end
				end
			})
		else
			self._hugEnded = true
		end
	end
end

function RelicConstruct:CleanupHug()
	self:StopMoving()
	self:SetFaceOwner(false)
	self.companion.MoodUninterruptible = false
end

function RelicConstruct:StartIdleSleep()
	self:SetState("Sleeping")
	self:PlayAnimation("SleepIdle")
	self:SetParticles("Sleep/Particle", true)
	self:PlaySound("Snore")
end

function RelicConstruct:CleanupIdleSleep()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self:PlaySound("Meow", true)
end

function RelicConstruct:StartRoam(p, roamShouldNap: boolean)
	self:SetState("MoodAction")
	self.roamSpots = p.WanderSpots or {}
	self.roamNapSpot = p.NapSpot
	self.roamSpotIndex = 0
	self.roamShouldNap = roamShouldNap
	self:EnterRoamPhase("WalkToNextSpot")
end

function RelicConstruct:EnterRoamPhase(p: string)
	self.roamPhaseGen += 1
	local roamPhaseGen = self.roamPhaseGen

	local function stillValid()
		return (self.activeMood == "Wander" or self.activeMood == "Sleep") and self.roamPhaseGen == roamPhaseGen
	end

	if p == "WalkToNextSpot" then
		self.roamSpotIndex += 1

		if not (self.roamSpotIndex > #self.roamSpots) then
			self:MoveTo(self.roamSpots[self.roamSpotIndex], {
				speed = 5,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v3

					if self.activeMood == "Wander" or self.activeMood == "Sleep" then
						v3 = self.roamPhaseGen == roamPhaseGen
					else
						v3 = false
					end

					if v3 then
						self:EnterRoamPhase("PauseAtSpot")
					end
				end
			})
		elseif self.roamShouldNap then
			self:EnterRoamPhase("WalkToNapSpot")
		else
			self._roamEnded = true
		end
	elseif p == "PauseAtSpot" then
		self:StopMoving()
		self:PlayAnimation("SitIdle")
		local v3 = 0.6 + math.random() * 1.6
		task.delay(v3, function()
			local v4

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v4 = self.roamPhaseGen == roamPhaseGen
			else
				v4 = false
			end

			if v4 then
				self:EnterRoamPhase("WalkToNextSpot")
			end
		end)
	elseif p == "WalkToNapSpot" then
		if self.roamNapSpot then
			self:MoveTo(self.roamNapSpot, {
				speed = 5,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v3

					if self.activeMood == "Wander" or self.activeMood == "Sleep" then
						v3 = self.roamPhaseGen == roamPhaseGen
					else
						v3 = false
					end

					if v3 then
						self:EnterRoamPhase("SitAtNapSpot")
					end
				end
			})
		else
			self._roamEnded = true
		end
	elseif p == "SitAtNapSpot" then
		self:StopMoving()
		self:PlayAnimation("SitIdle")
		local v3 = 1.2 + math.random() * 1.3
		task.delay(v3, function()
			local v4

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v4 = self.roamPhaseGen == roamPhaseGen
			else
				v4 = false
			end

			if v4 then
				self:EnterRoamPhase("Nap")
			end
		end)
	elseif p == "Nap" then
		self:StopMoving()
		self:SetState("Sleeping")
		self:PlayAnimation("SleepIdle")
		self:SetParticles("Sleep/Particle", true)
		self:PlaySound("Snore")
		task.delay(45, function()
			local v3

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v3 = self.roamPhaseGen == roamPhaseGen
			else
				v3 = false
			end

			if v3 then
				self._roamEnded = true
			end
		end)
	end
end

function RelicConstruct:CleanupRoam()
	self:StopMoving()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self.roamSpots = {}
	self.roamNapSpot = nil
	self.roamSpotIndex = 0
	self.roamShouldNap = false
	self._roamEnded = false
end

function RelicConstruct:SetupPrompt()
	local rootPart = self.companion.RootPart

	if not (rootPart and self.companion.IsOwner) then
		return
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.F
	proximityPrompt.ActionText = "Give Relic"
	proximityPrompt.ObjectText = self.companion.DisplayName or "Relic Construct"
	proximityPrompt.MaxActivationDistance = 12
	proximityPrompt.HoldDuration = 2
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = rootPart
	self.trove:Add(proximityPrompt)
	self.trove:Connect(proximityPrompt.Triggered, function()
		remoteEvent:FireServer()
	end)

	local function update(equippedTool, equippedItem)
		if (equippedTool or self.companion.StateData and self.companion.StateData.Color1 ~= color) and not (equippedItem and fish[equippedItem.name] and fish[equippedItem.name].RelicGroup) then
			proximityPrompt.Enabled = false
			return
		end

		proximityPrompt.ObjectText = self.companion.DisplayName or "Relic Construct"
		proximityPrompt.ActionText = `Give {equippedItem and equippedItem.name or "Relic"}`
		proximityPrompt.Enabled = true
	end

	self.trove:Connect(InventoryController.EquippedToolChanged, update)
	update(InventoryController.EquippedTool, InventoryController.EquippedItem)
	self.trove:Add(self.StateDataChanged:Connect(function()
		update(InventoryController.EquippedTool, InventoryController.EquippedItem)
	end))
end

function RelicConstruct:SetupChangeVFX()
	self.trove:Add(remoteEvent.OnClientEvent:Connect(function(p2, p3)
		if self.companion.Owner ~= p2 or not self.companion.Model then
			return
		end

		for _, v3 in self.companion.Model:QueryDescendants("ParticleEmitter.RelicBuffChange") do
			v3.Color = ColorSequence.new(p3)
			v3:Emit(v3:GetAttribute("EmitCount") or v3.Rate)
		end
	end))
end

function RelicConstruct:UpdateModel()
	if not self.companion.Model then
		print("cant update whit no model!!!!!!!")
		return
	end

	local color1 = self.companion.StateData and self.companion.StateData.Color1 or color
	local color2 = self.companion.StateData and self.companion.StateData.Color2 or color
	local v3

	if color1 == color then
		v3 = Color3.fromRGB(80, 80, 80)
	else
		v3 = color1
	end

	local colorSequence = ColorSequence.new(v3)
	local v4

	if color2 == color then
		v4 = Color3.fromRGB(80, 80, 80)
	else
		v4 = color2
	end

	local colorSequence2 = ColorSequence.new(v4)

	for _, instance in self.companion.Model:QueryDescendants(".RelicBuffRecolor") do
		if instance:IsA("BasePart") then
			instance.Color = color1
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
			instance.Color = colorSequence
		end
	end

	for _, instance in self.companion.Model:QueryDescendants(".RelicBuffRecolor2") do
		if instance:IsA("BasePart") then
			instance.Color = color2
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
			instance.Color = colorSequence2
		end
	end
end

function RelicConstruct:SetStateData(p)
	self:UpdateModel()
	self.StateDataChanged:FireDeferred(p)
end

function RelicConstruct:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return RelicConstruct