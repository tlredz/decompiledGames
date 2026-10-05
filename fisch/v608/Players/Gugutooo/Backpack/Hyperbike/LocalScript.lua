local createVector = vector.create
Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
local Players2 = game:GetService("Players")
Players = Players2
local RunService2 = game:GetService("RunService")
RunService = RunService2
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
Camera = Workspace.CurrentCamera
Animations = {}
LocalObjects = {}
ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")
ToolEquipped = false
local renderSteppedConnection = nil
local moveDirectionChangedConnection = nil
local jumpRequestConnection = nil

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

			v.AnimationTrack:Stop()
			table.remove(Animations, k)
		end
	end
end

function CheckIfAlive()
	if Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent then
		return true
	end

	return false
end

function Equipped(_)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	ToolEquipped = true

	if not CheckIfAlive() then
		return
	end

	local v = createVector(0, 0, 0)
	moveDirectionChangedConnection = Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		local _, v2 = workspace.CurrentCamera.CFrame:ToOrientation()
		local pointToObjectSpace = CFrame.fromOrientation(0, v2, 0):PointToObjectSpace(Humanoid.MoveDirection)

		if (pointToObjectSpace - v).Magnitude > 0.001 then
			v = pointToObjectSpace
			InvokeServer("MoveChanged", pointToObjectSpace)
		end
	end)
	jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
		InvokeServer("JumpRequest")
	end)
	Humanoid:ChangeState(Enum.HumanoidStateType.None)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end

function Unequipped()
	ToolEquipped = false
	LocalObjects = {}

	for _, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end

	local v = { renderSteppedConnection, jumpRequestConnection, moveDirectionChangedConnection }

	for _, v2 in pairs(v) do
		if v2 then
			v2:disconnect()
		end
	end

	Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	Animations = {}
end

function InvokeServer(p, p2)
	pcall(function()
		return (ServerControl:InvokeServer(p, p2))
	end)
end

function OnClientInvoke(p, object)
	if p == "PlayAnimation" and object and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", object)
		return
	end

	if p == "StopAnimation" and object then
		SetAnimation("StopAnimation", object)
		return
	end

	if p == "PlaySound" and object then
		object:Play()
		return
	end

	if p == "StopSound" and object then
		object:Stop()
		return
	end

	if p == "MousePosition" then
		return {
			Position = PlayerMouse.Hit.p,
			Target = PlayerMouse.Target
		}
	end

	if p == "SetLocalTransparencyModifier" and object and ToolEquipped then
		pcall(function()
			local v = false

			for _, v2 in pairs(LocalObjects) do
				if v2 == object then
					v = true
				end
			end

			if not v then
				table.insert(LocalObjects, object)

				if renderSteppedConnection then
					renderSteppedConnection:disconnect()
				end

				renderSteppedConnection = RunService.RenderStepped:connect(function()
					for k, v2 in pairs(LocalObjects) do
						if v2.Object and v2.Object.Parent then
							local localTransparencyModifier = v2.Object.LocalTransparencyModifier

							if not v2.AutoUpdate and (localTransparencyModifier == 1 or localTransparencyModifier == 0) or v2.AutoUpdate then
								v2.Object.LocalTransparencyModifier = v2.Transparency
							end
						else
							table.remove(LocalObjects, k)
						end
					end
				end)
			end
		end)
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)