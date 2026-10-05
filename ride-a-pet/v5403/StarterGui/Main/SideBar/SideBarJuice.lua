local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIChoreo = require(ReplicatedStorage:WaitForChild("UIChoreo"))
local POSE = UIChoreo.POSE
local parent = script.Parent
local parent2 = parent.Parent

local function drive(instance, p)
	local v = UIChoreo.new(instance, p)
	instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if instance.Visible then
			v:Enter(true)
		else
			v:Reset()
		end
	end)
	instance:GetAttributeChangedSignal("Open"):Connect(function()
		if instance:GetAttribute("Open") ~= true and instance.Visible then
			v:Leave()
		end
	end)
end

local v = {
	Parts = {
		{
			Get = "Header",
			Pose = POSE.Header,
			At = 0.08
		},
		{
			Get = "PlaceBest",
			Pose = POSE.Pop,
			At = 0.16
		},
		{
			Get = "GrowAll",
			Pose = POSE.Pop,
			At = 0.16
		}
	},
	Lists = {
		{
			Get = "Holder",
			At = 0.1,
			Step = 0.04
		}
	}
}

for _, childName in ipairs({ "PetsTracker", "PlotEggsTracker", "BasketTracker" }) do
	local child = parent2:FindFirstChild(childName)

	if child then
		drive(child, v)
	end
end

drive(parent, {
	Parts = {
		{
			Get = "Egg",
			Pose = POSE.Pop,
			At = 0.06
		},
		{
			Get = "Pets",
			Pose = POSE.Pop,
			At = 0.12
		}
	}
})