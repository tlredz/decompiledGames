local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FrameMarker = require(ReplicatedStorage.Resources.FrameMarker)
local libraryNew = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local able = libraryNew.Able
local EFP = libraryNew.EFP

local function WallCombo(p)
	local char = p.Char
	local victim = p.Victim
	local clone = script.Fx:Clone()
	game.Debris:AddItem(clone, 10)
	task.spawn(function()
		local lastTime = tick()

		while tick() - lastTime < 1 do
			if clone.Parent then
				clone:PivotTo(char:GetPivot() * clone:GetAttribute("Offset"):Inverse())
			end

			task.wait(0.01)
		end
	end)
	clone.Parent = EFP
	clone = clone.Fx
	local clones = {}
	local drag = nil

	for _, child in pairs(script.Beams:GetChildren()) do
		if child.Name == "Beam" then
			local leftGripAttachment = char:FindFirstChild("Left Arm"):FindFirstChild("LeftGripAttachment")
			local rightGripAttachment = victim:FindFirstChild("Right Arm"):FindFirstChild("RightGripAttachment")

			if leftGripAttachment and rightGripAttachment then
				local clone2 = child:Clone()
				game.Debris:AddItem(clone2, 6)
				table.insert(clones, clone2)
				clone2.Attachment0 = leftGripAttachment
				clone2.Attachment1 = rightGripAttachment
				clone2.Parent = char
			end
		else
			local rightGripAttachment = char:FindFirstChild("Right Arm"):FindFirstChild("RightGripAttachment")
			local leftGripAttachment = victim:FindFirstChild("Left Arm"):FindFirstChild("LeftGripAttachment")

			if leftGripAttachment and rightGripAttachment then
				local clone2 = child:Clone()
				game.Debris:AddItem(clone2, 6)
				table.insert(clones, clone2)
				clone2.Attachment0 = rightGripAttachment
				clone2.Attachment1 = leftGripAttachment
				clone2.Parent = char
			end
		end
	end

	local function setBeamEnable(enabled)
		for _, beam in clones do
			if beam:IsA("Beam") then
				beam.Enabled = enabled
			end
		end
	end

	setBeamEnable(false)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
	return FrameMarker.new({
		Framerate = 60
	}):Chain({
		[9] = function()
			local _9F = clone["9F"]
			local raycastResult = game.Workspace:Raycast(
				char:GetPivot().Position,
				char:GetPivot().lookVector * 10,
				raycastParams
			)

			if raycastResult then
				for _, emitter in pairs(_9F:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter.Name == "Smoke" then
						emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
					end
				end
			end

			playAttachment(_9F)
			local swirlMesh = _9F.SwirlMesh
			swirlMesh.Transparency = 0.25
			TweenService:Create(swirlMesh, TweenInfo.new(1, Enum.EasingStyle.Quart), {
				Transparency = 1,
				Size = createVector(25, 15, 25),
				CFrame = swirlMesh.CFrame * CFrame.new(0, -5, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			local lingerMesh = _9F.LingerMesh
			lingerMesh.Decal.Transparency = 0.5
			TweenService:Create(lingerMesh, TweenInfo.new(1, Enum.EasingStyle.Quint), {
				CFrame = lingerMesh.CFrame * CFrame.new(-7, 0, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
			}):Play()
			TweenService:Create(lingerMesh.Mesh, TweenInfo.new(1, Enum.EasingStyle.Quint), {
				Scale = createVector(0.5, 0.25, 0.25)
			}):Play()
			TweenService:Create(lingerMesh.Decal, TweenInfo.new(1), {
				Transparency = 1
			}):Play()
		end,
		[41] = function()
			setBeamEnable(true)
			playAttachment(clone["41F"])
		end,
		[64] = function()
			local _64F = clone["64F"]
			playAttachment(_64F)
			local swirlMesh = _64F.SwirlMesh
			swirlMesh.Transparency = 0.5
			TweenService:Create(swirlMesh, TweenInfo.new(1, Enum.EasingStyle.Quart), {
				Size = createVector(25, 15, 25),
				Position = swirlMesh.Position - createVector(0, 4, 0),
				Transparency = 1,
				Orientation = swirlMesh.Orientation - createVector(0, 180, 0)
			}):Play()
			local lingerMesh = _64F.LingerMesh
			lingerMesh.Decal.Transparency = 0
			TweenService:Create(lingerMesh, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {
				CFrame = lingerMesh.CFrame * CFrame.new(0, -5.5, 0) * CFrame.Angles(0, 2.356194490192345, 0)
			}):Play()
			TweenService:Create(lingerMesh.Mesh, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {
				Scale = createVector(8, 8, 8)
			}):Play()
			TweenService:Create(lingerMesh.Decal, TweenInfo.new(1.2), {
				Transparency = 1
			}):Play()
			local slamMesh = _64F.SlamMesh
			slamMesh.Decal.Transparency = 0
			TweenService:Create(slamMesh.Mesh, TweenInfo.new(2.5, Enum.EasingStyle.Quart), {
				Offset = createVector(0, 0, 0),
				Scale = createVector(0.2, 0.65, 0.65)
			}):Play()
			TweenService:Create(slamMesh.Decal, TweenInfo.new(2.5, Enum.EasingStyle.Quart), {
				Transparency = 1
			}):Play()
			local spikyMesh = _64F.SpikyMesh
			spikyMesh.Transparency = 0
			TweenService:Create(spikyMesh, TweenInfo.new(1, Enum.EasingStyle.Quart), {
				Size = createVector(15, 30, 30),
				CFrame = spikyMesh.CFrame * CFrame.new(-15, 0, 0) * CFrame.Angles(-3.141592653589793, 0, 0),
				Transparency = 1
			}):Play()
			setBeamEnable(false)
		end,
		[94] = function()
			playAttachment(clone["94F"])
			setBeamEnable(true)
		end,
		[119] = function()
			local _119F = clone["119F"]
			playAttachment(_119F)
			drag = _119F.Drag
			task.delay(0.4, function()
				able({
					FX = drag,
					On = true
				})
			end)
		end,
		[164] = function()
			clone:PivotTo(char:GetPivot() * CFrame.new(0, 0, 2) * clone:GetAttribute("Offset"):Inverse())
			local _164F = clone["164F"]
			local raycastResult = game.Workspace:Raycast(
				char:GetPivot().Position,
				char:GetPivot().lookVector * 10,
				raycastParams
			)

			if raycastResult then
				for _, emitter in pairs(_164F:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter.Name == "Smoke" then
						emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
					end
				end
			end

			playAttachment(_164F)
			local swirlMesh = _164F.SwirlMesh
			swirlMesh.Transparency = 0.25
			TweenService:Create(swirlMesh, TweenInfo.new(1, Enum.EasingStyle.Quart), {
				Transparency = 1,
				Size = createVector(25, 15, 25),
				CFrame = swirlMesh.CFrame * CFrame.new(0, -5, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			local lingerMesh = _164F.LingerMesh
			lingerMesh.Decal.Transparency = 0.5
			TweenService:Create(lingerMesh, TweenInfo.new(1, Enum.EasingStyle.Quint), {
				CFrame = lingerMesh.CFrame * CFrame.new(-7, 0, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
			}):Play()
			TweenService:Create(lingerMesh.Mesh, TweenInfo.new(1, Enum.EasingStyle.Quint), {
				Scale = createVector(0.5, 0.25, 0.25)
			}):Play()
			TweenService:Create(lingerMesh.Decal, TweenInfo.new(1), {
				Transparency = 1
			}):Play()
			local slamMesh = _164F.SlamMesh
			slamMesh.Decal.Transparency = 0
			TweenService:Create(slamMesh.Mesh, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {
				Offset = createVector(0, 0, 0),
				Scale = createVector(0.1, 0.3, 0.3)
			}):Play()
			TweenService:Create(slamMesh.Decal, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {
				Transparency = 1
			}):Play()
			task.delay(0.4, function()
				able({
					FX = drag,
					On = false
				})
			end)
			setBeamEnable(false)
		end,
		[655] = function(instance)
			clone:Destroy()
			instance:Destroy()
		end
	})
end

return WallCombo