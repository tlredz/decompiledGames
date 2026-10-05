local SubclassController = {}
local v = {}
local subclassNetwork = nil
local data = nil
local v2 = nil
local v3 = nil
local v4 = {
	UpdateStats = function(p)
		local subclassData = SubclassController:GetSubclassData()

		if not subclassData then
			return
		end

		local v5 = subclassData.Purchased[p.Name]

		if not v5 then
			return false, "Don't have that subclass"
		end

		local v6 = {}

		for k, v7 in pairs(p) do
			if not (v5[k] and v5[k] ~= v7) then
				continue
			end

			v6[k] = v7
			v5[k] = v7
		end

		if not next(v6) then
			return false, "No updates"
		end

		v.UpdateStats:Fire(p, v6)
		return true, p
	end,
	Purchased = function(p)
		local subclassData = SubclassController:GetSubclassData()

		if not subclassData then
			return
		end

		if subclassData.Purchased[p.Name] then
			return false, "Already purchased"
		end

		subclassData.Purchased[p.Name] = p.Subclass
		v.Purchased:Fire(p)
		return true, p.Subclass
	end,
	Upgrade = function(data2)
		local subclassData = SubclassController:GetSubclassData()

		if not subclassData then
			return
		end

		local v5 = subclassData.Purchased[data2.Name]

		if not v5 then
			return false, "Don't have that subclass"
		end

		v5.Passives[data2.Index] = data2.Upgrade
		v.Upgrade:Fire(data2)
		return true, data2.Upgrade
	end,
	Equipped = function(p)
		local subclassData = SubclassController:GetSubclassData()

		if not subclassData then
			return
		end

		local equipped = subclassData.Equipped
		subclassData.Equipped = p.Name

		if equipped == p.Name then
			return false, "Already equipped"
		end

		v.Equipped:Fire(equipped)
		return true, p.Name
	end
}

function SubclassController:Connect(p, p2)
	while not v[p] do
		task.wait()
	end

	return v[p]:Connect(p2)
end

function SubclassController.GetRawData(_)
	if not data then
		local Subclasses = require(game.ReplicatedStorage.Modules.Data.Subclasses)
		data = Subclasses.Data
	end

	return data
end

local now = 1
local flag = false

function SubclassController.GetUnlockedSubclasses(_)
	if os.time() - now < 2 and not v3 or flag or not subclassNetwork then
		return v3
	end

	now = os.time()
	flag = true
	v3 = subclassNetwork.GetUnlockedClasses:InvokeServer()
	flag = false
	return v3
end

function SubclassController:GetSubclassData()
	if not v2 and subclassNetwork then
		v2 = subclassNetwork.GetPlayerData:InvokeServer()
	end

	return v2
end

local flag2 = false

function SubclassController.UseSubclass(_, p)
	if flag2 then
		return false
	end

	flag2 = true
	local v5 = subclassNetwork.UseSubclass:InvokeServer(p)
	flag2 = false
	return v5
end

function SubclassController.OnStart(_)
	for k in v4 do
		local v5 = v
		local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
		v5[k] = Signal.new()
	end

	subclassNetwork = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SubclassNetwork")
	subclassNetwork.Update.OnClientEvent:Connect(function(p)
		assert(v4[p.Context], "Update type not supported")
		local _, _ = v4[p.Context](p.Data)
	end)
end

return SubclassController