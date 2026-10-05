local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebris = require(script.Parent.ClientDebris)
local ImpactFx = require(script.Parent.ImpactFx)
local WCFinaleAdminAbuseConfig = require(script.Parent.Parent.WCFinaleAdminAbuseConfig)
local v = -1e999
local v2 = {}
local v3 = {}
local color = Color3.fromRGB(255, 100, 30)
local v4 = { Color3.new(255, 0, 0), Color3.new(0.980392, 0.768627, 0) }

-- equivalent calls inferred from this helper; original call sites unknown
local function removeFromTable(list, p)
	local index = table.find(list, p)

	if index then
		table.remove(list, index)
	end
end

local ShootingPenalties = {}

function ShootingPenalties.spawn(data)
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local wCFinaleAdminAbuse = adminAbuse and adminAbuse:FindFirstChild("WCFinaleAdminAbuse")
	local shootingCard = wCFinaleAdminAbuse and wCFinaleAdminAbuse.Assets:FindFirstChild("ShootingCard")

	if not shootingCard then
		warn("[WCFinaleAdminAbuse] ShootingPenalties: FallingKeycap template not found in RS.AdminAbuse.ChichineBossRoom")
		return
	end

	local success, result = pcall(function()
		return shootingCard:Clone()
	end)

	if not (success and result) then
		return
	end

	result.Anchored = true
	result.CanCollide = false
	result.CanQuery = false
	result.CastShadow = false
	result.Color = v4[math.random(1, #v4)]
	local sx = data.sx or 0
	local sy = data.sy or 0
	local sz = data.sz or 0
	local lx = data.lx or 0
	local ly = data.ly or 0
	local lz = data.lz or 0
	local t = data.t or 1.5
	local vector2 = Vector3.new(sx, sy, sz)
	local vector3 = Vector3.new(lx, ly, lz)
	local unit = (vector3 - vector2).Unit
	local frontFace = result:FindFirstChild("FrontFace")
	local lookVector = frontFace and frontFace.CFrame.LookVector or createVector(0, 0, -1)
	local cross = lookVector:Cross(unit)
	local cframe

	if cross.Magnitude > 0.00001 then
		local v5 = math.acos((math.clamp(lookVector:Dot(unit), -1, 1)))
		cframe = CFrame.new(vector2) * CFrame.fromAxisAngle(cross.Unit, v5)
	elseif lookVector:Dot(unit) < 0 then
		local v5 = math.abs(lookVector.Y) < 0.9 and createVector(0, 1, 0) or createVector(1, 0, 0)
		cframe = CFrame.new(vector2) * CFrame.fromAxisAngle(lookVector:Cross(v5).Unit, 3.141592653589793)
	else
		cframe = CFrame.new(vector2)
	end

	result.CFrame = cframe
	local cFrame = cframe + (vector3 - cframe.Position)
	result.Parent = ClientDebris()
	table.insert(v2, result)
	local part = Instance.new("Part")
	part.Name = "WCFinaleSPWarnDisc"
	part.Shape = Enum.PartType.Cylinder
	part.Size = createVector(0.05, 40, 40)
	part.CFrame = CFrame.new(lx, ly + 0.15, lz) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.35
	part.Parent = ClientDebris()
	table.insert(v3, part)
	TweenService:Create(part, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(0.35, 40, 40)
	}):Play()
	local tween = TweenService:Create(result, TweenInfo.new(t, Enum.EasingStyle.Linear), {
		CFrame = cFrame
	})
	tween:Play()
	tween.Completed:Once(function()
		ImpactFx.explosion(lx, ly, lz, 45)
		removeFromTable(v2, result) -- equivalent call inferred; original call site unknown
		pcall(function()
			result:Destroy()
		end)
		local shootingPenalties = WCFinaleAdminAbuseConfig.ShootingPenalties
		local character = Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local v8 = shootingPenalties.landingRadius + 2
		local vector4 = humanoidRootPart.Position - Vector3.new(lx, ly, lz)
		local dot = vector4:Dot(vector4)

		if v8 * v8 < dot then
			return
		end

		local now = tick()

		if now - v < 1.5 then
			return
		end

		v = now
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 then
			humanoid:TakeDamage(shootingPenalties.damage)
		end
	end)
	task.delay(math.max(0, t - 0.15), function()
		if not part.Parent then
			return
		end

		local tween2 = TweenService:Create(part, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1
		})
		tween2.Completed:Once(function()
			removeFromTable(v3, part) -- equivalent call inferred; original call site unknown
			pcall(function()
				part:Destroy()
			end)
		end)
		tween2:Play()
	end)
end

function ShootingPenalties.impactFx(data)
	ImpactFx.explosion(data.x or 0, data.y or 0, data.z or 0, 45)
end

function ShootingPenalties.cleanup()
	for _, v5 in v2 do
		local v6 = v5
		pcall(function()
			v6:Destroy()
		end)
	end

	for _, v5 in v3 do
		local v6 = v5
		pcall(function()
			v6:Destroy()
		end)
	end

	table.clear(v2)
	table.clear(v3)
end

return ShootingPenalties