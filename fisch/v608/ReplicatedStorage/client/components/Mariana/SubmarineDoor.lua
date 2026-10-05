local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local modules = ReplicatedStorage.shared.modules
require(modules.vessels)
local localPlayer = Players.LocalPlayer
local remoteFunction = Net:RemoteFunction("GetDoorState")
local _ = {
	"Common",
	"Heat",
	"Ice",
	"Deep"
}
local v = Component.new({
	Tag = "SubmarineDoor"
})

local function IsSubmarine(p)
	local parent = p.Parent

	if not (parent and parent:IsA("Model")) then
		return false
	end

	if parent:GetAttribute("IsSubmarine") == true then
		return true, parent:GetAttribute("Tier")
	end

	return false
end

function v:SetState(state2: boolean)
	if self.State == state2 then
		return
	end

	self.State = state2

	if self.Instance:HasTag("Door") and remoteFunction:InvokeServer(self.Instance.Name) == true then
		return
	end

	for _, part in self.Instance:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Transparency = state2 == true and 1 or 0
		part.CanCollide = state2 == false
		part.CanQuery = state2 == false
		part.CanTouch = state2 == false
	end
end

function v:RefreshDoor()
	local character = localPlayer.Character

	if not character then
		return self:SetState(false)
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return self:SetState(false)
	end

	local seatPart = humanoid.SeatPart

	if not seatPart then
		return self:SetState(false)
	end

	local parent = seatPart.Parent
	local tier, v2

	if parent and parent:IsA("Model") and parent:GetAttribute("IsSubmarine") == true then
		tier = parent:GetAttribute("Tier")
		v2 = true
	else
		v2 = false
	end

	if not v2 or tier == nil then
		return self:SetState(false)
	end

	if self.Tier <= tier then
		return self:SetState(true)
	end

	return self:SetState(false)
end

function v:Construct()
	self.Trove = Trove.new()
	self.State = nil
	self.Tier = self.Instance:GetAttribute("SubmarineTier") or 1
end

function v:Start()
	local Reload

	Reload = function()
		self.Trove:Clean()
		local v2 = true
		self.Trove:Add(function()
			v2 = false
		end)
		local humanoid = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")

		if not v2 then
			return
		end

		self.Trove:Add(humanoid.Seated:Connect(function(_: boolean, _)
			self:RefreshDoor()
		end))
		self.Trove:Add(localPlayer.CharacterAppearanceLoaded:Connect(function()
			Reload()
		end))
		self:RefreshDoor()
	end

	Reload()
end

function v.Stop(p)
	p.Trove:Destroy()
end

return v