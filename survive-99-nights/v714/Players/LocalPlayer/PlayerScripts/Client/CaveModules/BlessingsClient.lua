local BlessingsClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local mouse = localPlayer:GetMouse()
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local blessingStatueHighlight = workspace.Highlights.BlessingStatueHighlight
local blessingFrame = Client.Interface.BlessingFrame
local v = nil
local v2 = nil
local X = 0
local v3 = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII"
}

function CheckStatueUnderMouse(unitRay: Ray)
	if unitRay == nil then
		unitRay = mouse.UnitRay
	end

	local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 100)

	if not raycastResult then
		return
	end

	local instance = raycastResult.Instance
	local parent = instance.Parent:GetAttribute("BlessingStatue") and instance.Parent or instance.Parent.Parent

	if parent and parent:GetAttribute("BlessingStatue") then
		if parent.Parent.Parent:GetAttribute("BlessingSelected") then
			return nil
		end

		return parent
	end
end

function SelectStatue(p)
	v2 = p
	Client.Sound.Play("BlessingSelectHead")
end

UserInputService.TouchTapInWorld:Connect(function(p, p2)
	if p2 or not v then
		return
	end

	local viewportPointToRay = workspace.CurrentCamera:ViewportPointToRay(p.X, p.Y)
	local v4 = CheckStatueUnderMouse(viewportPointToRay)

	if v4 then
		SelectStatue(v4)
	end
end)
ContextActionService:BindActionAtPriority("ClickBlessingStatue", function(_, p)
	if not (v and p == Enum.UserInputState.Begin) then
		return Enum.ContextActionResult.Pass
	end

	local v4 = CheckStatueUnderMouse()

	if v4 then
		SelectStatue(v4)
	end

	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 15, Enum.UserInputType.MouseButton1)
local v4 = {}
local v5 = {}

function FlashStatues(parent)
	if v4[parent] then
		return
	end

	v4[parent] = true

	if not v5[parent] then
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 1
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineTransparency = 0.3
		highlight.Parent = parent
		v5[parent] = highlight
	end

	task.spawn(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function checkStillViewing()
			if v5[parent] and v and v == parent and not (v2 or parent:GetAttribute("BlessingSelected")) then
				return true
			end

			return false
		end

		while checkStillViewing() do
			TweenService:Create(v5[parent], TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				FillTransparency = 0.79
			}):Play()
			wait(0.85)

			if not checkStillViewing() then
				break
			end

			TweenService:Create(v5[parent], TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				FillTransparency = 1
			}):Play()
			wait(0.85)
		end

		v4[parent] = false

		if v5[parent] then
			v5[parent].Adornee = nil
			v5[parent]:Destroy()
			v5[parent] = nil
		end
	end)
end

local v6 = {}
local v7 = {}

function CompressButton(p, p2)
	if not p then
		return
	end

	local button = p.Parent:FindFirstChild("Button")

	if not button or button:GetAttribute("Activated") then
		return
	end

	if p2 then
		button:SetAttribute("Activated", true)
	end

	if button and button:FindFirstChild("Mover") then
		if not v7[button] then
			v7[button] = 0
		end

		v7[button] += 1
		local v9 = v7[button]
		local mover = button.Mover

		if not v6[button] then
			v6[button] = {}
			v6[button][1] = mover.Main:GetPivot()
			v6[button][2] = mover.Inner:GetPivot()
		end

		TweenService:Create(mover.Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Position = v6[button][1] * CFrame.new(0, -1, 0).Position
		}):Play()
		TweenService:Create(mover.Inner, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Position = (v6[button][2] * CFrame.new(0, -1, 0)).Position
		}):Play()
		task.spawn(function()
			wait(0.4)

			if v9 == v7[button] and not p2 then
				TweenService:Create(mover.Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Position = v6[button][1].Position
				}):Play()
				TweenService:Create(
					mover.Inner,
					TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Position = v6[button][2].Position
					}
				):Play()
			end
		end)
	end
end

Client.Events.BlessingCompressButton:Connect(function(p, p2)
	if p == localPlayer then
		return
	end

	CompressButton(p2)
end)
UserInputService.InputChanged:Connect(function(input, _: boolean)
	if input.KeyCode == Enum.KeyCode.Thumbstick1 then
		X = input.Position.X
	end
end)

