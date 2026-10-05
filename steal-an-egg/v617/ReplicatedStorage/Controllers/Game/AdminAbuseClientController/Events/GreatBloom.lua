local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
require(ReplicatedStorage.Shared.Globals.Constants)
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local GUI = require(ReplicatedStorage.Client.GUI)
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Lanes = require(ReplicatedStorage.Client.Notifications.Lanes)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Sakura = require(ReplicatedStorage.Data.Sakura)
local SakuraBloomPolicy = require(ReplicatedStorage.Client.Modules.SakuraBloomPolicy)
local SakuraBloomVisibility = require(ReplicatedStorage.Client.SakuraBloomVisibility)
local SakuraFX = require(ReplicatedStorage.Client.SakuraFX)
local SakuraSignals = require(ReplicatedStorage.Client.SakuraSignals)
local Save = require(ReplicatedStorage.Shared.Save)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)

if not GameFlags.GreatBloomEnabled:Get() then
	return {
		StartEvent = function() end,
		StopEvent = function() end
	}
end

local color = Color3.fromRGB(255, 120, 200)
local color2 = Color3.fromRGB(120, 20, 70)
local color3 = Color3.fromRGB(255, 170, 220)
local color4 = Color3.fromRGB(120, 255, 140)
local color5 = Color3.fromRGB(255, 90, 110)
local localPlayer = Players.LocalPlayer
local currentCamera = Workspace.CurrentCamera
local sakura = ReplicatedStorage.Assets.Models.Sakura
local bloomWaypoint = sakura.BloomWaypoint
assert(bloomWaypoint:IsA("BillboardGui"), "Sakura.BloomWaypoint must be a BillboardGui")
local sparkles = ReplicatedStorage.Assets.VFX.Sakura.Hit:FindFirstChild("Sparkles")
assert(sparkles and sparkles:IsA("ParticleEmitter"), "VFX.Sakura.Hit.Sparkles must be a ParticleEmitter")
local crystal = sakura.Crystal
assert(crystal:IsA("Model") and crystal.PrimaryPart, "Sakura.Crystal needs a PrimaryPart")
local name = crystal.PrimaryPart.Name
local bounds = Workspace:WaitForChild("World"):WaitForChild("Areas"):WaitForChild("CherryBlossom"):WaitForChild("Bounds")
assert(bounds:IsA("BasePart"), "CherryBlossom.Bounds must be a BasePart")
local sakuraEventTutorialFrame = GUI.SakuraEventTutorialFrame()
local sakuraEventTutorialFrame2 = sakuraEventTutorialFrame.SakuraEventTutorialFrame
assert(sakuraEventTutorialFrame2:IsA("Frame"), "SakuraEventTutorialFrame.SakuraEventTutorialFrame must be a Frame")
local ok = sakuraEventTutorialFrame2.Ok
assert(ok:IsA("ImageButton"), "SakuraEventTutorialFrame.Ok must be an ImageButton")
local greatBloomBanner = GUI.GreatBloomBanner()
local banner = greatBloomBanner:FindFirstChild("Banner")
assert(banner and banner:IsA("Frame"), "GreatBloomBanner needs a Banner Frame")
local position = banner.Position
local count = 0
local sakuraCrystalCounter = GUI.SakuraCrystalCounter()
local guiObject = sakuraCrystalCounter:FindFirstChildWhichIsA("GuiObject")
assert(guiObject, "SakuraCrystalCounter needs a root Frame")
local count2 = sakuraCrystalCounter:FindFirstChild("Count", true)
assert(count2 and count2:IsA("TextLabel"), "SakuraCrystalCounter needs a TextLabel named Count")
local gain = sakuraCrystalCounter:FindFirstChild("Gain", true)
local uIScale = guiObject:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
uIScale.Parent = guiObject
local position2 = guiObject.Position
local v = false
local uIStroke

if gain then
	uIStroke = gain:FindFirstChildOfClass("UIStroke")
else
	uIStroke = nil
end

local position3

if gain then
	position3 = gain.Position
else
	position3 = UDim2.new()
end

local v2 = {}
local flag = false
local count3 = 0

for _, descendant in ipairs(guiObject:GetDescendants()) do
	if not (not gain or descendant ~= gain and not descendant:IsDescendantOf(gain)) then
		continue
	end

	if descendant:IsA("TextLabel") then
		table.insert(v2, {
			Instance = descendant,
			Property = "TextTransparency",
			Value = descendant.TextTransparency
		})
		table.insert(v2, {
			Instance = descendant,
			Property = "TextStrokeTransparency",
			Value = descendant.TextStrokeTransparency
		})
	elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
		table.insert(v2, {
			Instance = descendant,
			Property = "ImageTransparency",
			Value = descendant.ImageTransparency
		})
	elseif descendant:IsA("UIStroke") then
		table.insert(v2, {
			Instance = descendant,
			Property = "Transparency",
			Value = descendant.Transparency
		})
	end

	if descendant:IsA("GuiObject") and descendant.BackgroundTransparency < 1 then
		table.insert(v2, {
			Instance = descendant,
			Property = "BackgroundTransparency",
			Value = descendant.BackgroundTransparency
		})
	end
