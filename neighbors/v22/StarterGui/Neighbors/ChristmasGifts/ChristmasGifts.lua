local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Network = require(ReplicatedStorage.Modules.Network)
local SantaGifts = require(ReplicatedStorage.Assets.Data.SantaGifts)
local UI = require(ReplicatedStorage.Modules.UI)
local Confetti = require(script.Confetti)
local parent = script.Parent
local items = parent.GiftPage.Items
local christmasGifts = ReplicatedStorage.Assets.Models.ChristmasGifts
local vector2 = Vector2.new(0.5, 0.5)
local v = { Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255) }
Confetti.setGravity(Vector2.new(0, 1))
local v2 = {}
local enabled = false
local ID = nil

for _ = 1, 50 do
	table.insert(
		v2,
		Confetti.createParticle(vector2, Vector2.new(math.random(90) - 45, math.random(30, 100)), parent, v)
	)
end

local RunService = game:GetService("RunService")
RunService.RenderStepped:connect(function()
	for _, v4 in v2 do
		v4.Enabled = enabled
		v4:Update()
	end
end)

local function GetGiftInfoByName(p: string)
	for _, santaGift in SantaGifts do
		if santaGift.Info.Name == p then
			return santaGift
		end
	end

	return nil
end

local function ClearGiftList()
	for _, frame in items:GetChildren() do
		if frame:IsA("Frame") and frame.Visible then
			frame:Destroy()
		end
	end
end

local function DisplayConfirmation(p, modelPreview)
	local frame = parent.Confirmation.Frame
	parent.Confirmation.Visible = true
	frame.Description.Text = `{p.Name}\nReceived on {os.date("%x %I:%M %p", p.CreationDate)}`
	local viewportFrame = frame.Icon:FindFirstChildOfClass("ViewportFrame")

	if viewportFrame then
		viewportFrame:Destroy()
	end

	local clone = modelPreview:Clone()
	clone.Parent = frame.Icon
end

Network:listen("UpdateChristmasGifts", function(list)
	parent.Confirmation.Visible = false
	ClearGiftList()
	local clone = items.Category:Clone()
	clone.Label.Text = "Packages"
	clone.Parent = items

	if #list == 0 then
		parent.Visible = false
	end

	for _, v4 in list do
		local clone2 = christmasGifts:FindFirstChild(v4.ModelName):Clone()
		local name = v4.Name
		local _ = v4.Redeemed

		for _, santaGift in SantaGifts do
			if santaGift.Info.Name == name then
				break
			end
		end

		local clone3 = items.Gift:Clone()
		clone3.Name = name
		clone3.Visible = true
		clone2.Parent = clone3.ModelPreview
		clone2:PivotTo(CFrame.Angles(-1.5707963267948966, -3.141592653589793, 0.7853981633974483))
		local camera = Instance.new("Camera")
		camera.CFrame = CFrame.new(Vector3.new(0, 0.5, clone2:GetExtentsSize().Magnitude - 0.25), createVector(0, 0, 0))
		camera.FieldOfView = 55
		clone3.ModelPreview.CurrentCamera = camera
		clone3.Parent = clone.Items
		UI:Bind(clone3.Button)
		local v5 = v4
		clone3.Button.MouseButton1Click:Connect(function()
			if parent.Confirmation.Visible then
				return
			end

			ID = v5.ID
			DisplayConfirmation(v5, clone3.ModelPreview)
		end)
	end

	parent.Parent.Buttons.ChristmasGifts.Count.Text = #list
	parent.Parent.Buttons.ChristmasGifts.Count.Visible = #list > 0
	parent.Parent.Buttons.ChristmasGifts.Visible = #list > 0
	clone.Visible = true
end)
UI:Bind(parent.Confirmation.Frame.Cancel)
UI:Bind(parent.Confirmation.Frame.Open)
parent.Confirmation.Frame.Cancel.MouseButton1Click:Connect(function()
	parent.Confirmation.Visible = false
end)
local flag = false
parent.Confirmation.Frame.Open.MouseButton1Click:Connect(function()
	if flag then
		return
	end

	flag = true
	local v4 = Network:invoke("OpenChristmasGift", ID)

	if v4 then
		task.spawn(function()
			enabled = true
			local v5 = v4.Info.Special and 0.5 or 0.1
			task.delay(v5, function()
				enabled = false
			end)
		end)
	end

	flag = false
end)
parent.Parent.Buttons.ChristmasGifts.Count.Visible = false
parent.Parent.Buttons.ChristmasGifts.Visible = false
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	parent.Confirmation.Visible = false
end)