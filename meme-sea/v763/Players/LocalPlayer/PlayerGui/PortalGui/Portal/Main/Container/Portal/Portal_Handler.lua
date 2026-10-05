local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local cooldown = localPlayer:WaitForChild("Cooldown", 60)
ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
ReplicatedStorage:WaitForChild("Sound_Effect")
local portalAssets = guiTemplate:WaitForChild("PortalAssets")
local teleport = workspace:WaitForChild("Location"):WaitForChild("Teleport")
local SetText = require(moduleScript:WaitForChild("SetText"))
require(moduleScript:WaitForChild("Translate"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local parent = script.Parent
local parent2 = parent.Parent.Parent
local parent3 = parent2.Parent.Parent
local headBar = parent2.HeadBar
local parent4 = parent2.Parent
local container = parent.Container
local close = headBar:WaitForChild("Close")
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local portal_Template = portalAssets:WaitForChild("Portal_Template")
local connections = {}
local v = {
	{
		Name = "Floppa Island",
		Level_Req = 1,
		Icon = "rbxassetid://9930005090",
		Background_Color = Color3.fromRGB(92, 140, 211),
		Board = "rbxassetid://15488722052"
	},
	{
		Name = "Snow Island",
		Level_Req = 300,
		Icon = "rbxassetid://17607358050",
		Background_Color = Color3.fromRGB(92, 140, 211),
		Board = "rbxassetid://15488722052"
	},
	{
		Name = "Gorilla Island",
		Level_Req = 600,
		Icon = "rbxassetid://7154724966",
		Background_Color = Color3.fromRGB(92, 140, 211),
		Board = "rbxassetid://15488722052"
	},
	{
		Name = "Sand Island",
		Level_Req = 750,
		Icon = "rbxassetid://622495190",
		Background_Color = Color3.fromRGB(92, 140, 211),
		Board = "rbxassetid://15488722052"
	},
	{
		Name = "Pumpkin Island",
		Level_Req = 950,
		Icon = "rbxassetid://15489864256",
		Background_Color = Color3.fromRGB(92, 140, 211),
		Board = "rbxassetid://15488722052"
	},
	{
		Name = "Sus Mountain",
		Level_Req = 1150,
		Icon = "rbxassetid://6533289495",
		Background_Color = Color3.fromRGB(94, 198, 82),
		Board = "rbxassetid://15488723127"
	},
	{
		Name = "Moai Island",
		Level_Req = 1250,
		Icon = "rbxassetid://13464160174",
		Background_Color = Color3.fromRGB(94, 198, 82),
		Board = "rbxassetid://15488723127"
	},
	{
		Name = "Sus Island",
		Level_Req = 1500,
		Icon = "rbxassetid://5747127665",
		Background_Color = Color3.fromRGB(94, 198, 82),
		Board = "rbxassetid://15488723127"
	},
	{
		Name = "Noob Arena",
		Level_Req = 1600,
		Icon = "rbxassetid://16884321832",
		Background_Color = Color3.fromRGB(94, 198, 82),
		Board = "rbxassetid://15488723127"
	},
	{
		Name = "Forgotten Island",
		Level_Req = 1700,
		Icon = "rbxassetid://91697971513999",
		Size = UDim2.new(0.65, 0, 0.65, 0),
		Background_Color = Color3.fromRGB(94, 198, 82),
		Board = "rbxassetid://15488723127"
	},
	{
		Name = "Pvp Arena",
		Level_Req = 2000,
		Icon = "rbxassetid://15940102857",
		Background_Color = Color3.fromRGB(168, 82, 211),
		Board = "rbxassetid://15488724139"
	},
	{
		Name = "MrBeast Island",
		Level_Req = 2100,
		Icon = "rbxassetid://12369053967",
		Position = UDim2.new(0.5, 0, 0.475, 0),
		Size = UDim2.new(0.6, 0, 0.6, 0),
		Background_Color = Color3.fromRGB(168, 82, 211),
		Board = "rbxassetid://15488724139"
	}
}

local function GenerateIsland()
	for _, button in ipairs(container:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections)

	for _, v2 in ipairs(v) do
		local clone = portal_Template:Clone()
		clone.Name = v2.Name
		clone.Island.Text = v2.Name
		clone.Icon.Image = v2.Icon
		clone.Icon.Position = v2.Position or UDim2.new(0.5, 0, 0.475, 0)
		clone.Icon.Size = v2.Size or UDim2.new(0.6, 0, 0.6, 0)
		clone.Board.Image = v2.Board
		clone.BackgroundColor3 = v2.Background_Color or Color3.fromRGB(92, 140, 211)

		if localPlayer:GetAttribute("TH") then
			clone.Level.Text = `เลเวล {v2.Level_Req}+`
		else
			clone.Level.Text = `Level {v2.Level_Req}+`
		end

		clone.Visible = true
		clone.Parent = container
		connections[#connections + 1] = clone.Activated:Connect(function()
			local child = teleport:FindFirstChild(clone.Name)
			local character = localPlayer.Character

			if child and Generate.CheckIfAlive(character) then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				local humanoid = character:FindFirstChild("Humanoid")
				local portal_Z_Holding = cooldown:FindFirstChild("Portal_Z_Holding")

				if humanoidRootPart and humanoid and portal_Z_Holding and character:GetAttribute("Portal_Teleporting") then
					if humanoid.Sit == false then
						clone.Active = false
						character:SetAttribute("Portal_Teleporting", clone.Name)
						Close_Portal(character)
						clone.Active = true
					elseif localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "คุณไม่สามารถวาร์ประหว่างที่นั่งอยู่ได้.",
							MessageColor = "Red"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "You can't teleport while seated.",
							MessageColor = "Red"
						})
					end
				end
			end
		end)
	end
end

GenerateIsland()
localPlayer:GetAttributeChangedSignal("TH"):Connect(GenerateIsland)
parent3:GetPropertyChangedSignal("Enabled"):Connect(function()
	if parent3.Enabled and parent4.Position ~= UDim2.new(0.5, 0, 0.5, 0) then
		parent4.Position = UDim2.new(0.5, 0, 0.5, 0)
	end
end)

function Close_Portal(instance)
	if instance and instance:GetAttribute("Portal_Teleporting") == "None" then
		instance:SetAttribute("Portal_Teleporting", "Closed")
	end

	if parent3.Enabled then
		TweenService:Create(parent4, tweenInfo, {
			Position = UDim2.new(0.5, 0, 1.5, 0)
		}):Play()
		task.wait(0.5)
		parent3.Enabled = false
	end
end

close.Activated:Connect(function()
	local character = localPlayer.Character

	if Generate.CheckExist(character) then
		Close_Portal(character)
	end
end)