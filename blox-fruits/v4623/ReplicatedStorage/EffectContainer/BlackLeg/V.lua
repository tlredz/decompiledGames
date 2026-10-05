local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local sound = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

return function(data)
	local rootPart = (data.SubEffect or 1) == 1 and data.RootPart

	if rootPart then
		local cFrame = rootPart.CFrame

		if not data.Fast then
			Util.Anims:Get(rootPart.Parent, "BlackLegIgnite"):Play()
			local clone = script.particle:Clone()
			debris:AddItem(clone, 3)
			clone.CFrame = cFrame

			if data.HueShift then
				Util.HueShift({ clone }, data.HueShift)
			end

			clone.Parent = _WorldOrigin
			task.delay(0.2, function()
				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			sound:Play("BlackLegIgnite2", rootPart.Position, nil, 1, 1)
		end

		local clone = script.Particle4:Clone()
		debris:AddItem(clone, 3)

		if data.HueShift then
			Util.HueShift({ clone }, data.HueShift)
		end

		clone.CFrame = cFrame * CFrame.new(0, -2, 0)
		clone.Orientation += createVector(-90, 90, 0)
		clone.Parent = _WorldOrigin

		if not data.Fast then
			wait(1.2)
		end

		sound:Play("BlackLegIgnite2", clone.Position, nil, 1, 1)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local position = clone.Position
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 125 then
				Util.CameraShaker:Shake(Util.CameraShaker.Presets.Bump)
			end
		end

		coroutine.wrap(function()
			local ground = Util.RocksModule.Ground
			local position2 = clone.Position
			local v = { workspace.Map }
			ground(position2, 13, createVector(2.5, 3.1, 2.5), v, 6, false, 1)
		end)()
		local v = cFrame * CFrame.new(0, -2.5, 0).Position
		local ray, v2, v3 = Util.Ray(v, CFrame.new(v).UpVector.Unit * -15, { workspace.Characters, workspace.Enemies })

		if ray then
			local clone2 = script.BurntFloor:Clone()
			clone2.CFrame = CFrame.new(v2, v2 + v3) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone2.Parent = _WorldOrigin
			TweenService:Create(clone2, tweenInfo, {
				Size = createVector(17.811, 0.001, 17.811)
			}):Play()
			task.delay(1, function()
				for _, decal in pairs(clone2:GetDescendants()) do
					if decal:IsA("Decal") then
						TweenService:Create(decal, tweenInfo, {
							Transparency = 1
						}):Play()
					end
				end
			end)
			debris:AddItem(clone2, 3)
		end
	end
end