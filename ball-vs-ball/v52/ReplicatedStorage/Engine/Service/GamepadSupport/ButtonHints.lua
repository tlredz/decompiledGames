local ButtonHints = {}
local v = {
	"A",
	"B",
	"X",
	"Y",
	"L1",
	"R1",
	"L2",
	"R2",
	"L3",
	"R3",
	"上",
	"下",
	"左",
	"右"
}
local v2 = {
	["上"] = "DPadUp",
	["下"] = "DPadDown",
	["左"] = "DPadLeft",
	["右"] = "DPadRight",
	L1 = "ButtonLB",
	R1 = "ButtonRB",
	L2 = "ButtonLT",
	R2 = "ButtonRT",
	L3 = "ButtonLS",
	R3 = "ButtonRS"
}
local v3 = {
	["78093668585057"] = "A",
	["73435950824571"] = "B",
	["110712507528378"] = "X",
	["129763894702339"] = "Y"
}

function ButtonHints.Ensure(button, p)
	for _, v4 in v do
		local image = button:FindFirstChild("手柄" .. v4)

		if image and image:IsA("ImageLabel") then
			return image
		end
	end

	local v4 = button:FindFirstChild("手柄按键提示")
	local v5 = not button:IsA("TextButton") and "" or button.Text
	local v6 = button.Name == "关闭按钮" or button.Name == "返回按钮" or button.Name == "CloseButton" or button.Name == "Back" or button.Name == "closeBtn" or button.Name == "backBtn" or button.Name == "取消按钮" or button.Name == "拒绝按钮" or v5 == "Close" or v5 == "Back" or v5 == "Cancel"

	if not (v4 or p) then
		return nil
	end

	local v7 = p or v6 and "B" or "A"

	if v4 then
		v7 = v3[v4.Image:match("%d+")] or v7
	end

	if not v4 then
		v4 = Instance.new("ImageLabel")
		v4.BackgroundTransparency = 1
		v4.AnchorPoint = Vector2.new(1, 0.5)
		v4.Position = UDim2.fromScale(0.96, 0.5)
		v4.SizeConstraint = Enum.SizeConstraint.RelativeYY
		v4.Size = UDim2.fromScale(0.45, 0.45)
		v4.ZIndex = button.ZIndex + 2
		v4.Parent = button
	end

	v4.Name = "手柄" .. v7
	v4.Image = "rbxasset://textures/ui/Controls/XboxController/" .. (v2[v7] or "Button" .. v7) .. "@2x.png"
	v4:SetAttribute("GamepadKey", nil)
	v4:SetAttribute("PromptMode", nil)
	return v4
end

function ButtonHints.Shortcut(p, p2)
	local v4 = ButtonHints.Ensure(p, p2)
	v4.Name = "手柄" .. p2
	local v5 = "rbxasset://textures/ui/Controls/XboxController/" .. (v2[p2] or "Button" .. p2) .. "@2x.png"
	local v6 = ({
		["上"] = Enum.KeyCode.DPadUp,
		["下"] = Enum.KeyCode.DPadDown,
		["左"] = Enum.KeyCode.DPadLeft,
		["右"] = Enum.KeyCode.DPadRight
	})[p2] or Enum.KeyCode["Button" .. p2]
	local UserInputService = game:GetService("UserInputService")
	local getImageForKeyCode = UserInputService.GetImageForKeyCode
	local UserInputService2 = game:GetService("UserInputService")
	local success, result = pcall(getImageForKeyCode, UserInputService2, v6)

	if success then
		if result == "" then
			result = v5
		end
	else
		result = v5
	end

	v4.Image = result
	return v4
end

function ButtonHints.TrackStandalone(instance, p, callback)
	local UserInputService = game:GetService("UserInputService")
	local parentModule = require(script.Parent)
	local v4 = ButtonHints.Ensure(instance, p)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateImage()
		local v5 = Enum.KeyCode["Button" .. p]
		local success, imageForKeyCode = pcall(UserInputService.GetImageForKeyCode, UserInputService, v5)

		if success and imageForKeyCode ~= "" then
			v4.Image = imageForKeyCode
		end
	end

	updateImage() -- equivalent call inferred; original call site unknown
	local connections = {}
	table.insert(connections, UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateImage))
	table.insert(connections, UserInputService.GamepadConnected:Connect(updateImage))
	local total = 0
	local RunService = game:GetService("RunService")
	table.insert(connections, RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < 0.1 then
			return
		end

		total = 0
		v4.Visible = parentModule.IsGamepad() and parentModule.CanActivate(instance) and callback()
	end))
	instance.Destroying:Connect(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

return ButtonHints