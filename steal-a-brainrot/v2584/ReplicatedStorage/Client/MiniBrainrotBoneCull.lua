local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local MiniBoneRegistry = require(ReplicatedStorage.Shared.MiniBoneRegistry)

if not ServerData.IsTradePlaza() then
	return
end

local currentCamera = workspace.CurrentCamera
local v = {}

local function siftUp(p: number)
	while p > 1 do
		local v2 = p // 2

		if not (v[p].nextUpdate < v[v2].nextUpdate) then
			break
		end

		local v3 = v
		local v4 = v
		local v5 = v[v2]
		local v6 = v[p]
		v3[p] = v5
		v4[v2] = v6
		p = v2
	end
end

local function siftDown(p: number)
	local count = #v

	while true do
		local v2 = p * 2
		local v3 = v2 + 1

		if v2 <= count then
			if not (v[v2].nextUpdate < v[p].nextUpdate) then
				v2 = p
			end
		else
			v2 = p
		end

		if v3 <= count and v[v3].nextUpdate < v[v2].nextUpdate then
			v2 = v3
		end

		if v2 == p then
			break
		end

		local v4 = v
		local v5 = v
		local v6 = v[v2]
		local v7 = v[p]
		v4[p] = v6
		v5[v2] = v7
		p = v2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function heapPush(p)
	local v2 = #v + 1
	v[v2] = p
	siftUp(v2)
end

local function heapPop()
	local count = #v
	local v2 = v[1]
	local v3 = v[count]
	v[count] = nil

	if count > 1 then
		v[1] = v3
		siftDown(1)
	end

	return v2
end

local function setBonesCulled(p, bonesCulled: boolean)
	p.bonesCulled = bonesCulled

	if bonesCulled then
		for _, bone in p.bones do
			bone.bone.Parent = nil
		end
	else
		for _, bone in p.bones do
			if bone.parent.Parent then
				bone.bone.Parent = bone.parent
			end
		end
	end
end

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	local instant = FFlags:GetInstant("TradePlaza/BoneCullDistance", 60)
	FFlags:GetInstant("TradePlaza/BoneChangesPerFrame", 3)
	local instant2 = FFlags:GetInstant("TradePlaza/BoneCullBudget", 0.001)
	local instant3 = FFlags:GetInstant("TradePlaza/BoneCullMaxPerFrame", 200)
	local position = currentCamera.CFrame.Position
	debug.profilebegin("MiniBrainrotBoneCull")
	local count = 0

	while count < instant3 and instant2 > 0 do
		local v2 = v[1]

		if not v2 or now < v2.nextUpdate then
			break
		end

		local count2 = #v
		local _ = v[1]
		local v3 = v[count2]
		v[count2] = nil

		if count2 > 1 then
			v[1] = v3
			siftDown(1)
		end

		if v2.removed then
			continue
		end

		if v2.root.Parent then
			local lastTime = os.clock()
			local magnitude = (position - v2.root.Position).Magnitude
			local particlesCulled = instant <= magnitude

			if v2.particlesCulled ~= particlesCulled then
				for _, particle in v2.particles do
					particle.Enabled = not particlesCulled
				end

				v2.particlesCulled = particlesCulled
			end

			v2.nextUpdate = now + (particlesCulled and 0.5 or magnitude < instant * 0.5 and 0.1 or 0.3333333333333333)
			heapPush(v2) -- equivalent call inferred; original call site unknown
			instant2 -= os.clock() - lastTime
			count += 1
		else
			v2.removed = true
		end
	end

	debug.profileend()
end)
Observers.observeTag("MiniBrainrotCull", function(folder)
	local primaryPart = folder.PrimaryPart or folder:FindFirstChildWhichIsA("BasePart", true)

	if not primaryPart then
		return
	end

	local v2 = MiniBoneRegistry[folder]
	MiniBoneRegistry[folder] = nil
	local bones = v2 or {}

	if not v2 then
		for _, bone in folder:GetDescendants() do
			local parent = bone.Parent

			if bone:IsA("Bone") and parent and parent:IsA("BasePart") then
				table.insert(bones, {
					bone = bone,
					parent = parent
				})
			end
		end
	end

	local emitters = {}

	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") and emitter.Enabled then
			table.insert(emitters, emitter)
		end
	end

	if #bones == 0 and #emitters == 0 then
		return
	end

	local v4 = {
		root = primaryPart,
		bones = bones,
		particles = emitters,
		bonesCulled = false,
		particlesCulled = false,
		nextUpdate = 0,
		removed = false
	}

	for _, bone in v4.bones do
		if bone.parent.Parent then
			bone.bone.Parent = bone.parent
		end
	end

	for _, v5 in emitters do
		v5.Enabled = false
	end

	v4.particlesCulled = true
	heapPush(v4) -- equivalent call inferred; original call site unknown
	return function()
		v4.removed = true

		if v4.bonesCulled then
			for _, bone in v4.bones do
				bone.bone:Destroy()
			end
		end
	end
end)