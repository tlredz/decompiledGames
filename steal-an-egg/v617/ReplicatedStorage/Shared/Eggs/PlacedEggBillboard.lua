local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Data.Assets)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
local Time = require(ReplicatedStorage.Shared.Utils.Time)
local elapsed = Time.Elapsed
local GUI = require(ReplicatedStorage.Client.GUI)
local SwapGradient = require(ReplicatedStorage.Shared.Utils.SwapGradient)
local HoverHighlight = require(ReplicatedStorage.Client.WorldFX.HoverHighlight)
local MonsterParasite = require(ReplicatedStorage.Shared.Types.MonsterParasite)
local SurfaceTracker = require(ReplicatedStorage.Client.SmartProximityPrompt.SurfaceTracker)
local MonsterParasite2 = require(ReplicatedStorage.Data.MonsterParasite)
local Save = require(ReplicatedStorage.Shared.Save)
local t = require(ReplicatedStorage.Packages.t)
local v = {}
local v2 = {}
local v3 = nil
local v4 = nil
local v5 = ""
local v6 = nil
local count = 0
local v7 = nil
local v8 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getKey(p: number, p2: string)
	return (`{p}:{p2}`)
end

local function bindGui()
	local v9 = v4

	if v9 ~= nil then
		return v9
	end

	local screenGui = GUI.AssetEggData()
	assert(screenGui:IsA("ScreenGui"), "PlayerGui.AssetEggData must be a ScreenGui")
	local frame = screenGui.Frame
	assert(frame:IsA("GuiObject"), "AssetEggData.Frame must be a GuiObject")
	local canvasGroup = frame.CanvasGroup
	assert(canvasGroup:IsA("GuiObject"), "AssetEggData.Frame.CanvasGroup must be a GuiObject")
	local displayName = canvasGroup.DisplayName
	assert(displayName:IsA("TextLabel"), "AssetEggData.Frame.CanvasGroup.DisplayName must be a TextLabel")
	local remainingHatchTime = canvasGroup.RemainingHatchTime
	assert(remainingHatchTime:IsA("TextLabel"), "AssetEggData.Frame.CanvasGroup.RemainingHatchTime must be a TextLabel")
	local v10 = {
		Root = screenGui,
		Frame = frame,
		CanvasGroup = canvasGroup,
		DisplayName = displayName,
		RemainingHatchTime = remainingHatchTime
	}
	v4 = v10
	frame.Visible = false
	remainingHatchTime.RichText = true
	return v10
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRemainingSeconds(p)
	local record = p.Record
	local placement = record.Placement

	if placement == nil or placement.ReadyAt ~= nil then
		return 0
	end

	local timeSkipSeconds = p.TimeSkipSeconds
	local v9 = timeSkipSeconds == nil and 0 or timeSkipSeconds.Value
	return (math.max(
		0,
		EggRecords.GrowthSecondsRemaining(
			record,
			Workspace:GetServerTimeNow(),
			record.GrowthSpeedMultiplier,
			nil,
			Players.LocalPlayer
		) - v9
	))
end

local function getEntryScreenPosition(p)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return false, Vector2.zero
	end

	local worldToViewportPoint, v9 = currentCamera:WorldToViewportPoint(ModelBounds(p.Model).Position)

	if v9 then
		return true, Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
	end

	return false, Vector2.zero
end

local function selectNearestEntry()
	local character = Players.LocalPlayer.Character

	if character == nil or character.PrimaryPart == nil then
		return nil
	end

	local position = character.PrimaryPart.Position
	local v9 = 1e999
	local v10 = nil

	for _, v11 in pairs(v) do
		if v11.Model.Parent == nil then
			continue
		end

		local _, v12 = v11.Tracker:GetClosestSurfacePoint(position, 0, 7)

		if not (v12 ~= nil and v12 <= 7 and v12 < v9) then
			continue
		end

		v10 = v11
		v9 = v12
	end

	return v10
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateStaticContent(p, data)
	local v9 = Assets.Directory[data.Record.AssetCategory]
	assert(v9 ~= nil, (`Missing asset config for category {data.Record.AssetCategory}`))
	p.DisplayName.Text = "Egg"
	local displayName = p.DisplayName
	local v11

	if not v9.Egg.HideRarity then
		v11 = v9.Rarity.RarityGradient
	end

	SwapGradient(displayName, v11)
