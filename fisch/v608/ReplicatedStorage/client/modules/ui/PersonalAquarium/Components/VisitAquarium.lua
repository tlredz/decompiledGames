game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers.CutsceneController)
local legacy = ReplicatedStorage.client.legacy
local legacyUiLoader = require(legacy.legacyUiLoader)
require("../Types")
local packages2 = ReplicatedStorage.packages
local Trove = require(packages2.Trove)
require(packages2.Signal)
local remoteFunction = Net:RemoteFunction("PersonalAquarium/JoinUnavailableAquarium")
local _ = legacyUiLoader.PlayerGui.hud.safezone.PersonalAquarium
local anno_localthought = ReplicatedStorage.events.anno_localthought
local VisitAquarium = {}

function VisitAquarium.Start(_, dependencies)
	VisitAquarium.Dependencies = dependencies
	VisitAquarium.Trove = Trove.new()
	VisitAquarium._Updater = dependencies.Shared.HandleButtonFn(
		VisitAquarium.Dependencies.Instance.confirm,
		function() end,
		true
	)
	VisitAquarium.VisitAquariumOpenSignal = dependencies.Signals.VisitAquarium
	VisitAquarium.VisitAquariumOpenSignal:Connect(VisitAquarium._Open)
	dependencies.Shared.HandleButtonFn(dependencies.Instance.deny, VisitAquarium._CloseRequested, false)
end

function VisitAquarium.Opened() end

function VisitAquarium.Closed()
	VisitAquarium.Trove:Clean()
	VisitAquarium.Dependencies.Instance.Visible = false
end

function VisitAquarium._Open(p: string, p2: number)
	VisitAquarium.Trove:Clean()
	VisitAquarium.Dependencies.Instance.Visible = true
	VisitAquarium.Dependencies.Instance.question.Text = `{p} is unavailable in this server, do you still want to go visit?`

	if VisitAquarium._Updater then
		VisitAquarium._Updater(function()
			CutsceneController:Fade(3)
			VisitAquarium.Dependencies.Instance.Visible = false
			VisitAquarium.Dependencies.Signals.ForceClose:Fire()

			if remoteFunction:InvokeServer(p2) then
				anno_localthought:Fire("Success!")
			else
				anno_localthought:Fire("Teleport failed...")
			end
		end)
	end
end

function VisitAquarium._CloseRequested()
	VisitAquarium.Dependencies.Instance.Visible = false
end

return VisitAquarium