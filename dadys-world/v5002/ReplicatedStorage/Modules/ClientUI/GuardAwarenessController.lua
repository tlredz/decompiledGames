local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
local MyDataController = require(ReplicatedStorage.Modules.ClientUI.MyDataController)
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local color = Color3.fromRGB(129, 215, 180)
local color2 = Color3.fromRGB(255, 70, 70)
local v = {
	template = "GuardAllyBadge",
	stackAnchor = Vector2.new(0.5, 1),
	stackPosition = UDim2.fromScale(0.02, -0.18),
	stackSize = UDim2.fromScale(0.44, 2),
	stackPadding = UDim.new(0.04, 0),
	zIndex = 56,
	backing = Color3.fromRGB(28, 32, 36),
	alertBacking = Color3.fromRGB(140, 24, 30),
	ringThickness = 3,
	alertScale = 1.12,
	alertBreath = 0.5
}
local GuardAwarenessController = {}
local v2 = {}
local v3 = {}
local v4 = {}
local frame = nil
local fn
local fn2

-- equivalent calls inferred from this helper; original call sites unknown
local function localName()
	local localPlayer = Players.LocalPlayer
	return localPlayer and localPlayer.Name or ""
end

local function toonIcon(instance)
	local moduleName = instance:FindFirstChild("ModuleName", true) or instance:FindFirstChild("CharacterName", true)
	local value = moduleName and moduleName:IsA("StringValue") and moduleName.Value or nil

	if not value or value == "" then
		return nil
	end

	local success, result = pcall(function()
		local tower = TowerLUT:GetTower(value)
		local module = tower and require(tower)

		if type(module) == "table" then
			return module.VoteIcon or module.Icon
		end

		return nil
	end)
	return success and result or nil
end

local function labArmed()
	local localPlayer = Players.LocalPlayer
	return localPlayer ~= nil and localPlayer:GetAttribute("SoulvesterLabArmed") == true
end

local function labPrint(...)
	local localPlayer = Players.LocalPlayer
	local v5

	if localPlayer == nil then
		v5 = false
	else
		v5 = localPlayer:GetAttribute("SoulvesterLabArmed") == true
	end

	if v5 then
		print("[SoulvesterLab/awareness]", ...)
	end
end

local v5 = nil
local v6 = nil
local count = 0
local v7 = false

local function musicAllowed()
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	return character ~= nil and character:GetAttribute("SoulvesterChaseMusic") ~= false
end

local function routeThroughMusicBus(p)
	if not SoundGroupManager.AssignMusicSound(p) then
		return
	end

	local group = SoundGroupManager.GetGroup("Music")

	if not group then
		return
	end

	group.Volume = MyDataController:getDataFromPath("Settings.MusicToggle") == true and 0 or 1
end

local function swellMusic(p)
	TweenService:Create(p, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Volume = 0.035
	}):Play()
end

local function sweepStrayMusic(result)
	for _, child in ipairs(SoundService:GetChildren()) do
		if not (child.Name == "SoulvesterChaseMusic" and child ~= result) then
			continue
		end

		child:Destroy()
		labPrint("chase music: destroyed a stray copy")
	end
end

local function startMusic()
	count += 1
	v7 = false

	if v5 and v5.Parent then
		if v6 then
			v6:Cancel()
			v6 = nil
			labPrint("chase music: RECLAIMED mid-fade")
		end

		if v5.Volume < 0.035 then
			swellMusic(v5)
		end
	else
		v5 = nil
		v6 = nil
		local localPlayer = Players.LocalPlayer
		local character = localPlayer and localPlayer.Character
		local v8

		if character == nil then
			v8 = false
		else
			v8 = character:GetAttribute("SoulvesterChaseMusic") ~= false
		end

		if not v8 then
			return
		end

		local success, result = pcall(function()
			return Audio:Play("rbxassetid://137998155470758", {
				Parent = SoundService,
				Looped = true,
				Volume = 0
			})
		end)

		if not (success and result) then
			warn("[GuardAwarenessController] chase music failed to start:", (tostring(result)))
			return
		end

		result.Name = "SoulvesterChaseMusic"
		sweepStrayMusic(result)
		local v9 = SoundGroupManager.AssignMusicSound(result) and SoundGroupManager.GetGroup("Music")

		if v9 then
			v9.Volume = MyDataController:getDataFromPath("Settings.MusicToggle") == true and 0 or 1
		end

		v5 = result
		swellMusic(result)
		labPrint("chase music: START")
	end
