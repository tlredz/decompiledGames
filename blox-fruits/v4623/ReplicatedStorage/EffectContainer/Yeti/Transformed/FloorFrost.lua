local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
local FX = require(ReplicatedStorage.FX)
return function(player)
	local player2 = player.player
	local character = player.Character
	local scene = player.Scene
	local v = player2 and player2:IsA("Player")
	local isFiendYeti = player.IsFiendYeti == true
	local v2

	if v then
		v2 = player2:GetAttribute("RedYeti") == true
	else
		v2 = isFiendYeti or character and character:GetAttribute("RedYeti") == true and true or false
	end

	local v3

	if v then
		v3 = player2
	else
		v3 = character
	end

	local folder = Instance.new("Folder")

	if scene then
		folder.Name = "YetiFloorEffects"
		folder.Parent = workspace._WorldOrigin
	elseif v then
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "YetiFruitVFXColor")
	else
		folder.Parent = workspace._WorldOrigin
	end

	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local __BoundingBox

	if scene and player.Rig then
		__BoundingBox = player.Rig:FindFirstChild("__BoundingBox") or nil
	end

	local clone = (v2 and FX:WaitForChild("YetiEffectsRed").Walking or FX:WaitForChild("YetiEffects").Walking).Floor:Clone()

	if v3 then
		Util.SetParentOverrideWithColor(clone, folder, v3, "YetiFruitVFXColor")
	else
		clone.Parent = folder
	end

	if __BoundingBox then
		clone.CFrame = __BoundingBox.CFrame
		clone.Weld.Part0 = __BoundingBox
		clone.Weld.C1 = CFrame.new(0, __BoundingBox.Size.Y / 2, 0)
	else
		clone.CFrame = humanoidRootPart.CFrame
		clone.Weld.Part0 = humanoidRootPart
		clone.Weld.C1 = CFrame.new(0, character.Humanoid.HipHeight + 0.669, 0)
	end

	clone.Weld.Enabled = true

	if v2 then
		clone.Atch.Position = createVector(0, -0.1, 0)
	end

	local descendants = clone:GetDescendants()
	local flag = true

	for _, emitter in descendants do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = flag
		end
	end

	local v4

	if v2 then
		v4 = Util.Sound:Play("AkumaYeti_Aura_AmbientLoop_01", clone)
	else
		v4 = Util.Sound:Play("YETI_TNSFM_Idle_Loop_01", clone)
	end

	local clone2 = nil

	while (scene or not v or player.Backpack and (player.Backpack:FindFirstChild("Yeti-Yeti") or character:FindFirstChild("Yeti-Yeti") or player.Backpack:FindFirstChild("Fiend (Yeti)-Fiend (Yeti)") or character:FindFirstChild("Fiend (Yeti)-Fiend (Yeti)"))) and humanoidRootPart and humanoidRootPart:IsDescendantOf(workspace) and player.Rig and player.Rig.Parent do
		if scene or not ((humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 1000) then
			if scene or not (character:FindFirstChild("Busy") and character.Busy.Value) then
				task.spawn(function()
					if v2 and character:GetAttribute("YetiOnWater") then
						if clone2 then
							return
						end

						clone2 = script:WaitForChild("AkumaEnergy"):Clone()
						clone2:ScaleTo(11.25)

						if v3 then
							Util.SetParentOverrideWithColor(clone2, character, v3, "YetiFruitVFXColor")
						else
							clone2.Parent = character
						end

						local rotation = clone2:GetPivot().Rotation
						task.spawn(function()
							while clone2 and clone2.Parent and humanoidRootPart do
								clone2:PivotTo(rotation + humanoidRootPart.CFrame.Position - createVector(0, 11, 0))
								task.wait()
							end
						end)
						task.spawn(function()
							while v2 and (character:GetAttribute("YetiOnWater") and character:FindFirstChild("YetiRig") ~= nil or scene) and player.Rig.Parent do
								task.wait()
							end

							local transparenciesByDescendant = {}
							local v6 = {}

							for _, descendant in ipairs(clone2:GetDescendants()) do
								if descendant:IsA("Texture") or descendant:IsA("Decal") then
									transparenciesByDescendant[descendant] = descendant.Transparency
								elseif descendant:IsA("ParticleEmitter") then
									v6[descendant] = true
								end
							end

							Util.HeartbeatLoopFor.HeartbeatLoopFor(0.2, function(_, _, transparency)
								if clone2:FindFirstChild("Cylinder.020") then
									clone2["Cylinder.020"].Transparency = transparency

									for k, _ in pairs(v6) do
										k.Transparency = NumberSequence.new(transparency)
									end

									for k, v7 in pairs(transparenciesByDescendant) do
										k.Transparency = math.lerp(v7, 1, transparency)
									end
								end
							end, function()
								if clone2:FindFirstChild("Cylinder.020") then
									clone2["Cylinder.020"].Transparency = 1

									for k, _ in pairs(v6) do
										k.Transparency = NumberSequence.new(1)
									end

									for k, v7 in pairs(transparenciesByDescendant) do
										k.Transparency = math.lerp(v7, 1, 1)
									end
								end

								if clone2 then
									clone2:Destroy()
									clone2 = nil
								end
							end)
						end)
					end
				end)

				if not scene and player2 and player2:IsA("Player") then
					if workspace:Raycast(
						humanoidRootPart.Position + createVector(0, 1, 0),
						createVector(-0, -15, -0),
						raycastParams
					) then
						if not flag then
							TweenService:Create(v4, TweenInfo.new(0.5), {
								Volume = 0.2
							}):Play()
							flag = true

							for k, emitter in pairs(descendants) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end
						end
					elseif flag then
						TweenService:Create(v4, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
						flag = false

						for k, emitter in pairs(descendants) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end
				end
			elseif flag then
				flag = false

				for _, emitter in descendants do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end

		task.wait(0.07)
	end

	if v4 then
		Util.Sound:FadeOut(v4, 0.2)
	end

	for _, emitter in descendants do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.wait(3)
	folder:Destroy()
end