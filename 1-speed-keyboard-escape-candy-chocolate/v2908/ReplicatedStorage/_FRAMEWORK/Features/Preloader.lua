local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local FeatureManager = require(script.Parent.Parent.Libraries.FeatureManager)
local SoundManager = require(script.Parent.ClientOnly.SoundManager)
local v = nil
local v2 = nil
local v3 = nil
local tracksByAnimationId = {}
local v4 = {}
local v5 = {}

local function normalizeAnimationId(animationId: string)
	local v6 = string.match(animationId, "^%s*rbxassetid://(%d+)%s*$") or string.match(animationId, "^%s*(%d+)%s*$")

	if v6 == nil or string.find(v6, "[1-9]") == nil then
		return nil, "Preloader received an invalid animation ID."
	end

	return `rbxassetid://{v6}`, nil
end

local function getPreloadAnimator()
	local v6 = v2

	if v6 ~= nil and v3 ~= nil then
		return v6
	end

	local model = Instance.new("Model")
	model.Name = "AnimationPreloader"
	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.Parent = model
	local animator = Instance.new("Animator")
	animator.Name = "Animator"
	animator.Parent = humanoid
	v3 = model
	v2 = animator
	return animator
end

local function preloadAnimation(instance)
	local animationId, v6 = normalizeAnimationId(instance.AnimationId)

	if animationId == nil then
		error(v6 or "Preloader received an invalid animation ID.")
		return
	end

	local v7 = tracksByAnimationId[animationId]

	if v7 ~= nil then
		return v7
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = getPreloadAnimator():LoadAnimation(animation)
	animation:Destroy()
	tracksByAnimationId[animationId] = track
	return track
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveImage(instance)
	if instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("ParticleEmitter") then
		return instance.Texture
	end

	return instance.Image
end

local function addImageLabel(image: string)
	local parent = v

	if parent ~= nil and v4[image] == nil then
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "PreloadedImage"
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderSizePixel = 0
		imageLabel.Position = UDim2.fromOffset(0, 0)
		imageLabel.Size = UDim2.fromOffset(1, 1)
		imageLabel.Image = image
		imageLabel.Parent = parent
		v4[image] = imageLabel
	end
end

local function preloadImage(instance)
	local image = resolveImage(instance) -- equivalent call inferred; original call site unknown

	if image == "" then
		error("Preloader cannot preload an empty image.")
	elseif v == nil then
		v5[image] = true
	else
		addImageLabel(image)
	end
end

local function initializeImagePreloader()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AssetPreloader"
	screenGui.DisplayOrder = -2147483640
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = Players.LocalPlayer.PlayerGui
	v = screenGui

	for k in v5 do
		addImageLabel(k)
	end

	table.clear(v5)
end

local Preloader = {
	preload = function(instance)
		if instance:IsA("Sound") then
			SoundManager.preloadSound(instance.SoundId)
			return nil
		end

		if instance:IsA("Animation") then
			return preloadAnimation(instance)
		end

		if not (instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("ParticleEmitter") or instance:IsA("ImageLabel") or instance:IsA("ImageButton")) then
			error("Preloader only supports Sound, Animation, Decal, Texture, ParticleEmitter, ImageLabel, and ImageButton instances.")
			return
		end

		if not RunService:IsClient() then
			return nil
		end

		local image = resolveImage(instance) -- equivalent call inferred; original call site unknown

		if image == "" then
			error("Preloader cannot preload an empty image.")
		elseif v == nil then
			v5[image] = true
		else
			addImageLabel(image)
		end

		return nil
	end,
	clearImagePreload = function()
		if RunService:IsServer() then
			return
		end

		for _, v6 in v4 do
			v6:Destroy()
		end

		table.clear(v4)
		table.clear(v5)
	end
}
FeatureManager.RegisterFeature(script.Name, {
	OnUIInit = initializeImagePreloader
})
return Preloader