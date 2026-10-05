local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local FastCastRedux = require(game.ReplicatedStorage.Modules.FastCastRedux)
local random = Random.new()
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local _ = game.Players.LocalPlayer
local behavior = FastCastRedux.newBehavior()
behavior.MaxDistance = 150
behavior.Acceleration = Vector3.new(0, -workspace.Gravity, 0)
behavior.CosmeticBulletTemplate = script.BloodFly
behavior.CosmeticBulletContainer = workspace.Effects.Blood.Particle
behavior.AutoIgnoreContainer = false
behavior.RaycastParams = RaycastParams.new()
behavior.RaycastParams.FilterType = Enum.RaycastFilterType.Include
behavior.RaycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local cframe = CFrame.Angles(-1.5707963267948966, 0, 0)
local v = {}
table.insert(v, script.PoolActor)
table.insert(v, (script.PoolActor:Clone()))
table.insert(v, (script.PoolActor:Clone()))
local BloodyZee = {}

for _, v2 in v do
	v2.Parent = workspace.Effects.Blood
end

BloodyZee.PermBlood = false
behavior.HighFidelityBehavior = 3

local function onRayHit(_, data, _, _)
	local instance = data.Instance
	local v2 = random:NextInteger(5, 20) / 10
	local v3 = math.random(0, 3.141592653589793)
	local cFrame = CFrame.lookAlong(data.Position + data.Normal * 0.1, data.Normal) * cframe * CFrame.Angles(0, v3, 0)
	local clone = script.Pool:Clone()
	clone.CFrame = cFrame
	clone:SetAttribute("CF", instance.CFrame:ToObjectSpace(cFrame))
	clone:SetAttribute("RT", v3)
	clone.Ref.Value = instance
	clone.Parent = workspace.Effects.Blood
	TweenService:Create(clone, tweenInfo, {
		Size = Vector3.new(v2, 0, v2)
	}):Play()

	if not BloodyZee.PermBlood then
		Debris:AddItem(clone, 8)
	end
end

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	for _, part in workspace.Effects.Blood:GetChildren() do
		if not (part:IsA("BasePart") and part.Locked ~= true) then
			continue
		end

		local value = part.Ref.Value

		if value and value.Parent and not ((value.Position - part.Position).Magnitude > 100000) then
			part.CFrame = value.CFrame:ToWorldSpace(part:GetAttribute("CF"))
		else
			part.Locked = true
			v[math.random(1, #v)]:SendMessage("Ray", part)
		end
	end
end)

local function onRayUpdated(_, p, p2, p3, _, p4)
	if not p4 then
		return
	end

	p4.Position = p + p2 * p3
end

local function onRayTerminated(p)
	local cosmeticBulletObject = p.RayInfo.CosmeticBulletObject

	if cosmeticBulletObject then
		cosmeticBulletObject.Trail.Enabled = false
		Debris:AddItem(cosmeticBulletObject, 0.15)
	end
end

local v2 = FastCastRedux.new()
v2.RayHit:Connect(onRayHit)
v2.LengthChanged:Connect(onRayUpdated)
v2.CastTerminating:Connect(onRayTerminated)

function BloodyZee.Blood(_, p, p2, p3, p4)
	if _G.Settings.Gore ~= true or not BloodyZee.PermBlood and (workspace.CurrentCamera.CFrame.Position - p.Position).Magnitude > 150 then
		return
	end

	local v3 = math.rad((random:NextInteger(-p3, p3)))
	local v4 = math.rad((random:NextInteger(-p4, p4)))
	local lookVector = (p * CFrame.Angles(v3, v4, 0)).LookVector
	v2:Fire(p.Position, lookVector, p2, behavior)
end

return BloodyZee