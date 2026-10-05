local createVector = vector.create
game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local events = ReplicatedStorage.events
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local GeneralUtils = require(shared.utils.GeneralUtils)
local Monetization = require(shared.Monetization)
local Net = require(packages.Net)
local Signal = require(packages.Signal)
local SimplePath = require(packages.SimplePath)
local Trove = require(packages.Trove)
local remoteEvent = Net:RemoteEvent("FollowingNpcDebug", -1)
local FollowingNpcController = {
	currentNpcData = {},
	Status = {
		Following = "Following",
		Seated = "Seated",
		Spawning = "Spawning",
		Walking = "Walking",
		Idle = "Idle"
	}
}
local v = {
	Stuck = {
		chance = 40,
		dialogues = {
			"Bro, I got stuck on something...",
			"I think I stumbled upon something!",
			"I could barely see the ground!",
			"I almost fell here haha"
		}
	},
	OutOfReach = {
		chance = 40,
		dialogues = {
			"Bro, you walk so fast!",
			"Wow, you walk so fast! Wait for me...",
			"I had lost you!",
			"You disappeared from my sight..."
		}
	},
	Seat = {
		chance = 50,
		dialogues = {
			"Aren't you afraid of falling off this boat?",
			"Is this boat safe?",
			"Can you guarantee me that this boat won't sink?",
			"If I fall into the sea, will you help me?"
		}
	},
	BoatSeating = {
		chance = 20,
		dialogues = {
			"The waves are amazing today! Don't you think?",
			"The ocean breeze is the best thing in the world!",
			"Have you ever stopped to think about how much water there is in the ocean?",
			"The sound of the ocean is so relaxing, don’t you think?"
		}
	},
	NonBoatSeat = {
		chance = 5,
		dialogues = {
			"Are you seriously going to stop and rest now?",
			"Don't we have to go somewhere now?",
			"I'm not going to sit there! Come on, we have to go!",
			"Aren't you forgetting anything?..."
		}
	}
}

function FollowingNpcController:New(childName, customPathProperties, options)
	local child = script.Npcs:FindFirstChild(childName)

	if not child or self.currentNpcData[childName] then
		return
	end

	local object = setmetatable({
		_trove = Trove.new(),
		destroyed = false,
		npcName = childName,
		npcModel = child,
		npcStatus = "Following",
		customPathProperties = customPathProperties,
		customBehavior = options or {},
		focused = false,
		customTarget = nil,
		customMinDistance = nil,
		instances = {},
		OnSpawned = Signal.new(),
		OnTeleported = Signal.new(),
		lastSpawnTime = os.time(),
		stuckCount = 0
	}, {
		__index = FollowingNpcController
	})
	self.currentNpcData[childName] = object
	object:Construct()
	return object
end

function FollowingNpcController:Destroy()
	self.currentNpcData[self.npcName] = nil
	self.destroyed = true
	self._trove:Destroy()
end

function FollowingNpcController:Construct()
	local function setUpCharacter(character)
		if not character then
			return
		end

		if character then
			character:WaitForChild("HumanoidRootPart")
		end

		local humanoid = character:WaitForChild("Humanoid")

		if humanoid.Health <= 0 then
			return
		end

		self:Spawn()
		self._trove:Connect(humanoid.Died, function()
			if self._currentTrove then
				self._trove:Remove(self._currentTrove)
			end
		end)
	end

	setUpCharacter(localPlayer.Character or localPlayer.CharacterAdded:Wait())
	self._trove:Connect(localPlayer.CharacterAdded, setUpCharacter)
end

function FollowingNpcController:GetPosition()
	local humanoidRootPart = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):FindFirstChild("HumanoidRootPart")
	return self.customTarget and (typeof(self.customTarget) == "Instance" and self.customTarget:IsA("PVInstance") and self.customTarget:GetPivot().Position or typeof(self.customTarget) == "CFrame" and self.customTarget.Position) or humanoidRootPart:GetPivot().Position
end

