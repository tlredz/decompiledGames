local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local FX = require(ReplicatedStorage.FX)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function burstEffect(position, p)
	Util.Sound:Play("QuickSlice", position, nil, 1.1 + math.random(-32, 32) / 100, 0.25)
	local clone = FX:WaitForChild("StringEffects").ThreadHitEffect:Clone()
	clone.Position = position
	local dustEmitter = clone.DustEmitter
	local hitEmitter = clone.HitEmitter

	if p then
		dustEmitter.Color = ColorSequence.new(p)
		hitEmitter.Color = ColorSequence.new(p)
	end

	clone.Parent = _WorldOrigin
	dustEmitter:Emit(5)
	hitEmitter:Emit(1)
	Util.Debris:AddItem(clone, 2)
	wait(1.5)
	clone:Destroy()
end

return function(data)
	local position = data.Position
	local hitType = data.HitType or nil
	local color = data.Color or nil
	local buso = data.Buso

	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 300 then
		return
	end

	if hitType then
		local v

		if buso then
			v = buso.Color
		else
			v = Color3.new(1, 1, 1)
		end

		local v2 = color or v

		if hitType == 1 then
			spawn(function()
				local clone = ReplicatedStorage.Assets.Models.SlashMesh:Clone()
				clone.Size = createVector(1, 0.05, 2)
				Util.Debris:AddItem(clone, 3)
				clone.CFrame = CFrame.new(position) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 1,
						Size = createVector(15.34, 0.05, 25.13),
						CFrame = clone.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
					}
				)
				clone.Parent = _WorldOrigin
				Util.Sound:Play("QuickSlice", position, nil, 1.1 + math.random(-32, 32) / 100, 0.25)
				tween:Play()
				tween.Completed:Connect(function()
					clone:Destroy()
				end)
				burstEffect(position, v2 or nil)
			end)
		elseif hitType == 2 then
			local part = Instance.new("Part")
			Util.Debris:AddItem(part, 3)
			part.Color = Color3.fromRGB(255, 154, 107)
			part.Anchored = true
			part.CanCollide = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.CFrame = CFrame.new(
				position + Vector3.new(math.random(-10, 10), math.random(-2, 2), math.random(-10, 10)),
				position
			)
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = Enum.MeshType.Sphere
			specialMesh.Offset = createVector(0, 0, 40)
			specialMesh.Scale = createVector(0.1, 0.1, 1)
			specialMesh.Parent = part
			local tween = TweenService:Create(
				specialMesh,
				TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
				{
					Offset = createVector(0, 0, 0),
					Scale = createVector(0.35, 0.35, 20)
				}
			)
			local tween2 = TweenService:Create(
				specialMesh,
				TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Offset = createVector(0, 0, -40),
					Scale = createVector(0.1, 0.1, 1)
				}
			)
			tween2.Completed:Connect(function()
				part:Destroy()
			end)
			tween.Completed:Connect(function()
				tween2:Play()
			end)
			Util.Sound:Play("QuickSlice", position, nil, 1.1 + math.random(-32, 32) / 100, 0.25)
			part.Parent = _WorldOrigin
			tween:Play()
			burstEffect(position, v2 or nil)
		elseif hitType == 3 then
			local clone = FX:WaitForChild("StringEffects").OverheatHit:Clone()
			Util.Debris:AddItem(clone, 1)
			clone.Position = position
			clone.Parent = _WorldOrigin
			clone.Bigflames:Emit(5)
			clone.Smallflames:Emit(5)
			clone.Embers:Emit(3)
			Util.Sound:Play("Lava", position, nil, 1.2 + math.random(-35, 25) / 100, 1)
		end
	else
		local color2

		if buso then
			color2 = buso.Color
		else
			color2 = Color3.new(1, 1, 1)
		end

		local clone = FX:WaitForChild("StringEffects").StringCurveMesh:Clone()
		Util.Debris:AddItem(clone, 5)

		if color2 then
			clone.Color = color2:Lerp(Color3.new(), 0.4)
		end

		clone.Size = createVector(1, 1, 1)
		clone.CFrame = CFrame.new(position) * CFrame.Angles(
			math.rad((math.random(-180, 180))),
			math.rad((math.random(-180, 180))),
			(math.rad((math.random(-180, 180))))
		)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(math.random(3, 4) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = Vector3.new(math.random(20, 25), 0.2, math.random(20, 25)),
				CFrame = clone.CFrame * CFrame.Angles(0, 3.12413936106985, 0),
				Color = color2 and color2:Lerp(Color3.new(), 0.25) or Color3.new(0.380392, 0, 0.568627)
			}
		)
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		clone.Parent = _WorldOrigin
		tween:Play()
		burstEffect(position, color or color2 or nil)
	end
end