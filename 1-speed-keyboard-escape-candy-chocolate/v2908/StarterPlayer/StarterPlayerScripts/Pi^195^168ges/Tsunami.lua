local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local v = {}

local function setupClient(instance)
	local tsunami = instance:FindFirstChild("Tsunami")
	local tsunamiSpawn = instance:FindFirstChild("TsunamiSpawn")
	local tsunamiEnd = instance:FindFirstChild("TsunamiEnd")
	local timer = instance:FindFirstChild("Timer", true)

	if tsunami and tsunamiSpawn and tsunamiEnd then
		v[instance] = {
			union = tsunami,
			label = timer,
			startCF = tsunamiSpawn.CFrame,
			endCF = tsunamiEnd.CFrame
		}
	end
end

RunService.PreRender:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v2 in v do
		local tsunamiStartTime = k:GetAttribute("TsunamiStartTime") or -1
		local travelTime = k:GetAttribute("TravelTime") or 1

		if tsunamiStartTime == -1 then
			continue
		end

		local v3 = serverTimeNow - tsunamiStartTime

		if v3 < 0 then
			continue
		end

		local v4 = v3 % travelTime / travelTime
		v2.union.CFrame = v2.startCF:Lerp(v2.endCF, v4)

		if not v2.label then
			continue
		end

		local v5 = travelTime - v3 % travelTime
		v2.label.Text = string.format("%.1f", v5)
	end
end)

for _, v2 in ipairs(CollectionService:GetTagged("TsunamiModel")) do
	setupClient(v2)
end

CollectionService:GetInstanceAddedSignal("TsunamiModel"):Connect(setupClient)