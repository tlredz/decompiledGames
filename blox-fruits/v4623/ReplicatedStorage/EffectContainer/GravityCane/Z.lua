local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService2 = game:GetService("TweenService")
game:GetService("RunService")
local _ = Util.RocksModule
local destroyAfter = Util.DestroyAfter
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage.FX)
local gravityCane = FX:WaitForChild("GravityCane")

local function gravitytiger(player, hold, hrp)
	local cFrame = hrp.CFrame
	local clone = gravityCane.emit1:Clone()
	local clone2 = gravityCane.StartUp:Clone()
	local clone3 = gravityCane.strike:Clone()
	local clone4 = gravityCane.SpiralWind:Clone()
	clone.CFrame = cFrame * CFrame.new(0, 0, -4.5)
	clone.Parent = _WorldOrigin
	clone3.CFrame = cFrame * CFrame.new(0, 0, -4.5)
	clone3.Parent = _WorldOrigin
	clone2.CFrame = cFrame * CFrame.new(0, -2, 0)
	clone2.Parent = _WorldOrigin

	for _, child in ipairs(clone2.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	local v = Util.Sound:Play("GravityCane_Sound2", cFrame)
	Util.Sound:FadeOut(v, 1)

	repeat
		wait()
	until hold.Value == false or not hold:IsDescendantOf(workspace)

	repeat
		wait()
	until hrp:GetAttribute("GravityCaneZPosition")

	local cframe = CFrame.new(hrp.Position, hrp:GetAttribute("GravityCaneZPosition"))
	Util.Sound:Play("GravityCane_Sound", cframe)
	clone.CFrame = cframe * CFrame.new(0, 0, -4.5)
	clone3.CFrame = cframe * CFrame.new(0, 0, -4.5)
	clone2.CFrame = cframe * CFrame.new(0, -2, 0)
	destroyAfter(clone, 3)
	destroyAfter(clone3, 3)
	destroyAfter(clone2, 3)
	TweenService2:Create(
		clone4,
		TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false, 0),
		{
			Size = createVector(91.061, 91.655, 91.45),
			Transparency = 1,
			CFrame = clone4.CFrame * CFrame.Angles(0, 0, 2.8797932657906435)
		}
	):Play()
	TweenService2:Create(
		clone2.PointLight,
		TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
		{
			Brightness = 25
		}
	):Play()

	for _, child in ipairs(clone3.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	task.wait(0.1)
	clone4.CFrame = cframe
	clone4.Parent = _WorldOrigin
	destroyAfter(clone4, 0.7)
	task.spawn(function()
		wait(0.1)

		if player == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(35, 90, 0, 0.8)
			local clone5 = gravityCane.LTN:Clone()
			clone5.Parent = game:GetService("Lighting")
			destroyAfter(clone5, 2)
			TweenService:Create(clone5, TweenInfo.new(0.1), {
				TintColor = Color3.fromRGB(99, 71, 255),
				Brightness = -0.5,
				Contrast = 1,
				Saturation = -1
			}):Play()
			wait(0.05)
			TweenService:Create(clone5, TweenInfo.new(0.05), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			}):Play()
			wait(0.05)
			TweenService:Create(clone5, TweenInfo.new(0.1), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = -0.3,
				Contrast = 1,
				Saturation = -1
			}):Play()
			wait(0.05)
			TweenService:Create(clone5, TweenInfo.new(0.05), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			}):Play()
		end
	end)

	for _, child in ipairs(clone.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	for _, child in ipairs(clone.Attachment2:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	clone.Attachmentfar.rad:Emit(5)
	wait(0.1)
	TweenService2:Create(
		clone2.PointLight,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
		{
			Brightness = 0
		}
	):Play()

	for _, child in ipairs(clone3.Attachment2:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end
end

return function(data)
	local hold = data.hold
	local hrp = data.hrp

	if (hrp.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	gravitytiger(data.player, hold, hrp)
end