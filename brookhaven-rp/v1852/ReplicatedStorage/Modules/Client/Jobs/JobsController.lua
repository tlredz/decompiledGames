local JobsController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = false
local Signal = require(ReplicatedStorage.Packages.Signal)
JobsController.CurrentJobName = nil
JobsController.OnJobNameChanged = Signal.new()

function JobsController.FrameworkInit()
	local JobsUIController = require(ReplicatedStorage.Modules.Client.Jobs.JobsUIController)
	v = JobsUIController
end

function JobsController.RefreshCurrentJobName(currentJobName: string?)
	JobsController.CurrentJobName = currentJobName
	JobsController.OnJobNameChanged:Fire(currentJobName)
end

function JobsController.FrameworkStart()
	Remotes.connect("JobMainUIOpen", function(p: string)
		v.OpenMainJobUI(p)
		JobsController.RefreshCurrentJobName(p)
	end)
	Remotes.connect("JobMainUIClose", function()
		v.CloseMainJobUI()
		JobsController.RefreshCurrentJobName(nil)
	end)
end

return JobsController