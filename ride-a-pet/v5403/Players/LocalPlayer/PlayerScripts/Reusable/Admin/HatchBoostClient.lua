local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local General = require(ReplicatedStorage.GameServices.General)
local localPlayer = Players.LocalPlayer
local eggHatchBoost = nil

local function Update()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	local playerGuiMain = playerGui and playerGui:FindFirstChild("Main")
	local activeBuffs = playerGuiMain and playerGuiMain:FindFirstChild("ActiveBuffs")
	eggHatchBoost = activeBuffs and activeBuffs:FindFirstChild("EggHatchBoost")
	local v = math.max(
		0,
		(math.ceil((ReplicatedStorage:GetAttribute("HatchSpeedBoostUntil") or 0) - workspace:GetServerTimeNow()))
	)
	local hatchSpeedBoostAmount = ReplicatedStorage:GetAttribute("HatchSpeedBoostAmount") or 1

	if eggHatchBoost then
		eggHatchBoost.Visible = v > 0 and hatchSpeedBoostAmount > 1
		local timer = eggHatchBoost:FindFirstChild("Timer")
		local statValue = eggHatchBoost:FindFirstChild("StatValue")

		if timer then
			timer.Text = string.format("%d:%02d:%02d", math.floor(v / 3600), math.floor(v / 60) % 60, v % 60)
		end

		if statValue then
			statValue.Text = "x" .. tostring(hatchSpeedBoostAmount)
		end
	end

	for _, v2 in Players:GetPlayers() do
		local hatchBoostTimes = v2:FindFirstChild("HatchBoostTimes")
		local plot = hatchBoostTimes and General:GetPlot(v2)
		local eggs = plot and plot:FindFirstChild("Eggs")

		if not eggs then
			continue
		end

		for _, child in eggs:GetChildren() do
			local eggKey = child:GetAttribute("EggKey")
			local attribute = eggKey and hatchBoostTimes:GetAttribute(eggKey)
			local eggData = child:FindFirstChild("EggData")
			local placeTime = eggData and eggData:FindFirstChild("PlaceTime")

			if not (type(attribute) == "number" and placeTime and placeTime.Value > 0 and attribute < placeTime.Value) then
				continue
			end

			placeTime.Value = attribute
		end
	end
end

ReplicatedStorage:GetAttributeChangedSignal("HatchSpeedBoostUntil"):Connect(Update)
ReplicatedStorage:GetAttributeChangedSignal("HatchSpeedBoostAmount"):Connect(Update)

while true do
	Update()
	task.wait(0.1)
end