local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = require(ReplicatedStorage.Packages.Log)
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.string)
local strict2 = t.strict(t.table)
local v = {}
local v2 = {}
local v3 = Log.new()
local v4 = {}

local function preload(p: string)
	local v5 = "Unknown failure"

	for i = 1, 3 do
		local v6 = nil
		local success, result = pcall(function()
			ContentProvider:PreloadAsync({ p }, function(_: string, p2)
				v6 = p2
			end)
		end)

		if success then
			v6 = v6 or ContentProvider:GetAssetFetchStatus(p)

			if v6 == Enum.AssetFetchStatus.Success then
				v[p] = true
				v2[p] = nil
				return
			else
				v5 = tostring(v6)

				if v6 ~= Enum.AssetFetchStatus.TimedOut then
					break
				end
			end
		else
			v5 = tostring(result)
		end

		if i < 3 then
			task.wait(i * 0.5)
		end
	end

	v2[p] = nil
	v3:AtWarning():Log((`Failed to preload image {p}: {v5}`))
end

function v4.Request(p: string)
	strict(p)

	if p == "" or v[p] or v2[p] then
		return false
	end

	if ContentProvider:GetAssetFetchStatus(p) == Enum.AssetFetchStatus.Success then
		v[p] = true
		return false
	end

	v2[p] = true
	task.spawn(preload, p)
	return true
end

function v4.RequestAll(items)
	strict2(items)
	local count = 0

	for _, item in items do
		if v4.Request(item) then
			count += 1
		end
	end

	return count
end

return table.freeze(v4)