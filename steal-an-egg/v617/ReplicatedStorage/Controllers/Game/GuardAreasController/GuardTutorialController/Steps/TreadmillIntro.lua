local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Client.GuardTutorialPresentation)
require(script.Parent.Types.Interface)
local color = Color3.fromRGB(255, 255, 255)
local TreadmillIntro = {}
TreadmillIntro.StepId = "TreadmillIntro"

function TreadmillIntro.IsSatisfied(object)
	return object:HasFinishedTreadmillIntro()
end

function TreadmillIntro.Bind(object, callback)
	local flag = false
	task.delay(7, function()
		if flag then
			return
		end

		object:MarkTreadmillIntroFinished()
		callback()
	end)
	return function()
		flag = true
	end
end

function TreadmillIntro.Present(object, _)
	object:AnnounceTyped("Use your treadmill to become faster!", color)
	return function()
		object:DropEverything()
	end
end

return TreadmillIntro