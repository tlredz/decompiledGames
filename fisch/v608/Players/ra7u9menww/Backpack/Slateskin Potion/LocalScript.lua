Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
local Players2 = game:GetService("Players")
Players = Players2
local RunService2 = game:GetService("RunService")
RunService = RunService2
local Workspace = game:GetService("Workspace")
Camera = Workspace.CurrentCamera
Animations = {}
LocalObjects = {}
ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")
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

			v.AnimationTrack:Stop()
			table.remove(Animations, k)
		end
	end
end

function DisableJump(p)
	if PreventJump then
		PreventJump:disconnect()
	end

	if p then
		PreventJump = Humanoid.Changed:connect(function(p2)
			if p2 == "Jump" then
				Humanoid.Jump = false
			end
		end)
	end
end

function CheckIfAlive()
	if Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent then
		return true
	end

	return false
end

function Equipped(data)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	ToolEquipped = true

	if not CheckIfAlive() then
		return
	end

	PlayerMouse = Player:GetMouse()
	data.Button1Down:connect(function()
		InvokeServer("Button1Click", {
			Down = true
		})
	end)
	data.Button1Up:connect(function()
		InvokeServer("Button1Click", {
			Down = false
		})
	end)
	data.Button2Down:connect(function()
		InvokeServer("Button2Click", {
			Down = true
		})
	end)
	data.Button2Up:connect(function()
		InvokeServer("Button2Click", {
			Down = false
		})
	end)
	data.KeyDown:connect(function(p)
		InvokeServer("KeyPress", {
			Key = p,
			Down = true
		})
	end)
	data.KeyUp:connect(function(p)
		InvokeServer("KeyPress", {
			Key = p,
			Down = false
		})
	end)
	data.Move:connect(function()
		InvokeServer("MouseMove", {
			Position = data.Hit.p,
			Target = data.Target
		})
	end)
end

function Unequipped()
	ToolEquipped = false
	LocalObjects = {}

	for _, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end

	for _, v in pairs({ PreventJump, ObjectLocalTransparencyModifier }) do
		if v then
			v:disconnect()
		end
	end

	Animations = {}
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

	if p == "DisableJump" then
		DisableJump(object)
	elseif p == "SetLocalTransparencyModifier" and object and ToolEquipped then
		pcall(function()
			local v = false

			for _, v2 in pairs(LocalObjects) do
				if v2 == object then
					v = true
				end
			end

			if not v then
				table.insert(LocalObjects, object)

				if ObjectLocalTransparencyModifier then
					ObjectLocalTransparencyModifier:disconnect()
				end

				ObjectLocalTransparencyModifier = RunService.RenderStepped:connect(function()
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