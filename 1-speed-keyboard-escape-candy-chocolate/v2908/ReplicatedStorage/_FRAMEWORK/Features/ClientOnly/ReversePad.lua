local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local ReverseGravity = require(ReplicatedStorage._FRAMEWORK.Features.ReverseGravity)
local GravityController = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.GravityController)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local ReversePad = {
	onReversed = Signal.new()
}
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = {}
local v2 = {}
local v3 = {}
local flag = false
local v4 = nil
local v5 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function isPadEnabled(instance)
	local reversePadEnabled = instance:GetAttribute("ReversePadEnabled")
	return typeof(reversePadEnabled) ~= "boolean" or reversePadEnabled
end

-- equivalent calls inferred from this helper; original call sites unknown
local function padCooldown(instance)
	local reversePadCooldown = instance:GetAttribute("ReversePadCooldown")

	if typeof(reversePadCooldown) == "number" then
		return (math.max(reversePadCooldown, 0.25))
	end

	return 1
end

local function isLocalCharacterPart(instance)
	local character = Players.LocalPlayer.Character
	return character ~= nil and instance:IsDescendantOf(character)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flip()
	local v6 = not ReverseGravity.isReversed()
	ReverseGravity.setReversed(v6)
	ReversePad.onReversed:Fire(v6)
	return v6
end

local function checkTriggerAllowed(p, instance)
	local padEnabled = isPadEnabled(instance) -- equivalent call inferred; original call site unknown

	if padEnabled then
		if os.clock() >= p.cooldownUntil then
			padEnabled = not flag
		else
			padEnabled = false
		end
	end

	return padEnabled
end

local function hasLanded()
	local character = Players.LocalPlayer.Character
	local humanoid

	if character ~= nil then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if GravityController.isActive() then
		return GravityController.isGrounded()
	end

	return humanoid ~= nil and humanoid.FloorMaterial ~= Enum.Material.Air
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trackLanding()
	local character = Players.LocalPlayer.Character
	local humanoid

	if character ~= nil then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	local v6

	if GravityController.isActive() then
		v6 = GravityController.isGrounded()
	elseif humanoid == nil then
		v6 = false
	else
		v6 = humanoid.FloorMaterial ~= Enum.Material.Air
	end

	if v6 then
		local now = os.clock()
		v4 = v4 or now

		if now - v4 >= 0.05 then
			flag = false
			v4 = nil
		end
	else
		v4 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function armCooldown(p, instance)
	p.cooldownUntil = os.clock() + padCooldown(instance)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyTrigger(p, instance, instance2)
	armCooldown(p, instance) -- equivalent call inferred; original call site unknown
	flag = true
	v4 = nil
	instance2.AssemblyLinearVelocity = createVector(0, 0, 0)
	local v6 = flip() -- equivalent call inferred; original call site unknown
	logger:info("flip triggered, pad/cooldown/reversed:", instance:GetFullName(), padCooldown(instance), v6)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onPadTouched(p, instance, otherPart)
	local character = Players.LocalPlayer.Character
	local v6

	if character == nil then
		v6 = false
	else
		v6 = otherPart:IsDescendantOf(character)
	end

	if v6 then
		local padEnabled = isPadEnabled(instance) -- equivalent call inferred; original call site unknown

		if padEnabled then
			if os.clock() >= p.cooldownUntil then
				padEnabled = not flag
			else
				padEnabled = false
			end
		end

		if padEnabled then
			applyTrigger(p, instance, otherPart) -- equivalent call inferred; original call site unknown
		else
			armCooldown(p, instance) -- equivalent call inferred; original call site unknown
		end
	end
end

local function wirePart(maid, p, instance, part)
	local v6 = v3[part]

	if v6 == nil then
		local reversePadCooldown = part:GetAttribute("ReversePadCooldown")
		v3[part] = instance

		if not part.CanTouch then
			logger:warn("pad has CanTouch disabled and will never fire:", part:GetFullName())
		end

		if typeof(reversePadCooldown) == "number" and reversePadCooldown < 0.25 then
			logger:warn(
				"ReversePadCooldown is below the minimum and was raised, pad/set/minimum:",
				part:GetFullName(),
				reversePadCooldown,
				0.25
			)
		end

		p.wired[part] = maid:Add(part.Touched:Connect(function(otherPart)
			onPadTouched(p, part, otherPart) -- equivalent call inferred; original call site unknown
		end))
	elseif v6 ~= instance then
		logger:warn(
			"part already claimed by another tagged pad, the second tag is ignored, part/owner/ignored:",
			part:GetFullName(),
			v6:GetFullName(),
			instance:GetFullName()
		)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unwirePart(p, p2)
	local connection = p.wired[p2]

	if connection ~= nil then
		connection:Disconnect()
		p.wired[p2] = nil
		v3[p2] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wireDescendant(p, p2, p3, part)
	if part:IsA("BasePart") and not CollectionService:HasTag(part, "Reverse Pad") then
		wirePart(p, p2, p3, part)
	end
end

local function watchPadParts(maid, p, folder)
	for _, descendant in folder:GetDescendants() do
		wireDescendant(maid, p, folder, descendant) -- equivalent call inferred; original call site unknown
	end

	maid:Add(folder.DescendantAdded:Connect(function(descendant)
		wireDescendant(maid, p, folder, descendant) -- equivalent call inferred; original call site unknown
	end))
	maid:Add(folder.DescendantRemoving:Connect(function(part)
		if part:IsA("BasePart") then
			unwirePart(p, part) -- equivalent call inferred; original call site unknown
		end
	end))
end

local function setupPad(part)
	if v2[part] == nil then
		local v6 = Janitor.new()
		local v7 = {
			wired = {},
			cooldownUntil = 0
		}
		v[part] = v6
		v2[part] = v7

		if part:IsA("BasePart") then
			wirePart(v6, v7, part, part)
		else
			watchPadParts(v6, v7, part)
		end
	end
end

local function teardownPad(p)
	local v6 = v2[p]

	if v6 ~= nil then
		for k in v6.wired do
			unwirePart(v6, k) -- equivalent call inferred; original call site unknown
		end

		v[p]:Destroy()
		v[p] = nil
		v2[p] = nil
	end
end

local function startClient()
	local maid = Janitor.new()
	v5 = maid
	flag = false
	maid:Add(GravityController.onReset:Connect(function()
		flag = false
		v4 = nil
	end))
	local count = 0

	for _, v6 in CollectionService:GetTagged("Reverse Pad") do
		setupPad(v6)
		count += 1
	end

	maid:Add(CollectionService:GetInstanceAddedSignal("Reverse Pad"):Connect(setupPad))
	maid:Add(CollectionService:GetInstanceRemovedSignal("Reverse Pad"):Connect(teardownPad))
	logger:info("watching tag", "\"Reverse Pad\"", "tagged instances found:", count)
end

function ReversePad.getTag()
	return "Reverse Pad"
end

function ReversePad.trigger()
	return flip()
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if Common.IsClient() then
			startClient()
		end
	end,
	OnUpdate = function()
		if flag then
			trackLanding() -- equivalent call inferred; original call site unknown
		end
	end
})
return ReversePad