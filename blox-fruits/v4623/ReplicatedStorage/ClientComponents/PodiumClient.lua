local Component = require(game.ReplicatedStorage.Modules.Component)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local Net = require(game.ReplicatedStorage.Modules.Net)
local podiumModels = script:WaitForChild("PodiumModels")
local v = {
	Melee = true,
	Sword = true,
	Gun = true,
	Fruit = true
}
local v2 = Component.new({
	Tag = "Podium"
})
local success, result = pcall(function()
	local map = Map.getMap("Sea1")
	local island = Map.getIsland(map, "Colosseum")
	local bonusMoment = Map.getBonusMoment(island, "Legendary Creator Statues")
	return Map.getAddress(bonusMoment)
end)

if not success then
	result = nil
end

local v3 = {}
local v4 = false

local function typeFromName(p)
	local match = p.Name:match("^%a+")

	if match == nil or not v[match] then
		return nil
	end

	return match
end

function v2:hideBase()
	local instance = self.Instance
	local v5 = {}

	if instance:IsA("BasePart") then
		table.insert(v5, instance)
	else
		for _, part in instance:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(v5, part)
			end
		end
	end

	for _, v6 in v5 do
		if self.Hidden[v6] == nil then
			self.Hidden[v6] = v6.Transparency
		end

		v6.Transparency = 1
	end
end

function v2:showBase()
	for k, transparency in self.Hidden do
		if k.Parent ~= nil then
			k.Transparency = transparency
		end
	end

	self.Hidden = {}
end

local function loadTrack(clone)
	local v5 = clone:FindFirstChildWhichIsA("Animator", true)

	if v5 == nil then
		local animationController = clone:FindFirstChildWhichIsA("AnimationController") or clone:FindFirstChildWhichIsA("Humanoid") or Instance.new("AnimationController")

		if animationController.Parent == nil then
			animationController.Parent = clone
		end

		v5 = animationController:FindFirstChildWhichIsA("Animator")

		if v5 == nil then
			v5 = Instance.new("Animator")
			v5.Parent = animationController
		end
	end

	if v5 == nil then
		return nil
	end

	local animation = clone:FindFirstChildWhichIsA("Animation", true)

	if animation == nil then
		return nil
	end

	local success2, result2 = pcall(function()
		return v5:LoadAnimation(animation)
	end)

	if not success2 or typeof(result2) ~= "Instance" then
		return nil
	end

	result2.Looped = false
	result2.Priority = Enum.AnimationPriority.Action
	return result2
end

local function endTimeOf(object)
	local success2, result2 = pcall(function()
		return object:GetTimeOfKeyframe("End")
	end)

	if success2 and typeof(result2) == "number" then
		return result2
	end

	return object.Length
end

local function ensureRootAlias(clone)
	if not (clone:FindFirstChild("AuraRoot") == nil and clone.PrimaryPart ~= nil) then
		return
	end

	local boundingBox, size = clone:GetBoundingBox()
	local part = Instance.new("Part")
	part.Name = "HumanoidRootPart"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = size
	part.CFrame = boundingBox
	local model = Instance.new("Model")
	model.Name = "AuraRoot"
	part.Parent = model
	model.PrimaryPart = part
	model.Parent = clone
end

local function spawnRig(object)
	local instance = object.Instance
	local podiumType = object.PodiumType

	if podiumType == nil or not (instance:IsA("Model") or instance:IsA("BasePart")) then
		return
	end

	local model = podiumModels:FindFirstChild((`{podiumType}1`))

	if model == nil or not model:IsA("Model") then
		return
	end

	if object.Pose ~= nil then
		object.Pose:Destroy()
	end

	local clone = model:Clone()
	clone:PivotTo(instance:GetPivot())
	clone.Parent = workspace
	object.Pose = clone
	ensureRootAlias(clone)
	object.Track = loadTrack(clone)
end

function v2:PlayFrozen()
	if self.EndConn ~= nil then
		self.EndConn:Disconnect()
		self.EndConn = nil
	end

	self.Freed = false
	local track = self.Track

	if track == nil then
		return
	end

	track:Play(0)
	track.TimePosition = 0
	track:AdjustSpeed(0)
end

function v2:Free(flag: boolean?)
	if self.Freed then
		return
	end

	self.Freed = true
	local track = self.Track

	if track == nil then
		return
	end

	if flag then
		track:Play(0)
		local success2, result2 = pcall(function()
			return track:GetTimeOfKeyframe("End")
		end)

		if not success2 or typeof(result2) ~= "number" then
			result2 = track.Length
		end

		track.TimePosition = result2
		track:AdjustSpeed(0)
	else
		local keyframeReachedConnection = nil
		keyframeReachedConnection = track.KeyframeReached:Connect(function(p: string)
			if p == "End" then
				track:AdjustSpeed(0)
				keyframeReachedConnection:Disconnect()

				if self.EndConn == keyframeReachedConnection then
					self.EndConn = nil
				end
			end
		end)
		self.EndConn = keyframeReachedConnection
		track:AdjustSpeed(1)
	end
end

function v2:Nudge(value: number?)
	local pose = self.Pose

	if pose == nil or self.Nudging then
		return
	end

	self.Nudging = true
	local pivot = pose:GetPivot()
	pose:PivotTo(pivot * CFrame.Angles(0, value or 0.13962634015954636, 0))
	task.delay(0.1, function()
		if self.Pose == pose and pose.Parent ~= nil then
			pose:PivotTo(pivot)
		end

		self.Nudging = false
	end)
end

function v2.GetModel(p)
	return p.Pose
end

function v2:Construct()
	local match = self.Instance.Name:match("^%a+")

	if match == nil or not v[match] then
		match = nil
	end

	self.PodiumType = match
	self.Hidden = {}
	self.Pose = nil
	self.Track = nil
	self.Freed = false
	self.EndConn = nil
	self.Nudging = false
end

function v2:Start()
	if self.PodiumType == nil then
		return
	end

	table.insert(v3, self)
	self:hideBase()
	spawnRig(self)

	if v4 then
		self:Free(true)
	else
		self:PlayFrozen()
	end
end

function v2:Stop()
	local index = table.find(v3, self)

	if index ~= nil then
		table.remove(v3, index)
	end

	if self.EndConn ~= nil then
		self.EndConn:Disconnect()
		self.EndConn = nil
	end

	if self.Track ~= nil then
		self.Track:Stop(0)
		self.Track = nil
	end

	if self.Pose ~= nil then
		self.Pose:Destroy()
		self.Pose = nil
	end

	self:showBase()
end

local function refreshAll()
	for _, v5 in v3 do
		if v4 then
			v5:Free(true)
		else
			v5:PlayFrozen()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCompleted(flag: boolean)
	if flag == v4 then
		return
	end

	v4 = flag
	refreshAll()
end

if result == nil then
	return v2
end

local remoteFunction = Net:RemoteFunction("RequestBonusMomentReplication")
local remoteEvent = Net:RemoteEvent("OnBonusMomentReplicatedChange")
task.spawn(function()
	local success2, result2 = pcall(function()
		return remoteFunction:InvokeServer({
			Type = "GetMomentProgress"
		})
	end)
	local data

	if success2 then
		data = result2 and result2.Data
	end

	if typeof(data) == "table" and data[result] == true then
		if v4 == true then
			return
		end

		v4 = true
		refreshAll()
	end
end)
remoteEvent.OnClientEvent:Connect(function(p)
	local data = p and p.Data

	if typeof(data) == "table" then
		setCompleted(data[result] == true) -- equivalent call inferred; original call site unknown
	end
end)
return v2