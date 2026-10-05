local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIChoreo = require(ReplicatedStorage:WaitForChild("UIChoreo"))
local POSE = UIChoreo.POSE
UIChoreo.window(script.Parent, {
	Parts = {
		{
			Get = "Header",
			Pose = POSE.Header,
			At = 0.07
		},
		{
			Get = "Close",
			Pose = POSE.Close,
			At = 0.16
		}
	},
	Lists = {
		{
			Get = "Holder",
			At = 0.1,
			Step = 0.05,
			Skip = {
				LastItem = true
			}
		}
	},
	CloseLead = 0.08
})