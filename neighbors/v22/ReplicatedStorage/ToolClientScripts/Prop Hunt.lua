local PropHunt = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
require(ReplicatedStorage.Modules.Tool)
local _ = Players.LocalPlayer

function PropHunt:GetClosestProps()
	local v = {}

	for _, object in CollectionService:GetTagged("Props") do
		if object:IsDescendantOf(workspace) then
			v[#v + 1] = {
				Object = object,
				Distance = self.Player:DistanceFromCharacter(object.BottomRoot.Position)
			}
		end
	end

	table.sort(v, function(a, b)
		return a.Distance < b.Distance
	end)
	return v[1].Object, v[2].Object, v[3].Object
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HumanoidCanSit(instance, p)
	instance.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, p)
end

function PropHunt.Initialize(_) end

function PropHunt.Activated(_) end

function PropHunt:Equipped()
	if self.GUI then
		self.GUI:Destroy()
		self.GUI = nil
	end

	for _, v in CollectionService:GetTagged("Props") do
		if v:FindFirstChild("Prompt", true) then
			v:FindFirstChild("Prompt", true):Destroy()
		end

		local clone = script:WaitForChild("Prompt"):Clone()
		clone.Enabled = false
		clone.Parent = v.PrimaryPart
		local v2 = v
		clone.Triggered:Connect(function(player)
			HumanoidCanSit(self, false) -- equivalent call inferred; original call site unknown
			self:FireEvent("Morph", v2, v2:GetAttribute("Prop"))
		end)
	end

	self.GUI = script:WaitForChild("TransformGui"):Clone()
	self.GUI.Parent = self.Player.PlayerGui
	self.GUI.Reset.MouseButton1Click:Connect(function()
		self:FireEvent("Morph")
		HumanoidCanSit(self, true) -- equivalent call inferred; original call site unknown
	end)
	local v = {}
	do local _values = table.pack(self:GetClosestProps()); for _k = 1, _values.n do v[_k] = _values[_k] end end
	local RunService = game:GetService("RunService")
	self.Connection = RunService.PostSimulation:Connect(function()
		local v2 = { self:GetClosestProps() }

		for _, child in self.Tool.Highlights:GetChildren() do
			if table.find(v2, child.Adornee) then
				continue
			end

			local prompt = child.Adornee:FindFirstChild("Prompt", true)
			child:Destroy()

			if prompt then
				prompt.Enabled = false
			end
		end

		v = v2
		self:SetInteractions(true)
	end)
end

function PropHunt:Unequipped()
	self:Canceled()
end

function PropHunt:SetInteractions(flag: boolean)
	local childrenByAdornee = {}

	for _, child in self.Tool.Highlights:GetChildren() do
		childrenByAdornee[child.Adornee] = child
	end

	if flag then
		local v = { self:GetClosestProps() }

		for k, v2 in v do
			if childrenByAdornee[v2] then
				continue
			end

			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillColor = Color3.fromRGB(237, 255, 42)
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineTransparency = 0
			highlight.Name = "TransformHighlight"
			highlight.Adornee = v[k]
			highlight.Enabled = true
			highlight.Parent = self.Tool.Highlights
			local prompt = v2:FindFirstChild("Prompt", true)

			if prompt then
				prompt.Enabled = true
			end
		end
	else
		for k, v in childrenByAdornee do
			v:Destroy()
			local prompt = k:FindFirstChild("Prompt", true)

			if prompt then
				prompt.Enabled = false
			end
		end
	end
end

function PropHunt:Canceled()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	self:SetInteractions(false)

	for _, v in CollectionService:GetTagged("Props") do
		if not v:IsDescendantOf(workspace) then
			continue
		end

		local prompt = v:FindFirstChild("Prompt", true)

		if prompt and prompt:IsA("ProximityPrompt") then
			prompt.Enabled = false
		end
	end

	if self.GUI and not self.Character:GetAttribute("PropMorphed") then
		self.GUI:Destroy()
		self.GUI = nil
		self:FireEvent("Morph")
		HumanoidCanSit(self, true) -- equivalent call inferred; original call site unknown
	else
		self:FireEvent("Morph")
		HumanoidCanSit(self, true) -- equivalent call inferred; original call site unknown

		if self.GUI then
			self.GUI:Destroy()
			self.GUI = nil
		end
	end
end

function PropHunt:Destroyed()
	return self:Canceled()
end

return PropHunt