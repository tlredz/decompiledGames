local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage.Util.ScaleParticle)
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local _ = workspace.Map
require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local v = { TweenInfo.new(0.1, Enum.EasingStyle.Back) }

local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.CFrame = cFrame

	if p then
		local ResizeModel = require(game.ReplicatedStorage.Util.ResizeModel)
		ResizeModel(clone, p)
		clone.Size *= p
	end

	return clone
end

local ResizeModel = require(game.ReplicatedStorage.Util.ResizeModel)
ResizeModel(script.ice, 4)
script.ice.Size *= 4
local random = Random.new()
return function(data)
	local player = data.player
	local cFrame = data.CFrame

	if not data.RespectHeight then
		local vector2 = Vector3.new(cFrame.X, -3.8, cFrame.Z)
		cFrame = CFrame.new(vector2, vector2 + cFrame.LookVector)
	end

	if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.Position - cFrame.p).magnitude > 750 + (not data.Scale and 0 or data.Scale * 500 or 0) then
			return
		end
	elseif (workspace.CurrentCamera.CFrame.Position - cFrame.p).magnitude > 750 + (not data.Scale and 0 or data.Scale * 500 or 0) then
		return
	end

	local cFrame2 = cFrame * CFrame.Angles(0, Random.new():NextNumber(0, 3.14), 0)
	local ice2 = script.ice
	local scale = data.Scale
	local clone = ice2:Clone()
	clone.CFrame = cFrame2

	if scale then
		local ResizeModel2 = require(game.ReplicatedStorage.Util.ResizeModel)
		ResizeModel2(clone, scale)
		clone.Size *= scale
	end

	if data.NonCollide then
		clone.CanCollide = false
	else
		local play = Sound:Play("YETI_IceFloor_Create_04_V2", cFrame.Position)
		play.RollOffMinDistance = 10 * (data.Scale or 1)
	end

	local size = clone.Size
	clone.Size = size / 2 * random:NextNumber(1, 2)

	if player:GetAttribute("RedYeti") then
		clone.Transparency = 1
	end

	Util.SetParentOverrideWithColor(clone, workspace, player, "YetiFruitVFXColor")
	TweenService:Create(clone, v[1], {
		Size = size
	}):Play()

	if not player:GetAttribute("RedYeti") then
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	task.delay(1.75 * (not data.Scale and 1 or data.Scale * 9 or 1), function()
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(1 * (data.Scale or 1), Enum.EasingStyle.Linear, Enum.EasingDirection.In),
			{
				Size = createVector(0, 0, 0)
			}
		)
		tween.Completed:Connect(function()
			clone.Transparency = 1
			clone.CanCollide = false
			clone.CanQuery = false
			task.wait(1)
			clone:Destroy()
		end)
		tween:Play()
	end)
end