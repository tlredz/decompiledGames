local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "ClickToWearOutfitToggle"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local value = self.Instance:WaitForChild("DecalValue").Value
	local value2 = self.Instance:WaitForChild("DecalValueBack").Value
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "OutfitSetDecal", function(texture)
		value.Texture = texture
		value2.Texture = texture
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v