end

if guiObject.BackgroundTransparency < 1 then
	table.insert(v2, {
		Instance = guiObject,
		Property = "BackgroundTransparency",
		Value = guiObject.BackgroundTransparency
	})
end

local v3 = 0
local v4 = nil
local total = 0
local maid = Trove.new()
local v5 = CameraShaker.new(Enum.RenderPriority.Camera.Value + 2, function(cframe: CFrame)
	currentCamera.CFrame *= cframe
end)
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = {}
local v14 = {}
local v15 = {}
local v16 = {}
local v17 = {}
local v18 = {}
local v19 = 0
local v20 = false
local flag2 = false
local flag3 = false
local v21 = nil
local v22 = nil
local v23 = nil
local v24 = false
local flag4 = false
local v25 = false
local v26 = {}
local GreatBloom = {}

local function isUnlocked()
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	return SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27)
end

local function shouldPresent()
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	return SakuraBloomPolicy.CanShowBloom(v20, isLoaded, v27)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setBloomInstanceHidden(p, flag5: boolean)
	local v27 = v26[p]

	if v27 then
		v27:Clean()
		v26[p] = nil
	end

	if not flag5 then
		return
	end

	v26[p] = SakuraBloomVisibility.Conceal(p)
end

local function setWorldVFXEnabled(enabled: boolean)
	for _, folder in CollectionService:GetTagged("GreatBloomVFX") do
		for _, effect in folder:GetDescendants() do
			if effect:IsA("Beam") or effect:IsA("ParticleEmitter") then
				effect.Enabled = enabled
			end
		end
	end
end

local function refreshReplicatedVisibility()
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	local hasBloomUnlocked = SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27)

	for _, v28 in CollectionService:GetTagged(Sakura.TreeTag) do
		setBloomInstanceHidden(v28, not hasBloomUnlocked) -- equivalent call inferred; original call site unknown
	end

	for _, v28 in CollectionService:GetTagged(Sakura.CrystalTag) do
		setBloomInstanceHidden(v28, not hasBloomUnlocked) -- equivalent call inferred; original call site unknown
	end

	setWorldVFXEnabled(v20 and hasBloomUnlocked)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function distanceFromCharacter(vector2: Vector3)
	local primaryPart = Player.FindPrimaryPart(localPlayer)

	if primaryPart == nil then
		return 1e999
	end

	return (primaryPart.Position - vector2).Magnitude
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shakeIfNear(vector2: Vector3, spawnShakeRadius: number, p: number, p2: number)
	if distanceFromCharacter(vector2) <= spawnShakeRadius then
		v5:ShakeOnce(p, p2, 0.1, 0.6)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notifyTop(formatted: string, seconds: number)
	Toast.Show({
		Lane = "Banner",
		Text = formatted,
		Color = color,
		StrokeColor = color2,
		Seconds = seconds
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showBanner()
	count += 1
	local v27 = count
	local holdBanner = Lanes.HoldBanner()
	task.spawn(function()
		while Lanes.IsBannerShowing() and count == v27 do
			task.wait(0.1)
		end

		if count ~= v27 then
			holdBanner()
			return
		end

		local position4 = position - UDim2.fromScale(0, position.Y.Scale + banner.Size.Y.Scale)
		banner.Position = position4
		greatBloomBanner.Enabled = true
		TweenService:Create(banner, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = position
		}):Play()
		task.wait(7)

		if count ~= v27 then
			holdBanner()
			return
		end

		local tween = TweenService:Create(banner, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = position4
		})
		tween.Completed:Once(function()
			if count == v27 then
				greatBloomBanner.Enabled = false
			end

			holdBanner()
		end)
		tween:Play()
	end)
end

