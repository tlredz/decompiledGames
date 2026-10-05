local SceneController = require(game.ReplicatedStorage.Controllers.SceneController)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Config = require(script.Config)
require(game.ReplicatedStorage.Controllers.SceneController.SceneRigs.Helper.HelperTypes)
local v = nil
local v2 = 1
return function(data)
	v2 += 1
	local v3 = v2

	if v then
		v:Destroy()
	end

	v = Trove.new()
	local maid = assert(v)
	assert(maid):Add(function()
		v3 = -1
		v = nil
		maid = nil
	end)
	maid:Add(task.delay(0.1, function()
		local flag = false
		maid:Add(task.defer(function()
			local total = 0

			while flag == false do
				if total >= 10 then
					warn((`critial fallback hit for {data.ItemId}:{debug.traceback()}`))
					local sequenceType = data.SequenceType

					if flag then
						break
					end

					flag = true

					if not maid or v3 ~= v2 then
						break
					end

					data.OnSequenceFinished(sequenceType, nil)
					break
				else
					total += task.wait(1)
				end
			end
		end))
		local v4 = Config[data.ItemId]

		if v4 == nil then
			warn((`no info in map for {data.ItemId}`))
		end

		local v5 = nil
		local v6 = nil
		local physicalMovesetItemId

		if v4 then
			physicalMovesetItemId = v4.PhysicalMovesetItemId
		else
			physicalMovesetItemId = data.ItemId
		end

		local skinItemId

		if v4 then
			skinItemId = v4.SkinItemId
		else
			skinItemId = data.SkinItemId
		end

		if physicalMovesetItemId then
			local match = ItemConfig.match(physicalMovesetItemId)

			if match:isErr() then
				match:inspectErr(warn)
			else
				v5 = match:unwrap()
			end
		end

		if skinItemId then
			local match = ItemConfig.match(skinItemId)

			if match:isErr() then
				match:inspectErr(warn)
			else
				v6 = match:unwrap()
			end
		end

		if v5 == nil then
			warn(v4, (`unknown fruitConfig from {data.ItemId}`))
			local sequenceType = data.SequenceType

			if not flag then
				flag = true

				if maid and v3 == v2 then
					data.OnSequenceFinished(sequenceType, nil)
				end
			end
		else
			local storageKey = v5.Index.StorageKey
			local storageKey2

			if v6 then
				storageKey2 = v6.Index.StorageKey
			end

			local v7 = SceneController.TryGetCurrentClass()

			if not v7 or v7.Data.PhysicalMoveset ~= storageKey or v7.Data.SkinStorageName ~= storageKey2 then
				v7 = nil
			end

			if v7 == nil then
				if SceneController.Scenes[storageKey] then
					v7 = SceneController.Scenes[storageKey].new({
						SkinStorageName = storageKey2
					})
				else
					v7 = nil
				end
			end

			if v7 == nil then
				warn((`unknown class from fruitname={storageKey}`))
			elseif maid ~= nil then
				maid:Add(task.defer(function()
					data.OnSequenceStarted(data.SequenceType, v7)
					local v8 = v7.PlaySequence({
						Name = data.SequenceType,
						OnFinish = function()
							local sequenceType = data.SequenceType
							local v9 = v7

							if not flag then
								flag = true

								if maid and v3 == v2 then
									data.OnSequenceFinished(sequenceType, v9)
								end
							end
						end
					})
					maid:Add(v8)
					v7.Data.Scene:Init()
				end))
			end
		end
	end))
	return function()
		if maid then
			maid:Destroy()
		end
	end
end