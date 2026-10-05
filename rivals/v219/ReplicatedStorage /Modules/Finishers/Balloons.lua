local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Finisher = require(ReplicatedStorage.Modules.Finisher)
require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer()
	self:_AnchorModel(0, false)
	self:_Ragdoll()
	local parts = {}

	for _, part in pairs(self:_GetObjects()) do
		if part:IsA("BasePart") and part.Name ~= "Head" and part.Name ~= "UpperTorso" then
			table.insert(parts, part)
		end
	end

	local parent = parts[math.random(#parts)]

	if not parent then
		return
	end

	self:CreateSound("rbxassetid://130365736768706", 1.25, 1, nil, true, 5)
	self:CreateSound("rbxassetid://95957584341529", 1.25, 2 + 0.25 * math.random(), nil, true, 5)
	local attachment = Instance.new("Attachment")
	attachment.Parent = parent
	table.insert(self._destroy_these, attachment)

	for _ = 1, 3 do
		local v2 = Random.new():NextUnitVector() * createVector(1, 0, 1)
		local clone = script.Balloon:Clone()
		clone.Color = Color3.fromHSV(math.random(), 1, 1)
		clone.CFrame = parent.CFrame + createVector(0, 4, 0) + v2 * 2
		clone.RopeConstraint.Attachment1 = attachment
		clone.Parent = parent
		table.insert(self._destroy_these, clone)

		if CONSTANTS.IS_SERVER then
			clone:SetNetworkOwner(nil)
		end

		wait(0.1)
	end
end

function object:_Init() end

return object