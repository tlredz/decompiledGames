local Marked = {}
local library = require(script.Parent.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local playTween = library.PlayTween
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
local _ = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local _ = library.EditableMeshShader
local _ = library.Shake
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

function Marked.FirstEvent(p)
	print(p)
	local data = p.Data
	local char = data.Char
	local _ = char.PrimaryPart
	local bind = data.Bind
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

	local function FirstEvent()
		local clone = vfx.Ok:Clone()
		local weld = Instance.new("Weld")
		weld.Part0 = clone.PrimaryPart
		weld.Part1 = char:FindFirstChild("Torso")
		weld.Parent = clone
		clone.Parent = char
		local v2 = object._maid:give(Instance.new("NumberValue"))
		object._maid:giveTask(v2.Changed:Connect(function()
			clone:ScaleTo(v2.Value)
		end))
		v2.Value = 3
		TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 1.4
		}):Play()
		playAttachment(clone.init)
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://103232279189010"
		sound.RollOffMode = Enum.RollOffMode.InverseTapered
		sound.RollOffMaxDistance = 90
		sound.Looped = true
		sound.Volume = 0
		sound.Parent = char:FindFirstChild("Torso")
		sound:Play()
		task.delay(35, function()
			if sound then
				return sound:Destroy()
			end
		end)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(sound, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Volume = 0.35
		}):Play()
		local parentChangedConnection = nil
		parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
			if sound and sound.Parent then
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(sound, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Volume = 0
				}):Play()
			end

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:IsA("Beam") then
					playTween(descendant, {
						Time = 0.3,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new(1)
						}
					})
					game.Debris:AddItem(descendant, 0.3)
				elseif descendant:IsA("PointLight") then
					playTween(descendant, {
						Time = 0.3,
						EasingStyle = "Sine",
						Goal = {
							Brightness = 0
						}
					})
					game.Debris:AddItem(descendant, 0.3)
				end
			end

			game.Debris:AddItem(clone, 5)
			parentChangedConnection:Disconnect()
		end)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return Marked