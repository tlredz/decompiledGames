Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
local Players2 = game:GetService("Players")
Players = Players2
local Debris2 = game:GetService("Debris")
Debris = Debris2
local RunService2 = game:GetService("RunService")
RunService = RunService2
local ContentProvider2 = game:GetService("ContentProvider")
ContentProvider = ContentProvider2
Animations = {}
LocalObjects = {}
ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")
Rate = 0.016666666666666666
ToolEquipped = false

function SetAnimation(p, data)
	if not (ToolEquipped and CheckIfAlive()) then
		return
	end

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

function Equipped(p)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	ToolEquipped = true

	if not CheckIfAlive() then
		return
	end

	PlayerMouse = p

	for _, animation in pairs(Tool:GetChildren()) do
		if animation:IsA("Animation") then
			ContentProvider:Preload(animation.AnimationId)
		end
	end
end

function Unequipped()
	for _, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end

	if ObjectLocalTransparencyModifier then
		ObjectLocalTransparencyModifier:disconnect()
	end

	LocalObjects = {}
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

function OnClientInvoke(p, p2)
	if not (ToolEquipped and CheckIfAlive()) then
		return
	end

	if p == "PlayAnimation" and p2 then
		SetAnimation("PlayAnimation", p2)
		return
	end

	if p == "StopAnimation" and p2 then
		SetAnimation("StopAnimation", p2)
		return
	end

	if p == "MouseData" then
		return PlayerMouse and {
			Position = PlayerMouse.Hit.p,
			Target = PlayerMouse.Target
		} or nil
	end

	if p == "SetLocalTransparencyModifier" and p2 and ToolEquipped then
		pcall(function()
			local v = false

			for _, v2 in pairs(LocalObjects) do
				if v2 == p2 then
					v = true
				end
			end

			if not v then
				table.insert(LocalObjects, p2)

				if ObjectLocalTransparencyModifier then
					ObjectLocalTransparencyModifier:disconnect()
				end

				ObjectLocalTransparencyModifier = RunService.RenderStepped:connect(function()
					for k, v2 in pairs(LocalObjects) do
						if v2.Object and v2.Object.Parent then
							if not v2.AutoUpdate and (v2.Object.LocalTransparencyModifier == 1 or v2.Object.LocalTransparencyModifier == 0) or v2.AutoUpdate then
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