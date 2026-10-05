local Maid = require(script.Parent.Utility.Maid)
local Signal = require(script.Parent.Utility.Signal)
local v = {
	[Enum.HumanoidStateType.Running] = true
}
local v2 = {
	[Enum.HumanoidStateType.Jumping] = true,
	[Enum.HumanoidStateType.Freefall] = true
}
local v3 = {
	onFreefall = "onFreeFall"
}
local StateTracker = {}
StateTracker.__index = StateTracker
StateTracker.ClassName = "StateTracker"

function StateTracker.new(controller)
	local object = setmetatable({}, StateTracker)
	object._maid = Maid.new()
	object.Controller = controller
	object.State = Enum.HumanoidStateType.Running
	object.Speed = 0
	object.Jumped = false
	object.JumpTick = os.clock()
	object.Animation = require(controller.Character:WaitForChild("Animate"):WaitForChild("Controller"))
	object.Changed = Signal.new()
	init(object)
	return object
end

function init(data)
	data._maid:Mark(data.Changed)
	data._maid:Mark(data.Changed:Connect(function(p, p2)
		local v4 = "on" .. p.Name
		data.Animation[v3[v4] or v4](p2)
	end))
end

function StateTracker:Update(p, p2, p3)
	local velocity = self.Controller.HRP.Velocity
	local dot = velocity:Dot(p)
	local state2 = self.State
	local speed = self.Speed
	local magnitude = velocity.Magnitude
	local running

	if p2 then
		if self.Jumped and os.clock() - self.JumpTick > 0.1 then
			self.Jumped = false
		end

		magnitude = (velocity - dot * p).Magnitude
		running = Enum.HumanoidStateType.Running
	elseif dot > 0 then
		if self.Jumped then
			running = Enum.HumanoidStateType.Jumping
		else
			running = Enum.HumanoidStateType.Freefall
		end
	else
		if self.Jumped then
			self.Jumped = false
		end

		running = Enum.HumanoidStateType.Freefall
	end

	local speed2 = p3 and magnitude or 0

	if state2 ~= running or v[running] and math.abs(speed2 - speed) > 0.1 then
		self.State = running
		self.Speed = speed2
		self.Changed:Fire(running, speed2)
	end
end

function StateTracker:RequestJump()
	self.Jumped = true
	self.JumpTick = os.clock()
end

function StateTracker:Destroy()
	self._maid:Sweep()
end

return StateTracker