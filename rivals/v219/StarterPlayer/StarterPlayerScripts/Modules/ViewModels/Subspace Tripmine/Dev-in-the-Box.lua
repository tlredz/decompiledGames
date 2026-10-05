local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local SubspaceTripmine = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Subspace Tripmine"])
local devintheBoxExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("DevintheBoxExplosionEffect")
local devintheBox = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("Dev-in-the-Box")
local object = setmetatable({}, SubspaceTripmine)
object.__index = object

function object.new(...)
	local self = setmetatable(SubspaceTripmine.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(p, position)
	local cframe = position:FuzzyEq(workspace.CurrentCamera.CFrame.Position) and CFrame.new(position) or CFrame.new(
		position,
		(Vector3.new(workspace.CurrentCamera.CFrame.X, position.Y, workspace.CurrentCamera.CFrame.Z))
	)
	local v = math.random() < 0.5
	local clone = devintheBox:Clone()
	clone.Dev.SenseiWarrior.Transparency = v and 0 or 1
	clone.Dev.Nosniy.Transparency = v and 1 or 0
	clone:PivotTo(cframe + createVector(0, 0.5, 0))
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 4)
	WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clone), p.ClientItem:GetWrap(), true)
	Utility:CreateSound("rbxassetid://86639533276627", 0.875, 1 + 0.1 * math.random(), position, true, 10)
	Utility:CreateSound("rbxassetid://121003602924254", 1.25, 1 + 0.1 * math.random(), position, true, 10)
	local clone2 = devintheBoxExplosionEffect:Clone()
	clone2.CFrame = CFrame.new(position)
	clone2.Parent = workspace
	BetterDebris:AddItem(clone2, 5)
	Utility:PlayParticles(clone2)
	pcall(function()
		task.delay(3, function()
			clone.Primary.Anchored = false
		end)
		clone.AnimationController:LoadAnimation(clone.Animation):Play()
		wait(0.1)
		clone.top.Lid.Delete:Destroy()
		clone.top.Lid.Velocity = (Random.new():NextUnitVector() * createVector(1, 0, 1) + createVector(0, 4, 0)) * (15 + 25 * math.random())
		clone.top.Lid.RotVelocity = CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		).LookVector * (10 + 10 * math.random())
	end)
end

function object:_Init() end

return object