local function showCrystalPopup(p: number, vector2: Vector3)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = vector2 + createVector(0, 4, 0)
	part.Parent = Workspace
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.fromOffset(140, 40)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = part
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.TextScaled = true
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0.2
	textLabel.Text = `+{Simple.FormatCompact(p)} Crystals`
	textLabel.Parent = billboardGui
	TweenService:Create(part, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = part.Position + createVector(0, 6, 0)
	}):Play()
	TweenService:Create(textLabel, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()
	Debris:AddItem(part, 1.2000000000000002)
end

local function setCounterShown(flag5: boolean, duration: number)
	local quad = Enum.EasingStyle.Quad
	local v27

	if flag5 then
		v27 = Enum.EasingDirection.Out
	else
		v27 = Enum.EasingDirection.In
	end

	local tweenInfo = TweenInfo.new(duration, quad, v27)

	for _, v28 in v2 do
		TweenService:Create(v28.Instance, tweenInfo, {
			[v28.Property] = not flag5 and 1 or v28.Value
		}):Play()
	end

	if flag5 == v then
		return
	end

	v = flag5
	local uDim = UDim2.fromScale(0, -guiObject.Size.Y.Scale * 0.6)

	if flag5 then
		sakuraCrystalCounter.Enabled = true
		guiObject.Position = position2 + uDim
		uIScale.Scale = 0.8
		TweenService:Create(guiObject, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = position2
		}):Play()
		TweenService:Create(uIScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	else
		TweenService:Create(guiObject, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = position2 + uDim
		}):Play()
		TweenService:Create(uIScale, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Scale = 0.85
		}):Play()
		task.delay(duration, function()
			if not v then
				sakuraCrystalCounter.Enabled = false
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideCounter()
	setCounterShown(false, 0.5)
	total = 0
	flag = false
end

local function animateGain(total2: number)
	local label = gain

	if label == nil or not label:IsA("TextLabel") then
		return
	end

	count3 += 1
	local v27 = count3
	local v28 = total2 > 0
	label.Text = `{v28 and "+" or "-"}{Simple.FormatCompact((math.abs(total2)))}`
	local textColor

	if v28 then
		textColor = color4
	else
		textColor = color5
	end

	label.TextColor3 = textColor
	local v30 = label.Size.Y.Scale * 0.9
	local v31 = v28 and -1 or 1
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	if flag then
		label.Position = position3 + UDim2.fromScale(0, -v31 * v30 * 0.2)
		TweenService:Create(label, tweenInfo, {
			TextTransparency = 0,
			Position = position3
		}):Play()
	else
		label.Position = position3 + UDim2.fromScale(0, -v31 * v30 * 0.5)
		label.TextTransparency = 1

		if uIStroke then
			uIStroke.Transparency = 1
		end

		TweenService:Create(label, tweenInfo, {
			TextTransparency = 0,
			Position = position3
		}):Play()

		if uIStroke then
			TweenService:Create(uIStroke, tweenInfo, {
				Transparency = 0
			}):Play()
		end
	end

	flag = true
	task.delay(1.8000000000000003, function()
		if count3 ~= v27 then
			return
		end

		flag = false
		local tweenInfo2 = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(label, tweenInfo2, {
			TextTransparency = 1,
			Position = position3 + UDim2.fromScale(0, v31 * v30)
		}):Play()

		if uIStroke then
			TweenService:Create(uIStroke, tweenInfo2, {
				Transparency = 1
			}):Play()
		end
	end)
end

local function popCounter()
	local v27 = Save.Await()

	if v27 == nil then
		return
	end

	local sakuraCrystals = v27.SakuraCrystals
	local v28 = v4
	v4 = sakuraCrystals

	if v28 == nil or sakuraCrystals == v28 then
		return
	end

	local v29 = sakuraCrystals - v28
	local serverTimeNow = Workspace:GetServerTimeNow()

	if v3 < serverTimeNow or total > 0 ~= (v29 > 0) then
		total = 0
	end

	total += v29
	count2.Text = Simple.FormatCompact(sakuraCrystals)
	animateGain(total)
	v3 = Workspace:GetServerTimeNow() + 2.2
	local v30 = v
	setCounterShown(true, 0.15)

	if v30 then
		uIScale.Scale = 1.12
		TweenService:Create(uIScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	end

	task.delay(2.2, function()
		local serverTimeNow2 = Workspace:GetServerTimeNow()

		if v3 - 0.05 <= serverTimeNow2 then
			hideCounter() -- equivalent call inferred; original call site unknown
		end
	end)
end

local function decorateTree(parent)
	local primaryPart = parent.PrimaryPart
	assert(primaryPart, (`{parent.Name} needs a PrimaryPart`))
	local highlight = Instance.new("Highlight")
	highlight.Name = "BloomOutline"
	highlight.FillColor = Color3.new(0, 0, 0)
	highlight.FillTransparency = 1
	highlight.OutlineColor = color3
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Enabled = false
	highlight.Parent = parent
	v10[parent] = highlight
	local clone = sparkles:Clone()
	clone.Name = "BloomSparkles"
	clone.Rate = 14
	clone.Enabled = true
	clone.Parent = primaryPart
end

-- equivalent calls inferred from this helper; original call sites unknown
local function damageFraction(instance)
	local hits = instance:GetAttribute("Hits")
	local hitsRequired = instance:GetAttribute("HitsRequired")

	if typeof(hits) == "number" and typeof(hitsRequired) == "number" and not (hitsRequired <= 1) then
		return (math.clamp(hits / hitsRequired, 0, 1))
	end

	return 0
end

local function renderDamage(instance)
	local v27 = v10[instance]

	if v27 == nil then
		return
	end

	TweenService:Create(v27, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FillTransparency = 1 - damageFraction(instance) * 0.85
	}):Play()
end

local function shakeTree(instance)
	local v27 = v7[instance]

	if v27 == nil or v9[instance] then
		return
	end

	local v28 = (v8[instance] or 0) + 1
	v8[instance] = v28
	local radius = instance:GetAttribute("Radius")
	local v29 = math.clamp((typeof(radius) ~= "number" and 10 or radius) / 10, 0.8, 1.6) * 0.06981317007977318
	local v30 = math.random() * 100
	task.spawn(function()
		local total2 = 0

		while total2 < 0.7 and instance.Parent and v8[instance] == v28 do
			total2 += task.wait()
			local v31 = (1 - total2 / 0.7) ^ 2
			local v32 = total2 * 9
			local v33 = math.noise(v30, v32) * 2 * v29 * v31
			local v34 = math.noise(v32, v30) * 2 * v29 * v31
			instance:PivotTo(v27 * CFrame.Angles(v33, 0, v34))
		end

		if instance.Parent and v8[instance] == v28 then
			instance:PivotTo(v27)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clampTreeHeight(instance)
	local Y = instance:GetExtentsSize().Y

	if Y > 30 then
		instance:ScaleTo(instance:GetScale() * (30 / Y))
	end
end

local function growTree(model)
	if not model or model:GetAttribute("TreeLoaded") then
		warn(model, "already loaded")
		return
	end

	model:SetAttribute("TreeLoaded", true)
	v9[model] = true
	local scale = model:GetScale()
	task.spawn(function()
		model:ScaleTo(scale * 0.05)
		local total2 = 0

		while total2 < 0.55 and model.Parent do
			total2 += task.wait()
			local value = TweenService:GetValue(
				math.clamp(total2 / 0.55, 0, 1),
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			)
			model:ScaleTo(scale * math.max(0.05, value))
			clampTreeHeight(model) -- equivalent call inferred; original call site unknown
		end

		if model.Parent then
			model:ScaleTo(scale)
			clampTreeHeight(model) -- equivalent call inferred; original call site unknown
			decorateTree(model)
			renderDamage(model)
		end

		v9[model] = nil
	end)
end

local function fallTree(model, cframe: CFrame)
	local clone = model:Clone()
	clone.Name = "SakuraTreeFalling"
	clone:RemoveTag(Sakura.TreeTag)

	for _, tag in ipairs(clone:GetTags()) do
		clone:RemoveTag(tag)
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("ProximityPrompt") or descendant:IsA("BillboardGui") or descendant:IsA("ParticleEmitter") or descendant:IsA("Highlight") then
			descendant:Destroy()
		end
	end

	clone.Parent = Workspace
	local scale = clone:GetScale()
	local cframe2 = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	task.spawn(function()
		local total2 = 0

		while total2 < 0.6 do
			total2 += task.wait()
			local v27 = math.clamp(total2 / 0.6, 0, 1)
			local v28 = TweenService:GetValue(v27, Enum.EasingStyle.Quad, Enum.EasingDirection.In) * 0.6108652381980153
			clone:PivotTo(cframe * cframe2 * CFrame.Angles(v28, 0, 0) * cframe2:Inverse())
			clone:ScaleTo(scale * math.max(0.05, 1 - v27 * v27))
		end

		clone:Destroy()
	end)
end

local function onTreeHit(model)
	shakeTree(model)
	renderDamage(model)
	local position4 = model:GetPivot().Position
	local height = model:GetAttribute("Height")
	local v27 = position4 + Vector3.new(0, (typeof(height) ~= "number" and 20 or height) * 0.6, 0)
	SakuraFX.EmitBurst("Hit", v27, 30, 8)
	SakuraFX.PlayCue("TreeHit", position4, 0.9, 0.9 + math.random() * 0.2)
	shakeIfNear(position4, 30, 0.8, 6) -- equivalent call inferred; original call site unknown
end

local function updateHighlights()
	local primaryPart = Player.FindPrimaryPart(localPlayer)
	local v27 = {}

	for k, v28 in v10 do
		if k.Parent == nil then
			continue
		end

		local v29 = not primaryPart and 1e999 or (primaryPart.Position - k:GetPivot().Position).Magnitude
		local distance = damageFraction(k) > 0 and 0 or v29

		if distance <= 160 then
			table.insert(v27, {
				Tree = k,
				Distance = distance
			})
		else
			v28.Enabled = false
		end
	end

	table.sort(v27, function(a, b)
		return a.Distance < b.Distance
	end)

	for k, v28 in v27 do
		v10[v28.Tree].Enabled = k <= 24
	end
end

local function onTreeAdded(model)
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	if not SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27) or not model:IsA("Model") or model.Name == "SakuraTreeFalling" then
		return
	end

	local position4 = model:GetPivot().Position
	v6[model] = position4
	v7[model] = model:GetPivot()
	shakeIfNear(position4, Sakura.Bloom.SpawnShakeRadius, 1.5, 8) -- equivalent call inferred; original call site unknown
	SakuraFX.EmitBurst("Spawn", position4 + createVector(0, 1, 0), 40, 10)
	SakuraFX.PlayCue("TreeSpawn", position4, 0.7, 0.75)
	growTree(model)
	local connection = v11[model]

	if connection then
		connection:Disconnect()
	end

	v11[model] = model:GetAttributeChangedSignal("Hits"):Connect(function()
		onTreeHit(model)
	end)
end

local function onTreeRemoved(model)
	local v27 = v6[model]
	local v28 = v7[model]
	v6[model] = nil
	v7[model] = nil
	v8[model] = nil
	v9[model] = nil
	v10[model] = nil
	local connection = v11[model]

	if connection then
		connection:Disconnect()
		v11[model] = nil
	end

	if v27 == nil then
		return
	end

	if model:IsA("Model") and v28 then
		fallTree(model, v28)
	end

	shakeIfNear(v27, 60, 2, 10) -- equivalent call inferred; original call site unknown
	SakuraFX.EmitBurst("Break", v27 + createVector(0, 8, 0), 90, 12)
	SakuraFX.PlayCue("TreeBreak", v27, 1, 1)
end

local function onCrystalAdded(model)
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	if not (SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27) and model:IsA("Model")) then
		return
	end

	local primaryPart = model.PrimaryPart or model:WaitForChild(name, 5)

	if primaryPart == nil or model.Parent == nil or v13[model] then
		return
	end

	v13[model] = model:GetPivot()
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 1.2
	pointLight.Range = 8
	pointLight.Parent = primaryPart
	v14[model] = pointLight
	local owner = model:GetAttribute("Owner")
	local playerByUserId

	if typeof(owner) == "number" then
		playerByUserId = Players:GetPlayerByUserId(owner)
	end

	local origin = model:GetAttribute("Origin")

	if playerByUserId and typeof(origin) == "Vector3" then
		v15[model] = playerByUserId
		v16[model] = origin
		v17[model] = 0
		model:PivotTo(CFrame.new(origin))
	end
