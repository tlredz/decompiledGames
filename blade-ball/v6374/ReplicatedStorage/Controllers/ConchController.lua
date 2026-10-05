local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3("./UI/TopBarController")
local v2 = require3(ReplicatedStorage2.Packages.Conch)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Packages.Vide)
local ConchController = {}
ConchController._initializedConch = false

function ConchController:InitConch()
	if self._initializedConch then
		return
	end

	self._initializedConch = true
	require3(ReplicatedStorage2.Shared.ConchCustomTypes)
	v2.initiate_default_lifecycle()
	v2.ui.bind_to(Enum.KeyCode.F2)
	local v5 = v:Create("Conch"):setCaptionHint(Enum.KeyCode.F2):setCaption("Open Conch"):setImage(
		"rbxassetid://9790261539",
		"deselected"
	):setImage(
		"rbxassetid://9790261414",
		"selected"
	):setOrder(-1000)
	v4.root(function()
		v4.effect(function()
			local opened = v2.ui.opened()
			v5:setState(opened and "Selected" or "Deselected")
			v2.ui.focused(opened)
		end)
	end)
	v5.toggled:Connect(v2.ui.opened)
	v3:Invoke("Conch/PlayerAdded")
end

function ConchController:Start()
	if v3:Invoke("Conch/CanUse") then
		self:InitConch()
	end
end

return ConchController