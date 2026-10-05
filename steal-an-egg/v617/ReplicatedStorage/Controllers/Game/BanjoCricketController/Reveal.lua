local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local BanjoCricket = require(ReplicatedStorage.Data.BanjoCricket)
local Mushrooms = require(script.Parent.Mushrooms)
local Sounds = require(script.Parent.Sounds)
local v = {}
local v2 = {}
local v3 = "Closed"
local v4 = nil
local count = 0

local function rootsOpened(instance, cframe: CFrame)
	local attribute = instance:GetAttribute(BanjoCricket.Attributes.RevealOffset)

	if typeof(attribute) == "Vector3" then
		return cframe + attribute
	end

	local _, v6 = instance:GetBoundingBox()
	return cframe - Vector3.new(0, v6.Y, 0)
end

local function doorOpened(instance, cframe: CFrame)
	local attribute = instance:GetAttribute(BanjoCricket.Attributes.DoorOpenAngle)
	local v6 = typeof(attribute) ~= "number" and 100 or attribute
	return cframe * CFrame.Angles(0, math.rad(v6), 0)
end

local function makePassable(folder)
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapOpen(p)
	p.Model:PivotTo(p.Opened)
	makePassable(p.Model)
end

local function glide(data, duration: number, p)
	makePassable(data.Model)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = data.Closed
	cFrameValue.Changed:Connect(function(cframe: CFrame)
		if data.Model.Parent ~= nil then
			data.Model:PivotTo(cframe)
		end
	end)
	local tween = TweenService:Create(cFrameValue, TweenInfo.new(duration, p, Enum.EasingDirection.Out), {
		Value = data.Opened
	})
	tween.Completed:Once(function()
		cFrameValue:Destroy()
	end)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function binder(p, callback)
	return function(model)
		if p[model] or not (model:IsA("Model") and model:IsDescendantOf(Workspace)) then
			return
		end

		local pivot = model:GetPivot()
		local v6 = {
			Model = model,
			Closed = pivot,
			Opened = callback(model, pivot)
		}
		p[model] = v6

		if v3 == "Open" then
			snapOpen(v6) -- equivalent call inferred; original call site unknown
		end
	end
end

local function track(tag: string, p, callback)
	local v6 = binder(p, callback) -- equivalent call inferred; original call site unknown
	CollectionService:GetInstanceAddedSignal(tag):Connect(v6)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(p2)
		p[p2] = nil
	end)

	for _, v7 in CollectionService:GetTagged(tag) do
		v6(v7)
	end
end

local function songEmitter()
	for _, v6 in CollectionService:GetTagged(BanjoCricket.Tags.Music) do
		if v6:IsDescendantOf(Workspace) then
			return v6
		end
	end

	for _, v6 in v2 do
		return v6.Model
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSong(band: number)
	if v4 ~= nil then
		return
	end

	local v6 = songEmitter()

	if v6 == nil then
		return
	end

	v4 = Audio.Play(BanjoCricket.Sounds.Band, v6, {
		Looped = true,
		MaxDistance = 90,
		Volume = band
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function creakRoots(value: number)
	local _, v6 = next(v)

	if v6 then
		Sounds.Creak(v6.Closed, value)
	end
end

local v5 = {
	Start = function()
		track(BanjoCricket.Tags.Roots, v, rootsOpened)
		track(BanjoCricket.Tags.Door, v2, doorOpened)
	end,
	Strain = function(value: number)
		if v3 ~= "Closed" then
			return
		end

		count += 1
		local v6 = count
		local lastTime = os.clock()
		local v7 = math.clamp(value, 0, 1) * 0.06981317007977318
		creakRoots(value) -- equivalent call inferred; original call site unknown
		local preRenderConnection = nil
		preRenderConnection = RunService.PreRender:Connect(function()
			local v8 = (os.clock() - lastTime) / 0.6
			local v9

			if count == v6 then
				v9 = v3 == "Closed"
			else
				v9 = false
			end

			if v9 and not (v8 >= 1) then
				local v10 = v7 * (1 - v8)

				for _, v11 in v do
					v11.Model:PivotTo(v11.Closed * CFrame.Angles(math.sin(v8 * 40) * v10, 0, math.cos(v8 * 29) * v10))
				end
			else
				preRenderConnection:Disconnect()

				if v9 then
					for _, v10 in v do
						v10.Model:PivotTo(v10.Closed)
					end
				end
			end
		end)
	end,
	Open = function()
		if v3 ~= "Closed" then
			return
		end

		v3 = "Open"

		for _, v6 in v do
			snapOpen(v6) -- equivalent call inferred; original call site unknown
		end

		for _, v6 in v2 do
			snapOpen(v6) -- equivalent call inferred; original call site unknown
		end

		playSong(BanjoCricket.Volume.Band) -- equivalent call inferred; original call site unknown
	end,
	Play = function()
		if v3 ~= "Closed" then
			return
		end

		v3 = "Revealing"
		local reveal = BanjoCricket.Reveal
		task.delay(reveal.LightsAt, Mushrooms.SetAllLit, true)
		task.delay(reveal.HarmonyAt, Sounds.Strum)
		task.delay(reveal.MusicAt, playSong, BanjoCricket.Volume.BandFaint)
		task.delay(reveal.RootsAt, function()
			creakRoots(1) -- equivalent call inferred; original call site unknown

			for _, v6 in v do
				glide(v6, reveal.RootsSeconds, Enum.EasingStyle.Quad)
			end
		end)
		task.delay(reveal.DoorAt, function()
			v3 = "Open"

			for _, v6 in v2 do
				glide(v6, reveal.DoorSeconds, Enum.EasingStyle.Back)
			end

			local v6 = v4

			if v6 then
				Audio.FadeTo(v6, {
					Volume = BanjoCricket.Volume.Band,
					Seconds = reveal.DoorSeconds
				})
			end
		end)
		task.delay(reveal.LightsOffAt, Mushrooms.SetAllLit, false)
	end
}
return table.freeze(v5)