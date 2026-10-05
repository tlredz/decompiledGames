local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetIds = require(ReplicatedStorage.Shared.Utils.AssetIds)
local Preload = require(ReplicatedStorage.Shared.Utils.Preload)
local v2 = {}
local v3 = {}
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function schedulePreload(animation)
	table.insert(v3, animation)

	if flag then
		return
	end

	flag = true
	task.defer(function()
		while true do
			local v4 = v3
			v3 = {}

			if #v4 > 0 then
				Preload.WarmAssets(v4)
			end

			if #v3 ~= 0 then
				continue
			end

			flag = false
			break
		end
	end)
end

local v = {
	Get = function(p)
		local parsed = AssetIds.Parse(p)
		assert(parsed ~= nil, (`invalid animation asset id {p}`))
		local v4 = v2[parsed]

		if v4 then
			return v4
		end

		local animation = Instance.new("Animation")
		animation.Name = `Animation_{parsed}`
		animation.AnimationId = `rbxassetid://{parsed}`
		v2[parsed] = animation
		schedulePreload(animation) -- equivalent call inferred; original call site unknown
		return animation
	end
}
return table.freeze(v)