end

local function fadeOutMusic(instance, duration, p)
	if v6 then
		v6:Cancel()
	end

	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Volume = 0
		}
	)
	v6 = tween
	tween.Completed:Connect(function(p2)
		if p2 ~= Enum.PlaybackState.Completed then
			return
		end

		if v6 == tween then
			v6 = nil
		end

		if v5 == instance then
			v5 = nil
		end

		instance:Stop()
		instance:Destroy()
	end)
	tween:Play()
	labPrint("chase music: STOP (" .. p .. ")")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopMusic(p)
	local v8 = v5

	if not v8 then
		return
	end

	if p then
		count += 1
		v7 = false
		fadeOutMusic(v8, 0.6, "immediate")
	else
		if v7 or v6 then
			return
		end

		v7 = true
		count += 1
		local v9 = count
		task.delay(0.6, function()
			if v5 ~= v8 or count ~= v9 then
				return
			end

			v7 = false
			fadeOutMusic(v8, 1.2, "chase ended")
		end)
	end
end

local function updateMusic()
	if next(v3) ~= nil then
		startMusic()
		return
	end

	local v8 = v5

	if not v8 then
		return
	end

	if not v7 then
		if v6 then
			return
		end

		v7 = true
		count += 1
		local v9 = count
		task.delay(0.6, function()
			if v5 ~= v8 or count ~= v9 then
				return
			end

			v7 = false
			fadeOutMusic(v8, 1.2, "chase ended")
		end)
	end
end

local v8 = {}

local function badgeRing(instance)
	local ring = instance:FindFirstChild("Ring", true)

	if not (ring and ring:IsA("UIStroke") and ring) then
		ring = nil
	end

	return ring
end

