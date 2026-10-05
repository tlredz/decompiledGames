local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "LazyLoadModel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.GetGuid(p)
	local instance = p.Instance
	local lazyLoadModelGuid = instance:GetAttribute("lazyLoadModelGuid")

	while lazyLoadModelGuid == nil do
		instance:GetAttributeChangedSignal("lazyLoadModelGuid"):Wait()
		lazyLoadModelGuid = instance:GetAttribute("lazyLoadModelGuid")
	end

	return lazyLoadModelGuid
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v