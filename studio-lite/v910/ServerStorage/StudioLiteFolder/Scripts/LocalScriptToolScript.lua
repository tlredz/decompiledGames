Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
local Players2 = game:GetService("Players")
Players = Players2
ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ClientControl.OnClientInvoke = function(p, object)
	if p == "PlaySound" and object then
		object:Play()
	end
end

function InvokeServer(p, p2, p3)
	pcall(function()
		ServerControl:InvokeServer(p, p2, p3)
	end)
end

function Equipped(p)
	local parent = Tool.Parent
	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
	local humanoid = parent:FindFirstChild("Humanoid")

	if not playerFromCharacter or not humanoid or humanoid.Health == 0 then
		return
	end

	p.Button1Down:connect(function()
		InvokeServer("Click", true, p.Hit.p)
	end)
end

local function Unequipped() end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)