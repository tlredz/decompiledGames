local createVector = vector.create
local SwordBurst = {}
local library = require(game.ReplicatedStorage.library)
local _ = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local _ = library.dtwait
local EFP = library.EFP
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
require(game.ReplicatedStorage.Resources.FrameMarker)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.CurrentCamera }
local v = {
	Shockwave = {
		"rbxassetid://119827538140482",
		"rbxassetid://94766371110676",
		"rbxassetid://123208912741587",
		"rbxassetid://134867710844761",
		"rbxassetid://83366600435524",
		"rbxassetid://128353111761737",
		"rbxassetid://136296600784735",
		"rbxassetid://104535960303264",
		"rbxassetid://96504567036241",
		"rbxassetid://126248396869379",
		"rbxassetid://81245934474468",
		"rbxassetid://112557701311012",
		"rbxassetid://136395168077016",
		"rbxassetid://140506293591590",
		"rbxassetid://133281062308678",
		"rbxassetid://81505048695528",
		"rbxassetid://18799643112"
	},
	Slash = {
		"rbxassetid://16612901487",
		"rbxassetid://16612901209",
		"rbxassetid://16612900970",
		"rbxassetid://16612900673",
		"rbxassetid://16612900426",
		"rbxassetid://16612900092",
		"rbxassetid://16612899797",
		"rbxassetid://16612899543",
		"rbxassetid://16612899179",
		"rbxassetid://16612898917",
		"rbxassetid://16612898595",
		"rbxassetid://16612898335",
		"rbxassetid://16612898097"
	},
	Slash2 = {
		"rbxassetid://16612901487",
		"rbxassetid://16612901209",
		"rbxassetid://16612900970",
		"rbxassetid://16612900673",
		"rbxassetid://16612900426",
		"rbxassetid://16612900092",
		"rbxassetid://16612899797",
		"rbxassetid://16612899543",
		"rbxassetid://16612899179",
		"rbxassetid://16612898917",
		"rbxassetid://16612898595",
		"rbxassetid://16612898335",
		"rbxassetid://16612898097"
	},
	slash1 = {
		"rbxassetid://131239208597047",
		"rbxassetid://72991831178564",
		"rbxassetid://120447946840212",
		"rbxassetid://133946210360573",
		"rbxassetid://122388190483058",
		"rbxassetid://128152359882427",
		"rbxassetid://110072935161094",
		"rbxassetid://75931263662008",
		"rbxassetid://135422485475985",
		"rbxassetid://97893024221257",
		"rbxassetid://90712277685817",
		"rbxassetid://117366004102345",
		"rbxassetid://80664136092603",
		"rbxassetid://75751746554686",
		"rbxassetid://124858789651146",
		"rbxassetid://125728201466274",
		"rbxassetid://130374401141126"
	},
	slash2 = {
		"rbxassetid://16612901487",
		"rbxassetid://16612901209",
		"rbxassetid://16612900970",
		"rbxassetid://16612900673",
		"rbxassetid://16612900426",
		"rbxassetid://16612900092",
		"rbxassetid://16612899797",
		"rbxassetid://16612899543",
		"rbxassetid://16612899179",
		"rbxassetid://16612898917",
		"rbxassetid://16612898595",
		"rbxassetid://16612898335",
		"rbxassetid://16612898097"
	}
}
local v2 = nil
v2 = {
	AlignGroup = function(folder, cframe: CFrame?, flag: boolean?)
		if cframe then
			folder:PivotTo(cframe)
		end

		local result = {}

		for _, part in folder:GetDescendants() do
			if not (part:IsA("BasePart") and part:GetAttribute("Ground")) then
				continue
			end

			local raycastResult = workspace:Raycast(
				part.Position + createVector(0, 2, 0),
				createVector(-0, -10, -0),
				raycastParams
			)

			if raycastResult or not flag then
				if raycastResult then
					part.CFrame = part.CFrame - part.Position + raycastResult.Position
				else
					result[part] = raycastResult ~= nil
				end
			else
				part:Destroy()
			end
		end

		return folder, result
	end,
	DeltaDelay = function(p: number, callback, ...)
		local v3 = { ... }
		return task.spawn(function()
			v2.DeltaWait(p)
			callback(unpack(v3))
		end)
	end,
	DeltaWait = function(p: number)
		if p then
			local total = 0

			while total < p do
				local RunService = game:GetService("RunService")
				total += RunService.Heartbeat:Wait()
			end
		else
			local RunService = game:GetService("RunService")
			RunService.Heartbeat:Wait()
		end
	end,
	createinfo = function(object)
		local attributes = object:GetAttributes()
		return TweenInfo.new(
			attributes.time,
			Enum.EasingStyle[attributes.style],
			Enum.EasingDirection[attributes.direction],
			tonumber(attributes.Repeat),
			attributes.reverse,
			(tonumber(attributes.delay))
		)
	end,
	TweenMethod = function(instance, _)
		local info = instance:FindFirstChild("info")
		local goal = instance:FindFirstChild("goal")
		local tweens = {}

		if not (info and goal) then
			return
		end

		local function createinfo(folder)
			local attributes = folder:FindFirstChild("info") and folder:FindFirstChild("info"):GetAttributes() or info:GetAttributes()
			return TweenInfo.new(
				attributes.time,
				Enum.EasingStyle[attributes.style],
				Enum.EasingDirection[attributes.direction],
				tonumber(attributes.Repeat),
				attributes.reverse,
				(tonumber(attributes.delay))
			)
		end

		for _, folder in goal:GetChildren() do
			if not folder:IsA("Folder") then
				return
			end

			local v4 = createinfo(folder)
			local attributes

			if folder.Name == "Part" or folder.Name == "MeshPart" then
				attributes = folder:GetAttributes()
			else
				attributes = false
			end

			if attributes and folder:GetAttribute("CFrame") then
				attributes.CFrame = instance.CFrame * attributes.CFrame
			end

			local tweenService = game.TweenService
			local v5 = instance:FindFirstChildOfClass(folder.Name) or instance

			if instance:FindFirstChildOfClass(folder.Name) or not attributes then
				attributes = folder:GetAttributes()
			end

			local tween = tweenService:Create(v5, v4, attributes)
			tweens[folder.Name .. "Tween"] = {
				Tween = tween,
				Instance = instance
			}
		end

		return {
			tweens = tweens,
			play = function()
				for _, v4 in tweens do
					local tween = v4.Tween
					local instance2 = v4.Instance
					tween:Play()
					instance2:SetAttribute("Pause", false)
					local completedConnection = nil
					local cancelChangedConnection = instance2:GetAttributeChangedSignal("Cancel"):Connect(function()
						tween:Cancel()
					end)
					local tween2 = tween
					local pauseChangedConnection = instance2:GetAttributeChangedSignal("Pause"):Connect(function()
						if instance2:GetAttribute("Pause") then
							tween2:Pause()
						else
							tween2:Play()
						end
					end)
					completedConnection = tween.Completed:Connect(function()
						cancelChangedConnection:Disconnect()
						pauseChangedConnection:Disconnect()
						completedConnection:Disconnect()
					end)
				end
			end
		}
	end,
	TweenMeshFlipbook = function(image, list, p, callback)
		local v3 = p or TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		image:IsA("ImageLabel")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateTexture(p2)
			local decal

			if image:IsA("ImageLabel") then
				decal = image
			else
				decal = image:FindFirstChildOfClass("Decal")
			end

			local v4 = decal and list[p2]

			if v4 then
				if image:IsA("ImageLabel") then
					decal.Image = v4
				else
					decal.Texture = v4
				end
			end
		end

		local v4 = #list
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 1
		local v5 = game.TweenService:Create(numberValue, v3, {
			Value = v4
		})
		v5:Play()
		local flag = false
		local changedConnection = nil
		local completedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cleanup()
			if flag then
				return
			end

			flag = true

			if changedConnection then
				changedConnection:Disconnect()
			end

			if completedConnection then
				completedConnection:Disconnect()
			end

			if numberValue then
				numberValue:Destroy()
			end
		end

		changedConnection = numberValue.Changed:Connect(function(p2)
			updateTexture(math.floor(p2)) -- equivalent call inferred; original call site unknown
		end)
		completedConnection = v5.Completed:Connect(function()
			cleanup() -- equivalent call inferred; original call site unknown

			if callback then
				task.spawn(callback)
			end
		end)

		if image then
			image.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					cleanup() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		return v5
	end,
	scaleModel = function(model, value)
		local v3

		if typeof(model) == "Instance" then
			v3 = model:IsA("Model")
		else
			v3 = false
		end

		assert(v3, "Input must be a Model")
		local v4

		if typeof(value) == "number" then
			v4 = value > 0
		else
			v4 = false
		end

		assert(v4, "Scale must be a positive number")

		local function scaleAttributes(descendant)
			local v5 = {
				"VertexColor",
				"Transparency",
				"delay",
				"Repeat",
				"time"
			}

			for k, v6 in descendant:GetAttributes() do
				if table.find(v5, k) then
					continue
				end

				if typeof(v6) == "Vector3" then
					descendant:SetAttribute(k, v6 * value)
				elseif typeof(v6) == "number" then
					descendant:SetAttribute(k, v6 * value)
				end
			end
		end

		model:ScaleTo(value)

		for _, descendant in model:GetDescendants() do
			scaleAttributes(descendant)
		end
	end,
	FixMesh = function(parent)
		local highlight = Instance.new("Highlight")
		highlight.Parent = parent
		highlight.OutlineTransparency = 1
		highlight.FillTransparency = 1
		return highlight
	end,
	PlayAttachment = function(folder, p, p2)
		for _, effect in pairs(folder:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				local attributes = effect:GetAttributes()
				local emitDelay = attributes.EmitDelay
				local emitDuration = attributes.EmitDuration or 0
				local v4 = effect
				task.delay(emitDelay, function()
					if emitDuration > 0 then
						task.defer(function()
							v4.Enabled = true
							task.wait(emitDuration)
							v4.Enabled = false
						end)
					else
						v4:Emit(attributes.EmitCount)
					end
				end)
			end

			if not effect:IsA("Beam") then
				continue
			end

			local attributes = effect:GetAttributes()
			local duration = attributes.Duration
			local v3 = not (p2 and p2.TweenTime) and 0.5 or p2.TweenTime
			local v4 = effect

			local function Shut_OFF()
				TweenService:Create(v4, TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Width1 = 0,
					Width0 = 0
				}):Play()
			end

			local v5 = effect

			local function Turn_ON()
				TweenService:Create(v5, TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Width1 = attributes.Width1,
					Width0 = attributes.Width0
				}):Play()
			end

			Turn_ON()

			if not duration then
				continue
			end

			local Shut_OFF2 = Shut_OFF
			task.delay(duration, function()
				Shut_OFF2()
			end)
		end

		if p then
			game.Debris:AddItem(folder, p)
		end
	end,
	PlayMeshes = function(model, options, p)
		local v3 = options or {}
		local scaleTO = p and p.scaleTO or false

		local function handle(instance)
			if instance:FindFirstChild("info") then
				v2.TweenMethod(instance).play()

				if instance:GetAttribute("Destroy") then
					task.delay(instance.info:GetAttribute("time"), instance.Destroy, instance)
				end
			end

			local flipbook = instance:GetAttribute("Flipbook")

			if flipbook and instance:FindFirstChild("tweeninfo") and v3[flipbook] then
				local v4 = v3[flipbook]
				v2.TweenMeshFlipbook(
					instance,
					v4,
					v2.createinfo(instance:FindFirstChild("tweeninfo")) or TweenInfo.new(0.5),
					function()
						if not instance:GetAttribute("Destroy") then
							return
						end

						instance:Destroy()
					end
				)
			end
		end

		if scaleTO then
			v2.scaleModel(model, scaleTO)
		end

		v2.FixMesh(model)

		if model:IsA("Model") then
			for _, child in model:GetChildren() do
				handle(child)
			end
		else
			handle(model)
		end
	end
}