end

local function onCrystalRemoved(model)
	if model:IsA("Model") then
		v13[model] = nil
		v14[model] = nil
		v15[model] = nil
		v16[model] = nil
		v17[model] = nil
		v18[model] = nil
	end

	v12[model] = nil
end

local function hideCrystal(folder)
	v13[folder] = nil
	v18[folder] = nil

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
		elseif descendant:IsA("PointLight") then
			descendant.Enabled = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requestCollect(k, cframe: CFrame)
	task.spawn(function()
		if not Remotes.Bloomery.AskGatherPetal:InvokeServer(k) then
			task.wait(1)
			v12[k] = nil

			if k.Parent then
				v13[k] = cframe
				v18[k] = 0
			end
		end
	end)
end

local function animateCrystals(total2: number, dt: number)
	local primaryPart = Player.FindPrimaryPart(localPlayer)

	for k, v27 in v13 do
		if k.Parent == nil then
			continue
		end

		local v28 = v17[k]
		local v29 = v16[k]

		if v28 == nil or not v29 then
			local v30 = v15[k]
			local v31

			if v30 then
				v31 = Player.FindPrimaryPart(v30)
			end

			local v32 = v18[k]

			if v32 == nil or not v31 then
				local v33

				if primaryPart == nil then
					v33 = false
				else
					v33 = (primaryPart.Position - v27.Position).Magnitude <= 22
				end

				local v34 = math.sin(total2 * (v33 and 4 or 2) + v27.Position.X) * 0.35
				k:PivotTo(v27 * CFrame.new(0, v34, 0) * CFrame.Angles(0, total2 * 1.2 * (v33 and 2.5 or 1), 0))
				local v35 = v14[k]

				if v35 then
					v35.Brightness = not v33 and 1.2 or math.sin(total2 * 6) * 0.8 + 2.5
				end
			else
				local v33 = v32 + dt
				v18[k] = v33
				local v34 = math.clamp(v33 / 0.7, 0, 1)
				local v35 = v34 * v34
				local v36 = v31.Position + createVector(0, 1, 0)
				local lerped = k:GetPivot().Position:Lerp(v36, (math.min(1, v35 * 0.5 + dt * 6)))
				k:PivotTo(CFrame.new(lerped) * CFrame.Angles(0, total2 * 1.2 * 4, 0))
				k:ScaleTo((math.max(0.2, Sakura.Bloom.CrystalScale * (1 - v35 * 0.6))))

				if v34 >= 1 or (lerped - v36).Magnitude < 1 then
					if v30 == localPlayer then
						v18[k] = nil
						v13[k] = nil
						requestCollect(k, v27) -- equivalent call inferred; original call site unknown
					else
						hideCrystal(k)
					end
				end
			end
		else
			local v30 = v28 + dt
			v17[k] = v30
			local v31 = math.clamp(v30 / 0.5, 0, 1)
			local value = TweenService:GetValue(v31, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local v32 = math.sin(v31 * 3.141592653589793) * 6
			local v33 = v29:Lerp(v27.Position, value) + Vector3.new(0, v32, 0)
			k:PivotTo(CFrame.new(v33) * CFrame.Angles(0, total2 * 1.2 * 3, 0))

			if v30 >= 0.7 then
				v17[k] = nil
				v18[k] = 0
				v12[k] = true
			end
		end
	end
end

local function findTreeInReach(primaryPart)
	local v27 = 1e999
	local v28 = nil

	for k, v29 in v7 do
		if k.Parent == nil or v9[k] then
			continue
		end

		local radius = k:GetAttribute("Radius")
		assert(typeof(radius) == "number", (`{k.Name} needs a Radius attribute`))
		local magnitude = Vector3.new(
			primaryPart.Position.X - v29.Position.X,
			0,
			primaryPart.Position.Z - v29.Position.Z
		).Magnitude

		if not (magnitude <= radius + Sakura.Bloom.HitRange and magnitude < v27) then
			continue
		end

		v28 = k
		v27 = magnitude
	end

	return v28
end

local function tryAutoSwing()
	if flag4 then
		return
	end

	local character = Player.FindCharacter(localPlayer)
	local primaryPart = Player.FindPrimaryPart(localPlayer)
	local humanoid = Player.FindHumanoid(localPlayer)

	if character == nil or primaryPart == nil or humanoid == nil or humanoid.Health <= 0 then
		return
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if tool == nil or not Sakura.IsBatTool(tool) then
		return
	end

	local treeInReach = findTreeInReach(primaryPart)

	if treeInReach == nil then
		return
	end

	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	if not SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27) then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	local hitAnim = tool:FindFirstChild("HitAnim")
	assert(
		animator and hitAnim and hitAnim:IsA("Animation"),
		(`{tool.Name} needs a HitAnim and the character an Animator`)
	)
	flag4 = true
	local track = animator:LoadAnimation(hitAnim)
	track.Priority = Enum.AnimationPriority.Action
	track:Play()
	Remotes.Bloomery.AskStrikeTree:FireServer(treeInReach)
	task.spawn(function()
		local v28 = os.clock() + 3

		repeat
			task.wait()
		until not track.IsPlaying or v28 <= os.clock()

		track:Stop()
		track:Destroy()
		flag4 = false
	end)