function BlessingsClient.ViewStatues(instance)
	if v then
		return
	end

	if not instance.Parent:GetAttribute("Unlocked") then
		print("cave area not unlocked")
		return
	end

	CompressButton(instance)
	Client.Sound.Play("StoneButton", {
		Volume = 0.5,
		Replicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.4
		}
	})
	Client.Events.BlessingCompressButton:FireServer(instance)
	blessingFrame.CloseButton.Visible = true
	blessingFrame.SelectFrame.Visible = false
	blessingFrame.Visible = true

	if instance:FindFirstChild("BlessingInteract") then
		instance.BlessingInteract.PrimaryPart.ProximityAttachment.ProximityInteraction.Enabled = false
	end

	local v8 = true
	local cFrame = instance.CameraCF.CFrame
	local cFrame2 = workspace.CurrentCamera.CFrame
	X = 0
	local blessingSelectedChangedConnection = instance:GetAttributeChangedSignal("BlessingSelected"):Connect(function()
		if instance:GetAttribute("BlessingSelected") then
			HideInterface()
			task.delay(3, function()
				v8 = false
			end)
		end
	end)
	v2 = nil
	local v9 = nil
	local v10 = nil
	v = instance
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	local v11 = 0
	local fieldOfView = 70
	Client.TweenModule.new(function(p)
		v11 = p
	end, 4, "Expo"):Play()
	task.delay(0, function()
		Client.TweenModule.new(function(p)
			fieldOfView = 70 - 30 * p
		end, 2.5, "Quad", "InOut"):Play()
	end)
	local total = 0
	local total2 = 0

	while localPlayer.Character and v8 and v do
		local v13 = RunService.RenderStepped:Wait()

		if instance:GetAttribute("BlessingSelected") == nil then
			if X < -0.8 and v10 ~= "Left" then
				v10 = "Left"
				local model = v.Statue1:FindFirstChildOfClass("Model")

				if v2 ~= model then
					v2 = model
					Client.Sound.Play("BlessingSelectHead")
				end
			elseif X > 0.8 and v10 ~= "Right" then
				v10 = "Right"
				local model = v.Statue2:FindFirstChildOfClass("Model")

				if v2 ~= model then
					v2 = model
					Client.Sound.Play("BlessingSelectHead")
				end
			end
		end

		local lerped = cFrame2:Lerp(cFrame, v11)
		local X2 = workspace.CurrentCamera.ViewportSize.X
		local v14 = (mouse.X / X2 - 0.5) * 2 * 5
		local Y = workspace.CurrentCamera.ViewportSize.Y
		local v15 = (mouse.Y / Y - 0.5) * 2 * 5

		if v2 then
			if v2.Parent.Name == "Statue1" then
				v14 = -8
			else
				v14 = 8
			end

			v15 = 0
		end

		if not v2 then
			FlashStatues(instance)
			v9 = nil
		end

		if v9 ~= v2 then
			v9 = v2

			if v9 then
				ShowInterfaceForStatue(v9)
			else
				HideInterface()
			end
		end

		total += (v14 - total) * 0.9 * v13
		total2 += (v15 - total2) * 0.9 * v13
		local cFrame3 = lerped * CFrame.Angles(math.rad(-total2), math.rad(-total), 0)
		workspace.CurrentCamera.CFrame = cFrame3
		workspace.CurrentCamera.FieldOfView = fieldOfView
	end

	if blessingSelectedChangedConnection then
		blessingSelectedChangedConnection:Disconnect()
	end

	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.FieldOfView = 70
	task.delay(1, function()
		if instance:FindFirstChild("BlessingInteract") then
			instance.BlessingInteract.PrimaryPart.ProximityAttachment.ProximityInteraction.Enabled = true
		end
	end)
	v = nil
	HideInterface()
end

function ExitView()
	HideInterface()
	v = nil
end

