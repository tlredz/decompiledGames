local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local chargeMeter = ReplicatedStorage:WaitForChild("resources"):WaitForChild("ui"):WaitForChild("WrathOfOlympus"):WaitForChild("Zeus"):WaitForChild("ChargeMeter")
local electrifiedBoost = ReplicatedStorage:WaitForChild("resources"):WaitForChild("vfx"):WaitForChild("ElectrifiedBoost")
local color = Color3.fromRGB(80, 80, 80)
local color2 = Color3.fromRGB(80, 80, 80)
local v = Component.new({
	Tag = "Electrifiable"
})

function v:Construct()
	self.trove = Trove.new()
	self.bolts = {}
	self.barGradients = {}
	self.vfx = nil
end

function v:GetAdornPart()
	local instance = self.Instance

	if instance:IsA("BasePart") then
		return instance
	end

	return instance:FindFirstChild("Hitbox") or instance.PrimaryPart
end

function v:SetupChargeMeter()
	local adornPart = self:GetAdornPart()

	if not adornPart or adornPart:FindFirstChild("ChargeMeter") then
		return
	end

	local clone = self.trove:Clone(chargeMeter)
	clone.Adornee = adornPart
	clone.Parent = adornPart
	local main = clone:FindFirstChild("Main")

	if not main then
		return
	end

	for _, uIListLayout in main:GetChildren() do
		if uIListLayout:IsA("UIListLayout") then
			continue
		end

		table.insert(self.bolts, uIListLayout)
		local bar = uIListLayout:FindFirstChild("Bar")

		if not bar then
			continue
		end

		local uIGradient = bar:FindFirstChildOfClass("UIGradient")

		if uIGradient then
			table.insert(self.barGradients, uIGradient)
		end
	end

	table.sort(self.bolts, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
end

function v:UpdateChargeMeter()
	local charge = self.Instance:GetAttribute("Charge") or 0
	local v2 = math.ceil(charge * #self.bolts)

	for k, image in self.bolts do
		if not image:IsA("ImageLabel") then
			continue
		end

		local imageColor

		if k <= v2 then
			imageColor = color
		else
			imageColor = color2
		end

		image.ImageColor3 = imageColor
	end

	local v3 = 1 - charge

	for _, barGradient in self.barGradients do
		barGradient.Offset = Vector2.new(0, v3)
	end
end

function v:AttachVFX()
	if self.vfx then
		return
	end

	local adornPart = self:GetAdornPart()

	if not adornPart then
		return
	end

	local clone = electrifiedBoost:Clone()
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = clone
	weldConstraint.Part1 = adornPart
	weldConstraint.Parent = clone
	clone.CFrame = adornPart.CFrame
	clone.Anchored = false
	clone.Parent = adornPart.Parent
	local multiplyVFXSize = self.Instance:GetAttribute("MultiplyVFXSize")
	local descendants = clone:QueryDescendants("ParticleEmitter")

	if multiplyVFXSize and multiplyVFXSize ~= 1 then
		for _, descendant in descendants do
			local numberSequenceKeypoints = {}

			for _, keypoint in descendant.Size.Keypoints do
				table.insert(
					numberSequenceKeypoints,
					NumberSequenceKeypoint.new(
						keypoint.Time,
						keypoint.Value * multiplyVFXSize,
						keypoint.Envelope * multiplyVFXSize
					)
				)
			end

			descendant.Size = NumberSequence.new(numberSequenceKeypoints)
		end
	end

	self.vfx = clone
	self.trove:Add(clone)
end

function v:RemoveVFX()
	if not self.vfx then
		return
	end

	self.vfx:Destroy()
	self.vfx = nil
end

function v:Start()
	self:SetupChargeMeter()
	self.trove:Add(self.Instance:GetAttributeChangedSignal("Active"):Connect(function()
		if self.Instance:GetAttribute("Active") then
			self:AttachVFX()
		else
			self:RemoveVFX()
		end
	end))

	if self.Instance:GetAttribute("Active") then
		self:AttachVFX()
	end
end

function v:Stop()
	self:RemoveVFX()
	self.trove:Clean()
	table.clear(self.bolts)
	table.clear(self.barGradients)
end

RunService.PreRender:Connect(function()
	for _, v2 in v:GetAll() do
		v2:UpdateChargeMeter()
	end
end)
return v