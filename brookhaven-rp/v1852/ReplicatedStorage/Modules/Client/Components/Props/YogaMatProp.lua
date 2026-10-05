local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = nil
local v2 = { 118891120710625, 106499378314344, 105380573063936 }
local v3 = {
	{
		[2] = 78682241993016
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function makeAnimation(name: string, p: number)
	local animation = Instance.new("Animation")
	animation.Name = name
	animation.AnimationId = "rbxassetid://" .. tostring(p)
	return animation
end

local function getOrCreateToolReference(parent)
	local toolReference = parent:FindFirstChild("ToolReference")

	if toolReference ~= nil and toolReference:IsA("ObjectValue") then
		return toolReference
	end

	if toolReference ~= nil then
		toolReference:Destroy()
	end

	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "ToolReference"
	objectValue.Parent = parent
	return objectValue
end

local function getSharedUiTemplate()
	if v ~= nil and v.Parent ~= nil then
		return v
	end

	local uiClone = ReplicatedStorage:FindFirstChild("UiClone")

	if uiClone ~= nil then
		local yogaMatSequenceUI = uiClone:FindFirstChild("YogaMatSequenceUI")

		if yogaMatSequenceUI ~= nil and yogaMatSequenceUI:IsA("ScreenGui") then
			v = yogaMatSequenceUI
			return v
		end
	end
end

local function createAndParentUi(instance)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local v4

	if v == nil or v.Parent == nil then
		local uiClone = ReplicatedStorage:FindFirstChild("UiClone")

		if uiClone ~= nil then
			local yogaMatSequenceUI = uiClone:FindFirstChild("YogaMatSequenceUI")

			if not (yogaMatSequenceUI == nil or not yogaMatSequenceUI:IsA("ScreenGui")) then
				v = yogaMatSequenceUI
				v4 = v
			end
		end
	else
		v4 = v
	end

	if playerGui == nil or v4 == nil then
		warn(("YogaMatProp: UI template '%s' ScreenGui not found"):format("YogaMatSequenceUI"))
		return nil
	end

	local clone = v4:Clone()
	local v5 = clone:FindFirstChild("ToolReference")

	if v5 == nil or not v5:IsA("ObjectValue") then
		if v5 ~= nil then
			v5:Destroy()
		end

		v5 = Instance.new("ObjectValue")
		v5.Name = "ToolReference"
		v5.Parent = clone
	end

	v5.Value = instance
	v5:SetAttribute("Component", "YogaMatProp")
	clone.Parent = playerGui
	return clone
end

local v4 = Component.new({
	Tag = "YogaMatProp"
})

function v4:Construct()
	self._Janitor = Janitor.new()
	self._seatedJanitor = self._Janitor:Add(Janitor.new())
	self._cycleJanitor = self._Janitor:Add(Janitor.new())
	self.OnAnimationNumberUpdated = self._Janitor:Add(Signal.new())
	self.currentAnimation = 1
	self._cycleDebounced = false
	self._isSessionActive = false
	self.poseAnimations = {}
	self.transitionAnimations = {}
	self.poseTracks = {}
	self.transitionTracks = {}
	local folder = Instance.new("Folder")
	folder.Name = "YogaMatAnimations"
	folder.Parent = self.Instance
	self._Janitor:Add(folder)
	local animations = {}

	for k, v5 in v2 do
		local animation = makeAnimation("Pose" .. tostring(k), v5) -- equivalent call inferred; original call site unknown
		animation.Parent = folder
		self.poseAnimations[k] = animation
		table.insert(animations, animation)
	end

	for k, v5 in v3 do
		self.transitionAnimations[k] = {}

		for k2, v6 in v5 do
			local animation = makeAnimation(("Transition_%d_%d"):format(k, k2), v6) -- equivalent call inferred; original call site unknown
			animation.Parent = folder
			self.transitionAnimations[k][k2] = animation
			table.insert(animations, animation)
		end
	end

	task.spawn(function()
		local v5 = {}

		for _, v6 in animations do
			if ContentProvider:GetAssetFetchStatus(v6.AnimationId) == Enum.AssetFetchStatus.None then
				table.insert(v5, v6)
			end
		end

		if #v5 > 0 then
			ContentProvider:PreloadAsync(v5)
		end
	end)
	self.Instance:SetAttribute("CurrentAnimation", self.currentAnimation)
end

function v4.GetCurrentAnimation(p)
	return p.currentAnimation
end

function v4:_stopAllTracks(value: number?)
	local v5 = value or 0.1

	for _, poseTrack in self.poseTracks do
		if poseTrack.IsPlaying then
			poseTrack:Stop(v5)
		end
	end

	for _, transitionTrack in self.transitionTracks do
		for _, v6 in transitionTrack do
			if v6.IsPlaying then
				v6:Stop(v5)
			end
		end
	end
end

function v4:CycleNextAnimation()
	if not self._isSessionActive or self._cycleDebounced then
		return
	end

	self._cycleDebounced = true
	task.delay(0.5, function()
		self._cycleDebounced = false
	end)
	self._cycleJanitor:Cleanup()
	local currentAnimation = self.currentAnimation
	local currentAnimation2 = currentAnimation % #self.poseTracks + 1
	local transitionTrack = self.transitionTracks[currentAnimation]
	local v6

	if transitionTrack then
		v6 = transitionTrack[currentAnimation2] or nil
	else
		v6 = nil
	end

	local poseTrack = self.poseTracks[currentAnimation2]

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playTarget(p: number)
		if poseTrack ~= nil and not poseTrack.IsPlaying then
			poseTrack:Play(p)
		end
	end

	if v6 == nil then
		self:_stopAllTracks(1)
		playTarget(1) -- equivalent call inferred; original call site unknown
	else
		self:_stopAllTracks()
		v6:Play(0.1)
		local length = v6.Length
		local v7 = math.min(0.2, (math.max(0, length)))
		local v8 = math.max(0, length - v7)
		local thread = task.delay(v8, function()
			v6:Stop(v7)
			playTarget(v7) -- equivalent call inferred; original call site unknown
		end)
		self._cycleJanitor:Add(function()
			pcall(task.cancel, thread)
		end)
		self._cycleJanitor:Add(v6.Ended:Once(function()
			v6:Stop(v7)
			playTarget(0.1) -- equivalent call inferred; original call site unknown
		end))
	end

	self.currentAnimation = currentAnimation2
	self.Instance:SetAttribute("CurrentAnimation", currentAnimation2)
	self.OnAnimationNumberUpdated:Fire(currentAnimation2)
end

function v4:_beginSession(instance)
	local animator = instance:FindFirstChildOfClass("Animator")

	if animator == nil then
		animator = instance:WaitForChild("Animator", 5)
	end

	if animator == nil then
		warn("YogaMatProp: occupant has no Animator")
		return
	end

	self.poseTracks = {}

	for k, animation in self.poseAnimations do
		local track = animator:LoadAnimation(animation)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Action2
		self.poseTracks[k] = track
		self._seatedJanitor:Add(function()
			track:Stop(0.1)
			track:Destroy()
		end)
	end

	self.transitionTracks = {}

	for k, transitionAnimation in self.transitionAnimations do
		self.transitionTracks[k] = {}

		for k2, animation in transitionAnimation do
			local track = animator:LoadAnimation(animation)
			track.Looped = false
			track.Priority = Enum.AnimationPriority.Action
			self.transitionTracks[k][k2] = track
			self._seatedJanitor:Add(function()
				track:Stop(0.1)
				track:Destroy()
			end)
		end
	end

	self.currentAnimation = 1
	self.Instance:SetAttribute("CurrentAnimation", self.currentAnimation)
	self._isSessionActive = true
	self.OnAnimationNumberUpdated:Fire(self.currentAnimation)
	local poseTrack = self.poseTracks[self.currentAnimation]

	if poseTrack ~= nil then
		poseTrack:Play(0.1)
	end

	local v5 = createAndParentUi(self.Instance)

	if v5 ~= nil then
		self._seatedJanitor:Add(v5)
	end

	self._seatedJanitor:Add(function()
		self._isSessionActive = false
		self.poseTracks = {}
		self.transitionTracks = {}
	end)
end

function v4:_onOccupantChanged(p)
	self._cycleJanitor:Cleanup()
	self._seatedJanitor:Cleanup()
	local occupant = p.Occupant

	if occupant == nil then
		return
	end

	local parent = occupant.Parent

	if not (parent ~= nil and Players:GetPlayerFromCharacter(parent) == Players.LocalPlayer) then
		return
	end

	self:_beginSession(occupant)
end

function v4:Start()
	local seat = self.Instance:WaitForChild("Seat")
	self._Janitor:Add(seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		self:_onOccupantChanged(seat)
	end))
	self:_onOccupantChanged(seat)
end

function v4:Stop()
	self._Janitor:Destroy()
end

return v4