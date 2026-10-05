local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = require(ReplicatedStorage.Packages.Log)
local Trove = require(ReplicatedStorage.Packages.Trove)
local tutorial = ReplicatedStorage.Assets.UI.Tutorial
local v = Log.new()
local TutorialProp = {}

function TutorialProp:Clone(name: string)
	local v2 = Trove.new()
	local clone = tutorial[self]:Clone()
	clone.Name = name
	v2:Add(clone)
	return clone, v2
end

function TutorialProp.Teardown(p: string, instance)
	local function detach()
		v:AtTrace():Log(p)
		instance:Destroy()
	end

	return detach
end

return TutorialProp