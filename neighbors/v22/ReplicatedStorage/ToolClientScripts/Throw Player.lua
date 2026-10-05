local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Tool)
local _ = {
	MaxChargeTime = 2,
	RayDistance = 1000
}
local ThrowPlayer = {}
local animation = Instance.new("Animation", script)
animation.Name = "ThrowPlayerAnimation"
animation.AnimationId = "rbxassetid://13705489603"

function ThrowPlayer:Unequipped()
	self:StopHoldingTrack(true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isHoldingCharacter(player)
	return player.Character:GetAttribute("Carrying") ~= nil
end

function ThrowPlayer:UpdateRadialVisibility(flag: boolean?)
	if self.ThrowGui then
		if flag then
			self.ThrowGui.Enabled = false
		else
			self.ThrowGui.Enabled = isHoldingCharacter(self.Player)
		end
	end
end

function ThrowPlayer:StopHoldingTrack(flag: boolean?)
	if self.HoldTrack then
		self.HoldTrack:Stop(0.1)
		self.HoldTrack = nil
	end

	self:UpdateRadialVisibility(flag)
end

function ThrowPlayer:GetHitPosition()
	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = self.Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	return viewportPointToRay.Origin + viewportPointToRay.Direction * 1000
end

function ThrowPlayer:ActivateRadial()
	while self.ThrowGui and self.TimeStartedToHold and self.ThrowGui.Parent and isHoldingCharacter(self.Player) do
		local v = math.min(1, (os.clock() - self.TimeStartedToHold) / 2)
		self.ThrowGui.RoundMeter.Progress:SetAttribute("Value", v)
		task.wait()
	end
end

local function onMouseDown(player)
	local animator = player.Humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	if player.Tool.Parent == player.Character and isHoldingCharacter(player.Player) then
		player.TimeStartedToHold = os.clock()

		if not (player.Player:GetAttribute("VR") or player.HoldTrack) then
			player.HoldTrack = animator:LoadAnimation(animation)

			if player.HoldTrack then
				player.HoldTrack:Play(2)
			end
		end

		player:UpdateRadialVisibility()
		player:ActivateRadial()
	end
end

local function onMouseUp(player)
	if player.Tool.Parent == player.Character and isHoldingCharacter(player.Player) and player.TimeStartedToHold then
		local v = (os.clock() - player.TimeStartedToHold) / 2
		player:FireEvent("ThrowRequest", player:GetHitPosition(), v)
	end

	player.TimeStartedToHold = nil
	player:StopHoldingTrack(true)
end

function ThrowPlayer:Initialize()
	local head = self.Character:WaitForChild("Head", 5)

	if not head then
		return
	end

	self.Camera = workspace.CurrentCamera
	self.ThrowGui = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("ThrowGui"):Clone()
	self.ThrowGui.Enabled = false
	self.ThrowGui.Adornee = head
	self.ThrowGui.Parent = self.Tool
	local mouse = self.Player:GetMouse()
	mouse.Button1Down:Connect(function()
		onMouseDown(self)
	end)
	mouse.Button1Up:Connect(function()
		onMouseUp(self)
	end)
	self.Player:GetAttributeChangedSignal("State"):Connect(function()
		self:StopHoldingTrack()
	end)
end

function ThrowPlayer:Destroyed()
	self:StopHoldingTrack()
end

return ThrowPlayer