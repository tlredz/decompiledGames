local UserGameSettings = UserSettings():GetService("UserGameSettings")
local RunService = game:GetService("RunService")
local v = RunService:IsStudio() and false
local v2 = #Enum.QualityLevel:GetEnumItems() - 1
local enumItems = Enum.SavedQualitySetting:GetEnumItems()
table.remove(enumItems, 1)
local Quality = {
	GUI_QUALITIES = enumItems
}
local count = #enumItems
Quality.MAX_GUI_SETTING = count
local v3 = nil
task.spawn(function()
	local FPSTracker = require(game.ReplicatedStorage.Util.FPSTracker)
	v3 = FPSTracker
end)
local result = {
	auto = Enum.SavedQualitySetting.QualityLevel1,
	manual = UserGameSettings.SavedQualityLevel or Enum.SavedQualitySetting.QualityLevel1
}
local v4 = 60
local v5 = 0

local function map(p: number, p2: number, p3: number, p4: number, p5: number)
	return p4 + (p - p2) * (p5 - p4) / (p3 - p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateQualityLevel()
	result.manual = UserGameSettings.SavedQualityLevel
end

function Quality.GetInternalQualityValue(_)
	local value = result.manual.Value
	return (math.floor((value - 0) * (v2 - 0) / (count - 0) + 0))
end

function Quality.GetQuality(_)
	return result
end

task.spawn(function()
	updateQualityLevel() -- equivalent call inferred; original call site unknown
	UserGameSettings:GetPropertyChangedSignal("SavedQualityLevel"):Connect(updateQualityLevel)

	while task.wait(1) do
		local v6 = v or v3 and v3.FPS

		if not v6 then
			break
		end

		if math.max(v5, v6) - math.min(v5, v6) >= 1 then
			local v7 = math.clamp(math.ceil(count / (60 / v6)), 1, count)

			if v7 ~= result.auto.Value then
				result.auto = enumItems[v7]
			end

			v5 = v6
		end

		v4 = math.clamp(v6, 0, 60)
	end
end)
return Quality