end

local function isInsideBounds(vector2: Vector3)
	local pointToObjectSpace = bounds.CFrame:PointToObjectSpace(vector2)
	return math.abs(pointToObjectSpace.X) <= bounds.Size.X / 2 + 90 and math.abs(pointToObjectSpace.Z) <= bounds.Size.Z / 2 + 90
end

local function buildWaypoint()
	local part = Instance.new("Part")
	part.Name = "BloomWaypointHost"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = bounds.Position + createVector(0, 24, 0)
	part.Parent = Workspace
	local clone = bloomWaypoint:Clone()
	clone.Enabled = false

	for _, label in clone:GetChildren() do
		if not label:IsA("TextLabel") then
			continue
		end

		label.TextTransparency = 1
		local uIStroke2 = label:FindFirstChildOfClass("UIStroke")

		if uIStroke2 then
			uIStroke2.Transparency = 1
		end
	end

	clone.Parent = part
	v23 = part
	v22 = clone
	v24 = false
	maid:Add(part)
	maid:Add(function()
		v22 = nil
		v23 = nil
		v24 = false
	end)
end

local function setWaypointShown(instance, flag5: boolean)
	if v24 == flag5 then
		return
	end

	v24 = flag5
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local v27 = flag5 and 0 or 1

	if flag5 then
		instance.Enabled = true
	end

	for _, label in instance:GetChildren() do
		if not label:IsA("TextLabel") then
			continue
		end

		TweenService:Create(label, tweenInfo, {
			TextTransparency = v27
		}):Play()
		local uIStroke2 = label:FindFirstChildOfClass("UIStroke")

		if uIStroke2 then
			TweenService:Create(uIStroke2, tweenInfo, {
				Transparency = v27
			}):Play()
		end
	end

	if not flag5 then
		task.delay(0.5, function()
			if not v24 and instance.Parent then
				instance.Enabled = false
			end
		end)
	end
