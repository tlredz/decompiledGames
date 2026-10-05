local localPlayer = game.Players.LocalPlayer
local Realm = require(game.ReplicatedStorage.Util.Realm)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local v = {}

while not HUD.IsInitialized do
	task.wait()
end

assert(HUD.IsInitialized, "bad hud controller")
local v2 = {
	TeamSelected = false
}

function v2.EnableGuiComponentsOnSpawn()
	local parent = script.Parent

	local function enableComponents()
		parent.Code.Visible = true
		task.wait()
		local hUDButtonBar = parent:WaitForChild("HUDButtonBar")
		local settings = hUDButtonBar:WaitForChild("Settings")
		settings.Visible = true
		task.wait()
		local crewButton = hUDButtonBar:WaitForChild("CrewButton")
		crewButton.Visible = true
		task.wait()
		local alliesButton = hUDButtonBar:WaitForChild("AlliesButton")
		alliesButton.Visible = true
		task.wait()
		local homeButton = hUDButtonBar:WaitForChild("HomeButton")
		homeButton.Visible = true
		task.wait()
		HUD:Open()
		task.spawn(v2.reflectHUDButtonVisibility)
	end

	if game.Players.LocalPlayer.Character then
		enableComponents()
	else
		game.Players.LocalPlayer.CharacterAdded:Once(function()
			if script.Parent:IsDescendantOf(game.Players.LocalPlayer) then
				enableComponents()
			end
		end)
	end
end

function v2.reflectHUDButtonVisibility()
	local parent = script.Parent
	local hUDButtonBar = parent.HUDButtonBar
	local visible = localPlayer.Team == game.Teams.Pirates
	parent.Crew.Visible = visible
	hUDButtonBar.CrewButton.Visible = visible

	if Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
		parent.Crew.Visible = false
		hUDButtonBar.CrewButton.Visible = false
		hUDButtonBar.AlliesButton.Visible = true
	end
end

return (setmetatable(v2, {
	__index = function(p, p2)
		if not v[p2] then
			return
		end

		local v3 = v[p2]()
		rawset(p, p2, v3)
		return v3
	end
}))