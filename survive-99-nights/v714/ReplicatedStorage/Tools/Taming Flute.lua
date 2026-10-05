local TamingFlute = {}
TamingFlute.__index = TamingFlute
TamingFlute.Cooldown = 0.05
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local RunService = game:GetService("RunService")
local random = Random.new()
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Characters }
local v = {
	{
		Gravity = 1.3,
		ZoneSize = 0.3,
		TameDuration = 2.75,
		TimeBetweenMoves = 1.2,
		ClickVelocity = 0.5,
		LossRate = 0.22,
		StartingPosition = 0,
		MaxBarMovement = 0.2
	},
	{
		Gravity = 2,
		ZoneSize = 0.23,
		TameDuration = 3,
		TimeBetweenMoves = 1,
		ClickVelocity = 0.5,
		LossRate = 0.25,
		StartingPosition = 0,
		MaxBarMovement = 0.3
	},
	{
		Gravity = 2.2,
		ZoneSize = 0.18,
		TameDuration = 3.5,
		TimeBetweenMoves = 0.8,
		ClickVelocity = 0.5,
		LossRate = 0.27,
		StartingPosition = 0,
		MaxBarMovement = 0.4
	},
	{
		Gravity = 2.4,
		ZoneSize = 0.1,
		TameDuration = 5,
		TimeBetweenMoves = 0.7,
		ClickVelocity = 0.5,
		LossRate = 0.5,
		StartingPosition = 0,
		MaxBarMovement = 0.5
	}
}
local v2 = {}

function TamingFlute.new(model, realModel)
	local self = setmetatable({}, TamingFlute)
	self.Model = model
	self.RealModel = realModel
	self.AnimalsInRange = {}
	self.ClosestAnimal = nil
	self.ToolTier = realModel:GetAttribute("ToolTier")
	self.LastSwing = 0
	self.LastTaming = 0
	return self
end

function GetProgressBarColour(p)
	return (Color3.fromHSV(70 * p / 255, 1, 1))
end

function TamingFlute:StartTamingMinigame(currentAnimalTaming, value)
	local v3 = v[value or 1]
	local tamingFluteFrame = Client.Interface.TamingFluteFrame
	local platform = Client.Utility.GetPlatform()
	local tameDuration = v3.TameDuration

	if localPlayer:GetAttribute("Class") == "Zookeeper" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 3 then
		tameDuration *= 0.8
	end

	if Client.Utility.IsFlameActive("Pet Flame") then
		tameDuration *= 0.8
	end

	self.NoteVelocity = 0
	self.NotePosition = 1
	self.TamingTime = v3.StartingPosition * tameDuration
	self.ClickVelocity = v3.ClickVelocity
	local total = 0
	local gravity = v3.Gravity
	local v4 = nil
	tamingFluteFrame.TimingBar.SuccessArea.Size = UDim2.new(1, 0, v3.ZoneSize, 0)
	local v5 = 1 - v3.ZoneSize - 0.1
	local maxBarMovement = v3.MaxBarMovement or 1
	Client.Events.PlayAnimation:Fire("Flute_Play")

	local function moveBar()
		local v6

		while true do
			v6 = random:NextInteger(5, v5 * 100) / 100

			if v4 == nil then
				break
			end

			local v7 = math.abs(v4 - v6)

			if v7 > 0.05 and v7 < maxBarMovement then
				break
			end
		end

		v4 = v6
		tamingFluteFrame.TimingBar.SuccessArea.Position = UDim2.new(0.5, 0, v6, 0)
	end

	moveBar()

	local function update(p)
		if platform == "Mobile" then
			p *= 0.85
		end

		self.NoteVelocity -= gravity * p
		local v6 = self.NotePosition + self.NoteVelocity * p
		self.NotePosition = math.clamp(v6, 0, 1)
		local v7 = 1 - self.NotePosition
		tamingFluteFrame.TimingBar.Bar.Position = UDim2.new(0.5, 0, v7, 0)
		local Y = tamingFluteFrame.TimingBar.SuccessArea.AbsolutePosition.Y
		local v8 = tamingFluteFrame.TimingBar.SuccessArea.AbsolutePosition.Y + tamingFluteFrame.TimingBar.SuccessArea.AbsoluteSize.Y
		local Y2 = tamingFluteFrame.TimingBar.Bar.AbsolutePosition.Y
		local v9 = tamingFluteFrame.TimingBar.Bar.AbsolutePosition.Y + tamingFluteFrame.TimingBar.Bar.AbsoluteSize.Y
		local v10 = Y < v9 and Y2 < Y or Y2 < v8 and v8 < v9 or (Y < Y2 and v9 < v8 or false)

		if v10 then
			self.TamingTime += p
		else
			self.TamingTime -= p * v3.LossRate
		end

		self.TamingTime = math.clamp(self.TamingTime, 0, 50)

		if v10 then
			total += p

			if total > v3.TimeBetweenMoves then
				moveBar()
				Client.Events.TamingEffects:Fire("MusicNote", currentAnimalTaming, localPlayer)
				Client.Sound.Play("Flute" .. math.random(1, 4), {
					Volume = 0.45,
					Replicate = true,
					ReplicationProperties = {
						Instance = localPlayer.Character.Head,
						Volume = 0.35
					}
				})
				Client.Sound.Play("FluteWood")
				total = 0
			end
		end

		local v11 = math.clamp(self.TamingTime / tameDuration, 0, 1)
		tamingFluteFrame.SuccessBar.Bar.Size = UDim2.new(1, 0, v11, 0)
		tamingFluteFrame.SuccessBar.Bar.BackgroundColor3 = GetProgressBarColour(v11)

		if v11 <= 0 then
			return
		end

		if v11 >= 1 then
			self:StopTamingMinigame()
			print("success")
			Client.Sound.Play("FluteAlert", {
				Volume = 0.45,
				Replicate = true,
				ReplicationProperties = {
					Instance = localPlayer.Character.Head,
					Volume = 0.35
				}
			})
			Client.Events.RequestTame_Hungry:FireServer(currentAnimalTaming, self.RealModel)
		end
	end

	self.TamingMinigameActive = true
	self.CurrentAnimalTaming = currentAnimalTaming
	update(0)
	tamingFluteFrame.Visible = true
	RunService:BindToRenderStep("TamingFluteMinigame", Enum.RenderPriority.First.Value, update)
	local RunService2 = game:GetService("RunService")

	if RunService2:IsStudio() then
		task.delay(1, function()
			self.TamingTime = 1000
		end)
	end
