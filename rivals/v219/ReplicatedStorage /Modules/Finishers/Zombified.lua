local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local v = {
	Color = Color3.fromRGB(45, 117, 0)
}
local v2 = { "rbxassetid://76551122205423", "rbxassetid://121329175458153", "rbxassetid://86178802108357" }
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer(...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	rootPart.Anchored = true
	wait(9.9)
	rootPart.Anchored = false
	Ragdoll.PlayServer(self, ...)
end

function object:PlayClient()
	for _, part in pairs(self:_GetObjects()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, tweenInfo, v):Play()
		end
	end

	if self._is_humanoid then
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://84937348544434"
		local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

		if success then
			result:Play(0)
		end
	end

	self:CreateSound("rbxassetid://113907213192044", 1.5, 1, nil, true, 15)
	self:CreateSound("rbxassetid://103180063975943", 0.25, 0.5 + 0.1 * math.random(), nil, true, 15)
	self:CreateSound("rbxassetid://84523504613156", 1, 1, nil, true, 15)
	wait(0.8)
	self:CreateSound("rbxassetid://99312045046993", 1, 1, nil, true, 15)
	wait(0.8)
	self:CreateSound("rbxassetid://109142509049932", 1, 1, nil, true, 15)
	wait(2.4)
	local table2 = Utility:CloneTable(v2)

	for _ = 1, #v2 do
		self:CreateSound(table.remove(table2, math.random(#table2)), 0.5, 0.5 + 0.1 * math.random(), nil, true, 5)
		wait(5.7 / #v2)
	end

	self:CreateSound("rbxassetid://126800102156089", 0.5, 0.75, nil, true, 5)
end

function object:_Init() end

return object