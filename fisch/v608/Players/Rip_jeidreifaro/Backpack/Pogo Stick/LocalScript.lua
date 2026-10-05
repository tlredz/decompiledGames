local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
local Players2 = game:GetService("Players")
Players = Players2
local RunService2 = game:GetService("RunService")
RunService = RunService2
local Debris2 = game:GetService("Debris")
Debris = Debris2
Animations = {}
Remotes = Tool:WaitForChild("Remotes")
ServerControl = Remotes:WaitForChild("ServerControl")
ClientControl = Remotes:WaitForChild("ClientControl")
local GliderController = require(ReplicatedStorage.client.legacyControllers.Items.GliderController)
Sounds = {
	Hop = Handle:WaitForChild("Hop")
}
Rate = 0.016666666666666666
ToolEquipped = false

function SetAnimation(p, data)
	if p == "PlayAnimation" and data and ToolEquipped and Humanoid then
		for k, v in pairs(Animations) do
			if v.Animation ~= data.Animation then
				continue
			end

			v.AnimationTrack:Stop()
			table.remove(Animations, k)
		end

		local track = Humanoid:LoadAnimation(data.Animation)
		table.insert(Animations, {
			Animation = data.Animation,
			AnimationTrack = track
		})
		track:Play(data.FadeTime, data.Weight, data.Speed)
	elseif p == "StopAnimation" and data then
		for k, v in pairs(Animations) do
			if v.Animation ~= data.Animation then
				continue
			end

			v.AnimationTrack:Stop(data.FadeTime)
			table.remove(Animations, k)
		end
	end
end

function KeyPressed(p, down)
	InvokeServer("KeyPressed", {
		Key = p,
		Down = down
	})
end

function CheckIfAlive()
	if Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent then
		return true
	end

	return false
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
raycastParams.RespectCanCollide = true
raycastParams.CollisionGroup = "Players"

function HandleJump(p)
	if CheckIfAlive() then
		Character:SetAttribute("PogoStick", nil)
		Character:SetAttribute("PogoStick2", nil)
		Character:SetAttribute("PogoStickJump", nil)
		Humanoid.HipHeight = 0
	end

	for _, v in pairs({ JumpMonitor, StateChanged }) do
		if v then
			v:disconnect()
		end
	end

	if not (p and CheckIfAlive() and ToolEquipped) then
		return
	end

	Humanoid.HipHeight = 0.72
	Character:SetAttribute("PogoStick2", 0.25)
	Character:SetAttribute("PogoStickJump", 2)
	local v = false
	local now = 0

	local function CanJump()
		if tick() - now < 1 or v or GliderController.LastGliding and tick() - GliderController.LastGliding < 1 then
			return false
		end

		if Humanoid:GetState() == Enum.HumanoidStateType.Running or Humanoid:GetState() == Enum.HumanoidStateType.Landed or Humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics then
			return true
		end

		local rootPart = Humanoid.RootPart

		if rootPart then
			return workspace:Raycast(rootPart.Position, createVector(0, -2.5, 0), raycastParams) ~= nil
		end

		return false
	end

	JumpMonitor = Humanoid.Changed:connect(function(p2)
		if p2 == "Jump" then
			local _ = Humanoid:GetState().Name
			local _ = Torso.Velocity * createVector(0, 1, 0)

			if not Humanoid.Jump or not CanJump() or v then
				Humanoid.Jump = false
				return
			end

			now = tick()
			v = true
			Character:SetAttribute("PogoStick2", nil)
			Character:SetAttribute("PogoStick", 16)
			local clone = Sounds.Hop:Clone()
			clone.Pitch = math.random(1250, 1750) * 0.001
			Debris:AddItem(clone, 2)
			clone.Parent = Handle
			clone:Play()
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		else
			if p2 ~= "SeatPart" or not (Humanoid and Humanoid.SeatPart or Handle:IsGrounded()) then
				return
			end

			Tool.Parent = Player.Backpack
		end
	end)
	StateChanged = Humanoid.StateChanged:connect(function(_, p2)
		local name = p2.Name
		local _ = Torso.Velocity * createVector(0, 1, 0)

		if name == "Swimming" then
			Tool.Parent = Player.Backpack
		elseif name ~= "Jumping" and name ~= "Freefall" and v then
			Character:SetAttribute("PogoStick2", 0.25)
			Character:SetAttribute("PogoStick", nil)
			v = false
		end
	end)
end

function Equipped(p)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	ToolEquipped = true
	raycastParams.FilterDescendantsInstances = { Character }

	if not CheckIfAlive() then
		return
	end

	if GliderController.LastGliding and tick() - GliderController.LastGliding < 0.25 then
		Humanoid:UnequipTools()
		return
	end

	PlayerMouse = p
	PlayerMouse.KeyDown:connect(function(p2)
		KeyPressed(p2, true)
	end)
	PlayerMouse.KeyUp:connect(function(p2)
		KeyPressed(p2, false)
	end)
	Spawn(function()
		HandleJump(true)
	end)
end

function Unequipped()
	for _, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end

	Spawn(function()
		HandleJump(false)
	end)
	Animations = {}
	ToolEquipped = false
end

function InvokeServer(p, p2)
	local v = nil
	pcall(function()
		v = ServerControl:InvokeServer(p, p2)
	end)
	return v
end

function OnClientInvoke(p, object)
	if p == "PlayAnimation" and object and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", object)
	elseif p == "StopAnimation" and object then
		SetAnimation("StopAnimation", object)
	elseif p == "PlaySound" and object then
		object:Play()
	elseif p == "StopSound" and object then
		object:Stop()
	elseif p == "MouseData" then
		return PlayerMouse and {
			Position = PlayerMouse.Hit.p,
			Target = PlayerMouse.Target
		} or nil
	end
end

Delay(0, function()
	if ToolEquipped then
		return
	end

	HandleJump(false)
end)
ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)