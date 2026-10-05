local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IntroController = require(ReplicatedStorage.Modules.Client.UI.IntroController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local YoungRoddoController = {}
local v = nil
YoungRoddoController.SuppressInvites = false

function YoungRoddoController.FrameworkInit() end

function YoungRoddoController.TryShow(p: number)
	if YoungRoddoController.SuppressInvites then
		return false
	end

	if p == 0 then
		v = nil
		return false
	end

	if v ~= nil and p <= v then
		return true
	end

	if not IntroController.HasPassedIntro() or #PanelController.GetOpenPanelsByGroup("FamilyInviteBlocking") > 0 then
		return false
	end

	v = p
	PanelController.OpenPanelByContext("MainGUIHandler", "YoungRoddoInvite")
	return true
end

return YoungRoddoController