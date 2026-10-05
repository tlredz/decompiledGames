local RideAnimator = {}
RideAnimator.__index = RideAnimator
local v = {
	"Idle",
	"Walk",
	"Gallop",
	"Sprint",
	"Fall"
}

function RideAnimator.new(items)
	local self = setmetatable({
		rigs = {},
		moving = false,
		moveAnim = "Walk",
		airborne = false,
		action = nil
	}, RideAnimator)

	for _, item in items do
		if not (item.animator and item.folder) then
			continue
		end

		local tracksByChildName = {}

		for _, childName in v do
			local animation = item.folder:FindFirstChild(childName)

			if not (animation and animation:IsA("Animation")) then
				continue
			end

			local track = item.animator:LoadAnimation(animation)
			track.Looped = true
			local priority

			if childName == "Idle" then
				priority = Enum.AnimationPriority.Idle
			else
				priority = Enum.AnimationPriority.Action
			end

			track.Priority = priority
			tracksByChildName[childName] = track
		end

		if tracksByChildName.Idle then
			tracksByChildName.Idle:Play()
		end

		table.insert(self.rigs, {
			tracks = tracksByChildName
		})
	end

	return self
end

function RideAnimator:_setAction(action)
	if action == self.action then
		return
	end

	local action2 = self.action
	self.action = action

	for _, rig in self.rigs do
		if action2 and rig.tracks[action2] then
			rig.tracks[action2]:Stop(0.15)
		end

		if action and rig.tracks[action] then
			rig.tracks[action]:Play(0.15)
		end
	end
end

function RideAnimator:_refresh()
	if self.airborne then
		self:_setAction("Fall")
	elseif self.moving then
		self:_setAction(self.moveAnim)
	else
		self:_setAction(nil)
	end
end

function RideAnimator:Update(moving, p)
	self.moving = moving
	self.moveAnim = p or self.moveAnim
	self:_refresh()
end

function RideAnimator:SetFalling(airborne)
	self.airborne = airborne
	self:_refresh()
end

function RideAnimator:Destroy()
	for _, rig in self.rigs do
		for _, track in rig.tracks do
			track:Stop(0.15)
		end
	end

	self.rigs = {}
end

return RideAnimator