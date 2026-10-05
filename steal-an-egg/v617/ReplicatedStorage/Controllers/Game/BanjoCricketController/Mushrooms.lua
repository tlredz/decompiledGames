local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local BanjoCricket = require(ReplicatedStorage.Data.BanjoCricket)
local BanjoCricketFlags = require(ReplicatedStorage.Shared.Flags.BanjoCricketFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(55, 55, 65)
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local v3 = {}
local v4 = false
local v5 = 0
local v6 = false
local v7 = nil
local v8 = nil
local vector2 = createVector(0, 0, 0)
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
local v9 = {
	Bounce = {
		Seconds = 0.55,
		Sample = function(p: number)
			return math.sin(p * 3.141592653589793 * 3) * (1 - p) * 0.2, 0, 0, 0
		end
	},
	Hop = {
		Seconds = 0.45,
		Sample = function(p: number)
			return math.sin(p * 3.141592653589793 * 2) * (1 - p) * 0.08, math.sin(p * 3.141592653589793) * 0.9, 0, 0
		end
	},
	Squish = {
		Seconds = 0.3,
		Sample = function(p: number)
			return -math.sin(p * 3.141592653589793) * 0.1, 0, 0, 0
		end
	},
	Breathe = {
		Seconds = 0.7,
		Sample = function(p: number)
			return math.sin(p * 3.141592653589793) * 0.06, 0, 0, 0
		end
	},
	Droop = {
		Seconds = 0.9,
		Sample = function(p: number)
			return -math.sin(p * 3.141592653589793) * 0.14, 0, 0, 0
		end
	},
	Shake = {
		Seconds = 0.55,
		Sample = function(p: number)
			local v10 = (1 - p) ^ 2 * 0.15707963267948966
			return 0, 0, math.sin(p * 38) * v10, math.cos(p * 31) * v10
		end
	}
}

local function refreshGlow(data)
	local glow = data.Glow
	local tweenInfo = TweenInfo.new(glow == "Off" and 0.3 or 0.06, Enum.EasingStyle.Quad)
	local brightness = glow == "Lit" and 4 or glow == "Soft" and 1.2 or 0
	local fillTransparency = glow == "Lit" and 0.35 or glow == "Soft" and 0.75 or 1
	local outlineTransparency

	if glow == "Lit" then
		outlineTransparency = 0
	elseif glow == "Soft" then
		outlineTransparency = 0.5
	elseif data.Aimed then
		outlineTransparency = 0.35
	else
		outlineTransparency = 1
	end

	local highlight = data.Highlight
	local outlineColor

	if glow == "Off" and data.Aimed then
		outlineColor = color
	else
		outlineColor = data.Color
	end

	highlight.OutlineColor = outlineColor
	TweenService:Create(data.Light, tweenInfo, {
		Brightness = brightness
	}):Play()
	TweenService:Create(data.Highlight, tweenInfo, {
		FillTransparency = fillTransparency,
		OutlineTransparency = outlineTransparency
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setGlow(p, glow: string, duration: number?)
	p.GlowId += 1
	p.Glow = glow
	refreshGlow(p)

	if duration == nil then
		return
	end

	local glowId = p.GlowId
	task.delay(duration, function()
		if p.GlowId == glowId and not v4 then
			p.Glow = "Off"
			refreshGlow(p)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function move(p, p2: string)
	p.Motions[p2] = os.clock()
	v2[p] = true
end

local function animate()
	if next(v2) == nil then
		return
	end

	local now = os.clock()

	for k in v2 do
		local total = 1
		local total2 = 0
		local total3 = 0
		local total4 = 0

		for k2, motion in k.Motions do
			local v11 = v9[k2]
			local v12 = (now - motion) / v11.Seconds

			if v12 >= 1 then
				k.Motions[k2] = nil
			else
				local sample, v13, v14, v15 = v11.Sample(v12)
				total += sample
				total2 += v13
				total3 += v14
				total4 += v15
			end
		end

		if next(k.Motions) == nil then
			v2[k] = nil
		end

		if k.Model.Parent == nil then
			continue
		end

		k.Model:ScaleTo(k.BaseScale * total)
		k.Model:PivotTo(k.BasePivot * CFrame.new(0, total2, 0) * CFrame.Angles(total3, 0, total4))
	end
end

local function beadFolder()
	local v11 = v7

	if v11 and v11.Parent then
		return v11
	end

	local folder = Instance.new("Folder")
	folder.Name = "BanjoCricketRings"
	folder.Parent = Workspace
	v7 = folder
	return folder
end

local function makeBeads(hitbox, pivot: CFrame, maid)
	local v11 = BanjoCricketFlags.Stages:Get()
	local v12 = math.max(hitbox.Size.X, hitbox.Size.Z) / 2 + 0.7
	local result = table.create(v11)

	for i = 1, v11 do
		local v13 = (i - 1) / v11 * 3.141592653589793 * 2
		local v14 = maid:Add(Instance.new("Part"))
		v14.Name = "Bead"
		v14.Shape = Enum.PartType.Ball
		v14.Size = createVector(0.55, 0.55, 0.55)
		v14.Anchored = true
		v14.CanCollide = false
		v14.CanQuery = false
		v14.CanTouch = false
		v14.CastShadow = false
		v14.Transparency = 1
		v14.CFrame = pivot * CFrame.new(math.cos(v13) * v12, 0.3, math.sin(v13) * v12)
		local parent = v7

		if not (parent and parent.Parent) then
			parent = Instance.new("Folder")
			parent.Name = "BanjoCricketRings"
			parent.Parent = Workspace
			v7 = parent
		end

		v14.Parent = parent
		table.insert(result, v14)
	end

	return result
end

local function paintBeads(p, p2: number?)
	for k, bead in p.Beads do
		local v11 = k <= v5
		bead.Transparency = v6 and (v11 and 0 or 0.55) or 1
		local color3

		if v11 then
			color3 = p.Color
		else
			color3 = color2
		end

		bead.Color = color3
		local material

		if v11 then
			material = Enum.Material.Neon
		else
			material = Enum.Material.SmoothPlastic
		end

		bead.Material = material

		if not (k == p2 and v6) then
			continue
		end

		bead.Size = createVector(1.1, 1.1, 1.1)
		TweenService:Create(bead, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
			Size = createVector(0.55, 0.55, 0.55)
		}):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isNear(p, character)
	overlapParams.FilterDescendantsInstances = { character }
	local boundingBox, v11 = p.Model:GetBoundingBox()
	return #Workspace:GetPartBoundsInBox(boundingBox, v11 + createVector(2, 2, 2), overlapParams) > 0
end

local function trackPlayer()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	vector2 = not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) and createVector(0, 0, 0) or humanoidRootPart.AssemblyLinearVelocity

	for _, v11 in v do
		if v11.Pressed then
			v11.Pressed = character ~= nil and isNear(v11, character)
		end
	end
end

local function approachSpeed(state, character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		return 0
	end

	local v11 = (state.Anchor.Position - humanoidRootPart.Position) * createVector(1, 0, 1)
	return (math.max(not (v11.Magnitude > 0.001) and 0 or vector2:Dot(v11.Unit), -vector2.Y))
end

local function watchBumps(state)
	for _, part in state.Model:GetDescendants() do
		if part:IsA("BasePart") then
			state.Trove:Connect(part.Touched, function(instance)
				local character = localPlayer.Character
				local now = os.clock()

				if character == nil or state.Pressed or not instance:IsDescendantOf(character) or instance:FindFirstAncestorOfClass("Tool") ~= nil or next(state.Motions) ~= nil or now - state.BumpedAt < 0.6 or approachSpeed(
					state,
					character
				) < 3 then
					return
				end

				state.BumpedAt = now
				state.Pressed = true
				local v11 = v8

				if v11 then
					v11(state.Index)
				end
			end)
		end
	end
end

local function anchorOf(instance)
	local hitbox = instance:FindFirstChild("Hitbox")

	if hitbox and hitbox:IsA("BasePart") then
		return hitbox
	end

	return instance.PrimaryPart
end

local function bind(model)
	if v[model] or not (model:IsA("Model") and model:IsDescendantOf(Workspace)) then
		return
	end

	local attribute = model:GetAttribute(BanjoCricket.Attributes.MushroomIndex)
	local hitbox = model:FindFirstChild("Hitbox")

	if not (hitbox and hitbox:IsA("BasePart")) then
		hitbox = model.PrimaryPart
	end

	if hitbox == nil or typeof(attribute) ~= "number" then
		return
	end

	local mushroom = BanjoCricket.Mushrooms[attribute]

	if mushroom == nil then
		return
	end

	local maid = Trove.new()
	local light = maid:Add(Instance.new("PointLight"))
	light.Brightness = 0
	light.Range = 16
	light.Color = mushroom.Color
	light.Shadows = false
	light.Parent = hitbox
	local highlight = maid:Add(Instance.new("Highlight"))
	highlight.Adornee = model
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = mushroom.Color
	highlight.OutlineColor = mushroom.Color
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.Parent = model
	local pivot = model:GetPivot()
	local v13 = {
		Model = model,
		Anchor = hitbox,
		Index = attribute,
		Color = mushroom.Color,
		Light = light,
		Highlight = highlight,
		Beads = makeBeads(hitbox, pivot, maid),
		BasePivot = pivot,
		BaseScale = model:GetScale(),
		Glow = "Off",
		GlowId = 0,
		Aimed = false,
		Motions = {},
		BumpedAt = 0,
		Pressed = false,
		Trove = maid
	}
	paintBeads(v13)
	watchBumps(v13)
	v[model] = v13
	table.insert(v3, {
		Index = attribute,
		Anchor = hitbox
	})
end

local function unbind(p)
	local v11 = v[p]

	if v11 == nil then
		return
	end

	v[p] = nil
	v2[v11] = nil

	for k, v12 in v3 do
		if v12.Anchor ~= v11.Anchor then
			continue
		end

		table.remove(v3, k)
		break
	end

	v11.Trove:Destroy()
end

local function each(p: number, callback)
	for _, v11 in v do
		if v11.Index == p then
			callback(v11)
		end
	end
end

local v10 = {
	Start = function(callback)
		v8 = callback
		local mushroom = BanjoCricket.Tags.Mushroom
		CollectionService:GetInstanceAddedSignal(mushroom):Connect(bind)
		CollectionService:GetInstanceRemovedSignal(mushroom):Connect(unbind)

		for _, v11 in CollectionService:GetTagged(mushroom) do
			bind(v11)
		end

		RunService.PreRender:Connect(animate)
		RunService.PreSimulation:Connect(trackPlayer)
	end,
	Anchor = function(p: number)
		for _, v11 in v3 do
			if v11.Index == p then
				return v11.Anchor
			end
		end

		return nil
	end,
	Targets = function()
		return v3
	end,
	DistanceFrom = function(vector3: Vector3)
		local v11 = 1e999

		for _, v12 in v3 do
			v11 = math.min(v11, (v12.Anchor.Position - vector3).Magnitude)
		end

		return v11
	end,
	RandomIndex = function(object)
		if #v3 == 0 then
			return nil
		end

		return v3[object:NextInteger(1, #v3)].Index
	end,
	Flash = function(p: number, duration: number)
		for _, v11 in v do
			if v11.Index ~= p then
				continue
			end

			setGlow(v11, "Lit", duration) -- equivalent call inferred; original call site unknown
		end
	end,
	Move = function(p: number, p2: string)
		for _, v11 in v do
			if v11.Index ~= p then
				continue
			end

			move(v11, p2) -- equivalent call inferred; original call site unknown
		end
	end,
	MoveAll = function(p: string)
		for _, v11 in v do
			move(v11, p) -- equivalent call inferred; original call site unknown
		end
	end,
	Squish = function(p: number)
		local currentCamera = Workspace.CurrentCamera

		for _, v11 in v do
			if not (v11.Index == p and (currentCamera == nil or (currentCamera.CFrame.Position - v11.Anchor.Position).Magnitude <= 150)) then
				continue
			end

			move(v11, "Squish") -- equivalent call inferred; original call site unknown
		end
	end,
	Pulse = function()
		for _, v11 in v do
			v11.GlowId += 1
			v11.Glow = "Soft"
			refreshGlow(v11)
			local v12 = v11
			local glowId = v11.GlowId
			task.delay(0.45, function()
				if v12.GlowId == glowId and not v4 then
					v12.Glow = "Off"
					refreshGlow(v12)
				end
			end)
			move(v11, "Breathe") -- equivalent call inferred; original call site unknown
		end
	end,
	Celebrate = function()
		for _, v11 in v do
			setGlow(v11, "Lit", BanjoCricket.Timing.Note) -- equivalent call inferred; original call site unknown
			move(v11, "Bounce") -- equivalent call inferred; original call site unknown
		end
	end,
	Darken = function()
		v4 = false

		for _, v11 in v do
			v11.GlowId += 1
			v11.Glow = "Off"
			refreshGlow(v11)
		end
	end,
	SetAllLit = function(flag: boolean)
		v4 = flag

		for _, v11 in v do
			v11.GlowId += 1
			v11.Glow = flag and "Lit" or "Off"
			refreshGlow(v11)

			if not flag then
				continue
			end

			move(v11, "Bounce") -- equivalent call inferred; original call site unknown
		end
	end,
	ShowAim = function(p: number?)
		for _, v11 in v do
			local aimed = v11.Index == p

			if v11.Aimed == aimed then
				continue
			end

			v11.Aimed = aimed
			refreshGlow(v11)
		end
	end,
	SetProgress = function(p: number, flag: boolean)
		local v11

		if v5 < p then
			v11 = p
		end

		v5 = p
		v6 = flag

		for _, v12 in v do
			paintBeads(v12, v11)
		end
	end
}
return table.freeze(v10)