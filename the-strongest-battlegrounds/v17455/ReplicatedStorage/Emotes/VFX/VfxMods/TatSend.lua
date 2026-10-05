local TatSend = {}
local library = require(game.ReplicatedStorage.library)
local _ = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local _ = library.dtwait
local _ = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local _ = library.Able
local _ = library.LifeScale
local quickFX = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local _ = library.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)

function TatSend.FirstEvent(p)
	local data = p.Data
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local char = data.Char
	local _ = char.HumanoidRootPart
	local humanoid = char.Humanoid
	local v2 = nil

	if not char:WaitForChild("realconnect", 4) then
		return
	end

	wait(0.03)

	for _, v4 in pairs(humanoid:GetPlayingAnimationTracks()) do
		if v4.Animation.AnimationId ~= "rbxassetid://81016048005396" then
			continue
		end

		v2 = v4
		break
	end

	local connections = {}
	v2.Stopped:Once(function()
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end
	end)
	table.insert(connections, v2:GetMarkerReachedSignal("connect"):Once(function()
		local grab = vfx.Grab
		local folder = quickFX({
			FX = grab,
			Maid = object._maid,
			Anchor = char:GetPivot() * grab:GetAttribute("Offset"):Inverse()
		})

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:SetAttribute("EmitCount", emitter:GetAttribute("EmitCount") * 1.35)
			end
		end

		shared.vfx.emit(folder)
		local burst1 = vfx.Burst1
		local v4 = quickFX({
			FX = burst1,
			Maid = object._maid,
			Anchor = char:GetPivot() * burst1:GetAttribute("Offset"):Inverse()
		})
		shared.vfx.emit(v4)
	end))
	table.insert(connections, v2:GetMarkerReachedSignal("telekensis"):Once(function()
		local tonardo = vfx.tonardo
		local folder = quickFX({
			FX = tonardo,
			Maid = object._maid,
			Anchor = char:GetPivot() * CFrame.new(0, 0, -1) * tonardo:GetAttribute("Offset"):Inverse()
		})

		for _, descendant in pairs(folder:GetDescendants()) do
			local emitDuration = descendant:GetAttribute("EmitDuration")

			if emitDuration then
				descendant:SetAttribute("EmitDuration", emitDuration * 0.8)
			end
		end

		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 2 do
				if not folder.Parent or not v2 or v2 and not v2.IsPlaying then
					task.delay(1, Clean)
					break
				end

				folder:PivotTo(char:GetPivot() * tonardo:GetAttribute("Offset"):Inverse())
				folder.SpinModel:PivotTo(folder.SpinModel:GetPivot() * CFrame.Angles(0, -0.03490658503988659, 0))
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			end
		end)
		local v4 = object._maid:give(Instance.new("NumberValue"))
		folder:ScaleTo(0.1)
		v4.Value = folder:GetScale()
		object._maid:giveTask(v4.Changed:Connect(function()
			folder:ScaleTo(v4.Value)
		end))
		TweenService:Create(v4, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 1.45
		}):Play()
		shared.vfx.emit(folder)
	end))
	table.insert(connections, v2:GetMarkerReachedSignal("throw"):Once(function()
		local throw = vfx.Throw
		local v4 = quickFX({
			FX = throw,
			Maid = object._maid,
			Anchor = char:GetPivot() * throw:GetAttribute("Offset"):Inverse()
		})
		shared.vfx.emit(v4)
	end))
	table.insert(connections, v2:GetMarkerReachedSignal("stop"):Once(function()
		local tonardoBurst = vfx.tonardoBurst
		local v4 = quickFX({
			FX = tonardoBurst,
			Maid = object._maid,
			Anchor = char:GetPivot() * tonardoBurst:GetAttribute("Offset"):Inverse()
		})
		shared.vfx.emit(v4)
	end))

	local function FirstEvent()
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[95] = function() end,
			[172] = function() end
		})
	end

	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return TatSend