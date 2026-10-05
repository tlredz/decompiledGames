local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local RemoteType = require(ReplicatedStorage.Modules.Shared.FormModules.RemoteType)
local playerGui = game.Players.LocalPlayer.PlayerGui
local mainGUIHandler = nil
local formGui = nil
local toggleForm = nil
local formModules = nil
local v = nil
local FormController = {
	FormShown = Signal.new()
}

function FormController.ToggleForm(_, p)
	if not toggleForm then
		warn(debug.traceback("Waiting for ToggleForm instance to exist"))
	elseif toggleForm:Invoke(p or v.FormId) then
		FormController.FormShown:Fire()
	end
end

function FormController.ExitForm(_)
	toggleForm:Invoke()
end

function FormController.FrameworkStart()
	if game.GameId ~= 7732870260 and not RunService:IsStudio() then
		return
	end

	mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
	formGui = playerGui:WaitForChild("FormGui", 10)

	if formGui == nil then
		return
	end

	toggleForm = formGui:WaitForChild("ToggleForm")
	formModules = ReplicatedStorage.Modules.Shared:WaitForChild("FormModules")
	local Config = require(formModules:WaitForChild("Config"))
	v = Config
	local surveyButton = mainGUIHandler:WaitForChild("SurveyButton")

	if surveyButton then
		surveyButton.Parent = mainGUIHandler
		surveyButton.Visible = false
		local v2 = {
			formId = v.FormId
		}
		local _, v3 = Remotes.invokeServer("FormRemote", RemoteType.FetchFormData, v2)

		if v3 then
			surveyButton.Visible = true
		else
			warn("No form data")
			return
		end
	end

	FormController._maid = Janitor.new()
end

return FormController