local EasterEggs = require(game.ReplicatedStorage.Modules.Data.EasterEggs)
local Net = require(game.ReplicatedStorage.Modules.Net)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local v = nil
local v2 = nil
local easterServiceStreaming = nil
local eggModels = game.ReplicatedStorage:WaitForChild("ClientComponents"):WaitForChild("EasterEgg"):WaitForChild("EggModels")
local EasterNetwork = {
	Data = {
		Index = {},
		Rewards = {},
		_Requested = false,
		_RequestFinished = false
	}
}
local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Parent = script
local bindableEvent2 = Instance.new("BindableEvent")
bindableEvent2.Parent = script
local streaming = {}
EasterNetwork.Streaming = streaming
local now = 1
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function _requestData()
	local success, result = pcall(function(...)
		local v4 = v:InvokeServer("GetData")
		local v5 = {}

		for k, count2 in pairs(v4.Index) do
			local isNew

			if EasterNetwork.Data.Index[k] then
				isNew = EasterNetwork.Data.Index[k].IsNew
			end

			v5[k] = {
				Count = count2,
				IsNew = isNew
			}
		end

		EasterNetwork.Data.Index = v5
		EasterNetwork.Data.Rewards = v4.Rewards
	end)

	if not success then
		warn(result)
	end
end

local function processEvent(p: string, p2)
	if p == "ItemChanged" then
		if EasterNetwork.Data.Index[p2.Key] == nil then
			EasterNetwork.Data.Index[p2.Key] = {
				Count = 0
			}
		end

		local count2 = EasterNetwork.Data.Index[p2.Key].Count

		if count2 ~= p2.Value then
			EasterNetwork.Data.Index[p2.Key].Count = p2.Value

			if count2 == 0 and p2.Value == 1 then
				EasterNetwork.Data.Index[p2.Key].IsNew = true
				task.spawn(function()
					if p2.Key ~= "Gacha Egg" then
						local rarity = EasterEggs.List[p2.Key].Rarity
						local model = eggModels:FindFirstChild(p2.Key)
						assert(model and model:IsA("Model"), (`no model found for "{p2.Key}"`))
						local ModelPopup = require(game.ReplicatedStorage.Controllers.UI.ModelPopup)
						local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
						ModelPopup:Open(model, RarityUtil.matchRarity(rarity):unwrap().Value)
					end
				end)
			end

			bindableEvent:Fire(p2.Key, p2.Value, count2)
		end
	elseif p == "RewardsChanged" then
		for _, v4 in pairs(p2.Value) do
			if table.find(EasterNetwork.Data.Rewards, v4) then
				continue
			end

			table.insert(EasterNetwork.Data.Rewards, v4)
			bindableEvent2:Fire(v4)
		end
	elseif p == "RemoveEggUID" then
		if streaming[p2] then
			streaming[p2].Destroy()
		end
	elseif p == "PullNewData" then
		_requestData() -- equivalent call inferred; original call site unknown
	else
		warn("unknown request", p)
	end

	pcall(function(...)
		local Players = game:GetService("Players")
		local eggMenu = Players.LocalPlayer.PlayerGui:FindFirstChild("EggMenu")

		if eggMenu then
			count += 1
			eggMenu:SetAttribute("updateDebug", count)
		end
	end)
end

function EasterNetwork.TryClaimReward(p)
	if GlobalUtil.FFlags.IsUnitTest ~= true then
		return v:InvokeServer("ClaimReward", p)
	end

	local count2 = 0

	for _, v4 in pairs(EasterNetwork.GetData().Index) do
		if v4.Count > 0 then
			count2 += 1
		end
	end

	for i = 1, #EasterEggs.Rewards do
		if not (EasterEggs.Rewards[i].Milestone <= count2) then
			continue
		end

		processEvent("RewardsChanged", {
			Value = { p }
		})
		break
	end
end

function EasterNetwork.IsEventEnabled()
	return workspace:GetAttribute("EasterEventActive") == true
end

function EasterNetwork.IsClaimingEnabled()
	return workspace:GetAttribute("EasterClaimEnabled") == true
end

local v4 = nil

function EasterNetwork.GetData()
	if GlobalUtil.FFlags.IsUnitTest == true then
		if v4 ~= nil then
			return v4
		end

		warn("getting mock data")
		local integer = Random.new():NextInteger(0, EasterEggs.Total)
		local count2 = 0
		local v5 = {}

		for k in pairs(EasterEggs.List) do
			local count3 = count2 == integer and 0 or 1
			v5[k] = {
				Count = count3,
				IsNew = count3 > 0 and math.random() <= 0.5 or nil
			}

			if count2 < integer then
				count2 += 1
			end
		end

		local storageNames = {}

		for i = 1, #EasterEggs.Rewards do
			if not (EasterEggs.Rewards[i].Milestone <= integer and math.random() < 0.3) then
				continue
			end

			for _, reward in pairs(EasterEggs.Rewards) do
				table.insert(storageNames, reward.StorageName)

				if reward.StorageName == EasterEggs.Rewards[i].StorageName then
					break
				end
			end

			break
		end

		v4 = {
			Index = v5,
			Rewards = storageNames,
			_Requested = true,
			_RequestFinished = true
		}
		EasterNetwork.Data = v4
		v4 = v4
		return v4
	else
		if not EasterNetwork.Data._Requested then
			EasterNetwork.Data._Requested = true
			_requestData() -- equivalent call inferred; original call site unknown
			EasterNetwork.Data._RequestFinished = true
		end

		while EasterNetwork.Data._RequestFinished == false do
			task.wait()
		end

		return EasterNetwork.Data
	end
