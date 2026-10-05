local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local JobUtil = require(ReplicatedStorage.Modules.Shared.Game.JobUtil)
local localPlayer = Players.LocalPlayer
local cam = nil
local jobMessage = nil

local function TweenJobTitle(p: string)
	local menu = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGUIHandler"):WaitForChild("Menu")
	cam = menu:WaitForChild("Cam")
	jobMessage = menu:WaitForChild("JobMessage")

	if jobMessage.Visible == false then
		local idFromJobName = JobUtil.getIdFromJobName(p)
		jobMessage.Image = "rbxassetid://" .. idFromJobName
		jobMessage.Visible = true
		jobMessage.Position = UDim2.new(-0.4, 0, 0.15, 0)
		jobMessage:TweenPosition(UDim2.new(0.45, 0, 0.15, 0), "InOut", "Sine", 0.3, true)
		wait(1.7)
		jobMessage:TweenPosition(UDim2.new(1.4, 0, 0.15, 0), "InOut", "Sine", 0.5, true)
		wait(1)
		jobMessage.Visible = false
	end
end

local JobsUIController = {}

function JobsUIController.OpenMainJobUI(p: string)
	local menu = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGUIHandler"):WaitForChild("Menu")
	cam = menu:WaitForChild("Cam")
	jobMessage = menu:WaitForChild("JobMessage")
	local idFromJobName = JobUtil.getIdFromJobName(p)
	cam.JobOpen.JobImage.Image = "rbxassetid://" .. idFromJobName

	if JobUtil.isStudentJob(p) then
		cam.JobOpen.Words.Text = "Student"
	else
		cam.JobOpen.Words.Text = "Job"
	end

	cam.JobOpen.Visible = true
	task.spawn(function()
		TweenJobTitle(p)
	end)
end

function JobsUIController.CloseMainJobUI()
	cam = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGUIHandler"):WaitForChild("Menu"):WaitForChild("Cam")
	cam.JobOpen.Visible = false
end

function JobsUIController.FrameworkInit() end

function JobsUIController.FrameworkStart() end

return JobsUIController