local lastTime = os.clock()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local jSONDecode = HttpService:JSONDecode(script:GetAttribute("Baseline"))

local function inspect(folder, starterGui)
	local result = {
		exists = folder ~= nil,
		count = 0,
		images = 0,
		imagesLoaded = 0,
		missing = 0,
		missingExamples = {}
	}

	if not folder then
		return result
	end

	local v = {}

	for _, guiObject in ipairs(folder:GetDescendants()) do
		result.count += 1
		local v2 = guiObject:GetFullName():sub(#folder:GetFullName() + 2) .. " [" .. guiObject.ClassName .. "]"
		v[v2] = (v[v2] or 0) + 1

		if not ((guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) and guiObject.Image ~= "") then
			continue
		end

		result.images += 1

		if guiObject.IsLoaded then
			result.imagesLoaded += 1
		end
	end

	if not starterGui then
		return result
	end

	for k, item in pairs(starterGui) do
		local v2 = math.max(0, item - (v[k] or 0))
		result.missing += v2

		if v2 > 0 and #result.missingExamples < 3 then
			table.insert(result.missingExamples, k)
		end
	end

	return result
end

local function snapshot(stage)
	local localPlayer = Players.LocalPlayer
	local v = {
		stage = stage,
		t = math.round((os.clock() - lastTime) * 1000) / 1000,
		isLoaded = game:IsLoaded(),
		hasCharacter = localPlayer and localPlayer.Character ~= nil
	}
	local StarterGui = game:GetService("StarterGui")
	v.StarterGui = inspect(StarterGui, jSONDecode.StarterGui)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	v.ReplicatedStorage = inspect(ReplicatedStorage, jSONDecode.ReplicatedStorage)
	v.PlayerGui = inspect(localPlayer and localPlayer:FindFirstChild("PlayerGui"), jSONDecode.StarterGui)
	print("[LoadingTimingProbe] " .. HttpService:JSONEncode(v))
end

local function afterLoaded()
	snapshot("Loaded")

	for _, duration in ipairs({
		0.25,
		1,
		3,
		8
	}) do
		local v = duration
		task.delay(duration, function()
			snapshot("Loaded+" .. v .. "s")
		end)
	end

	task.delay(9, function()
		print("[LoadingTimingProbe] DONE")
	end)
end

if game:IsLoaded() then
	snapshot("Start-already-loaded")
	afterLoaded()
else
	game.Loaded:Once(afterLoaded)
	snapshot("Start")
	task.spawn(function()
		while not game:IsLoaded() do
			task.wait(0.5)

			if not game:IsLoaded() then
				snapshot("Waiting")
			end
		end
	end)
end