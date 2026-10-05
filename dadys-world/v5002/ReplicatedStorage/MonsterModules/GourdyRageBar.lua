local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local v = nil
pcall(function()
	local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
	v = SoundGroupManager
end)
local GourdyRageBar = {}
GourdyRageBar.__index = GourdyRageBar
local v2 = {
	Spawning = { "Have new friends come to play-?", "Hello…? I hear someone!", "What was that noise-?" },
	ReceivingItem = {
		"Thank you! Thank you! Thank you!!!",
		"Yay! You're the best!!!",
		"I knew you didn't forget about me!",
		"For me?! YAY!!!",
		"Hehe, Thank you sooo much!"
	},
	MeterHalf = { "Huh…did everyone forget about me…?", "Uhm… I don't feel great…", "…A-anyone around?" },
	GoingAggro = { "H-HELP!!", "W-WHAT'S HAPPENING!?", "MAMA!? PAPA-?! HELP-" },
	PanicModeAggro = { "WHERE ARE YOU GOING!?", "WAIT! DON'T LEAVE!!", "STAY WITH ME!! -PLEASE!" }
}
local vector2 = Vector2.new(-0.41, 0)
local vector3 = Vector2.new(0.37, 0)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 101, 101)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)

function GourdyRageBar.new(character, options)
	local object = setmetatable({}, GourdyRageBar)
	object.character = character
	object.config = options or {}
	local events = ReplicatedStorage:FindFirstChild("Events")
	object.DialogueEvent = events and events:FindFirstChild("MonsterDialogueEvent")

	if not object.DialogueEvent then
		warn("GourdyRageBar: MonsterDialogueEvent not found - dialogue system disabled")
	end

	object.halfMeterDialogueShown = false
	object.aggroDialogueShown = false
	character:SetAttribute("GourdyRagePercent", 0)
	object.humanoid = character:WaitForChild("Humanoid", 60)
	object.hrp = character:WaitForChild("HumanoidRootPart", 60)
	object.head = character:WaitForChild("Head_geo", 60)

	if not object.head then
		object.head = character:WaitForChild("Head", 60)
	end

	if object.humanoid and object.hrp then
		if object.head then
			if object.config and object.config.DebugEnabled then
				print("GourdyRageBar: Found head component:", object.head.Name)
			end
		else
			warn("GourdyRageBar: No Head found (tried Head_geo and Head) - using HumanoidRootPart for UI positioning")
			object.head = object.hrp
		end

		object.maxRage = options.MaxRage or 100
		object.decayTime = options.DecayTime or 105
		object.decayInterval = options.DecayInterval or 0.5
		object.decayAmount = object.maxRage / object.decayTime * object.decayInterval
		object.currentRage = 0
		object.isStationary = true
		object.lastDecayTime = tick()

		if not object:createUI() then
			warn("GourdyRageBar: Template ReplicatedStorage.Assets.GourdyRageBar missing or incomplete - running without a bar")
		end

		object:startDecayLoop()
		object:setupConnections()
		task.spawn(function()
			task.wait(math.random(400, 500) / 100)
			object:showDialogue("Spawning", "all")
		end)
		return object
	else
		warn("GourdyRageBar: Failed to find essential character components (Humanoid/HumanoidRootPart) after 60s")
		object:cleanup()
		return nil
	end
end

function GourdyRageBar:createUI()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local gourdyRageBar = assets and assets:FindFirstChild("GourdyRageBar")

	if not (gourdyRageBar and gourdyRageBar:IsA("BillboardGui")) then
		return false
	end

	local clone = gourdyRageBar:Clone()
	local fill = clone:FindFirstChild("Fill", true)
	local uIGradient = fill and fill:FindFirstChildOfClass("UIGradient")

	if not (fill and fill:IsA("ImageLabel") and uIGradient) then
		clone:Destroy()
		return false
	end

	fill.ImageColor3 = color
	uIGradient.Offset = vector2
	clone.StudsOffsetWorldSpace = createVector(0, -6.5, 0)
	clone.Adornee = self.head
	clone.Parent = self.head
	self.billboardGui = clone
	self.fill = fill
	self.fillGradient = uIGradient
	return true
end

