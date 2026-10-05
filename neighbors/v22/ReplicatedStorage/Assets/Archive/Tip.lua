local Tip = {}
require(script:WaitForChild("Mouse"))
game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
localPlayer:GetMouse()
local playerGui = localPlayer:WaitForChild("PlayerGui")
local tip = script:WaitForChild("Tip")
local frame = tip:WaitForChild("Frame")
local v = nil
local v2 = nil
tip.Parent = playerGui
localPlayer.CharacterAdded:connect(function()
	frame.Visible = false
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnect()
	if v then
		for _, v3 in v do
			v3:disconnect()
		end
	end

	v = nil
end

function Tip:connect(instance, callback)
	local mouseEnter = instance.MouseEnter
	local mouseLeave = instance.MouseLeave
	local _ = type(callback) == "function"

	if UserInputService.TouchEnabled then
		mouseEnter = instance.MouseButton1Down
		mouseLeave = instance.MouseButton1Up
	end

	mouseEnter:connect(function()
		if v then
			disconnect() -- equivalent call inferred; original call site unknown
		end

		v2 = instance
		frame.Visible = true
		task.spawn(function()
			while frame.Visible and v2 == instance do
				local v3 = typeof(callback) == "function" and callback() or tostring(callback)
				local text = v3:match("function") and "" or v3

				if text and not (#text < 1) then
					frame.Label.Text = text
					task.wait(1)
				else
					frame.Visible = false
					disconnect() -- equivalent call inferred; original call site unknown
					break
				end
			end
		end)
		v = { instance.AncestryChanged:connect(function(_, p)
				if not p then
					frame.Visible = false
					disconnect() -- equivalent call inferred; original call site unknown
				end
			end) }
	end)
	mouseLeave:connect(function()
		if v2 == instance then
			frame.Visible = false
			disconnect() -- equivalent call inferred; original call site unknown
		end
	end)
end

function Tip.disable(_)
	frame.Visible = false
end

return Tip