end

local function renderWaypoint()
	local v27 = v22
	local v28 = v23

	if v27 == nil or v28 == nil then
		return
	end

	local primaryPart = Player.FindPrimaryPart(localPlayer)

	if primaryPart ~= nil then
		local position4 = primaryPart.Position
		local pointToObjectSpace = bounds.CFrame:PointToObjectSpace(position4)
		local v29

		if math.abs(pointToObjectSpace.X) <= bounds.Size.X / 2 + 90 then
			v29 = math.abs(pointToObjectSpace.Z) <= bounds.Size.Z / 2 + 90
		else
			v29 = false
		end

		if not v29 and localPlayer:GetAttribute("AreaId") == "Prehistoric" then
			setWaypointShown(v27, true)
			local countdown = v27:FindFirstChild("Countdown")

			if countdown and countdown:IsA("TextLabel") then
				countdown.Text = `{math.floor((primaryPart.Position - v28.Position).Magnitude)} studs`
			end

			return
		end
	end

	setWaypointShown(v27, false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleMusic(flag5: boolean)
	if flag5 then
		script.SakuraEventMusic:Play()
	else
		script.SakuraEventMusic:Stop()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideTutorial()
	if not sakuraEventTutorialFrame.Enabled and v21 == nil then
		return
	end

	sakuraEventTutorialFrame.Enabled = false
	local v27 = v21
	v21 = nil

	if v27 ~= nil then
		v27()
	end
end

local function showTutorialManually()
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	if not SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27) or sakuraEventTutorialFrame.Enabled then
		return
	end

	Tabs.Deactivate({
		instant = true
	})
	v21 = HiddenUIHandler.Acquire()
	sakuraEventTutorialFrame.Enabled = true
	SakuraFX.PlayCue("TutorialOpen", localPlayer, 0.8)
