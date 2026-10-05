local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind("Game.Balance.GroupReward", {
	Label = "+10K Speed",
	SpeedPowerAward = 10000
}, {
	SpeedPowerAward = true
}, false)

local function updateLabel()
	local v2 = v
	local label

	if v.SpeedPowerAward == 10000 then
		label = "+10K Speed"
	else
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		label = `+{require(ReplicatedStorage2.Packages.FormatNumber.Simple).FormatCompact(v.SpeedPowerAward, ".#")} Speed`
	end

	v2.Label = label
end

local label2

if v.SpeedPowerAward == 10000 then
	label2 = "+10K Speed"
else
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	label2 = `+{require(ReplicatedStorage2.Packages.FormatNumber.Simple).FormatCompact(v.SpeedPowerAward, ".#")} Speed`
end

v.Label = label2
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2.Shared.Flags.BalanceConfig).Changed:Connect(updateLabel)
return v