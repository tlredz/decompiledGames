local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local Type = require(game.ReplicatedStorage.Packages.Type)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Net

if RunService:IsRunning() then
	Net = require(game.ReplicatedStorage.Modules.Net)
else
	Net = nil
end

local UserReplicationCache = require(script.UserReplicationCache)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
require(script.KEYS)
require(script.Types)
return ServiceLocker(function()
	local v

	if Net then
		v = Net:RemoteFunction("GetAllItemValues")
	else
		v = nil
	end

	local v2

	if Net then
		v2 = Net:RemoteFunction("ItemReplicationServiceRefreshAsync")
	else
		v2 = nil
	end

	local v3

	if Net then
		v3 = Net:RemoteEvent("OnItemValueChanged")
	else
		v3 = nil
	end

	local v4

	if Net then
		v4 = Net:RemoteEvent("OnItemReplicationServiceRefreshed")
	else
		v4 = nil
	end

	local userCache = {}
	local v6 = {}

	local function getReplicationCache(p: number)
		local v7 = userCache[p]

		if v7 and v7:GetIfAlive() then
			return v7
		end

		userCache[p] = nil
		userCache[p] = UserReplicationCache.new(p)
		return userCache[p]
	end

	if RunService:IsServer() and RunService:IsRunning() then
		local v7 = {}

		local function onNewPlayer(p)
			local userId = p.UserId
			local v8 = userCache[userId]

			if not (v8 and v8:GetIfAlive()) then
				userCache[userId] = nil
				userCache[userId] = UserReplicationCache.new(userId)
				v8 = userCache[userId]
			end

			local userId2 = p.UserId

			if v6[userId2] then
				v6[userId2]()
				v6[userId2] = nil
			end

			if v3 then
				v6[userId2] = v8:ConnectOnChanged(function(p2: string, itemId: number, networkedUID: string?, p5, _, flag: boolean)
					if flag then
						return
					end

					v7[p.UserId] = v7[p.UserId] or {}
					table.insert(v7[p.UserId], {
						Key = p2,
						ItemId = itemId,
						NetworkedUID = networkedUID,
						Value = p5
					})
				end)
			end
		end

		local connections = { Players.PlayerAdded:Connect(onNewPlayer), Players.PlayerRemoving:Connect(function(player)
				for k, v8 in userCache do
					if not (k == player.UserId or Players:GetPlayerByUserId(k) == nil) then
						continue
					end

					v8:Destroy()
					userCache[k] = nil

					if not v6[k] then
						continue
					end

					v6[k]()
					v6[k] = nil
				end
			end) }
		task.spawn(function()
			for _, v8 in Players:GetPlayers() do
				local v9 = v8
				task.spawn(function()
					onNewPlayer(v9)
				end)
			end
		end)

		if v then
			v.OnServerInvoke = function(p)
				local userId = p.UserId
				local v8 = userCache[userId]

				if not (v8 and v8:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v8 = userCache[userId]
				end

				return v8:GetItems()
			end
		end

		if v3 then
			local lastTime = tick()
			table.insert(connections, RunService.Heartbeat:Connect(function()
				if not (tick() - lastTime > 0.016666666666666666) then
					return
				end

				lastTime = tick()
				local v8 = v7
				v7 = {}

				for k, v9 in v8 do
					local playerByUserId = Players:GetPlayerByUserId(k)

					if playerByUserId then
						v3:FireClient(playerByUserId, v9)
					end
				end

				table.clear(v8)
			end))
		end

		local v8 = {
			IS_SERVER = true,
			IS_CLIENT = false,
			_Connections = connections,
			_UserCache = userCache,
			KEYS = require(script.KEYS),
			IsInitialized = true,
			GetItems = function(self, p: number, p2)
				local v9 = userCache[p]

				if not (v9 and v9:GetIfAlive()) then
					userCache[p] = nil
					userCache[p] = UserReplicationCache.new(p)
					v9 = userCache[p]
				end

				return (v9:GetItems(p2))
			end,
			GetAllIds = function(self, p: number, p2)
				local v9 = userCache[p]

				if not (v9 and v9:GetIfAlive()) then
					userCache[p] = nil
					userCache[p] = UserReplicationCache.new(p)
					v9 = userCache[p]
				end

				return v9:GetAllIds(p2)
			end,
			BindRule = function(self, p: number, p2, flag: boolean)
				local v9 = userCache[p]

				if not (v9 and v9:GetIfAlive()) then
					userCache[p] = nil
					userCache[p] = UserReplicationCache.new(p)
					v9 = userCache[p]
				end

				v9:BindRule(p2, flag)
			end,
			UnbindRule = function(self, p: number, p2)
				local v9 = userCache[p]

				if not (v9 and v9:GetIfAlive()) then
					userCache[p] = nil
					userCache[p] = UserReplicationCache.new(p)
					v9 = userCache[p]
				end

				v9:UnbindRule(p2)
			end,
			_GetRefreshData = function(self, p, items, p2, value)
				local Global = require(game.ServerStorage.Global)
				local v9 = Global.session[p]

				if v9 then
					for k, item in items do
						local replicateItemId = v9.wrap.replicateItemId
						local v11

						if p2 then
							v11 = p2[k] or nil
						end

						replicateItemId(value or "All", item, v11)
					end
				end

				local result = {}
				local userId = p.UserId
				local v10 = userCache[userId]

				if not (v10 and v10:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v10 = userCache[userId]
				end

				local v11 = value or v10:GetKeys()
				assert(v11, "bad keys")

				for k, item in items do
					local UID

					if p2 then
						UID = p2[k] or nil
					end

					local attributes = {}

					for _, v14 in v11 do
						attributes[v14] = v10:Get(v14, item, UID)
					end

					table.insert(result, {
						ItemId = item,
						UID = UID,
						Attributes = attributes,
						Nulled = {}
					})
				end

				return result, v11
			end,
			RefreshClient = function(self, player, p, p2, p3)
				if v4 then
					v4:FireClient(player, self:_GetRefreshData(player, p, p2, p3))
				end
			end,
			_ReplicateItem = function(self, p, flag: boolean, p2, p3: number, p4: string?, p5, p6, _: boolean?)
				local userId = p.UserId
				local v9 = userCache[userId]

				if not (v9 and v9:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v9 = userCache[userId]
				end

				local v10, v11 = v9:Set(p2, flag, p3, p4, p5, p6, false)
				return v10, v11
			end,
			Push = function(_, player)
				local v9 = {}
				local userId = player.UserId
				local v10 = userCache[userId]

				if not (v10 and v10:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v10 = userCache[userId]
				end

				for _, v11 in v10:Release() do
					local formatted = `{v11.ItemId}_{v11.NetworkedUID}`
					v9[formatted] = v9[formatted] or {
						ItemId = v11.ItemId,
						UID = v11.NetworkedUID,
						Attributes = {},
						Nulled = {}
					}

					if v11.Value == nil then
						table.insert(v9[formatted].Nulled, v11.Key)
					else
						v9[formatted].Attributes[v11.Key] = v11.Value
					end
				end

				local values = TableUtil.values(v9)

				if v4 then
					local success, _ = pcall(function()
						v4:FireClient(player, values)
					end)

					if not success then
						for i = 1, math.ceil(#values / 250) do
							local v11 = (i - 1) * 250 + 1
							local v12 = {}

							for i2 = v11, v11 + 250 - 1 do
								table.insert(v12, values[i2])
							end

							v4:FireClient(player, v12)
						end
					end
				end
			end,
			CommitItem = function(_, p, p2, p3: number, p4: string?, p5, p6)
				local userId = p.UserId
				local v9 = userCache[userId]

				if not (v9 and v9:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v9 = userCache[userId]
				end

				local v10, v11 = v9:Set(p2, true, p3, p4, p5, p6, true)
				return v10, v11
			end,
			ReplicateItem = function(self, p, p2, p3: number, p4: string?, p5, p6)
				return self:_ReplicateItem(p, false, p2, p3, p4, p5, p6, false)
			end,
			ReplicateItemAsync = function(self, p, p2, p3: number, p4: string?, p5, p6)
				return self:_ReplicateItem(p, true, p2, p3, p4, p5, p6, false)
			end,
			ConnectOnChanged = function(self, p, callback)
				local userId = p.UserId
				local v9 = userCache[userId]

				if not (v9 and v9:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v9 = userCache[userId]
				end

				return v9:ConnectOnChanged(callback)
			end,
			ConnectOnKeyChanged = function(self, p, p2, callback)
				if RunService:IsStudio() then
					local userId = p.UserId
					local v9 = userCache[userId]

					if not (v9 and v9:GetIfAlive()) then
						userCache[userId] = nil
						userCache[userId] = UserReplicationCache.new(userId)
						v9 = userCache[userId]
					end

					return v9:ConnectOnKeyChanged(p2, function(...)
						local v10 = { ... }
						debug.profilebegin((`KeyChanged({p2})`))
						callback(v10[1], v10[2], v10[3], v10[4])
						debug.profileend()
					end)
				else
					local userId = p.UserId
					local v9 = userCache[userId]

					if not (v9 and v9:GetIfAlive()) then
						userCache[userId] = nil
						userCache[userId] = UserReplicationCache.new(userId)
						v9 = userCache[userId]
					end

					return v9:ConnectOnKeyChanged(p2, callback)
				end
			end,
			ConnectOnItemChanged = function(self, p, p2: number, p3: string?, callback)
				local userId = p.UserId
				local v9 = userCache[userId]

				if not (v9 and v9:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v9 = userCache[userId]
				end

				return v9:ConnectOnItemChanged(p2, p3, callback)
			end,
			ConnectOnItemKeyChanged = function(self, p, p2, p3: number, p4: string?, callback)
				local userId = p.UserId
				local v9 = userCache[userId]

				if not (v9 and v9:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v9 = userCache[userId]
				end

				return v9:ConnectOnItemKeyChanged(p2, p3, p4, callback)
			end,
			ReadItem = function(_, p, p2, p3: number, p4: string?)
				local userId = p.UserId
				local v9 = userCache[userId]

				if not (v9 and v9:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v9 = userCache[userId]
				end

				return v9:Get(p2, p3, p4)
			end,
			GetIfRestricted = function(self, p, p2: number, p3: number, p4: string)
				local v9 = userCache[p2]

				if not (v9 and v9:GetIfAlive()) then
					userCache[p2] = nil
					userCache[p2] = UserReplicationCache.new(p2)
					v9 = userCache[p2]
				end

				return v9:GetIfRestricted(p, p3, p4)
			end,
			GetIfHasRule = function(self, p, p2, p3: number, p4: number, p5: string)
				local v9 = userCache[p3]

				if not (v9 and v9:GetIfAlive()) then
					userCache[p3] = nil
					userCache[p3] = UserReplicationCache.new(p3)
					v9 = userCache[p3]
				end

				return v9:GetIfHasRule(p, p2, p4, p5)
			end,
			newRestriction = function(p, itemId: number, UID: string?)
				local v9 = {
					Type = "ItemField",
					ItemId = itemId,
					Key = p,
					UID = UID
				}
				table.freeze(v9)
				return v9
			end,
			newUIDLockRestriction = function(p, itemId: number)
				local v9 = {
					Type = "RequireUID",
					ItemId = itemId,
					Key = p
				}
				table.freeze(v9)
				return v9
			end,
			newMirrorRule = function(sourceKey, p2, boundKey, items)
				local v9 = {
					Type = "Mirror",
					SourceKey = sourceKey,
					BoundKey = boundKey,
					Source = {
						ItemId = p2.ItemId,
						NetworkedUID = p2.NetworkedUID
					},
					Bound = {},
					Restrictions = {}
				}

				for _, item in items do
					table.insert(v9.Bound, {
						ItemId = item.ItemId,
						NetworkedUID = item.NetworkedUID
					})
					table.insert(v9.Restrictions, {
						Type = "ItemField",
						ItemId = item.ItemId,
						UID = item.NetworkedUID,
						Key = boundKey
					})
				end

				TableUtil.deepFreeze(v9)
				return v9
			end,
			newComputedRule = function(sourceKey, p2, boundKey, items, callback)
				local v9 = {
					Type = "Compute",
					SourceKey = sourceKey,
					BoundKey = boundKey,
					Callback = callback,
					Source = {
						ItemId = p2.ItemId,
						NetworkedUID = p2.NetworkedUID
					},
					Bound = {},
					Restrictions = {}
				}

				for _, item in items do
					table.insert(v9.Bound, {
						ItemId = item.ItemId,
						NetworkedUID = item.NetworkedUID
					})
					table.insert(v9.Restrictions, {
						Type = "ItemField",
						ItemId = item.ItemId,
						UID = item.NetworkedUID,
						Key = boundKey
					})
				end

				TableUtil.deepFreeze(v9)
				return v9
			end,
			RestrictReplication = function(_, p, p2)
				local userId = p.UserId
				local v9 = userCache[userId]

				if not (v9 and v9:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v9 = userCache[userId]
				end

				v9:Restrict(p2)
			end,
			UnrestrictReplication = function(_, p, p2)
				local userId = p.UserId
				local v9 = userCache[userId]

				if not (v9 and v9:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v9 = userCache[userId]
				end

				v9:Unrestrict(p2)
			end
		}
		table.freeze(v8)

		if v2 then
			local v9 = {}

			v2.OnServerInvoke = function(p, list, list2, list3)
				assert(#list < 50000, "too big")

				if list2 then
					assert(#list2 < 50000, "too big")
				end

				if list3 then
					assert(#list3 < 50000, "too big")
				end

				assert(Type.array(TypeUtil.Types.ItemId())(list))
				assert(Type.optional(Type.array(Type.string))(list2))
				assert(Type.optional(Type.array(Type.string))(list3))
				local v10 = #list * math.max(not list3 and 0 or #list3 or 0, #TableUtil.keys(require(script.KEYS)))

				if (v9[p.UserId] or 0) + v10 > 50000 then
					return {}
				end

				v9[p.UserId] = (v9[p.UserId] or 0) + v10
				task.delay(60, function()
					v9[p.UserId] = (v9[p.UserId] or 0) - v10

					if v9[p.UserId] <= 0 then
						v9[p.UserId] = nil
					end
				end)
				return v8:_GetRefreshData(p, list, list2, list3)
			end
		end

		return v8
	else
		local connections = {}

		if v3 then
			table.insert(connections, v3.OnClientEvent:Connect(function(items)
				local userId = Players.LocalPlayer.UserId
				local v7 = userCache[userId]

				if not (v7 and v7:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v7 = userCache[userId]
				end

				for _, item in items do
					v7:Set(item.Key, false, item.ItemId, item.NetworkedUID, item.Value, nil, false)
				end
			end))
		end

		if v then
			task.spawn(function()
				for _, v7 in v:InvokeServer(), nil, nil do
					local userId = Players.LocalPlayer.UserId
					local v8 = userCache[userId]

					if not (v8 and v8:GetIfAlive()) then
						userCache[userId] = nil
						userCache[userId] = UserReplicationCache.new(userId)
						v8 = userCache[userId]
					end

					v8:Set(v7.Key, false, v7.ItemId, v7.NetworkedUID, v7.Value, nil, false)
				end
			end)
		end

		local function refresh(items, items2)
			debug.profilebegin("Processing Bulk Update")
			local userId = Players.LocalPlayer.UserId
			local v7 = userCache[userId]

			if not (v7 and v7:GetIfAlive()) then
				userCache[userId] = nil
				userCache[userId] = UserReplicationCache.new(userId)
				v7 = userCache[userId]
			end

			if items2 then
				for _, item in items do
					for _, item2 in items2 do
						v7:Set(item2, true, item.ItemId, item.UID, item.Attributes[item2], nil, false)
					end

					for _, v8 in item.Nulled do
						v7:Set(v8, true, item.ItemId, item.UID, nil, nil, false)
					end
				end
			else
				for _, item in items do
					for k, attribute in item.Attributes do
						v7:Set(k, true, item.ItemId, item.UID, attribute, nil, false)
					end

					for _, v8 in item.Nulled do
						v7:Set(v8, true, item.ItemId, item.UID, nil, nil, false)
					end
				end
			end

			debug.profileend()
		end

		if v4 then
			table.insert(connections, v4.OnClientEvent:Connect(refresh))
		end

		return {
			IS_SERVER = false,
			IS_CLIENT = true,
			KEYS = require(script.KEYS),
			IsInitialized = true,
			_UserCache = userCache,
			_Connections = connections,
			ConnectOnKeyChanged = function(self, p, callback)
				local userId = Players.LocalPlayer.UserId
				local v8 = userCache[userId]

				if not (v8 and v8:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v8 = userCache[userId]
				end

				return v8:ConnectOnKeyChanged(p, callback)
			end,
			ConnectOnChanged = function(self, callback)
				local userId = Players.LocalPlayer.UserId
				local v8 = userCache[userId]

				if not (v8 and v8:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v8 = userCache[userId]
				end

				return v8:ConnectOnChanged(callback)
			end,
			ConnectOnItemChanged = function(self, p: number, p2: string?, callback)
				local userId = Players.LocalPlayer.UserId
				local v8 = userCache[userId]

				if not (v8 and v8:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v8 = userCache[userId]
				end

				return v8:ConnectOnItemChanged(p, p2, callback)
			end,
			ConnectOnItemKeyChanged = function(self, p, p2: number, p3: string?, callback)
				local userId = Players.LocalPlayer.UserId
				local v8 = userCache[userId]

				if not (v8 and v8:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v8 = userCache[userId]
				end

				return v8:ConnectOnItemKeyChanged(p, p2, p3, callback)
			end,
			ReadItem = function(_, p, p2: number, p3: string?)
				local userId = Players.LocalPlayer.UserId
				local v8 = userCache[userId]

				if not (v8 and v8:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v8 = userCache[userId]
				end

				return v8:Get(p, p2, p3)
			end,
			GetItems = function(self, p)
				local userId = Players.LocalPlayer.UserId
				local v8 = userCache[userId]

				if not (v8 and v8:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v8 = userCache[userId]
				end

				return v8:GetItems(p)
			end,
			RefreshAsync = function(_, p, p2, p3)
				if v2 then
					refresh(v2:InvokeServer(p, p2, p3))
				end
			end,
			WriteTempItem = function(_, p, p2: number, p3: string?, p4)
				local userId = Players.LocalPlayer.UserId
				local v8 = userCache[userId]

				if not (v8 and v8:GetIfAlive()) then
					userCache[userId] = nil
					userCache[userId] = UserReplicationCache.new(userId)
					v8 = userCache[userId]
				end

				return v8:Set(p, false, p2, p3, p4, nil, false)
			end
		}
	end
end, function(data)
	if data.IS_SERVER then
	end

	for _, _Connection in data._Connections do
		_Connection:Disconnect()
	end

	for k, v in data._UserCache do
		data._UserCache[k] = nil
		v:Destroy()
	end
end)