end

local function acknowledgeTutorial()
	if flag3 then
		return
	end

	flag3 = true
	hideTutorial() -- equivalent call inferred; original call site unknown
	local v27 = Save.Await()

	if v27 and not v27.Sakura.TutorialSeen then
		Remotes.Bloomery.AskBriefingConfirm:InvokeServer()
	end

	flag3 = false
	local v28 = CollectionService:GetTagged("MainSakuraTree")[1]

	if v28 and localPlayer.Character and localPlayer.Character.PrimaryPart then
		local magnitude = (localPlayer.Character.PrimaryPart.Position - v28:GetPivot().Position).Magnitude
		local v29 = Save.Await()

		if magnitude < 100 and v29 and v29.Sakura.Unlocked then
			localPlayer:SetAttribute("SakuraTutorialSkip", true)
			Tabs.Activate("SakuraEggCharge")
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkEndingWarning()
	if flag2 then
		return
	end

	local v27 = v19 - Workspace:GetServerTimeNow()

	if v27 <= Sakura.Bloom.EndingWarningSeconds and v27 > 0 then
		flag2 = true
		notifyTop(`🌸 The Great Bloom ends in {Sakura.Bloom.EndingWarningSeconds} seconds!`, 4) -- equivalent call inferred; original call site unknown
	end
end

local function stopPresentation()
	maid:Clean()
	v25 = false
	count += 1
	greatBloomBanner.Enabled = false
	hideTutorial() -- equivalent call inferred; original call site unknown
	hideCounter() -- equivalent call inferred; original call site unknown

	for k, connection in v11 do
		connection:Disconnect()
		v11[k] = nil
	end

	for _, v27 in v10 do
		if v27.Parent then
			v27:Destroy()
		end
	end

	for folder in v7 do
		if not folder.Parent then
			continue
		end

		folder:SetAttribute("TreeLoaded", nil)

		for _, descendant in folder:GetDescendants() do
			if descendant.Name == "BloomSparkles" then
				descendant:Destroy()
			end
		end
	end

	table.clear(v6)
	table.clear(v7)
	table.clear(v8)
	table.clear(v9)
	table.clear(v10)
	flag4 = false
	local v27 = Save.Peek()
	local v28

	if v27 then
		v28 = v27.SakuraCrystals
	end

	v4 = v28
	setWorldVFXEnabled(false)
	toggleMusic(false) -- equivalent call inferred; original call site unknown
end