end

function TamingFlute:StopTamingMinigame()
	self.LastTaming = time()
	Client.Events.StopAnimation:Fire("Flute_Play")
	RunService:UnbindFromRenderStep("TamingFluteMinigame")
	Client.Interface.TamingFluteFrame.Visible = false
	self.TamingMinigameActive = false
	self.CurrentAnimalTaming = nil
end

function TamingFlute:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function TamingFlute:Activate()
	if time() < self.LastSwing + self.Cooldown then
		return
	end

	self.LastSwing = time()

	if self.TamingMinigameActive then
		self.NoteVelocity = self.ClickVelocity
		return
	end

	if time() - self.LastTaming < 1 then
		print("just finished taming")
		return
	end

	if localPlayer:GetAttribute("CurrentPets") and localPlayer:GetAttribute("CurrentPets") >= localPlayer:GetAttribute("MaxPets") then
		Client.Events.UpdateOwnedPets:InvokeServer()

		if localPlayer:GetAttribute("CurrentPets") >= localPlayer:GetAttribute("MaxPets") then
			Client.PopUpUI.AddPopUp("You already have the maximum number of pets", "warning")
			return
		end
	end

	if self.ClosestAnimal then
		local closestAnimal = self.ClosestAnimal

		if closestAnimal:GetAttribute("TamingInProgress") and closestAnimal:GetAttribute("TamingInProgress") ~= localPlayer.UserId then
			Client.PopUpUI.AddPopUp("Someone else is taming this animal", "warning")
			return
		end

		local v3 = math.clamp(
			closestAnimal:GetAttribute("TamingDifficulty") - self.RealModel:GetAttribute("TamingDifficultyOffset"),
			1,
			10
		)

		if not v[v3] then
			Client.PopUpUI.AddPopUp("You need to upgrade your flute to tame this animal", "warning")
			return
		end

		closestAnimal:SetAttribute("LocalTaming", true)
		task.delay(2, function()
			closestAnimal:SetAttribute("LocalTaming", nil)
		end)
		Client.Events.RequestTame_Neutral:FireServer(closestAnimal, self.RealModel)

		if self.RealModel.Name == "Admin Taming Flute" then
			Client.Events.TamingEffects:Fire("MusicNote", closestAnimal, localPlayer)
			Client.Sound.Play("Flute" .. math.random(1, 4), {
				Volume = 0.45,
				Replicate = true,
				ReplicationProperties = {
					Instance = localPlayer.Character.Head,
					Volume = 0.35
				}
			})
			Client.Sound.Play("FluteWood")
		else
			self:StartTamingMinigame(closestAnimal, v3)
		end
	end
end

function CanTame(instance)
	if instance:GetAttribute("Tamed") then
		return false
	end

	if instance:GetAttribute("CanBeTamed") then
		return true
	end

	return false
end

function TamingFlute:GetClosestAnimal()
	if self.TamingMinigameActive or time() - self.LastTaming < 1 then
		return nil
	end

	local v3 = nil
	local v4 = 1e999
	local position = localPlayer.Character and localPlayer.Character:GetPivot().Position

	if not position then
		return v3, v4
	end

	for _, v5 in pairs(self.AnimalsInRange) do
		if not CanTame(v5) or (v5:GetAttribute("LocalTaming") or v5:GetAttribute("TamingInProgress")) then
			continue
		end

		local magnitude = (v5:GetPivot().Position - position).Magnitude

		if not (magnitude <= 20 and magnitude < v4) then
			continue
		end

		v3 = v5
		v4 = magnitude
	end

	return v3, v4
