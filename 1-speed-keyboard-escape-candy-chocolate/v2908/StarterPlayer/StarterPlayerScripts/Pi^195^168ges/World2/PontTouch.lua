local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local _ = {
	Tag = "BridgeTouch",
	FadeOutDuration = 1,
	InvisibleTime = 1,
	FadeInDuration = 1,
	FadeSteps = 30
}
local localPlayer = Players.LocalPlayer
local v = {}

local function buildCache(folder)
	local v2 = {
		Parts = {},
		Texts = {}
	}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(v2.Parts, {
				Instance = descendant,
				OrigTransparency = descendant.Transparency,
				OrigCanCollide = descendant.CanCollide
			})
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			table.insert(v2.Texts, {
				Instance = descendant,
				OrigTransparency = descendant.TextTransparency
			})
		end
	end

	return v2
end

local function applyFade(cache, p: number)
	for _, part in ipairs(cache.Parts) do
		part.Instance.Transparency = part.OrigTransparency + p * (1 - part.OrigTransparency)
	end

	for _, text in ipairs(cache.Texts) do
		text.Instance.TextTransparency = text.OrigTransparency + p * (1 - text.OrigTransparency)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCollision(cache, canCollide: boolean)
	for _, part in ipairs(cache.Parts) do
		if part.OrigCanCollide then
			part.Instance.CanCollide = canCollide
		end
	end
end

local function restoreOriginal(cache)
	for _, part in ipairs(cache.Parts) do
		part.Instance.Transparency = part.OrigTransparency
		part.Instance.CanCollide = part.OrigCanCollide
	end

	for _, text in ipairs(cache.Texts) do
		text.Instance.TextTransparency = text.OrigTransparency
	end
end

local function triggerBridge(folder)
	if v[folder] then
		return
	end

	v[folder] = true
	local cache = buildCache(folder)
	local v2 = (folder:GetAttribute("FadeOutDuration") or 1) / 30

	for i = 1, 30 do
		applyFade(cache, i / 30)
		task.wait(v2)
	end

	applyFade(cache, 1)
	setCollision(cache, false) -- equivalent call inferred; original call site unknown
	task.wait(1)

	for i = 30, 0, -1 do
		applyFade(cache, i / 30)
		task.wait(0.03333333333333333)
	end

	restoreOriginal(cache)
	v[folder] = nil
end

local function connectTouch(folder)
	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Touched:Connect(function(otherPart)
				if not otherPart.Parent then
					return
				end

				local character = localPlayer.Character

				if character and otherPart.Parent == character then
					triggerBridge(folder)
				end
			end)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupModel(model)
	if not model:IsA("Model") then
		return
	end

	connectTouch(model)
end

for _, v2 in ipairs(CollectionService:GetTagged("BridgeTouch")) do
	setupModel(v2) -- equivalent call inferred; original call site unknown
end

CollectionService:GetInstanceAddedSignal("BridgeTouch"):Connect(setupModel)