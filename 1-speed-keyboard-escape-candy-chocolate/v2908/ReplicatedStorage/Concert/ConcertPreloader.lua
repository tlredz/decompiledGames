local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local parent = script.Parent
local MicroProfiler = require(ReplicatedStorage.Utilities.MicroProfiler)
local ConcertPreloader = {}
local v = nil
local v2 = nil
local v3 = {}

local function NormalizeAnimationId(animationId)
	local v4 = nil

	if type(animationId) == "number" then
		if animationId ~= animationId or animationId <= 0 or animationId % 1 ~= 0 or math.abs(animationId) == 1e999 then
			return nil
		end

		v4 = string.format("%.0f", animationId)
	elseif type(animationId) == "string" then
		v4 = string.match(animationId, "^%s*rbxassetid://(%d+)%s*$") or string.match(animationId, "^%s*(%d+)%s*$")
	end

	if v4 and string.find(v4, "[1-9]") then
		return (`rbxassetid://{v4}`)
	end

	return nil
end

local function GetAnimationPreloadAnimator()
	if v2 and v2.Parent then
		return v2
	end

	local model = Instance.new("Model")
	model.Name = "ConcertAnimationPreloadRig" .. (RunService:IsServer() and "Server" or "Client")
	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.Parent = model
	local animator = Instance.new("Animator")
	animator.Parent = humanoid
	model.Parent = Workspace
	v = model
	v2 = animator
	return animator
end

local function CleanupAnimationPreloader()
	for _, v4 in v3 do
		pcall(v4.Destroy, v4)
	end

	table.clear(v3)

	if v then
		v:Destroy()
	end

	v = nil
	v2 = nil
end

function ConcertPreloader.PreloadAnimation(p)
	if not RunService:IsClient() or p.AnimationId == "" then
		return false
	end

	local animationPreloadAnimator = GetAnimationPreloadAnimator()
	local success, result = pcall(animationPreloadAnimator.LoadAnimation, animationPreloadAnimator, p)

	if success then
		table.insert(v3, result)
		return true
	end

	warn((`[ConcertPreloader] Could not preload animation {p.AnimationId}: {tostring(result)}`))
	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddProviderAsset(list, p, p2)
	if p[p2] then
		return
	end

	p[p2] = true
	table.insert(list, p2)
end

local function IsProviderAsset(animation)
	return animation:IsA("AudioPlayer") or animation:IsA("Sound") or animation:IsA("MeshPart") or animation:IsA("SpecialMesh") or animation:IsA("CharacterMesh") or animation:IsA("MaterialVariant") or animation:IsA("Decal") or animation:IsA("Texture") or animation:IsA("SurfaceAppearance") or animation:IsA("ImageLabel") or animation:IsA("ImageButton") or animation:IsA("ParticleEmitter") or animation:IsA("Trail") or animation:IsA("Beam") or animation:IsA("VideoFrame") or animation:IsA("Sky") or animation:IsA("Shirt") or animation:IsA("Pants") or animation:IsA("ShirtGraphic")
end

local function AddAnimation(list, p, list2, p2)
	local animationId = NormalizeAnimationId(p2.AnimationId)

	if not animationId or p[animationId] then
		return
	end

	p[animationId] = true
	table.insert(list, p2)

	if p2.Parent == nil then
		table.insert(list2, p2)
	end
end

local function CollectStageAssets(folder, list, p, animations, p2, animations2)
	for _, animation in folder:GetDescendants() do
		if animation:IsA("Animation") then
			local animationId = NormalizeAnimationId(animation.AnimationId)

			if animationId and not p2[animationId] then
				p2[animationId] = true
				table.insert(animations, animation)

				if animation.Parent == nil then
					table.insert(animations2, animation)
				end
			end
		elseif IsProviderAsset(animation) then
			AddProviderAsset(list, p, animation) -- equivalent call inferred; original call site unknown
		end
	end
end

local function PreloadAllStages()
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local v7 = {}
	local v8 = {}

	for _, moduleScript in parent.Stages:GetDescendants() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if success then
			if type(result) == "table" and typeof(result.AssetFolder) == "Instance" and result.AssetFolder:IsA("Folder") then
				debug.profilebegin("ConcertPreloader.CollectStageAssets")
				local success2, result2 = pcall(CollectStageAssets, result.AssetFolder, v4, v5, v6, v7, v8)
				debug.profileend()

				if not success2 then
					warn((`[ConcertPreloader] Could not inspect stage {moduleScript.Name}: {tostring(result2)}`))
				end

				RunService.Heartbeat:Wait()
			else
				warn((`[ConcertPreloader] Stage {moduleScript.Name} has no valid AssetFolder.`))
			end
		else
			warn((`[ConcertPreloader] Could not load stage {moduleScript.Name}: {tostring(result)}`))
		end
	end

	local v9 = os.clock() + 0.004

	for _, v10 in v6 do
		local v11 = v10
		MicroProfiler.Call("ConcertPreloader.LoadAnimation", function()
			ConcertPreloader.PreloadAnimation(v11)
		end)
		AddProviderAsset(v4, v5, v10) -- equivalent call inferred; original call site unknown

		if not (v9 <= os.clock()) then
			continue
		end

		RunService.Heartbeat:Wait()
		v9 = os.clock() + 0.004
	end

	for i = 1, #v4, 100 do
		local v10 = math.min(i + 100 - 1, #v4)
		local v11 = table.create(v10 - i + 1)

		for i2 = i, v10 do
			table.insert(v11, v4[i2])
		end

		local success, result = pcall(ContentProvider.PreloadAsync, ContentProvider, v11)

		if not success then
			warn((`[ConcertPreloader] ContentProvider batch failed: {tostring(result)}`))
		end

		RunService.Heartbeat:Wait()
	end

	CleanupAnimationPreloader()

	for _, v10 in v8 do
		v10:Destroy()
	end

	print((`[ConcertPreloader] Preloaded {#v4} content instance(s) and {#v6} animation(s).`))
end

local flag = false

function ConcertPreloader.Preload()
	if flag then
		return
	end

	flag = true

	if not RunService:IsClient() then
		return
	end

	task.spawn(PreloadAllStages)
end

return ConcertPreloader