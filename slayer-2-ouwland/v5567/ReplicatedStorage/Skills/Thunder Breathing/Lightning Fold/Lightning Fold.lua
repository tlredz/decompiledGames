local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local ServerClientPortal = require(ReplicatedStorage.CAM.Global.ServerClientPortal)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local TweenService = game:GetService("TweenService")
local Config = require(script.Parent.Config)
script.ground_ef.base_ef123asd.Size = NumberSequence.new(Config.RADIUS)
local LightningFold = {
	Id = 0
}
local track = nil
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))

function LightningFold.Hold(player)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if track then
		track:Stop()
		track = nil
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = gameSettings.skillStandStillForce
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	local clone = script.ground_ef:Clone()
	clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
	clone.Parent = workspace.Debree
	clone.base_ef123asd:Emit(1)
	v:Add(clone)
	DebrisModule:AddItem(clone, 6)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, 6)
	v:Add(boolValue)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 45,
			MaxTorque = 3000
		}
	)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 242, 65)
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	DebrisModule:AddItem(highlight, 15)
	v:Add(highlight)
	task.spawn(function()
		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v2:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			local maximizeRayClient, _, _, v3 = RaycastHelper.MaximizeRayClient(
				humanoidRootPart.Position,
				Platform_Handler.mousepos(),
				Config.RADIUS,
				true,
				3,
				75,
				3
			)
			LightningFold.LastAim = {
				char = v3,
				mousepos = maximizeRayClient,
				at = os.clock()
			}

			if v3 == nil then
				if highlight then
					highlight.Parent = workspace.Debree
				end
			elseif highlight and v3:FindFirstChild("HumanoidRootPart") then
				highlight.Parent = v3
			end

			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				maximizeRayClient,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end
	end)
	track = humanoid.Animator:LoadAnimation(script.Startup)
	track:Play()
	track:AdjustSpeed(1)
	track.Looped = true
end

local tweenInfo = TweenInfo.new(Config.ZIGZAG_DUR)

function LightningFold.UnHold(player, p)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and character:FindFirstChild("Humanoid") ~= nil) then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local id = LightningFold.Id
	local v2, _ = ManuelCancel.new(player, 1)
	v2:Connect(function()
		LightningFold.Id = -1
		LightningFold.Cancel(player)
	end)
	local _, _, _, char = RaycastHelper.MaximizeRayClient(humanoidRootPart.Position, p, Config.RADIUS, true, 5, 75, 3)
	local lastAim = LightningFold.LastAim
	LightningFold.LastAim = nil

	if lastAim ~= nil and os.clock() - lastAim.at < 0.25 then
		if lastAim.char ~= nil and lastAim.char.Parent ~= nil then
			char = lastAim.char
		end

		if lastAim.mousepos ~= nil then
			local _ = lastAim.mousepos
		end
	end

	task.wait(Config.STARTUP_DUR)

	if LightningFold.Id ~= id then
		LightningFold.Cancel(player)
		return
	end

	local cFrame = humanoidRootPart.CFrame
	local cframe = CFrame.new(cFrame.Position, p + vector.create(0, -p.Y + cFrame.Position.Y, 0))
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanTouch = false
	part.CanCollide = false
	part.CFrame = cFrame
	part.Transparency = 1
	local v3 = cframe + cframe.LookVector * Config.RADIUS
	part.Parent = workspace.Debree
	local weld = Instance.new("Weld", part)
	weld.Part0 = part
	weld.Part1 = humanoidRootPart
	local v4 = Utility.AddValue(getvaluesfolder, "NOMouvementlines", 3)
	local v5 = cFrame
	local v6 = false

	for i = 1, #Config.ZIGZAG_OFFSETS + 1 do
		if LightningFold.Id == id then
			local cFrame2

			if Config.ZIGZAG_OFFSETS[i] == nil then
				if char == nil or char.PrimaryPart == nil then
					cFrame2 = v3
				else
					cFrame2 = CFrame.new(char.PrimaryPart.Position) * v3.Rotation * CFrame.new(0, 0, 1)
				end
			else
				if char ~= nil and char.PrimaryPart ~= nil and i ~= 1 then
					local position = char.PrimaryPart.Position
					cFrame = CFrame.new(cFrame.Position) * CFrame.lookAt(
						cFrame.Position,
						position + vector.create(0, -position.Y + cFrame.Position.Y, 0)
					).Rotation
				end

				cFrame2 = cFrame * Config.ZIGZAG_OFFSETS[i]
			end

			local v8 = cFrame2.Position - v5.Position
			local v9 = vector.magnitude(v8)
			local normalized = vector.normalize(v8)
			local raycastResult = workspace:Raycast(
				v5.Position + normalized * -2,
				normalized * (v9 + 3),
				RaycastHelper.Crater
			)

			if raycastResult ~= nil then
				cFrame2 = CFrame.new(raycastResult.Position + normalized * -2) * cFrame2.Rotation
			end

			TweenService:Create(part, tweenInfo, {
				CFrame = cFrame2
			}):Play()
			local v10 = vector.magnitude(v5.Position - cFrame2.Position)
			ServerClientPortal.Server(script.Parent.Name, {
				v5,
				cFrame2,
				v10,
				Config.ZIGZAG_DUR
			})

			if i < 4 then
				game.ReplicatedStorage.Communication.CnC.ClientEffects:Fire(
					"Thunder_Bell_VFX",
					character,
					"Dash" .. i,
					{
						v5,
						cFrame2,
						v10,
						cFrame
					}
				)
			else
				v6 = i == 4 or v6
			end

			task.wait(Config.ZIGZAG_DUR)
			v5 = cFrame2
		else
			if part ~= nil then
				part:Destroy()
			end

			if v4 ~= nil then
				v4:Destroy()
			end

			LightningFold.Cancel(player)
			return
		end
	end

	if v6 == true then
		game.ReplicatedStorage.Communication.CnC.ClientEffects:Fire("Thunder_Bell_VFX", character, "Downslam", v5)
	end

	if v4 ~= nil then
		DebrisModule:AddItem(v4, 0.5)
	end

	if part ~= nil then
		DebrisModule:AddItem(part, 0.5)
	end

	LightningFold.Cancel(player)
	return v5
end

function LightningFold.Cancel(player)
	if track then
		track:Stop()
		track = nil
	end

	v:Clean()
	local character = player.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart ~= nil then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)

			if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart.Name == "skill_look_at" then
				for _, child in pairs(humanoidRootPart:GetChildren()) do
					if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
						child:Destroy()
					end
				end
			end
		end
	end
end

return LightningFold