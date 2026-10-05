local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local _ = {
	targetTimestamp = 1792260000
}
local now = 0

local function fn()
	local v = math.max(0, (math.ceil(1792260000 - workspace:GetServerTimeNow())))
	local v2 = math.floor(v / 86400)
	local v3 = math.floor(v % 86400 / 3600)
	local v4 = math.floor(v % 3600 / 60)
	local v5 = v % 60
	local text = string.format("%02d:%02d:%02d:%02d", v2, v3, v4, v5)

	for _, label in CollectionService:GetTagged("HalloweenEventCountdown") do
		if label:IsA("TextLabel") then
			label.Text = text
		end
	end
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			now = os.clock()
			fn()
		end
	end,
	OnUpdate = function()
		if RunService:IsClient() then
			local now2 = os.clock()

			if now2 - now >= 1 then
				now = now2
				fn()
			end
		end
	end
})
return {
	getTargetTimestamp = function()
		return 1792260000
	end
}