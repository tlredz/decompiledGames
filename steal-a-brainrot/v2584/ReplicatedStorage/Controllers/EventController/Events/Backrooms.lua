local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local localPlayer = Players.LocalPlayer
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local LightingController = require(ReplicatedStorage.Controllers.LightingController)
local WorldBrainrotController = require(ReplicatedStorage.Controllers.WorldBrainrotController)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local BackroomsSpeedData = require(ReplicatedStorage.Datas.BackroomsSpeedData)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local remoteFunction = Net:RemoteFunction("BackroomsService/RequestBuySpeed")
local remoteEvent = Net:RemoteEvent("BackroomsService/UpdateOwnedSpeedTier")
local _ = {
	Idle = "Idle",
	Walk = "Walk",
	Attack = "Attack"
}
local v = {
	Priority = 100,
	Ambient = Color3.fromRGB(110, 100, 80),
	OutdoorAmbient = Color3.fromRGB(90, 80, 60),
	Brightness = 2,
	ExposureCompensation = 0,
	EnvironmentDiffuseScale = 0.8,
	EnvironmentSpecularScale = 0.4,
	GlobalShadows = false,
	ColorCorrection = {
		TintColor = Color3.fromRGB(255, 235, 145),
		Brightness = -0.1,
		Saturation = -0.2,
		Contrast = 0.1
	}
}
local remoteEvent2 = Net:RemoteEvent("BackroomsService/RequestOwnedSpeedTier")
local currentCamera = workspace.CurrentCamera
local maid = Trove.new()
local v2 = {}
local color = Color3.fromRGB(255, 242, 153)
local color2 = Color3.fromRGB(255, 30, 30)
local random = Random.new()
local color3 = Color3.new(0, 0, 0)

local function attachLight(parent, color4: Color3?, value: number?, value2: number?, value3: number?)
	local attachment = Instance.new("Attachment")
	attachment.Name = "BackroomsAttachment"
	attachment.CFrame = CFrame.new(0, value3 or 3, 0)
	local pointLight = Instance.new("PointLight")
	pointLight.Name = "BackroomsPointLight"
	pointLight.Brightness = value or 3
	pointLight.Color = color4 or color
	pointLight.Range = value2 or 12
	pointLight.Parent = attachment
	attachment.Parent = parent
	return function()
		attachment:Destroy()
		pointLight:Destroy()
	end, pointLight
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startLightFlicker(p, fn)
	task.spawn(function()
		task.wait(random:NextNumber(0, 8))

		while p.Parent do
			local v3

			if fn then
				local v4 = fn()

				if v4 == nil then
					v3 = false
				else
					v3 = v4 < 30
				end
			else
				v3 = false
			end

			task.wait(random:NextNumber(v3 and 0.4 or 8, v3 and 1.5 or 25))

			if not p.Parent then
				break
			end

			for _ = 1, random:NextInteger(v3 and 4 or 2, v3 and 10 or 6) do
				if not p.Parent then
					return
				end

				p.Enabled = false
				task.wait(random:NextNumber(0.04, 0.18))

				if not p.Parent then
					return
				end

				p.Enabled = true
				task.wait(random:NextNumber(0.04, 0.18))
			end
		end
	end)
end

local function isInsideLightingArea(position: Vector3)
	for k in v2 do
		local pointToObjectSpace = k.CFrame:PointToObjectSpace(position)
		local size = k.Size

		if math.abs(pointToObjectSpace.X) <= size.X * 0.5 and math.abs(pointToObjectSpace.Y) <= size.Y * 0.5 and math.abs(pointToObjectSpace.Z) <= size.Z * 0.5 then
			return true
		end
	end

	return false
end

