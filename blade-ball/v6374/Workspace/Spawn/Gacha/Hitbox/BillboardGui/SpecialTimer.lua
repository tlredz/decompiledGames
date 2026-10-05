game:GetService("ReplicatedStorage")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

workspace:WaitForChild("Spawn")
local Utils = require(game.ReplicatedStorage.Common.Utils)
local module = require("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local parent = script.Parent
local connection = nil
connection = Utils.Thread.Every(1, function()
	local v = module.getTimestamps().endTimestamp - os.time()

	if v > 0 then
		parent.TimerLabel.Text = Utils.ValueConvertor:FormatTimeWithDaysFull(v)
	elseif parent and parent.Parent then
		parent.Parent:Destroy()
		connection:Disconnect()
	end
end)