function SwordBurst.FirstEvent(p)
	local char = p.Data.Char
	local _ = char.HumanoidRootPart
	local humanoid = char.Humanoid
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v3 then
			v3 = true
			object._maid:doCleaning()
		end
	end

	task.delay(6, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local KATANAWEAPON = char:FindFirstChild("#KATANAWEAPON")
	local v4 = nil

	for _, v6 in pairs(humanoid:GetPlayingAnimationTracks()) do
		if v6.Animation.AnimationId ~= "rbxassetid://125939352094096" then
			continue
		end

		v4 = v6
		break
	end

	v4:GetMarkerReachedSignal("slice"):Once(function()
		local function NewSlash()
			local primaryPart = char.PrimaryPart
			local v6 = nil
			local slash = vfx:FindFirstChild("Slash")

			if slash then
				slash = object._maid:give(slash:Clone())
				v2.AlignGroup(slash, char:GetPivot())
				slash.Parent = workspace.Thrown
				v2.PlayAttachment(slash, 8)
				v2.PlayMeshes(slash.Mesh, v)
				v2.DeltaDelay(0.07, function()
					if maid and maid.Over then
						return
					end

					v6 = object._maid:give(slash:Clone())
					v2.AlignGroup(v6, slash:GetPivot())
					v6.Parent = workspace.Thrown
					task.delay(4, function()
						if v6 and v6.Parent then
							v6:Destroy()
						end
					end)
					slash:Destroy()
				end)
			end

			local freeze = vfx:FindFirstChild("Freeze")

			if freeze then
				freeze = object._maid:give(freeze:Clone())
				v2.AlignGroup(freeze, slash:GetPivot())
				freeze.Parent = EFP
				game.Debris:AddItem(freeze, 4)
				v2.PlayAttachment(freeze.FX, 8)

				for _, emitter in freeze:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v7 = emitter
					task.delay(emitter:GetAttribute("delaa") or 0.1, function()
						if v7 and v7.Parent then
							v7.TimeScale = 0
						end
					end)
				end
			end

			local flag = false

			local function fn(_: boolean)
				if not (char and primaryPart) or flag then
					return
				end

				if maid and maid.Over then
					if v6 and v6.Parent then
						v6:Destroy()
					end

					slash:Destroy()
					freeze:Destroy()
					flag = true
				else
					flag = true

					if slash then
						v2.PlayMeshes(v6.Mesh, v)
					end

					if freeze then
						for _, emitter in freeze:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter.TimeScale = 1
							end
						end
					end
				end
			end

			task.delay(2.4, function()
				fn()
			end)
			object._maid:give(function()
				fn()
			end)
		end

		local function SlashV2()
			local slashesh22 = vfx.slashesh22
			local folder = quickFX({
				FX = slashesh22,
				Maid = object._maid,
				Anchor = char:GetPivot() * CFrame.new(0, 0, -14) * slashesh22:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(folder)
			object.slashesh22 = folder

			for _, emitter in pairs(folder:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(emitter, TweenInfo.new(0.2), {
					TimeScale = 0.001
				}):Play()
			end
		end

		SlashV2()
		NewSlash()
	end)
	local v6 = {}
	tick()
	local folder = nil
	v4.Stopped:Once(function()
		for _, folder2 in pairs(v6) do
			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end

		if folder then
			for _, effect in pairs(folder:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end
	end)
	v4:GetMarkerReachedSignal("sheathe"):Once(function()
		shared.vfx.emit(KATANAWEAPON.bladetest1.W3)

		for _, folder2 in pairs(v6) do
			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end

		for _, effect in pairs(folder:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local slashesh22 = object.slashesh22

		for _, emitter in pairs(slashesh22:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(emitter, TweenInfo.new(0.1), {
				TimeScale = 1
			}):Play()
		end

		local slashesh2 = vfx.slashesh2
		local v7 = quickFX({
			FX = slashesh2,
			Maid = object._maid,
			Anchor = char:GetPivot() * CFrame.new(0, 0, -11) * slashesh2:GetAttribute("Offset"):Inverse()
		})
		game.Debris:AddItem(v7, 4)
		shared.vfx.emit(v7)
	end)
	v4:GetMarkerReachedSignal("return"):Once(function()
		task.delay(0.065, function()
			if KATANAWEAPON then
				folder = object._maid:give(vfx.KatanaTemplate.Main:Clone())
				folder.Parent = EFP
				local main = KATANAWEAPON:FindFirstChild("Main")

				if main then
					local cube001 = KATANAWEAPON:FindFirstChild("Cube.001")

					if cube001 then
						for _, v7 in pairs({ vfx.bladetest1, vfx.bladetest2 }) do
							local v8 = object._maid:give(v7:Clone())
							v8.Parent = KATANAWEAPON
							table.insert(v6, v8)
							local weld = Instance.new("Weld")
							weld.Part0 = cube001
							weld.Part1 = v8
							weld.Parent = v8
						end
					end

					local weld = Instance.new("Weld")
					weld.Part0 = folder
					weld.Part1 = main
					weld.Parent = folder
				end

				shared.vfx.emit(folder.Attachmentmain.Spark)
			end
		end)

		if KATANAWEAPON then
			task.wait(0.125)
			shared.vfx.emit(KATANAWEAPON.bladetest1.W2)
		end
	end)
	task.delay(3.05, function()
		if v4.IsPlaying and KATANAWEAPON then
			shared.vfx.emit(KATANAWEAPON.bladetest2)
		end
	end)
	wait(5)
	Clean() -- equivalent call inferred; original call site unknown
end

return SwordBurst