local v3 = nil
local v4 = {
	"ColorCorrectionEffect",
	"BlurEffect",
	"BloomEffect",
	"SunRaysEffect",
	"DepthOfFieldEffect"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isSuppressedCameraEffect(instance)
	for _, className in v4 do
		if instance:IsA(className) then
			return true
		end
	end

	return false
end

local function applyLighting()
	if v3 then
		return
	end

	local maid2 = Trove.new()
	v3 = maid2
	maid2:Add(LightingController:Push("Backrooms", v))
	localPlayer:SetAttribute("BackroomsCaveInside", true)
	maid2:Add(function()
		localPlayer:SetAttribute("BackroomsCaveInside", nil)
	end)
	local sunRaysEffect = Lighting:FindFirstChildOfClass("SunRaysEffect")
	local clockTime = Lighting.ClockTime
	local intensity

	if sunRaysEffect then
		intensity = sunRaysEffect.Intensity
	else
		intensity = nil
	end

	local flag = false
	local flag2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setClockTime(clockTime2: number)
		flag = true
		Lighting.ClockTime = clockTime2
		flag = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setSunRaysIntensity(intensity2: number)
		if not sunRaysEffect then
			return
		end

		flag2 = true
		sunRaysEffect.Intensity = intensity2
		flag2 = false
	end

	setClockTime(0) -- equivalent call inferred; original call site unknown
	setSunRaysIntensity(0) -- equivalent call inferred; original call site unknown
	maid2:Add(RunService.PreRender:Connect(function()
		if flag then
			return
		end

		setClockTime(0) -- equivalent call inferred; original call site unknown
	end))

	if sunRaysEffect then
		maid2:Add(sunRaysEffect:GetPropertyChangedSignal("Intensity"):Connect(function()
			if flag2 then
				return
			end

			setSunRaysIntensity(0) -- equivalent call inferred; original call site unknown
		end))
	end

	maid2:Add(function()
		setClockTime(clockTime) -- equivalent call inferred; original call site unknown

		if intensity ~= nil then
			setSunRaysIntensity(intensity) -- equivalent call inferred; original call site unknown
		end
	end)

	if currentCamera then
		local enabledsByState = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function suppress(child)
			if enabledsByState[child] ~= nil then
				return
			end

			-- equivalent call inferred; original call site unknown
			if not (isSuppressedCameraEffect(child) and string.sub(child.Name, 1, 19) ~= "LightingController_") then
				return
			end

			enabledsByState[child] = child.Enabled
			child.Enabled = false
		end

		for _, child in currentCamera:GetChildren() do
			suppress(child) -- equivalent call inferred; original call site unknown
		end

		maid2:Add(currentCamera.ChildAdded:Connect(suppress))
		maid2:Add(function()
			for k, enabled in enabledsByState do
				if k.Parent then
					k.Enabled = enabled
				end
			end

			table.clear(enabledsByState)
		end)
	end

	maid2:Add(Observers.observeTag("MapVFX", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	maid2:Add(Observers.observeCharacters(function(_, instance)
		local maid3 = Trove.new()
		maid3:Add(task.spawn(function()
			local upperTorso = instance:WaitForChild("UpperTorso", 10)

			if not upperTorso then
				return
			end

			maid3:Add((attachLight(upperTorso)))
		end))
		return maid3:WrapClean()
	end))
	local renderedMovingAnimals = workspace:FindFirstChild("RenderedMovingAnimals")

	if renderedMovingAnimals then
		maid2:Add(Observers.observeChildren(renderedMovingAnimals, function(instance)
			local maid3 = Trove.new()
			maid3:Add(task.spawn(function()
				local rootPart = instance:WaitForChild("RootPart", 10)

				if not rootPart then
					return
				end

				maid3:Add((attachLight(rootPart)))
			end))
			return maid3:WrapClean()
		end))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeLighting()
	if not v3 then
		return
	end

	v3:Destroy()
	v3 = nil
end

local function startSpeedShop()
	local backroomsSpeedUpgrade = localPlayer.PlayerGui:WaitForChild("BackroomsSpeedUpgrade", 30)

	if not backroomsSpeedUpgrade then
		warn("[Backrooms] PlayerGui.BackroomsSpeedUpgrade missing — speed shop disabled")
		return
	end

	local backroomsSpeedUpgrade2 = backroomsSpeedUpgrade:WaitForChild("BackroomsSpeedUpgrade", 5)

	if not backroomsSpeedUpgrade2 then
		warn("[Backrooms] BackroomsSpeedUpgrade.BackroomsSpeedUpgrade frame missing")
		return
	end

	local backroomsSpeedShop = InterfaceController:Get("BackroomsSpeedShop")
	local v5 = backroomsSpeedShop or InterfaceController:Register(
		"BackroomsSpeedShop",
		backroomsSpeedUpgrade2,
		"TopQuint"
	)

	if not v5 then
		warn("[Backrooms] failed to get/register BackroomsSpeedShop interface")
		return
	end

	if not backroomsSpeedShop then
		v5:AttachCloseButton(backroomsSpeedUpgrade2.Header.Close)
	end

	InterfaceController:SetState("BackroomsSpeedShop", false)
	maid:Add(function()
		InterfaceController:SetState("BackroomsSpeedShop", false)
	end)
	local v6 = Synchronizer:Wait(localPlayer)

	if not v6 then
		return
	end

	local list = backroomsSpeedUpgrade2.Content.List
	local template = list.Template
	local v7 = {}
	local v8 = 0

	for k, upgrade in BackroomsSpeedData.upgrades do
		local clone = template:Clone()
		clone.Name = tostring(k)
		clone.LayoutOrder = k
		clone.Frame.Label.Text = `+{upgrade} Speed`
		clone.Visible = true
		clone.Parent = list
		maid:Add(clone)
		local v9 = {
			copy = clone,
			amount = upgrade,
			locked = false
		}
		table.insert(v7, v9)
		local v10 = AnimatedButton.new(clone.Frame.Buy)
		v10:Animate()
		maid:Add(v10)
		local v12 = upgrade
		maid:Add(v10.OnActivated:Connect(function()
			if v9.locked then
				return
			end

			remoteFunction:InvokeServer(v12)
		end))
	end

	local function findLocked(instance)
		local locked = instance:FindFirstChild("Locked") or instance.Frame:FindFirstChild("Locked")
		return locked, locked and locked:FindFirstChild("Txt")
	end

	local function updateRow(state)
		local rebirth = v6:Get("Rebirth") or 0
		local v9 = type(rebirth) ~= "number" and 0 or rebirth
		local requiredRebirthForAmount = BackroomsSpeedData.getRequiredRebirthForAmount(v8 + state.amount)
		local v10 = requiredRebirthForAmount <= v9
		state.locked = not v10
		local copy = state.copy
		local locked = copy:FindFirstChild("Locked") or copy.Frame:FindFirstChild("Locked")
		local txt = locked and locked:FindFirstChild("Txt")

		if locked then
			locked.Visible = not v10

			if not v10 and txt then
				txt.Text = `YOU NEED {requiredRebirthForAmount} REBIRTHS`
			end
		end

		local canBuy = BackroomsSpeedData.canBuy(v8, state.amount, v9)
		local upgradeCost = BackroomsSpeedData.getUpgradeCost(v8, state.amount)
		state.copy.Frame.PreviousAmount.Text = NumberUtils:Comma(BackroomsSpeedData.getTotalSpeed(v8))
		local maxUpgradesForRebirth = BackroomsSpeedData.getMaxUpgradesForRebirth(v9)
		state.copy.Frame.TargetAmount.Text = NumberUtils:Comma(BackroomsSpeedData.getTotalSpeed((math.min(
			v8 + state.amount,
			maxUpgradesForRebirth
		))))

		if canBuy then
			state.copy.Frame.Buy.Price.Text = `Buy (${NumberUtils:ToString(upgradeCost)})`
		else
			state.copy.Frame.Buy.Price.Text = "MAX"
		end

		local coins = v6:Get("Coins")
		local v11

		if type(coins) == "number" then
			v11 = upgradeCost <= coins
		else
			v11 = false
		end

		local target = Spr.target
		local buy = state.copy.Frame.Buy
		local backgroundColor

		if v10 and canBuy and v11 then
			backgroundColor = Color3.fromRGB(81, 158, 86)
		else
			backgroundColor = Color3.fromRGB(158, 158, 158)
		end

		target(buy, 1, 5, {
			BackgroundColor3 = backgroundColor
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateAll()
		for _, v9 in v7 do
			updateRow(v9)
		end
	end

	maid:Add(remoteEvent.OnClientEvent:Connect(function(value: number?)
		v8 = value or 0
		updateAll() -- equivalent call inferred; original call site unknown
	end))
	maid:Add(v6:OnChanged("Coins", updateAll))
	maid:Add(v6:OnChanged("Rebirth", updateAll))
	task.spawn(updateAll)
	task.spawn(function()
		remoteEvent2:FireServer()
	end)
end

local Backrooms = {}

function Backrooms.OnStart(_)
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	local clone = maid:Clone(script.BackroomsMapWalls)
	clone.Parent = workspace
	maid:Add(function()
		SoundController:UpdateAmbience()
	end)
	SoundController:UpdateAmbience()
	EffectController:Run("BackroomsEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("BackroomsEvent", "GrassRecolor")
	end)
	maid:Add(Observers.observeTag("BackroomsLightingArea", function(part)
		if not part:IsA("BasePart") then
			return nil
		end

		v2[part] = true
		return function()
			v2[part] = nil
		end
	end, { workspace }))
	maid:Add(function()
		table.clear(v2)
	end)
	maid:Add(Timer.Simple(0.016666666666666666, function()
		if currentCamera and isInsideLightingArea(currentCamera.CFrame.Position) then
			applyLighting()
			return
		end

		removeLighting() -- equivalent call inferred; original call site unknown
	end, true))
	maid:Add(removeLighting)
	local renderedBrainrots = {}
	local v6 = ReplicatorClient.get("Backrooms/Brainrots")
	maid:Add(WorldBrainrotController:RenderPool({
		PoolId = "Backrooms/Brainrots",
		ReplicatorId = "Backrooms/Brainrots",
		ShowTimer = true,
		ShowDropButton = true,
		GrabHoldDuration = 1.5,
		GrabMaxDistance = 10,
		KeepWhenGrabbed = false,
		RenderedBrainrots = renderedBrainrots,
		OnRendered = function(p: string)
			local v7 = renderedBrainrots[p]

			if not (v7 and v7.model and v7.model.PrimaryPart) then
				return
			end

			local _, v8 = attachLight(v7.model.PrimaryPart, color, 3, 16, 2)

			local function fn()
				local v9 = v6:TryIndex({ "brainrots", p })

				if v9 then
					return v9.despawnTimer
				end

				return nil
			end

			startLightFlicker(v8, fn) -- equivalent call inferred; original call site unknown
		end
	}))
	maid:Add(Observers.observeTag("BackroomsSpeedShop", function(proximityPrompt)
		if not proximityPrompt:IsA("ProximityPrompt") then
			return nil
		end

		local triggeredConnection = proximityPrompt.Triggered:Connect(function()
			InterfaceController:Toggle("BackroomsSpeedShop")
		end)
		return function()
			triggeredConnection:Disconnect()
		end
	end))
	maid:Add(Observers.observeTag("BackroomsSammy", function(model)
		if not model:IsA("Model") then
			return nil
		end

		local maid2 = Trove.new()
		maid2:Add(task.spawn(function()
			local v7 = os.clock() + 10
			local humanoidRootPart = nil

			while os.clock() < v7 do
				humanoidRootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("RootPart") or model.PrimaryPart

				if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					break
				end

				task.wait(0.1)
				humanoidRootPart = nil
			end

			if not humanoidRootPart then
				return
			end

			local backroomsSammyTier = model:GetAttribute("BackroomsSammyTier")
			maid2:Add((attachLight(
				humanoidRootPart,
				color2,
				4,
				backroomsSammyTier == 1 and 22 or backroomsSammyTier == 3 and 40 or 32,
				2
			)))
		end))
		maid2:Add(task.spawn(function()
			local animationController = model:WaitForChild("AnimationController", 10)

			if not animationController then
				return
			end

			local animator = animationController:WaitForChild("Animator", 10)

			if not animator then
				return
			end

			local animations = model:WaitForChild("Animations", 10)

			if not animations then
				return
			end

			local function loadAnim(childName: string, looped: boolean, priority)
				local animation = animations:FindFirstChild(childName)

				if not (animation and animation:IsA("Animation")) then
					return nil
				end

				local track = animator:LoadAnimation(animation)
				track.Looped = looped
				track.Priority = priority
				maid2:Add(function()
					track:Stop(0)
					track:Destroy()
				end)
				return track
			end

			local v7 = loadAnim("Idle", true, Enum.AnimationPriority.Idle)
			local v8 = loadAnim("Walk", true, Enum.AnimationPriority.Movement)
			local v9 = loadAnim("Attack", false, Enum.AnimationPriority.Action)
			local v10 = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function playLoopTrack(p)
				if v10 == p then
					return
				end

				if v10 then
					v10:Stop(0.2)
				end

				v10 = p

				if v10 then
					v10:Play(0.2)
				end
			end

			local function applyWalkState()
				if model:GetAttribute("Walking") then
					playLoopTrack(v8) -- equivalent call inferred; original call site unknown
				else
					playLoopTrack(v7) -- equivalent call inferred; original call site unknown
				end
			end

			if model:GetAttribute("Walking") then
				playLoopTrack(v8) -- equivalent call inferred; original call site unknown
			else
				playLoopTrack(v7) -- equivalent call inferred; original call site unknown
			end

			maid2:Add(model:GetAttributeChangedSignal("Walking"):Connect(applyWalkState))
			maid2:Add(model:GetAttributeChangedSignal("BackroomsAttackCounter"):Connect(function()
				if v9 then
					v9:Play(0.1)
				end
			end))
		end))
		return maid2:WrapClean()
	end, { workspace }))
	maid:Add(Observers.observeTag("HideInBackrooms", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	maid:Add(Observers.observeTag("BackroomsFlicker", function(light)
		if not light:IsA("SpotLight") then
			return nil
		end

		local parent = light.Parent

		if not (parent and parent:IsA("BasePart")) then
			return nil
		end

		local color4 = parent.Color
		local maid2 = Trove.new()
		maid2:Add(function()
			parent.Color = color4
			light.Enabled = true
		end)
		maid2:Add(task.spawn(function()
			task.wait(random:NextNumber(0, 8))

			while true do
				task.wait(random:NextNumber(8, 25))

				for _ = 1, random:NextInteger(2, 6) do
					parent.Color = color3
					light.Enabled = false
					task.wait(random:NextNumber(0.04, 0.18))
					parent.Color = color4
					light.Enabled = true
					task.wait(random:NextNumber(0.04, 0.18))
				end
			end
		end))
		return maid2:WrapClean()
	end, { workspace }))
	startSpeedShop()
end

function Backrooms.OnStop(_)
	maid:Destroy()
end

function Backrooms.OnLoad(_) end

return Backrooms