local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LightingController = require(ReplicatedStorage.Controllers.Game.LightingController)
local Notifications = require(ReplicatedStorage.Client.Notifications)
local CorruptedPlate = require(ReplicatedStorage.Client.Notifications.CorruptedPlate)
local TutorialBeam = require(ReplicatedStorage.Client.WorldFX.TutorialBeam)
local Kit = require(script.Parent.Kit)
local Vfx = require(script.Parent.Vfx)
local color = Color3.fromRGB(10, 60, 10)
local color2 = Color3.fromRGB(120, 120, 120)
local hex = Kit.Green:ToHex()
local v = {
	Waiting = "DR. SCRAMBLE'S MECH",
	Mech = "DR. SCRAMBLE'S MECH",
	Ejecting = "DR. SCRAMBLE'S MECH",
	Ball = "DR. SCRAMBLE",
	Human = "DR. SCRAMBLE",
	Final = "DR. SCRAMBLE",
	Defeated = "DR. SCRAMBLE"
}
local localPlayer = Players.LocalPlayer
local object = setmetatable({}, {
	__mode = "k"
})

local function now()
	return Workspace:GetServerTimeNow()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function struggleHint()
	local lastInputType = UserInputService:GetLastInputType()

	if lastInputType == Enum.UserInputType.Touch then
		return "Tap fast to break free!"
	end

	if string.find(lastInputType.Name, "Gamepad") then
		return "Mash A to break free!"
	end

	return "Mash click or Space to break free!"
end

local function remember(instance, attributeName: string, p)
	local attribute = instance:GetAttribute(attributeName)

	if attribute ~= nil then
		return attribute
	end

	instance:SetAttribute(attributeName, p)
	return p
end

local function tintCoil(folder, p: string)
	if object[folder] == p then
		return
	end

	object[folder] = p

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			local color3 = descendant.Color
			local coilBaseColor = descendant:GetAttribute("CoilBaseColor")

			if coilBaseColor == nil then
				descendant:SetAttribute("CoilBaseColor", color3)
			else
				color3 = coilBaseColor
			end

			local brightness = descendant.Brightness
			local coilBaseBrightness = descendant:GetAttribute("CoilBaseBrightness")

			if coilBaseBrightness == nil then
				descendant:SetAttribute("CoilBaseBrightness", brightness)
			else
				brightness = coilBaseBrightness
			end

			if p == "Lit" then
				color3 = ColorSequence.new(Kit.Green)
			elseif p == "Spent" then
				color3 = ColorSequence.new(color2)
			end

			descendant.Color = color3

			if p == "Spent" then
				brightness *= 0.35
			end

			descendant.Brightness = brightness
		elseif descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
			local color3 = descendant.Color
			local coilBaseColor = descendant:GetAttribute("CoilBaseColor")

			if coilBaseColor == nil then
				descendant:SetAttribute("CoilBaseColor", color3)
			else
				color3 = coilBaseColor
			end

			if p == "Spent" then
				color3 = color2
			end

			descendant.Color = color3
		elseif descendant:IsA("Light") then
			local enabled = descendant.Enabled
			local coilBaseEnabled = descendant:GetAttribute("CoilBaseEnabled")

			if coilBaseEnabled == nil then
				descendant:SetAttribute("CoilBaseEnabled", enabled)
			else
				enabled = coilBaseEnabled
			end

			descendant.Enabled = enabled and p ~= "Spent"
		end
	end
end

local function find(child, list)
	for _, childName in list do
		child = child:WaitForChild(childName, 10)
		assert(child, (`ScrambleBossUI is missing {table.concat(list, ".")}`))
	end

	return child
end

local Presentation = {}
Presentation.__index = Presentation

