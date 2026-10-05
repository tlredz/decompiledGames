local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIController = require(ReplicatedStorage:WaitForChild("UIController"))
local UIQuality = require(ReplicatedStorage:WaitForChild("UIQuality"))
local UIChoreo = require(ReplicatedStorage:WaitForChild("UIChoreo"))
local POSE = UIChoreo.POSE
local parent = script.Parent

local function title(instance)
	for _, label in ipairs(instance:GetChildren()) do
		if label:IsA("TextLabel") and label.Visible and label.Text == "Fusion" then
			return { label }
		end
	end

	return {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyOpenFrom()
	parent:SetAttribute("UIOpenFrom", UIQuality.low() and 1 or UIController.Settings.OpenFrom)
end

applyOpenFrom() -- equivalent call inferred; original call site unknown
parent.Destroying:Once(UIQuality.onChanged(applyOpenFrom))
UIChoreo.window(parent, {
	Parts = {
		{
			Get = "Possible_Fusion",
			Pose = POSE.Panel,
			At = 0,
			Fade = false
		},
		{
			Get = title,
			Pose = POSE.Header,
			At = 0.07,
			Fade = false
		},
		{
			Get = "Close",
			Pose = POSE.Close,
			At = 0.16
		},
		{
			Get = "Fuse",
			Pose = POSE.Rise,
			At = 0.24
		}
	},
	CloseLead = 0.08
})