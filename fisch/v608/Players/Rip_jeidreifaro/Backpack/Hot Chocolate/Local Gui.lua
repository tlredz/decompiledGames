local parent = script.Parent
local track = nil
enabled = true

function onButton1Down(p)
	if not enabled then
		return
	end

	enabled = false
	p.Icon = "rbxasset://textures\\ArrowFarCursor.png"
	track:Play()
	wait(8)
	p.Icon = "rbxasset://textures\\ArrowCursor.png"
	enabled = true
end

function onEquippedLocal(p)
	if p == nil then
		print("Mouse not found")
		return
	end

	local humanoid = parent.Parent:FindFirstChildOfClass("Humanoid")

	if humanoid then
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			track = humanoid:LoadAnimation(parent:WaitForChild("R15Drink"))
		else
			track = humanoid:LoadAnimation(parent:WaitForChild("drink"))
		end
	end

	p.Icon = "rbxasset://textures\\ArrowCursor.png"
	p.Button1Down:connect(function()
		onButton1Down(p)
	end)
end

function onUnequippedLocal()
	track:Stop()
	track:remove()
	track = nil
end

parent.Unequipped:connect(onUnequippedLocal)
parent.Equipped:connect(onEquippedLocal)