function Presentation.new(maid, arena)
	local scrambleBossUI = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScrambleBossUI", 20)
	local object2 = setmetatable({
		Trove = maid,
		Arena = arena,
		Gui = scrambleBossUI,
		BossName = find(scrambleBossUI, { "BossHPBar", "BossName" }),
		HealthText = find(scrambleBossUI, { "BossHPBar", "BarHolder", "HealthAmount" }),
		HealthHolder = find(scrambleBossUI, { "BossHPBar", "BarHolder" }),
		Bar = find(scrambleBossUI, {
			"BossHPBar",
			"BarHolder",
			"BarBG",
			"Bar"
		}),
		Phantom = find(scrambleBossUI, {
			"BossHPBar",
			"BarHolder",
			"BarBG",
			"PhantomBar"
		}),
		PhaseSegments = find(scrambleBossUI, { "BossHPBar", "BarHolder", "ShieldBarHolder" }),
		BossScale = find(scrambleBossUI, { "BossHPBar", "JuiceScale" }),
		TimerLabel = find(scrambleBossUI, { "BossHPBar", "Frame", "TimerLabel" }),
		TimerTitle = find(scrambleBossUI, { "BossHPBar", "Frame", "Title" }),
		TimerFrame = find(scrambleBossUI, { "BossHPBar", "Frame" }),
		Countdown = find(scrambleBossUI, { "BossHPBar", "Countdown" }),
		CountdownPlate = find(scrambleBossUI, { "BossHPBar", "Countdown", "Plate" }),
		CountdownBody = find(scrambleBossUI, {
			"BossHPBar",
			"Countdown",
			"Plate",
			"Body"
		}),
		CountdownText = "",
		StopCountdownGlitch = nil,
		Target = find(scrambleBossUI, { "Target" }),
		TargetTitle = find(scrambleBossUI, { "Target", "Title" }),
		TargetSub = find(scrambleBossUI, { "Target", "Sub" }),
		TargetCountdown = find(scrambleBossUI, { "Target", "Countdown" }),
		Flash = find(scrambleBossUI, { "Flash" }),
		DisplayedHealth = 1,
		LastHealthFraction = 1,
		LastPhase = "",
		HealthJuice = maid:Extend(),
		PhantomValue = 1,
		CrocTargetUntil = 0,
		Arrow = nil,
		ArrowKey = "",
		ArrowTarget = nil,
		Reticles = {},
		Lit = false,
		HumanFade = 0
	}, Presentation)
	object2.Segments = {}

	for _, frame in object2.PhaseSegments:GetChildren() do
		if frame:IsA("Frame") then
			table.insert(object2.Segments, frame)
		end
	end

	table.sort(object2.Segments, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	object2.Target.Visible = false
	object2.Flash.BackgroundTransparency = 1
	object2.Countdown.Visible = false
	maid:Add(function()
		scrambleBossUI.Enabled = false
		object2:SetCountdown(nil)
		object2:SetArrow("", nil)

		for _, reticle in object2.Reticles do
			reticle:Destroy()
		end

		if object2.Lit then
			LightingController.ClearLayer("ScrambleBoss", 2)
		end
	end)
	maid:Connect(RunService.RenderStepped, function(p2: number)
		object2:Step(p2)
	end)
	return object2
end

function Presentation:PunchHealth(flag: boolean)
	self.HealthJuice:Clean()

	if GuiService.ReducedMotionEnabled then
		self.BossScale.Scale = 1
		self.HealthHolder.Rotation = 0
	else
		local healthPunchScale = self.Gui.BossHPBar:GetAttribute("HealthPunchScale") or 1.06
		local bossScale = self.BossScale

		if flag then
			healthPunchScale += 0.04
		end

		bossScale.Scale = healthPunchScale
		self.HealthHolder.Rotation = math.random() < 0.5 and -1.5 or 1.5
		local tween = TweenService:Create(
			self.BossScale,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Scale = 1
			}
		)
		local tween2 = TweenService:Create(
			self.HealthHolder,
			TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Rotation = 0
			}
		)
		self.HealthJuice:Add(tween)
		self.HealthJuice:Add(tween2)
		tween:Play()
		tween2:Play()
	end
end

