local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HideOrShowInPrivateServer"
})
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	if GameUtil.IsPrivateServer() then
		p.Instance.Visible = p.Instance:GetAttribute("Visible")
	else
		p.Instance.Visible = not p.Instance:GetAttribute("Visible")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v