end

local function updateCountdown(p, data)
	local visible = data.OwnerUserId == Players.LocalPlayer.UserId
	p.RemainingHatchTime.Visible = visible

	if not visible then
		v5 = ""
		return
	end

	local remainingSeconds = getRemainingSeconds(data) -- equivalent call inferred; original call site unknown
	local text = remainingSeconds <= 0 and "Ready!" or elapsed(remainingSeconds)
	local serverGrowthBoostMultiplier = EggRecords.ServerGrowthBoostMultiplier()
	local v11 = Save.Await()
	local v12 = (v11 == nil or not MonsterParasite.IsBoostActive(
		v11.MonsterParasite,
		MonsterParasite.BoostKinds.EggGrowth
	)) and 0 or MonsterParasite2.BoostMultiplier(MonsterParasite.BoostKinds.EggGrowth) - 1
	local v13 = data.Record.GrowthSpeedMultiplier + serverGrowthBoostMultiplier + v12

	if remainingSeconds > 0 and v13 > 1 then
		text ..= ` <font color="#FFD700">(x{v13})</font>`
	end

	if text == v5 then
		return
	end

	v5 = text
	p.RemainingHatchTime.Text = text
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearActiveHighlight()
	local v9 = v6
	v6 = nil

	if v9 ~= nil then
		HoverHighlight.FadeOut(v9, 0.25)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearFadeTween()
	local v9 = v7
	v7 = nil
	v8 = nil

	if v9 ~= nil then
		v9:Cancel()
		v9:Destroy()
	end
end

local function playCanvasFade(p, groupTransparency: number, p2: number?)
	if v7 ~= nil and v8 == groupTransparency then
		return
	end

	clearFadeTween() -- equivalent call inferred; original call site unknown
	v8 = groupTransparency

	if groupTransparency < 1 then
		p.Frame.Visible = true
	end

	if math.abs(p.CanvasGroup.GroupTransparency - groupTransparency) <= 0.001 then
		p.CanvasGroup.GroupTransparency = groupTransparency
		v8 = nil

		if groupTransparency >= 1 and p2 ~= nil and v3 == nil and count == p2 then
			p.Frame.Visible = false
		end
	else
		local tween = TweenService:Create(
			p.CanvasGroup,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				GroupTransparency = groupTransparency
			}
		)
		v7 = tween
		tween.Completed:Once(function(p3)
			if v7 == tween then
				v7 = nil
				v8 = nil
			end

			tween:Destroy()

			if p3 ~= Enum.PlaybackState.Completed then
				return
			end

			p.CanvasGroup.GroupTransparency = groupTransparency

			if groupTransparency >= 1 and p2 ~= nil and v3 == nil and count == p2 then
				p.Frame.Visible = false
			end
		end)
		tween:Play()
	end
end

local function setActiveEntry(data)
	if data == nil then
		if v3 == nil then
			return
		end

		local v9 = bindGui()
		v3 = nil
		v5 = ""
		count += 1
		local v10 = count
		clearActiveHighlight() -- equivalent call inferred; original call site unknown

		if v9.Frame.Visible then
			playCanvasFade(v9, 1, v10)
		end
	else
		local v9 = bindGui()
		count += 1

		if not v9.Frame.Visible then
			v9.CanvasGroup.GroupTransparency = 1
		end

		playCanvasFade(v9, 0, nil)
		local formatted = `{data.OwnerUserId}:{data.Uid}`

		if v3 ~= formatted then
			v3 = formatted
			v5 = ""
			clearActiveHighlight() -- equivalent call inferred; original call site unknown
			v6 = HoverHighlight.FadeIn(data.Model, "EggHoverHighlight", 0.25)
			updateStaticContent(v9, data) -- equivalent call inferred; original call site unknown
		end

		updateCountdown(v9, data)
		v9.Frame.Visible = true
	end
end

