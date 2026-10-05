local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local UIChoreo = require(ReplicatedStorage:WaitForChild("UIChoreo"))
local juice = BitohiUI.Juice
local POSE = UIChoreo.POSE
local parent = script.Parent
local v = nil
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function endBreathe()
	count += 1

	if v then
		v()
		v = nil
	end
end

UIChoreo.window(parent, {
	Parts = {
		{
			Get = "Rewards",
			Pose = POSE.Panel,
			At = 0,
			Fade = false
		},
		{
			Get = "Segment2",
			Pose = POSE.Panel,
			At = 0.05,
			Fade = false
		},
		{
			Get = "Header",
			Pose = POSE.Header,
			At = 0.07
		},
		{
			Get = "Rewards/*",
			Pose = POSE.Pop,
			At = 0.12,
			Step = 0.035,
			MaxTotal = 0.2,
			Order = "Grid"
		},
		{
			Get = "Segment2/*",
			Pose = POSE.Pop,
			At = 0.18,
			Step = 0.05,
			MaxTotal = 0.16,
			Order = "Grid"
		},
		{
			Get = "Close",
			Pose = POSE.Close,
			At = 0.16
		},
		{
			Get = "Rebirth",
			Pose = POSE.Rise,
			At = 0.24
		},
		{
			Get = "SkipRebirth",
			Pose = POSE.Rise,
			At = 0.3
		}
	},
	CloseLead = 0.08,
	Opened = function(instance)
		endBreathe() -- equivalent call inferred; original call site unknown
		local v2 = count
		task.wait(0.7)
		local rebirth = instance:FindFirstChild("Rebirth")

		if v2 == count and rebirth and rebirth.Visible then
			v = juice.pulse(rebirth, 1.04, nil, "BreatheScale")
		end
	end,
	Closing = endBreathe,
	Hidden = endBreathe
})