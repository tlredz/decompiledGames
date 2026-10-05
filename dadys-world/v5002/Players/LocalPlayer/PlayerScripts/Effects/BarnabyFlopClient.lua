local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local modules = ReplicatedStorage:WaitForChild("Modules", 30)
local effects = modules and modules:FindFirstChild("Effects")
local syncedAnimationController = effects and effects:FindFirstChild("SyncedAnimationController")

if not syncedAnimationController then
	warn("[BarnabyFlopClient] SyncedAnimationController missing; observer renderer disabled")
	return
end

local module = require(syncedAnimationController)

local function getFlopConfig()
	local genArcade = modules and modules:WaitForChild("GenArcade", 30)
	local swimmyBarnaby = genArcade and genArcade:WaitForChild("SwimmyBarnaby", 30)
	local flopConfig = swimmyBarnaby and swimmyBarnaby:FindFirstChild("FlopConfig")

	if not flopConfig then
		return nil
	end

	local success, result = pcall(require, flopConfig)
	return success and result or nil
end

local flopConfig = getFlopConfig()

if not flopConfig then
	warn("[BarnabyFlopClient] FlopConfig missing; observer renderer disabled")
	return
end

local function resolveTemplate()
	local child = ReplicatedStorage

	for _, childName in ipairs(flopConfig.templatePath) do
		child = child and child:FindFirstChild(childName)
	end

	return child
end

local v = {}
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupFor(model)
	if v2[model] then
		v3[model] = true
	end

	local v4 = v[model]

	if v4 then
		v4:Cleanup()
		v[model] = nil
	end
end

local function getController(model)
	local v4 = v[model]

	if v4 then
		return v4
	end

	if v2[model] then
		return nil
	end

	local child = ReplicatedStorage

	for _, childName in ipairs(flopConfig.templatePath) do
		child = child and child:FindFirstChild(childName)
	end

	if not child then
		warn(string.format("[FlopDebug][Observer] %s: template missing -> renders nothing", localPlayer.Name))
		return nil
	end

	local child2 = model:FindFirstChild(flopConfig.attachPartName)

	if not child2 then
		v2[model] = true
		child2 = model:WaitForChild(flopConfig.attachPartName, 5)
		v2[model] = nil

		if v3[model] then
			v3[model] = nil
			return nil
		end
	end

	if child2 then
		if not model.Parent then
			return nil
		end

		if v[model] then
			return v[model]
		end

		local v5 = module.new({
			template = child,
			attachTo = child2,
			offset = flopConfig.resolveOffset(),
			animationIds = flopConfig.hopAnimationIds,
			cooldown = flopConfig.cooldown,
			overlapPolicy = flopConfig.resolveOverlapPolicy(),
			hideWhilePlaying = flopConfig.hideWhilePlaying,
			meshTextureOverrides = flopConfig.resolveTextureOverrides(model)
		})
		v[model] = v5
		return v5
	else
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
		local magnitude = humanoidRootPart and primaryPart and math.floor((humanoidRootPart.Position - primaryPart.Position).Magnitude) or -1
		warn(string.format(
			"[FlopDebug][Observer] %s: ANCHOR NOT FOUND on %s after %ds (dist=%s) -> renders nothing",
			localPlayer.Name,
			tostring(model.Name),
			5,
			(tostring(magnitude))
		))
		return nil
	end
end

local function onFlop(model, p)
	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		warn(string.format(
			"[FlopDebug][Observer] %s: bad character arg (%s) -> ignored",
			localPlayer.Name,
			(typeof(model))
		))
		return
	end

	if model == localPlayer.Character then
		return
	end

	print(string.format(
		"[FlopDebug][Observer] %s: recv flop for %s idx=%s",
		localPlayer.Name,
		tostring(model.Name),
		(tostring(p))
	))

	if p == nil then
		cleanupFor(model) -- equivalent call inferred; original call site unknown
	else
		local controller = getController(model)

		if not controller then
			warn(string.format(
				"[FlopDebug][Observer] %s: no controller for %s -> nothing rendered",
				localPlayer.Name,
				(tostring(model.Name))
			))
			return
		end

		controller:SetOverlapPolicy(flopConfig.resolveOverlapPolicy())
		controller:Play(p)
		print(string.format(
			"[FlopDebug][Observer] %s: PLAYED idx=%s on %s",
			localPlayer.Name,
			tostring(p),
			(tostring(model.Name))
		))
	end
end

local events = ReplicatedStorage:WaitForChild("Events", 30)
local barnabyFlopEvent = events and events:WaitForChild("BarnabyFlopEvent", 30)

if barnabyFlopEvent then
	barnabyFlopEvent.OnClientEvent:Connect(onFlop)
else
	warn("[BarnabyFlopClient] BarnabyFlopEvent missing; observer renderer disabled")
end