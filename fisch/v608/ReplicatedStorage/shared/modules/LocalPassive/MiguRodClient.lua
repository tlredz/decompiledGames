local MiguRodClient = {}
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
game:GetService("SoundService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Trove = require(ReplicatedStorage.packages.Trove)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local module = require("./PassiveHandler")
require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rods"))
local random = Random.new()
local v = { Enum.KeyCode.ButtonX, Enum.UserInputType.Touch }
local v2 = {
	Shift = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift },
	Ctrl = { Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl },
	Alt = { Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt },
	Space = { Enum.KeyCode.Space },
	Meta = { Enum.KeyCode.LeftMeta, Enum.KeyCode.RightMeta }
}
local v3 = {
	PS = "rbxassetid://133037091735870",
	PC = {
		Shift = "rbxassetid://97289546665992",
		Ctrl = "rbxassetid://119530165061292",
		Alt = "rbxassetid://134732874854984",
		Space = "rbxassetid://121874172843116",
		Meta = "rbxassetid://83689240947558"
	},
	Xbox = "rbxassetid://117600191854686"
}

function MiguRodClient:PlaySound(childName: string, value: number?)
	local v4 = self.config.SFXSuffix and script:FindFirstChild(childName .. self.config.SFXSuffix) or script:FindFirstChild(childName)
	local clone = v4:Clone()
	clone.PlaybackSpeed *= value or 1
	clone.Name = v4.Name .. "Clone"
	clone.Parent = script
	clone:Play()
	task.delay(v4.TimeLength * 2, function()
		clone:Destroy()
	end)
	return clone
end

function MiguRodClient:GetInputIcon()
	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		if UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonX) == "ButtonSquare" then
			return v3.PS
		end

		return v3.Xbox
	elseif UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
		return v3.PC[SettingsController:GetSettingValue("miguRodMasteryKeybind")] or ""
	else
		return ""
	end
end

function MiguRodClient:GetInputs()
	local clone = table.clone(v)
	local v4 = v2[SettingsController:GetSettingValue("miguRodMasteryKeybind")]

	if v4 then
		for _, v5 in v4 do
			table.insert(clone, v5)
		end
	end

	if not (self.current:FindFirstPassive("BellonasWaraxe") or self.current.mock) then
		table.insert(clone, Enum.KeyCode.ButtonL2)
		table.insert(clone, Enum.UserInputType.MouseButton2)
	end

	return clone
end

