local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local random = Random.new()
local SwirlsX = {}
SwirlsX.__index = SwirlsX
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

function SwirlsX.new(parts: number, cframe: CFrame, tpart)
	local self = setmetatable({}, SwirlsX)
	self.ChargeProperties = {
		Origin = cframe,
		Parts = parts,
		Tpart = tpart,
		MinStartRadius = 31.5,
		MaxStartRadius = 38.5,
		MinEndRadius = -7,
		MaxEndRadius = 10.5,
		MinRotSpeed = 1900,
		MaxRotSpeed = 2100,
		MinRadiusDecreaseSpeed = 200,
		MaxRadiusDecreaseSpeed = 240,
		MinYOffset = -7,
		MaxYOffset = 7,
		TotalAngle = 360,
		MinSpinDuration = 0.05,
		MaxSpinDuration = 0.1,
		DecelerationSpeed = 84,
		MinLifetime = 2.5,
		MaxLifetime = 3,
		RadLimit = -16,
		DestroyLifetime = 0.5
	}
	self.ShootProperties = {
		Origin = cframe,
		Parts = parts,
		Tpart = tpart,
		MinStartRadius = 7,
		MaxStartRadius = 14,
		MinEndRadius = 56,
		MaxEndRadius = 84,
		MinRotSpeed = 1500,
		MaxRotSpeed = 2100,
		MinRadiusIncreaseSpeed = 40,
		MaxRadiusIncreaseSpeed = 160,
		MinUpSpeed = 120,
		MaxUpSpeed = 360,
		YOffset = -11.2,
		TotalAngle = 360,
		DecelerationSpeed = 44,
		MinLifetime = 0.5,
		MaxLifetime = 1,
		DestroyLifetime = 0.5
	}
	self.ShieldProperties = {
		Origin = cframe,
		Parts = parts,
		Tpart = tpart,
		MinRad = 14,
		MaxRad = 14.7,
		YOffset = 3.5,
		YSpeed = 40,
		RadLimit = 42
	}
	return self
end

function SwirlsX.Charge(p)
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
			clone.Position += Vector3.new(0, -number5 / 5, 0)
			v += number3 / 50

			if number2 <= number and os.time() - now <= number7 then
				number -= number4 / 50
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

function SwirlsX.Shoot(p)
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
			clone.Position = Vector3.new(v8, clone.Position.Y + number5 / 50, v9)
			v += number3 / 50

			if number <= number2 and os.time() - now <= number6 then
				number += number4 / 50
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

return SwirlsX