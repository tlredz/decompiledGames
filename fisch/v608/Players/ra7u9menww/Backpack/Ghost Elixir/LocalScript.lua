Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
local Players2 = game:GetService("Players")
Players = Players2
local RunService2 = game:GetService("RunService")
RunService = RunService2
Animations = {}
ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")
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

	Spawn(function()
		PlayerMouse = data
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
	end)
end

function Unequipped()
	for _, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end

	Animations = {}
	ToolEquipped = false
end

function InvokeServer(p, p2)
	pcall(function()
		return (ServerControl:InvokeServer(p, p2))
	end)
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
	elseif p == "MousePosition" then
		return PlayerMouse and {
			Position = PlayerMouse.Hit.p,
			Target = PlayerMouse.Target
		} or nil
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)