end

function TamingFlute:UpdateClosestAnimal()
	local closestAnimal, _ = self:GetClosestAnimal()

	if closestAnimal ~= self.ClosestAnimal then
		self.ClosestAnimal = closestAnimal
		Client.AnimalTamingClient.HighlightClosestNPC(closestAnimal)
	end
end

function TamingFlute:UpdateAnimalsInRange()
	local animalsInRange = {}
	local position = localPlayer.Character and localPlayer.Character:GetPivot().Position

	if position then
		for k in pairs(v2) do
			if not (CanTame(k) and (k:GetPivot().Position - position).Magnitude <= 100) then
				continue
			end

			table.insert(animalsInRange, k)
		end
	end

	self.AnimalsInRange = animalsInRange
end

function TamingFlute:RunUpdateLoops()
	task.spawn(function()
		while self.Equipped do
			self:UpdateAnimalsInRange()
			task.wait(1)
		end
	end)
	task.spawn(function()
		while self.Equipped do
			self:UpdateClosestAnimal()
			task.wait()
		end
	end)
end

function TamingFlute.Deactivate(_) end

function TamingFlute:ToggleLevelParticles(levelParticlesOn)
	self.LevelParticlesOn = levelParticlesOn

	for _, emitter in pairs(self.Model:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and emitter.Name == "UpgradeParticles" then
			emitter.Enabled = levelParticlesOn and emitter.Parent.Name ~= "CenterEmitPoint"
		end
	end

	local folder = Client.FirstPersonModule.IsVisible() and Client.FirstPersonModule.GetTool()

	if folder then
		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name == "UpgradeParticles" then
				emitter.Enabled = levelParticlesOn and emitter.Parent.Name ~= "CenterEmitPoint"
			end
		end
	end
end

function TamingFlute:FlashLevelParticles()
	if not self.LevelParticlesOn then
		return
	end

	local function emit(folder)
		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name == "UpgradeParticles" and emitter.Parent.Name == "CenterEmitPoint" then
				emitter:Emit(1)
			end
		end
	end

	emit(self.Model)
	local tool = Client.FirstPersonModule.GetTool()

	if tool and Client.FirstPersonModule.IsVisible() then
		emit(tool)
	end
end

function TamingFlute:TrackLevelUp()
	local function update()
		local XP = self.RealModel:GetAttribute("XP")
		local levelUpXP = self.RealModel:GetAttribute("LevelUpXP")

		if XP and levelUpXP and levelUpXP <= XP and (self.ToolTier or 1) < 3 then
			self:ToggleLevelParticles(true)
		else
			self:ToggleLevelParticles(false)
		end
	end

	self.XPEvent = self.RealModel:GetAttributeChangedSignal("XP"):Connect(update)
	self.FlashEvent = Client.Events.ToolUpgradeFlash:Connect(function()
		self:FlashLevelParticles()
	end)
	update()
end

function TamingFlute:OnEquip()
	self.Equipped = true
	Client.GuiButtonHandler.ShowButton("Play")
	Client.AnimalTamingClient.ShowFaces(true)
	task.spawn(function()
		local topRight = Client.Interface.TopRight

		if localPlayer:GetAttribute("Class") == "Beastmaster" then
			topRight.Visible = true
			topRight.Frame.PetSummon.Visible = true
		end

		if not (localPlayer:GetAttribute("CurrentPets") and localPlayer:GetAttribute("CurrentPets") > 0) then
			return
		end

		topRight.Visible = true
		topRight.Frame.PetWhistle.Visible = true

		if localPlayer:GetAttribute("Class") == "Beastmaster" then
			topRight.Frame.PetSummon.Visible = true
		end
	end)
	self.TamingFailedEvent = Client.Events.TamingFailed:Connect(function(p)
		if self.TamingMinigameActive and self.CurrentAnimalTaming == p then
			self:StopTamingMinigame()
		end
	end)
	self:RunUpdateLoops()
	self:TrackLevelUp()
end

function TamingFlute:OnUnequip()
	self.Equipped = false
	Client.GuiButtonHandler.HideButton("Play")
	Client.AnimalTamingClient.ShowFaces(false)
	task.spawn(function()
		local topRight = Client.Interface.TopRight

		if topRight:GetAttribute("EnabledSoFar") and topRight:GetAttribute("EnabledSoFar") <= 0 then
			topRight.Visible = false
		end

		topRight.Frame.PetWhistle.Visible = false
		topRight.Frame.PetSummon.Visible = false
	end)

	if self.TamingMinigameActive then
		Client.Events.TamingAttemptEnded:FireServer()
	end

	self:StopTamingMinigame()
	self.TamingFailedEvent:Disconnect()
	self.XPEvent:Disconnect()
	self.FlashEvent:Disconnect()
end

function NPCAdded(p)
	if p.Parent == workspace.Characters then
		v2[p] = true
	end
end

function NPCRemoved(p)
	v2[p] = nil
end

Client.Utility.ForAllTagged("NPC", NPCAdded, NPCRemoved)
return TamingFlute