function MiguRodClient:FinishCounterAttack(p: number)
	self.attackTrove:Clean()
	local counterAttack = self.currentConfig.CounterAttack

	if not counterAttack then
		return
	end

	if p > 0.1 then
		local animation = self.current:GetAnimation("migurod_fire")

		if animation then
			animation.Priority = Enum.AnimationPriority.Action4
			animation:Play(0)
		end

		self:PlaySound("CounterAttackSound")
	else
		local animation = self.current:GetAnimation("migurod_aimend")

		if animation then
			animation.Priority = Enum.AnimationPriority.Action4
			animation:Play(0.1)
		end

		self:PlaySound("boowomp")
	end

	local animation = self.current:GetAnimation("migurod_aim")

	if animation then
		animation:Stop(0.1)
	end

	local value = TweenService:GetValue(p, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
	self.current:AddProgress(math.map(value, 0, 1, counterAttack.MinDamage, counterAttack.MaxDamage))
	self.current.fx:SpawnShake(self.current.reel_bar, value / 2, 0.25, 0.01, false)
end

function MiguRodClient:StartCounterAttack()
	local counterAttack = self.currentConfig.CounterAttack

	if self.isCounterAttacking or not counterAttack then
		return
	end

	self.isCounterAttacking = true
	self:PlaySound("CounterStart", random:NextNumber(0.85, 1.1))
	local animation = self.current:GetAnimation("migurod_aim")

	if animation then
		animation.Priority = Enum.AnimationPriority.Action3
		animation:Play(0.1)
	end

	local integer = random:NextInteger(0, 1)
	local v4 = 1 - integer
	local v5 = "MiguRodCounterAttack" .. self.current.base_seed
	local scale = self.current.reel_bar.Position.X.Scale
	local total = 0
	local v6 = 0
	local clone = script.counterAttack:Clone()
	clone.UIScale.Scale = 0
	clone.Position = UDim2.fromScale(scale, 0.7)
	clone.inputIcon.Image = self:GetInputIcon()
	clone.Parent = self.current.reel
	TweenService:Create(clone.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		Scale = 1
	}):Play()

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		local clone2 = script.counterAttackMobile:Clone()
		clone2.Position = UDim2.fromScale(scale, -0.3)
		clone2.Parent = self.current.reel
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
			Position = UDim2.fromScale(scale, 0.3)
		}):Play()
		self.attackTrove:Add(function()
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
				Position = UDim2.fromScale(scale, -0.3)
			}):Play()
			task.delay(0.25, clone2.Destroy, clone2)
		end)
	end

	self.attackTrove:Add(function()
		self.isCounterAttacking = false
		ContextActionService:UnbindAction(v5)

		if clone:FindFirstChild("UIScale") then
			TweenService:Create(clone.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Scale = 0
			}):Play()
		end

		task.delay(0.25, clone.Destroy, clone)
	end)
	self.attackTrove:Add(self.current.OnLogicStep:Connect(function(p: number)
		if self.current.isPaused then
			return
		end

		total += p
		v6 = math.clamp(math.map(total, 0, counterAttack.BarMoveTime, integer, v4), 0, 1)
		clone.playerbar.Position = UDim2.fromScale(v6, 0.5)

		if total >= counterAttack.BarMoveTime then
			self:FinishCounterAttack(0)
		end
	end))
	ContextActionService:BindActionAtPriority(v5, function(_, p, p2)
		if p ~= Enum.UserInputState.Begin or p2.UserInputType == Enum.UserInputType.Touch and p2.Position.Y / self.current.reel.AbsoluteSize.Y > 0.5 then
			return Enum.ContextActionResult.Pass
		end

		if not self.isCounterAttacking then
			self.attackTrove:Clean()
			return Enum.ContextActionResult.Pass
		end

		local v7 = 1 - math.abs(v6 - 0.5) * 2
		task.spawn(function()
			if v7 >= 0.9 then
				clone.fgGlow.perfect.Enabled = true
				self:PlaySound("PerfectCounter")
			else
				clone.fgGlow.imperfect.Enabled = true
			end

			clone.fgGlow.ImageTransparency = 0
			TweenService:Create(clone.fgGlow, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				ImageTransparency = 1
			}):Play()
		end)
		self:FinishCounterAttack(v7)
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value + 1, table.unpack(self:GetInputs()))
end

function MiguRodClient:SliceBar(p: number)
	if not (self.current and self.current.reel_playerbar) then
		return false
	end

	if self.current:IsInBar(p) then
		if self.isRedlip then
			self.current:AddProgress(-self.current.progress * 0.25)
		end

		self:PlaySound("SliceHit", random:NextNumber(0.85, 1.1))
		self.current.fx:SpawnShake(self.reel, 0.1, 0.5, 0.02, false)
		local v4 = p - self.current.barPosition
		local v5 = v4 > 0 and 1 or -1
		local v6 = self.current.barSize / 2 - math.abs(v4)
		self.barSizeModifier.Value -= v6
		self.current.barPosition -= v6 / 2 * v5
		local clone = self.current.reel_playerbar:Clone()
		clone.Size = UDim2.fromScale(v6, clone.Size.Y.Scale)
		clone.Position = UDim2.fromScale(p + v6 / 2 * v5, clone.Position.Y.Scale)
		clone.Name = "LostBarChunk"
		local shine = clone:FindFirstChild("Shine")

		if shine then
			shine:Destroy()
		end

		clone.Parent = self.container
		self.current.renderTweens:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Position = clone.Position + UDim2.fromScale(v5 * random:NextNumber(0.05, 0.2), 10),
			Rotation = v5 * random:NextNumber(70, 120)
		}):Play()
		self.current:DelayRender(1, function()
			clone:Destroy()
		end)
		self.current:Update(0)
		return false
	else
		local v4 = self.isRedlip and not self.current.onbar and 0.4 or 1
		self.current:AddProgress(self.currentConfig.ProgressPerDodge * v4)
		return true
	end
