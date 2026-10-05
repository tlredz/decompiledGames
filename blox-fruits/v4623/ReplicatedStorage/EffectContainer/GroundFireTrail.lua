local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local RayCastWhitelist = require(game.ReplicatedStorage.Util.RayCastWhitelist)
local SpikyFlare = require(game.ReplicatedStorage.Util.Particles.SpikyFlare)
require(game.ReplicatedStorage.Util.Particles.Rock)
require(game.ReplicatedStorage.Util.Particles.Dust)
local Rock = require(game.ReplicatedStorage.Util.Rock)

local function alignCF(data, p, _)
	local p2 = data.p
	local unit = data.LookVector:Cross(p).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(p).Unit.Unit
	return CFrame.fromMatrix(p2, unit2, p, unit3)
end

local _ = workspace._WorldOrigin
game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local part = data.Part

	if not part or not part.Parent or (part.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	local offset = data.Offset or CFrame.new()
	local scale = data.Scale
	local color = data.Color or Color3.new(0, 0.3, 1)
	local lerped = color:Lerp(Color3.new(1, 1, 1), 0.15)
	local lastTime = tick()
	local count = 0

	while part:IsDescendantOf(workspace) do
		local _ = tick() - lastTime
		count += 1

		if count % 2 == 0 then
			local v = part.CFrame * offset
			local v2, v3, v4 = RayCastWhitelist(v.p, -v.UpVector * scale * 2, { workspace.Map })

			if v2 then
				local v5 = alignCF(CFrame.new(Vector3.new(), v.LookVector), v4 or createVector(0, 1, 0)) + v3

				if count % 6 == 0 then
					for i = -1, 1, 2 do
						SpikyFlare.new({
							InnerColor = color,
							OuterColor = lerped,
							TransparencyInfluence = 0.15,
							AngleInfluence = { Vector3.new(), (Vector3.new(0, 0, -i * 3.141592653589793 / 3)) },
							PulseSpeed = 1,
							FadeIn = 0.1,
							FadeOut = 0.3,
							Lifetime = 0.15,
							CFrame = v5 * CFrame.new(i * scale / 2, 0, 0) * CFrame.Angles(0.5235987755982988, 0, 0),
							Scale = { 4 * scale * 0.45, scale * 0.45 * Random.new():NextNumber(4, 4.2) }
						})
						SpikyFlare.new({
							InnerColor = color,
							OuterColor = lerped,
							TransparencyInfluence = 0.15,
							AngleInfluence = { Vector3.new(), (Vector3.new(0, 0, -i * 3.141592653589793 / 3)) },
							PulseSpeed = 1,
							FadeIn = 0.1,
							FadeOut = 0.3,
							Lifetime = 0.15,
							CFrame = v5 * CFrame.new(i * scale / 2, 0, 0) * CFrame.Angles(0.5235987755982988, 0, 0),
							Scale = { 4 * scale * 0.45, scale * 0.45 * Random.new():NextNumber(4, 4.2) }
						})
					end
				end

				for i = -1, 1, 2 do
					local v6 = v5 * Vector3.new(i * scale * Random.new():NextNumber(0.9, 1.1), 0, 0) - v5.p
					local ground = Rock.new("Ground", {
						Scale = { scale / 2 * 1.1, scale / 2 * 1.15 },
						FadeIn = 0.1,
						FadeOut = 0.3,
						Lifetime = { 0.3, 0.35 }
					})
					ground:Spawn(v5)
					ground:TweenShift(v6, 0.25)

					if not (math.random() < 0.25) then
						continue
					end

					local flying = Rock.new("Flying", {
						Scale = { scale / 4, scale / 3 },
						FadeIn = 0.1,
						FadeOut = 0.25,
						Lifetime = { 0.25, 0.5 }
					})
					flying:Spawn(v5 * CFrame.new(i * scale, 0, 0))
					flying:Eject({
						RotVelocity = Vector3.new(
							math.random() * 2 * 3.141592653589793,
							math.random() * 2 * 3.141592653589793,
							math.random() * 2 * 3.141592653589793
						) * 2,
						Velocity = (v5 * CFrame.Angles(0, 0, -i * 3.141592653589793 / 6)).UpVector * createVector(
							1,
							0.1,
							0
						) * Random.new():NextNumber(10, 30) * (scale / 2) + createVector(0, 1, 0) * Random.new():NextNumber(
							30,
							60
						) * math.clamp(scale / 2, 1, 5) * 0.5
					})
				end
			end
		end

		RunService.RenderStepped:Wait()
	end
end