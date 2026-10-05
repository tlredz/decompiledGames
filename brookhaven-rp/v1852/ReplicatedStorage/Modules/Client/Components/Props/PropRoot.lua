local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropRoot"
})
local Players = game:GetService("Players")
local Remotes = require(ReplicatedStorage.Packages.Remotes)

function v:Construct()
	self._Janitor = Janitor.new()
	local changable = self.Instance:FindFirstChild("Changable")
	self.isChangeable = changable and changable.Value
	self.ownerName = string.sub(self.Instance.Name, 5)
end

function v.Start(_) end

function v.DeleteProp(p)
	Remotes.invokeServerComponent(p.Instance, "DeleteProp")
end

function v.IsOwnedByPlayer(p, p2)
	if p2 then
		return p.ownerName == p2.Name
	end

	return false
end

function v.GetName(p)
	return p.Instance:GetAttribute("id")
end

function v.GetOwnerName(p)
	return p.ownerName
end

function v.GetOwner(p)
	return (Players:FindFirstChild(p.ownerName))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v