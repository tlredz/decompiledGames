local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HideAllDescendentsIfNotUSA"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	for _, descendant in p.Instance:GetDescendants() do
		if descendant:IsA("ClickDetector") and descendant.MaxActivationDistance > 0 then
			descendant:AddTag("HideIfNotUSA")
		end

		if not (descendant:IsA("BasePart") or descendant:IsA("Texture") or descendant:IsA("MeshPart") or descendant:IsA("Decal") or descendant:IsA("ImageLabel") or descendant:IsA("ImageButton")) then
			continue
		end

		if descendant.Transparency ~= 0 then
			continue
		end

		descendant:AddTag("HideIfNotUSA")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v