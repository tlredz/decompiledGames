local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local jumpPads = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Misc"):WaitForChild("JumpPads")
local v = {
	Default = { "rbxassetid://85163949920258", 1 },
	Trampoline = { "rbxassetid://75001064846226", 1 },
	["Bounce House"] = { "rbxassetid://139519788113881", 1 },
	["Shady Chicken Sandwich"] = { "rbxassetid://99488347318534", 1.25 },
	["Spider Web"] = { "rbxassetid://88449856112147", 1.25 },
	["Jolly Man"] = { "rbxassetid://111488886881644", 1.5 },
	["Flamingo Floatie"] = { "rbxassetid://139519788113881", 1 }
}
local v2 = {
	Default = { "rbxassetid://17835965985", 1 },
	Trampoline = { "rbxassetid://79142560912255", 1 },
	["Bounce House"] = { "rbxassetid://18963214636", 1 },
	["Shady Chicken Sandwich"] = { "rbxassetid://138205332923098", 1.25 },
	["Spider Web"] = { "rbxassetid://128812513158754", 1.25 },
	["Flamingo Floatie"] = { "rbxassetid://130086876465618", 1 }
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class:CreateJumpPadVisual(value, p)
	local clone = (jumpPads:FindFirstChild(value or "Default") or jumpPads.Default):Clone()
	clone:ScaleTo(clone:GetScale() * p.X / 10)

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
	end

	return clone
end

function class:_ObjectAdded(instance)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function get_cframe()
		return instance:GetPivot() * CFrame.new(0, 0, instance.Size.Z / 2)
	end

	local viewModelName = instance:GetAttribute("ViewModelName")
	local objectID = instance:GetAttribute("ObjectID")
	local v3 = v2[viewModelName] or v2.Default
	local v4 = v[viewModelName] or v.Default
	instance:SetAttribute("SoundID", v3[1])
	instance:SetAttribute("SoundVolume", v3[2])
	Utility:CreateSound(v4[1], v4[2], 1.25, instance, true, 5)
	local folder = self:CreateJumpPadVisual(viewModelName, instance.Size)
	folder.Parent = instance
	local wrap = FighterController:GetWrap(objectID)

	if wrap then
		WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(folder), wrap, true)
	end

	local v5 = folder:GetScale() * 1.25
	local scale = folder:GetScale()
	local cframe = CFrame.Angles(0, 0, 0.17453292519943295 * (math.random() - 0.5))
	local lastTime = tick()

	while tick() < lastTime + 0.25 do
		local v6 = 1 - (1 - (tick() - lastTime) / 0.25) ^ 3
		folder:ScaleTo(v5 + (scale - v5) * v6)
		folder:PivotTo(get_cframe() * cframe:Lerp(CFrame.identity, v6))
		RunService.RenderStepped:Wait()
	end

	folder:ScaleTo(scale)
	folder:PivotTo(get_cframe())

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = instance
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
		part.Anchored = false
	end
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("JumpPadHitbox"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v3 in pairs(CollectionService:GetTagged("JumpPadHitbox")) do
		task.defer(self._ObjectAdded, self, v3)
	end
end

return class._new()