ContextActionService:BindActionAtPriority("CloseBlessingSelect", function(_, _, _)
	if not v then
		return Enum.ContextActionResult.Pass
	end

	ExitView()
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 5, Enum.KeyCode.ButtonB)
ContextActionService:BindActionAtPriority("SelectBlessingSelect", function(_, _, _)
	if not (v and v2) then
		return Enum.ContextActionResult.Pass
	end

	Client.Events.RequestSelectBlessing:FireServer(v2)
	task.delay(6, function()
		ExitView()
	end)
	BlessingSelectedParticles(v2)
	HideInterface()
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 5, Enum.KeyCode.ButtonA)
blessingFrame.CloseButton.MouseButton1Click:Connect(function()
	ExitView()
end)
blessingFrame.SelectFrame.CloseButton.MouseButton1Click:Connect(function()
	v2 = nil
	blessingFrame.CloseButton.Visible = true
	blessingFrame.SelectFrame.Visible = false
	blessingFrame.Visible = true
	blessingStatueHighlight.Adornee = nil
	blessingStatueHighlight.Enabled = false
end)

function AnimateOtherStatue()
	if not (v2 and v2.Parent and v2.Parent.Parent) then
		return
	end

	local parent = v2.Parent
	local parent2 = v2.Parent.Parent
	local statue1 = parent2:FindFirstChild("Statue1")
	local statue2 = parent2:FindFirstChild("Statue2")

	if parent.Name ~= statue1.Name then
		statue2 = statue1
	end

	for _, descendant in pairs(statue2:GetDescendants()) do
		if descendant:isA("BasePart") then
			TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Color = Color3.fromRGB(0, 0, 0)
			}):Play()
		end
	end
end

blessingFrame.SelectFrame.SelectButton.MouseButton1Click:Connect(function()
	if not v2 then
		ExitView()
		return
	end

	Client.Events.RequestSelectBlessing:FireServer(v2)
	task.delay(6, function()
		ExitView()
	end)
	BlessingSelectedParticles(v2)
	HideInterface()
end)

function ActivateParticles(folder)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and string.sub(emitter.Name, 1, 4) == "Acti") then
			continue
		end

		emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
	end
end

function BlessingSelectedParticles(instance)
	if instance:GetAttribute("ParticlesDone") then
		return
	end

	instance:SetAttribute("ParticlesDone", true)
	AnimateOtherStatue()

	if instance and instance.Parent:FindFirstChild("Main") then
		instance.Parent.Main.OnSelected:Play()
	end

	task.spawn(function()
		wait(5)
		Client.CamShake.ShakeOnce(3, 20, 2, 4)
		Client.Utility.SpawnParticles("RocksRaining", CFrame.new(instance:GetPivot().Position) * CFrame.new(0, 4, 0), {
			Duration = 4
		})
		wait(0.5)
		wait(1)
		Client.Sound.Play("BlessingSelected")
	end)

	if instance then
		ActivateParticles(instance)
		CompressButton(instance.Parent.Parent, true)
	end

	TweenService:Create(instance.Statue.Eyes, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Color = Color3.fromRGB(47, 255, 0)
	}):Play()
end

Client.Events.BlessingSelectedParticles:Connect(function(p)
	BlessingSelectedParticles(p)
end)

function ShowInterfaceForStatue(adornee)
	blessingStatueHighlight.FillTransparency = 1
	TweenService:Create(blessingStatueHighlight, TweenInfo.new(0.5), {
		FillTransparency = 0.7
	}):Play()
	local _ = adornee.Parent.Name == "Statue1"
	local v8 = "Blessing" .. v2.Name
	local _ = workspace:GetAttribute(v8) or 1
	blessingFrame.SelectFrame.TitleLabel.Text = `Blessing of the {v2.Name} {workspace:GetAttribute(v8) and v3[workspace:GetAttribute(v8) + 1] or v3[1]}`
	blessingFrame.SelectFrame.InfoLabel.Text = adornee:GetAttribute("Description")
	blessingFrame.CloseButton.Visible = false
	blessingFrame.SelectFrame.Visible = true
	blessingStatueHighlight.Adornee = adornee
	blessingStatueHighlight.Enabled = true
end

function HideInterface()
	blessingStatueHighlight.Adornee = nil
	blessingStatueHighlight.Enabled = false
	blessingFrame.Visible = false
	blessingFrame.SelectFrame.TitleLabel.Text = " "
	blessingFrame.SelectFrame.InfoLabel.Text = " "
end

return BlessingsClient