workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris
local Crow = require(script.Crow)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setColorSequence(p, color)
	p.Color = ColorSequence.new(color)
end

return function(data)
	local type = data.Type

	if type == -1 then
		local amount = data.Amount or 1
		local bezier = data.Bezier
		local life = data.Life

		for _ = 1, amount do
			Crow.new(life, bezier, function(instance)
				instance:Destroy()
			end)
		end
	elseif type == 0 then
		local amount = data.Amount or 1
		local bezier = data.Bezier
		local life = data.Life
		local slash = data.Slash

		for _ = 1, amount do
			Crow.new(life, bezier, function(instance)
				Effect.new("Shadow.Misc"):replicate({
					Type = 1,
					Position = instance.Position
				})
				Util.Sound:Play("ShadowAura", instance.Position, nil, math.random(19, 21) / 10, 2)
				instance:Destroy()

				if slash then
					Effect.new("Shadow.Misc"):replicate({
						Type = 2,
						Root = instance.Position
					})
				end
			end)
		end
	elseif type == 1 then
		local amount = data.Amount or 1
		local bezier = data.Bezier
		local life = data.Life

		for _ = 1, amount do
			local v = Crow.new(life, bezier, function(instance)
				Effect.new("Shadow.Misc"):replicate({
					Type = 1,
					Position = instance.Position
				})
				Util.Sound:Play("ShadowAura", instance.Position, nil, math.random(19, 21) / 10, 2)
				instance:Destroy()
			end)
			v.Color = Color3.fromRGB(32, 9, 83)
			setColorSequence(v.LeftEye.EyeParticles, Color3.fromRGB(125, 49, 255)) -- equivalent call inferred; original call site unknown
			setColorSequence(v.RightEye.EyeParticles, Color3.fromRGB(125, 49, 255)) -- equivalent call inferred; original call site unknown
			setColorSequence(v.LeftWing.LeftWingSmoke, Color3.fromRGB(34, 0, 90)) -- equivalent call inferred; original call site unknown
			setColorSequence(v.RightWing.RightWingSmoke, Color3.fromRGB(34, 0, 90)) -- equivalent call inferred; original call site unknown
			setColorSequence(v.Smoke, Color3.fromRGB(34, 0, 90)) -- equivalent call inferred; original call site unknown
		end
	elseif type == 2 then
		local position = data.Position
		local radius = data.Radius
		local life = data.Life
		local lifeRange = data.LifeRange
		local lastTime = tick()
		local lastTime2 = tick()

		while tick() - lastTime <= life do
			if tick() - lastTime2 > 0.2 then
				lastTime2 = tick()
				local v = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					0,
					-radius
				)
				local v2 = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					math.random(0, 10),
					-radius
				)
				local v3 = v * CFrame.Angles(0, math.rad((math.random(-20, 20))), 0) * CFrame.new(0, 0, 2 * radius)
				local _ = v * CFrame.Angles(0, math.rad((math.random(-30, 30))), 0) * CFrame.new(
					0,
					math.random(0, 10),
					2 * radius
				)
				local v4 = {
					v.p,
					(cflerp(v, v3, 0.33) * CFrame.new(math.random(-10, 10), math.random(-15, -10), 0)).p,
					(cflerp(v, v3, 0.66) * CFrame.new(math.random(-10, 10), math.random(-15, -10), 0)).p,
					v3.p
				}
				Crow.new(math.random(lifeRange[1], lifeRange[2]) / 10, v4, function(instance)
					Effect.new("Shadow.Misc"):replicate({
						Type = 1,
						Position = instance.Position
					})
					Util.Sound:Play("ShadowAura", instance.Position, nil, math.random(19, 21) / 10, 2)
					instance:Destroy()
				end)
				local halfRadius = radius / 2
				local v6 = {
					v2.p,
					(cflerp(v, v3, 0.33) * CFrame.new(math.random(-halfRadius, halfRadius), math.random(-5, 10), 0)).p,
					(cflerp(v, v3, 0.66) * CFrame.new(math.random(-halfRadius, halfRadius), math.random(-5, 10), 0)).p,
					v3.p
				}
				Crow.new(math.random(lifeRange[1], lifeRange[2]) / 10, v6, function(instance)
					Effect.new("Shadow.Misc"):replicate({
						Type = 1,
						Position = instance.Position
					})
					Util.Sound:Play("ShadowAura", instance.Position, nil, math.random(19, 21) / 10, 2)
					instance:Destroy()
				end)
			end

			RunService.RenderStepped:Wait()
		end
	elseif type == 3 then
		local position = data.Position
		local lifeRange = data.LifeRange

		for _ = 1, math.random(6, 7) do
			local cframe = CFrame.Angles(math.rad((math.random(1, 15))), math.rad((math.random(-180, 180))), 0)
			local v = CFrame.new(position) * cframe
			local v2 = v * CFrame.new(0, math.random(12, 35), math.random(-45, -20))
			local v3 = {
				position,
				(cflerp(v, v2, 0.33) * CFrame.new(math.random(-40, 40), math.random(-5, 10), 0)).p,
				(cflerp(v, v2, 0.66) * CFrame.new(math.random(-60, 60), math.random(-5, 10), 0)).p,
				v2.p
			}
			Crow.new(math.random(lifeRange[1], lifeRange[2]) / 10, v3, function(instance)
				Effect.new("Shadow.Misc"):replicate({
					Type = 1,
					Position = instance.Position
				})
				instance:Destroy()
			end)
		end
	end
end