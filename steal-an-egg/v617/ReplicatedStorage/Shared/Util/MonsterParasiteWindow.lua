local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MonsterParasite = require(ReplicatedStorage.Data.MonsterParasite)
local MonsterParasiteFlags = require(ReplicatedStorage.Shared.Flags.MonsterParasiteFlags)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)
local v = {
	Changed = Signal.new()
}
local v2 = MonsterParasiteFlags.Enabled:Get() and os.time() < MonsterParasite.EndsAt

function v.IsActive()
	return v2
end

function v.Refresh()
	local v3 = MonsterParasiteFlags.Enabled:Get() and os.time() < MonsterParasite.EndsAt

	if v3 == v2 then
		return
	end

	v2 = v3
	v.Changed:Fire(v2)
end

local v3 = Timer.new(1)
v3.Tick:Connect(v.Refresh)
v3:Start()
MonsterParasiteFlags.Enabled.Changed:Connect(v.Refresh)
return table.freeze(v)