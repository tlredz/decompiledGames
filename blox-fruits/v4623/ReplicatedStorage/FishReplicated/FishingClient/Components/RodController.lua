local createVector = vector.create
local RodController = {
	__components = nil,
	__loadOrder = 0,
	__maid = nil,
	__state = nil,
	state = nil
}
RodController.__index = RodController
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local Anims = require(game.ReplicatedStorage.Util.Anims)
local Inventory = require(game.ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("UI"):WaitForChild("Inventory"))
local ItemReplication = require(game.ReplicatedStorage.Util.ItemReplication)
local IdMap = require(game.ReplicatedStorage.IdMap)
local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local fishing = IrisLog.new("Fishing")
local humanoidRootPart = nil

if character then
	task.spawn(function()
		humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
	end)
end

localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
	humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
end)
local _ = script.Parent.Parent.Parent.Bobbers
local v = {}
local thread = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function resumeRenderThread()
	if not thread or coroutine.status(thread) == "dead" then
		thread = task.spawn(function()
			while task.wait(1) do
				for i = #v, 1, -1 do
					local v2 = v[i]
					local rod = v2:GetRod()

					if rod and rod.Parent then
						v2:UpdateRender(rod)
					else
						table.remove(v, i)
					end
				end

				if #v ~= 0 then
					continue
				end

				thread = nil
				break
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addRodToRenderQueue(p)
	if not table.find(v, p) then
		table.insert(v, p)
		resumeRenderThread() -- equivalent call inferred; original call site unknown
	end
end

function RodController:GetSounds()
	return (self.__components:Get("Sounds"))
end

function RodController:DestroyBobber()
	self.__maid.vanityBobber = nil
end

local ContextActionService = game:GetService("ContextActionService")

function RodController:DisableMovement()
	if not self.IsLocalOwner then
		return
	end

	self.__maid.disabledMovement = nil
	local humanoid = character.Humanoid
	humanoid.AutoRotate = false
	local folder = Instance.new("Folder", character)
	folder.Name = "DisableMovement"
	ContextActionService:BindAction("freezeMovement", function()
		return Enum.ContextActionResult.Sink
	end, false, unpack(Enum.PlayerActions:GetEnumItems()))

	function self.__maid.disabledMovement()
		folder:Destroy()
		humanoid.AutoRotate = true
		ContextActionService:UnbindAction("freezeMovement")
	end
end

function RodController:DisableJump()
	if not self.IsLocalOwner then
		return
	end

	self.__maid.disabledMovement = nil
	local _ = character.Humanoid
	local folder = Instance.new("Folder", character)
	folder.Name = "DisableMovement"
	ContextActionService:BindAction("freezeMovement", function()
		return Enum.ContextActionResult.Sink
	end, false, Enum.PlayerActions.CharacterJump)

	function self.__maid.disabledMovement()
		folder:Destroy()
		ContextActionService:UnbindAction("freezeMovement")
	end
end

function RodController:Render(flag: boolean)
	if flag then
		self:BuildFishingLineSegments()
		self:BuildBobber()
	else
		self:DestroyFishingLineSegments()
		self:DestroyBobber()
	end
end

function RodController:UpdateRender(instance)
	local isRendered = humanoidRootPart and (humanoidRootPart.Position - instance:GetPivot().Position).Magnitude < 200

	if isRendered ~= self.isRendered then
		self.isRendered = isRendered

		if isRendered then
			self:Render(true)
		else
			self:Render(false)
		end
	end
end

function RodController:DisableBaitText()
	if self.observer then
		return
	end

	self.__maid.baitTextUpdate = nil
	self.__maid.baitTextUpdateOnQuantityChanged = nil
	self.__maid.openInventoryEvent = nil
	self.__maid.baitText = nil
end

function RodController:EnableBaitText()
	if self.observer then
		return
	end

	local data = game.Players.LocalPlayer:FindFirstChild("Data")
	local fishingData = data and data:FindFirstChild("FishingData")

	if fishingData then
		local currentBait = game.Players.LocalPlayer.PlayerGui.Main.BottomHUDList.CurrentBait
		local selectedBait = fishingData:GetAttribute("SelectedBait")
		local v2

		if selectedBait then
			v2 = IdMap.Bait[selectedBait]
		else
			v2 = nil
		end

		local function baitTextUpdate()
			selectedBait = fishingData:GetAttribute("SelectedBait")
			local v3

			if selectedBait then
				v3 = IdMap.Bait[selectedBait]
			end

			if selectedBait and selectedBait ~= "None" then
				local client = ItemReplication.Quantity.readClient(v3)
				currentBait.Text = `[Selected Bait: {selectedBait} x{client}]`
				currentBait.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				currentBait.Text = "[No Bait Selected]"
				currentBait.TextColor3 = Color3.fromRGB(255, 127, 53)
			end
		end

		self.__maid.baitTextUpdate = fishingData:GetAttributeChangedSignal("SelectedBait"):Connect(baitTextUpdate)
		self.__maid.baitTextUpdateOnQuantityChanged = ItemReplication.Quantity.onChanged(function(p2)
			if v2 and p2 == v2 then
				baitTextUpdate()
			end
		end)
		self.__maid.openInventoryEvent = currentBait.InputBegan:Connect(function(input)
			if v2 and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				Inventory:Open(v2)
			end
		end)
		self.__maid.baitText = nil

		function self.__maid.baitText()
			currentBait.Visible = false
		end

		currentBait.Visible = true
		baitTextUpdate()
	end
end

function RodController:MakeLineSegment(parent, attachment, attachment2)
	if not attachment then
		return nil, attachment2
	end

	if not attachment2 then
		return nil, attachment
	end

	local ropeConstraint = Instance.new("RopeConstraint", parent)
	ropeConstraint.Attachment0 = attachment
	ropeConstraint.Attachment1 = attachment2
	ropeConstraint.Color = self:GetRod():GetAttribute("FishingLineColor") or BrickColor.Black()
	ropeConstraint.Thickness = 0.05
	ropeConstraint.Visible = true
	ropeConstraint.Length = ropeConstraint.CurrentDistance * 1.001
	return ropeConstraint, attachment2
end

function RodController:DestroyFishingLineSegments()
	local rod = self:GetRod()

	if not rod then
		return
	end

	local segments = rod:FindFirstChild("Segments")

	if not segments then
		return
	end

	segments:Destroy()
end

function RodController:BuildFishingLineSegments()
	local rod = self:GetRod()

	if not rod or rod:FindFirstChild("Segments") then
		return
	end

	local folder = Instance.new("Folder", rod)
	folder.Name = "Segments"
	local _, v2 = self:MakeLineSegment(
		folder,
		rod:FindFirstChild("ReelLineAttach", true),
		rod:FindFirstChild("Ring1", true)
	)
	local _, v3 = self:MakeLineSegment(folder, v2, rod:FindFirstChild("Ring2", true))
	local _, v4 = self:MakeLineSegment(folder, v3, rod:FindFirstChild("Ring3", true))
	local _, _ = self:MakeLineSegment(folder, v4, rod:FindFirstChild("Attachment", true))
end

function RodController:GetState()
	return self:GetRod() and self:GetRod():GetAttribute("State")
end

function RodController:SetState(state)
	local _ = self.State
	self.State = state

	if self:GetRod() then
		self:GetRod():SetAttribute("State", state)
	end

	if state == "ReeledIn" then
		local rod = self:GetRod()
		local reel = rod and rod:FindFirstChild("Reel", true)

		if reel then
			reel.CFrame = reel:GetAttribute("InactiveCF") + reel.CFrame.Position
		end

		self:BuildBobber()
		self:ResetTension()
		self:EnableBaitText()
	elseif state == "Waiting" or state == "Playing" or state == "Launching" then
		local rod = self:GetRod()
		local reel = rod and rod:FindFirstChild("Reel", true)

		if reel then
			reel.CFrame = reel:GetAttribute("ActiveCF") + reel.CFrame.Position
		end

		self:DestroyBobber()

		if state == "Playing" then
			self:DisableBaitText()
		else
			self:EnableBaitText()
		end
	end
end

function RodController:BuildBobber()
	if not self:GetRod() or self:GetRod():GetAttribute("State") ~= "ReeledIn" then
		return
	end

	self.__maid.vanityBobber = nil
	self.__maid.spawnBob = task.spawn(function()
		fishing:Append("RodController: Spawn Vanity Bobber")

		if not (self:GetRod() and self:GetRod():IsDescendantOf(workspace)) or self:GetRod():FindFirstChild("VanityBobber") then
			return
		end

		local flag = false
		local clone = script.Parent.Parent.Parent.Bobbers:FindFirstChild(self:GetRod():GetAttribute("BobberAsset") or "Bobber"):Clone()
		fishing:Append("RodController: Clone Vanity Bobber")

		function self.__maid.vanityBobber()
			fishing:Append("RodController: Destroy Vanity Bobber")
			self.__maid.vanityBobberUpdate = nil
			clone:Destroy()
			flag = true
		end

		clone.Name = "VanityBobber"
		self.LaunchTime = tick()
		local ropeConstraint = Instance.new("RopeConstraint", clone)
		self.RopeConstraint = ropeConstraint
		ropeConstraint.Name = "RopeConstraint"
		ropeConstraint.Attachment1 = clone:FindFirstChild("BobAttach", true)
		ropeConstraint.WinchEnabled = false
		ropeConstraint.Color = self:GetRod():GetAttribute("FishingLineColor") or BrickColor.Black()
		ropeConstraint.Length = 0.3
		ropeConstraint.Visible = true
		ropeConstraint.Thickness = 0.05
		local part = Instance.new("Part")
		part.Anchored = true
		part.Transparency = 1
		part.Massless = true
		part.Size = createVector(0.01, 0.01, 0.01)
		part.Parent = clone
		part.CanQuery = false
		part.CanCollide = false
		part.CanTouch = false
		local attachment = Instance.new("Attachment", part)
		attachment.Name = "invisAttach"
		ropeConstraint.Attachment0 = attachment
		ropeConstraint.Enabled = false
		local attachment2 = self:GetRod():FindFirstChild("Attachment", true)
		local primaryPart = clone.PrimaryPart
		local RunService = game:GetService("RunService")
		RunService.PreSimulation:Wait()

		if flag then
			return
		end

		clone.Parent = self:GetRod()
		local rod = self:GetRod()
		fishing:Append("Set Vanity Bobber Parent ", self:GetRod())
		part.CFrame = attachment2.WorldCFrame
		primaryPart.CFrame = part.CFrame
		local RunService2 = game:GetService("RunService")
		RunService2.PreSimulation:Wait()
		ropeConstraint.Enabled = true
		local __maid = self.__maid
		local RunService3 = game:GetService("RunService")
		__maid.vanityBobberUpdate = RunService3.RenderStepped:Connect(function(_)
			part.CFrame = attachment2.WorldCFrame
			primaryPart.AssemblyLinearVelocity = Vector3.new(
				primaryPart.AssemblyLinearVelocity.X * createVector(0.99, 0.99, 0.99),
				-3,
				primaryPart.AssemblyLinearVelocity.Z * createVector(0.99, 0.99, 0.99)
			)
			primaryPart.AssemblyAngularVelocity *= 0.75

			if primaryPart.Massless then
				primaryPart.Massless = false
			end

			if rod:FindFirstChild("Bobber") then
				task.defer(function()
					local Global = require(game.ReplicatedStorage.Global)
					Global.TestGameWarn("destroy bobber")
					self.__maid.vanityBobberUpdate = nil
					self.__maid.vanityBobber = nil
				end)
			end
		end)
		task.defer(function()
			self.__maid.spawnBob = nil
		end)
	end)
	fishing:Thread("SpawnVanityBobber", self.__maid.spawnBob)
end

function RodController:WaitUntilCanLaunchBobber()
	local animations = self:GetAnimations()

	if animations then
		local fishing_UpperBodyCast = animations.Fishing_UpperBodyCast

		repeat
			task.wait()
		until not fishing_UpperBodyCast.IsPlaying or fishing_UpperBodyCast.TimePosition > 0.75
	end
end

function RodController:HideRod()
	local rod = self:GetRod()
	local model = rod:FindFirstChildOfClass("Model")
	self.__maid.HideRod = nil
	local primaryPart = rod.PrimaryPart
	model.Parent = nil
	local bobber = self.__components:Get("Bobber")

	if bobber then
		bobber.__maid:Destroy()
	end

	function self.__maid.HideRod()
		model.Parent = rod
		rod.PrimaryPart = primaryPart
	end
end

function RodController:ShowRod()
	self.__maid.HideRod = nil
end

function RodController:OnRodToolEquipped(instance)
	local v2 = nil
	self.__maid.StateUpdated = instance:GetAttributeChangedSignal("State"):Connect(function()
		local state = instance:GetAttribute("State")
		local sounds = self:GetSounds()

		if state == "StartCasting" then
			self:GetSounds():PlayRandom("InitiateThrow")
		elseif state ~= "Launching" then
			if state == "Waiting" then
				if v2 ~= "Biting" then
					sounds:PlayRandom("LandInWater")

					if not self.observer then
						sounds:PlayRandom("LineInWaterWaitingLoop")
					end
				end
			elseif state == "Biting" then
				if not self.observer then
					sounds:PlayRandom("FishOnLine")
				end
			elseif state == "Playing" then
				sounds:StopSound("LineInWaterWaitingLoop")
				sounds:PlayRandom("ReelingHoveringFishOut")
				sounds:PlayRandom("ReelingHoveringFishIn")
			elseif state == "ReelingIn" then
				sounds:StopSound("LineInWaterWaitingLoop")
				sounds:StopSound("ReelingHoveringFishIn")
				sounds:StopSound("ReelingHoveringFishOut")
			elseif state == "ReeledIn" then
				sounds:StopSound("LineInWaterWaitingLoop")
				sounds:StopSound("ReelingHoveringFishIn")
				sounds:StopSound("ReelingHoveringFishOut")
			end
		end

		v2 = state
	end)
	self.__maid.updateLineTension = instance:GetAttributeChangedSignal("Tension"):Connect(function()
		self:UpdateRender(instance)
		local tension = instance:GetAttribute("Tension") or 0.995
		local segments = instance:FindFirstChild("Segments")

		if tension and segments then
			for _, child in segments:GetChildren() do
				child.Length = child.CurrentDistance * (2 - tension)
			end
		end
	end)
	task.defer(function()
		instance:SetAttribute("Tension", 0.995)
	end)

	if self.IsLocalOwner then
		self.__maid.isReelingChanged = instance:GetAttributeChangedSignal("IsReeling"):Connect(function()
			self:isReelingChanged(instance:GetAttribute("IsReeling"))
		end)
		local animations = self:GetAnimations()

		if animations then
			for _, animation in animations do
				animation:Play()
				animation:Stop()
			end
		end

		animations.Fishing_RodEquipped:Play()
		local rodAnimations = self:GetRodAnimations()

		if rodAnimations then
			for _, rodAnimation in rodAnimations do
				rodAnimation:Play()
				rodAnimation:Stop()
			end
		end
	end

	task.defer(function()
		addRodToRenderQueue(self) -- equivalent call inferred; original call site unknown
	end)
	self:SetState("ReeledIn")
	task.defer(function()
		self:UpdateRender(instance)
	end)
	task.defer(function()
		self:EnableBaitText()
	end)
end

function RodController:OnRodToolUnequipped(p)
	self.__maid.updateLineTension = nil
	self.__maid.vanityBobber = nil

	if self.IsLocalOwner then
		self:GetAnimations().Fishing_RodEquipped:Stop()
		self.__maid.disabledMovement = nil
		self.__maid.isReelingChanged = nil
		local animations = self:GetAnimations()

		if animations then
			for _, animation in animations do
				animation:Stop()
			end
		end

		local rodAnim = self.RodAnims[p]

		if rodAnim then
			for _, v2 in rodAnim do
				v2:Stop()
			end
		else
			local rodAnimations = self:GetRodAnimations()

			if rodAnimations then
				for _, rodAnimation in rodAnimations do
					rodAnimation:Stop()
				end
			end
		end

		self:DisableBaitText()
	end

	if self.RodAnims then
		self.RodAnims[p] = nil
	end

	self:GetSounds():StopAll(p)
end

function RodController:OnRodToolChanged(tool)
	if self.Tool == tool then
		return
	end

	local tool2 = self.Tool
	self.Tool = tool

	if tool2 then
		self:OnRodToolUnequipped(tool2)
	end

	if tool then
		self:OnRodToolEquipped(tool)

		if self.observer and tool:GetAttribute("ServerState") ~= "ReeledIn" then
			task.defer(function()
				if self:GetRod() == tool then
					script.Parent.Parent.Parent.FishingRequest:InvokeServer("requestMissingBobber", self.Owner, nil)
				end
			end)
		end
	end
end

function RodController:GetRod()
	if not self.Tool and self.Owner and self.Owner.Character then
		for _, tool in self.Owner.Character:GetChildren() do
			if tool:IsA("Tool") and tool:HasTag("FishingRod") then
				self:OnRodToolChanged(tool)
			end
		end
	end

	return self.Tool
end

function RodController:GetAnimations()
	if self.Anims then
		return self.Anims
	end

	local character2 = self.Owner.Character

	if not character2 then
		return
	end

	local humanoid = character2:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildWhichIsA("Animator")

	if not animator then
		return
	end

	self.__maid.CharacterAnims = self.Owner.CharacterAdded:Connect(function(_)
		self.Anims = nil
		self:GetAnimations()
	end)
	local tracks = {}
	self.Anims = tracks

	for _, v2 in {
		"Fishing_UpperBodyIdle",
		"Fishing_Reeling_L",
		"Fishing_Reeling_R",
		"Fishing_Reeling_M",
		"Fishing_Cast",
		"Fishing_UpperBodyCast",
		"Fishing_UpperBodyIdle",
		"Fishing_RodEquipped",
		"Fishing_PullFishOut"
	} do
		local track = animator:LoadAnimation(Anims:GetRaw(v2))

		if track then
			tracks[v2] = track
		end
	end

	tracks.Fishing_UpperBodyIdle:Stop()
	tracks.Fishing_UpperBodyIdle.Priority = Enum.AnimationPriority.Action
	tracks.Fishing_Cast.Priority = Enum.AnimationPriority.Action2
	tracks.Fishing_Reeling_L.Priority = Enum.AnimationPriority.Action2
	tracks.Fishing_Reeling_M.Priority = Enum.AnimationPriority.Action2
	tracks.Fishing_Reeling_R.Priority = Enum.AnimationPriority.Action2
	tracks.Fishing_PullFishOut.Priority = Enum.AnimationPriority.Action3
	tracks.Fishing_PullFishOut.Looped = false
	tracks.Fishing_UpperBodyCast.Priority = Enum.AnimationPriority.Action2
	tracks.Fishing_UpperBodyIdle.Priority = Enum.AnimationPriority.Action2
	tracks.Fishing_RodEquipped.Priority = Enum.AnimationPriority.Action
	return tracks
end

function RodController:GetRodAnimations()
	local rod = self:GetRod()
	fishing:Append("Rod? ", rod)

	if not rod then
		return
	end

	local rodAnim = self.RodAnims[rod]

	if rodAnim then
		return rodAnim
	end

	local animationController = rod:FindFirstChild("AnimationController", true)
	fishing:Append("AnimationController? ", animationController)

	if not animationController then
		return
	end

	local animator = animationController:FindFirstChildWhichIsA("Animator")
	fishing:Append("Animator? ", animator)

	if not animator then
		return
	end

	local tracks = {}
	self.RodAnims[rod] = tracks

	for _, v2 in { "Fishing_RodModel_Idle", "Fishing_RodModel_Cast", "Fishing_RodModel_Reel" } do
		local track = animator:LoadAnimation(Anims:GetRaw(v2))

		if track then
			tracks[v2] = track
		end
	end

	return tracks
end

local function getReelAnimationWeights(reelingAngle)
	local v2 = math.clamp(reelingAngle, -90, 90)
	local v3 = {
		left = 0,
		middle = 0,
		right = 0
	}

	if v2 <= 0 then
		local left = 1 - (v2 + 90) / 90
		v3.left = left
		v3.middle = 1 - left
		v3.right = 0
		return v3
	else
		local right = v2 / 90
		v3.left = 0
		v3.middle = 1 - right
		v3.right = right
		return v3
	end
end

function RodController:teleportToClosestLandToWater()
	local rod = self:GetRod()

	if not rod then
		return
	end

	local bobber = rod:FindFirstChild("Bobber")

	if not bobber then
		return
	end

	local parent = rod.Parent
	local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart2 then
		return
	end

	local position = humanoidRootPart2.Position
	local vector2 = Vector3.new(
		bobber.PrimaryPart.Position.X,
		humanoidRootPart2.Position.Y,
		bobber.PrimaryPart.Position.Z
	)
	local unit = (vector2 - position).Unit
	local magnitude = (position - vector2).Magnitude
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.RespectCanCollide = false
	raycastParams:AddToFilter(workspace.Map)
	local cframe = nil

	for i = 1, magnitude do
		local v2 = position + unit * i
		local raycastResult = workspace:Raycast(v2, createVector(-0, -100, -0), raycastParams)

		if not raycastResult then
			continue
		end

		if raycastResult.Instance and raycastResult.Instance:HasTag("WaterBody") then
			break
		end

		if not raycastResult.Instance or math.abs(raycastResult.Position.Y - humanoidRootPart2.Position.Y) > 5 then
			continue
		end

		local _ = raycastResult.Instance
		cframe = CFrame.new(
			Vector3.new(raycastResult.Position.X, humanoidRootPart2.Position.Y, raycastResult.Position.Z),
			vector2
		)
	end

	if not cframe then
		return false
	end

	self:DisableMovement()

	if ((cframe + cframe.LookVector * -4).Position - humanoidRootPart2.Position).Magnitude <= 5 then
		local total = 0

		while humanoidRootPart2.CFrame.LookVector:Dot(CFrame.lookAt(humanoidRootPart2.Position, vector2).LookVector) < 0.995 do
			total += task.wait()
			local cframe2 = CFrame.lookAt(humanoidRootPart2.Position, vector2)
			local lerped = humanoidRootPart2.CFrame:Lerp(cframe2, (math.min(total * 5, 1)))

			if cframe2 ~= cframe2 or cframe2.Position ~= cframe2.Position or lerped ~= lerped or lerped.Position ~= lerped.Position or total >= 1 then
				return true
			end

			humanoidRootPart2.CFrame = lerped
		end

		local cframe2 = CFrame.lookAt(humanoidRootPart2.Position, vector2)

		if cframe2 ~= cframe2 or cframe2.Position ~= cframe2.Position then
			return true
		end

		humanoidRootPart2.CFrame = cframe2
		return true
	else
		parent.Humanoid.MoveToFinished:Once(function()
			for _ = 1, 10 do
				task.wait()
				humanoidRootPart2.CFrame = cframe + cframe.LookVector * -4
			end
		end)
		parent.Humanoid:MoveTo((cframe + cframe.LookVector * -4).Position)
		return true
	end
end

function RodController:ConnectActiveSkillChanged(callback)
	local activeSkillChangedConnection = self:GetRod():GetAttributeChangedSignal("ActiveSkill"):Connect(function()
		callback(self:GetRod():GetAttribute("ActiveSkill"))
	end)
	callback(self:GetRod():GetAttribute("ActiveSkill"))
	return activeSkillChangedConnection
end

function RodController:isReelingChanged(flag: boolean)
	self.pauseReeling = nil
	self.__maid.reelingAngleChanged = nil

	if not flag then
		return
	end

	self:DisableMovement()
	local animations = self:GetAnimations()
	local rodAnimations = self:GetRodAnimations()
	local fishing_Reeling_L = animations.Fishing_Reeling_L
	local fishing_Reeling_M = animations.Fishing_Reeling_M
	local fishing_Reeling_R = animations.Fishing_Reeling_R
	local fishing_RodModel_Reel = rodAnimations.Fishing_RodModel_Reel
	animations.Fishing_UpperBodyIdle:Stop()
	rodAnimations.Fishing_RodModel_Idle:Stop()
	fishing_RodModel_Reel.Looped = true
	fishing_Reeling_R.Looped = true
	fishing_Reeling_L.Looped = true
	fishing_Reeling_M.Looped = true
	local v2 = 1
	fishing_RodModel_Reel:Play()
	fishing_Reeling_L:Play()
	fishing_Reeling_M:Play()
	fishing_Reeling_R:Play()
	fishing_Reeling_L:AdjustWeight(0.01)
	fishing_Reeling_R:AdjustWeight(0.01)
	fishing_Reeling_M:AdjustWeight(0.01)
	local rod = self:GetRod()
	local connection = self:ConnectActiveSkillChanged(function(p)
		if p == "Reel Boost" then
			v2 = 1.5
		else
			v2 = 1
		end

		fishing_Reeling_L:AdjustSpeed(v2)
		fishing_Reeling_M:AdjustSpeed(v2)
		fishing_Reeling_R:AdjustSpeed(v2)
		fishing_RodModel_Reel:AdjustSpeed(v2)
	end)
	local fn

	fn = function()
		local v3 = false
		fishing_Reeling_L:AdjustSpeed(0.0001)
		fishing_Reeling_M:AdjustSpeed(0.0001)
		fishing_Reeling_R:AdjustSpeed(0.0001)
		fishing_RodModel_Reel:AdjustSpeed(0.0001)
		task.spawn(function()
			while not v3 and self.pauseReeling == fn do
				for _, v4 in {
					fishing_Reeling_M,
					fishing_Reeling_L,
					fishing_Reeling_R,
					fishing_RodModel_Reel
				} do
					v4.TimePosition += math.random() / 200 * math.random(-1, 1)
				end

				task.wait()
			end
		end)
		return function()
			v3 = true
			fishing_Reeling_L:AdjustSpeed(v2)
			fishing_Reeling_M:AdjustSpeed(v2)
			fishing_Reeling_R:AdjustSpeed(v2)
			fishing_RodModel_Reel:AdjustSpeed(v2)
		end
	end

	self.pauseReeling = fn
	local reelingAngleChangedConnection = rod:GetAttributeChangedSignal("ReelingAngle"):Connect(function()
		local reelAnimationWeights = getReelAnimationWeights(rod:GetAttribute("ReelingAngle"))
		fishing_Reeling_L:AdjustWeight(reelAnimationWeights.left + 0.01)
		fishing_Reeling_M:AdjustWeight(reelAnimationWeights.middle + 0.01)
		fishing_Reeling_R:AdjustWeight(reelAnimationWeights.right + 0.01)
	end)
	local reelingSpeedChangedConnection = rod:GetAttributeChangedSignal("ReelingSpeed"):Connect(function()
		local _ = rod:GetAttribute("ReelingSpeed") or 0.1
	end)

	function self.__maid.reelingAngleChanged()
		reelingAngleChangedConnection:Disconnect()
		reelingSpeedChangedConnection:Disconnect()
		connection:Disconnect()
		fishing_Reeling_L:Stop()
		fishing_Reeling_M:Stop()
		fishing_Reeling_R:Stop()
		fishing_RodModel_Reel:Stop()
	end
end

function RodController:StartCasting()
	local reel = self:GetRod():FindFirstChild("Reel", true)

	if reel then
		reel.CFrame = reel:GetAttribute("ActiveCF") + reel.CFrame.Position
	end

	if not self.IsLocalOwner then
		return
	end

	self:SetState("StartCasting")
	self:DisableMovement()
	local animations = self:GetAnimations()
	local rodAnimations = self:GetRodAnimations()

	if animations then
		self.__maid.castStarted = task.spawn(function()
			animations.Fishing_UpperBodyCast.Looped = false
			rodAnimations.Fishing_RodModel_Cast.Looped = false
			animations.Fishing_UpperBodyCast:Play()
			rodAnimations.Fishing_RodModel_Cast:Play()

			repeat
				task.wait()
			until animations.Fishing_UpperBodyCast.TimePosition >= 0.55

			animations.Fishing_UpperBodyCast.TimePosition = 0.6
			rodAnimations.Fishing_RodModel_Cast.TimePosition = 0.6
			rodAnimations.Fishing_RodModel_Cast:AdjustSpeed(0)
			animations.Fishing_UpperBodyCast:AdjustSpeed(0)
			rodAnimations.Fishing_RodModel_Cast.TimePosition = animations.Fishing_UpperBodyCast.TimePosition
		end)
	end
end

function RodController:ResetTension()
	if self:GetRod() then
		self:GetRod():SetAttribute("Tension", 0.995)
	end
end

function RodController:ReleaseCasting()
	if not self.IsLocalOwner then
		return
	end

	self:SetState("ReleaseCasting")
	self:DisableJump()
	self.__maid.castStarted = nil
	local animations = self:GetAnimations()
	local rodAnimations = self:GetRodAnimations()

	if animations then
		animations.Fishing_UpperBodyCast.Looped = false
		rodAnimations.Fishing_RodModel_Cast.Looped = false
		animations.Fishing_UpperBodyCast:AdjustSpeed(1)
		rodAnimations.Fishing_RodModel_Cast:AdjustSpeed(1)
		self.__maid.onCastAnimFinished = animations.Fishing_UpperBodyCast.Stopped:Connect(function()
			if self.State == "ReeledIn" or self.State == "LaunchingFail" then
				return
			end

			animations.Fishing_UpperBodyIdle:Play()
			rodAnimations.Fishing_RodModel_Idle:Play()
		end)
	end
end

function RodController:CancelCasting()
	if self.State == "ReeledIn" then
		return
	end

	self:SetState("ReeledIn")

	if not self.IsLocalOwner then
		return
	end

	self.__maid.disabledMovement = nil
	self.__maid.castStarted = nil
	local animations = self:GetAnimations()

	if animations then
		self:GetRodAnimations().Fishing_RodModel_Cast:Stop()
		animations.Fishing_UpperBodyCast:Stop()
	end
end

function RodController:PlayReelInAnimation()
	self.__maid.reelingAngleChanged = nil
	local animations = self:GetAnimations()

	if animations then
		for k, animation in animations do
			if k ~= "Fishing_RodEquipped" then
				animation:Stop()
			end
		end
	end

	local rodAnimations = self:GetRodAnimations()

	if rodAnimations then
		for _, rodAnimation in rodAnimations do
			rodAnimation:Stop()
		end
	end

	animations.Fishing_PullFishOut:Play()
end

function RodController:PauseReelIn()
	self.__maid.reelingAngleChanged = nil
	local animations = self:GetAnimations()

	if animations then
		for k, animation in animations do
			if k ~= "Fishing_PullFishOut" and k ~= "Fishing_RodEquipped" then
				animation:Stop()
			end
		end
	end

	local rodAnimations = self:GetRodAnimations()

	if rodAnimations then
		for _, rodAnimation in rodAnimations do
			rodAnimation:Stop()
		end
	end
end

function RodController:ReeledInRod()
	local v2 = self.State == "ReelingIn" or self:GetRod() and self:GetRod():GetAttribute("State") == "ReelingIn"

	if self.State == "ReeledIn" then
		return
	end

	self:SetState("ReeledIn")

	if not v2 then
		self:GetSounds():PlayRandom("CatchFailure")
	end

	if not self.IsLocalOwner then
		return
	end

	self.__maid.disabledMovement = nil
	self.__maid.onCastAnimFinished = nil
	self.__maid.castStarted = nil
	self.__maid.reelingAngleChanged = nil
	local animations = self:GetAnimations()

	if animations then
		for k, animation in animations do
			if k ~= "Fishing_RodEquipped" then
				animation:Stop()
			end
		end
	end

	local rodAnimations = self:GetRodAnimations()

	if rodAnimations then
		for _, rodAnimation in rodAnimations do
			rodAnimation:Stop()
		end
	end

	if not v2 and self:GetRod() and self:GetRod().Parent == game.Players.LocalPlayer.Character then
		self:PlayReelInAnimation()
	end
end

function RodController:Construct()
	local object = setmetatable(self, RodController)
	local owner = self.Owner
	self.IsLocalOwner = owner == localPlayer
	object.RodAnims = {}

	local function onCharacterAdded(character2)
		if not character2 then
			return
		end

		object.__maid.onCharacterChildAdded = character2.ChildAdded:Connect(function(tool)
			if tool:IsA("Tool") and tool:HasTag("FishingRod") then
				object:OnRodToolChanged(tool)
			end
		end)
		object.__maid.onCharacterChildRemoved = character2.ChildRemoved:Connect(function(tool)
			if tool:IsA("Tool") and tool:HasTag("FishingRod") then
				object:OnRodToolChanged(nil)
			end
		end)

		for _, tool in character2:GetChildren() do
			if tool:IsA("Tool") and tool:HasTag("FishingRod") then
				object:OnRodToolChanged(tool)
			end
		end
	end

	object.__maid:GiveTask(owner.CharacterAdded:Connect(onCharacterAdded))
	onCharacterAdded(owner.Character)
	return object
end

function RodController.Setup() end

return RodController