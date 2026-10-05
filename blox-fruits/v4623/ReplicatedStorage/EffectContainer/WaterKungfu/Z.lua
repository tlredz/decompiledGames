local createVector = vector.create
local _ = game.Players.LocalPlayer
local _ = workspace._WorldOrigin
local currentCamera = workspace.CurrentCamera
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Z = FX:WaitForChild("WaterKungfu").Z
local C = FX:WaitForChild("WaterKungfu").C
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local v = {
	"rbxassetid://121275527290964",
	"rbxassetid://75055760956069",
	"rbxassetid://79130295335070",
	"rbxassetid://73104710092919",
	"rbxassetid://84007950365489",
	"rbxassetid://139976807824989",
	"rbxassetid://112656605208290",
	"rbxassetid://112656605208290",
	"rbxassetid://110337500831747",
	"rbxassetid://104406951456554",
	"rbxassetid://104035358548557",
	"rbxassetid://84525649693445",
	"rbxassetid://112606957745530",
	"rbxassetid://0"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function Animate(clone)
	coroutine.wrap(function()
		for _, texture in pairs(v) do
			clone.Decal.Texture = texture
			task.wait(0.025)
		end
	end)()
end

local function Tween(p, duration, p2, p3, p4)
	local tween = TweenService:Create(p, TweenInfo.new(duration, p2, p3), p4)
	tween:Play()
	return tween
end

local function Emit(emitter)
	if not emitter then
		return
	end

	if emitter:IsA("ParticleEmitter") then
		local emitDelay = emitter:GetAttribute("EmitDelay") or 0
		local emitDuration = emitter:GetAttribute("EmitDuration")
		task.delay(emitDelay, function()
			emitter:Emit(emitter:GetAttribute("EmitCount"))

			if emitDuration then
				emitter.Enabled = true
				task.delay(emitDuration, function()
					emitter.Enabled = false
				end)
			end
		end)
	else
		for _, emitter2 in pairs(emitter:GetDescendants()) do
			if not emitter2:IsA("ParticleEmitter") then
				continue
			end

			local emitDelay = emitter2:GetAttribute("EmitDelay") or 0
			local v2 = emitter2
			local v3 = emitter2:GetAttribute("EmitDuration")
			task.delay(emitDelay, function()
				v2:Emit(v2:GetAttribute("EmitCount"))

				if v3 then
					v2.Enabled = true
					task.delay(v3, function()
						v2.Enabled = false
					end)
				end
			end)
		end
	end
end

local function DisableAllFXs(folder)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
			continue
		end

		effect.Enabled = false
	end
end

return function(data)
	local DELAY_DURATION = 0.15
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 500 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local clone = C.ChargeFX.A1:Clone()
		clone.Parent = data.RightHand
		Emit(clone)
		local v2 = Util.Sound:Play("BF_WaterFu_Z_Held_01", data.RightHand)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		DisableAllFXs(clone)
		Util.Debris:AddItem(clone, 1)
	elseif stage == 2 then
		task.wait(0.125)
		local direction = data.Direction
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local clone = Z.FireFX:Clone()
		clone.CFrame = direction * CFrame.new(0, 0, -1)
		clone.Parent = folder
		Util.Debris:AddItem(clone, 2)
		Emit(clone)
		Util.Sound:Play("BF_WaterFu_Z_SteamBlast_03", direction.Position)
		task.wait(0.025)
		local clone2 = Z.BaseWind:Clone()
		clone2.CFrame = direction * CFrame.Angles(0, -1.5707963267948966, 1.5707963267948966)
		clone2.Parent = folder
		Util.Debris:AddItem(clone2, 2)
		local cFrame = clone2.CFrame * CFrame.new(0, 40.5, 0)
		local quad = Enum.EasingStyle.Quad
		local out = Enum.EasingDirection.Out
		TweenService:Create(clone2, TweenInfo.new(0.35, quad, out), {
			CFrame = cFrame,
			Size = createVector(11, 6.25, 11)
		}):Play()
		local quad2 = Enum.EasingStyle.Quad
		local out2 = Enum.EasingDirection.Out
		local v3 = {
			CFrame = clone2.CFrame * CFrame.Angles(-6.283185307179586, 0, 0)
		}
		TweenService:Create(clone2, TweenInfo.new(0.4, quad2, out2), v3):Play()
		task.delay(0.25, function()
			local sine = Enum.EasingStyle.Sine
			local out3 = Enum.EasingDirection.Out
			TweenService:Create(clone2, TweenInfo.new(0.1, sine, out3), {
				Transparency = 1
			}):Play()
		end)
		local clone3 = Z.ProjVFX:Clone()
		clone3.CFrame = direction
		clone3.Parent = folder
		Util.Debris:AddItem(clone3, 2)
		local quad3 = Enum.EasingStyle.Quad
		local out3 = Enum.EasingDirection.Out
		local v4 = {
			CFrame = clone3.CFrame * CFrame.new(0, 0, -43)
		}
		TweenService:Create(clone3, TweenInfo.new(0.35, quad3, out3), v4):Play()
		Emit(clone3)
		task.delay(0.125, function()
			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone3.Attach.burst:Emit(1)
		end)
		local clone4 = Z.InnerWind:Clone()
		local cFrame2 = direction * CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966)
		clone4.CFrame = cFrame2
		clone4.Parent = folder
		Util.Debris:AddItem(clone4, 2)
		local mesh = clone4.Mesh
		local quint = Enum.EasingStyle.Quint
		local out4 = Enum.EasingDirection.Out
		TweenService:Create(mesh, TweenInfo.new(0.25, quint, out4), {
			Scale = createVector(2.55, 2, 2.55)
		}):Play()
		local cFrame3 = cFrame2 * CFrame.new(0, -40, 0) * CFrame.Angles(6.283185307179586, 0, 0)
		local quad4 = Enum.EasingStyle.Quad
		local out5 = Enum.EasingDirection.Out
		TweenService:Create(clone4, TweenInfo.new(0.35, quad4, out5), {
			CFrame = cFrame3
		}):Play()
		task.delay(DELAY_DURATION, function()
			local decal = clone4.Decal
			local sine = Enum.EasingStyle.Sine
			local out6 = Enum.EasingDirection.Out
			TweenService:Create(decal, TweenInfo.new(0.3, sine, out6), {
				Transparency = 1
			}):Play()
		end)
		local clone5 = Z.OuterWind:Clone()
		local cFrame4 = CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966) * direction
		clone5.CFrame = cFrame4
		clone5.Parent = folder
		Util.Debris:AddItem(clone5, 2)
		local mesh2 = clone5.Mesh
		local quint2 = Enum.EasingStyle.Quint
		local out6 = Enum.EasingDirection.Out
		TweenService:Create(mesh2, TweenInfo.new(0.25, quint2, out6), {
			Scale = createVector(4, 4.25, 4)
		}):Play()
		local cFrame5 = cFrame4 * CFrame.new(0, -35, 0) * CFrame.Angles(5.497787143782138, 0, 0)
		local quad5 = Enum.EasingStyle.Quad
		local out7 = Enum.EasingDirection.Out
		TweenService:Create(clone5, TweenInfo.new(0.35, quad5, out7), {
			CFrame = cFrame5
		}):Play()
		task.delay(0.35, function()
			local cFrame6 = cFrame4 * CFrame.new(0, -35, 0) * CFrame.Angles(6.283185307179586, 0, 0)
			local sine = Enum.EasingStyle.Sine
			local out8 = Enum.EasingDirection.Out
			TweenService:Create(clone5, TweenInfo.new(0.05, sine, out8), {
				CFrame = cFrame6
			}):Play()
		end)
		task.delay(DELAY_DURATION, function()
			local decal = clone5.Decal
			local sine = Enum.EasingStyle.Sine
			local out8 = Enum.EasingDirection.Out
			TweenService:Create(decal, TweenInfo.new(0.35, sine, out8), {
				Transparency = 1
			}):Play()
		end)
		local clone6 = Z.OuterRing:Clone()
		local cFrame7 = direction * CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966)
		clone6.CFrame = cFrame7
		clone6.Parent = folder
		Util.Debris:AddItem(clone6, 2)
		local mesh3 = clone6.Mesh
		local quint3 = Enum.EasingStyle.Quint
		local out8 = Enum.EasingDirection.Out
		TweenService:Create(mesh3, TweenInfo.new(0.25, quint3, out8), {
			Scale = createVector(3.5, 4.3, 3.5)
		}):Play()
		local cFrame8 = cFrame7 * CFrame.new(0, -36, 0)
		local quad6 = Enum.EasingStyle.Quad
		local out9 = Enum.EasingDirection.Out
		TweenService:Create(clone6, TweenInfo.new(0.35, quad6, out9), {
			CFrame = cFrame8
		}):Play()
		task.delay(0.35, function()
			local cFrame6 = cFrame8 * CFrame.Angles(4.71238898038469, 0, 0)
			local sine = Enum.EasingStyle.Sine
			local out10 = Enum.EasingDirection.Out
			TweenService:Create(clone6, TweenInfo.new(0.4, sine, out10), {
				CFrame = cFrame6
			}):Play()
		end)
		Animate(clone6) -- equivalent call inferred; original call site unknown
		local clone7 = Z.SpikeWind:Clone()
		clone7.CFrame = direction
		clone7.Orientation += createVector(90, 0, 0)
		clone7.Parent = folder
		Util.Debris:AddItem(clone7, 2)
		local quint4 = Enum.EasingStyle.Quint
		local out10 = Enum.EasingDirection.Out
		TweenService:Create(clone7, TweenInfo.new(0.5, quint4, out10), {
			Size = createVector(33.6, 6.6, 33.6)
		}):Play()
		local quad7 = Enum.EasingStyle.Quad
		local out11 = Enum.EasingDirection.Out
		local v11 = {
			CFrame = clone7.CFrame * CFrame.new(0, -43, 0)
		}
		TweenService:Create(clone7, TweenInfo.new(0.35, quad7, out11), v11):Play()
		task.delay(0.1, function()
			local sine = Enum.EasingStyle.Sine
			local out12 = Enum.EasingDirection.Out
			TweenService:Create(clone7, TweenInfo.new(0.25, sine, out12), {
				Transparency = 1
			}):Play()
		end)
		local clone8 = Z.GroundSmoke:Clone()
		clone8.CFrame = direction * CFrame.new(0, -2.5, 0)
		clone8.Parent = folder
		Util.Debris:AddItem(clone8, 2)
		local quad8 = Enum.EasingStyle.Quad
		local out12 = Enum.EasingDirection.Out
		local v12 = {
			CFrame = clone8.CFrame * CFrame.new(0, 0, -40)
		}
		TweenService:Create(clone8, TweenInfo.new(0.35, quad8, out12), v12):Play()
		task.delay(DELAY_DURATION, function()
			for _, emitter in pairs(clone8:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		local clone9 = Z.PuddleSource:Clone()
		clone9.CFrame = direction
		clone9.Parent = folder
		Util.Debris:AddItem(clone9, 2)
		local quad9 = Enum.EasingStyle.Quad
		local out13 = Enum.EasingDirection.Out
		local v13 = {
			CFrame = clone9.CFrame * CFrame.new(0, 0, -40)
		}
		TweenService:Create(clone9, TweenInfo.new(0.5, quad9, out13), v13):Play()
		coroutine.wrap(function()
			local rightVector = direction.RightVector
			local lookVector = direction.LookVector
			local cross = rightVector:Cross(lookVector)
			local cframe = CFrame.fromMatrix(direction.Position, rightVector, lookVector, cross)

			for i = 1, 4 do
				local clone10 = Z.OuterWind:Clone()
				clone10.CFrame = cframe * CFrame.new(0, i * 7, 0)
				clone10.Decal.Transparency = 0.85
				clone10.Parent = folder
				Util.Debris:AddItem(clone10, 2)
				local mesh4 = clone10.Mesh
				local quint5 = Enum.EasingStyle.Quint
				local out14 = Enum.EasingDirection.Out
				TweenService:Create(mesh4, TweenInfo.new(0.25, quint5, out14), {
					Scale = createVector(4, 4.25, 4)
				}):Play()
				local cFrame6 = clone10.CFrame * CFrame.Angles(6.283185307179586, 0, 0)
				local sine = Enum.EasingStyle.Sine
				local out15 = Enum.EasingDirection.Out
				TweenService:Create(clone10, TweenInfo.new(0.35, sine, out15), {
					CFrame = cFrame6
				}):Play()
				task.delay(0.1, function()
					local decal = clone10.Decal
					local sine2 = Enum.EasingStyle.Sine
					local out16 = Enum.EasingDirection.Out
					TweenService:Create(decal, TweenInfo.new(0.25, sine2, out16), {
						Transparency = 1
					}):Play()
				end)
				task.wait(0.05)
			end
		end)()
		coroutine.wrap(function()
			task.wait(0.05)

			for _ = 1, 6 do
				local position = clone9.Position
				local v14 = clone9.CFrame.RightVector * Random.new():NextNumber(-75, 75) + clone9.CFrame.UpVector * -15
				local raycastResult = workspace:Raycast(position, v14, raycastParams)

				if raycastResult then
					local clone10 = Z.Puddle:Clone()
					clone10.Position = raycastResult.Position
					clone10.Parent = folder
					Util.Debris:AddItem(clone10, 3)
					Emit(clone10)
				end

				task.wait(0.05)
			end
		end)()
	end
end