local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AvatarEditorContext"
})

function v.Open(p)
	p.Instance.Visible = true
end

function v.Close(p)
	p.Instance.Visible = false
end

function v.IsOpen(p)
	return p.Instance.Visible
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v