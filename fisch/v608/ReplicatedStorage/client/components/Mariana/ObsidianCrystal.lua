local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local color = Color3.fromRGB(38, 32, 54)
local color2 = Color3.fromRGB(130, 43, 46)
local color3 = Color3.fromRGB(106, 97, 130)
local v = Component.new({
	Tag = "ObsidianCrystal",
	Ancestors = { workspace }
})

function v:Construct()
	self.Trove = Trove.new()
	self.Core = nil
	self.Glow = 0

	local function attach(part)
		if self.Core or part.Name ~= "innerObsidian" or not part:IsA("BasePart") then
			return
		end

		self.Core = part
		local pointLight = Instance.new("PointLight")
		pointLight.Range = 18
		pointLight.Brightness = 0
		pointLight.Parent = part
		self.Light = self.Trove:Add(pointLight)
	end

	local innerObsidian = self.Instance:FindFirstChild("innerObsidian")

	if innerObsidian then
		attach(innerObsidian)
	else
		self.Trove:Connect(self.Instance.ChildAdded, attach)
	end
end

function v:RenderSteppedUpdate(p: number)
	if not self.Core then
		return
	end

	local obsidianTrenchRedness = workspace:GetAttribute("ObsidianTrenchRedness") or 0
	local lerped = color:Lerp(color2, obsidianTrenchRedness)
	local serverTimeNow = workspace:GetServerTimeNow()
	local glowUntil = self.Instance:GetAttribute("GlowUntil")
	local v2 = glowUntil and serverTimeNow < glowUntil and 1 or 0
	local v3 = self.Glow < v2 and 7 or 1.8
	self.Glow += (v2 - self.Glow) * (1 - math.exp(-v3 * p))
	local brightness = 2 + obsidianTrenchRedness * 6

	if self.Glow < 0.01 then
		self.Glow = 0
		self.Core.Color = lerped
		self.Core.Material = Enum.Material.Glass
		self.Light.Brightness = brightness
		self.Light.Color = lerped
	else
		local v5 = math.sin(serverTimeNow * 6) * 0.35 + 0.65
		self.Core.Color = lerped:Lerp(color3, self.Glow * v5)
		self.Core.Material = Enum.Material.Neon
		self.Light.Brightness = brightness + (v5 * 8 - brightness) * self.Glow
		self.Light.Color = lerped:Lerp(color3, self.Glow)
	end
end

function v.Stop(p)
	p.Trove:Clean()
end

return v