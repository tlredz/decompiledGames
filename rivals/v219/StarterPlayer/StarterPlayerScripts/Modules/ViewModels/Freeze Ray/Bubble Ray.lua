local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local FreezeRay = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Freeze Ray"])
local bubbleRayExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("BubbleRayExplosionEffect")
local v = {
	"rbxassetid://6928709440",
	"rbxassetid://6928709814",
	"rbxassetid://6928710129",
	"rbxassetid://6928710411",
	"rbxassetid://6928710904",
	"rbxassetid://6928711244"
}
local object = setmetatable({}, FreezeRay)
object.__index = object

function object.new(...)
	local self = setmetatable(FreezeRay.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(_, position, p)
	local clone = bubbleRayExplosionEffect:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)

	for _ = 1, 8 do
		Utility:CreateSound(v[math.random(#v)], 0.75, 1 + 0.2 * math.random(), clone, true, 10)
	end

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 8)
		end
	end

	Utility:PlayParticles(clone.Attachment)
end

function object:_Init() end

return object