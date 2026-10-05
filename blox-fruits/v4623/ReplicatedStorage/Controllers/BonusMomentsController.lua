local createVector = vector.create
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
require(script.Types)
local bonusMoments = game.ReplicatedStorage:WaitForChild("BonusMoments")
local bonusMomentsRemoteEvent = game.ReplicatedStorage.Remotes:WaitForChild("BonusMomentsRemoteEvent")
local bonusMomentsRemoteFunction = game.ReplicatedStorage.Remotes:WaitForChild("BonusMomentsRemoteFunction")
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)
local v = BuildInfo.IS_PUBLISHED == false
local v2 = {}
local v3 = {}
local v4 = {
	Completed = true,
	SetActive = true
}
local BonusMomentsController = {}
local class = {}
class.__index = class

function class:new(flag: boolean, completions: number)
	local localPlayer = game.Players.LocalPlayer
	local character = localPlayer.Character
	local object = setmetatable({
		MomentData = self,
		_Maid = Maid.new(),
		_MainMaid = Maid.new(),
		Trove = Trove.new(),
		Completed = flag and not self.Repeatable,
		Completions = completions,
		Player = localPlayer,
		Root = character:FindFirstChild("HumanoidRootPart"),
		Human = character:FindFirstChild("Humanoid"),
		Active = false,
		MiscData = {}
	}, class)
	local remoteEvents = self.RemoteEvents

	if not remoteEvents then
		remoteEvents = {}
		self.RemoteEvents = remoteEvents
	end

	assert(remoteEvents, "bad remote events")

	function remoteEvents.Completed(object2, ...)
		object2:Complete(...)
	end

	function remoteEvents:SetActive(...)
		self:SetActive(...)
	end

	if self.OnLoad then
		task.spawn(self.OnLoad, object)
	end

	return object
end

function class:SetActive(active: boolean)
	self.Active = active
	local onActive = self.MomentData.OnActive

	if onActive then
		onActive(self, active)
	end
end

function class:GiveTask(p2)
	return self._Maid:GiveTask(p2)
end

function class:DoCleaning()
	return self._Maid:DoCleaning()
end

function class:Add(p2)
	return self.Trove:Add(p2)
end

function class:Clean()
	return self.Trove:Clean()
end

function class:Complete(flag: boolean, flag2: boolean?, completions: number)
	self.Completed = completions > 0 and not self.MomentData.Repeatable
	self.Completions = completions

	if self.MomentData.OnComplete then
		self.MomentData.OnComplete(self, flag, flag2, completions)
	end

	if flag2 or flag and not self.MomentData.Repeatable then
		self._MainMaid:DoCleaning()

		if flag2 or not self.MomentData.LoadWhenCompleted then
			v3[self.MomentData.DataName] = nil
		end
	end

	self:SetActive(false)

	if flag2 or not self.MomentData.Repeatable then
		self.Trove:Clean()
		self._Maid:DoCleaning()
	end
end

local function fn(folder, vector2: Vector3?)
	local humanoid = folder:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.Name = "NPC"
	end

	local v5 = folder.PrimaryPart.CFrame.Position - createVector(0, 2.385, 0)
	local humanoid2 = folder:FindFirstChildWhichIsA("Humanoid")

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanQuery = false
		part.CastShadow = false
		part.CanCollide = false
		part.CanTouch = false
		local parent = part.Parent

		if humanoid2 then
			if parent:IsA("Accessory") then
				part.Anchored = false
			elseif part.Name == "HumanoidRootPart" then
				part.Anchored = true
			else
				local humanoidRootPart = part.Name == "Head" and parent:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local alignPosition = Instance.new("AlignPosition", part)
					local attachment = Instance.new("Attachment", humanoidRootPart)
					attachment.Position = part.Position - humanoidRootPart.Position
					alignPosition.Attachment0 = Instance.new("Attachment", part)
					alignPosition.Attachment1 = attachment
				end

				part.Anchored = part.Name == "Anchor" or parent.Name == "Anchor"
			end
		elseif folder:GetAttribute("CompositeTextureId") == nil then
			part.Anchored = true
		end
	end

	local NPC = folder:FindFirstChild("NPC")

	if NPC then
		NPC.NameDisplayDistance = 40
		NPC.DisplayDistanceType = "Subject"
		NPC.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		NPC.DisplayName = folder:GetAttribute("DisplayName") or NPC.DisplayName
		NPC.BreakJointsOnDeath = false
		NPC.AutoRotate = false
		NPC.RequiresNeck = false
		NPC.EvaluateStateMachine = false
	end

	folder:SetAttribute("FloorPos", vector2 or v5)
	folder:SetAttribute("FloorNormal", createVector(0, 1, 0))
	folder.Destroying:Once(function()
		folder:SetAttribute("Destroyed", true)
	end)
end

function class:AddNpc(instance, callback, flag: boolean?)
	if not v2[instance.Name] then
		local NPCList = require(game.ReplicatedStorage.NPCManager.NPCList)
		NPCList.legacy(instance.Name, function(_)
			if typeof(callback) == "function" then
				return (callback(self))
			end

			return callback
		end, 1)
		v2[instance.Name] = true
	end

	local clone = instance:Clone()
	clone:SetAttribute("Optimized", true)
	clone.Parent = workspace.NPCs
	fn(clone)

	if not flag then
		self._MainMaid:GiveTask(clone)
	end

	return clone
end

function class:FireServer(...)
	return bonusMomentsRemoteEvent:FireServer(self.MomentData.DataName, ...)
end

function class:InvokeServer(...)
	return bonusMomentsRemoteFunction:InvokeServer(self.MomentData.DataName, ...)
end

function BonusMomentsController.GetLoadedMoments(_)
	return v3
end

function BonusMomentsController.OnStart(_)
	bonusMomentsRemoteEvent.OnClientEvent:Connect(function(dataName: string, p: string, ...)
		if v3[dataName] then
			local momentData = v3[dataName].MomentData

			if momentData.RemoteEvents and momentData.RemoteEvents[p] then
				return momentData.RemoteEvents[p](v3[dataName], ...)
			end
		else
			local v5, v6

			if p == "Loaded" then
				v5, v6 = ...
			else
				v5 = false
				v6 = 0
			end

			local child = bonusMoments:FindFirstChild(dataName)

			if not child then
				warn((`[BonusMoments] no client module named "{dataName}" in {bonusMoments:GetFullName()}`))
				return
			end

			local success, result = pcall(require, child)

			if not success then
				warn((`[BonusMoments] client module "{dataName}" failed to load: {result}`))
				return
			end

			if result then
				result.DataName = dataName
				result.Island = child:GetAttribute("Island")
			end

			if p == "Loaded" then
				v3[dataName] = class.new(result, v5, v6)
				return
			end

			local v7

			if result.RemoteEvents then
				v7 = result.RemoteEvents[p]
			end

			if v7 and not v4[p] then
				return v7(nil, ...)
			end

			if v and v7 then
				warn((`[BonusMoments] ignored "{p}" for unloaded moment "{dataName}"`))
			end
		end
	end)
end

return BonusMomentsController