local function setChaseAlert(k, p)
	if p == (v8[k] ~= nil) then
		return
	end

	local v9 = v4[k]

	if p then
		if not (v9 and v9.Parent) then
			return
		end

		local ring = v9:FindFirstChild("Ring", true)

		if not (ring and ring:IsA("UIStroke") and ring) then
			ring = nil
		end

		local v10 = {
			tweens = {},
			ring = ring,
			ringColor = ring and ring.Color,
			backing = v9.BackgroundColor3
		}

		if ring then
			ring.Color = color2
		end

		local tweenInfo = TweenInfo.new(v.alertBreath, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		table.insert(v10.tweens, TweenService:Create(v9, tweenInfo, {
			BackgroundColor3 = v.alertBacking
		}))
		local alertScale = v9:FindFirstChild("AlertScale")

		if alertScale then
			alertScale.Scale = 1
			table.insert(v10.tweens, TweenService:Create(alertScale, tweenInfo, {
				Scale = v.alertScale
			}))
		end

		for _, tween in ipairs(v10.tweens) do
			tween:Play()
		end

		v8[k] = v10
		labPrint("chase alert ON:", k.Name)
	else
		local v10 = v8[k]
		v8[k] = nil

		for _, tween in ipairs(v10.tweens) do
			tween:Cancel()
		end

		if v9 and v9.Parent then
			v9.BackgroundColor3 = v10.backing

			if v10.ring and v10.ring.Parent then
				v10.ring.Color = v10.ringColor
			end

			local alertScale = v9:FindFirstChild("AlertScale")

			if alertScale then
				alertScale.Scale = 1
			end
		end

		labPrint("chase alert OFF:", k.Name)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rebuildBadge(p)
	if v8[p] ~= nil ~= false then
		local v9 = v4[p]
		local v10 = v8[p]
		v8[p] = nil

		for _, tween in ipairs(v10.tweens) do
			tween:Cancel()
		end

		if v9 and v9.Parent then
			v9.BackgroundColor3 = v10.backing

			if v10.ring and v10.ring.Parent then
				v10.ring.Color = v10.ringColor
			end

			local alertScale = v9:FindFirstChild("AlertScale")

			if alertScale then
				alertScale.Scale = 1
			end
		end

		labPrint("chase alert OFF:", p.Name)
	end

	local v9 = v4[p]

	if v9 then
		v9:Destroy()
	end

	v4[p] = fn(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureGuardEntry(child)
	if v2[child] then
		return
	end

	v2[child] = true
	rebuildBadge(child) -- equivalent call inferred; original call site unknown
end

local function dropGuardEntry(p)
	if v8[p] ~= nil ~= false then
		local v9 = v4[p]
		local v10 = v8[p]
		v8[p] = nil

		for _, tween in ipairs(v10.tweens) do
			tween:Cancel()
		end

		if v9 and v9.Parent then
			v9.BackgroundColor3 = v10.backing

			if v10.ring and v10.ring.Parent then
				v10.ring.Color = v10.ringColor
			end

			local alertScale = v9:FindFirstChild("AlertScale")

			if alertScale then
				alertScale.Scale = 1
			end
		end

		labPrint("chase alert OFF:", p.Name)
	end

	v2[p] = nil
	local v9 = v4[p]
	v4[p] = nil

	if v9 then
		v9:Destroy()
	end

	if next(v2) == nil then
		for k in pairs(v3) do
			fn2(k)
		end

		local v10 = v5

		if not v10 then
			return
		end

		if not v7 then
			if v6 then
				return
			end

			v7 = true
			count += 1
			local v11 = count
			task.delay(0.6, function()
				if v5 ~= v10 or count ~= v11 then
					return
				end

				v7 = false
				fadeOutMusic(v10, 1.2, "chase ended")
			end)
		end
	end
end

local function refreshGuarded(instance)
	if instance.Parent and instance:GetAttribute("GuardedBy") == localName() then
		if v2[instance] then
			return
		end

		v2[instance] = true
		rebuildBadge(instance) -- equivalent call inferred; original call site unknown
		return
	end

	dropGuardEntry(instance)
end

local function ensureBadgeStack()
	if frame and frame.Parent then
		return frame
	end

	local gui = GameContext.Gui
	local ability1 = gui and gui:FindFirstChild("Ability1")

	if not ability1 then
		labPrint("ally badge: no Ability1 button yet")
		return nil
	end

	frame = Instance.new("Frame")
	frame.Name = "GuardBadges"
	frame.AnchorPoint = v.stackAnchor
	frame.Position = v.stackPosition
	frame.Size = v.stackSize
	frame.BackgroundTransparency = 1
	frame.ZIndex = v.zIndex
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Padding = v.stackPadding
	uIListLayout.Parent = frame
	frame.Parent = ability1
	return frame
end

local object = setmetatable({}, {
	__mode = "k"
})

local function orderFor(p)
	if object[p] then
		return object[p]
	end

	local count2 = 0

	for _ in pairs(object) do
		count2 += 1
	end

	object[p] = (count2 + 1) * 100
	return object[p]
end

local function buildDefaultBadge()
	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundColor3 = v.backing
	frame2.BorderSizePixel = 0
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
	uIAspectRatioConstraint.Parent = frame2
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = frame2
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Name = "Ring"
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Color = color
	uIStroke.Thickness = v.ringThickness
	uIStroke.Parent = frame2
	CollectionService:AddTag(uIStroke, "scaleUIStroke")
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Portrait"
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Size = UDim2.fromScale(1, 1)
	local clone = uICorner:Clone()
	clone.Parent = imageLabel
	imageLabel.Parent = frame2
	return frame2
end

local v9 = false

local function buildBadge()
	local GUI = ReplicatedStorage:FindFirstChild("GUI")
	local guiObject = GUI and GUI:FindFirstChild(v.template)

	if not (guiObject and guiObject:IsA("GuiObject")) then
		return (buildDefaultBadge())
	end

	if not (v9 or guiObject:FindFirstChild("Portrait", true)) then
		v9 = true
		warn("[GuardAwarenessController] " .. v.template .. " has no ImageLabel named Portrait; the ally art cannot show")
	end

	return guiObject:Clone()
end

fn = function(p)
	local badgeStack = ensureBadgeStack()

	if not badgeStack then
		return nil
	end

	local badge = buildBadge()
	badge.Name = "Ally_" .. p.Name

	if not object[p] then
		local count2 = 0

		for _ in pairs(object) do
			count2 += 1
		end

		object[p] = (count2 + 1) * 100
	end

	badge.LayoutOrder = object[p]
	badge.Visible = true
	local portrait = badge:FindFirstChild("Portrait", true)

	if portrait and portrait:IsA("ImageLabel") then
		portrait.Image = toonIcon(p) or ""
		portrait.ScaleType = Enum.ScaleType.Fit
	end

	local v10 = badge:FindFirstChild("AlertScale")

	if not (v10 and v10:IsA("UIScale")) then
		v10 = Instance.new("UIScale")
		v10.Name = "AlertScale"
		v10.Parent = badge
	end

	v10.Scale = 0.6
	badge.Parent = badgeStack
	TweenService:Create(v10, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	return badge
end

local function addThreat(model, ally)
	local v10 = v3[model]

	if v10 and v10.ally == ally then
		return
	end

	v3[model] = {
		ally = ally
	}
	labPrint(string.format("THREAT ON: %s is chasing guarded ally %s", model.Name, ally.Name))
end

fn2 = function(instance)
	if not v3[instance] then
		return
	end

	v3[instance] = nil
	local chasingValue = instance:FindFirstChild("ChasingValue")
	local value = chasingValue and chasingValue:IsA("ObjectValue") and chasingValue.Value
	labPrint(string.format(
		"THREAT OFF: %s (now chasing %s; guarded=%s)",
		instance.Name,
		not value and "nobody" or value.Name or "nobody",
		not value and "-" or tostring(v2[value] ~= nil) or "-"
	))
end

local now = 0

local function chasedGuardedAlly(instance)
	local chasingValue = instance:FindFirstChild("ChasingValue")
	local value = chasingValue and chasingValue:IsA("ObjectValue") and chasingValue.Value or nil

	if value then
		return v2[value] and value or nil, "value"
	end

	local v10 = nil

	if instance:GetAttribute("Chasing") == true then
		return v10, "attr-only"
	end

	return v10, "idle"
end

local now2 = 0

local function scanThreats()
	if next(v2) == nil and next(v3) == nil then
		return
	end

	for k in pairs(v2) do
		local v10 = v4[k]

		if v10 and v10.Parent then
			continue
		end

		rebuildBadge(k) -- equivalent call inferred; original call site unknown
	end

	local lastTime = os.clock()
	local v10 = {}
	local localPlayer = Players.LocalPlayer
	local v12 = localPlayer ~= nil and localPlayer:GetAttribute("SoulvesterLabArmed") == true and next(v2) ~= nil and os.clock() - now > 3 and ({} or nil) or nil

	for _, model in ipairs(CollectionService:GetTagged("Twisted")) do
		if not (model:IsA("Model") and model.Parent) then
			continue
		end

		local chasingValue = model:FindFirstChild("ChasingValue")
		local value = chasingValue and chasingValue:IsA("ObjectValue") and chasingValue.Value or nil
		local v13, v14

		if value then
			v13 = v2[value] and value or nil
			v14 = "value"
		elseif model:GetAttribute("Chasing") == true then
			v14 = "attr-only"
		else
			v14 = "idle"
		end

		if v12 then
			local chasingValue2 = model:FindFirstChild("ChasingValue")
			local value2 = chasingValue2 and chasingValue2:IsA("ObjectValue") and chasingValue2.Value
			table.insert(
				v12,
				string.format(
					"%s[chasing=%s value=%s]->%s",
					model.Name,
					tostring(model:GetAttribute("Chasing") == true),
					value2 and value2.Name or "nil",
					not v13 and "no guarded ally" or v13.Name .. " (GUARDED via " .. v14 .. ")" or "no guarded ally"
				)
			)
		end

		if not v13 then
			continue
		end

		v10[model] = true
		addThreat(model, v13)
	end

	for k in pairs(v3) do
		if not v10[k] then
			fn2(k)
		end
	end

	local v13 = {}

	for _, v14 in pairs(v3) do
		v13[v14.ally] = true
	end

	for k in pairs(v2) do
		setChaseAlert(k, v13[k] == true)
	end

	if next(v3) == nil then
		local v14 = v5

		if v14 and not (v7 or v6) then
			v7 = true
			count += 1
			local v15 = count
			task.delay(0.6, function()
				if v5 ~= v14 or count ~= v15 then
					return
				end

				v7 = false
				fadeOutMusic(v14, 1.2, "chase ended")
			end)
		end
	else
		startMusic()
	end

	local v14 = (os.clock() - lastTime) * 1000

	if v14 > 5 and os.clock() - now2 > 5 then
		now2 = os.clock()
		warn(string.format("[GuardSpike] scanThreats took %.1f ms", v14))
	end

	if v12 then
		now = os.clock()
		local names = {}

		for k in pairs(v2) do
			table.insert(names, k.Name)
		end

		labPrint(string.format(
			"census: guarding [%s]; twisteds: %s",
			table.concat(names, ", "),
			#v12 > 0 and table.concat(v12, ", ") or "none"
		))
	end
end

local v10 = {}

local function watch(instance)
	if v10[instance] then
		return
	end

	v10[instance] = instance:GetAttributeChangedSignal("GuardedBy"):Connect(function()
		local v11 = instance

		if v11.Parent and v11:GetAttribute("GuardedBy") == localName() then
			if v2[v11] then
				return
			end

			v2[v11] = true
			rebuildBadge(v11) -- equivalent call inferred; original call site unknown
			return
		end

		dropGuardEntry(v11)
	end)

	if instance.Parent and instance:GetAttribute("GuardedBy") == localName() then
		if v2[instance] then
			return
		end

		v2[instance] = true
		rebuildBadge(instance) -- equivalent call inferred; original call site unknown
		return
	end

	dropGuardEntry(instance)
end

local function unwatch(p)
	local connection = v10[p]

	if connection then
		connection:Disconnect()
	end

	v10[p] = nil
	dropGuardEntry(p)
end

function GuardAwarenessController.setupAll()
	local inGamePlayers = workspace:WaitForChild("InGamePlayers", 30)

	if not inGamePlayers then
		warn("[GuardAwarenessController] InGamePlayers never appeared; awareness layer disabled")
		return
	end

	for _, child in ipairs(inGamePlayers:GetChildren()) do
		if v10[child] then
			continue
		end

		local v11 = child
		v10[child] = child:GetAttributeChangedSignal("GuardedBy"):Connect(function()
			local v12 = v11

			if v12.Parent and v12:GetAttribute("GuardedBy") == localName() then
				if v2[v12] then
					return
				end

				v2[v12] = true
				rebuildBadge(v12) -- equivalent call inferred; original call site unknown
				return
			end

			dropGuardEntry(v12)
		end)

		if child.Parent and child:GetAttribute("GuardedBy") == localName() then
			ensureGuardEntry(child) -- equivalent call inferred; original call site unknown
			continue
		end

		dropGuardEntry(child)
	end

	inGamePlayers.ChildAdded:Connect(watch)
	inGamePlayers.ChildRemoved:Connect(unwatch)
	local localPlayer = Players.LocalPlayer

	if localPlayer then
		localPlayer.CharacterRemoving:Connect(function()
			for k in pairs(v3) do
				fn2(k)
			end

			stopMusic(true) -- equivalent call inferred; original call site unknown
		end)
	end

	local localPlayer2 = Players.LocalPlayer
	local v11

	if localPlayer2 == nil then
		v11 = false
	else
		v11 = localPlayer2:GetAttribute("SoulvesterLabArmed") == true
	end

	if v11 then
		local now3 = os.clock()
		RunService.RenderStepped:Connect(function()
			local now4 = os.clock()
			local v12 = now4 - now3
			now3 = now4

			if v12 > 0.15 then
				local success, result = pcall(function()
					return require(ReplicatedStorage.Parts.RenderModules.SoulvesterGuardCinematic)
				end)
				local v13 = success and result and result.isActive() and "ACTIVE" or "no"
				local count2 = 0
				local count3 = 0

				for _ in pairs(v3) do
					count2 += 1
				end

				for _ in pairs(v2) do
					count3 += 1
				end

				warn(string.format(
					"[GuardSpike] frame %.0f ms | shot=%s threats=%d guarding=%d music=%s",
					v12 * 1000,
					v13,
					count2,
					count3,
					(tostring(v5 ~= nil))
				))
			end
		end)
	end

	task.spawn(function()
		while true do
			local success, result = pcall(scanThreats)

			if not success then
				warn("[GuardAwarenessController] scan failed:", result)
			end

			task.wait(0.2)
		end
	end)
end

return GuardAwarenessController