local createVector = vector.create
local _ = game.Players.LocalPlayer
local _ = workspace._WorldOrigin
local currentCamera = workspace.CurrentCamera
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
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
		clone.Parent = data.LeftHand
		Emit(clone)
		local v2 = Util.Sound:Play("BF_WaterFu_CHeld", data.LeftHand)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		DisableAllFXs(clone)
		Util.Debris:AddItem(clone, 1)
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 10)
		local root = data.Root
		Util.Sound:Play("BF_WaterFu_C_DashRelease_10", root.Position)
		local clone = C.DashTrail:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, -1, 0)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = clone
		weldConstraint.Part1 = root
		weldConstraint.Parent = clone
		clone.Parent = folder
		Util.Debris:AddItem(clone, 1)
		task.delay(0.2, function()
			DisableAllFXs(clone)
		end)
		task.wait(0.175)
		local clone2 = C.PunchFX:Clone()
		clone2.Position = data.TargetPosition
		clone2.Orientation = root.Orientation * createVector(0, 1, 1)
		clone2.CFrame *= CFrame.new(0, 0, -2.5)
		clone2.Parent = folder
		Util.Debris:AddItem(clone2, 1)
		Emit(clone2)
		Util.Sound:Play("BF_WaterFu_CImpact", clone2.Position)
		local clone3 = C.OuterRing:Clone()
		clone3.CFrame = clone2.CFrame * CFrame.new(0, 0, 3)
		clone3.Orientation += createVector(0, 90, 90)
		clone3.Parent = folder
		Util.Debris:AddItem(clone3, 2)
		local mesh = clone3.Mesh
		local quad = Enum.EasingStyle.Quad
		local out = Enum.EasingDirection.Out
		TweenService:Create(mesh, TweenInfo.new(0.35, quad, out), {
			Scale = createVector(2.25, 2.25, 2.25)
		}):Play()
		local quad2 = Enum.EasingStyle.Quad
		local out2 = Enum.EasingDirection.Out
		local v2 = {
			Position = clone3.Position + clone3.CFrame.UpVector * -5,
			Orientation = clone3.Orientation + createVector(120, 0, 0)
		}
		TweenService:Create(clone3, TweenInfo.new(0.35, quad2, out2), v2):Play()
		Animate(clone3) -- equivalent call inferred; original call site unknown
		task.delay(0.125, function()
			for _ = 1, 4 do
				local v3 = clone2.Position + createVector(0, 5, 0)
				local v4 = clone2.CFrame.LookVector * Random.new():NextNumber(-5, 30) + clone2.CFrame.RightVector * Random.new():NextNumber(
					-20,
					20
				) + clone2.CFrame.UpVector * -15
				local raycastResult = workspace:Raycast(v3, v4, raycastParams)

				if raycastResult then
					local clone4 = C.Puddle:Clone()
					clone4.Position = raycastResult.Position
					clone4.Parent = folder
					Util.Debris:AddItem(clone4, 3)
					Emit(clone4)
				end

				task.wait(0.05)
			end
		end)
	end
end