end

function MiguRodClient:SpawnSlash(p: number, p2: number, flag: boolean)
	self.isSlashing = true
	local clone = script.slashWarning:Clone()
	clone.Position = UDim2.fromScale(p, 0.5)
	clone.BackgroundTransparency = 1
	clone.exclamation.UIScale.Scale = 2
	clone.Parent = self.container
	self.current.logicTweens:CreateAndPlay(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 0.75
	})
	self.current.logicTweens:CreateAndPlay(
		clone.exclamation,
		TweenInfo.new(self.currentConfig.WarningTime / 5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 3, true),
		{
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}
	)
	self.current.logicTweens:CreateAndPlay(
		clone.exclamation.UIScale,
		TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{
			Scale = 1
		}
	)
	self.current.logicTweens:CreateAndPlay(
		self.knife,
		TweenInfo.new(self.currentConfig.WarningTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{
			Position = UDim2.fromScale(0.9, 0.45),
			Rotation = -100
		}
	)
	self.current.logicTweens:CreateAndPlay(
		self.knife.flare,
		TweenInfo.new(self.currentConfig.WarningTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Rotation = 85,
			ImageTransparency = 0,
			Position = UDim2.fromScale(-1, -1.2)
		}
	)
	self:PlaySound("WarningSound", random:NextNumber(0.85, 1.1))
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { "rbxassetid://132490467818887" })
	self.reelTrove:Add(self.current:DelayLogic(self.currentConfig.WarningTime, function()
		if not (self.current and self.current.active) then
			return
		end

		self.current.logicTweens:CreateAndPlay(
			self.knife,
			TweenInfo.new(self.currentConfig.SlashTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{
				Position = UDim2.fromScale(0.841, 0.692),
				Rotation = 0
			}
		)
		self.current.logicTweens:CreateAndPlay(
			self.knife.flare,
			TweenInfo.new(self.currentConfig.SlashTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{
				Rotation = -15,
				ImageTransparency = 1,
				Position = UDim2.fromScale(-1.75, -1.85)
			}
		)
		clone:Destroy()
		local clone2 = script.slashFlipbook:Clone()
		clone2.Position = UDim2.fromScale(p, 0.5)
		clone2.ImageRectOffset = Vector2.zero
		clone2.Parent = self.container
		self:PlaySound("SliceSound", random:NextNumber(0.85, 1.1))

		for i = 0, 256, 256 do
			for i2 = 0, 256, 256 do
				clone2.ImageRectOffset = Vector2.new(i2, i)
				self.current:WaitLogic(self.currentConfig.SlashTime / 4)
			end

			if i ~= 0 then
				continue
			end

			local sliceBar = self:SliceBar(p)

			if self.currentWave ~= p2 then
				continue
			end

			if sliceBar then
				if flag and self.dodgedCurrentWave and self.config.CounterAttack and self.random:NextNumber(0, 100) < self.config.CounterAttack.TriggerChance then
					self:StartCounterAttack()
				end
			else
				self.dodgedCurrentWave = false
			end
		end

		clone2:Destroy()
		self.current:WaitLogic(self.config.Cooldown)
		self.isSlashing = false
	end))
end

function MiguRodClient:SpawnSlashes()
	self.currentWave = (self.currentWave or 0) + 1
	self.dodgedCurrentWave = true
	local currentWave = self.currentWave
	local slashCount = self.currentConfig.SlashCount
	local v4 = {}

	for i = 1, slashCount do
		local v5 = math.min(self.current.barSize, 0.05)
		local number = self.random:NextNumber(v5 + 0, 1 - v5)

		for _, v6 in v4 do
			if math.abs(number - v6) < self.currentConfig.MinSlashDistance then
				number -= math.sign(number - 0.5) * self.currentConfig.MinSlashDistance * 2
			end
		end

		table.insert(v4, number)
		local v6 = i
		self.current:DelayLogic((i - 1) * (0.75 / self.currentConfig.SlashCount), function()
			if not (self.current and self.current.active) then
				return
			end

			if v6 == 4 then
				self.current.OnFishMove:Fire(self.current.fishPosition, 0)
			end

			self:SpawnSlash(number, currentWave, v6 == slashCount)
		end)
	end

	table.sort(v4)
	table.insert(v4, 0.99)
	local v5 = 0.01
	local v6 = 0
	local v7 = 0

	for _, v8 in v4 do
		local v9 = v8 - v5

		if v6 < v9 then
			v7 = v5 + v9 / 2
			v6 = v9
		end

		v5 = v8
	end

	self.current.core.fish:ForceMoveTo(v7, self.currentConfig.WarningTime / 4)
	self.current.core.fish:DelayNextMovement(self.currentConfig.WarningTime)
end

function MiguRodClient:Morph(parent, object2)
	self.current:Preload({ parent, script })
	self.random = object2:GetRandom(6)
	local isRedlip

	if object2.fish.Name == "Redlip Batfish" then
		isRedlip = object2.rodName == "MiguRod"
	else
		isRedlip = false
	end

	self.isRedlip = isRedlip

	if self.config.CounterAttack then
		self.reelTrove:Add(function()
			local animation = self.current:GetAnimation("migurod_aim")

			if animation and animation.IsPlaying then
				animation:Stop()
				local animation2 = self.current:GetAnimation("migurod_aimend")

				if animation2 then
					animation2:Play(0.1)
				end
			end
		end)
	end

	if self.isRedlip then
		self.currentConfig = {
			SlashCount = 5,
			Cooldown = 0,
			AttackChance = 100,
			ProgressPerDodge = 1.5,
			WarningTime = 0.75,
			SlashTime = 0.25,
			MinSlashDistance = self.config.MinSlashDistance,
			TriggerOnFishSlashed = self.config.TriggerOnFishSlashed
		}
		object2:AddModifier("progressLossMultiplier", "multiply", 0.25)
		object2:AddModifier("accel", "multiply", 1.5)
		object2:AddModifier("progressefficiency", "force_final", 0)
		local minigameScale = parent:FindFirstChildOfClass("UIScale")

		if not minigameScale then
			minigameScale = Instance.new("UIScale")
			minigameScale.Scale = 1
			minigameScale.Parent = parent
		end

		self.minigameScale = minigameScale
		local clone = script.cutsceneBars:Clone()
		clone.Top.Position = UDim2.fromScale(0.5, -1.5)
		clone.Bottom.Position = UDim2.fromScale(0.5, 2.5)
		clone.middleBg.Size = UDim2.fromScale(2, 1.5)
		clone.middleBg.BackgroundTransparency = 1
		clone.Parent = object2.reel
		self.redlipBars = clone
		local clone2 = script.vignette:Clone()
		clone2.vignette.ImageTransparency = 1
		clone2.Parent = localPlayer.PlayerGui
		self.reelTrove:Add(clone2)
		self.redlipVignette = clone2
		object2.core.ui.StartStopAnim_StartTime = 2
		object2.core.ui.CameraFOV_InactiveFOV = 33
		object2.core.ui.CameraFOV_ActiveFOV = 32
		object2.core.ui.CameraFOV_AnimTime = 2
		parent:SetAttribute("RootPosition", UDim2.fromScale(0.5, 0.525))
		parent.Position = UDim2.fromScale(0.5, 0.525)
		TweenService:Create(minigameScale, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
			Scale = 1.5
		}):Play()
		TweenService:Create(clone.Bottom, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
			Position = UDim2.fromScale(0.5, 2)
		}):Play()
		TweenService:Create(clone.Top, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
			Position = UDim2.fromScale(0.5, -1)
		}):Play()
		TweenService:Create(clone.middleBg, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
			Size = UDim2.fromScale(2, 0.25),
			BackgroundTransparency = 0
		}):Play()
		TweenService:Create(clone2.vignette, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			ImageTransparency = 0
		}):Play()
	else
		self.currentConfig = self.config
	end

	object2.OnMinigameEnd:Connect(function()
		self.attackTrove:Clean()

		if self.minigameScale then
			TweenService:Create(self.minigameScale, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Scale = 1
			}):Play()
			self.minigameScale = nil
		end

		if self.redlipBars then
			TweenService:Create(
				self.redlipBars.Bottom,
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
				{
					Position = UDim2.fromScale(0.5, 2.5)
				}
			):Play()
			TweenService:Create(
				self.redlipBars.Top,
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
				{
					Position = UDim2.fromScale(0.5, -1.5)
				}
			):Play()
			TweenService:Create(
				self.redlipBars.middleBg,
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
				{
					Size = UDim2.fromScale(2, 1.5),
					BackgroundTransparency = 1
				}
			):Play()
			self.redlipBars = nil
		end

		if self.redlipVignette then
			TweenService:Create(self.redlipVignette.vignette, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				ImageTransparency = 1
			}):Play()
			self.redlipVignette = nil
		end
	end)
	local clone = script.miguContainer:Clone()
	clone.Parent = parent
	self.container = clone
	local clone2 = script.nife:Clone()
	clone2.Parent = object2.reel_bar.fish:FindFirstChild("icon") or object2.reel_bar.fish
	self.knife = clone2
	self.barSizeModifier = object2:CreateModifier("barSize", "add")
	self.current.core.rod.BarElasticity = 0.2
	object2.core.fish.OnMovementAttempted:BindAtPriority(5000, function(p, ...)
		if not p then
			return p, ...
		end

		if not self.isSlashing and self.random:NextNumber(0, 100) < self.currentConfig.AttackChance then
			self:SpawnSlashes()
			p = false
		end

		return p, ...
	end)

	if object2.rodName == "MiguRod" and self.config.TriggerOnFishSlashed then
		object2.OnSlash:Connect(function()
			self:SliceBar(self.current.fishPosition)
		end)
	end

	self.reelTrove:Add(function()
		self.isSlashing = false
	end)