function GourdyRageBar:setupConnections()
	local isStationary = self.character:FindFirstChild("IsStationary")

	if isStationary then
		self.stationaryConnection = isStationary.Changed:Connect(function(isStationary2)
			self.isStationary = isStationary2

			if not isStationary2 then
				self:hideBar()
			end
		end)
	end

	local info = workspace:FindFirstChild("Info")
	local panic = info and info:FindFirstChild("Panic")

	if panic then
		self.panicConnection = panic.Changed:Connect(function(p)
			if p == true and self.isStationary then
				if self.config and self.config.DebugEnabled then
					print("GourdyRageBar: PANIC MODE TRIGGERED - Emerging immediately!")
				end

				self:setRage(self.maxRage)
			end
		end)
	end

	self.ancestryConnection = self.character.AncestryChanged:Connect(function()
		if not self.character.Parent then
			self:cleanup()
		end
	end)
end

function GourdyRageBar:startDecayLoop()
	self.decayCoroutine = task.spawn(function()
		while self.character.Parent and not self.character:GetAttribute("GourdyEmergenceComplete") do
			task.wait(self.decayInterval)

			if not self.isStationary or self.character:GetAttribute("GourdyEmerging") then
				continue
			end

			local scaledDecayAmount = self:getScaledDecayAmount()
			self:setRage((math.min(self.maxRage, self.currentRage + scaledDecayAmount)))

			if self.config and self.config.DebugEnabled and self.currentRage % 10 == 0 then
				print("GourdyRageBar: Rage:", math.floor(self.currentRage), "%")
			end
		end
	end)
end

function GourdyRageBar:getScaledDecayAmount()
	local activePlayerCount = self:getActivePlayerCount()
	local v3 = activePlayerCount <= 2 and 0.6 or activePlayerCount <= 4 and 0.8 or 1
	return self.decayAmount * v3
end

function GourdyRageBar:getActivePlayerCount()
	local count = 0

	if not workspace:FindFirstChild("InGamePlayers") then
		return count
	end

	for _, model in pairs(workspace.InGamePlayers:GetChildren()) do
		if not (model:IsA("Model") and model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0) then
			continue
		end

		count += 1
	end

	return count
end

function GourdyRageBar:setRage(value)
	self.currentRage = math.clamp(value, 0, self.maxRage)
	self.character:SetAttribute("GourdyRagePercent", self.currentRage)
	local v3 = self.currentRage / self.maxRage * 100

	if v3 >= 50 and not self.halfMeterDialogueShown then
		self.halfMeterDialogueShown = true
		self:showDialogue("MeterHalf", "all")
	elseif v3 < 50 and self.halfMeterDialogueShown then
		self.halfMeterDialogueShown = false
	end

	if v3 >= 50 and not self.character:GetAttribute("AngryAnimPlayed") then
		self.character:SetAttribute("AngryAnimPlayed", true)
		local GourdyMonster = require(ReplicatedStorage.MonsterData.GourdyMonster)
		GourdyMonster.PlayAngryAnimation(self.character)
	end

	self:updateVisuals()

	if self.currentRage >= self.maxRage and self.isStationary and not self.aggroDialogueShown then
		if workspace.Info and workspace.Info:FindFirstChild("Panic") and workspace.Info.Panic.Value then
			self:showDialogue("PanicModeAggro", "all")
		else
			self:showDialogue("GoingAggro", "all")
		end

		self.aggroDialogueShown = true
		self.isStationary = false
		self:triggerEmergence()
	end
end

function GourdyRageBar:updateVisuals()
	if not (self.fill and self.fillGradient) then
		return
	end

	local v3 = self.currentRage / self.maxRage
	TweenService:Create(self.fillGradient, tweenInfo, {
		Offset = vector2:Lerp(vector3, v3)
	}):Play()
	TweenService:Create(self.fill, tweenInfo, {
		ImageColor3 = color:Lerp(color2, v3)
	}):Play()
end

function GourdyRageBar:feedItem(p)
	if p then
		self:showDialogue("ReceivingItem", p)
	end

	local rageReductionPerItem = self.config.RageReductionPerItem or 100
	local v3 = math.max(0, self.currentRage - rageReductionPerItem)
	self:setRage(v3)

	if self.config and self.config.DebugEnabled then
		print("GourdyRageBar: Fed item - rage reduced by", rageReductionPerItem, "points! New rage:", v3)
	end
