local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function registerTimer(label)
	if not label:IsA("TextLabel") then
		return
	end

	local model = label:FindFirstAncestorOfClass("Model")

	if model then
		v[label] = model
	end
end

local function unregisterTimer(p)
	v[p] = nil
end

for _, v2 in ipairs(CollectionService:GetTagged("Timer")) do
	registerTimer(v2) -- equivalent call inferred; original call site unknown
end

CollectionService:GetInstanceAddedSignal("Timer"):Connect(registerTimer)
CollectionService:GetInstanceRemovedSignal("Timer"):Connect(unregisterTimer)
RunService.RenderStepped:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v2 in v do
		local bridgeDie = v2:GetAttribute("BridgeDie")
		local serverStartTime = v2:GetAttribute("ServerStartTime")

		if not (bridgeDie and serverStartTime) then
			continue
		end

		local v3 = math.max(0, bridgeDie - (serverTimeNow - serverStartTime))

		if v3 > 0 then
			k.Text = string.format("%.2f", v3)
			k.TextColor3 = v3 < 1 and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
		else
			k.Text = "Wait..."
			k.TextColor3 = Color3.new(1, 0, 0)
		end
	end
end)