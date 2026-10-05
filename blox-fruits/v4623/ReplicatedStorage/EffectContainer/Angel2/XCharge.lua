local createVector = vector.create
local _ = game.Players.LocalPlayer
game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local _WorldOrigin = workspace._WorldOrigin

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFeetCFrame(cFrame: CFrame, parent, value: number?)
	local humanoid = parent:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if humanoid and humanoidRootPart then
		local v = humanoid.HipHeight + humanoidRootPart.Size.Y * 0.5
		return cFrame * CFrame.new(0, -(v + (value or 0.05)), 0)
	else
		return nil
	end
end

return function(player)
	local character = player.Character
	local rightHand = character.RightHand
	local humanoidRootPart = character.HumanoidRootPart

	if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 or not player.Holding then
		return
	end

	if player.ShowWarning then
		for _, target in pairs(player.targets) do
			local v = target
			task.spawn(function()
				if not v:IsDescendantOf(workspace) then
					return
				end

				local parent = v.Parent
				local part = Instance.new("Part", workspace._WorldOrigin)
				local feetCFrame = GetFeetCFrame(parent.HumanoidRootPart.CFrame, parent) -- equivalent call inferred; original call site unknown
				part.CFrame = CFrame.new(feetCFrame.Position) * CFrame.Angles(0, 0, 1.5707963267948966)
				part.Shape = Enum.PartType.Cylinder
				part.Anchored = true
				part.Size = createVector(1, 1, 1)
				part.Transparency = 1
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Color = Color3.fromRGB(255, 0, 0)
				part.Material = Enum.Material.Neon
				local v3 = player.holdingFor - (workspace:GetServerTimeNow() - player.started)
				local TweenService = game:GetService("TweenService")
				local tween = TweenService:Create(part, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
					Size = createVector(1, 80, 80),
					Transparency = 0
				})
				tween.Completed:Once(function()
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(part, TweenInfo.new(0.2), {
						Transparency = 1
					}):Play()
					Util.Debris:AddItem(part, 2)
				end)
				tween:Play()

				while v3 > 0 do
					v3 -= task.wait()
					local feetCFrame2 = GetFeetCFrame(parent.HumanoidRootPart.CFrame, parent) -- equivalent call inferred; original call site unknown
					part.CFrame = CFrame.new(feetCFrame2.Position) * CFrame.Angles(0, 0, 1.5707963267948966)
				end
			end)
		end
	end

	math.min(9.5, humanoidRootPart.Size.Y * 0.5 + humanoidRootPart.Parent.Humanoid.HipHeight)
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	folder.ChildAdded:Connect(function(_) end)
	local clone = script.Aura:Clone()
	clone.CFrame = rightHand.CFrame
	clone.Parent = folder
	clone.Weld.Part0 = rightHand

	repeat
		task.wait()
	until not (player.Holding and player.Holding.Value and player.Holding:IsDescendantOf(workspace))

	local clone2 = FX:WaitForChild("Angel2").AngelGrab.StartImpact:Clone()
	clone2.CFrame = CFrame.new(humanoidRootPart.Position)
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)
	end

	task.wait(0.7)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Util.Debris:AddItem(folder, 2)
end