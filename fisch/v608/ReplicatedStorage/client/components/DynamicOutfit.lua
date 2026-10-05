local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local v = Component.new({
	Tag = "DynamicOutfit"
})

function v:Construct()
	self.trove = Trove.new()
end

function v:UpdateObject(instance, p2: string)
	if instance:GetAttribute("VisibleOutfit") then
		instance.LocalTransparencyModifier = instance:GetAttribute("VisibleOutfit") == p2 and 0 or 1
	elseif instance:IsA("Shirt") then
		instance.ShirtTemplate = instance:GetAttribute((`Texture_{p2}`)) or instance.ShirtTemplate
	elseif instance:IsA("Pants") then
		instance.PantsTemplate = instance:GetAttribute((`Texture_{p2}`)) or instance.PantsTemplate
	elseif instance:IsA("ProximityPrompt") then
		instance.ObjectText = self.Instance:GetAttribute((`DisplayName_{p2}`)) or instance.ObjectText
	elseif instance:IsA("ValueBase") then
		instance.Value = instance:GetAttribute((`Value_{p2}`)) or instance.Value
	end
end

function v:Update()
	local currentOutfit = self.Instance:GetAttribute("CurrentOutfit")

	for _, descendant in self.Instance:GetDescendants() do
		self:UpdateObject(descendant, currentOutfit)
	end
end

function v:Start()
	self:Update()
	self.trove:Add(self.Instance:GetAttributeChangedSignal("CurrentOutfit"):Connect(function()
		self:Update()
	end))
	self.trove:Add(self.Instance.DescendantAdded:Connect(function(descendant)
		self:UpdateObject(descendant, self.Instance:GetAttribute("CurrentOutfit"))
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

return v