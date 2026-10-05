local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(script.Parent.Types)
local TempConfigs = require(game.ReplicatedStorage.ItemConfig.TempConfigs)
local TempIds = {}
local Global = require(game.ReplicatedStorage.Global)

if Global.IsSandboxed then
	local Index, v, v2 = require(game.ReplicatedStorage.ItemConfig.Data.Index)

	for _, v3 in Index, v, v2 do
		local itemId = v3["Item Id"]
		local RawSource = require(script.Parent.RawSource)

		if not (itemId <= #RawSource) then
			table.insert(TempIds, {
				Type = v3["Id Type"],
				StorageKey = v3["Storage Key"]
			})
		end
	end
end

for _, tempConfig in TempConfigs do
	table.insert(TempIds, {
		Type = tempConfig.Index.IdType,
		StorageKey = tempConfig.Index.StorageKey
	})
end

TableUtil.deepFreeze(TempIds)
return TempIds