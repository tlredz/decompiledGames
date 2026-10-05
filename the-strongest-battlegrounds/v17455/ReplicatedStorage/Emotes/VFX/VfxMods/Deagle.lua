local Deagle = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local _ = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local _ = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local _ = libraryNew.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local DeagleAdditions = require(script.Parent.DeagleAdditions)

function Deagle.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
	warn(data.Bind)
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
		DeagleAdditions(char)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Deagle.ShootEvent(p)
	local char = p.Data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
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

	local function ShootEvent()
		local v2 = object._maid:give(Instance.new("CFrameValue"))
		v2.Name = "DeagleAnchor"
		v2.Parent = char
		game.Debris:AddItem(v2, 1)
		local FX = quickFX({
			FX = vfx.Shoot,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(-0.4, 3.5, -5) * CFrame.Angles(-1.5707963267948966, 0, 0)
		})
		lifeScale({
			FX = FX,
			Scale = 0.8
		})
		v2.Value = humanoidRootPart.CFrame
		playAttachment(FX)
		task.wait(0.1)
		local v4 = object._maid:give(Instance.new("PointLight"))
		v4.Brightness = 11
		v4.Color = Color3.new(1, 0.317647, 0.109804)
		v4.Range = 20
		v4.Parent = humanoidRootPart
		TweenService:Create(v4, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Range = 0,
			Brightness = 10
		}):Play()
		local FX2 = quickFX({
			FX = vfx.Ground,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		lifeScale({
			FX = FX2,
			Scale = 0.7
		})
		playAttachment(FX2)
	end

	task.spawn(ShootEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return Deagle