local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local localPlayer = Players.LocalPlayer
local Archives = {}
local v = {}

local function split(value)
	if typeof(value) == "string" and value ~= "" then
		return string.split(value, ",")
	end

	return {}
end

local function difference(last, items)
	local v2 = {}

	for _, item in last do
		v2[item] = true
	end

	local result = {}

	for _, item in items do
		if not v2[item] then
			table.insert(result, item)
		end
	end

	return result
end

local function currentList(childName: string)
	local _, v2 = Utility.GetData(localPlayer)
	local archives

	if v2 ~= nil then
		archives = v2:FindFirstChild("Archives")
	end

	local stringValue

	if archives ~= nil then
		stringValue = archives:FindFirstChild(childName)
	end

	return split((stringValue == nil or not stringValue:IsA("StringValue")) and "" or stringValue.Value)
end

local flag = false
local v2 = simplesignal.new()
task.spawn(function()
	Utility.GetData(localPlayer, true)

	for k, v3 in v do
		v3.Last = currentList(k)
		v3.Seeding = false
	end

	flag = true
	v2:Fire()
end)

local function watchOf(p: string)
	local v3 = v[p]

	if v3 ~= nil then
		return v3
	end

	local v4 = DataValue.new(`Archives/{p}`, "", "Account")
	local signal = simplesignal.new()
	local v6 = {
		Value = v4,
		Signal = signal,
		Last = not flag and {} or currentList(p),
		Seeding = not flag
	}
	v[p] = v6
	v4.Changed:Connect(function(value)
		local last = (typeof(value) ~= "string" or value == "") and {} or string.split(value, ",")

		if v6.Seeding then
			v6.Last = last
			return
		end

		local v8 = difference(v6.Last, last)
		v6.Last = last

		if #v8 == 0 then
			return
		end

		signal:Fire(v8, last)
	end)
	return v6
end

function Archives.WaitLoaded()
	if flag then
		return
	end

	v2:Wait()
end

function Archives:Connect(onSignal)
	return watchOf(self).Signal:Connect(onSignal)
end

function Archives.IsUnlocked(p: string, p2: string)
	return table.find(watchOf(p).Last, p2) ~= nil
end

function Archives.Get(p: string)
	return table.clone(watchOf(p).Last)
end

return Archives