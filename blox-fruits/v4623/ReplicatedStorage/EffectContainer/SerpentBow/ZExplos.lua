local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local sound = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1500 then
		return
	end

	local connections = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function endmove()
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end
	end

	if p.Arg == 1 then
		local clone = FX:WaitForChild("SerpentBow").Explos:Clone()
		clone:WaitForChild("Ball")
		clone:SetPrimaryPartCFrame(cFrame)
		local tween = TweenService:Create(
			clone.Ball,
			TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{
				Size = createVector(67.222, 70.468, 70.4),
				Transparency = 1,
				Color = Color3.fromRGB(137, 107, 255)
			}
		)
		local tween2 = TweenService:Create(
			clone.ExplosSphere,
			TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{
				Size = createVector(53.264, 56.192, 52.817),
				Transparency = 0.4
			}
		)
		table.insert(connections, tween2.Completed:Connect(function()
			TweenService:Create(
				clone.ExplosSphere,
				TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Size = createVector(41.982, 44.29, 41.63),
					Transparency = 1
				}
			):Play()
		end))
		local tween3 = TweenService:Create(
			clone.spike,
			TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{
				Size = createVector(64.996, 64.743, 65.371),
				Transparency = 1,
				Color = Color3.fromRGB(68, 68, 68)
			}
		)
		local tween4 = TweenService:Create(
			clone.spike2,
			TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 2),
			{
				Size = createVector(64.996, 64.743, 65.371),
				Transparency = 1,
				Color = Color3.fromRGB(50, 50, 50)
			}
		)
		coroutine.resume(coroutine.create(function()
			local lastTime = tick()

			while tick() - lastTime < 1 do
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:wait()
				clone.ExplosSphere.CFrame = clone.ExplosSphere.CFrame * CFrame.Angles(0, 0.08726646259971647, 0)
			end

			clone:Destroy()
			endmove() -- equivalent call inferred; original call site unknown
		end))
		clone.Parent = _WorldOrigin
		tween:Play()
		clone:FindFirstChild("Ball").Attachment.ParticleEmitter:Emit(200)
		tween2:Play()
		tween3:Play()
		tween4:Play()
		sound:Play("MainExplosion", cFrame, nil, 0.8, 2)
		sound:Play("BackdropExplosion", cFrame, nil, 1.5, 1.5)
		local character = game.Players.LocalPlayer.Character

		if character ~= nil and (character:FindFirstChild("HumanoidRootPart").Position - cFrame.Position).magnitude <= 80 then
			Util.CameraShaker:ShakeOnce(3, 9, 0.2, 0.8)
		end
	else
		local clone = FX:WaitForChild("SerpentBow").Ball:Clone()
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		Util.Debris:AddItem(clone, 1)
		sound:Play("gloopy", cFrame, nil, math.random(1, 8) / 10 + 0.8, 0.85)
		clone.Attachment.ParticleEmitter:Emit(35)
		local tween = TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = createVector(5.295, 5.551, 5.546),
			Transparency = 1
		})
		local completedConnection = nil
		completedConnection = tween.Completed:Connect(function()
			wait(0.3)
			tween:Destroy()
			completedConnection:Disconnect()
		end)
	end
end