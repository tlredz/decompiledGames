local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local v = Component.new({
	Tag = "AnimationMimic"
})

local function getAnimator(parent)
	local animator = parent:FindFirstChildOfClass("Animator")

	if animator then
		return animator
	end

	local animator2 = Instance.new("Animator")
	animator2.Parent = parent
	return animator2
end

function v:MimicTrack(instance)
	local animation = instance.Animation

	if not animation or self._tracks[instance] then
		return
	end

	local track = self._animator:LoadAnimation(animation)
	self._tracks[instance] = track
	track.Priority = instance.Priority
	track.Looped = instance.Looped
	track:Play(0, instance.WeightTarget, instance.Speed)
	track.TimePosition = instance.TimePosition
	self._bindTrove:Connect(instance:GetPropertyChangedSignal("Speed"), function()
		track:AdjustSpeed(instance.Speed)
	end)
	self._bindTrove:Connect(instance:GetPropertyChangedSignal("WeightTarget"), function()
		track:AdjustWeight(instance.WeightTarget)
	end)
	self._bindTrove:Connect(instance.Stopped, function()
		track:Stop()
		self._tracks[instance] = nil
	end)
end

function v:Bind(parent)
	self._bindTrove:Clean()

	for k, _track in pairs(self._tracks) do
		_track:Stop(0)
		self._tracks[k] = nil
	end

	if not parent then
		return
	end

	local v2 = parent:FindFirstChildOfClass("Animator")

	if not v2 then
		v2 = Instance.new("Animator")
		v2.Parent = parent
	end

	self._bindTrove:Connect(v2.AnimationPlayed, function(p)
		self:MimicTrack(p)
	end)

	for _, v3 in ipairs(v2:GetPlayingAnimationTracks()) do
		self:MimicTrack(v3)
	end
end

function v:Construct()
	local parent = self.Instance.Parent
	self._trove = Trove.new()
	self._bindTrove = self._trove:Extend()
	local animator = parent:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = parent
	end

	self._animator = animator
	self._tracks = {}
end

function v:Start()
	self:Bind(self.Instance.Value)
	self._trove:Connect(self.Instance.Changed, function()
		self:Bind(self.Instance.Value)
	end)
end

function v:Stop()
	if self._trove then
		self._trove:Destroy()
		self._trove = nil
	end
end

return v