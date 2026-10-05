local createVector = vector.create
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local SmokeScreen = {}
SmokeScreen.__index = SmokeScreen

function SmokeScreen.new(fighterInterface)
	local self = setmetatable({}, SmokeScreen)
	self.FighterInterface = fighterInterface
	self._smoke_cloud_spring = Spring.new(0, 1, 20)
	self._smoke_cloud_cover = Instance.new("Part")
	self._smoke_cloud_dof = Instance.new("DepthOfFieldEffect")
	self._smoke_cloud_cc = Instance.new("ColorCorrectionEffect")
	self._smoke_clouds_entered = {}
	self:_Init()
	return self
end

function SmokeScreen:Hide()
	self._smoke_cloud_cover.Parent = nil
	self._smoke_cloud_dof.Parent = nil
	self._smoke_cloud_cc.Parent = nil
end

function SmokeScreen:Update(_, _)
	local _GetSmokeCloud = self:_GetSmokeCloud()
	self._smoke_cloud_spring.Target = _GetSmokeCloud and 1 or 0
	self._smoke_cloud_spring.Speed = _GetSmokeCloud and 100 or 20
	self._smoke_cloud_cover.Transparency = 1 + -0.989 * self._smoke_cloud_spring.Value
	self._smoke_cloud_cover.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -0.25)
	self._smoke_cloud_cover.Parent = workspace
	self._smoke_cloud_dof.FarIntensity = self._smoke_cloud_spring.Value
	self._smoke_cloud_dof.Parent = self._smoke_cloud_spring.Value > 0.001 and Lighting or nil
	self._smoke_cloud_cc.Contrast = 0 + -1 * self._smoke_cloud_spring.Value
	self._smoke_cloud_cc.TintColor = Color3.fromRGB(255, 255, 255):Lerp(
		Color3.fromRGB(99, 99, 99),
		self._smoke_cloud_spring.Value
	)
	self._smoke_cloud_cc.Parent = Lighting

	if _GetSmokeCloud and not self._smoke_clouds_entered[_GetSmokeCloud] then
		self._smoke_clouds_entered[_GetSmokeCloud] = true
		ReplicatedStorage.Remotes.Replication.Fighter.WasSmoked:FireServer(_GetSmokeCloud:GetAttribute("ObjectID"))
	end
end

function SmokeScreen:Clear()
	self._smoke_clouds_entered = {}
end

function SmokeScreen:Destroy()
	self._smoke_cloud_cover:Destroy()
	self._smoke_cloud_dof:Destroy()
	self._smoke_cloud_cc:Destroy()
	self:Clear()
end

function SmokeScreen:_GetSmokeCloud()
	local v = {
		workspace.CurrentCamera.CFrame.Position,
		self.FighterInterface.ClientFighter.Entity and self.FighterInterface.ClientFighter.Entity.RootPart.Position or nil
	}

	for _, v2 in pairs(v) do
		local v3 = GameplayUtility:GetSmokeCloudsInSphere(v2)[1]

		if v3 then
			return v3
		end
	end
end

function SmokeScreen:_Setup()
	self._smoke_cloud_cover.Color = Color3.fromRGB(72, 75, 79)
	self._smoke_cloud_cover.Anchored = true
	self._smoke_cloud_cover.CanCollide = false
	self._smoke_cloud_cover.CastShadow = false
	self._smoke_cloud_cover.CanQuery = false
	self._smoke_cloud_cover.CanTouch = false
	self._smoke_cloud_cover.Size = createVector(10, 10, 0)
	self._smoke_cloud_cover.Material = Enum.Material.Neon
	self._smoke_cloud_cover.Transparency = 1
	self._smoke_cloud_dof.FarIntensity = 0
	self._smoke_cloud_dof.FocusDistance = 0
	self._smoke_cloud_dof.InFocusRadius = 1.75
	self._smoke_cloud_dof.NearIntensity = 0
end

function SmokeScreen:_Init()
	self:_Setup()
end

return SmokeScreen