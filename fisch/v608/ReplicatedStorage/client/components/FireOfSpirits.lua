local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages:WaitForChild("Trove"))
local Component = require(packages:WaitForChild("Component"))
local Net = require(packages:WaitForChild("Net"))
local fx = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("fx"))
local remoteEvent = Net:RemoteEvent("FireOfSpirits/Sacrificed")
local fireball_cast = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("scylla"):WaitForChild("fireball_cast")
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(143, 216, 255)
local color2 = Color3.fromRGB(225, 245, 255)
local v = Component.new({
	Tag = "FireOfSpirits"
})

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function scaleSequence(sequence, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in sequence.Keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope * p)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function v:ApplySize(p2: number)
	local v2 = p2 * 0.8 + 0.2

	for _, flame in self.flames do
		if flame.part then
			TweenService:Create(flame.part, tweenInfo, {
				Size = flame.baseSize * v2
			}):Play()
		end

		if flame.light then
			TweenService:Create(flame.light, tweenInfo, {
				Brightness = p2 * 2.5 + 0.5,
				Range = p2 * 9 + 6
			}):Play()
		end

		if flame.fire then
			flame.fire.Size = p2 * 8 + 4
			flame.fire.Heat = p2 * 8 + 6
		end

		for _, emitter in flame.emitters do
			emitter.Rate = flame.baseRates[emitter] * v2
			emitter.Size = scaleSequence(flame.baseSizes[emitter], v2)
			local baseSpeed = flame.baseSpeeds[emitter]
			emitter.Speed = NumberRange.new(baseSpeed.Min * v2, baseSpeed.Max * v2)
		end
	end
end

function v:Burst(p2: number)
	local v2 = math.clamp((p2 - 1) * 6 + 8, 8, 60)

	for _, flame in self.flames do
		for _, emitter in flame.emitters do
			emitter:Emit(v2)
		end

		if flame.light then
			local brightness = flame.light.Brightness
			local tween = TweenService:Create(flame.light, tweenInfo2, {
				Brightness = brightness + 2
			})
			local v3 = flame
			tween.Completed:Once(function()
				TweenService:Create(v3.light, tweenInfo3, {
					Brightness = brightness
				}):Play()
			end)
			tween:Play()
		end

		local part = flame.part or flame.fire and flame.fire.Parent

		if part then
			fx:PlaySound(fireball_cast, part, true)
		end
	end
end

function v:CreateFallbackFlame()
	local instance

	if self.Instance:IsA("BasePart") then
		instance = self.Instance
	elseif self.Instance:IsA("Model") then
		instance = self.Instance.PrimaryPart or self.Instance:FindFirstChildWhichIsA("BasePart")
	end

	if not instance then
		return
	end

	local fire = Instance.new("Fire")
	fire.Color = color
	fire.SecondaryColor = color2
	fire.Size = 4
	fire.Heat = 6
	fire.Parent = instance
	self.trove:Add(fire)
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 0.5
	pointLight.Range = 6
	pointLight.Parent = instance
	self.trove:Add(pointLight)
	table.insert(self.flames, {
		part = nil,
		baseSize = nil,
		fire = fire,
		light = pointLight,
		emitters = {},
		baseRates = {},
		baseSizes = {},
		baseSpeeds = {}
	})
end

function v:Construct()
	self.trove = Trove.new()
	self.flames = {}
end

function v:Start()
	for _, part in self.Instance:GetDescendants() do
		if not (part.Name == "Flame" and part:IsA("BasePart")) then
			continue
		end

		local emitters = {}
		local ratesByEmitter = {}
		local sizesByEmitter = {}
		local speedsByEmitter = {}

		for _, emitter in part:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			table.insert(emitters, emitter)
			ratesByEmitter[emitter] = emitter.Rate
			sizesByEmitter[emitter] = emitter.Size
			speedsByEmitter[emitter] = emitter.Speed
		end

		table.insert(self.flames, {
			part = part,
			baseSize = part.Size,
			light = part:FindFirstChildWhichIsA("PointLight", true),
			emitters = emitters,
			baseRates = ratesByEmitter,
			baseSizes = sizesByEmitter,
			baseSpeeds = speedsByEmitter
		})
	end

	if #self.flames == 0 then
		self:CreateFallbackFlame()
	end

	self.trove:Connect(remoteEvent.OnClientEvent, function(p, p2)
		if p == self.Instance then
			self:Burst(tonumber(p2) or 1)
		end
	end)
	task.spawn(function()
		local fireOfSpirits = ReplicatedStorage:WaitForChild("FireOfSpirits", 30)
		local flameSize = fireOfSpirits and fireOfSpirits:WaitForChild("FlameSize", 10)

		if not flameSize then
			return
		end

		self.trove:Connect(flameSize:GetPropertyChangedSignal("Value"), function()
			self:ApplySize(flameSize.Value)
		end)
		self:ApplySize(flameSize.Value)
	end)
end

function v.Stop(p)
	p.trove:Destroy()
end

return v