end

function GourdyRageBar:fillRage(p)
	self:feedItem(p)
end

function GourdyRageBar:triggerEmergence()
	local success, result = pcall(function()
		local isStationary = self.character:FindFirstChild("IsStationary")
		local gourdyState = self.character:FindFirstChild("GourdyState")

		if not (isStationary and isStationary.Value) then
			return
		end

		if self.character:GetAttribute("GourdyEmerging") then
			if self.config and self.config.DebugEnabled then
				print("GourdyRageBar: Emergence already in progress, skipping...")
			end
		else
			print("Twisted Gourdy is emerging!")
			self.character:SetAttribute("GourdyEmerging", true)
			self:hideBar()

			if gourdyState then
				gourdyState.Value = "Emerging"
			end

			self:playEmergenceSound()
			self:performEmergenceSequence(isStationary, gourdyState)
		end
	end)

	if not success then
		warn("GourdyRageBar: Failed to trigger emergence:", result)
	end
end

function GourdyRageBar:performEmergenceSequence(p, p2)
	if self.config and self.config.DebugEnabled then
		print("GourdyRageBar: ===== TWISTED GOURDY EMERGENCE SEQUENCE =====")
	end

	local v3 = self:setupEmergenceAnimation()

	if self.config and self.config.DebugEnabled then
		print("GourdyRageBar: PHASE 1 - Animation started, duration:", v3)
	end

	task.spawn(function()
		local GourdyMonster = require(ReplicatedStorage.MonsterData.GourdyMonster)
		GourdyMonster.CloseEyes(self.character)
		GourdyMonster.SpawnEmergenceParticles(self.character)
		local emergenceSound = self.character.HumanoidRootPart:FindFirstChild("EmergenceSound")

		if emergenceSound then
			emergenceSound:Play()
		end

		task.wait(0.1)
		self:animateEmergenceMovement(v3)
		task.wait(v3 * 0.5 - 0.1)

		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: PHASE 3 - Midpoint reached, eyes opening with rage textures")
		end

		GourdyMonster.SwitchToRageTextures(self.character)
		task.wait(v3 * 0.5)

		if self.emergenceAnimationTrack then
			self.emergenceAnimationTrack:Stop()
			self.emergenceAnimationTrack = nil

			if self.config and self.config.DebugEnabled then
				print("GourdyRageBar: Stopped emergence animation")
			end
		end

		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: PHASE 4 - Animation complete, activating AI systems")
		end

		if p then
			p.Value = false
		end

		if p2 then
			p2.Value = "Mobile"
		end

		local rootPart = self.character:FindFirstChild("RootPart")
		local rootPartRoot = rootPart and rootPart:FindFirstChild("root")

		if rootPartRoot then
			local cFrame = rootPartRoot.CFrame
			local position = cFrame.Position
			local vector4 = Vector3.new(position.X, 1.25, position.Z)
			rootPartRoot.CFrame = CFrame.new(vector4) * (cFrame - cFrame.Position)

			if self.config and self.config.DebugEnabled then
				print("GourdyRageBar: Root bone maintained at emerged height Y=1.25")
			end
		end

		GourdyMonster.ApplyMobileStats(self.character)
		self:transitionToMobileAnimations()
		self.character:SetAttribute("GourdyEmerging", nil)
		self.character:SetAttribute("GourdyEmergenceComplete", true)

		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: PHASE 5 - AI activated, Gourdy is now mobile and hunting")
		end

		self:cleanup()

		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: PHASE 6 - Emergence sequence complete")
			print("GourdyRageBar: ===== EMERGENCE SEQUENCE FINISHED =====")
		end
	end)
end

function GourdyRageBar:setupEmergenceAnimation()
	local emergenceAnimationTrack = self:startEmergenceAnimation()
	local v4

	if emergenceAnimationTrack then
		self.emergenceAnimationTrack = emergenceAnimationTrack
		task.wait()
		local length = emergenceAnimationTrack.Length
		v4 = not (length and length > 0.5 and length < 10) and 4 or length

		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: Using animation duration:", v4, "(track length:", length, ")")
		end

		if length > 0 then
			emergenceAnimationTrack:AdjustSpeed(length / v4)
			return v4
		end
	else
		v4 = 4

		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: No animation found, using duration:", v4)
		end
	end

	return v4
