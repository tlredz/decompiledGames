local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local isStudio = RunService:IsStudio()

-- equivalent calls inferred from this helper; original call sites unknown
local function normJob(jobId)
	local v = jobId == nil and "" or tostring(jobId)

	if isStudio and (v == "" or v:gsub("[%-0]", "") == "") then
		return ""
	end

	return v
end

local v = normJob(game.JobId) -- equivalent call inferred; original call site unknown
local PartyWatcher = {
	PartyChanged = simplesignal.new(),
	MemberAdded = simplesignal.new(),
	MemberRemoved = simplesignal.new(),
	MemberMoved = simplesignal.new(),
	SizeChanged = simplesignal.new()
}
local v2 = cleanit.new()
local v3 = nil
local v4 = nil
local v5 = {}
local count = 0

local function size()
	local count2 = 0

	for _ in v5 do
		count2 += 1
	end

	return count2
end

local function localLevel()
	local data = Utility.GetData(Players.LocalPlayer)
	local exp

	if data ~= nil then
		exp = data:FindFirstChild("Exp")
	end

	local goal

	if exp ~= nil then
		goal = exp:FindFirstChild("Goal")
	end

	if goal == nil then
		return 0
	end

	return (math.floor(goal.Value / gameSettings.expPerLevel))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function soloMember()
	return {
		UserId = Players.LocalPlayer.UserId,
		DisplayName = Players.LocalPlayer.DisplayName,
		Location = game.PlaceId,
		JobId = game.JobId,
		IsInHere = true,
		Level = localLevel()
	}
end

function PartyWatcher.GetPartyId()
	return v4
end

function PartyWatcher.GetSize()
	local count2 = 0

	for _ in v5 do
		count2 += 1
	end

	if count2 > 0 then
		return count2
	end

	return 1
end

function PartyWatcher.GetMembers()
	local result = {}

	for _, v6 in v5 do
		table.insert(result, v6)
	end

	if #result == 0 then
		table.insert(result, soloMember())
	end

	return result
end

function PartyWatcher.GetMembersInPlace(p: number)
	local result = {}

	for _, v6 in v5 do
		if v6.Location == p then
			table.insert(result, v6)
		end
	end

	local count2 = 0

	for _ in v5 do
		count2 += 1
	end

	if count2 == 0 and p == game.PlaceId then
		table.insert(result, soloMember())
	end

	return result
end

local function buildMember(instance)
	local location = instance:GetAttribute("Location")
	local jobId2 = instance:GetAttribute("JobId")
	return {
		UserId = tonumber(instance.Name),
		DisplayName = instance:GetAttribute("DisplayName"),
		Location = location,
		JobId = jobId2,
		IsInHere = game.PlaceId == location and normJob(jobId2) == v,
		Level = instance:GetAttribute("Level") or 0
	}
end