end

function MiguRodClient.new(p, config, env)
	local self = setmetatable({}, {
		__index = p
	})
	self.config = config
	self.trove = Trove.new()
	self.env = env
	self.uid = game.HttpService:GenerateGUID(false)
	self.currentWave = 0
	self.dodgedCurrentWave = true
	self.reelTrove = self.trove:Extend()
	self.attackTrove = self.reelTrove:Extend()
	local maid = self.trove:Extend()

	local function setupCharacter(character)
		maid:Clean()

		if config.DisableMesmerizerVisuals then
			return
		end

		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local clone = script.StarThings:Clone()
		maid:Add(clone)
		clone.Parent = workspace.active.debrisfx
		local total = 0
		RunService:BindToRenderStep("MiguRodVisualUpdate", Enum.RenderPriority.Last.Value + 1000, function(p2: number)
			total += p2 * 3.141592653589793
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 3, 0) * CFrame.fromOrientation(0, total, 0)

			for _, image in clone:GetDescendants() do
				if image:IsA("ImageLabel") and image.Parent.Enabled then
					image.Rotation += p2 * -90
				end
			end
		end)
		maid:Add(function()
			RunService:UnbindFromRenderStep("MiguRodVisualUpdate")
		end)

		local function updateState()
			local bonusCatchReady = localPlayer:GetAttribute("BonusCatchReady")

			for _, descendant in clone:GetDescendants() do
				if not ((descendant:IsA("Trail") or descendant:IsA("BillboardGui")) and descendant.Parent) then
					continue
				end

				local enabled

				if bonusCatchReady then
					enabled = descendant.Parent.Name == "Active"
				else
					enabled = descendant.Parent.Name == "Inactive"
				end

				descendant.Enabled = enabled
			end
		end

		maid:Connect(localPlayer:GetAttributeChangedSignal("BonusCatchReady"), updateState)
		updateState()
	end

	self.trove:Connect(localPlayer.CharacterAdded, setupCharacter)

	if localPlayer.Character then
		setupCharacter(localPlayer.Character)
	end

	return self
end

setmetatable(MiguRodClient, module)
return MiguRodClient