end

function GourdyRageBar.adjustEmergencePosition(p)
	local humanoidRootPart = p.character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = humanoidRootPart.CFrame.Position
	local vector4 = Vector3.new(position.X, 1.25, position.Z)
	humanoidRootPart.CFrame = CFrame.new(vector4, humanoidRootPart.CFrame.LookVector)

	if p.config and p.config.DebugEnabled then
		print("GourdyRageBar: Adjusted emergence position to Y=1.25")
	end
end

function GourdyRageBar:startEmergenceAnimation()
	local humanoid = self.character:FindFirstChild("Humanoid")

	if not humanoid then
		return nil
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return nil
	end

	local GourdyMonster = require(ReplicatedStorage.MonsterData.GourdyMonster)
	local v3 = GourdyMonster.AnimationCache and GourdyMonster.AnimationCache[self.character]
	local emerge = nil

	if v3 and v3.Emerge then
		emerge = v3.Emerge

		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: Using cached emergence animation")
		end
	else
		local animations = self.character:FindFirstChild("Animations")

		if animations then
			emerge = animations:FindFirstChild("GroundedEmerge") or animations:FindFirstChild("Emerge") or animations:FindFirstChild("GourdyEmerge")
		end
	end

	if emerge then
		local GourdyMonster2 = require(ReplicatedStorage.MonsterData.GourdyMonster)
		local v4 = GourdyMonster2.AnimationTracks and GourdyMonster2.AnimationTracks[self.character]

		if v4 and v4.GroundedIdle then
			v4.GroundedIdle:Stop(0.8)

			if self.config and self.config.DebugEnabled then
				print("GourdyRageBar: Stopping grounded idle with smooth blend")
			end
		end

		task.wait(0.1)
		local animations = self.character:FindFirstChild("Animations")
		local idle = animations and animations:FindFirstChild("Idle")

		if idle then
			local track = animator:LoadAnimation(idle)
			track.Looped = true
			track.Priority = Enum.AnimationPriority.Idle
			track:Play(0.5)

			if self.config and self.config.DebugEnabled then
				print("GourdyRageBar: Started regular idle as base layer")
			end
		end

		local track = animator:LoadAnimation(emerge)
		track.Looped = false
		track.Priority = Enum.AnimationPriority.Action
		track:Play(0.4)

		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: Started emergence animation:", emerge.Name)
		end

		return track
	else
		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: No emergence animation found")
		end

		return nil
	end
end

function GourdyRageBar:transitionToMobileAnimations()
	local humanoid = self.character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	if self.emergenceAnimationTrack then
		self.emergenceAnimationTrack:Stop()
		self.emergenceAnimationTrack = nil
	end

	local GourdyMonster = require(ReplicatedStorage.MonsterData.GourdyMonster)
	local v3 = GourdyMonster.AnimationTracks and GourdyMonster.AnimationTracks[self.character]

	if v3 and v3.GroundedIdle and v3.GroundedIdle.IsPlaying then
		v3.GroundedIdle:Stop(0.5)

		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: Stopped grounded idle")
		end
	end

	for _, v4 in pairs(animator:GetPlayingAnimationTracks()) do
		if not v4.Animation then
			continue
		end

		local animationId = tostring(v4.Animation.AnimationId)

		if not (string.find(animationId, "91883346043403") and v4.IsPlaying) then
			continue
		end

		v4:Stop(0.3)

		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: Stopped remaining grounded idle animation")
		end
	end

	self.character:SetAttribute("GroundedIdlePlaying", nil)
	self.character:SetAttribute("RageIdlePlaying", true)

	if self.config and self.config.DebugEnabled then
		print("GourdyRageBar: Transitioned from grounded idle to rage idle")
	end
end