local function updateBillboard()
	if next(v2) == nil then
		local v9 = selectNearestEntry()

		if v9 ~= nil then
			local v10 = bindGui()
			local currentCamera = Workspace.CurrentCamera
			local zero, flag

			if currentCamera == nil then
				zero = Vector2.zero
				flag = false
			else
				local worldToViewportPoint, v11 = currentCamera:WorldToViewportPoint(ModelBounds(v9.Model).Position)

				if v11 then
					zero = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
					flag = true
				else
					zero = Vector2.zero
					flag = false
				end
			end

			if flag then
				setActiveEntry(v9)
				v10.Frame.Position = UDim2.fromOffset(zero.X, zero.Y)
				return
			end
		end
	end

	if v3 == nil then
		return
	end

	local v9 = bindGui()
	v3 = nil
	v5 = ""
	count += 1
	local v10 = count
	clearActiveHighlight() -- equivalent call inferred; original call site unknown

	if v9.Frame.Visible then
		playCanvasFade(v9, 1, v10)
	end
end

local PlacedEggBillboard = {
	SetEntry = function(data)
		t.strict(t.number)(data.OwnerUserId)
		t.strict(t.string)(data.Uid)
		t.strict(t.instanceIsA("Model"))(data.Model)
		assert(Eggs.SchemaValidation.RuntimeEggRecord(data.Record), "Invalid runtime egg record")
		local formatted = `{data.OwnerUserId}:{data.Uid}`
		local v9 = v[formatted]
		local tracker

		if v9 == nil or v9.Model ~= data.Model then
			tracker = SurfaceTracker.new(data.Model)
		else
			tracker = v9.Tracker
		end

		if v9 ~= nil and v9.Model ~= data.Model then
			v9.Tracker:Destroy()
		end

		v[formatted] = {
			OwnerUserId = data.OwnerUserId,
			Uid = data.Uid,
			Record = data.Record,
			Model = data.Model,
			TimeSkipSeconds = data.TimeSkipSeconds,
			Tracker = tracker
		}
	end,
	SetNightPresentationActive = function(p: number, p2: string, flag: boolean)
		t.strict(t.number)(p)
		t.strict(t.string)(p2)
		t.strict(t.boolean)(flag)
		local key = getKey(p, p2) -- equivalent call inferred; original call site unknown

		if flag then
			v2[key] = p

			if v3 == nil then
				return
			end

			local v9 = bindGui()
			v3 = nil
			v5 = ""
			count += 1
			local v10 = count
			clearActiveHighlight() -- equivalent call inferred; original call site unknown

			if v9.Frame.Visible then
				playCanvasFade(v9, 1, v10)
			end
		else
			v2[key] = nil
		end
	end,
	RemoveEntry = function(p: number, p2: string)
		t.strict(t.number)(p)
		t.strict(t.string)(p2)
		local key = getKey(p, p2) -- equivalent call inferred; original call site unknown
		local v9 = v[key]

		if v9 ~= nil then
			v9.Tracker:Destroy()
		end

		v[key] = nil
		v2[key] = nil

		if v3 == key then
			if v3 == nil then
				return
			end

			local v10 = bindGui()
			v3 = nil
			v5 = ""
			count += 1
			local v11 = count
			clearActiveHighlight() -- equivalent call inferred; original call site unknown

			if v10.Frame.Visible then
				playCanvasFade(v10, 1, v11)
			end
		end
	end,
	DestroyOwner = function(p: number)
		t.strict(t.number)(p)

		for k, v9 in pairs(v) do
			if v9.OwnerUserId ~= p then
				continue
			end

			v9.Tracker:Destroy()
			v[k] = nil

			if not (v3 == k and v3 ~= nil) then
				continue
			end

			local v10 = bindGui()
			v3 = nil
			v5 = ""
			count += 1
			local v11 = count
			clearActiveHighlight() -- equivalent call inferred; original call site unknown

			if v10.Frame.Visible then
				playCanvasFade(v10, 1, v11)
			end
		end

		for k, v9 in pairs(v2) do
			if v9 == p then
				v2[k] = nil
			end
		end
	end
}
RunService:BindToRenderStep(
	`PlacedEggBillboard@{HttpService:GenerateGUID(false)}`,
	Enum.RenderPriority.Last.Value,
	updateBillboard
)
return PlacedEggBillboard