local function startPresentation()
	if not v25 then
		local isLoaded = Save.IsLoaded()
		local v27

		if isLoaded then
			v27 = Save.Peek()
		end

		if SakuraBloomPolicy.CanShowBloom(v20, isLoaded, v27) then
			v25 = true
			setWorldVFXEnabled(true)
			toggleMusic(true) -- equivalent call inferred; original call site unknown

			for _, v28 in ipairs(CollectionService:GetTagged(Sakura.TreeTag)) do
				onTreeAdded(v28)
			end

			maid:Add(CollectionService:GetInstanceAddedSignal(Sakura.TreeTag):Connect(onTreeAdded))
			maid:Add(CollectionService:GetInstanceRemovedSignal(Sakura.TreeTag):Connect(onTreeRemoved))
			buildWaypoint()
			local v28

			if Save.Await() then
				v28 = Save.Await().SakuraCrystals
			end

			v4 = v28
			local total2 = 0
			local total3 = 0
			maid:Add(RunService.Heartbeat:Connect(function(dt: number)
				total3 += dt
				total2 += dt
				animateCrystals(total3, dt)

				if total2 >= 0.15 then
					total2 = 0
					updateHighlights()
					tryAutoSwing()
					renderWaypoint()
					checkEndingWarning() -- equivalent call inferred; original call site unknown
				end

				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local position4 = humanoidRootPart.Position
					local pointToObjectSpace = bounds.CFrame:PointToObjectSpace(position4)
					local v29

					if math.abs(pointToObjectSpace.X) <= bounds.Size.X / 2 + 90 then
						v29 = math.abs(pointToObjectSpace.Z) <= bounds.Size.Z / 2 + 90
					else
						v29 = false
					end

					if v29 then
						script.SakuraEventMusic.Volume = 0.5
						return
					end
				end

				script.SakuraEventMusic.Volume = 0
			end))

			for _, v29 in CollectionService:GetTagged(Sakura.CrystalTag) do
				onCrystalAdded(v29)
			end

			showBanner() -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshAccess()
	refreshReplicatedVisibility()
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	if SakuraBloomPolicy.CanShowBloom(v20, isLoaded, v27) then
		startPresentation()
	else
		stopPresentation()
	end
end

function GreatBloom:StartEvent(p: number, _)
	stopPresentation()
	v20 = true
	flag2 = false
	v19 = Workspace:GetServerTimeNow() + p
	refreshAccess() -- equivalent call inferred; original call site unknown
end

function GreatBloom.StopEvent(_)
	v20 = false
	stopPresentation()
	refreshReplicatedVisibility()
end

v5:Start()
sakuraEventTutorialFrame.Enabled = false
greatBloomBanner.Enabled = false

for _, v27 in v2 do
	v27.Instance[v27.Property] = 1
end

if gain and gain:IsA("TextLabel") then
	gain.TextTransparency = 1

	if uIStroke then
		uIStroke.Transparency = 1
	end
end

GUI.OnActivated(ok, acknowledgeTutorial)
ButtonFX(ok)
CollectionService:GetInstanceAddedSignal(Sakura.TreeTag):Connect(function(p)
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	setBloomInstanceHidden(p, not SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27)) -- equivalent call inferred; original call site unknown
end)
CollectionService:GetInstanceRemovedSignal(Sakura.TreeTag):Connect(function(p)
	setBloomInstanceHidden(p, false) -- equivalent call inferred; original call site unknown
end)
CollectionService:GetInstanceAddedSignal(Sakura.CrystalTag):Connect(function(p)
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	setBloomInstanceHidden(p, not SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27)) -- equivalent call inferred; original call site unknown
	onCrystalAdded(p)
end)
CollectionService:GetInstanceRemovedSignal(Sakura.CrystalTag):Connect(onCrystalRemoved)
CollectionService:GetInstanceRemovedSignal(Sakura.CrystalTag):Connect(function(p)
	setBloomInstanceHidden(p, false) -- equivalent call inferred; original call site unknown
end)
CollectionService:GetInstanceAddedSignal("GreatBloomVFX"):Connect(function()
	task.defer(refreshReplicatedVisibility)
end)
Remotes.Bloomery.PetalsGathered.OnClientEvent:Connect(function(p: number, vector2: Vector3)
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	if not SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27) then
		return
	end

	showCrystalPopup(p, vector2)
	SakuraFX.EmitBurst("Pickup", vector2 + createVector(0, 2, 0), 14, 3)
	SakuraFX.PlayCue("CrystalPickup", localPlayer, 0.6, 0.95 + math.random() * 0.15)
end)
Save.WatchFields("SakuraCrystals", function()
	local isLoaded = Save.IsLoaded()
	local v27

	if isLoaded then
		v27 = Save.Peek()
	end

	if SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v27) then
		popCounter()
		return
	end

	hideCounter() -- equivalent call inferred; original call site unknown
end)
Save.WatchFields("Sakura", refreshAccess)
Save.Loaded:Connect(function(p)
	if p == localPlayer then
		refreshAccess() -- equivalent call inferred; original call site unknown
	end
end)
SakuraSignals.ShowTutorial:Connect(showTutorialManually)
refreshReplicatedVisibility()
task.spawn(function()
	local v27 = Remotes.LiveEvents.FetchRunning:InvokeServer()
	local v28

	if typeof(v27) == "table" then
		v28 = v27[Sakura.EventName]
	end

	if typeof(v28) == "number" and v28 - os.time() > 0 then
		GreatBloom:StartEvent(v28 - os.time())
	end
end)
return GreatBloom