local function addMember(object, p)
	local name = tonumber(p.Name)

	if name == nil or v5[name] ~= nil then
		return
	end

	local member = buildMember(p)
	v5[name] = member
	PartyWatcher.MemberAdded:Fire(member)
	object:Connect(p.AttributeChanged, function(p2)
		if v5[name] == nil then
			return
		end

		local member2 = buildMember(p)
		v5[name] = member2

		if p2 == "Location" or p2 == "JobId" then
			PartyWatcher.MemberMoved:Fire(member2)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeMember(name: string)
	local v6 = tonumber(name)
	local v7

	if v6 ~= nil then
		v7 = v5[v6]
	end

	if v7 == nil then
		return
	end

	v5[v6] = nil
	PartyWatcher.MemberRemoved:Fire(v7)
end

local rebind

rebind = function(value: string?)
	count += 1
	local v6 = count

	if v3 ~= nil then
		v3:Destroy()
		v3 = nil
	end

	local v7 = v4 ~= nil
	v4 = nil

	for k, v8 in v5 do
		v5[k] = nil
		PartyWatcher.MemberRemoved:Fire(v8)
	end

	if value == nil or value == "" then
		if v7 then
			PartyWatcher.PartyChanged:Fire(nil)
		end

		local v8 = soloMember() -- equivalent call inferred; original call site unknown
		v5[v8.UserId] = v8
		PartyWatcher.MemberAdded:Fire(v8)
		PartyWatcher.SizeChanged:Fire(1)
	else
		local parties = ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Parties")
		local v8 = parties:FindFirstChild(value) or parties:WaitForChild(value, 10)

		if not (v6 == count and v8 ~= nil) then
			return
		end

		local v9 = cleanit.new()
		v3 = v9
		v4 = value
		PartyWatcher.PartyChanged:Fire(value)
		v9:Connect(v8.ChildAdded, function(p)
			addMember(v9, p)
			local sizeChanged = PartyWatcher.SizeChanged
			local count2 = 0

			for _ in v5 do
				count2 += 1
			end

			sizeChanged:Fire(count2)
		end)
		v9:Connect(v8.ChildRemoved, function(p)
			removeMember(p.Name) -- equivalent call inferred; original call site unknown
			local sizeChanged = PartyWatcher.SizeChanged
			local count2 = 0

			for _ in v5 do
				count2 += 1
			end

			sizeChanged:Fire(count2)
		end)
		v9:Connect(v8.Destroying, function()
			if v6 ~= count then
				return
			end

			task.defer(rebind, value)
		end)

		for _, child in v8:GetChildren() do
			addMember(v9, child)
		end

		local sizeChanged = PartyWatcher.SizeChanged
		local count2 = 0

		for _ in v5 do
			count2 += 1
		end

		sizeChanged:Fire(count2)
	end
end

function PartyWatcher.WatchPlace(p: number)
	local maid = cleanit.new()
	local v6 = {}
	local total = 0

	for _, v7 in v5 do
		if v7.Location ~= p then
			continue
		end

		v6[v7.UserId] = v7
		total += 1
	end

	local flag = false
	local v7 = {
		Added = maid:Add(simplesignal.new()),
		Removed = maid:Add(simplesignal.new()),
		CountChanged = maid:Add(simplesignal.new()),
		Get = function()
			local result = {}

			for _, v8 in v6 do
				table.insert(result, v8)
			end

			return result
		end,
		Destroy = function()
			if flag then
				return
			end

			flag = true
			maid:Destroy()
		end
	}

	local function setIn(p2, flag2: boolean)
		local v8 = v6[p2.UserId] ~= nil
		local v9 = v6
		local userId = p2.UserId
		local v10

		if flag2 then
			v10 = p2
		end

		v9[userId] = v10

		if v8 == flag2 then
			return
		end

		total += flag2 and 1 or -1

		if flag2 then
			v7.Added:Fire(p2)
		else
			v7.Removed:Fire(p2)
		end

		v7.CountChanged:Fire(total)
	end

	local function onMember(p2)
		setIn(p2, p2.Location == p)
	end

	maid:Add(PartyWatcher.MemberAdded:Connect(onMember))
	maid:Add(PartyWatcher.MemberMoved:Connect(onMember))
	maid:Add(PartyWatcher.MemberRemoved:Connect(function(p2)
		local v8 = v6[p2.UserId] ~= nil
		v6[p2.UserId] = nil

		if v8 == false then
			return
		end

		total += -1
		v7.Removed:Fire(p2)
		v7.CountChanged:Fire(total)
	end))
	return v7
end

v5[Players.LocalPlayer.UserId] = soloMember()
task.spawn(function()
	local _, v6 = Utility.GetData(Players.LocalPlayer, true)
	local partyId = v6:WaitForChild("partyInfo"):WaitForChild("partyId")
	v2:Connect(partyId.Changed, function(p)
		task.spawn(rebind, p)
	end)
	rebind(partyId.Value)
end)
return PartyWatcher