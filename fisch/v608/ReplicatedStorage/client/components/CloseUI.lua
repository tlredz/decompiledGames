local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local v = Component.new({
	Tag = "CloseUI"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	p.trove:Add(p.Instance.Activated:Connect(function()
		p.Instance.Parent.Visible = false
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v