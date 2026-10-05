local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
local FinishersController = {}

function FinishersController.PlayFinisher(p, p2, p3, p4, ...)
	local v3 = assert(p._finishers[p2], (`Could not find finisher {p2}`))
	local success, result = pcall(v3, p3, p4, ...)

	if not success then
		warn((`Something went wrong while running finisher {p2} - {result}`))
	end

	return success, result
end

function FinishersController:Preview(p: string)
	ProximityPromptService.Enabled = false
	local finisher = v2:Get("Finisher")

	if finisher then
		v2:Open("FinisherShowRoomUI", "Finisher", true)
		finisher.Info.PlayFinisher(p)
	end

	ProximityPromptService.Enabled = true
end

function FinishersController.Init(p)
	local finishers = {}

	for _, moduleScript in script.Finishers:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success = nil
		local result = nil
		local v4 = moduleScript
		task.spawn(function()
			success, result = pcall(require3, v4)
		end)

		if success == nil and result == nil then
			task.spawn(
				error,
				(`Please, don't yield inside of a finisher animation module ({moduleScript:GetFullName()})`)
			)
		elseif success then
			finishers[moduleScript.Name] = result
		else
			task.spawn(error, (`Something went wrong while requiring finisher {moduleScript:GetFullName()} - {result}`))
		end
	end

	p._finishers = finishers
end

function FinishersController:Start()
	v:Connect("PlayFinisher", function(p: string, player, player2, ...)
		local character = player.Character
		local character2 = player2.Character

		if character and character2 then
			self:PlayFinisher(p, character, character2, ...)
		end
	end)
	v:Connect("PreviewFinisher", function(p: string)
		self:Preview(p)
	end)
	v2:Get("Finisher")
end

return FinishersController