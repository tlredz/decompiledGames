local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Meme").F.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function ButtonHolding(_, root, holding, folder, raycastParams)
	local clone = assets.FlyModel:Clone()
	clone:ScaleTo(1.75)
	local fly = clone.Fly
	fly.CFrame = root.CFrame
	fly.Anchored = false
	fly.Weld.Part1 = root
	fly.Weld.C0 *= CFrame.new(0, -1.5, 0)
	fly.Parent = folder

	if holding.Value == true then
		local v = Util.Sound:Play("SpinningWithWindLoop", root)
		local clone2 = assets.GroundRocks:Clone()
		clone2.Parent = folder
		local emittersByEmitter = {}
		local v2 = false

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false
			emittersByEmitter[emitter] = emitter
		end

		local v3 = 0.016666666666666666

		while true do
			fly.Weld.C0 = fly.Weld.C0 * CFrame.Angles(0, math.rad(v3 * 35 * 60), 0)
			local raycastResult = workspace:Raycast(
				root.Position + createVector(0, 1, 0),
				createVector(-0, -15, -0),
				raycastParams
			)

			if raycastResult then
				clone2.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05

				if v2 == false then
					v2 = true

					for _, v4 in pairs(emittersByEmitter) do
						v4.Enabled = true

						if v4:GetAttribute("Color") then
							v4.Color = ColorSequence.new(raycastResult.Instance.Color, raycastResult.Instance.Color)
						end
					end
				end
			elseif v2 == true then
				v2 = false

				for _, v4 in pairs(emittersByEmitter) do
					v4.Enabled = false
				end
			end

			v3 = RunService.Heartbeat:Wait()

			if not (holding.Value ~= true or not holding:IsDescendantOf(workspace)) then
				continue
			end

			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			for _, v4 in pairs(emittersByEmitter) do
				v4.Enabled = false
			end

			break
		end
	end

	fly:Destroy()
end

local CreateCone = require(script.Parent.CreateCone)
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
return function(p)
	local root = p.Root

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local cFrame = root.CFrame
	local cone = CreateCone(root.Parent.RightLowerArm, folder, CFrame.Angles(0, 3.141592653589793, 0))
	local clone = assets.Flight:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	clone.Anchored = false
	clone.Weld.Part0 = root

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	ButtonHolding(p, root, p.Holding, folder, raycastParams)
	clone.Weld.Enabled = false
	clone.Anchored = true

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	Util.Debris:AddItem(folder, 5)
	task.spawn(function()
		task.wait(0.1)
		cone:Shrink()
	end)
end