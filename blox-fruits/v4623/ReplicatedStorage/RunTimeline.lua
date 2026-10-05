local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local ProcessTimeline = require(game.ReplicatedStorage.Util.ProcessTimeline)
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)

function wrapTransformer(p, items, items2, callback)
	if items or items2 or callback then
		return function(p2)
			if items or items2 then
				local v = items == nil

				if items then
					for _, item in items do
						local flag = true

						for _, v4 in string.split(item, "&") do
							if p._TagMap[v4] and table.find(p._TagMap[v4], p2.Id) then
								continue
							end

							flag = false
							break
						end

						if not flag then
							continue
						end

						v = true
						break
					end
				end

				if v and items2 then
					for _, item in items2 do
						local flag = true

						for _, v4 in string.split(item, "&") do
							if p._TagMap[v4] and table.find(p._TagMap[v4], p2.Id) then
								continue
							end

							flag = false
							break
						end

						if not flag then
							continue
						end

						v = false
						break
					end
				end

				if not v then
					return nil
				end
			end

			if callback then
				return callback(p2)
			end

			return p2
		end
	end

	return nil
end

local class = {}
class.__index = class

function class:Log(p: string, items, value)
	local v = value or "INFO"

	if v and self.LevelFilter > ProcessTimeline.LOG_LEVELS[v] or not self.IsEnabled then
		return
	end

	local v2 = self._Timeline:log(p, v)

	if items then
		for _, item in items do
			self._TagMap[item] = self._TagMap[item] or {}
			table.insert(self._TagMap[item], v2.Id)
		end
	end

	return v2
end

function class:GetTagCounts()
	local result = {}

	for k, v in self._TagMap do
		result[k] = #v
	end

	return result
end

function class:Output(p2, p3, callback)
	return self._Timeline:output(wrapTransformer(self, p2, p3, callback))
end

function class:PrepReport(p2, p3, callback)
	return self._Timeline:prepReport(wrapTransformer(self, p2, p3, callback))
end

return ServiceLocker(function()
	return (setmetatable({
		IsInitialized = true,
		IsEnabled = BuildInfo.IS_PUBLISHED == false or GlobalUtil.FFlags.IsUnitTest,
		LevelFilter = BuildInfo.IS_PUBLISHED and 2 or 1,
		_TagMap = {},
		_Timeline = ProcessTimeline.new()
	}, class))
end, function(_) end)