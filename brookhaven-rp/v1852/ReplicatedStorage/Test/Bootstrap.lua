local Bootstrap = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Test.IntegrationTestTypes)

function Bootstrap.Play(_)
	local ReplicatedFirst = game:GetService("ReplicatedFirst")
	local IntroCameraMediator = require(ReplicatedFirst.IntroCameraMediator)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)

	while not IntroCameraMediator.getSkipIntroHandler() do
		task.wait()
	end

	IntroCameraMediator.getSkipIntroHandler()()
	GamepassController.WaitForGamepasses()

	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
end

return Bootstrap