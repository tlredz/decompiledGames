local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local random = Random.new()
local SwirlsC = {}
SwirlsC.__index = SwirlsC
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

function SwirlsC.new(parts: number, cframe: CFrame, tpart)
	local self = setmetatable({}, SwirlsC)
	self.ChargeProperties = {
		Origin = cframe,
		Parts = parts,
		Tpart = tpart,
		MinStartRadius = 45,
		MaxStartRadius = 55,
		MinEndRadius = -10,
		MaxEndRadius = 15,
		MinRotSpeed = 950,
		MaxRotSpeed = 1050,
		MinRadiusDecreaseSpeed = 100,
		MaxRadiusDecreaseSpeed = 120,
		MinYOffset = -5,
		MaxYOffset = 5,
		TotalAngle = 360,
		MinSpinDuration = 0.1,
		MaxSpinDuration = 0.2,
		DecelerationSpeed = 42,
		MinLifetime = 5,
		MaxLifetime = 6,
		RadLimit = -8,
		DestroyLifetime = 1
	}
	self.ShootProperties = {
		Origin = cframe,
		Parts = parts,
		Tpart = tpart,
		MinStartRadius = 50,
		MaxStartRadius = 75,
		MinEndRadius = 90,
		MaxEndRadius = 190,
		MinRotSpeed = 750,
		MaxRotSpeed = 1050,
		MinRadiusIncreaseSpeed = 120,
		MaxRadiusIncreaseSpeed = 290,
		MinUpSpeed = 220,
		MaxUpSpeed = 350,
		YOffset = -15,
		TotalAngle = 360,
		DecelerationSpeed = 92,
		MinLifetime = 0.15,
		MaxLifetime = 0.15,
		DestroyLifetime = 0.4
	}
	self.ShieldProperties = {
		Origin = cframe,
		Parts = parts,
		Tpart = tpart,
		MinRad = 20,
		MaxRad = 21,
		YOffset = 5,
		YSpeed = 20,
		RadLimit = 30
	}
	return self
end

function SwirlsC.Charge(p)
	for i = 1, p.ChargeProperties.Parts do
		local clone = p.ChargeProperties.Tpart:Clone()
		clone.Parent = _WorldOrigin or workspace
		clone.Att0.Trail.Enabled = false
		local now = os.time()
		local number = random:NextNumber(p.ChargeProperties.MinStartRadius, p.ChargeProperties.MaxStartRadius)
		local number2 = random:NextNumber(p.ChargeProperties.MinEndRadius, p.ChargeProperties.MaxEndRadius)
		local number3 = random:NextNumber(p.ChargeProperties.MinRotSpeed, p.ChargeProperties.MaxRotSpeed)
		local number4 = random:NextNumber(
			p.ChargeProperties.MinRadiusDecreaseSpeed,
			p.ChargeProperties.MaxRadiusDecreaseSpeed
		)
		local number5 = random:NextNumber(p.ChargeProperties.MinYOffset, p.ChargeProperties.MaxYOffset)
		local number6 = random:NextNumber(p.ChargeProperties.MinSpinDuration, p.ChargeProperties.MaxSpinDuration)
		local number7 = random:NextNumber(p.ChargeProperties.MinLifetime, p.ChargeProperties.MaxLifetime)
		local v = p.ChargeProperties.TotalAngle / p.ChargeProperties.Parts * i
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local v9 = p.ChargeProperties.Origin.Position.X + math.cos((math.rad(v))) * number
			local v10 = p.ChargeProperties.Origin.Position.Z + math.sin((math.rad(v))) * number
			clone.Att0.Trail.Enabled = true
			clone.Position = Vector3.new(v9, p.ChargeProperties.Origin.Position.Y + number5, v10)
			clone.Position += Vector3.new(0, -number5 / 10, 0)
			v += number3 / 100

			if number2 <= number and os.time() - now <= number7 then
				number -= number4 / 100
				return
			end

			task.wait(number6)
			number3 -= p.ChargeProperties.DecelerationSpeed

			if number3 <= p.ChargeProperties.RadLimit then
				heartbeatConnection:Disconnect()
				Debris:AddItem(clone, p.ChargeProperties.DestroyLifetime)
			end
		end)
	end
end

function SwirlsC.Shoot(p)
	for i = 1, p.ShootProperties.Parts * 1.1 do
		local clone = p.ShootProperties.Tpart:Clone()
		clone.Parent = _WorldOrigin or workspace
		clone.Att0.Trail.Enabled = false
		clone.Position = p.ShootProperties.Origin.Position + Vector3.new(0, p.ShootProperties.YOffset, 0)
		local now = os.time()
		local number = random:NextNumber(p.ShootProperties.MinStartRadius, p.ShootProperties.MaxStartRadius)
		local number2 = random:NextNumber(p.ShootProperties.MinEndRadius, p.ShootProperties.MaxEndRadius)
		local number3 = random:NextNumber(p.ShootProperties.MinRotSpeed, p.ShootProperties.MaxRotSpeed)
		local number4 = random:NextNumber(
			p.ShootProperties.MinRadiusIncreaseSpeed,
			p.ShootProperties.MaxRadiusIncreaseSpeed
		)
		local number5 = random:NextNumber(p.ShootProperties.MinUpSpeed, p.ShootProperties.MaxUpSpeed)
		local number6 = random:NextNumber(p.ShootProperties.MinLifetime, p.ShootProperties.MaxLifetime)
		local v = p.ShootProperties.TotalAngle / p.ShootProperties.Parts * i
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local v8 = p.ShootProperties.Origin.Position.X + math.cos((math.rad(v))) * number
			local v9 = p.ShootProperties.Origin.Position.Z + math.sin((math.rad(v))) * number
			clone.Att0.Trail.Enabled = true
			clone.Position = Vector3.new(v8, clone.Position.Y + number5 / 100, v9)
			v += number3 / 100

			if number <= number2 and os.time() - now <= number6 then
				number += number4 / 100
				return
			end

			number3 -= p.ShootProperties.DecelerationSpeed

			if number3 <= 0 then
				heartbeatConnection:Disconnect()
				Debris:AddItem(clone, p.ShootProperties.DestroyLifetime)
			end
		end)
	end
end

return SwirlsC