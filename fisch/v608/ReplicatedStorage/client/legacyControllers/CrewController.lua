local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local remoteFunction = Net:RemoteFunction("Crew/GetSnapshot")
local remoteFunction2 = Net:RemoteFunction("Crew/Create")
local remoteFunction3 = Net:RemoteFunction("Crew/Leave")
local remoteFunction4 = Net:RemoteFunction("Crew/SetWhoCanJoin")
local remoteFunction5 = Net:RemoteFunction("Crew/SetEmblem")
local remoteFunction6 = Net:RemoteFunction("Crew/Promote")
local remoteFunction7 = Net:RemoteFunction("Crew/Demote")
local remoteFunction8 = Net:RemoteFunction("Crew/Kick")
local remoteFunction9 = Net:RemoteFunction("Crew/JoinServer")
local remoteFunction10 = Net:RemoteFunction("Crew/Invite")
local remoteFunction11 = Net:RemoteFunction("Crew/RescindInvite")
local remoteFunction12 = Net:RemoteFunction("Crew/AcceptInvite")
local remoteFunction13 = Net:RemoteFunction("Crew/DeclineInvite")
local remoteFunction14 = Net:RemoteFunction("Crew/AcceptRequest")
local remoteFunction15 = Net:RemoteFunction("Crew/DeclineRequest")
local remoteFunction16 = Net:RemoteFunction("Crew/LookupUser")
local remoteFunction17 = Net:RemoteFunction("Crew/GetLevels")
local remoteFunction18 = Net:RemoteFunction("Crew/UpgradeCapacity")
local remoteFunction19 = Net:RemoteFunction("Crew/GetLeaderboard")
local remoteFunction20 = Net:RemoteFunction("Crew/SearchByName")
local remoteFunction21 = Net:RemoteFunction("Crew/RequestJoin")
local remoteFunction22 = Net:RemoteFunction("Crew/SetUIOpen")
local remoteEvent = Net:RemoteEvent("Crew/InvitePush")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local crewInviteNotif = script:WaitForChild("crewInviteNotif")
local v = {}
local CrewController = {
	GetPointer = function()
		return DataController.PlayerDataReplicator:TryIndex({ "Crews" })
	end
}

function CrewController.GetCrewId()
	local pointer = CrewController.GetPointer()
	local crewId = pointer and pointer.CrewId

	if crewId == "" then
		return nil
	end

	return crewId
end

function CrewController.IsInCrew()
	return CrewController.GetCrewId() ~= nil
end

function CrewController.GetPendingInvites()
	local pointer = CrewController.GetPointer()
	return pointer and pointer.PendingInvites or {}
end

function CrewController.OnInvitePush(onOnClientEvent)
	return remoteEvent.OnClientEvent:Connect(onOnClientEvent)
end

function CrewController.Fetch(p: string?)
	local success, result = pcall(function()
		return remoteFunction:InvokeServer(p)
	end)

	if success then
		return result
	end

	return nil
end

function CrewController.SetUIOpen(flag: boolean)
	task.spawn(function()
		pcall(function()
			remoteFunction22:InvokeServer(flag)
		end)
	end)
end

local function invoke(object, ...)
	local v2 = { ... }
	local success, result = pcall(function()
		return object:InvokeServer(table.unpack(v2))
	end)

	if not success then
		return {
			success = false,
			error = "Something went wrong, please try again."
		}
	end

	if typeof(result) == "table" then
		return result
	end

	return {
		success = false,
		error = "Unexpected server response."
	}
end

function CrewController:Create(p2: string?, p3, p4: string?)
	return invoke(remoteFunction2, self, p2, p3, p4)
end

function CrewController.Leave()
	return invoke(remoteFunction3)
end

function CrewController.SetWhoCanJoin(p: string)
	return invoke(remoteFunction4, p)
end

function CrewController.SetEmblem(p: string?, p2)
	return invoke(remoteFunction5, p, p2)
end

function CrewController.Promote(p: number)
	return invoke(remoteFunction6, p)
end

function CrewController.Demote(p: number)
	return invoke(remoteFunction7, p)
end

function CrewController.Kick(p: number)
	return invoke(remoteFunction8, p)
end

function CrewController.JoinMemberServer(p: number)
	return invoke(remoteFunction9, p)
end