function FollowingNpcController:LoadDialogue(childName, p, text)
	local currentNpc = self.currentNpc

	if not currentNpc or self.dialogueDebounce then
		return
	end

	local v2 = p or childName and v[childName]

	if not (v2 or text) then
		return
	end

	if not text then
		local customDialogues = currentNpc:FindFirstChild("CustomDialogues")
		local child = childName and customDialogues and customDialogues:FindFirstChild(childName)
		local chance = child and child:FindFirstChild("Chance")

		if math.random(1, 100) <= (chance and chance.Value or v2.chance) then
			local dialogues = child and child:FindFirstChild("Dialogues")

			if dialogues then
				local v3 = dialogues:GetChildren()[math.random(1, #dialogues:GetChildren())]

				if v3 then
					text = v3.Value
				end
			else
				text = v2.dialogues[math.random(1, #v2.dialogues)]
			end
		end
	end

	if text then
		self.dialogueDebounce = true
		local v3 = {
			npc = currentNpc
		}
		local description = currentNpc:FindFirstChild("description")

		if description then
			v3.voice = description.voice.Value
			v3.idle = description.idle
		else
			v3.voice = 1
			v3.idle = Instance.new("Animation")
			v3.idle.AnimationId = "rbxassetid://180435571"
			v3.idle.Parent = currentNpc
		end

		v3.dialog = {
			{
				text = text,
				t = 2,
				choices = {}
			}
		}
		events.clientdialog:Fire(v3, currentNpc:FindFirstChild("Head"), {
			dialog = v3.dialog
		})
		task.delay(3, function()
			self.dialogueDebounce = nil
		end)
	end
end

function FollowingNpcController:Seat(folder)
	local currentNpc = self.currentNpc

	if not currentNpc or self.npcStatus == FollowingNpcController.Status.Seated then
		return
	end

	local humanoidRootPart = currentNpc:WaitForChild("HumanoidRootPart")
	local humanoid = currentNpc:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	local _seatTrove = self._seatTrove

	if self._currentTrove and not self._seatTrove then
		self._seatTrove = self._currentTrove:Extend()
		_seatTrove = self._seatTrove
	end

	if not _seatTrove then
		return
	end

	self.npcStatus = FollowingNpcController.Status.Seated

	for _, part in currentNpc:GetChildren() do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = createVector(0, 0, 0)
		end
	end

	currentNpc:PivotTo(folder.CFrame + createVector(0, 3, 0))
	local v2 = _seatTrove:Add(Instance.new("Weld"))
	v2.Part0 = folder
	v2.Part1 = humanoidRootPart
	v2.C0 = CFrame.new(0, 0.05, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
	v2.C1 = CFrame.new(0, -1.5, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
	v2.Name = "SeatWeld"
	v2.Parent = humanoidRootPart
	humanoid.Sit = true
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
	_seatTrove:Add(function()
		self.customTarget = nil
		self.customMinDistance = nil
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)

		if humanoid.Sit then
			humanoid.Sit = false
		end

		if self.instances.seatAnimationTrack then
			self.instances.seatAnimationTrack:Destroy()
			self.instances.seatAnimationTrack = nil
		end
	end)

	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		local sitAnim = currentNpc:FindFirstChild("SitAnim", true)

		if sitAnim then
			self.instances.seatAnimationTrack = _seatTrove:Add(animator:LoadAnimation(sitAnim), "Stop")
			self.instances.seatAnimationTrack.Priority = Enum.AnimationPriority.Action4
			self.instances.seatAnimationTrack:Play()
		end
	else
		local animations = {}

		for _, animation in folder:GetDescendants() do
			if animation:IsA("Animation") then
				table.insert(animations, animation)
			end
		end

		if #animations > 0 then
			self.instances.seatAnimationTrack = _seatTrove:Add(
				animator:LoadAnimation(animations[math.random(1, #animations)]),
				"Stop"
			)
			self.instances.seatAnimationTrack:Play()
		end
	end

	self:LoadDialogue("Seat")
	local flag = true
	_seatTrove:Add(function()
		flag = false

		if self.instances.seatAnimationTrack then
			self.instances.seatAnimationTrack:Destroy()
			self.instances.seatAnimationTrack = nil
		end
	end)
	_seatTrove:Add(task.spawn(function()
		while flag do
			if self.customBehavior.SittingDialogueStatusTable then
				self:LoadDialogue(nil, self.customBehavior.SittingDialogueStatusTable)
			else
				self:LoadDialogue(self.customBehavior.SittingDialogueStatus or "BoatSeating")
			end

			task.wait(self.customBehavior.RandomDialogueSeatDelay or 20)
		end
	end))
end

function FollowingNpcController:Teleport(p, p2)
	local WAIT_INTERVAL = 0.25
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return
	end

	local currentNpc = self.currentNpc

	if not currentNpc or self.npcStatus == FollowingNpcController.Status.Seated and not self.customBehavior.GetUpAfterTeleport then
		return
	end

	if self.customBehavior.GetUpAfterTeleport and self._seatTrove and self._currentTrove then
		self._currentTrove:Remove(self._seatTrove)
		self.npcStatus = FollowingNpcController.Status.Following
		task.wait(WAIT_INTERVAL)
	end

	local humanoidRootPart2 = currentNpc:WaitForChild("HumanoidRootPart")
	local humanoid2 = currentNpc:WaitForChild("Humanoid")
	humanoid2:WaitForChild("Animator")

	if humanoid2 and humanoid2.Parent then
		if self._seatTrove and self._currentTrove then
			self._currentTrove:Remove(self._seatTrove)
		end

		local v2 = p2 or humanoidRootPart.CFrame * CFrame.new(5, 0, 5)
		currentNpc:PivotTo(v2)

		if p then
			self.npcStatus = FollowingNpcController.Status.Spawning
			humanoidRootPart2.Anchored = true
			GeneralUtils.scaleTween(currentNpc, TweenInfo.new(1, Enum.EasingStyle.Back), 1, nil, 0)
			task.wait(WAIT_INTERVAL)
			GeneralUtils.pivotTween(
				currentNpc,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				v2 * CFrame.new(0, 4, 0)
			)
			task.wait(WAIT_INTERVAL)
			GeneralUtils.pivotTween(currentNpc, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), v2)
			task.wait(0.5)
			humanoidRootPart2.Anchored = false
			self.npcStatus = FollowingNpcController.Status.Following
		end
	end
end

function FollowingNpcController:Spawn()
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return
	end

	if self._currentTrove then
		self._trove:Remove(self._currentTrove)
	end

	if self.path then
		self.path = nil
	end

	self._currentTrove = self._trove:Extend()

	if not self._currentTrove then
		return
	end

	local clone = self._currentTrove:Clone(self.npcModel)
	local humanoidRootPart2 = clone:WaitForChild("HumanoidRootPart")
	local humanoid2 = clone:WaitForChild("Humanoid")
	humanoid2:WaitForChild("Animator")
	humanoidRootPart2.PivotOffset = CFrame.new(0, 0, 0)
	clone.Parent = workspace
	self.currentNpc = clone
	local customPathProperties = self.customPathProperties or {}
	self:Teleport(
		not (customPathProperties and customPathProperties.doNotAnimateFirstTime),
		customPathProperties and customPathProperties.firstSpawn
	)

	if customPathProperties then
		customPathProperties.doNotAnimateFirstTime = nil
		customPathProperties.firstSpawn = nil
	end

	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = "FollowingNpc"
		end
	end

	self.OnSpawned:Fire(clone)
	local v2 = {
		AgentRadius = customPathProperties.AgentRadius or 2,
		AgentHeight = customPathProperties.AgentHeight or 5,
		AgentCanJump = customPathProperties.AgentCanJump or true,
		AgentCanClimb = customPathProperties.AgentCanClimb or true,
		Costs = customPathProperties.Costs or {
			Water = 10
		}
	}
	local v3 = SimplePath.new(clone, v2)
	v3.Visualize = Monetization.DEV_PLACE
	self.path = self._currentTrove:Add(v3, "Destroy")

	if self.customBehavior.SitWhenPlayerSeat ~= false then
		local function goToSeat()
			local seatPart = humanoid.SeatPart

			if not seatPart then
				return
			end

			local parent = seatPart.Parent

			if not parent or not parent.Parent or not parent.Parent.Parent or parent.Parent.Parent.Name ~= "boats" or not parent:FindFirstChildWhichIsA("Seat") then
				self:LoadDialogue("NonBoatSeat")
				return
			end

			local v4 = {}

			for _, seat in parent:GetChildren() do
				if seat:IsA("Seat") and seat ~= humanoid.SeatPart then
					table.insert(v4, {
						seat = seat,
						distance = (humanoidRootPart2.Position - seat.Position).Magnitude
					})
				end
			end

			table.sort(v4, function(a, b)
				return a.distance < b.distance
			end)
			local seat = v4[1] and v4[1].seat

			if not seat then
				return
			end

			self._seatTrove = self._currentTrove:Extend()

			if self.customBehavior.SitInstantly then
				self:Seat(seat)
			else
				self.customTarget = seat
				self.customMinDistance = 1
				os.time()
				self._currentTrove:Extend():Connect(RunService.RenderStepped, function(_: number)
					if (humanoidRootPart2.Position - seat.Position).Magnitude <= (self.customBehavior.SeatDistance or 5) and self.npcStatus ~= FollowingNpcController.Status.Seated then
						self:Seat(seat)
					end
				end)
			end
		end

		self._currentTrove:Connect(humanoid.Seated, function()
			if self._seatTrove then
				self._currentTrove:Remove(self._seatTrove)
			end

			if self.focused then
				return
			end

			if humanoid.SeatPart then
				goToSeat()
			else
				self.npcStatus = FollowingNpcController.Status.Following
			end
		end)
	end

	local flag = false
	v3.Error:Connect(function(p)
		if flag then
			return
		end

		if v3 and self.currentNpc == clone and v3.ErrorType then
			if p == v3.ErrorType.AgentStuck then
				if self.npcStatus ~= FollowingNpcController.Status.Seated and self.npcStatus ~= FollowingNpcController.Status.Spawning and self.npcStatus ~= FollowingNpcController.Status.Idle then
					pcall(function()
						v3:Run(self:GetPosition())
					end)
				end
			elseif (p == v3.ErrorType.ComputationError or p == v3.ErrorType.TargetUnreachable) and os.time() - self.lastSpawnTime > 3 then
				if self.stuckCount > 3 then
					self:Teleport(true)
					self.stuckCount = 0
					self:LoadDialogue("Stuck")
				else
					self.stuckCount += 1
				end

				pcall(function()
					v3:Run(self:GetPosition())
				end)
				self.lastSpawnTime = os.time()
				return
			end

			flag = true
			task.wait(0.5)
			flag = false
		end
	end)
	v3.WaypointReached:Connect(function()
		if v3 and self.currentNpc == clone and self.npcStatus ~= FollowingNpcController.Status.Seated and self.npcStatus ~= FollowingNpcController.Status.Spawning and self.npcStatus ~= FollowingNpcController.Status.Idle then
			pcall(function()
				v3:Run(self:GetPosition())
			end)
			self.stuckCount = 0
		end
	end)
	v3.Blocked:Connect(function()
		if v3 and self.currentNpc == clone then
			pcall(function()
				v3:Run(self:GetPosition())
			end)
		end
	end)
	v3.Reached:Connect(function()
		if v3 and self.currentNpc == clone and self.npcStatus ~= FollowingNpcController.Status.Seated and self.npcStatus ~= FollowingNpcController.Status.Spawning and self.npcStatus ~= FollowingNpcController.Status.Idle then
			pcall(function()
				v3:Run(self:GetPosition())
			end)
		end
	end)

	if self.npcStatus ~= FollowingNpcController.Status.Seated and self.npcStatus ~= FollowingNpcController.Status.Spawning and self.npcStatus ~= FollowingNpcController.Status.Idle then
		pcall(function()
			v3:Run(self:GetPosition())
		end)
	end

	self._currentTrove:Connect(clone.Destroying, function()
		if not self.destroyed then
			self:Spawn()
		end
	end)
	local v4 = false
	local total = 0
	self._currentTrove:Connect(RunService.RenderStepped, function(p: number)
		total += p

		if total < 0.3333333333333333 then
			return
		end

		total = 0
		local position = self:GetPosition()

		if not self.focused then
			position = humanoidRootPart.Position
		end

		local magnitude = (humanoidRootPart2.Position - position).Magnitude

		if humanoid2 and humanoid2:IsDescendantOf(clone) then
			humanoid2.WalkSpeed = v4 and 0 or math.clamp(magnitude / 1.25, 16, self.customBehavior.MaxSpeed or 64)
		end

		if magnitude > 124 and not self.focused then
			if self.npcStatus ~= FollowingNpcController.Status.Spawning then
				self:Teleport(true)
			end

			self:LoadDialogue("OutOfReach")

			if self.npcStatus ~= FollowingNpcController.Status.Seated and self.npcStatus ~= FollowingNpcController.Status.Spawning and self.npcStatus ~= FollowingNpcController.Status.Idle then
				pcall(function()
					v3:Run(self:GetPosition())
				end)
			end

			self.lastSpawnTime = os.time()
		elseif magnitude < (self.customMinDistance or 10) then
			v4 = true

			if v3.Status == v3.StatusType.Active then
				v3:Stop()
			end
		else
			v4 = false

			if v3.Status == v3.StatusType.Idle and self.npcStatus ~= FollowingNpcController.Status.Seated and self.npcStatus ~= FollowingNpcController.Status.Spawning and self.npcStatus ~= FollowingNpcController.Status.Idle then
				pcall(function()
					v3:Run(self:GetPosition())
				end)
			end
		end
	end)
	print((`Npc {self.npcName} spawned!`))
end

function FollowingNpcController:Start()
	remoteEvent.OnClientEvent:Connect(function(flag: boolean)
		if flag then
			self:New("NPCTest")
		elseif self.currentNpcData.NPCTest then
			self.currentNpcData.NPCTest:Destroy()
		end
	end)
end

return FollowingNpcController