end

function EasterNetwork.OnItemChanged(onEvent)
	return bindableEvent.Event:Connect(onEvent)
end

function EasterNetwork.OnRewardClaimed(onEvent)
	return bindableEvent2.Event:Connect(onEvent)
end

function EasterNetwork.TryCollectEgg(UID: string, additional)
	if tick() - now < 0.5 then
		return
	end

	now = tick()

	if streaming[UID] then
		v2:FireServer("CollectEgg", {
			UID = UID,
			Additional = additional
		})
	else
		print("TryCollectEgg: not streaming uid")
	end
end

function EasterNetwork.TryCollectVirtualEgg(virtualEggName)
	if tick() - now < 0.5 then
		return
	end

	now = tick()
	v2:FireServer("CollectVirtualEgg", {
		VirtualEggName = virtualEggName
	})
end

local flag = false

function EasterNetwork._Start()
	assert(flag == false)
	flag = true
	local count2 = 0

	if GlobalUtil.FFlags.IsUnitTest == false then
		v = Net:RemoteFunction("EasterServiceRF")
		v2 = Net:RemoteEvent("EasterServiceRE", true)
		easterServiceStreaming = game.ReplicatedStorage:FindFirstChild("Remotes"):WaitForChild("EasterServiceStreaming")
		easterServiceStreaming.OnClientEvent:Connect(function(buf, p)
			local v5 = {}

			if typeof(buf) == "buffer" then
				local v6 = 0
				local v7 = buffer.readu16(buf, v6)
				local v8 = v6 + 2

				for _ = 1, v7 do
					local v9 = buffer.readu32(buf, v8)
					local v10 = v8 + 4
					local id = buffer.readu8(buf, v10)
					local v12 = v10 + 1
					local v13 = buffer.readf32(buf, v12)
					local v14 = v12 + 4
					local v15 = buffer.readf32(buf, v14)
					local v16 = v14 + 4
					local v17 = buffer.readf32(buf, v16)
					v8 = v16 + 4
					v5[tostring(v9)] = {
						Id = id,
						Pos = Vector3.new(v13, v15, v17)
					}
				end
			else
				v5 = buf
			end

			local flag2 = false

			for k, v6 in pairs(streaming) do
				if v5[k] then
					continue
				end

				v6.Destroy()
				flag2 = true
			end

			for k, v6 in pairs(v5) do
				local v7 = p[k]

				if not streaming[k] then
					local attachment = Instance.new("Attachment")
					local _, name = EasterEggs.GetFromId(v6.Id)
					local v9 = k
					streaming[k] = {
						Name = name,
						State = {},
						CFrame = CFrame.new(v6.Pos),
						Pointer = attachment,
						Destroy = function()
							streaming[v9] = nil
							pcall(function(...)
								attachment:Destroy()
							end)
						end
					}
					attachment:SetAttribute("UID", k)
					attachment:SetAttribute("CFrame", CFrame.new(v6.Pos))
					attachment:SetAttribute("EggName", name)
					attachment:SetAttribute("SpawnMyEgg", true)
					flag2 = true
				end

				if v7 then
					for k2, v8 in pairs(v7) do
						streaming[k].State[k2] = v8
						streaming[k].Pointer:SetAttribute(k2, v8)
					end

					streaming[k].Pointer:SetAttribute("UpdateState", math.random())
				end

				streaming[k].Pointer:AddTag("EasterEgg26")
				streaming[k].Pointer.Parent = workspace
			end

			pcall(function(...)
				if flag2 then
					local Players = game:GetService("Players")
					local eggMenu = Players.LocalPlayer.PlayerGui:FindFirstChild("EggMenu")

					if eggMenu then
						count2 += 1
						eggMenu:SetAttribute("updateStreamingDebug", count2)
					end
				end
			end)
		end)
		v2.OnClientEvent:Connect(processEvent)
		game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PhysicsEggEvent").OnClientEvent:Connect(function(p: string, position: Vector3)
			local v5 = streaming[p]

			if v5 then
				v5.CFrame = CFrame.new(position)
				v5.Pointer:SetAttribute("CFrame", v5.CFrame)
			end
		end)

		if workspace:HasTag("GIVE_PIRATE_EGG") then
			task.delay(0.2, function()
				EasterNetwork.TryCollectVirtualEgg("Pirate Egg")
			end)
		end
	end
end

return EasterNetwork