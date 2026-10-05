game:GetService("CollectionService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local OilDrillModule = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()

function OilDrillModule.Init()
	Connections()
end

function AnimateDrillBit(instance)
	local primaryPart = instance.Drill.PrimaryPart
	local cFrame = primaryPart.CFrame
	local v = math.random() * 3.141592653589793 * 2
	task.spawn(function()
		while instance.Parent do
			RunService.RenderStepped:Wait()

			if instance:GetAttribute("Destroyed") then
				break
			end

			local now = tick()
			local v2 = -2160 * (now % 360)
			local cframe = CFrame.Angles(0, math.rad(v2), 0)
			local v3 = math.sin(now * 2 + v) * 4 / 2
			local cframe2 = CFrame.new(0, v3, 0)
			local v4 = math.noise(os.clock() * 5 * 1.7777, 1, 0) * 0.2
			local v5 = math.noise(os.clock() * 5 * 1.5555, 3, 0) * 0.2
			local cframe3 = CFrame.new(v4, 0, v5)
			primaryPart.CFrame = cFrame * cframe2 * cframe3 * cframe
		end
	end)
end

function AnimateOilLevel(instance)
	local Y = instance.Body.Gauge:FindFirstChild("Oil").Position.Y
	instance:GetAttributeChangedSignal("FillPercent"):Connect(function()
		local fillPercent = instance:GetAttribute("FillPercent")

		if fillPercent then
			for _, child in pairs(instance.Body.Gauge:GetChildren()) do
				if child.Name ~= "Oil" then
					continue
				end

				child.Size = Vector3.new(child.Size.X, 0.2 + 4.5 * fillPercent, child.Size.Z)
				local v = Y + fillPercent * 4.5 / 2
				local v2 = child.Position.Y - v
				child.CFrame -= Vector3.new(0, v2, 0)
			end
		end
	end)
end

function OpenOilDoor(p)
	local outputDoor = p.Body.OutputDoor
	local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false, 0)
	TweenService:Create(outputDoor.PrimaryPart, tweenInfo, {
		CFrame = outputDoor.PrimaryPart.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
	}):Play()
	task.wait(2)
	TweenService:Create(outputDoor.PrimaryPart, tweenInfo, {
		CFrame = outputDoor.PrimaryPart.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
	}):Play()
end

function Connections()
	Client.Utility.ForAllTagged("OilDrill", function(instance)
		if instance.Parent ~= workspace.Structures or instance:GetAttribute("Destroyed") then
			return
		end

		AnimateDrillBit(instance)
		AnimateOilLevel(instance)
	end)
	Client.Events.AnimateOilDrillDoor:Connect(function(p)
		OpenOilDoor(p)
	end)
end

return OilDrillModule