function GourdyRageBar:animateEmergenceMovement(p2)
	if p2 <= 0.1 then
		if self.config and self.config.DebugEnabled then
			print("GourdyRageBar: Skipping movement animation - duration too short:", p2)
		end
	else
		local rootPart = self.character:FindFirstChild("RootPart")
		local rootPartRoot = rootPart and rootPart:FindFirstChild("root")

		if rootPartRoot then
			local cFrame = rootPartRoot.CFrame
			local position = cFrame.Position
			local vector4 = Vector3.new(position.X, 1.25, position.Z)
			rootPartRoot.CFrame = CFrame.new(vector4) * (cFrame - cFrame.Position)

			if self.config and self.config.DebugEnabled then
				print("GourdyRageBar: TEST - Keeping root bone at Y=1.25 for entire sequence (no underground animation)")
				print("GourdyRageBar: Root bone set to Y=", rootPartRoot.CFrame.Position.Y)
			end
		elseif self.config and self.config.DebugEnabled then
			print("GourdyRageBar: No root bone found for emergence movement")
		end
	end
end

function GourdyRageBar:playEmergenceSound()
	if self.emergenceSoundPlaying then
		return
	end

	self.emergenceSoundPlaying = true
	local humanoidRootPart = self.character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		self.emergenceSoundPlaying = false
		return
	end

	local gourdyEmergenceSound = humanoidRootPart:FindFirstChild("GourdyEmergenceSound")

	if gourdyEmergenceSound then
		gourdyEmergenceSound:Destroy()
	end

	local v5 = Audio:Play("Sounds.Twisted.Gourdy.Emergence", {
		Name = "GourdyEmergenceSound",
		Volume = not (self.config and self.config.SoundConfig) and 0.8 or self.config.SoundConfig.EmergenceVolume or 0.8,
		PlaybackSpeed = not (self.config and self.config.SoundConfig) and 1 or self.config.SoundConfig.EmergencePitch or 1,
		Parent = humanoidRootPart
	})

	if v5 then
		if v then
			v.AssignSound(v5, "MonsterState")
		end

		v5.Ended:Connect(function()
			self.emergenceSoundPlaying = false
		end)
	end

	task.delay(5, function()
		self.emergenceSoundPlaying = false
	end)
end

function GourdyRageBar:hideBar()
	local billboardGui = self.billboardGui

	if not billboardGui then
		return
	end

	self.billboardGui = nil
	self.fill = nil
	self.fillGradient = nil

	if not billboardGui.Parent then
		billboardGui:Destroy()
		return
	end

	local tween = TweenService:Create(billboardGui, tweenInfo2, {
		Size = UDim2.new(0, 0, 0, 0)
	})
	tween.Completed:Connect(function()
		billboardGui:Destroy()
	end)
	tween:Play()

	if self.config and self.config.DebugEnabled then
		print("GourdyRageBar: Hiding rage bar")
	end
end

function GourdyRageBar:showDialogue(p2, player)
	if not self.DialogueEvent then
		return
	end

	if not v2[p2] then
		warn("GourdyRageBar: Unknown dialogue type:", p2)
		return
	end

	local v3 = v2[p2]
	local v4 = v3[math.random(1, #v3)]

	if player == "all" then
		self.DialogueEvent:FireAllClients("GourdyMonster", v4, 5)
	elseif typeof(player) == "Instance" and player:IsA("Player") then
		self.DialogueEvent:FireClient(player, "GourdyMonster", v4, 5)
	else
		warn("GourdyRageBar: Invalid dialogue target:", player)
	end

	if self.config and self.config.DebugEnabled then
		print("GourdyRageBar: Dialogue shown -", p2, ":", v4)
	end
end

function GourdyRageBar:cleanup()
	if self.decayCoroutine then
		task.cancel(self.decayCoroutine)
		self.decayCoroutine = nil
	end

	if self.stationaryConnection then
		self.stationaryConnection:Disconnect()
		self.stationaryConnection = nil
	end

	if self.panicConnection then
		self.panicConnection:Disconnect()
		self.panicConnection = nil
	end

	if self.ancestryConnection then
		self.ancestryConnection:Disconnect()
		self.ancestryConnection = nil
	end

	if self.billboardGui then
		self.billboardGui:Destroy()
		self.billboardGui = nil
		self.fill = nil
		self.fillGradient = nil
	end

	if self.character and self.character.Parent then
		self.character:SetAttribute("GourdyRagePercent", nil)
	end
end

function GourdyRageBar.getRagePercent(p)
	return p.currentRage / p.maxRage * 100
end

return GourdyRageBar