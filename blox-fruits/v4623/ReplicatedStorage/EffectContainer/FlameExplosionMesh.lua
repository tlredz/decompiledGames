workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale
	local duration = data.Duration or 0.75
	local magnitude = (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 300 + scale * 3 < magnitude then
		return
	end

	local clone = game.ReplicatedStorage.Assets.Models.FireMeshExplosion:Clone()
	clone.Parent = _WorldOrigin
	clone:SetPrimaryPartCFrame(cFrame)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function iterate(fn)
		for _, child in pairs(clone:GetChildren()) do
			fn(child)
		end
	end

	local function fn(instance)
		if instance.Name == "Root" then
			TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Circular), {
				Size = instance.Size.unit * scale * 1.66,
				CFrame = instance.CFrame * CFrame.Angles(0, math.sign(math.random() - 0.5) * 0.5, 0)
			}):Play()
			delay(duration * 0.6, function()
				TweenService:Create(instance, TweenInfo.new(duration * 0.4, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end)
		elseif instance.Name == "Shock" then
			TweenService:Create(instance, TweenInfo.new(duration * 0.4, Enum.EasingStyle.Quad), {
				Size = instance.Size.unit * scale + Vector3.new(0, scale * 1.5, 0)
			}):Play()
			delay(duration * 0.4, function()
				TweenService:Create(
					instance,
					TweenInfo.new(duration * 0.33, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Size = instance.Size.unit * Vector3.new(scale * 5, 0, scale * 5),
						CFrame = instance.CFrame * CFrame.new(0, -scale / 10, 0),
						Transparency = 1
					}
				):Play()
			end)
		elseif instance.Name == "Wind" then
			local function effect(instance2, p)
				TweenService:Create(instance2, TweenInfo.new(duration * 0.8 * (1 - p * 0.2), Enum.EasingStyle.Quad), {
					Size = instance2.Size.unit * scale * 2.5 * (1 - p * 0.2)
				}):Play()
				TweenService:Create(instance2, TweenInfo.new(duration * 0.8 * (1 - p * 0.2), Enum.EasingStyle.Linear), {
					CFrame = instance2.CFrame * CFrame.new(0, (p - 1) * scale * 0.125, 0) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					)
				}):Play()
				delay(duration * 0.6 * (1 - p * 0.2), function()
					TweenService:Create(instance2, TweenInfo.new(duration * 0.4, Enum.EasingStyle.Quad), {
						Transparency = 1,
						Size = Vector3.new(scale * 1.75 * (1 - p * 0.1), 0, scale * 1.75 * (1 - p * 0.1))
					}):Play()
				end)
			end

			effect(instance, 1)
			local clone2 = instance:Clone()
			clone2.CFrame = instance.CFrame
			clone2.Parent = clone
			effect(clone2, 2)
			local clone3 = instance:Clone()
			clone3.CFrame = instance.CFrame
			clone3.Parent = clone
			effect(clone3, 3)
		end
	end

	iterate(fn) -- equivalent call inferred; original call site unknown
	wait(duration)
	clone:Destroy()
end