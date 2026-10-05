local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local localPlayer = Players.LocalPlayer
local v = {
	"Ashen Fortune",
	"Chilled",
	"Wrath",
	"Prismize"
}
local v2 = Component.new({
	Tag = "ObsidianRiddleText",
	Ancestors = { workspace }
})

local function getMutation(instance)
	local mutation = instance:GetAttribute("Mutation")

	if typeof(mutation) == "string" and mutation ~= "" then
		return mutation
	end

	local parent = instance.Parent

	while parent and parent ~= workspace do
		if table.find(v, parent.Name) then
			return parent.Name
		else
			parent = parent.Parent
		end
	end

	return nil
end

local function getIconMutation(instance)
	local mutation = instance:GetAttribute("Mutation")

	if typeof(mutation) == "string" and mutation ~= "" then
		return mutation
	end

	return instance.Name
end

local function getGemColor(part)
	if not part:IsA("BasePart") then
		return nil
	end

	local glowColor = part:GetAttribute("GlowColor")

	if typeof(glowColor) == "Color3" then
		return glowColor
	end

	return part.Color
end

function v2:Construct()
	self.trove = Trove.new()
	self.mutation = getMutation(self.Instance)
	self.baseColor = nil
	self.litColor = nil
	self.lit = nil

	if self.Instance:IsA("TextLabel") then
		self.baseColor = self.Instance.TextColor3
	end
end

function v2:_findColor()
	for _, part in CollectionService:GetTagged("ObsidianGateIcon") do
		if not part:IsDescendantOf(workspace) then
			continue
		end

		local mutation = part:GetAttribute("Mutation")

		if typeof(mutation) ~= "string" or mutation == "" then
			mutation = part.Name
		end

		if mutation ~= self.mutation then
			continue
		end

		if not part:IsA("BasePart") then
			return nil
		end

		local glowColor = part:GetAttribute("GlowColor")

		if typeof(glowColor) == "Color3" then
			return glowColor
		end

		return part.Color
	end

	return nil
end

function v2:_apply(flag: boolean)
	local instance = self.Instance
	local lit

	if self.litColor == nil then
		lit = false
	else
		lit = localPlayer:GetAttribute("ObsidianRiddle") == self.mutation
	end

	if lit == self.lit then
		return
	end

	self.lit = lit
	local litColor

	if lit then
		litColor = self.litColor
	else
		litColor = self.baseColor
	end

	if flag then
		instance.TextColor3 = litColor
		return
	end

	local tween = TweenService:Create(instance, TweenInfo.new(0.6), {
		TextColor3 = litColor
	})
	self.trove:Add(tween)
	tween:Play()
end

function v2:Start()
	if not (self.baseColor and self.mutation) then
		return
	end

	self.litColor = self:_findColor()
	self:_apply(true)
	self.trove:Add(localPlayer:GetAttributeChangedSignal("ObsidianRiddle"):Connect(function()
		self:_apply(false)
	end))

	if self.litColor then
		return
	end

	self.trove:Add(CollectionService:GetInstanceAddedSignal("ObsidianGateIcon"):Connect(function(part)
		if not self.litColor then
			local mutation = part:GetAttribute("Mutation")

			if typeof(mutation) ~= "string" or mutation == "" then
				mutation = part.Name
			end

			if mutation == self.mutation then
				local v3 = self
				local glowColor

				if part:IsA("BasePart") then
					glowColor = part:GetAttribute("GlowColor")

					if typeof(glowColor) ~= "Color3" then
						glowColor = part.Color
					end
				end

				v3.litColor = glowColor
				self:_apply(true)
			end
		end
	end))
end

function v2.Stop(p)
	p.trove:Destroy()
end

return v2