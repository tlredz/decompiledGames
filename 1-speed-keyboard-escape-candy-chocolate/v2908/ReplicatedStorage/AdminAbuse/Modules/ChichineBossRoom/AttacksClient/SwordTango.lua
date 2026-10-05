local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage.AdminAbuse.ChichineBossRoom.Assets
local ClientDebris = require(script.Parent.ClientDebris)
local ChichineConfig = require(script.Parent.Parent.ChichineConfig)
local v = -1e999
local v2 = {}
local SwordTango = {}

function SwordTango.play(data)
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0
	local duration = data.duration or 10
	local phase = data.phase or 1
	local v3 = math.random(100, 150)
	local swordTango = assets:FindFirstChild("SwordTango")

	if not swordTango then
		warn("[ChichineBossRoom] SwordTango: 'SwordTango' model not found in Assets")
		return
	end

	local swordTango2 = ChichineConfig.SwordTango
	local v4 = math.clamp(phase, 1, 5)
	local vector = Vector3.new(x, y + 3, z)

	local function onSwordTouched(p)
		local character = Players.LocalPlayer.Character

		if not character or p.Parent ~= character then
			return
		end

		local now = tick()

		if now - v < swordTango2.damageCooldown then
			return
		end

		v = now
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 then
			humanoid:TakeDamage(swordTango2.damage)
		end
	end

	for i = 1, v4 do
		local clone = swordTango:Clone()
		local transparenciesByPart = {}

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			transparenciesByPart[part] = part.Transparency
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = true
			part.CastShadow = false
			part.Touched:Connect(onSwordTouched)
		end

		local v5 = (i - 1) / v4 * 6.283185307179586
		clone:PivotTo(CFrame.new(vector + Vector3.new(math.cos(v5) * v3, 0, math.sin(v5) * v3)) * CFrame.Angles(
			0,
			-v5,
			0
		))
		clone.Parent = ClientDebris()
		local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for k, transparency in transparenciesByPart do
			if k.Parent then
				TweenService:Create(k, tweenInfo, {
					Transparency = transparency
				}):Play()
			end
		end

		local total = 0
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			if not clone.Parent then
				heartbeatConnection:Disconnect()
				return
			end

			total += dt
			local v8 = v5 + total * 1.2
			local v9 = math.cos(v8) * v3
			local v10 = math.sin(v8) * v3
			clone:PivotTo(CFrame.new(vector + Vector3.new(v9, 0, v10)) * CFrame.Angles(0, -v8, 0))
		end)
		table.insert(v2, {
			model = clone,
			conn = heartbeatConnection
		})
		local folder = clone
		task.delay(duration, function()
			heartbeatConnection:Disconnect()

			if not folder.Parent then
				return
			end

			for i2, part in folder:GetDescendants() do
				if part:IsA("BasePart") then
					TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Transparency = 1
					}):Play()
				end
			end

			task.delay(0.5, function()
				pcall(function()
					folder:Destroy()
				end)

				for k, v8 in v2 do
					if v8.model ~= folder then
						continue
					end

					table.remove(v2, k)
					break
				end
			end)
		end)
	end
end

function SwordTango.cleanup()
	for _, v3 in v2 do
		local v4 = v3
		pcall(function()
			v4.conn:Disconnect()
			v4.model:Destroy()
		end)
	end

	table.clear(v2)
end

return SwordTango