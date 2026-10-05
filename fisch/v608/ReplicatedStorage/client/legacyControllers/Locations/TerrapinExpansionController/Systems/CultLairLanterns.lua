local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local Observers = require(packages.Observers)
local v = {}
local _ = {
	LightPartTransparency = 0.15
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getUid(instance)
	return instance:GetAttribute("UID")
end

local function findPrompt(model)
	if not model:IsA("Model") then
		return model:FindFirstChildWhichIsA("ProximityPrompt", true)
	end

	local light = model:FindFirstChild("Light")
	local proximityPrompt = light and light:FindFirstChildWhichIsA("ProximityPrompt", true)

	if proximityPrompt then
		return proximityPrompt
	end

	return model:FindFirstChildWhichIsA("ProximityPrompt", true)
end

local function getLantern(p: string)
	for _, v2 in ipairs(CollectionService:GetTagged("CultLantern")) do
		if v2:GetAttribute("UID") == p then
			return v2
		end
	end

	return nil
end

local function applyLanternLight(model)
	if model:GetAttribute("IsLit") then
		return
	end

	model:SetAttribute("IsLit", true)
	local proximityPrompt

	if model:IsA("Model") then
		local light = model:FindFirstChild("Light")
		proximityPrompt = light and light:FindFirstChildWhichIsA("ProximityPrompt", true)

		if not proximityPrompt then
			proximityPrompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
		end
	else
		proximityPrompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
	end

	if proximityPrompt then
		proximityPrompt.Enabled = false
	end

	local light = model:FindFirstChild("Light", true)

	if light then
		light.Transparency = 0.15

		for _, descendant in ipairs(light:GetDescendants()) do
			if descendant:IsA("Light") then
				descendant.Enabled = true
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			end
		end
	end

	local descendantAddedConnection = nil
	descendantAddedConnection = model.DescendantAdded:Connect(function(proximityPrompt2)
		if proximityPrompt2:IsA("ProximityPrompt") then
			proximityPrompt2.Enabled = false

			if descendantAddedConnection and descendantAddedConnection.Connected then
				descendantAddedConnection:Disconnect()
				descendantAddedConnection = nil
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lightLantern(p: string)
	v[p] = true
	local lantern = getLantern(p)

	if lantern then
		applyLanternLight(lantern)
	end
end

return {
	Start = function(_)
		local remoteEvent = Net:RemoteEvent("CultLairLanterns/LightEvent", -1)
		local remoteFunction = Net:RemoteFunction("CultLairLanterns/GetLanterns")
		Observers.observeTag("CultLantern", function(object)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function tryApply()
				local uid = getUid(object) -- equivalent call inferred; original call site unknown

				if uid and v[uid] then
					applyLanternLight(object)
				end
			end

			tryApply() -- equivalent call inferred; original call site unknown
			local uIDChangedConnection = object:GetAttributeChangedSignal("UID"):Connect(tryApply)
			return function()
				if uIDChangedConnection and uIDChangedConnection.Connected then
					uIDChangedConnection:Disconnect()
					uIDChangedConnection = nil
				end
			end
		end)
		remoteEvent.OnClientEvent:Connect(function(p: string)
			lightLantern(p) -- equivalent call inferred; original call site unknown
		end)
		local success, result = pcall(function()
			return remoteFunction:InvokeServer()
		end)

		if success and typeof(result) == "table" then
			for _, v2 in ipairs(result) do
				lightLantern(v2) -- equivalent call inferred; original call site unknown
			end
		end

		for _, v2 in ipairs(CollectionService:GetTagged("CultLantern")) do
			local uid = getUid(v2) -- equivalent call inferred; original call site unknown

			if uid and v[uid] then
				applyLanternLight(v2)
			end
		end
	end
}