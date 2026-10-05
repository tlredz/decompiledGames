local RunService = game:GetService("RunService")
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(script.Parent.Types)
local ListCache = require(game.ReplicatedStorage.Util.ListCache)
local SlowSignal = require(game.ReplicatedStorage.Util.SlowSignal)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local v

if RunService:IsClient() then
	local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
	v = LoggerBuilder.new():tag("ItemReplicationService"):tag("Service"):display():build() or nil
else
	v = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getFullId(p: number, p2: string?)
	return (`{p}_{p2}`)
end

local function getSourceId(p: string, p2: number, p3: string?)
	return (`{p}_{p2}_{p3}`)
end

local function getRestrictionId(p, p2: number, p3: string, p4: string)
	return (`{p}_{p2}_{p3}_{p4}`)
end

local function getDepRuleId(p, p2, p3: number, p4: string)
	return (`{p}:{p2}_{p3}_{p4}`)
end

local function getRuleSourceId(p, p2: number, p3: string)
	return (`{p}_{p2}_{p3}`)
end

return {
	new = function(userId: number)
		local flag = true
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local v5 = {}
		local v6 = ListCache.new()
		local v7 = ListCache.new()
		local v8 = ListCache.new()
		local v9 = {}
		local v10 = ListCache.new()
		local count = 0
		local v11 = {}
		local v12 = {}
		local v13 = {}
		local v14 = SlowSignal.new()
		local v15 = {}
		local v16 = {}
		local v17 = {}
		local v18 = {}
		return {
			UserId = userId,
			GetItems = function(_, p2)
				if not p2 then
					return v6:dump()
				end

				if v2[p2] then
					return v2[p2]:dump()
				end

				return {}
			end,
			GetKeys = function(_)
				return TableUtil.keys(v3)
			end,
			GetAllIds = function(_, p2)
				if not p2 then
					return v7:dump()
				end

				if v4[p2] then
					return v4[p2]:dump()
				end

				return {}
			end,
			GetIfAlive = function(_)
				return flag
			end,
			Destroy = function(self)
				if not flag then
					return
				end

				flag = false
				v14:Destroy()

				for _, v19 in v17 do
					v19:Destroy()
				end

				table.clear(v17)

				for _, v19 in v16 do
					v19:Destroy()
				end

				table.clear(v16)

				for _, v19 in v15 do
					v19:Destroy()
				end

				table.clear(v15)

				for _, v19 in v2 do
					v19:clear()
				end

				table.clear(v2)

				for _, v19 in v4 do
					v19:clear()
				end

				table.clear(v4)

				for _, v19 in v5 do
					v19:clear()
				end

				table.clear(v5)
				v6:clear()
				v7:clear()
				v8:clear()
				table.clear(v13)
			end,
			Restrict = function(self, data)
				local formatted = `{data.Key}_{data.ItemId}_{data.Type ~= "ItemField" and "_" or data.UID or "ALL"}_{data.Type}`

				if v8:get(formatted) == data then
					return
				end

				if v8:get(formatted) == nil then
					v8:set(formatted, data)
				else
					warn((`there's already a restriction on {ItemConfig.match(data.ItemId):unwrap().Index.DebugLabel} -> {data.Key}`))
				end
			end,
			Unrestrict = function(self, data)
				local formatted = `{data.Key}_{data.ItemId}_{data.Type ~= "ItemField" and "_" or data.UID or "ALL"}_{data.Type}`

				if v8:get(formatted) == nil then
					warn((`no restriction for #{ItemConfig.match(data.ItemId):unwrap().Index.DebugLabel} -> {data.Key}`))
				else
					v8:set(formatted, nil)
				end
			end,
			GetIfHasRule = function(_, p2, p3, p4: number, p5: string)
				return v10:get((`{p2}:{p3}_{p4}_{p5}`)) ~= nil
			end,
			BindRule = function(self, data, flag2: boolean)
				local formatted = `{data.SourceKey}:{data.BoundKey}_{data.Source.ItemId}_{data.Source.NetworkedUID or "ALL"}`

				if v10:get(formatted) == data then
					return
				end

				if v10:get(formatted) ~= nil then
					warn((`there's already a rule bound to on {formatted}`))
					return
				end

				for _, restriction in data.Restrictions do
					self:Restrict(restriction)
				end

				v10:set(formatted, data)
				local formatted2 = `{data.SourceKey}_{data.Source.ItemId}_{data.Source.NetworkedUID or "ALL"}`
				v9[formatted2] = v9[formatted2] or ListCache.new()
				v9[formatted2]:set(data.BoundKey, data)
				local v19 = self:Get(data.SourceKey, data.Source.ItemId, data.Source.NetworkedUID)
				self:_ApplyRule(data, v19, v19, flag2)
			end,
			UnbindRule = function(self, data)
				local formatted = `{data.SourceKey}:{data.BoundKey}_{data.Source.ItemId}_{data.Source.NetworkedUID or "ALL"}`

				if v10:get(formatted) ~= data then
					return
				end

				for _, restriction in data.Restrictions do
					self:Unrestrict(restriction)
				end

				v10:set(formatted, nil)
				local formatted2 = `{data.SourceKey}_{data.Source.ItemId}_{data.Source.NetworkedUID or "ALL"}`

				if v9[formatted2] then
					v9[formatted2]:set(data.BoundKey, nil)
				end
			end,
			GetIfRestricted = function(_, p2, p3: number, p4: string)
				local v19 = v8:get((`{p2}_{p3}_{p4}_ItemField`)) ~= nil
				local v20 = v8:get((`{p2}_{p3}___RequireUID`)) ~= nil

				if p4 == "ALL" then
					return v19 or v20
				end

				return v19
			end,
			ConnectOnChanged = function(_, callback)
				return v14:Connect(callback)
			end,
			ConnectOnKeyChanged = function(_, p2, callback)
				if v17[p2] == nil then
					v17[p2] = SlowSignal.new()
				end

				return v17[p2]:Connect(callback)
			end,
			ConnectOnItemKeyChanged = function(_, p2, p3: number, p4: string?, callback)
				local formatted = `{p2}_{p3}_{p4}`

				if v15[formatted] == nil then
					v15[formatted] = SlowSignal.new()
				end

				return v15[formatted]:Connect(callback)
			end,
			ConnectOnItemChanged = function(_, p2: number, p3: string?, callback)
				local fullId = getFullId(p2, p3) -- equivalent call inferred; original call site unknown

				if v16[fullId] == nil then
					v16[fullId] = SlowSignal.new()
				end

				return v16[fullId]:Connect(callback)
			end,
			_ApplyRule = function(self, data, p3, p4, flag2: boolean)
				for k, v19 in data.Bound do
					local v20 = v19
					local v21 = k
					local success, result = pcall(function()
						local boundKey = data.BoundKey
						local itemId = v20.ItemId
						local networkedUID = v20.NetworkedUID
						local v24

						if data.Type == "Compute" then
							v24 = data.Callback(v20.ItemId, v20.NetworkedUID, p3, p4)
						else
							v24 = p3
						end

						self:Set(boundKey, true, itemId, networkedUID, v24, data.Restrictions[v21], flag2)
					end)

					if not success then
						warn((`failed to apply rule ({`{data.SourceKey}:{data.BoundKey}_{data.Source.ItemId}_{data.Source.NetworkedUID or "ALL"}`}) to bound item {`{v19.ItemId}_{v19.NetworkedUID}`}: {result}`))
					end
				end
			end,
			_Set = function(self, p2, itemId: number, networkedUID: string?, p5, flag2: boolean)
				assert(flag, "dead user replication cache")
				local formatted = `{p2}_{itemId}_{networkedUID}`
				local v19 = v13[formatted]

				if v19 == p5 then
					return false, v19
				end

				v13[formatted] = p5

				if flag2 then
					if not v18[formatted] then
						v18[formatted] = {
							staged = {
								ItemId = itemId,
								Key = p2,
								NetworkedUID = networkedUID,
								Value = p5
							},
							current = {
								ItemId = itemId,
								Key = p2,
								NetworkedUID = networkedUID,
								Value = v19
							}
						}
					end

					v18[formatted].staged.Value = p5

					if v18[formatted].staged.Value == v18[formatted].current.Value then
						v18[formatted] = nil
					end
				elseif v18[formatted] then
					v18[formatted] = nil
				end

				local fullId = getFullId(itemId, networkedUID) -- equivalent call inferred; original call site unknown

				if p5 == nil then
					if v2[p2] and v2[p2]:set(fullId, nil) <= 0 then
						v2[p2] = nil
					end

					if v4[p2] and v4[p2]:set(fullId, nil) <= 0 then
						v4[p2] = nil
					end

					if v5[fullId] and v5[fullId]:set(p2, nil) <= 0 then
						v5[fullId] = nil
					end

					v6:set(formatted, nil)
					v7:set(formatted, nil)
				else
					if v2[p2] == nil then
						v2[p2] = ListCache.new()
					end

					if v4[p2] == nil then
						v4[p2] = ListCache.new()
					end

					if v5[fullId] == nil then
						v5[fullId] = ListCache.new()
					end

					local v20 = {
						ItemId = itemId,
						Key = p2,
						NetworkedUID = networkedUID,
						Value = p5
					}
					table.freeze(v20)
					local v21 = {
						ItemId = itemId,
						NetworkedUID = networkedUID
					}
					table.freeze(v21)
					v2[p2]:set(fullId, v20)

					if v4[p2]:get(fullId) == nil then
						v4[p2]:set(fullId, v21)
					end

					v5[fullId]:set(p2, v20)
					v6:set(formatted, v20)

					if v7:get(formatted) == nil then
						v7:set(formatted, v21)
					end
				end

				return true, v19
			end,
			Set = function(self, p2, flag2: boolean, p3: number, value: string?, p4, p5, flag3: boolean)
				count += 1
				local v19 = count
				v3[p2] = true

				if p4 == false then
					p4 = nil
				elseif p4 == 0 then
					p4 = nil
				end

				local v20 = v8:get((`{p2}_{p3}_{value or "ALL"}_ItemField`))

				if v20 and v20 ~= p5 then
					if p5 then
						warn(debug.traceback((`restriction for key={p2}, itemId={ItemConfig.match(p3):unwrap().Index.DebugLabel} doesn't match`)))
						print("known", v20, "new", p5)
					else
						warn(debug.traceback((`SetAsync for key={p2}, itemId={ItemConfig.match(p3):unwrap().Index.DebugLabel} is blocked by a restriction`)))
					end

					return false
				else
					if value == nil and v8:get((`{p2}_{p3}___RequireUID`)) then
						warn(debug.traceback((`SetAsync for key={p2}, itemId={ItemConfig.match(p3):unwrap().Index.DebugLabel} is blocked without a UID`)))
						return false
					end

					local formatted2 = `{p2}_{p3}_{value}`
					local _Set, v21 = self:_Set(p2, p3, value, p4, flag3)

					if not _Set then
						return _Set, v21
					end

					if v ~= nil then
						v.trace(function()
							return (`set {ItemConfig.match(p3):unwrap().Index.DebugLabel} "{p2}": {v21} -> {p4}`)
						end)
					end

					local function replicateAsync()
						while v11[formatted2] ~= nil and v11[formatted2] ~= v19 do
							local v22 = v12[formatted2]

							if v22 ~= nil and tick() - v22 > 5 then
								warn((`dead process: {formatted2}`))
								v11[formatted2] = nil
								v12[formatted2] = nil
							end

							RunService.Heartbeat:Wait()
						end

						v12[formatted2] = tick()
						v11[formatted2] = v19
						local success, result = pcall(function()
							local v22 = v9[`{p2}_{p3}_{value or "ALL"}`]

							if v22 then
								for _, v23 in v22:dump() do
									self:_ApplyRule(v23, p4, v21, flag3)
								end
							end

							v14:FireAsync(p2, p3, value, p4, v21, flag3)
							local v23 = v17[p2]

							if v23 then
								v23:FireAsync(p3, value, p4, v21, flag3)
							end

							local v24 = v16[`{p3}_{value}`]

							if v24 then
								v24:FireAsync(p2, p4, v21, flag3)
							end

							local v25 = v15[`{p2}_{p3}_{value}`]

							if v25 then
								v25:FireAsync(p4, v21, flag3)
							end
						end)
						v12[formatted2] = nil
						v11[formatted2] = nil

						if not success then
							warn((`replication failed for {formatted2}: {result}`))
						end
					end

					if flag2 then
						replicateAsync()
					else
						task.spawn(replicateAsync)
					end

					return _Set, v21
				end
			end,
			Release = function(_)
				local v19 = v18
				v18 = {}
				local stageds = {}

				for _, v20 in v19 do
					if v20.current.Value ~= v20.staged.Value then
						table.insert(stageds, v20.staged)
					end
				end

				return stageds
			end,
			Get = function(self, p2: string, p3: number, p4: string?, _)
				return v13[`{p2}_{p3}_{p4}`]
			end
		}
	end
}