function Presentation:SetPhaseSegments(p2: number)
	for k, segment in self.Segments do
		local fill = segment:FindFirstChild("Fill")

		if not fill then
			continue
		end

		local v2 = math.clamp(p2 * #self.Segments - (k - 1), 0, 1)
		fill.Visible = v2 > 0
		fill.Size = UDim2.fromScale(v2, 1)
	end
end

function Presentation:FadeHuman(folder, flag: boolean)
	local v2 = flag and math.floor(os.clock() * 12) % 2 == 0 and 0.6 or 0

	if folder == nil or v2 == self.HumanFade then
		return
	end

	self.HumanFade = v2

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			descendant.LocalTransparencyModifier = v2
		end
	end
end

function Presentation:InArena()
	return localPlayer:GetAttribute("InScrambleArena") == true
end

function Presentation:SetArrow(arrowKey: string, arrowTarget)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if arrowTarget == nil or humanoidRootPart == nil then
		if self.Arrow then
			TutorialBeam.Destroy(self.Arrow)
			self.Arrow = nil
		end

		self.ArrowKey = arrowTarget ~= nil and "" or arrowKey
		self.ArrowTarget = nil
	else
		local position

		if typeof(arrowTarget) == "Vector3" then
			position = arrowTarget
		else
			position = arrowTarget.Position
		end

		local vector = Vector3.new(position.X, humanoidRootPart.Position.Y, position.Z)
		self.ArrowKey = arrowKey
		self.ArrowTarget = arrowTarget

		if self.Arrow then
			TutorialBeam.Retarget(self.Arrow, vector)
		else
			self.Arrow = TutorialBeam.Attach(vector)
		end
	end
end

function Presentation:Say(text: string, p2: string?, value: number?)
	if not self:InArena() then
		return
	end

	local v2

	if p2 == nil then
		v2 = false
	else
		v2 = p2 ~= ""
	end

	Notifications.Toast.Show({
		Lane = "Banner",
		Text = text,
		Seconds = value or 2.5,
		SingleLine = true,
		Unique = true,
		Corrupted = true,
		PreText = v2 and {
			Text = `{p2}:`,
			Color = Kit.Green,
			StrokeColor = color
		} or nil
	})
end

function Presentation:SetCountdown(p: string?)
	if p == nil then
		if self.StopCountdownGlitch then
			self.StopCountdownGlitch()
			self.StopCountdownGlitch = nil
		end

		self.Countdown.Visible = false
		self.TimerFrame.Visible = true
		self.CountdownText = ""
	else
		local countdownBody = self.CountdownBody

		if p ~= self.CountdownText then
			self.CountdownText = p
			countdownBody.Text = p
		end

		local v2 = math.max(self.BossScale.Scale, 0.01)
		local textSize = math.floor(self.CountdownPlate.AbsoluteSize.Y / v2)

		if textSize > 0 and countdownBody.TextSize ~= textSize then
			countdownBody.TextSize = textSize
		end

		self.TimerFrame.Visible = false
		self.Countdown.Visible = true

		if self.StopCountdownGlitch == nil then
			self.StopCountdownGlitch = CorruptedPlate.Attach(self.Countdown, self.CountdownPlate)
		end
	end
end

function Presentation:FlashScreen(backgroundColor: Color3, duration: number, value: number?)
	self.Flash.BackgroundColor3 = backgroundColor
	self.Flash.BackgroundTransparency = 1 - (value or 0.6)
	TweenService:Create(self.Flash, TweenInfo.new(duration), {
		BackgroundTransparency = 1
	}):Play()
end

function Presentation:CrocTarget(p: number, duration: number)
	for k, reticle in self.Reticles do
		reticle:Destroy()
		self.Reticles[k] = nil
	end

	local playerByUserId = Players:GetPlayerByUserId(p)
	local humanoidRootPart = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChild("HumanoidRootPart")
	local v2 = humanoidRootPart and Vfx.Stamp("CrocTarget", humanoidRootPart, duration, true)

	if playerByUserId and v2 then
		self.Reticles[playerByUserId] = v2
		task.delay(duration, function()
			if self.Reticles[playerByUserId] == v2 then
				v2:Destroy()
				self.Reticles[playerByUserId] = nil
			end
		end)
	end

	if p == localPlayer.UserId then
		self.CrocTargetUntil = os.clock() + duration
		Kit.Sound("Tick", nil, 1, 1.4)
		self:FlashScreen(Kit.Red, 0.5, 0.35)
	end
end

function Presentation:Step(p: number)
	local arena = self.Arena
	local v2 = self:InArena()
	self.Gui.Enabled = v2

	if v2 ~= self.Lit then
		self.Lit = v2

		if v2 and LightingController.Presets.DrScramble then
			LightingController.SetLayer("ScrambleBoss", "DrScramble", 160, 2)
		else
			LightingController.ClearLayer("ScrambleBoss", 2)
		end
	end

	if v2 then
		local phase = arena:GetAttribute("Phase") or "Waiting"
		self.BossName.Text = v[phase] or "DR. SCRAMBLE"
		local v3 = 1
		local text = ""
		local v5 = nil

		if phase == "Waiting" then
			local spawnsAt = arena:GetAttribute("SpawnsAt") or 0
			local v6 = math.ceil((math.max(0, spawnsAt - Workspace:GetServerTimeNow())))
			text = not (spawnsAt > 0) and "WAITING FOR CHALLENGERS" or `ARRIVING IN {v6}`
			local v7 = v6 == 1 and "second" or "seconds"

			if spawnsAt > 0 then
				v5 = `The battle will begin in <font color="#{hex}">{v6}</font> {v7}`
			else
				v5 = "Waiting for challengers"
			end
		elseif phase == "Mech" or phase == "Ejecting" then
			local health = arena:GetAttribute("Health") or 0
			local v6 = math.max(arena:GetAttribute("MaxHealth") or 1, 1)
			v3 = health / v6
			text = `{math.floor(health)} / {math.floor(v6)} HP`
			local mech = arena:FindFirstChild("Mech")
			local overheated = mech and mech:GetAttribute("Overheated")
			self.TimerTitle.Text = "Phase"
			self.TimerLabel.Text = overheated and "OVERHEAT" or arena:GetAttribute("PhaseTwo") and "2/3" or "1/3"
		elseif phase == "Ball" then
			local coreStage = arena:GetAttribute("CoreStage") or 0

			if arena:GetAttribute("BallStunned") then
				local coreHealth = arena:GetAttribute("CoreHealth") or 0
				local v6 = math.max(arena:GetAttribute("CoreMax") or 1, 1)
				v3 = coreHealth / v6
				text = `CORE {coreHealth} / {v6}`
			else
				v3 = 1 - coreStage / 3
				text = `CORE DAMAGE {coreStage} / 3`
			end

			self.TimerTitle.Text = "Phase"
			self.TimerLabel.Text = "3/3"
		elseif phase == "Human" or phase == "Final" then
			local humanHits = arena:GetAttribute("HumanHits") or 0
			local v6 = math.max(arena:GetAttribute("HumanNeeded") or 3, 1)
			v3 = 1 - humanHits / v6
			text = `HIT HIM! {humanHits} / {v6}`
			self.TimerTitle.Text = "Phase"
			self.TimerLabel.Text = "FINAL"
		elseif phase == "Defeated" then
			self.TimerTitle.Text = "Phase"
			self.TimerLabel.Text = "WIN"
			v3 = 0
			text = "DEFEATED!"
		end

		self:SetCountdown(v5)
		local lastHealthFraction = math.clamp(v3, 0, 1)
		self.HealthText.Text = text
		local v7 = phase ~= self.LastPhase
		local v8 = lastHealthFraction < self.LastHealthFraction - 0.001

		if v7 or v8 then
			self:PunchHealth(v7)
		end

		self.LastPhase = phase
		self.LastHealthFraction = lastHealthFraction
		local healthTweenSpeed = self.Gui.BossHPBar:GetAttribute("HealthTweenSpeed") or 14
		local phantomTweenSpeed = self.Gui.BossHPBar:GetAttribute("PhantomTweenSpeed") or 2.5
		local v9 = GuiService.ReducedMotionEnabled and 1 or math.min(1, p * healthTweenSpeed)
		local v10 = GuiService.ReducedMotionEnabled and 1 or math.min(1, p * phantomTweenSpeed)
		self.DisplayedHealth += (lastHealthFraction - self.DisplayedHealth) * v9
		self.PhantomValue += (lastHealthFraction - self.PhantomValue) * v10
		self.Bar.Size = UDim2.fromScale(self.DisplayedHealth, 1)
		self.Phantom.Size = UDim2.fromScale(math.max(self.PhantomValue, self.DisplayedHealth), 1)
		self:SetPhaseSegments(lastHealthFraction)
		local ballTarget = arena:GetAttribute("BallTarget") or 0
		local ballCoil = arena:GetAttribute("BallCoil") or ""
		local spentCoil = arena:GetAttribute("SpentCoil") or ""
		local coils = arena:FindFirstChild("Coils")
		local v11

		if ballTarget == localPlayer.UserId then
			v11 = phase == "Ball"
		else
			v11 = false
		end

		local v12 = phase ~= "Mech" and 0 or arena:GetAttribute("GrabVictim") or 0
		local v13

		if v12 == 0 then
			v13 = false
		else
			v13 = v12 == localPlayer.UserId
		end

		local v14 = math.clamp(
			(arena:GetAttribute("GrabFree") or 0) / math.max(arena:GetAttribute("GrabNeeded") or 1, 1),
			0,
			1
		)

		if v11 then
			local v15 = math.max(0, (arena:GetAttribute("BallTargetEnds") or 0) - Workspace:GetServerTimeNow())
			self.Target.Visible = true
			self.TargetTitle.Text = "YOU'RE TARGETED!"
			self.TargetSub.Text = v15 > 0 and "Lead him into the glowing coil!" or "HE'S SPEEDING UP! GET TO THE COIL!"
			self.TargetCountdown.Text = string.format("%.2f", v15)
			local targetCountdown = self.TargetCountdown
			local textColor

			if v15 > 1.5 then
				textColor = Color3.fromRGB(255, 255, 255)
			else
				textColor = Kit.Red
			end

			targetCountdown.TextColor3 = textColor
		elseif v13 then
			self.Target.Visible = true
			self.TargetTitle.Text = "GRABBED!"
			local targetSub = self.TargetSub
			targetSub.Text = struggleHint()
			self.TargetCountdown.Text = `{math.floor(v14 * 100)}%`
			self.TargetCountdown.TextColor3 = Color3.new(1, 1, 1):Lerp(Kit.Green, v14)
		elseif os.clock() < self.CrocTargetUntil then
			self.Target.Visible = true
			self.TargetTitle.Text = "TARGETED!"
			self.TargetSub.Text = "The croc is coming for you. RUN!"
			self.TargetCountdown.Text = string.format("%.1f", self.CrocTargetUntil - os.clock())
			self.TargetCountdown.TextColor3 = Kit.Red
		elseif v12 == 0 then
			self.Target.Visible = false
		else
			local playerByUserId = Players:GetPlayerByUserId(v12)
			self.Target.Visible = true
			self.TargetTitle.Text = `SAVE {string.upper(playerByUserId and playerByUserId.DisplayName or "THEM")}!`
			self.TargetSub.Text = "Get under the claw and hit it!"
			self.TargetCountdown.Text = `{math.floor(v14 * 100)}%`
			self.TargetCountdown.TextColor3 = Color3.new(1, 1, 1):Lerp(Kit.Green, v14)
		end

		if coils then
			for _, child in coils:GetChildren() do
				local zone = child:FindFirstChild("Zone")
				local zoneRing = child:FindFirstChild("ZoneRing")
				local v15

				if child.Name == ballCoil then
					v15 = phase == "Ball"
				else
					v15 = false
				end

				local v16 = not v15

				if v16 then
					if child.Name == spentCoil then
						v16 = phase == "Ball"
					else
						v16 = false
					end
				end

				local midpoint = (math.sin(os.clock() * 6) + 1) / 2
				tintCoil(child, v15 and "Lit" or v16 and "Spent" or "Idle")

				if zone then
					zone.Transparency = not v15 and 0.8 or midpoint * 0.3 + 0.35
					local green

					if v15 then
						green = Kit.Green
					elseif v16 then
						green = color2
					else
						green = Color3.fromRGB(90, 220, 255)
					end

					zone.Color = green
				end

				if not zoneRing then
					continue
				end

				zoneRing.Transparency = v15 and 0 or 0.4
				local green

				if v15 then
					green = Kit.Green
				elseif v16 then
					green = color2
				else
					green = Color3.fromRGB(200, 250, 255)
				end

				zoneRing.Color = green
			end
		end

		local scrambleHuman = arena:FindFirstChild("ScrambleHuman")
		self:FadeHuman(
			scrambleHuman,
			phase == "Human" and scrambleHuman ~= nil and scrambleHuman:GetAttribute("Immune") == true
		)
		local mech = arena:FindFirstChild("Mech")
		local grabRescue = mech and mech:FindFirstChild("GrabRescue")

		if v11 and coils and coils:FindFirstChild(ballCoil) then
			local child = coils:FindFirstChild(ballCoil)
			local top = child:FindFirstChild("Top")

			if top and top:IsA("BasePart") then
				self:SetArrow(`coil:{ballCoil}`, top)
				return
			end

			local boundingBox, v16 = child:GetBoundingBox()
			self:SetArrow(`coil:{ballCoil}`, boundingBox.Position + Vector3.new(0, v16.Y / 2, 0))
		elseif v12 ~= 0 and not v13 and grabRescue then
			self:SetArrow("rescue", grabRescue)
		elseif mech and mech:GetAttribute("Overheated") and phase == "Mech" then
			self:SetArrow("mech", (mech:FindFirstChild("Torso")))
		elseif phase == "Ball" and arena:GetAttribute("BallStunned") then
			local ball = arena:FindFirstChild("Ball")
			self:SetArrow("ball", ball and ball.PrimaryPart or nil)
		else
			if phase ~= "Human" then
				self:SetArrow("", nil)
				return
			end

			local scrambleHuman2 = arena:FindFirstChild("ScrambleHuman")
			self:SetArrow("human", scrambleHuman2 and scrambleHuman2.PrimaryPart or nil)
		end
	else
		self:SetArrow("", nil)
		self:SetCountdown(nil)
	end
end

return Presentation