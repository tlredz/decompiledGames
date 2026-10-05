local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local localPlayer = game.Players.LocalPlayer
local v = Component.new({
	Tag = "OscarsLockerDoor"
})

function v:Construct()
	self.trove = Trove.new()
end

function v:SetVisibility(p2)
	if p2 then
		self.Instance.Transparency = 1
		self.Instance.CanCollide = false

		for _, descendant in self.Instance:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
				descendant.CanCollide = false
			elseif descendant:IsA("Highlight") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				descendant.Enabled = false
			end
		end
	else
		self.Instance.Transparency = 1
		self.Instance.CanCollide = true

		for _, descendant in self.Instance:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 0
				descendant.CanCollide = true
			elseif descendant:IsA("Highlight") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				descendant.Enabled = true
			end
		end
	end
end

function v:Start()
	if localPlayer.Character then
		self:SetVisibility(localPlayer.Character:GetAttribute("BlockDeterioration"))
	end
end

function v.Stop(p)
	p.trove:Destroy()
end

function v.UpdateAll(p)
	for _, v2 in v:GetAll() do
		v2:SetVisibility(p)
	end
end

local blockDeteriorationChangedConnection = nil

local function setupCharacter(character)
	if blockDeteriorationChangedConnection then
		blockDeteriorationChangedConnection:Disconnect()
	end

	blockDeteriorationChangedConnection = character:GetAttributeChangedSignal("BlockDeterioration"):Connect(function()
		v.UpdateAll(character:GetAttribute("BlockDeterioration"))
	end)
	v.UpdateAll(character:GetAttribute("BlockDeterioration"))
end

localPlayer.CharacterAdded:Connect(setupCharacter)

if localPlayer.Character then
	setupCharacter(localPlayer.Character)
end

return v