function CrewController.UpgradeCapacity()
	return invoke(remoteFunction18)
end

function CrewController.RequestJoin(p: string)
	return invoke(remoteFunction21, p)
end

function CrewController.GetLeaderboard(p: number?)
	local success, result = pcall(function()
		return remoteFunction19:InvokeServer(p)
	end)

	if success and typeof(result) == "table" then
		return result
	end

	return {}
end

function CrewController.SearchByName(p: string)
	local success, result = pcall(function()
		return remoteFunction20:InvokeServer(p)
	end)

	if success and typeof(result) == "table" then
		return result
	end

	return nil
end

function CrewController.Invite(p: number)
	return invoke(remoteFunction10, p)
end

function CrewController.RescindInvite(p: number)
	return invoke(remoteFunction11, p)
end

function CrewController.AcceptInvite(p: string)
	return invoke(remoteFunction12, p)
end

function CrewController.DeclineInvite(p: string)
	return invoke(remoteFunction13, p)
end

function CrewController.AcceptRequest(p: number)
	return invoke(remoteFunction14, p)
end

function CrewController.DeclineRequest(p: number)
	return invoke(remoteFunction15, p)
end

function CrewController.LookupUser(p: string)
	local success, result = pcall(function()
		return remoteFunction16:InvokeServer(p)
	end)

	if not success then
		return {
			success = false,
			error = "Something went wrong, please try again."
		}
	end

	if typeof(result) == "table" then
		return result
	end

	return {
		success = false,
		error = "Unexpected server response."
	}
end

function CrewController.GetLevels(p)
	local success, result = pcall(function()
		return remoteFunction17:InvokeServer(p)
	end)

	if success and typeof(result) == "table" then
		return result
	end

	return {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(uIScale, tweenInfo3, p)
	local tween = TweenService:Create(uIScale, tweenInfo3, p)
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	return tween
end

local function dismissInvite(clone, p: string)
	if v[p] == clone then
		v[p] = nil
	end

	local uIScale = clone:FindFirstChildOfClass("UIScale")

	if uIScale then
		fastTween(uIScale, tweenInfo2, {
			Scale = 0
		}) -- equivalent call inferred; original call site unknown
		task.wait(0.25)
	end

	clone:Destroy()
end

local function showInvite(p: string, p2: string)
	if p == "" or v[p] then
		return
	end

	if CrewController.IsInCrew() then
		task.spawn(function()
			CrewController.DeclineInvite(p)
		end)
		return
	end

	local right = HudController:GetSafeZone():WaitForChild("right")
	local clone = crewInviteNotif:Clone()
	v[p] = clone
	local uIScale = clone:FindFirstChildOfClass("UIScale")

	if uIScale then
		uIScale.Scale = 0
	end

	local notifContent = clone:WaitForChild("notifContent")
	local header = notifContent:FindFirstChild("header")
	local body = notifContent:FindFirstChild("body")
	local accept = notifContent:WaitForChild("Accept")
	local decline = notifContent:WaitForChild("Decline")

	if header and header:IsA("TextLabel") then
		header.Text = "Crew Invite"
	end

	if body and body:IsA("TextLabel") then
		body.Text = `You've been invited to join <b>{p2}</b>.`
	end

	local flag = false
	accept.Activated:Connect(function()
		if flag then
			return
		end

		flag = true

		if CrewController.AcceptInvite(p).success then
			dismissInvite(clone, p)
		else
			flag = false
		end
	end)
	decline.Activated:Connect(function()
		if flag then
			return
		end

		flag = true
		CrewController.DeclineInvite(p)
		dismissInvite(clone, p)
	end)
	clone.Parent = right

	if uIScale then
		local tween = TweenService:Create(uIScale, tweenInfo, {
			Scale = 1
		})
		tween:Play()
		tween.Completed:Once(function()
			tween:Destroy()
		end)
	end
end

function CrewController.Start(_)
	DataController.PlayerDataReplicator:WaitForLoaded()

	for k, v2 in pairs(CrewController.GetPendingInvites()) do
		local v3 = typeof(v2) ~= "table" and "" or v2.CrewName or ""
		task.spawn(showInvite, k, v3)
	end

	remoteEvent.OnClientEvent:Connect(function(p: string, p2: string)
		showInvite(p, p2)
	end)
end

return CrewController