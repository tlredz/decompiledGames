local createVector = vector.create
local realAssets = script.RealAssets
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }
local v = {}
local v2 = {
	Cam = { 112471633691073, 92872400083350 },
	CamEntire = { 81703661217800 },
	CamEzee = { 103566103210307 },
	CamRig = { 137845184446346 },
	CamRigNy = { 123321332402974 },
	CamRigWithLetterBox = { 103941810523228 },
	CamRigWithLetterBox3 = { 126468024889342 },
	CamRigWithLetterBox4 = { 105254849512612 },
	CamRigWithLetterBoxNewYer = { 125516476904316 },
	CamRigWithLetterBoxMech = { 85186887257470 },
	CameraFunny = { 124958014257711 },
	CameraRigBeast = { 96912364616540 },
	CameraRigVegetable = { 100366125413969 },
	CameraRigK = { 123782653232583 },
	EmergeCamera = { 97448479871185 },
	camOhio = { 99684244248954 },
	cambreath = { 84807030759844 },
	CamRigDook = { 77272264662660 },
	fx_CAM = { 71237135972087 },
	kakashicamrig = { 89179955166459 }
}

for _, moduleScript in pairs(script.VfxMods:GetChildren()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local v3 = tostring(moduleScript)
	local module = require(moduleScript)
	v[v3] = module
end

task.delay(10, function()
	if isClient then
		warn("g")
		local tracks = {}

		for childName, list in pairs(v2) do
			local child = script.Assets:FindFirstChild(childName)
			local animationController = child and child:FindFirstChildOfClass("AnimationController")

			if not animationController then
				continue
			end

			for _, v3 in ipairs(list) do
				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://" .. v3
				game.Debris:AddItem(animation, 8)
				local track = animationController:LoadAnimation(animation)
				track:Play(0, 1, 1)
				track.TimePosition = 0.01
				tracks[#tracks + 1] = track
				task.wait(0.5)
			end
		end

		task.delay(0.25, function()
			for _, v3 in ipairs(tracks) do
				if v3 and v3.IsPlaying then
					v3:Stop(0.001)
				end
			end
		end)
	end
end)

function shared.NerfVfx(data)
	local char = data.Char
	local v3 = game.Players.LocalPlayer.Character == char
	local rateNerf = data.RateNerf or 1.5
	local emitCountNerf = data.EmitCountNerf or 1.5
	local flag = true
	local script2 = data.Script

	if script2:GetAttribute("RateNerf") then
		rateNerf = script2:GetAttribute("RateNerf")
	end

	if script2:GetAttribute("EmitCountNerf") then
		emitCountNerf = script2:GetAttribute("EmitCountNerf")
	end

	if script2:GetAttribute("DidNerf") then
		script2:SetAttribute("DidNerf", false)
		flag = false
	elseif v3 then
		return
	else
		script2:SetAttribute("DidNerf", true)
	end

	for _, emitter in pairs(script2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if flag then
			emitter.Rate /= rateNerf

			if emitter:GetAttribute("EmitCount") and typeof(emitter:GetAttribute("EmitCount")) == "number" and emitter:GetAttribute("EmitCount") / emitCountNerf > 0 then
				emitter:SetAttribute("EmitCount", emitter:GetAttribute("EmitCount") / emitCountNerf)
			end
		else
			emitter.Rate *= rateNerf

			if emitter:GetAttribute("EmitCount") and typeof(emitter:GetAttribute("EmitCount")) == "number" then
				emitter:SetAttribute("EmitCount", emitter:GetAttribute("EmitCount") * emitCountNerf)
			end
		end
	end
end

if isClient then
	for k, v3 in pairs({
		Boundless = {
			RateNerf = 2.5,
			EmitCountNerf = 2.5
		},
		FS = {
			RateNerf = 2.15,
			EmitCountNerf = 2.5
		},
		Evolved = {
			RateNerf = 1.75,
			EmitCountNerf = 1.75
		},
		Flasher = {
			RateNerf = 2,
			EmitCountNerf = 2
		},
		Emerge = {
			RateNerf = 2,
			EmitCountNerf = 2
		},
		Electric = {
			RateNerf = 3,
			EmitCountNerf = 3
		},
		LifeformVfx = {
			RateNerf = 2,
			EmitCountNerf = 2
		},
		TrueRage = {
			RateNerf = 4,
			EmitCountNerf = 4
		}
	}) do
		local vfxMod = script.VfxMods[tostring(k)]
		vfxMod:SetAttribute("RateNerf", v3.RateNerf)
		vfxMod:SetAttribute("EmitCountNerf", v3.EmitCountNerf)
	end
end

local function fn(character, from)
	for _, child in pairs(character:GetChildren()) do
		if tostring(child) == tostring(from) then
			return child
		end
	end
end

local function fn2(items, intensity, p2)
	for _, item in pairs(items) do
		if item ~= game.Players.LocalPlayer.Character then
			continue
		end

		shared.repfire({
			Effect = "Camshake",
			Intensity = intensity,
			Last = p2 or nil
		})
		break
	end
end

function shared.smoothout(p, value)
	local currentCamera = workspace.CurrentCamera
	local v3 = p or currentCamera.CFrame
	local v4 = {
		Timeduration = 1,
		EasingStyle = Enum.EasingStyle.Exponential,
		EasingDirection = Enum.EasingDirection.Out
	}
	tick()
	local lastTime = os.clock()
	local RunService2 = game:GetService("RunService")
	RunService2:BindToRenderStep("CutsceneCameraSmoothOut" .. lastTime, Enum.RenderPriority.Camera.Value, function()
		local cFrame = currentCamera.CFrame
		local v5 = (os.clock() - lastTime) / (value or 0.55)

		if v5 >= 1.1 then
			local RunService3 = game:GetService("RunService")
			RunService3:UnbindFromRenderStep("CutsceneCameraSmoothOut" .. lastTime)
		else
			local shakes = shared.shakes or { 0, 0, 0 }
			currentCamera.CFrame = v3:Lerp(
				cFrame + Vector3.new(shakes[1], shakes[2], shakes[3]) / 1.15,
				TweenService:GetValue(v5, v4.EasingStyle, v4.EasingDirection)
			)
		end
	end)
	local custom = Enum.CameraType.Custom

	if shared.isconsole or shared.ismobile then
		custom = Enum.CameraType.Track
	end

	local humanoid = game.Players.LocalPlayer.Character.Humanoid
	currentCamera.CameraType = custom
	currentCamera.CameraSubject = humanoid
	print(currentCamera.CameraType)
	shared.SetCore(true, nil, true)
end

local function fn3(p, list)
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local RunService2 = game:GetService("RunService")

	if p.Char == localPlayer.Character then
		p.ForOthers = nil
	else
		local flag = true
		local flag2

		for _, v3 in pairs(p) do
			if v3 ~= localPlayer.Character then
				continue
			end

			flag2 = true
			flag = false
			break
		end

		if flag then
			flag2 = nil
		end

		if flag2 then
			p.ForOthers = nil
		end
	end

	if not p.Char or p.Force then
		p.Char = localPlayer.Character
	end

	if p.EmoteCall and localPlayer.Character ~= p.Char then
		return
	end

	local findPart = p.FindPart
	local clone = nil
	local camera = nil

	if findPart then
		local v3 = nil

		local function fn4()
			for _, part in pairs(p.Char.PrimaryPart:GetChildren()) do
				if not part:IsA("Part") or tostring(part) ~= findPart or part:GetAttribute("Done") then
					continue
				end

				part:SetAttribute("Done", true)
				part:SetAttribute("Custom2V1CAM", true)
				camera = part
				v3 = camera
				break
			end
		end

		local lastTime = tick()

		repeat
			task.wait()
			fn4()
		until tick() - lastTime >= 0.15 or v3 ~= nil

		if not v3 then
			return
		end

		table.insert(list, v3)
		findPart = v3
		clone = v3
		camera = v3
	end

	local bind = p.Bind
	local v3 = bind ~= nil

	if p.StopOthers then
		local accessory = Instance.new("Accessory")
		accessory.Name = "StopOthers"
		accessory:SetAttribute("customstop", p.customstop or nil)
		accessory.Parent = localPlayer.Character
		game.Debris:AddItem(accessory, 1)
	end

	local userChar = p.UserChar
	local character = localPlayer.Character
	character:SetAttribute("Ticker", (math.random(1, 100000)))
	local forceAco = p.ForceAco

	if not findPart then
		if p.SpecificRig then
			clone = p.SpecificRig:Clone()

			if p.ActualPart and clone:IsA("Model") then
				camera = clone[p.ActualPart]
			end
		else
			clone = script.Assets.CamRigWithLetterBox:Clone()
			camera = clone.camera
		end
	end

	local currentCamera = workspace.CurrentCamera

	if not findPart then
		clone.Parent = p.Char

		if clone:IsA("Model") then
			clone:SetAttribute("CameraModel", true)

			if p.From then
				clone:SetPrimaryPartCFrame(p.From.CFrame * p.Offset)
			else
				clone:SetPrimaryPartCFrame(p.SpoofedCFrame * p.Offset)
			end
		end
	end

	if list then
		table.insert(list, clone)
	end

	local fov = p.Fov or p.FOV
	local module = nil

	if fov then
		for _, child in pairs(currentCamera:GetChildren()) do
			if tostring(child) == "FieldOfView" then
				child:Destroy()
			end
		end

		if fov:IsA("ModuleScript") then
			module = require(fov)
		else
			local clone2 = fov:Clone()
			clone2.Name = "FieldOfView"
			clone2.Parent = clone
		end
	end

	local v4 = not p.deletiontime and 32 or p.deletiontime
	local CollectionService = game:GetService("CollectionService")
	CollectionService:AddTag(clone, (p.Id or "camwork_") .. p.Char.Name)
	game.Debris:AddItem(clone, v4)
	local v5 = nil
	local track = nil
	local weld = nil
	local pivot = false
	(function()
		for _, child in pairs(script.prels:GetChildren()) do
			if child.AnimationId ~= p.Anim then
				continue
			end

			v5 = child
			break
		end
	end)()

	if not findPart then
		if not v5 and p.Anim then
			v5 = Instance.new("Animation")
			game.Debris:AddItem(v5, v4)
			v5.AnimationId = "rbxassetid://" .. p.Anim
		end

		if clone:IsA("Model") then
			if p.SpoofedCFrame then
				clone.PrimaryPart.Anchored = true
				clone:PivotTo(p.SpoofedCFrame * p.Offset)
				task.delay(1, function()
					if clone and clone.Parent then
						pivot = clone:GetPivot()
					end
				end)
			else
				weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = p.From
				weld.Part1 = clone.PrimaryPart
				weld.C0 = p.Offset
			end

			local animationController = clone:FindFirstChildOfClass("AnimationController")
			local humanoid = clone:FindFirstChildOfClass("Humanoid")

			if not animationController and humanoid then
				animationController = humanoid
			end

			track = animationController:LoadAnimation(v5)
			track.Looped = false

			for _, v6 in pairs(animationController:GetPlayingAnimationTracks()) do
				v6:Stop(0)
			end
		elseif v5 and v5.Parent then
			v5:Destroy()
		end
	end

	local renderSteppedConnection = nil

	if p.UseCFrameEventually then
		task.delay(p.CFrameUsageTime or 5, function()
			p.SpoofedCFrame = p.From.CFrame
			p.From = nil

			if weld and weld.Parent then
				weld:Destroy()
			end

			clone.PrimaryPart.Anchored = true
			clone:PivotTo(p.SpoofedCFrame * p.Offset)
		end)
	end

	local numberValue = Instance.new("NumberValue")
	game.Debris:AddItem(numberValue, v4)
	numberValue.Value = 0.1
	TweenService:Create(
		numberValue,
		TweenInfo.new(p.LerpTime or 3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			Value = 0.5
		}
	):Play()

	if p.preload then
		if not game.Players.LocalPlayer.Character:WaitForChild("cutscenefire", 15) then
			return
		end

		if p.customdata == "portal" then
			local guide = p.guide

			if guide and guide.Parent then
				task.delay(1.5, function()
					task.spawn(function()
						for _ = 1, 35 do
							guide:PivotTo(p.From.CFrame * CFrame.new(0, -3, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1))
							task.wait()
						end
					end)
				end)
			end
		end
	end

	shared.SetCore(false, 3)
	local accessory = Instance.new("Accessory")
	accessory.Name = "NoRotate"
	accessory.Parent = p.Char
	game.Debris:AddItem(accessory, 35)

	if list then
		table.insert(list, accessory)
	end

	local flag = false
	local cameraSubject = currentCamera.CameraSubject
	local cloneOwner = character:GetAttribute("CloneOwner")
	local cFrame = currentCamera.CFrame
	local fn4

	fn4 = function(_, p2)
		if flag then
			return
		end

		cFrame = currentCamera.CFrame

		if p.ForOthers then
			return
		end

		local cameraSmoothTransition = localPlayer.Character:FindFirstChild("CameraSmoothTransition")

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
		end

		flag = true
		local v6 = not (p2 and p2.specialcall)
		local stopOthers = character:FindFirstChild("StopOthers")

		if stopOthers and not (stopOthers:GetAttribute("customstop") or stopOthers:GetAttribute("ultimateforce")) then
			v6 = false
		end

		if p.dontfix and v6 or stopOthers and stopOthers:GetAttribute("ultimateforce") then
			workspace.CurrentCamera.FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70

			if accessory then
				accessory:Destroy()
			end

			for _, v8 in pairs({ numberValue, clone }) do
				if v8 and v8.Parent then
					v8:Destroy()
				end
			end

			if not (stopOthers and stopOthers:GetAttribute("ultimateforce")) then
				task.delay(0.2, function()
					local cFrame2 = workspace.CurrentCamera.CFrame
					task.wait(0.75)

					if workspace.CurrentCamera.CFrame == cFrame2 and workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable and not (localPlayer.Character:FindFirstChild("RootAnchor") or localPlayer.Character:FindFirstChild("Freeze")) then
						flag = false
						p.dontfix = false
						p.smooth = false
						p.smoothin = false
						fn4()
					end
				end)
				return
			end

			stopOthers:Destroy()
			flag = true
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
			currentCamera.FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
			shared.SetCore(true, 3)
		elseif p.pauseothers then
			character:SetAttribute("PausedCutscene", nil)

			if accessory then
				accessory:Destroy()
			end

			for _, v8 in pairs({ numberValue, clone }) do
				if v8 and v8.Parent then
					v8:Destroy()
				end
			end
		else
			if not localPlayer:FindFirstChild("SkippedEmote") then
				task.spawn(function()
					local stopCutsceneFire = character:FindFirstChild("StopCutsceneFire")
					local v7 = not stopCutsceneFire and 0 or tonumber(stopCutsceneFire:GetAttribute("CoreDelay"))
					currentCamera.FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
					task.delay(v7, function()
						shared.SetCore(true, 3)
					end)

					local function fn5()
						if character:FindFirstChild("Freeze") then
							return
						else
							return true
						end
					end

					if fn5 then
						local lastTime = tick()

						repeat
							task.wait()

							if fn5 then
								workspace.CurrentCamera.FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
							end
						until workspace.CurrentCamera.FieldOfView == 70 or character:FindFirstChild("Freeze") or tick() - lastTime >= 0.1
					end
				end)

				if tostring(p.Anim) == "112471633691073" and p.Char == localPlayer.Character then
					for _, v7 in pairs(p.Char.Humanoid:GetPlayingAnimationTracks()) do
						if v7.Animation.AnimationId ~= "rbxassetid://107649573628906" then
							continue
						end

						v7:Play(0)
						v7:Stop(0)
					end
				end

				accessory:Destroy()
				local custom = Enum.CameraType.Custom

				if shared.isconsole or shared.ismobile then
					custom = Enum.CameraType.Track
				end

				local noSmoothTransition = character:FindFirstChild("NoSmoothTransition")

				if (p.smooth or cameraSmoothTransition) and not noSmoothTransition and p.Char == localPlayer.Character then
					if cameraSmoothTransition then
						cameraSmoothTransition:Destroy("")
					end

					if character:GetAttribute("CloneOwner") then
						local v7 = nil

						for _, child in pairs(workspace.Live:GetChildren()) do
							if child.Name ~= character:GetAttribute("CloneOwner") then
								continue
							end

							cameraSubject = child.Torso
							v7 = child
							break
						end

						if v7 and v7:GetAttribute("TooSlow") then
							return
						end
					end

					if cloneOwner and character:GetAttribute("Old") == cloneOwner then
						return
					end

					if not (p.CutsceneBind or p.DontDestroy) then
						for _, v8 in pairs({ numberValue, clone }) do
							if v8 and v8.Parent then
								v8:Destroy()
							end
						end
					end

					local v7 = {
						Timeduration = 1,
						EasingStyle = Enum.EasingStyle.Exponential,
						EasingDirection = Enum.EasingDirection.Out
					}
					local lastTime = os.clock()
					local v8 = false
					local cFrame2 = currentCamera.CFrame
					local v9 = false
					RunService2:BindToRenderStep(
						"CutsceneCameraSmoothOut" .. lastTime,
						Enum.RenderPriority.Camera.Value,
						function()
							local cFrame3 = currentCamera.CFrame
							local v10 = (os.clock() - lastTime) / (p.smoothtime or 0.6)

							if math.abs((math.deg((math.acos((math.clamp(
								cFrame3.LookVector:Dot(cFrame2.LookVector),
								-1,
								1
							))))))) > 1.75 then
								v8 = true
							end

							if v8 or v9 and currentCamera.CameraType == Enum.CameraType.Scriptable then
								RunService2:UnbindFromRenderStep("CutsceneCameraSmoothOut" .. lastTime)
							elseif v10 >= 1 then
								RunService2:UnbindFromRenderStep("CutsceneCameraSmoothOut" .. lastTime)
							else
								currentCamera.CFrame = cFrame:Lerp(
									cFrame3,
									TweenService:GetValue(v10, v7.EasingStyle, v7.EasingDirection)
								)
							end
						end
					)
					currentCamera.CameraType = custom
					currentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
					v9 = true
					local stopCutsceneFire = p.Char:FindFirstChild("StopCutsceneFire")
					local coreDelay

					if stopCutsceneFire then
						coreDelay = tonumber(stopCutsceneFire:GetAttribute("CoreDelay"))
					end

					if coreDelay then
						task.wait(coreDelay)
					end

					shared.SetCore(true, nil, true)
					return
				else
					if character:GetAttribute("CloneOwner") then
						local v7 = nil

						for _, child in pairs(workspace.Live:GetChildren()) do
							if child.Name ~= character:GetAttribute("CloneOwner") then
								continue
							end

							cameraSubject = child.Torso
							v7 = child
							break
						end

						if v7 and v7:GetAttribute("TooSlow") then
							return
						end
					end

					if cloneOwner and character:GetAttribute("Old") == cloneOwner then
						return
					end

					currentCamera.CameraType = custom
					currentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
				end
			end

			if not (p.CutsceneBind or p.DontDestroy) then
				for _, v8 in pairs({ numberValue, clone }) do
					if v8 and v8.Parent then
						v8:Destroy()
					end
				end
			end

			shared.SetCore(true, nil, true)
		end
	end

	local lastTime = tick()
	local specificStart = 0

	if track then
		if p.notinstant then
			track:Play()
		else
			track:Play(0)
		end
	end

	if p.synchronise then
		task.delay(0.5, function()
			if p.TimePosition then
				track.TimePosition = p.TimePosition + 0.5
			else
				track.TimePosition = 0.5
			end
		end)
	end

	if p.TimePosition then
		track.TimePosition = p.TimePosition
	end

	local coscFOV

	if p.portal then
		coscFOV = script.Fovs.CoscFOV
	else
		coscFOV = nil
	end

	if p.CustomSpeed then
		track:AdjustSpeed(p.CustomSpeed)
	end

	local v6 = false

	if p.SpecificStart then
		specificStart = p.SpecificStart
		forceAco = true
	end

	local lastTime2 = tick()
	local v7 = false
	local cframe = nil

	if not clone:GetAttribute("AnimSpeedAdjustment") then
		clone:SetAttribute("AnimSpeedAdjustment", 1)
	end

	if p.CustomSpeed then
		clone:SetAttribute("AnimSpeedAdjustment", p.CustomSpeed)
	end

	if p.EmberDelay then
		task.delay(3, function()
			track:AdjustSpeed(0.8)
		end)
	end

	local animSpeedAdjustment = clone:GetAttribute("AnimSpeedAdjustment")

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end

	if not p.ForOthers then
		workspace.Camera:SetAttribute("paused", false)
	end

	local doingEmote

	if userChar then
		doingEmote = userChar:FindFirstChild("DoingEmote")
	else
		doingEmote = nil
	end

	local v8 = nil
	local v9 = false
	local name = p.Name

	if name and not localPlayer.Character:FindFirstChild("DelayRespawn") then
		name = nil

		for _, v11 in pairs(localPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
			if v11.Animation.AnimationId ~= "rbxassetid://113450724032380" then
				continue
			end

			v8 = v11
			v9 = true
			break
		end
	end

	if p.NoLerpFast then
		task.delay(p.NoLerpFast, function()
			p.NoLerp = true

			if p.Relerp then
				task.delay(0.5, function()
					p.NoLerp = false
				end)
			end
		end)
	end

	local subject = p.Subject
	local cameraSubject2 = nil

	if subject then
		if typeof(subject) == "string" then
			cameraSubject2 = clone:FindFirstChild(subject) or cameraSubject2
		end

		cameraSubject2 = cameraSubject2 or camera
		currentCamera.CameraSubject = cameraSubject2
	end

	local lastTime3 = os.clock()
	local cFrame2 = currentCamera.CFrame
	local cframe2 = CFrame.new()

	if p.ManualOffset and clone:FindFirstChild("ManualFrames") then
		local specificStart2 = p.SpecificStart
		local manualFrames = clone.ManualFrames
		local value

		if manualFrames:IsA("ModuleScript") then
			local module2 = require(manualFrames)
			value = module2[math.ceil(specificStart2)]
		else
			local child = manualFrames:FindFirstChild((tostring((math.ceil(specificStart2)))))
			value = child and child.Value
		end

		if value then
			cframe2 = value:Inverse()
		end
	end

	local cFrame3

	if p.FirstCFrame then
		cFrame3 = p.Char.PrimaryPart.CFrame
	else
		cFrame3 = nil
	end

	local pauseothers = p.pauseothers

	if pauseothers then
		character:SetAttribute("PausedCutscene", true)
	end

	local flag2 = false

	if p.stoptime then
		task.delay(p.stoptime, function()
			return fn4()
		end)
	end

	local manualFrames = clone:FindFirstChild("ManualFrames")
	local module2

	if manualFrames and manualFrames:IsA("ModuleScript") then
		module2 = require(manualFrames)
		manualFrames = nil
	else
		module2 = nil
	end

	local fieldOfView = clone:FindFirstChild("FieldOfView") or clone:FindFirstChild("FOV")

	if fieldOfView and fieldOfView:IsA("ModuleScript") then
		module = module or require(fieldOfView)
		fieldOfView = nil
	end

	renderSteppedConnection = RunService2.RenderStepped:Connect(function(dt)
		if character:GetAttribute("PausedCutscene") and not pauseothers then
			if not flag2 then
				if not p.keepcutscenemoving then
					track:AdjustSpeed(0)
				end

				flag2 = true
			end
		else
			if flag2 then
				track:AdjustSpeed(animSpeedAdjustment or 1)
				flag2 = false
			end

			if flag or p.ForOthers then
				return renderSteppedConnection:Disconnect()
			end

			local character2 = localPlayer.Character
			local stopOthers = character2 and character2:FindFirstChild("StopOthers")

			if stopOthers and stopOthers:GetAttribute("customstop") then
				stopOthers = nil
			end

			if stopOthers and stopOthers:GetAttribute("ultimateforce") or (character2 and character2:FindFirstChild("Ragdoll") or stopOthers and not p.StopOthers) then
				return fn4(nil, {
					specialcall = true
				})
			end

			if not character or not character.Parent or character:FindFirstChild("CancelEmote") then
				fn4()
				return renderSteppedConnection:Disconnect()
			end

			if v9 and not (v8 and v8.IsPlaying) then
				fn4(nil, {
					specialcall = true
				})
				return renderSteppedConnection:Disconnect()
			end

			if name and name == "Last Will" and character2 and not character2:FindFirstChild("DelayRespawn") then
				fn4()
				return renderSteppedConnection:Disconnect()
			end

			if not (character2 and character2.Parent) then
				fn4(nil, {
					specialcall = true
				})
				return renderSteppedConnection:Disconnect()
			end

			if workspace:FindFirstChild("CancelCutscene") then
				fn4()
				return renderSteppedConnection:Disconnect()
			end

			if doingEmote and userChar and (userChar:FindFirstChild("CancelEmote2") or userChar:FindFirstChild("CancelEmote")) then
				fn4()
				return renderSteppedConnection:Disconnect()
			end

			local paused = workspace.Camera:GetAttribute("Paused")

			if paused and workspace:FindFirstChild("ForceStopCutscenes") then
				fn4()
				return
			end

			if v3 and (not bind or not bind.Parent or bind.Parent and bind:GetAttribute("ForceDestroy")) then
				renderSteppedConnection:Disconnect()
				return fn4()
			end

			if not (paused or flag or character:FindFirstChild("Distorting")) then
				if not (camera and (camera.Parent or forceAco) or forceAco) then
					renderSteppedConnection:Disconnect()
					return fn4()
				end

				if p.Subject and currentCamera.CameraSubject ~= cameraSubject2 then
					currentCamera.CameraSubject = cameraSubject2
				end

				local animSpeedAdjustment2 = clone:GetAttribute("AnimSpeedAdjustment")

				if animSpeedAdjustment2 ~= animSpeedAdjustment then
					animSpeedAdjustment = animSpeedAdjustment2
					track:AdjustSpeed(animSpeedAdjustment)
				end

				local v11 = dt * 60
				specificStart += v11
				local v12

				if p.Time then
					v12 = math.ceil(track.TimePosition * 60)
				else
					v12 = math.ceil(specificStart)
				end

				local vector2 = createVector(0, 0, 0)

				if clone:IsA("Model") and (not clone.Parent or clone:GetAttribute("ForceDestroy") or p.AnimSent and not p.AnimSent.IsPlaying) then
					renderSteppedConnection:Disconnect()
					return fn4()
				end

				if p.CFrameRetain and camera.CFrame ~= pivot and typeof(pivot) == "CFrame" then
					clone:PivotTo(pivot)
				end

				if shared.currenttopbar and shared.currenttopbar.b ~= false then
					shared.SetCore(false, 3)
				end

				local module3 = module or fieldOfView and fieldOfView.Parent and fieldOfView or nil

				if not module3 and coscFOV then
					if typeof(coscFOV) == "Instance" and coscFOV:IsA("ModuleScript") then
						module3 = require(coscFOV)
					else
						module3 = coscFOV
					end
				end

				if p.NoFov then
					module3 = false
				end

				if p.StopFOVAfter and tick() - lastTime > p.StopFOVAfter then
					module3 = nil
				end

				if p.SlowAfter and tick() - lastTime > p.SlowAfter and not v7 then
					v7 = true
					track:AdjustSpeed(0.1)
					cframe = true
				end

				if p.EnableShakeAfter and tick() - lastTime > p.EnableShakeAfter then
					local shakes = shared.shakes or { 0, 0, 0 }
					vector2 = Vector3.new(shakes[1], shakes[2], shakes[3])
					numberValue.Value = 1 - 2.5e-7 ^ dt
				end

				if manualFrames and manualFrames.Parent or module2 then
					local value, child

					if module2 then
						value = module2[math.ceil(specificStart)]
						child = value ~= nil and 1 or nil
					else
						child = manualFrames:FindFirstChild((math.ceil(specificStart)))
						value = child and child.Value
					end

					if child then
						v6 = true

						if p.ManualOffset then
							local cFrame4 = p.Char.PrimaryPart.CFrame

							if p.UseCFrame then
								cFrame4 = p.UseCFrame
							end

							if p.FirstCFrame and cFrame3 then
								cFrame4 = cFrame3
							end

							currentCamera.CFrame = cFrame4 * (p.ManualOffset or CFrame.new()) * cframe2 * value
						else
							currentCamera.CFrame = p.Char.PrimaryPart.CFrame * value
						end

						if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
							currentCamera.CameraType = Enum.CameraType.Scriptable
						end
					end

					if not child and v6 or character2 and character2:FindFirstChild("stoprncam") then
						fn4()
					end
				else
					if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
						currentCamera.CameraType = Enum.CameraType.Scriptable
					end

					if p.basic then
						if tick() - lastTime2 >= 0.25 then
							currentCamera.CFrame = camera.CFrame + vector2
						else
							currentCamera.CFrame = currentCamera.CFrame:Lerp(camera.CFrame, 1 - 0.00001 ^ dt)
						end
					else
						local noLerpAfter

						if p.NoLerp then
							noLerpAfter = not cframe
						else
							noLerpAfter = p.NoLerpAfter

							if noLerpAfter then
								if numberValue.Value == 0.5 then
									noLerpAfter = not cframe
								else
									noLerpAfter = false
								end
							end
						end

						if p.LerpAfter and numberValue.Value == 0.5 then
							noLerpAfter = false
						end

						if noLerpAfter then
							currentCamera.CFrame = camera.CFrame + vector2
						else
							local v13 = 1 - 0.00001 ^ dt
							local v14 = camera.CFrame + vector2

							if cframe then
								if cframe == true then
									cframe = CFrame.lookAlong(v14.Position, v14.LookVector * createVector(1, 0, 1))
								end

								if cframe ~= true then
									v14 = v14 - cframe.lookVector * 35 + createVector(0, 7, 0)
								end
							end

							currentCamera.CFrame = currentCamera.CFrame:Lerp(v14, v13)
						end
					end
				end

				if p.smoothin then
					local smoothinTime = p.smoothinTime or 0.75
					local v13 = (os.clock() - lastTime3) / smoothinTime

					if v13 < 0.75 then
						currentCamera.CFrame = cFrame2:Lerp(
							currentCamera.CFrame,
							TweenService:GetValue(v13, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
						)
					end
				end

				if module3 and not flag then
					if type(module3) == "table" then
						local v13 = module3[v12]

						if v13 ~= nil then
							if p.NoLerp and not p.fovlerp or p.NoLerpAfter and numberValue.Value == 0.5 then
								currentCamera.FieldOfView = tonumber(v13)
								return
							end

							local v14 = currentCamera
							local fieldOfView2 = currentCamera.FieldOfView
							v14.FieldOfView = fieldOfView2 + (tonumber(v13) - fieldOfView2) * 0.25
						end
					else
						local start = module3:FindFirstChild("start")
						local values = module3:FindFirstChild((tostring(v12)))
						local flag3

						if start and not values then
							values = start.Values
							flag3 = true
						else
							flag3 = false
						end

						if values then
							if not values:IsA("NumberValue") then
								if flag3 then
									values = values:FindFirstChild((tostring(v12)))
								else
									values = values.Values:FindFirstChildOfClass("NumberValue")
								end
							end

							if values and values:IsA("NumberValue") then
								if p.NoLerp and not p.fovlerp or p.NoLerpAfter and numberValue.Value == 0.5 then
									currentCamera.FieldOfView = tonumber(values.Value)
									return
								end

								local v13 = currentCamera
								local fieldOfView2 = currentCamera.FieldOfView
								v13.FieldOfView = fieldOfView2 + (tonumber(values.Value) - fieldOfView2) * 0.25
							end
						end
					end
				end
			end
		end
	end)
	local stoppedConnection

	if track then
		stoppedConnection = track.Stopped:Connect(function()
			fn4()
		end)
	else
		stoppedConnection = nil
	end

	clone:GetPropertyChangedSignal("Parent"):Connect(function()
		if clone.Parent or flag then
			return
		end

		wait(1)

		if flag then
			return
		end

		fn4(nil, {
			specialcall = true
		})
	end)
	p.Char:GetPropertyChangedSignal("Parent"):Once(function()
		if not p.Char.Parent then
			fn4(nil, {
				specialcall = true
			})
		end
	end)
	task.delay(v4, function()
		if stoppedConnection then
			stoppedConnection:Disconnect()
		end

		if renderSteppedConnection then
			fn4(nil, {
				specialcall = true
			})
		end
	end)
	return fn4, clone, weld, track
end

local _ = {
	[191] = {
		fov = 50,
		style = Enum.EasingStyle.Linear
	},
	[235] = {
		fov = 50,
		style = Enum.EasingStyle.Quad,
		dir = Enum.EasingDirection.InOut
	},
	[279] = {
		fov = 65
	},
	[421] = {
		fov = 45,
		style = Enum.EasingStyle.Linear
	},
	[513] = {
		fov = 45,
		style = Enum.EasingStyle.Quad,
		dir = Enum.EasingDirection.In
	},
	[530] = {
		fov = 20,
		style = Enum.EasingStyle.Linear
	},
	[576] = {
		fov = 20,
		style = Enum.EasingStyle.Circular,
		dir = Enum.EasingDirection.In
	},
	[600] = {
		fov = 54,
		style = Enum.EasingStyle.Linear
	},
	[749] = {
		fov = 54,
		style = Enum.EasingStyle.Quart,
		dir = Enum.EasingDirection.InOut
	},
	[790] = {
		fov = 40,
		style = Enum.EasingStyle.Quart,
		dir = Enum.EasingDirection.In
	},
	[801] = {
		fov = 70,
		style = Enum.EasingStyle.Linear
	}
}

function shared.CutsceneEvent(p)
	return fn3(p)
end

local function fn4(humanoid, animSent)
	for _, v3 in pairs(humanoid:GetPlayingAnimationTracks()) do
		if v3.Animation.AnimationId == "rbxassetid://" .. tostring(animSent) then
			return v3
		end
	end
end

local function fn5(instance, instance2, options)
	local primaryPart = instance.PrimaryPart
	local clone = instance2:Clone()
	game.Debris:AddItem(clone, 10)
	clone.Parent = workspace.Thrown

	local function fn6(instance3)
		local cFrame = primaryPart.CFrame

		if instance:GetAttribute("ForcedCFrame") and typeof(instance:GetAttribute("ForcedCFrame")) == "CFrame" then
			cFrame = instance:GetAttribute("ForcedCFrame")
		end

		instance3.CFrame = cFrame * instance3:GetAttribute("Offset")
	end

	if not (options or {}).all then
		fn6(clone)
		return clone
	end

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			fn6(part)
		end
	end

	return clone
end

local function fn6(childName, char)
	if workspace.Thrown:FindFirstChild(childName) then
		local child = workspace.Thrown:FindFirstChild(childName)

		if child:GetAttribute("Ownership") == tostring(char) then
			return child
		end
	end

	for _, child in pairs(workspace.Thrown:GetChildren()) do
		if tostring(child) == childName and child:GetAttribute("Ownership") == tostring(char) then
			return child
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fn7(folder, enabled)
	for _, emitter in pairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local function fn8(folder, instance, p)
	if not (folder and folder.Parent) then
		return
	end

	game.Debris:AddItem(folder, 30)

	for _, emitter in pairs(folder:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and (not p or not p.Exclude or emitter.Parent ~= p.Exclude)) then
			continue
		end

		local raycastResult = string.lower(emitter.Name) == "smoke" and instance and workspace:Raycast(
			instance.PrimaryPart.Position,
			instance.PrimaryPart.Position,
			raycastParams
		)

		if raycastResult then
			emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end
end

local function fn9(torso, beams, duration)
	local attachment2 = nil
	local attachment3 = nil

	for _, attachment in pairs(beams.Part:GetChildren()) do
		if not attachment:IsA("Attachment") then
			continue
		end

		local clone = attachment:Clone()
		clone.Parent = torso
		game.Debris:AddItem(clone, 10)

		if tostring(clone) == "Attachment1" then
			attachment3 = clone
		else
			attachment2 = clone
		end
	end

	for _, beam in pairs(beams.Part:GetChildren()) do
		if not beam:IsA("Beam") then
			continue
		end

		local clone = beam:Clone()
		game.Debris:AddItem(clone, 10)
		clone.Parent = torso
		clone.Attachment0 = attachment2
		clone.Attachment1 = attachment3
		clone.Enabled = true
		task.delay(duration, function()
			if clone and clone.Parent then
				clone.Enabled = false
			end
		end)
	end
end

local function fn10(data)
	local clone = data.Part:Clone()
	table.insert(data.cleanup, clone)
	clone.Parent = workspace.Thrown
	clone.CFrame = data.CFrame
	fn8(clone, data.Char)
	game.Debris:AddItem(clone, 5)

	if data.TempWc then
		clone.Anchored = false
		clone.Massless = true
		clone.CanCollide = false
		clone.CanTouch = false
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = data.WeldData.Part0
		weldConstraint.Part1 = clone
		game.Debris:AddItem(weldConstraint, data.WeldData.DeletionTime)
	end
end

local function fn11(data)
	local anim = data.anim
	local _ = data.Stop

	for k, marker in pairs(data.markers) do
		local connection = nil
		local v3 = marker
		connection = anim:GetMarkerReachedSignal(k):Connect(function()
			if not anim.IsPlaying then
				return
			end

			if not data.DontDisconnectMarkers then
				connection:Disconnect()
			end

			return v3(data.sendingdata)
		end)
		table.insert(data.cleanup, connection)
		task.delay(20, function()
			if connection then
				connection:Disconnect()
			end
		end)
	end
end

local meshes = require(script.VfxMods.meshes)
local VFX = {
	Lifeform = {
		StartupFunction = function(data)
			local cleanup = data.cleanup
			local char = data.Char
			local v3 = char == game.Players.LocalPlayer.Character
			local playerGui = v3 and game.Players.LocalPlayer.PlayerGui or char.PrimaryPart

			local function fn12(p)
				for _, sound in pairs(playerGui:GetChildren()) do
					if sound:IsA("Sound") and sound.SoundId == p then
						return sound
					end
				end
			end

			for _, soundId in pairs({ "rbxassetid://78904320114772", "rbxassetid://104373031451162" }) do
				local v5 = fn12(soundId)

				if v5 then
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(v5, TweenInfo.new(0.45), {
						Volume = 0
					}):Play()
					game.Debris:AddItem(v5, 0.5)
				end

				local volume = v3 and 1.35 or 2.25

				if not soundId:find("78904320114772") then
					volume *= 1.4
				end

				local sfx = shared.sfx({
					SoundId = soundId,
					Parent = playerGui,
					Volume = volume
				})
				sfx:Play()
				table.insert(cleanup, sfx)
				task.delay(0.5, function()
					sfx.TimePosition = 0.5
					wait(0.5)
					sfx.TimePosition = 1
				end)
				local v8 = sfx
				task.delay(14, function()
					if v8 and v8.Parent then
						task.delay(math.random(3, 6), function()
							if v8 and v8.Parent then
								local TweenService2 = game:GetService("TweenService")
								TweenService2:Create(v8, TweenInfo.new(1), {
									Volume = v8.Volume / 5
								}):Play()
							end
						end)
					end
				end)
			end

			if char ~= game.Players.LocalPlayer.Character then
				return
			end

			local thread = task.delay(3.1, function()
				if not (data.Bind and data.Bind.Parent and char == game.Players.LocalPlayer.Character) then
					return
				end

				local _, _ = shared.CutsceneEvent({
					Anim = 123782653232583,
					Offset = CFrame.new(0, -3, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					From = game.Players.LocalPlayer.Character.PrimaryPart,
					SpecificRig = script.Assets.CameraRigK,
					ActualPart = "Camera",
					NoLerpAfter = true,
					smooth = true,
					Bind = data.Bind,
					SpecificStart = 190
				})
			end)
			table.insert(data.cleanup, thread)
		end,
		RealModule = script.VfxMods.LifeformVfx
	},
	["Boss Raid"] = {
		CanRotate = true,
		StartupFunction = function(data)
			local char = data.Char
			local primaryPart = data.Char.PrimaryPart
			local cleanup = data.cleanup
			local bossraid = script.RealAssets.Bossraid
			local rightArm = char["Right Arm"]
			local thread = nil
			local emoteBind = data.EmoteBind
			local folder = nil
			local part = Instance.new("Part")
			local Debris = game:GetService("Debris")
			Debris:AddItem(part, 60)
			part.CanCollide = false
			part.CanQuery = false
			part.Transparency = 1
			part:SetAttribute("Name", data.Char.Name)
			part:SetAttribute("DeletionImmunity", true)
			part.Color = Color3.new(1, 1, 1)
			part.Name = "InfBall"
			part.Material = Enum.Material.Neon
			part.Shape = "Ball"
			part.Massless = true
			part.Size = createVector(20, 20, 20)
			local weld = Instance.new("Weld")
			weld.Part0 = primaryPart
			weld.Part1 = part
			weld.Parent = part
			part.Parent = char
			part:AddTag("InfinityBall")
			rightArm.Transparency = 1
			thread = task.delay(1.5, function()
				local clone = bossraid.ArmRegen:Clone()
				folder = clone
				table.insert(data.cleanup, clone)
				game.Debris:AddItem(clone, 5)
				clone.Parent = char
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				table.insert(data.cleanup, motor6D)
				motor6D.Part0 = rightArm
				motor6D.Part1 = clone.PrimaryPart
				motor6D.Parent = rightArm
				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://106040706115347"
				char.Humanoid:LoadAnimation(animation):Play()
				shared.sfx({
					Parent = rightArm,
					SoundId = "rbxassetid://71793661471749",
					Volume = 1.35,
					PlaybackSpeed = Random.new():NextNumber(1, 1.075)
				}):Play()
			end)
			table.insert(data.cleanup, thread)

			if emoteBind then
				emoteBind:GetPropertyChangedSignal("Parent"):Connect(function()
					if not emoteBind.Parent then
						rightArm.Transparency = 0

						if thread then
							task.cancel(thread)
						end
					end
				end)

				if not emoteBind.Parent then
					rightArm.Transparency = 0

					if thread then
						task.cancel(thread)
					end
				end
			end

			local v3 = {
				Texts = CFrame.new(
					1.39596558,
					-0.870697021,
					-0.397636414,
					0.923880339,
					3.17196898e-13,
					-0.382681459,
					-2.46100503e-13,
					1,
					2.3473698e-13,
					0.382681459,
					-1.22690798e-13,
					0.923880339
				),
				Blue = CFrame.new(
					-0.128771782,
					-0.946416378,
					-1.34786582,
					0.109281771,
					-0.460234433,
					-0.881046772,
					-0.148396462,
					0.868868649,
					-0.472279489,
					0.982872725,
					0.182355583,
					0.0266542491
				),
				Activate = CFrame.new(
					-0.468925238,
					-2.06283092,
					0.227512807,
					1.00000036,
					-2.04890966e-8,
					-2.98023224e-8,
					-2.04890966e-8,
					1.00000036,
					-5.21540642e-8,
					-2.98023224e-8,
					-5.21540642e-8,
					1.0000006
				),
				Slam = CFrame.new(
					-0.440316439,
					-3.11318493,
					-0.973331332,
					1.00000036,
					-2.04890966e-8,
					-2.98023224e-8,
					-2.04890966e-8,
					1.00000036,
					-5.21540642e-8,
					-2.98023224e-8,
					-5.21540642e-8,
					1.0000006
				),
				FloorEnable = CFrame.new(
					-0.940292835,
					-3.11318469,
					-0.895578265,
					1.00000036,
					-2.04890966e-8,
					-2.98023224e-8,
					-2.04890966e-8,
					1.00000036,
					-5.21540642e-8,
					-2.98023224e-8,
					-5.21540642e-8,
					1.0000006
				),
				Phase2 = CFrame.new(
					-0.77883029,
					-2.97686553,
					-0.781239569,
					0.49037835,
					-0.687594295,
					-0.535485148,
					0.206855595,
					0.688705623,
					-0.694907486,
					0.846605718,
					0.229999408,
					0.479958862
				),
				FloorPart = CFrame.new(
					-1.01313972,
					-2.90322304,
					-1.35118687,
					1.00000036,
					-2.04890966e-8,
					-2.98023224e-8,
					-2.04890966e-8,
					1.00000036,
					-5.21540642e-8,
					-2.98023224e-8,
					-5.21540642e-8,
					1.0000006
				),
				Land = CFrame.new(
					-0.285525084,
					-2.90988469,
					0.227512926,
					1.00000036,
					-2.04890966e-8,
					-2.98023224e-8,
					-2.04890966e-8,
					1.00000036,
					-5.21540642e-8,
					-2.98023224e-8,
					-5.21540642e-8,
					1.0000006
				)
			}

			local function fn12(primaryPart2)
				if primaryPart2:IsA("Model") and primaryPart2.PrimaryPart then
					primaryPart2 = primaryPart2.PrimaryPart
				end

				if primaryPart2:IsA("Part") or primaryPart2:IsA("MeshPart") and v3[tostring(primaryPart2)] then
					primaryPart2.CFrame = primaryPart.CFrame * v3[tostring(primaryPart2)]
				end

				if tostring(primaryPart2) == "Blue" then
					primaryPart2.Anchored = false
					primaryPart2.Massless = true
					primaryPart2.CanTouch = false
					primaryPart2.CanQuery = false

					if tostring(primaryPart2) == "Blue" then
						primaryPart2.Parent.Parent = char
					else
						primaryPart2.Parent = char
					end

					local motor6D = primaryPart2.Parent:FindFirstChildOfClass("Motor6D") or primaryPart2:FindFirstChildOfClass("Motor6D")
					motor6D.Part0 = char.PrimaryPart
					motor6D.Part1 = primaryPart2
					motor6D.Parent = char.PrimaryPart
				end
			end

			local v4 = nil

			local function fn13(instance)
				local clone = instance:Clone()

				if not v4 then
					v4 = clone
				end

				clone.Parent = workspace.Thrown
				table.insert(cleanup, clone)

				if tostring(instance) == "SteamArm" then
					return clone
				end

				fn12(clone)
				table.insert(data.cleanup, clone)

				if instance.Name == "Texts" then
					clone.Parent = char
				else
					game.Debris:AddItem(clone, 10)
					return clone
				end

				return clone
			end

			local function fn14()
				local folder2 = fn13(bossraid.Texts)
				local emoteBind2 = data.EmoteBind

				if emoteBind2 then
					emoteBind2:GetPropertyChangedSignal("Parent"):Connect(function()
						if not emoteBind2.Parent then
							local Debris2 = game:GetService("Debris")
							Debris2:AddItem(folder2, 0)
						end
					end)

					if not emoteBind2.Parent then
						local Debris2 = game:GetService("Debris")
						Debris2:AddItem(folder2, 0)
					end
				else
					local Debris2 = game:GetService("Debris")
					Debris2:AddItem(folder2, 0)
				end

				for _, effect in pairs(folder2:GetDescendants()) do
					if not ((effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) and effect:GetAttribute("EmitDelay")) then
						continue
					end

					local v5 = effect
					task.delay(effect:GetAttribute("EmitDelay"), function()
						v5:Emit(v5:GetAttribute("EmitCount"))
						task.delay(5, function()
							v5.TimeScale = 0
						end)
					end)
				end
			end

			task.delay(2.15, function()
				fn14()
			end)
			local v5 = nil
			local v6 = nil
			local v7 = nil
			local v8 = nil
			local v9 = {
				[0.07] = function()
					local v10 = fn13(bossraid.Blue)
					v5 = v10
					v10:ScaleTo(1)
					local primaryPart2 = v10.PrimaryPart
					local folder2 = fn13(bossraid.Activate)

					for _, emitter in pairs(folder2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					for _, effect in pairs(primaryPart2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					primaryPart2.PointLight.Brightness = 7
					TweenService:Create(
						primaryPart2.PointLight,
						TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Brightness = 1
						}
					):Play()
				end,
				[0.647] = function()
					spawn(function()
						for _ = 1, 5 do
							fn2({ char }, 2)
							task.wait(0.02)
						end
					end)
					v5:ScaleTo(1.8)
					local folder2 = fn13(bossraid.Slam)

					for _, emitter in pairs(folder2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					local folder3 = fn13(bossraid.FloorEnable)
					v6 = folder3

					for _, emitter in pairs(folder3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter:Emit(emitter:GetAttribute("EmitCount"))
						emitter.Enabled = true
					end
				end,
				[1.25] = function()
					local v10 = v5
					local total = 1
					local folder2 = fn13(bossraid.Phase2)
					v7 = folder2
					folder2.PointLight.Brightness = 0
					TweenService:Create(
						folder2.PointLight,
						TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Brightness = 2
						}
					):Play()

					for _, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					local folder3 = v6

					for _, emitter in pairs(folder3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter:Emit(emitter:GetAttribute("EmitCount"))
						emitter.Enabled = false
					end

					local folder4 = fn13(bossraid.FloorPart)
					v8 = folder4

					for _, effect in pairs(folder4:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
							continue
						end

						effect:Emit(effect:GetAttribute("EmitCount"))
						effect.Enabled = true
					end

					local thread2 = task.delay(0.2, function()
						local position = primaryPart.Position
						local _, v11 = workspace:FindFirstChildOfClass("Camera"):WorldToScreenPoint(position)

						if v11 then
							local RunService2 = game:GetService("RunService")
							local heartbeatConnection = RunService2.Heartbeat:Connect(function()
								if v5 and v5.Parent and folder4 and folder4.Parent then
									folder4.CFrame = CFrame.new(folder4.Position:Lerp(
										Vector3.new(
											v5.PrimaryPart.Position.X,
											folder4.Position.Y,
											v5.PrimaryPart.Position.Z
										),
										0.25
									)) * CFrame.Angles(0, 1.5707963267948966, 0)
								end
							end)
							task.delay(1, function()
								if heartbeatConnection then
									return heartbeatConnection:Disconnect()
								end
							end)
							table.insert(cleanup, heartbeatConnection)
						end
					end)
					table.insert(cleanup, thread2)
					task.spawn(function()
						for _ = 1, 7 do
							if v10 and v10.Parent then
								v10:ScaleTo(total)
								total += 0.4
								wait(0.02)
							else
								break
							end
						end
					end)
				end,
				[1.4] = function()
					local folder2 = v5

					for _, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					task.delay(0.325, function()
						local folder3 = v8

						for _, effect in pairs(folder3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
					local folder3 = v7

					for _, effect in pairs(folder3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					TweenService:Create(
						v5.Blue.PointLight,
						TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Brightness = 0
						}
					):Play()
					TweenService:Create(
						v7.PointLight,
						TweenInfo.new(0.76, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Brightness = 0
						}
					):Play()
				end,
				[2.09] = function()
					local folder2 = fn13(bossraid.Land)

					for _, emitter in pairs(folder2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end
				end,
				[2.29] = function()
					if v5 and v5.Parent then
						TweenService:Create(
							rightArm,
							TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 0
							}
						):Play()
					end

					if folder then
						if shared.OnScreen(primaryPart.Position) then
							for _, part2 in pairs(folder:GetDescendants()) do
								if part2:IsA("Part") or part2:IsA("MeshPart") then
									TweenService:Create(
										part2,
										TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end
							end

							game.Debris:AddItem(folder, 1)
						else
							folder:Destroy()
						end
					end

					local clone = bossraid.SteamArm.ParticleEmitter:Clone()
					clone.Parent = char["Right Arm"]
					local emoteBind2 = data.EmoteBind

					if emoteBind2 then
						emoteBind2:GetPropertyChangedSignal("Parent"):Connect(function()
							if not emoteBind2.Parent then
								local Debris2 = game:GetService("Debris")
								Debris2:AddItem(clone, 0)
							end
						end)

						if not emoteBind2.Parent then
							local Debris2 = game:GetService("Debris")
							Debris2:AddItem(clone, 0)
						end
					else
						local Debris2 = game:GetService("Debris")
						Debris2:AddItem(clone, 0)
					end

					task.delay(0.12, function()
						if clone and clone.Parent then
							clone.Enabled = true
						end
					end)
				end
			}
			local v10 = {}

			for k, v11 in pairs(v9) do
				local v12 = v11
				local thread2 = task.delay(k + 0.15, function()
					v12()
				end)
				table.insert(v10, thread2)
				table.insert(cleanup, thread2)
			end
		end
	},
	HugeSlash = {
		StartupFunction = function(sendingdata)
			local char = sendingdata.Char
			local _ = sendingdata.Char.PrimaryPart
			local cleanup = sendingdata.cleanup
			local realAnim = sendingdata.RealAnim
			local hugeSlash = script.RealAssets.HugeSlash
			local attachment2 = nil
			local attachment3 = nil

			for _, child in pairs(hugeSlash.Final:GetChildren()) do
				local clone = child:Clone()
				game.Debris:AddItem(clone, 10)
				table.insert(cleanup, clone)

				if tostring(clone) == "+" then
					attachment3 = clone
				else
					attachment2 = clone
				end

				clone.Parent = char["Right Arm"]
			end

			local clones = {}
			local v5 = {}
			local meshemit = require(script.VfxMods.meshemit)
			tick()
			fn11({
				anim = realAnim,
				markers = {
					first = function()
						fn2({ char }, 2)
						local v6 = fn5(char, hugeSlash.meshes.p1, {
							all = true
						})
						game.Debris:AddItem(v6, 7)
						table.insert(cleanup, v6)

						for _, child in pairs(v6:GetChildren()) do
							meshemit(child)
						end

						local clone = hugeSlash.ArmTrails.p1.Trail:Clone()
						game.Debris:AddItem(clone, 7)
						table.insert(cleanup, clone)
						clone.Parent = char["Right Arm"]
						clone.Enabled = true
						clone.Attachment0 = attachment2
						clone.Attachment1 = attachment3
						table.insert(clones, clone)
						local s1 = fn5(char, hugeSlash.S1)
						game.Debris:AddItem(s1, 7)
						table.insert(cleanup, s1)
						table.insert(cleanup, s1)
						v5.s1 = s1
						fn8(s1.s1)
					end,
					sec = function()
						fn2({ char }, 2)
						local v6 = fn5(char, hugeSlash.meshes.p2, {
							all = true
						})
						game.Debris:AddItem(v6, 7)
						table.insert(cleanup, v6)

						for _, child in pairs(v6:GetChildren()) do
							meshemit(child)
						end

						for _, trail in v5.s1.s2.ROTATE:GetDescendants() do
							if trail:IsA("Trail") then
								trail.Enabled = true
							end
						end

						local TweenService2 = game:GetService("TweenService")
						v5.s1.s2.ROTATE.Position = createVector(-5.005, -2.692, -0.089)
						v5.s1.s2.ROTATE.Orientation = createVector(0, 0, 0)
						TweenService2:Create(
							v5.s1.s2.ROTATE,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Position = createVector(-5.005, 1.345, -0.089)
							}
						):Play()
						TweenService2:Create(
							v5.s1.s2.ROTATE,
							TweenInfo.new(0.41, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Orientation = createVector(0, -207.535, 0)
							}
						):Play()
						task.delay(1.4, function()
							if not (v5 and v5.s1 and v5.s1.Parent) then
								return
							end

							for _, trail in v5.s1.s2.ROTATE:GetDescendants() do
								if trail:IsA("Trail") then
									trail.Enabled = false
								end
							end
						end)
						v5.s1.s2.Attachment.PointLight.Brightness = 3
						TweenService2:Create(
							v5.s1.s2.Attachment.PointLight,
							TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Brightness = 0
							}
						):Play()
						local clone = hugeSlash.ArmTrails.p2.Trail:Clone()
						game.Debris:AddItem(clone, 7)
						table.insert(cleanup, clone)
						clone.Parent = char["Right Arm"]
						clone.Enabled = true
						clone.Attachment0 = attachment2
						clone.Attachment1 = attachment3
						table.insert(clones, clone)

						for _, emitter in v5.s1.s2:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					end,
					third = function()
						local v6 = fn5(char, hugeSlash.meshes.p3, {
							all = true
						})
						game.Debris:AddItem(v6, 7)
						table.insert(cleanup, v6)

						for _, child in pairs(v6:GetChildren()) do
							meshemit(child)
						end

						local TweenService2 = game:GetService("TweenService")
						fn2({ char }, 2)
						v5.s1.s3.Attachment.PointLight.Brightness = 4
						TweenService2:Create(
							v5.s1.s3.Attachment.PointLight,
							TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Brightness = 0
							}
						):Play()
						local folder = fn5(char, hugeSlash.ArmAura)
						game.Debris:AddItem(folder, 7)
						table.insert(cleanup, folder)
						v5.armaura = folder
						folder.Anchored = false
						folder.CanCollide = false
						folder.Massless = true
						local motor6D = Instance.new("Motor6D")
						game.Debris:AddItem(motor6D, 7)
						table.insert(cleanup, motor6D)
						motor6D.Part0 = char["Right Arm"]
						motor6D.Part1 = folder
						motor6D.Parent = folder
						v5.armaura = folder
						local clone = hugeSlash.WindBeams:Clone()
						game.Debris:AddItem(clone, 7)
						table.insert(cleanup, clone)
						v5.windbeams = clone
						clone.Parent = workspace
						local v7 = {}

						for _, beam in pairs(clone:GetDescendants()) do
							if beam:IsA("Beam") then
								v7[beam] = {
									Attachment0 = beam.Attachment0.CFrame,
									Attachment1 = beam.Attachment1.CFrame
								}
							end
						end

						for k, v8 in pairs(v7) do
							local attachment0 = v8.Attachment0
							local attachment1 = v8.Attachment1

							for _, attachment in pairs(folder:GetDescendants()) do
								if not attachment:IsA("Attachment") then
									continue
								end

								local cFrame = attachment.CFrame

								if cFrame == attachment0 then
									k.Attachment0 = attachment
								elseif cFrame == attachment1 then
									k.Attachment1 = attachment
								end
							end
						end

						for _, beam in clone:GetDescendants() do
							if not beam:IsA("Beam") then
								continue
							end

							beam.Brightness = 0.3
							beam.TextureSpeed = 2
						end

						local clone2 = hugeSlash.ArmTrails.p3.Trail:Clone()
						game.Debris:AddItem(clone2, 7)
						table.insert(cleanup, clone2)
						clone2.Parent = char["Right Arm"]
						clone2.Enabled = true
						clone2.Attachment0 = attachment2
						clone2.Attachment1 = attachment3
						table.insert(clones, clone2)

						for _, emitter in v5.s1.s3:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						folder.D.ROT.Orientation = createVector(0, 0, 0)
						TweenService2:Create(
							folder.D.ROT,
							TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Orientation = createVector(0, -450, 0)
							}
						):Play()

						for _, emitter in folder:GetDescendants() do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter:Emit(emitter:GetAttribute("EmitCount"))
							emitter.Enabled = true
						end
					end,
					fourth = function()
						fn2({ char }, 1, 0.25)
						local v6 = fn5(char, hugeSlash.Invertt, {
							all = true
						})
						game.Debris:AddItem(v6, 7)
						table.insert(cleanup, v6)

						for _, child in pairs(v6:GetChildren()) do
							meshemit(child)
						end
					end,
					fifth = function()
						spawn(function()
							for _ = 1, 3 do
								fn2({ char }, 15)
								task.wait(0.01)
							end
						end)
						local lastTime = tick()

						repeat
							task.wait()
						until char:GetAttribute("ForcedCFrame") or tick() - lastTime >= 0.25

						local v6 = fn5(char, hugeSlash.meshes.s, {
							all = true
						})

						for _, child in pairs(v6:GetChildren()) do
							meshemit(child)
						end

						local TweenService2 = game:GetService("TweenService")
						local Debris = game:GetService("Debris")
						local v7 = fn5(char, hugeSlash.INVERT)
						local v8 = fn5(char, hugeSlash.ENDSPHERE)
						Debris:AddItem(v7, 1)
						v7.Parent = workspace.Camera
						TweenService2:Create(
							v7,
							TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
							{
								Position = v8.Position
							}
						):Play()
						TweenService2:Create(
							v7,
							TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Size = v8.Size
							}
						):Play()
						task.delay(0.135, function()
							v7:Destroy()
						end)
						local parent = fn5(char, hugeSlash.WorldSlash)
						local highlight = Instance.new("Highlight")
						highlight.DepthMode = Enum.HighlightDepthMode.Occluded
						highlight.FillColor = Color3.fromRGB(0, 0, 0)
						highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
						highlight.OutlineTransparency = 0
						highlight.Parent = parent
						highlight.OutlineTransparency = 0
						local v10 = fn5(char, hugeSlash.ENDDD)
						Debris:AddItem(parent, 1)
						parent.Parent = workspace.Camera
						TweenService2:Create(
							parent,
							TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Size = v10.Size
							}
						):Play()
						TweenService2:Create(
							parent,
							TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Position = v10.Position
							}
						):Play()
						task.delay(1, function()
							parent:Destroy()
						end)
						local folder = fn5(char, hugeSlash.SLASH)
						local clone = hugeSlash.Wind2:Clone()
						Debris:AddItem(clone, 5)
						v5.windbeams = clone
						clone.Parent = workspace.Thrown
						local v11 = {}

						for _, beam in pairs(clone:GetDescendants()) do
							if beam:IsA("Beam") then
								v11[beam] = {
									Attachment0 = beam.Attachment0.CFrame,
									Attachment1 = beam.Attachment1.CFrame
								}
							end
						end

						for k, v12 in pairs(v11) do
							local attachment0 = v12.Attachment0
							local attachment1 = v12.Attachment1

							for _, attachment in pairs(folder:GetDescendants()) do
								if not attachment:IsA("Attachment") then
									continue
								end

								local cFrame = attachment.CFrame

								if cFrame == attachment0 then
									k.Attachment0 = attachment
								elseif cFrame == attachment1 then
									k.Attachment1 = attachment
								end
							end
						end

						for _, beam in clone:GetDescendants() do
							if not beam:IsA("Beam") then
								continue
							end

							beam.Brightness = 0.45
							beam.TextureSpeed = 1.7
							TweenService2:Create(
								beam,
								TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									TextureSpeed = 0.4
								}
							):Play()
							TweenService2:Create(
								beam,
								TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Brightness = 0
								}
							):Play()
						end

						for _, emitter in folder:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end

							if not emitter:GetAttribute("EmitDuration") then
								continue
							end

							emitter.Enabled = true
							local v12 = emitter
							task.delay(emitter:GetAttribute("EmitDuration"), function()
								v12.Enabled = false
							end)
						end

						for _, emitter in v5.armaura:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						for _, beam in v5.windbeams:GetDescendants() do
							if not beam:IsA("Beam") then
								continue
							end

							TweenService2:Create(
								beam,
								TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Brightness = 0
								}
							):Play()
							TweenService2:Create(
								beam,
								TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									TextureSpeed = 0.6
								}
							):Play()
						end
					end
				},
				DontDisconnectMarkers = false,
				sendingdata = sendingdata,
				cleanup = cleanup
			})
		end
	},
	["Lifetime Barrage"] = {
		CutsceneData = {
			Anim = 113675038459828,
			Offset = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CameraRig25,
			ActualPart = "CamPart",
			smoothin = true,
			smooth = true,
			shake = {
				intensity = 15,
				amount = 0.15
			}
		},
		StartupFunction = function(data)
			local character = game.Players.LocalPlayer.Character
			local targChar = data.targChar
			local primaryPart = character.PrimaryPart
			local volume

			if character == data.Char or character == targChar then
				primaryPart = game.Players.LocalPlayer.PlayerGui
				volume = 1.35
			else
				volume = 2
			end

			if data.Char ~= game.Players.LocalPlayer.Character and data.targChar ~= game.Players.LocalPlayer then
				primaryPart = data.Char.PrimaryPart
			end

			local sfx = shared.sfx({
				SoundId = "rbxassetid://138037259932921",
				Parent = primaryPart,
				Volume = volume - 0.2
			})
			sfx:Play()
			table.insert(data.cleanup, sfx)
			local sfx2 = shared.sfx({
				SoundId = "rbxassetid://122891228249030",
				Parent = primaryPart,
				Volume = volume,
				RollOffMaxDistance = 120
			})
			sfx2:Play()
			table.insert(data.cleanup, sfx2)
		end,
		RealModule = script.VfxMods["7 Page"]
	},
	["Final Bomb"] = {
		CutsceneData = {
			Anim = 100366125413969,
			Offset = CFrame.new(0, 0, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CameraRigVegetable,
			ActualPart = "CamPart",
			smoothin = true,
			smooth = true,
			NoLerp = true
		},
		StartupFunction = function(data)
			local character = game.Players.LocalPlayer.Character
			local targChar = data.targChar
			local primaryPart = character.PrimaryPart
			local volume

			if character == data.Char or character == targChar then
				primaryPart = game.Players.LocalPlayer.PlayerGui
				volume = 2
			else
				volume = 4
			end

			if data.Char ~= game.Players.LocalPlayer.Character and data.targChar ~= game.Players.LocalPlayer then
				primaryPart = data.Char.PrimaryPart
			end

			local sfx = shared.sfx({
				SoundId = "rbxassetid://95080574694599",
				Parent = primaryPart,
				Volume = volume,
				TimePosition = 0,
				RollOffMaxDistance = 120
			})
			sfx:Play()
			task.delay(10.5, function()
				if table.find(data.cleanup, sfx) then
					table.remove(data.cleanup, table.find(data.cleanup, sfx))
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(sfx, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Volume = 0
				}):Play()
			end)
			table.insert(data.cleanup, sfx)
		end,
		RealModule = script.VfxMods.Vegetable
	},
	Speedster = {
		CutsceneData = {
			Anim = 92523816230897,
			Offset = CFrame.new(0, -3, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CameraRigbasic,
			ActualPart = "Camera",
			smoothin = true,
			smooth = true
		},
		StartupFunction = function(data)
			local character = game.Players.LocalPlayer.Character
			local targChar = data.targChar
			local primaryPart = character.PrimaryPart

			if character == data.Char or character == targChar then
				primaryPart = game.Players.LocalPlayer.PlayerGui
			end

			if data.Char ~= game.Players.LocalPlayer.Character and data.targChar ~= game.Players.LocalPlayer then
				primaryPart = data.Char.PrimaryPart
			end

			local sfx = shared.sfx({
				SoundId = "rbxassetid://127599988870711",
				Parent = primaryPart,
				Volume = 2,
				RollOffMaxDistance = 120
			})
			sfx:Play()
			table.insert(data.cleanup, sfx)
		end,
		RealModule = script.VfxMods.Speedster
	},
	["STILL FUNNY?"] = {
		CutsceneData = {
			Anim = 124958014257711,
			Offset = CFrame.new(),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CameraFunny,
			ActualPart = "CamPart"
		},
		StartupFunction = function(sendingdata)
			local char = sendingdata.Char
			local _ = sendingdata.Char.PrimaryPart
			local targChar = sendingdata.targChar
			local cleanup = sendingdata.cleanup
			local realAnim = sendingdata.RealAnim
			local stillFunny = script.RealAssets["Still Funny?"]
			local count = 0
			local folder = nil
			local folder2 = nil
			local character = game.Players.LocalPlayer.Character
			local v3 = char == character or sendingdata.CutsceneBind == character

			for _, soundId in pairs({
				"rbxassetid://118296832032427",
				"rbxassetid://118821266175755",
				"rbxassetid://98012468694360"
			}) do
				local volume = 6
				local primaryPart = soundId == "rbxassetid://98012468694360" and targChar.PrimaryPart

				if not primaryPart then
					if soundId == "rbxassetid://118821266175755" then
						primaryPart = char.PrimaryPart
					else
						primaryPart = false
					end
				end

				if v3 then
					volume /= 2
					primaryPart = game.Players.LocalPlayer.PlayerGui
				end

				local playerGui = primaryPart or char.Torso
				local sfx = shared.sfx

				if v3 then
					playerGui = game.Players.LocalPlayer.PlayerGui or playerGui
				end

				local v7 = sfx({
					SoundId = soundId,
					Volume = volume,
					Parent = playerGui
				})
				v7:Play()
				table.insert(cleanup, v7)
			end

			local count2 = 0
			fn11({
				anim = realAnim,
				markers = {
					punch = function()
						local folder3 = fn5(targChar, stillFunny.Start)
						table.insert(cleanup, folder3)
						game.Debris:AddItem(folder3, 10)

						for _, emitter in folder3:GetDescendants() do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v4 = emitter
							task.spawn(function()
								if v4:GetAttribute("EmitDelay") then
									task.wait(v4:GetAttribute("EmitDelay"))
								end

								v4:Emit(v4:GetAttribute("EmitCount"))
							end)
						end
					end,
					emit = function()
						count += 1

						if not folder2 then
							folder2 = fn5(targChar, stillFunny.BasicHit)
							table.insert(cleanup, folder2)
							game.Debris:AddItem(folder2, 10)
						end

						for _, emitter in folder2:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						if count == 3 then
							local TweenService2 = game:GetService("TweenService")
							local v4 = fn5(targChar, stillFunny.SphereBlocked)
							v4.Transparency = 0.125
							table.insert(cleanup, v4)
							game.Debris:AddItem(v4, 10)
							local folder3 = fn5(targChar, stillFunny.AP)
							table.insert(cleanup, folder3)
							game.Debris:AddItem(folder3, 10)
							local motor6D = Instance.new("Motor6D")
							table.insert(cleanup, motor6D)
							motor6D.C1 = CFrame.new(0, -0.217, 0)
							motor6D.Part0 = char["Left Arm"]
							motor6D.Part1 = folder3
							motor6D.Parent = char["Left Arm"]

							for _, emitter in folder3:GetDescendants() do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v5 = emitter
								task.spawn(function()
									v5:Emit(v5:GetAttribute("EmitCount") * 2)
									v5.Enabled = true
									task.wait(v5:GetAttribute("EmitDuration"))
									v5.Enabled = false
								end)
							end

							local folder4 = fn5(targChar, stillFunny.Blocked)
							table.insert(cleanup, folder4)
							game.Debris:AddItem(folder4, 10)

							for _, emitter in folder4:GetDescendants() do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v5 = emitter
								task.spawn(function()
									if v5:GetAttribute("EmitDelay") then
										task.wait(v5:GetAttribute("EmitDelay"))
									end

									v5:Emit(v5:GetAttribute("EmitCount") * 2)
								end)
							end

							local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
							task.wait(0.25)

							if folder4 and folder4.Parent then
								TweenService2:Create(v4, tweenInfo, {
									Transparency = 1
								}):Play()
							end
						end
					end,
					headbutt = function()
						if not folder then
							folder = fn5(targChar, stillFunny.HeadHit)
							table.insert(cleanup, folder)
							game.Debris:AddItem(folder, 10)
						end

						for _, emitter in folder:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						count2 += 1

						if count2 == 6 then
							local accessory = Instance.new("Accessory")
							accessory.Name = "CancelCutscene"
							accessory.Parent = workspace
							game.Debris:AddItem(accessory, 0.25)
							fn2({ char }, 3, 0.25)
						end
					end,
					last = function()
						local clone = stillFunny.Part.Attachment:Clone()
						clone.Parent = char.Head
						table.insert(cleanup, clone)
						game.Debris:AddItem(clone, 10)

						for _, emitter in clone:GetChildren() do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v4 = emitter
							task.spawn(function()
								v4:Emit(v4:GetAttribute("EmitCount"))
								v4.Enabled = true
								task.wait(v4:GetAttribute("EmitDuration"))
								v4.Enabled = false
							end)
						end
					end
				},
				DontDisconnectMarkers = true,
				sendingdata = sendingdata,
				cleanup = cleanup
			})
		end
	},
	["Flower Bomb"] = {
		StartupFunction = function(sendingdata)
			local char = sendingdata.Char
			local _ = sendingdata.Char.PrimaryPart
			local targChar = sendingdata.targChar
			local cleanup = sendingdata.cleanup
			local realAnim = sendingdata.RealAnim
			local flowerBomb = script.RealAssets.FlowerBomb
			local clone

			if targChar:FindFirstChild("Rose") then
				clone = nil
			else
				clone = flowerBomb.Rose:Clone()
				game.Debris:AddItem(clone, 6)
				clone.Parent = targChar
				clone.Sappling.Anchored = false
				local sapplingE = clone.SapplingE
				sapplingE.Parent = targChar.PrimaryPart
				sapplingE.Part0 = targChar.PrimaryPart
				sapplingE.Part1 = clone.Sappling
				sapplingE.Name = "Sappling"
			end

			fn11({
				anim = realAnim,
				markers = {
					a = function()
						local folder = fn5(char, flowerBomb.GroundSmoke1)
						table.insert(cleanup, folder)
						game.Debris:AddItem(folder, 5)

						for _, emitter in pairs(folder:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v3 = emitter
							task.spawn(function()
								v3:Emit(v3:GetAttribute("EmitCount"))
							end)
						end
					end,
					b = function()
						local folder = fn5(char, flowerBomb.Brush)
						table.insert(cleanup, folder)
						game.Debris:AddItem(folder, 5)

						for _, emitter in pairs(folder:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v3 = emitter
							task.spawn(function()
								v3:Emit(v3:GetAttribute("EmitCount"))
							end)
						end
					end,
					c = function()
						local folder = fn5(char, flowerBomb.Smell)
						table.insert(cleanup, folder)
						game.Debris:AddItem(folder, 5)

						for _, emitter in pairs(folder:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v3 = emitter
							task.spawn(function()
								v3:Emit(v3:GetAttribute("EmitCount"))
							end)
						end
					end,
					d = function()
						fn2({ char, sendingdata.CutsceneBind }, 3)
						local folder = fn5(char, flowerBomb.Slam)
						table.insert(cleanup, folder)
						game.Debris:AddItem(folder, 5)

						for _, emitter in pairs(folder:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v3 = emitter
							task.spawn(function()
								v3:Emit(v3:GetAttribute("EmitCount"))
							end)
						end
					end,
					e = function()
						fn2({ char, sendingdata.CutsceneBind }, 2)

						for _, v3 in pairs({ flowerBomb.Slam, clone }) do
							local folder

							if v3 == clone then
								folder = clone
							else
								folder = fn5(char, v3)
								table.insert(cleanup, folder)
								game.Debris:AddItem(folder, 5)
							end

							for _, emitter in pairs(folder:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v4 = emitter
								task.spawn(function()
									v4:Emit(v4:GetAttribute("EmitCount"))
								end)
							end
						end
					end,
					f = function()
						fn2({ char, sendingdata.CutsceneBind }, 5)

						for _, v3 in pairs({ flowerBomb.Snap, flowerBomb.HeadExplode }) do
							local folder = fn5(char, v3)
							table.insert(cleanup, folder)
							game.Debris:AddItem(folder, 5)

							for _, emitter in pairs(folder:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v4 = emitter
								task.spawn(function()
									v4:Emit(v4:GetAttribute("EmitCount"))
								end)
							end
						end

						if clone then
							clone:Destroy("")
						end
					end
				},
				DontDisconnectMarkers = false,
				sendingdata = sendingdata,
				cleanup = cleanup
			})
		end
	},
	["Iron Combo"] = {
		StartupFunction = function(sendingdata)
			local char = sendingdata.Char
			local _ = sendingdata.Char.PrimaryPart
			local targChar = sendingdata.targChar
			local cleanup = sendingdata.cleanup
			local realAnim = sendingdata.RealAnim
			local ironCombo = script.RealAssets["Iron Combo"]
			local v3 = {}
			local v4 = nil
			fn11({
				anim = realAnim,
				markers = {
					Stomp = function()
						local v5 = fn5(char, ironCombo.Stomp)
						table.insert(cleanup, v5)
						v5.Anchored = true
						game.Debris:AddItem(v5, 6)
						fn8(v5)
						fn2({ char, sendingdata.CutsceneBind }, 2)
					end,
					Hit1 = function()
						local v5 = fn5(char, ironCombo.VictimEffect)
						table.insert(cleanup, v5)
						game.Debris:AddItem(v5, 6)
						v5.Transparency = 1
						v4 = v5
						local weld = Instance.new("Weld")
						table.insert(cleanup, weld)
						weld.Part0 = targChar.Torso
						weld.Part1 = v5
						weld.Parent = v5
						fn8(v5)
						fn2({ char, sendingdata.CutsceneBind }, 2)
					end,
					Hit2 = function()
						fn2({ char, sendingdata.CutsceneBind }, 2)
						fn8(v4)
					end,
					Rotation = function()
						local clone = ironCombo.SpinKick:Clone()
						table.insert(cleanup, clone)
						game.Debris:AddItem(clone, 6)
						clone.Parent = workspace.Thrown
						local clone2 = ironCombo.BodyRotation:Clone()
						table.insert(cleanup, clone2)
						game.Debris:AddItem(clone2, 6)
						clone2.Parent = workspace.Thrown
						local weld = Instance.new("Weld")
						weld.Part0 = char["Left Leg"]
						weld.Part1 = clone
						weld.Parent = clone
						weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 3.141592653589793, 0)
						local weld2 = Instance.new("Weld")
						weld2.Part0 = char.Torso
						weld2.Part1 = clone2
						weld2.Parent = clone2
						table.insert(cleanup, weld)
						table.insert(cleanup, weld2)
						fn8(clone)
						fn7(clone, true)
						fn7(clone2, true)

						for _, v5 in pairs({ clone2, clone }) do
							table.insert(v3, v5)
						end
					end,
					Hit3 = function()
						fn2({ char, sendingdata.CutsceneBind }, 2)

						for _, v5 in pairs(v3) do
							fn7(v5, false)
						end

						fn8(v4)
					end,
					Hit4 = function()
						fn2({ char, sendingdata.CutsceneBind }, 2)
						fn8(v4)
					end,
					Hit5 = function()
						fn2({ char, sendingdata.CutsceneBind }, 4, 0.5)
						fn8(v4)

						for _, v5 in pairs({ ironCombo.Knockback, ironCombo.KnockbackDust }) do
							local v6 = fn5(char, v5)
							v6.Anchored = true
							game.Debris:AddItem(v6, 5)
							table.insert(cleanup, v6)
							fn8(v6)
						end
					end
				},
				DontDisconnectMarkers = false,
				sendingdata = sendingdata,
				cleanup = cleanup
			})
		end
	},
	["Time Shift"] = {
		StartupFunction = function(sendingdata)
			local char = sendingdata.Char
			local primaryPart = sendingdata.Char.PrimaryPart
			local targChar = sendingdata.targChar
			local cleanup = sendingdata.cleanup
			local realAnim = sendingdata.RealAnim
			local timeShift = script.RealAssets["Time Shift"]
			local v3 = TweenService
			local v4 = {}

			for _, part in pairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					v4[part.Name] = part.CFrame
				end
			end

			local clone = game.ReplicatedStorage.Resources.Clone_Rig:Clone()
			table.insert(cleanup, clone)
			game.Debris:AddItem(clone, 9)
			clone.Parent = workspace.Thrown
			clone.PrimaryPart.Anchored = true
			clone.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			clone.Humanoid:ApplyDescription(char.Humanoid:GetAppliedDescription())
			table.insert(v, clone)

			for _, part in pairs(clone:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.CollisionGroup = "untouchable"
				part.Massless = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Anchored = false
			end

			clone.PrimaryPart.Anchored = true
			clone:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(0, 1000, 0))
			task.delay(0.65, function()
				if clone and clone.Parent then
					clone:SetPrimaryPartCFrame(primaryPart.CFrame)
				end
			end)
			local animation = Instance.new("Animation")
			game.Debris:AddItem(animation, 6)
			table.insert(cleanup, animation)
			animation.AnimationId = "rbxassetid://125313562401655"
			local track = clone.Humanoid:LoadAnimation(animation)
			track:Play()
			track.TimePosition = realAnim.TimePosition

			-- equivalent calls inferred from this helper; original call sites unknown
			local function ye(p, p2)
				table.insert(cleanup, p)
				game.Debris:AddItem(p, p2)
			end

			fn11({
				anim = realAnim,
				markers = {
					MirageFade = function()
						local v5 = clone
						local clone2 = timeShift.RigClone:Clone()
						clone2.Parent = workspace.Thrown

						for _, part in clone2:GetChildren() do
							if not (part:IsA("BasePart") and v5:FindFirstChild((tostring(part)))) then
								continue
							end

							part.CFrame = v5[part.Name].CFrame
							part.Color = Color3.fromRGB(0, 0, 0)
							part.Material = Enum.Material.Neon
						end

						fn5(char, timeShift.Shine).Shine:Emit(7)
						local clone3 = timeShift.SparkleDestroy.Stars:Clone()
						clone3.Parent = clone2.Head
						clone3.Enabled = true
						local v6 = {
							Size = createVector(1.2, 0, 1.2),
							CFrame = clone2.Head.CFrame * CFrame.new(0, -0.6, 0)
						}
						local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
						v3:Create(clone2.Head, tweenInfo, v6):Play()
						local v7 = fn5(char, timeShift.InkPool)
						v7.Splash.Enabled = true
						game.Debris:AddItem(v7, 7)
						task.wait(0.25)
						clone3.Enabled = false
						clone2.Head.Transparency = 1

						for _, child in clone2:GetChildren() do
							if not (child.Name == "Torso" or child.Name == "Right Arm" or child.Name == "Left Arm") then
								continue
							end

							local v8 = {
								Size = Vector3.new(child.Size.X, 0, child.Size.Z),
								CFrame = child.CFrame * CFrame.new(0, -1, 0)
							}
							v3:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Linear), v8):Play()
							local clone4 = timeShift.SparkleDestroy.Stars:Clone()
							clone4.Parent = child
							clone4.Enabled = true
							local v10 = child
							task.spawn(function()
								task.wait(0.5)
								clone4.Enabled = false
								v10.Transparency = 1
								task.wait(0.5)
								v10:Destroy()
							end)
						end

						task.wait(0.5)
						clone2.Head:Destroy()

						for _, child in clone2:GetChildren() do
							if not (child.Name == "Right Leg" or child.Name == "Left Leg") then
								continue
							end

							local v8 = {
								Size = Vector3.new(child.Size.X, 0, child.Size.Z),
								CFrame = child.CFrame * CFrame.new(0, -1, 0)
							}
							v3:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Linear), v8):Play()
							local clone4 = timeShift.SparkleDestroy.Stars:Clone()
							clone4.Parent = child
							clone4.Enabled = true
							local v10 = child
							task.spawn(function()
								task.wait(0.5)
								clone4.Enabled = false
								v10.Transparency = 1
								task.wait(0.5)
								v10:Destroy()
							end)
						end

						v7.Splash.Enabled = false
					end,
					DelayedBarrage = function()
						local v5 = fn5(char, timeShift.DelayedBarrageCenter)
						game.Debris:AddItem(v5, 10)
						ye(v5, 7) -- equivalent call inferred; original call site unknown

						for _ = 1, 5 do
							fn2({ char, targChar }, math.random(1, 5))

							if not (v5 and v5.Parent) then
								return
							end

							local clone2 = timeShift.Punches:GetChildren()[math.random(1, 3)]:Clone()
							ye(clone2, 4) -- equivalent call inferred; original call site unknown
							clone2.Parent = workspace.Thrown
							game.Debris:AddItem(clone2, 2)
							clone2.CFrame = CFrame.lookAt(
								v5.Position + Vector3.new(
									math.random(-20, 20) / 10,
									math.random(-20, 20) / 10,
									math.random(-10, 10) / 10
								),
								v5.Attachment.WorldCFrame.Position
							)

							for _, emitter in clone2:GetDescendants() do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							task.wait(0.06)
						end

						fn2({ char, targChar }, 5, 0.35)
					end,
					DelayedHit = function()
						local timeBubble = targChar.Torso.TimeBubble
						timeBubble.Constant:Destroy()
						ye(timeBubble, 5) -- equivalent call inferred; original call site unknown
						local folder = fn5(char, timeShift.BubbleBreak)
						fn2({ char, targChar }, 2)
						ye(folder, 4) -- equivalent call inferred; original call site unknown

						for _, emitter in folder:GetDescendants() do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter:Emit(emitter:GetAttribute("EmitCount"))
							v3:Create(emitter, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
								TimeScale = 1
							}):Play()
						end
					end,
					CreateClone = function()
						local folder = fn5(char, timeShift.CreateClone)
						ye(folder, 7) -- equivalent call inferred; original call site unknown

						for _, emitter in folder:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						local v5 = fn5(char, timeShift.BarrageCenter)
						local position = v5.Attachment.WorldCFrame.Position
						ye(v5, 5) -- equivalent call inferred; original call site unknown
						local v6 = fn5(char, timeShift.PunchStreaks)
						ye(v6, 5) -- equivalent call inferred; original call site unknown
						v6.Attachment.Flare.Enabled = true
						v6.LineThing.Enabled = true
						local v7 = fn5(char, timeShift.BloodSplats)
						game.Debris:AddItem(v7, 6)
						ye(v7, 5) -- equivalent call inferred; original call site unknown

						for i = 1, 23 do
							if not (folder and folder.Parent) then
								break
							end

							local v8 = i % 6 + 1
							v6:FindFirstChild(v8).Swipe:Emit(1)
							v6:FindFirstChild(v8).Swipe2:Emit(1)
							v6.Shine:Emit(1)
							fn2({ char, targChar }, Random.new():NextNumber(0.9, 1.35))
							local clone2 = timeShift.BarrageFirst:Clone()
							clone2.Parent = workspace.Thrown
							ye(clone2, 2) -- equivalent call inferred; original call site unknown
							clone2.CFrame = CFrame.lookAt(
								v5.Position + Vector3.new(
									math.random(-20, 20) / 10,
									math.random(-20, 20) / 10,
									math.random(-10, 10) / 10
								),
								position
							)

							for _, emitter in clone2:GetDescendants() do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							if i % 2 == 0 then
								v7.Blood:Emit(1)
							end

							if i > 6 then
								if i > 14 then
									task.wait(0.02)
								else
									task.wait(0.06)
								end
							else
								task.wait(0.08)
							end
						end

						if v6 and v6.Parent then
							v6.Attachment.Flare.Enabled = false
							v6.LineThing.Enabled = false
						end
					end,
					Land = function()
						local folder = fn5(char, timeShift.Land)
						ye(folder, 5) -- equivalent call inferred; original call site unknown

						for _, emitter in folder:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						local clone2 = timeShift.ArmTrails.ArmTrail:Clone()
						clone2.Parent = char["Left Arm"]
						game.Debris:AddItem(clone2, 2)
						clone2.Circle.Circle:Emit(1)
						local clone3 = timeShift.ArmTrails.ArmTrail:Clone()
						clone3.Parent = char["Right Arm"]
						game.Debris:AddItem(clone3, 2)
						clone3.Circle.Circle:Emit(1)

						for _, v5 in pairs({ clone3, clone2 }) do
							ye(v5, 5) -- equivalent call inferred; original call site unknown
						end

						task.wait(1.2)

						if folder and folder.Parent then
							clone2.Bottom.Stars.Enabled = false
							clone3.Bottom.Stars.Enabled = false
						end
					end,
					EnemyFlingBack = function()
						task.wait(0.35)

						if not realAnim.IsPlaying then
							return
						end

						local folder = fn5(char, timeShift.TimeTrap)
						fn2({ char, targChar }, 3)
						ye(folder, 5) -- equivalent call inferred; original call site unknown

						for _, emitter in folder:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						if not realAnim.IsPlaying then
							return
						end

						local clone2 = timeShift.TimeBubble.TimeBubble:Clone()
						ye(clone2, 4) -- equivalent call inferred; original call site unknown
						clone2.Parent = targChar.Torso
						game.Debris:AddItem(clone2, 5)

						for _, emitter in clone2.Initial:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						for _, child in ipairs(clone2.Constant:GetChildren()) do
							child.Enabled = true
						end

						clone2.Constant.Circle:Emit(1)
					end,
					ImpactStart = function()
						local v5 = fn5(char, timeShift.PunchThrough)
						fn2({ char, targChar }, 4, 0.35)
						ye(v5, 4) -- equivalent call inferred; original call site unknown
						local thing = v5.Thing
						thing:SetPrimaryPartCFrame(primaryPart.CFrame * thing.Thing:GetAttribute("Offset"))

						if not realAnim.IsPlaying then
							return
						end

						v5.BackMore.LensFlare.Enabled = true

						for _, emitter in ipairs(v5.Thing.Thing.Constant:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						for _, emitter in ipairs(v5.Thing.Thing.Initial:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						task.wait(0.4)

						if not realAnim.IsPlaying then
							return
						end

						task.spawn(function()
							for i = 1, 16 do
								if not (realAnim.IsPlaying and v5) then
									break
								end

								v5.Thing:ScaleTo(i % 2 * -1 * (i / 40) + 1)
								task.wait(0.05)
							end
						end)
						task.wait(0.8)

						if not realAnim.IsPlaying then
							return
						end

						fn2({ char, targChar }, 4, 0.1)
						v5.BackMore.LensFlare.Enabled = false
						v5.Thing:ScaleTo(1)

						for _, emitter in ipairs(v5.Thing.Thing.Constant:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						for _, emitter in v5.Boom:GetChildren() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					end,
					Roar = function()
						fn2({ char, targChar }, 3, 0.4)
						local v5 = fn5(char, timeShift.InfernalCircle)
						ye(v5, 4) -- equivalent call inferred; original call site unknown

						for _, emitter in v5.Ground:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						for _, emitter in v5.Constant:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						v5.Constant.Beam.Enabled = true
						v5.Constant.Beam.Width1 = 10
						v5.Constant.Beam.Width0 = 5
						local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
						v3:Create(v5.Constant.Beam, tweenInfo, {
							Width1 = 20,
							Width0 = 10
						}):Play()
						task.wait(0.6)

						if not realAnim.IsPlaying then
							return
						end

						local clone2 = timeShift.FireArms.FireTrail:Clone()
						clone2.Parent = char:FindFirstChild("Right Arm")
						ye(clone2, 4) -- equivalent call inferred; original call site unknown
						game.Debris:AddItem(clone2, 2)

						for _, child in clone2.Hand:GetChildren() do
							child:Emit(child:GetAttribute("EmitCount"))
						end

						for _, trail in clone2:GetDescendants() do
							if trail:IsA("Trail") then
								trail.Enabled = true
							end
						end

						task.wait(0.05)

						if not realAnim.IsPlaying then
							return
						end

						local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
						v3:Create(v5.Constant.Beam, tweenInfo2, {
							Width1 = 0,
							Width0 = 0
						}):Play()

						for _, emitter in v5.Constant:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						task.wait(0.2)

						if not realAnim.IsPlaying then
							return
						end

						v5.Constant.Beam.Enabled = false
						task.wait(0.35)

						if not realAnim.IsPlaying then
							return
						end

						for _, effect in clone2:GetDescendants() do
							if effect:IsA("Trail") then
								effect.Enabled = false
							end

							if effect:IsA("ParticleEmitter") then
								effect.Enabled = false
							end
						end
					end
				},
				DontDisconnectMarkers = false,
				sendingdata = sendingdata,
				cleanup = cleanup
			})
		end
	},
	Pride = {
		StartupFunction = function(data)
			local char = data.Char
			local primaryPart = data.Char.PrimaryPart
			local cleanup = data.cleanup
			local pride = script.RealAssets.Pride
			local v3 = {
				Text = CFrame.new(-1.50000036, -0.225896835, 0.129238129, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				Symbol = CFrame.new(
					0.1771698,
					-3,
					-0.999992371,
					0.99999994,
					-2.48277008e-8,
					0,
					2.4827699e-8,
					1,
					8.72372894e-8,
					0,
					-8.72372894e-8,
					0.99999994
				),
				Lines = CFrame.new(0.0299999993, -1.18527019, -0.107999802, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				Head = CFrame.new(0, 1.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				LinesTwo = CFrame.new(
					-1.67300415,
					-0.711456299,
					0.0506057739,
					0.99999994,
					3.17196898e-13,
					0.0000116825104,
					-3.17198335e-13,
					1,
					1.22687085e-13,
					-0.0000116825104,
					-1.22690798e-13,
					0.99999994
				)
			}

			local function fn12(primaryPart2)
				if primaryPart2:IsA("Model") and primaryPart2.PrimaryPart then
					primaryPart2 = primaryPart2.PrimaryPart
				end

				if primaryPart2:IsA("Part") or primaryPart2:IsA("MeshPart") and v3[tostring(primaryPart2)] then
					primaryPart2.Anchored = false
					primaryPart2.Massless = true
					primaryPart2.CanCollide = false
					local weld = Instance.new("Weld")
					weld.Part0 = primaryPart
					weld.Part1 = primaryPart2
					weld.C0 = v3[primaryPart2.Name]
					weld.Parent = primaryPart2
				end
			end

			local function fn13(instance)
				local clone = instance:Clone()
				table.insert(data.cleanup, clone)

				if instance.Name ~= "Text" and instance.Name ~= "LinesTwo" then
					task.delay(5, function()
						if clone and clone.Parent then
							clone:Destroy("")
						end
					end)
				end

				clone.Parent = instance.Name == "Text" and char or workspace.Thrown

				if instance.Name ~= "Text" and instance.Name ~= "LinesTwo" then
					table.insert(cleanup, clone)
				end

				if tostring(instance) ~= "SteamArm" then
					fn12(clone)
				end

				return clone
			end

			local folder = fn13(pride.Lines)
			local TweenService2 = game:GetService("TweenService")
			local v4 = false
			local folder2 = nil

			local function fn14()
				if not v4 then
					v4 = true

					if folder then
						local folder3 = folder
						TweenService2:Create(
							folder.BeamUp,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								CFrame = lastpos
							}
						):Play()
						TweenService2:Create(folder.PointLight, TweenInfo.new(0.5), {
							Brightness = 0
						}):Play()

						for _, beam in pairs(folder3:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							TweenService2:Create(
								beam,
								TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									TextureSpeed = 0.175
								}
							):Play()
							TweenService2:Create(
								beam,
								TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Width0 = 0
								}
							):Play()
							TweenService2:Create(
								beam,
								TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Width1 = 0
								}
							):Play()
							TweenService2:Create(
								beam,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Brightness = 0
								}
							):Play()
						end
					end

					if folder2 then
						for _, emitter in pairs(folder2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								TweenService2:Create(
									emitter,
									TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
									{
										TimeScale = 0.75
									}
								):Play()
							end
						end
					end
				end
			end

			local function fn15()
				if not (data.EmoteBind and data.EmoteBind.Parent) then
					return fn14()
				end

				local folder3 = fn13(pride.Text)
				local emoteBind = data.EmoteBind

				if emoteBind then
					emoteBind:GetPropertyChangedSignal("Parent"):Connect(function()
						if not emoteBind.Parent then
							local Debris = game:GetService("Debris")
							Debris:AddItem(folder3, 0)
						end
					end)

					if not emoteBind.Parent then
						local Debris = game:GetService("Debris")
						Debris:AddItem(folder3, 0)
					end
				else
					local Debris = game:GetService("Debris")
					Debris:AddItem(folder3, 0)
				end

				for _, emitter in pairs(folder3:GetDescendants()) do
					if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitDelay")) then
						continue
					end

					local v5 = emitter
					task.delay(emitter:GetAttribute("EmitDelay"), function()
						v5:Emit(v5:GetAttribute("EmitCount"))
						task.delay(5, function()
							if v5 and v5.Parent then
								v5.TimeScale = 0
							end
						end)
					end)
				end
			end

			task.delay(1.3399999999999999, function()
				if data.EmoteBind and data.EmoteBind.Parent then
					fn15()
				end
			end)
			folder.Floor.CFrame = primaryPart.CFrame * CFrame.new(
				0.0299999993,
				-2.8024292,
				-0.108000003,
				1,
				0,
				0,
				0,
				1,
				0,
				0,
				0,
				1
			)
			folder.BeamUp.CFrame = CFrame.new(0, 8.388, 0)
			folder.PointLight.Brightness = 10
			local folder3 = fn13(pride.Symbol)

			for _, emitter in pairs(folder3:GetDescendants()) do
				if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitDelay")) then
					continue
				end

				local v5 = emitter
				task.delay(emitter:GetAttribute("EmitDelay"), function()
					if v5:GetAttribute("EmitDuration") then
						task.spawn(function()
							v5.Enabled = true
							task.wait(v5:GetAttribute("EmitDuration"))
							v5.Enabled = false
						end)
					end

					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			TweenService2:Create(
				folder.PointLight,
				TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Brightness = 2
				}
			):Play()
			folder2 = folder

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.TimeScale = 1
				end
			end

			for _, beam in pairs(folder:GetDescendants()) do
				if not (beam:IsA("Beam") and beam:GetAttribute("EmitDuration")) then
					continue
				end

				local v5 = beam
				task.spawn(function()
					if not (data.EmoteBind and data.EmoteBind.Parent) then
						return fn14()
					end

					v5.Enabled = true
					v5.TextureSpeed = 2.6
					v5.Width1 = 0
					v5.Width0 = 0
					v5.Brightness = 1
					TweenService2:Create(v5, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Width1 = 10
					}):Play()
					TweenService2:Create(v5, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Width0 = 14
					}):Play()
					task.wait(v5:GetAttribute("EmitDuration"))
					v5.Enabled = false
				end)
			end

			for _, emitter in pairs(folder:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter:GetAttribute("EmitDelay") then
					local v5 = emitter
					task.delay(emitter:GetAttribute("EmitDelay"), function()
						v5:Emit(v5:GetAttribute("EmitCount"))
					end)
				end

				if not emitter:GetAttribute("EmitDuration") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					v5.Enabled = true
					task.wait(v5:GetAttribute("EmitDuration"))
					v5.Enabled = false
				end)
			end

			task.wait(0.2)

			if not (data.EmoteBind and data.EmoteBind.Parent) then
				return fn14()
			end

			local cframe = CFrame.new(0, 12, 0)

			for _, beam in pairs(folder:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				TweenService2:Create(beam, TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					TextureSpeed = 0.175
				}):Play()
				TweenService2:Create(beam, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Width0 = 0
				}):Play()
				TweenService2:Create(beam, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Width1 = 0
				}):Play()
				TweenService2:Create(beam, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Brightness = 0
				}):Play()
			end

			task.wait(0.2)

			if not (data.EmoteBind and data.EmoteBind.Parent) then
				return fn14()
			end

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService2:Create(emitter, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						TimeScale = 0.75
					}):Play()
				end
			end

			TweenService2:Create(folder.BeamUp, TweenInfo.new(1.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = cframe
			}):Play()
			task.delay(1, function()
				if folder and folder.Parent then
					TweenService2:Create(folder.PointLight, TweenInfo.new(0.65), {
						Brightness = 0
					}):Play()
				end
			end)
		end
	},
	["Energy Barrage"] = {
		StartupFunction = function(p)
			local cleanup = p.cleanup
			local char = p.Char
			local energyBarrage = script.RealAssets["Energy Barrage"]
			local clone = energyBarrage.Charge:Clone()
			clone.Parent = char["Right Arm"]
			local part = clone.Part
			part.Part0 = char["Right Arm"]
			part.Part1 = clone
			part.Parent = char["Right Arm"]

			for _, v3 in pairs({ part, clone }) do
				table.insert(cleanup, v3)
				game.Debris:AddItem(v3, 5)
			end

			fn8(clone)
			local pointLight = clone.PointLight
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(pointLight, TweenInfo.new(1.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Brightness = 0
			}):Play()
			local clone2 = energyBarrage.Mesh1:Clone()
			clone2.Parent = workspace.Thrown
			game.Debris:AddItem(clone2, 5)
			table.insert(cleanup, clone2)
			clone2:SetPrimaryPartCFrame(char.PrimaryPart.CFrame * CFrame.new(
				0.550508738,
				-0.544127226,
				-1.98861122,
				0.364312619,
				0.0203950703,
				0.9310534,
				0.770004511,
				0.555725038,
				-0.313469112,
				-0.523802876,
				0.83111608,
				0.186753333
			))
			meshes(clone2.Start)
		end,
		ManualVfxMarkers = {
			start = function(data)
				local v3 = true
				task.delay(1.25, function()
					v3 = false
				end)
				local cleanup = data.cleanup
				local char = data.Char
				local energyBarrage = script.RealAssets["Energy Barrage"]
				local clone = energyBarrage.Flare:Clone()
				clone.Parent = workspace.Thrown
				clone.Anchored = true
				clone.CanCollide = false
				table.insert(cleanup, clone)
				game.Debris:AddItem(clone, 5)
				local part = clone.Part
				clone.Anchored = false
				part.Part0 = char["Right Arm"]
				part.Part1 = clone
				part.Parent = char["Right Arm"]
				local clone2 = energyBarrage.Shadows:Clone()
				clone2.Parent = workspace.Thrown
				clone2.Anchored = true
				clone2.CanCollide = false
				table.insert(cleanup, clone2)
				game.Debris:AddItem(clone2, 5)
				local clone3 = energyBarrage.Blast:Clone()
				clone3.Parent = workspace.Thrown
				clone3.Anchored = true
				clone3.CanCollide = false
				table.insert(cleanup, clone3)
				game.Debris:AddItem(clone3, 5)
				local primaryPart = char.PrimaryPart
				clone2.CFrame = primaryPart.CFrame * CFrame.new(
					0.366658211,
					-0.647371531,
					-0.0279288292,
					1,
					0,
					0,
					0,
					0.954035819,
					0.299692631,
					0,
					-0.299692631,
					0.954035819
				)
				clone3.CFrame = primaryPart.CFrame * CFrame.new(
					-0.0279541016,
					-2.68310118,
					-4.47197533,
					1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					1
				)
				local clones = {}

				for _, child in pairs(energyBarrage.meshco2:GetChildren()) do
					local clone4 = child:Clone()
					clone4.Parent = workspace.Thrown
					game.Debris:AddItem(clone4, 5)
					table.insert(cleanup, clone4)
					local v4 = {
						Mesh1 = CFrame.new(
							0.0567238331,
							-3.10474038,
							-5.71570921,
							-0.0972452834,
							-0.0344095677,
							0.994665444,
							-0.59640193,
							0.802103937,
							-0.0305602588,
							-0.796773493,
							-0.596192122,
							-0.0985228345
						),
						Mesh2 = CFrame.new(0.0790758133, -3.74736953, -4.53130436, 1, 0, 0, 0, 1, 0, 0, 0, 1),
						Mesh3 = CFrame.new(
							0.319773912,
							0.860762358,
							0.635813951,
							0,
							0,
							-1,
							-0.880613863,
							0.473834604,
							0,
							0.473834604,
							0.880613863,
							0
						)
					}
					clone4:SetPrimaryPartCFrame(primaryPart.CFrame * v4[tostring(clone4)])
					table.insert(clones, clone4)
				end

				local function fn12()
					for _, v5 in pairs({ clone2, clone3, clone }) do
						fn8(v5)
					end

					local spotLight = clone3.Light.SpotLight
					spotLight.Brightness = 23
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(
						spotLight,
						TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Brightness = 0
						}
					):Play()

					for _, v5 in pairs(clones) do
						meshes(v5.Start)
					end
				end

				local lastTime = tick()

				while task.wait(0.1) and not (tick() - lastTime >= 1.5) and v3 and clone and clone.Parent do
					fn12()

					if char == game.Players.LocalPlayer.Character or data.targChar == game.Players.LocalPlayer.Character then
						shared.addshake(2)
					end
				end
			end
		}
	},
	["Dragon Combo"] = {
		CanRotate = true,
		ManualVfxMarkers = {
			kick = function(instance)
				local char = instance.Char
				fn10({
					Part = script.RealAssets["Dragon Combo"].FirstKick,
					CFrame = instance.Char.PrimaryPart.CFrame * CFrame.new(
						-0.194038391,
						0.110570431,
						-2.67600632,
						1,
						0,
						0,
						0,
						1,
						0,
						0,
						0,
						1
					),
					cleanup = instance.cleanup,
					Char = char,
					TempWc = true,
					WeldData = {
						Part0 = instance.PrimaryPart,
						DeletionTime = 0.125
					}
				})
			end,
			knee = function(instance)
				local char = instance.Char
				fn10({
					Part = script.RealAssets["Dragon Combo"].SecondKick,
					CFrame = instance.Char.PrimaryPart.CFrame * CFrame.new(
						0.419416428,
						0.213001251,
						-2.73835373,
						1,
						0,
						0,
						0,
						0.987193644,
						-0.159526601,
						0,
						0.159526601,
						0.987193644
					),
					cleanup = instance.cleanup,
					Char = char,
					TempWc = true,
					WeldData = {
						Part0 = instance.PrimaryPart,
						DeletionTime = 0.125
					}
				})
			end,
			elbow = function(instance)
				local char = instance.Char
				fn10({
					Part = script.RealAssets["Dragon Combo"].Punch,
					CFrame = instance.Char.PrimaryPart.CFrame * CFrame.new(
						-0.108257294,
						1.001791,
						-2.73835373,
						1,
						0,
						0,
						0,
						0.987193644,
						-0.159526601,
						0,
						0.159526601,
						0.987193644
					),
					cleanup = instance.cleanup,
					Char = char,
					TempWc = true,
					WeldData = {
						Part0 = instance.PrimaryPart,
						DeletionTime = 0.125
					}
				})
			end,
			before = function(p)
				local char = p.Char
				local clone = script.RealAssets["Dragon Combo"].Spin:Clone()
				clone:SetAttribute("CleanupVfx", true)
				game.Debris:AddItem(clone, 4)
				table.insert(p.cleanup, clone)
				clone.Parent = workspace.Thrown
				clone.CFrame = p.Char.PrimaryPart.CFrame * CFrame.new(
					-0.0667285919,
					0.276163578,
					-0.00317764282,
					0.938543797,
					-0.260623813,
					0.226298034,
					0.241059393,
					0.964180171,
					0.110667206,
					-0.247034445,
					-0.049314931,
					0.967751026
				)
				clone.Anchored = false
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = char.PrimaryPart
				weldConstraint.Part1 = clone
				weldConstraint.Parent = clone
				game.Debris:AddItem(weldConstraint, 1)
			end,
			connect = function(p)
				local _ = p.Char
				local cleanup = p.cleanup
				fn7((function(p2)
					for _, part in pairs(cleanup) do
						if tostring(part) ~= "Connection" and typeof(part) ~= "thread" and part:IsA("Part") and tostring(part) == p2 and part:GetAttribute("CleanupVfx") then
							return part
						end
					end
				end)("Spin"), false) -- equivalent call inferred; original call site unknown
				local clone = script.RealAssets["Dragon Combo"].Last:Clone()
				clone:SetAttribute("CleanupVfx", true)
				game.Debris:AddItem(clone, 4)
				table.insert(p.cleanup, clone)
				clone.Parent = workspace.Thrown
				clone.Anchored = true
				clone.CFrame = p.Char.PrimaryPart.CFrame * CFrame.new(
					1.15736961,
					2.35800409,
					-2.05744553,
					0.946060956,
					0.0924426466,
					0.310521185,
					0.0847944021,
					0.854376137,
					-0.512690306,
					-0.312696338,
					0.511366844,
					0.800453186
				)

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Enabled = true
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				local thread = task.delay(0.1, function()
					if not (clone and clone.Parent) then
						return
					end

					for _, emitter in pairs(clone:GetDescendants()) do
						if not (emitter:IsA("ParticleEmitter") and emitter.Name == "Lines") then
							continue
						end

						emitter.TimeScale = 0.05
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(
							emitter,
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								TimeScale = 1
							}
						):Play()
						local v4 = emitter
						task.delay(0.8, function()
							v4.Enabled = false
						end)
					end
				end)
				table.insert(p.cleanup, thread)
			end,
			here = function(instance)
				local char = instance.Char
				fn10({
					Part = script.RealAssets["Dragon Combo"].Last,
					CFrame = instance.Char.PrimaryPart.CFrame * CFrame.new(
						-2.39925194,
						0.451612711,
						-1.62694168,
						0.224234238,
						-0.946514726,
						0.232010737,
						0.843607068,
						0.0693361685,
						-0.532465816,
						0.487900436,
						0.31512326,
						0.814033866
					),
					cleanup = instance.cleanup,
					Char = char,
					TempWc = true,
					WeldData = {
						Part0 = instance.PrimaryPart,
						DeletionTime = 0.125
					}
				})
			end,
			finished = function(instance)
				local char = instance.Char
				fn10({
					Part = script.RealAssets["Dragon Combo"].LastImpact,
					CFrame = instance.Char.PrimaryPart.CFrame * CFrame.new(
						-2,
						-2.90000057,
						-2.22402573,
						1,
						0,
						0,
						0,
						1,
						0,
						0,
						0,
						1
					),
					cleanup = instance.cleanup,
					Char = char,
					TempWc = true,
					WeldData = {
						Part0 = instance.PrimaryPart,
						DeletionTime = 0.125
					}
				})
			end
		}
	},
	["Explosive Stomps"] = {
		CanRotate = true,
		ManualVfxMarkers = {
			stomp = function(state)
				local char = state.Char
				local _ = state.cleanup
				local explosiveStomps = script.RealAssets["Explosive Stomps"]

				if state.stompcount then
					state.stompcount += 1
				else
					state.stompcount = 1
				end

				if state.stompcount ~= 2 then
					local v3 = 2 + state.stompcount / 10
					fn2({ char, state.targChar }, v3)
				end

				;({
					function()
						local v3 = fn5(char, explosiveStomps.NormalImpact)
						table.insert(state.cleanup, v3)
						fn8(v3)
						local weldConstraint = Instance.new("WeldConstraint")
						weldConstraint.Parent = v3
						weldConstraint.Part0 = v3
						weldConstraint.Part1 = char.PrimaryPart
						state.first = v3
					end,
					function()
						local folder = fn5(char, explosiveStomps.ImpactEnabled)
						table.insert(state.cleanup, folder)
						fn8(folder)
						local weldConstraint = Instance.new("WeldConstraint")
						weldConstraint.Parent = folder
						weldConstraint.Part0 = folder
						weldConstraint.Part1 = char.PrimaryPart

						for _, emitter in pairs(folder:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v4 = emitter
							task.spawn(function()
								v4.Enabled = true
							end)
						end

						state.impactenabled = folder
						spawn(function()
							local lastTime = tick()

							while task.wait(0.015) and not (tick() - lastTime >= 3) and folder and folder.Parent do
								if state.stophere then
									break
								else
									fn2({ char, state.targChar }, 1)
								end
							end
						end)
					end,
					function()
						state.stophere = true

						for _, emitter in pairs(state.impactenabled:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v3 = emitter
							task.spawn(function()
								v3:Emit(v3:GetAttribute("EmitCount"))
								v3.Enabled = false
							end)
						end
					end,
					function()
						for _, emitter in pairs(state.first:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v3 = emitter
							task.spawn(function()
								v3:Emit(v3:GetAttribute("EmitCount"))
							end)
						end
					end,
					function()
						fn8(state.first)
					end,
					function()
						fn8(state.first)
					end,
					function()
						local folder = fn5(char, explosiveStomps.Impact2)
						table.insert(state.cleanup, folder)
						fn8(folder)
						local weldConstraint = Instance.new("WeldConstraint")
						weldConstraint.Parent = folder
						weldConstraint.Part0 = folder
						weldConstraint.Part1 = char.PrimaryPart

						for _, emitter in pairs(folder:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v4 = emitter
							task.spawn(function()
								v4:Emit(v4:GetAttribute("EmitCount"))
							end)
						end
					end
				})[state.stompcount]()
			end,
			laststomp = function(p)
				local folder = fn5(p.Char, script.RealAssets["Explosive Stomps"].LastImpact)
				fn8(folder)

				for _, emitter in pairs(folder:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v3 = emitter
					task.spawn(function()
						v3:Emit(v3:GetAttribute("EmitCount"))
					end)
				end
			end
		},
		DontDisconnectMarkers = true
	},
	["Boxed Up"] = {
		ManualVfxMarkers = {
			axekick = function(p)
				local char = p.Char
				local clone = script.RealAssets["Boxed Up"].Part:Clone()
				clone.Transparency = 1
				clone.Parent = workspace.Thrown
				game.Debris:AddItem(clone, 5)
				clone.CFrame = char.PrimaryPart.CFrame * CFrame.new(0.4, -2.75, -4.5)
				task.delay(0.055, function()
					fn8(clone)
				end)
				table.insert(p.cleanup, clone)
			end
		}
	},
	["Sure Hit"] = {
		TransparencyData = {
			DoTransparency = true,
			TransparencyTime = 0.7
		},
		CutsceneData = {
			Anim = 108626770482262,
			NoLerpAfter = true,
			Offset = CFrame.new(0, 1, 0) * CFrame.Angles(0, 3.141592653589793, 0),
			From = "HumanoidRootPart"
		},
		Startup = function(p)
			local sfx = shared.sfx({
				SoundId = "rbxassetid://92024165829141",
				Parent = p.targChar.Torso,
				Volume = 2,
				RollOffMaxDistance = 85
			})
			sfx:Play()
			table.insert(p.cleanup, sfx)
		end,
		ManualVfxMarkers = {
			rip = function(data)
				local char = data.Char
				local character = game.Players.LocalPlayer.Character
				local v3 = character == char or character == data.targChar
				local clone = realAssets["Head Rip"].Background:Clone()
				clone.Parent = workspace.Thrown
				clone.Anchored = true
				clone.CFrame = char.PrimaryPart.CFrame * CFrame.new(0, 1, -2) * CFrame.Angles(0, 1.5707963267948966, 0)
				fn8(clone)
				fn9(data.targChar.Torso, realAssets["Head Rip"].Beams, 1.75)
				local v4 = fn6("DomainRipEmote", data.Char)
				TweenService:Create(v4, TweenInfo.new(0.1), {
					Color = Color3.fromRGB(255, 255, 255)
				}):Play()
				local v5 = {}

				if v3 then
					for _, parent in pairs({ char, data.targChar }) do
						local highlight = Instance.new("Highlight")
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillColor = Color3.fromRGB(0, 0, 0)
						highlight.FillTransparency = 0
						highlight.OutlineTransparency = 1
						highlight.Parent = parent
						game.Debris:AddItem(highlight, 5)
						table.insert(data.cleanup, highlight)
						table.insert(v5, highlight)
					end
				end

				wait(1.8)

				for _, v6 in pairs(v5) do
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(v6, TweenInfo.new(0.15), {
						FillTransparency = 1
					}):Play()
				end

				if not v4 then
					return
				end

				if v4 then
					table.remove(data.cleanup, table.find(data.cleanup, v4))
				end

				pcall(function()
					shared.sfx({
						SoundId = "rbxassetid://103104416579539",
						CFrame = v4.CFrame,
						Volume = 4,
						RollOffMaxDistance = 85
					}):Play()
					local callback = data.Callback
					v4:SetAttribute("DelayDeletion", 4)
					v4.Attachment["1"]:Emit(60)
					TweenService:Create(v4, TweenInfo.new(0.1), {
						Transparency = 1
					}):Play()

					if callback[1] then
						callback[1]()
					end
				end)
			end,
			touch = function(data)
				local cleanup = data.cleanup
				local char = data.Char
				local character = game.Players.LocalPlayer.Character
				local v3 = character == char or character == data.targChar
				local clone = realAssets["Head Rip"].DomainRipEmote:Clone()
				game.Debris:AddItem(clone, 8)
				clone.Anchored = true

				if not v3 then
					clone.Size *= 1.5
				end

				clone.Parent = workspace.Thrown
				clone:SetAttribute("Ownership", (tostring(char)))
				table.insert(cleanup, clone)
				clone.CFrame = char.PrimaryPart.CFrame * CFrame.new(0, 4, 0)
				TweenService:Create(clone, TweenInfo.new(0.35), {
					Transparency = 0
				}):Play()
			end
		}
	},
	["Lethal Beam"] = {
		Tasks = {
			[1.25] = function(data)
				local char = data.Char
				local cleanup = data.cleanup
				local lethalBeam = script.RealAssets["Lethal Beam"]
				local clone = lethalBeam.Part.Charge:Clone()
				clone:SetAttribute("Beam", true)
				table.insert(cleanup, clone)
				game.Debris:AddItem(clone, 10)
				clone.Parent = char.Head
				local clone2 = lethalBeam.Light:Clone()
				table.insert(cleanup, clone2)
				game.Debris:AddItem(clone2, 10)
				clone2.Parent = char.Head
				TweenService:Create(clone2, TweenInfo.new(1), {
					Brightness = 5
				}):Play()
				clone2.Name = "lethalbeamlight"
				local targChar = data.targChar
				spawn(function()
					local lastTime = tick()

					while task.wait(0.01) and clone and clone.Parent and workspace.Live:FindFirstChild((tostring(char))) and tick() - lastTime <= 0.9 do
						fn2({ char, targChar }, 0.25)
					end
				end)
			end,
			[2.19] = function(data)
				local char = data.Char
				local targChar = data.targChar
				local cleanup = data.cleanup
				local lethalBeam = script.RealAssets["Lethal Beam"]
				local clone = lethalBeam.Part.Ground:Clone()
				table.insert(cleanup, clone)
				game.Debris:AddItem(clone, 10)
				clone.Parent = char.PrimaryPart
				local v3 = nil
				spawn(function()
					local lastTime = tick()

					while task.wait(0.01) and clone and clone.Parent and workspace.Live:FindFirstChild((tostring(char))) and tick() - lastTime <= 0.85 do
						fn2({ char, targChar }, 1)
					end
				end)
				table.insert(cleanup, (task.delay(0.01, function()
					if not (clone and clone.Parent) then
						return
					end

					local clone2 = lethalBeam.Part.Beam:Clone()
					v3 = clone2
					table.insert(cleanup, clone2)
					game.Debris:AddItem(clone2, 10)
					clone2.Parent = char.PrimaryPart
				end)))
				table.insert(cleanup, (task.delay(0.35, function()
					if clone and clone.Parent then
						for _, child in pairs(clone:GetChildren()) do
							child.Enabled = false
						end
					end
				end)))
				table.insert(cleanup, (task.delay(0.8199999999999998, function()
					if not (clone and clone.Parent) then
						return
					end

					if v3 then
						for _, effect in pairs(v3:GetChildren()) do
							if effect:IsA("Beam") or effect:IsA("ParticleEmitter") then
								effect.Enabled = false
							end
						end

						local lethalbeamlight = char.Head:FindFirstChild("lethalbeamlight")

						if lethalbeamlight then
							TweenService:Create(lethalbeamlight, TweenInfo.new(0.65), {
								Brightness = 0
							}):Play()
						end

						local charge = char.Head:FindFirstChild("Charge")

						if charge and charge:IsA("Attachment") and charge:GetAttribute("Beam") then
							for _, child in pairs(charge:GetChildren()) do
								child.Enabled = false
							end

							game.Debris:AddItem(charge, 1)
						end
					end
				end)))
			end
		}
	},
	["slice combo"] = {
		CanRotate = true,
		DontDisconnectMarkers = true,
		ManualVfxMarkers = {
			slice = function(state)
				local function fn12()
					local char = state.Char
					local sliceCombo = script.RealAssets.SliceCombo

					for _, v3 in pairs({ sliceCombo.cleave1, sliceCombo.smokesuku }) do
						local v4 = fn5(char, v3)
						table.insert(state.cleanup, v4)
						fn8(v4)
					end
				end

				fn12()
				state.realfunction = fn12
				fn2({ state.targChar, state.Char }, 1.35)
			end,
			tar = function(state)
				if state.tar then
					for _, child in pairs(state.tar:GetChildren()) do
						child.Enabled = false
					end
				else
					local char = state.Char
					local v3 = fn5(char, script.RealAssets.SliceCombo.tar2)
					table.insert(state.cleanup, v3)
					local weldConstraint = Instance.new("WeldConstraint")
					weldConstraint.Part0 = char.PrimaryPart
					weldConstraint.Part1 = v3
					weldConstraint.Parent = v3
					state.tar = v3
				end
			end,
			chop = function(p)
				(function()
					local char = p.Char
					local sliceCombo = script.RealAssets.SliceCombo

					for _, v3 in pairs({ sliceCombo.final2, sliceCombo.finalcleave, sliceCombo.smokesuku2 }) do
						local v4 = fn5(char, v3)
						table.insert(p.cleanup, v4)

						if tostring(v3) == "final2" then
							local v5 = v4
							task.delay(0.053, function()
								fn7(v5, false) -- equivalent call inferred; original call site unknown
							end)
						else
							fn8(v4)
						end
					end
				end)()
			end
		}
	},
	Ruthless = {
		CutsceneData = {
			Anim = 126468024889342,
			Offset = CFrame.new() * CFrame.Angles(0, 3.141592653589793, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CamRigWithLetterBox3,
			ActualPart = "camera",
			NoLerpAfter = true
		},
		DontDisconnectMarkers = true,
		StartupFunction = function(p)
			local cleanup = p.cleanup
			local char = p.Char
			local clone = script.RealAssets.RuthlessCombo["Stone Wall"]:Clone()
			game.Debris:AddItem(clone, 5)
			table.insert(cleanup, clone)
			clone.Parent = workspace.Thrown
			clone:SetAttribute("Owner", (tostring(char)))
			clone:SetPrimaryPartCFrame(char.PrimaryPart.CFrame * CFrame.new(0, 0, -0.25))
			local sfx = shared.sfx({
				SoundId = "rbxassetid://115070297337427",
				Parent = clone.handle,
				Volume = 4,
				RollOffMaxDistance = char == game.Players.LocalPlayer.Character and 150 or 80
			})
			sfx:Play()
			table.insert(cleanup, sfx)
			local animation = Instance.new("Animation")
			game.Debris:AddItem(animation, 6)
			animation.AnimationId = "rbxassetid://81929189800796"
			animation.Parent = workspace.Thrown
			table.insert(cleanup, animation)
			local track = clone.AnimationController:LoadAnimation(animation)
			track:Play()
			local stoppedConnection = track.Stopped:Connect(function()
				if clone and clone.Parent then
					clone:SetPrimaryPartCFrame(char.PrimaryPart.CFrame * CFrame.new(0, 0, -4.5))
				end
			end)
			task.delay(5, function()
				if stoppedConnection then
					return stoppedConnection:Disconnect()
				end
			end)
		end,
		ManualVfxMarkers = {
			punch = function(p)
				local cleanup = p.cleanup
				local char = p.Char
				local ruthlessComboPart

				if char:FindFirstChild("RuthlessComboPart") then
					ruthlessComboPart = char:FindFirstChild("RuthlessComboPart")
				else
					ruthlessComboPart = script.RealAssets.RuthlessCombo.RuthlessComboPart:Clone()
					game.Debris:AddItem(ruthlessComboPart, 5)
					table.insert(cleanup, ruthlessComboPart)
					ruthlessComboPart.Parent = char
					ruthlessComboPart.CFrame = char.PrimaryPart.CFrame * CFrame.new(
						0.115600586,
						0.263999939,
						-3.45088959,
						-1,
						0,
						-8.74227766e-8,
						0,
						1,
						0,
						8.74227766e-8,
						0,
						-1
					)
				end

				if ruthlessComboPart and ruthlessComboPart.Parent then
					fn8(ruthlessComboPart, char, {
						Exclude = ruthlessComboPart.BigHit
					})
				end
			end,
			heavypunch = function(p)
				local _ = p.cleanup
				local char = p.Char

				if char:FindFirstChild("RuthlessComboPart") then
					local clone = script.RealAssets.RuthlessCombo.Wide:Clone()
					clone.CFrame = char.PrimaryPart.CFrame * CFrame.new(2, 0, -3.65) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					)
					clone.Parent = workspace.Thrown
					local Debris = game:GetService("Debris")
					Debris:AddItem(clone, 5)

					for _, emitter in pairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						shared.resizeparticle(emitter, 2)
						emitter.Speed = NumberRange.new(emitter.Speed.Min * 1.85, emitter.Speed.Max * 1.85)
						emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * 0.5, emitter.Lifetime.Max * 0.5)
						emitter:Emit(emitter:GetAttribute("EmitCount") * 2)
					end

					local folder = nil

					for _, child in pairs(workspace.Thrown:GetChildren()) do
						if not (tostring(child) == "Stone Wall" and child:GetAttribute("Owner") == tostring(char)) then
							continue
						end

						folder = child
						break
					end

					table.remove(p.cleanup, table.find(p.cleanup, folder))

					for _, descendant in pairs(folder:GetDescendants()) do
						if descendant:IsA("Motor6D") then
							descendant:Destroy()
						elseif descendant:IsA("MeshPart") then
							local v4 = descendant
							task.delay(0.6, function()
								if v4 and v4.Parent then
									TweenService:Create(
										v4,
										TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
										{
											Size = createVector(0, 0, 0)
										}
									):Play()
								end
							end)
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.Parent = descendant
							bodyVelocity.Velocity = char.PrimaryPart.CFrame.lookVector * math.random(80, 120) + Vector3.new(
								0,
								math.random(10, 30),
								0
							) * Random.new():NextNumber(1.2, 1.35)
							bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
							game.Debris:AddItem(bodyVelocity, Random.new():NextNumber(0.1, 0.2))
							local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
							bodyAngularVelocity.AngularVelocity = Vector3.new(
								math.random(-10, 10),
								math.random(-5, 5),
								math.random(-6, 6)
							) * Random.new():NextNumber(0.5, 1)
							bodyAngularVelocity.MaxTorque = createVector(2000000000, 2000000000, 2000000000)
							bodyAngularVelocity.Parent = descendant
							game:service("Debris"):AddItem(bodyAngularVelocity, 0.15)
						end
					end
				end
			end
		}
	},
	Weak = {
		ManualVfxMarkers = {
			start = function(data)
				local humiliation = script.RealAssets.Humiliation
				local char = data.Char
				local cleanup = data.cleanup

				for _, emitter in pairs(humiliation:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local clone = emitter:Clone()
					clone:SetAttribute("HumiliationSpeed", true)
					clone.Parent = char["Right Arm"]
					game.Debris:AddItem(clone, 5)
					table.insert(cleanup, clone)
				end

				local clone = humiliation.Part.Punchbarrage:Clone()
				clone:SetAttribute("CleanupVfx", true)
				clone.Parent = data.targChar.Head
				game.Debris:AddItem(clone, 5)
				table.insert(cleanup, clone)

				if char ~= game.Players.LocalPlayer.Character and data.targChar ~= game.Players.LocalPlayer.Character then
					return
				end

				local lastTime = tick()
				spawn(function()
					while task.wait(0.01) and not (tick() - lastTime >= 1.075) and clone do
						if not clone.Parent then
							break
						end

						shared.addshake(0.65)
					end
				end)
			end,
			stop = function(p)
				local char = p.Char
				local cleanup = p.cleanup
				local v3 = (function(p2)
					for _, attachment in pairs(cleanup) do
						if tostring(attachment) ~= "Connection" and typeof(attachment) ~= "thread" and attachment:IsA("Attachment") and tostring(attachment) == p2 and attachment:GetAttribute("CleanupVfx") then
							return attachment
						end
					end
				end)("Punchbarrage")

				if v3 then
					fn7(v3, false) -- equivalent call inferred; original call site unknown
					game.Debris:AddItem(v3, 2)
				end

				for _, child in pairs(char["Right Arm"]:GetChildren()) do
					if not (child.Name:find("Speedlines") and child:GetAttribute("HumiliationSpeed")) then
						continue
					end

					child.Enabled = false
					local v4 = child
					task.delay(1, function()
						if v4 and v4.Parent then
							return v4:Destroy()
						end
					end)
				end
			end,
			crack = function(data)
				local _ = data.Char
				local _ = data.cleanup
				local clone = script.RealAssets.Humiliation.Part.Necksnap:Clone()
				clone.Parent = data.targChar.Head
				game.Debris:AddItem(clone, 10)
				fn8(clone)
			end
		}
	},
	["Final Spark"] = {
		CutsceneData = {
			Anim = 81703661217800,
			Offset = CFrame.new(0, -3, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CamEntire,
			ActualPart = "CamPart",
			NoLerpAfter = true
		},
		StartupFunction = function(data)
			local targChar = data.targChar
			local primaryPart = data.Char.PrimaryPart
			local character = game.Players.LocalPlayer.Character

			if character == data.Char or character == targChar then
				primaryPart = game.Players.LocalPlayer.PlayerGui
				character = 3
			end

			for _, soundId in pairs({ "rbxassetid://115522807511223", "rbxassetid://115659241517024" }) do
				local volume = soundId == "rbxassetid://115659241517024" and 1.75 or character == 3 and 2.5 or 4.5
				local sfx = shared.sfx({
					SoundId = soundId,
					Parent = primaryPart,
					Volume = volume
				})
				sfx:Play()
				table.insert(data.cleanup, sfx)
			end
		end,
		RealModule = script.VfxMods.Flasher
	},
	["Shadow Eruption"] = {
		StartupFunction = function(p)
			local v3 = p.Char == game.Players.LocalPlayer.Character
			local sfx = shared.sfx({
				SoundId = "rbxassetid://126167683979349",
				Parent = v3 and game.Players.LocalPlayer.PlayerGui or p.Char.Torso,
				Volume = v3 and 3 or 6,
				PlaybackSpeed = 1
			})
			sfx:Play()
			table.insert(p.cleanup, sfx)
		end,
		CanRotate = true,
		RealModule = script.VfxMods.ShadowEruption,
		CutsceneData = {
			Anim = 103566103210307,
			Offset = CFrame.new(0, -3, 0, 0.999999881, 0, 2.98023224e-8, 0, 1, 0, 2.98023224e-8, 0, 1.00000024),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CamEzee,
			ActualPart = "CamPart",
			NoLerpAfter = true
		}
	},
	["Energy Explosion"] = {
		StartupFunction = function(_) end,
		CanRotate = true,
		RealModule = script.VfxMods.EnergyExplosion
	},
	Football1 = {
		StartupFunction = function(_) end
	},
	Isagi = {
		CutsceneData = {
			Anim = 71352315444179,
			Offset = CFrame.new(0, -3, 0) * CFrame.Angles(0, 3.141592653589793, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CamRigWithLetterBox,
			ActualPart = "camera",
			basic = true,
			FOV = script.Fovs.BallKick
		},
		RealModule = script.VfxMods.Isagi
	},
	["True Aura"] = {
		CutsceneData = {
			Anim = 77272264662660,
			Offset = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CamRigDook,
			ActualPart = "CameraPart",
			NoLerpAfter = true
		},
		StartupFunction = function(_) end,
		RealModule = script.VfxMods.TrueRage
	},
	["Divine Form"] = {
		CutsceneData = {
			Anim = 123321332402974,
			Offset = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CamRigNy,
			ActualPart = "CameraPart",
			NoLerpAfter = true
		},
		StartupFunction = function(p)
			local cleanup = p.cleanup
			local char = p.Char
			local v3 = char == game.Players.LocalPlayer.Character
			local sfx = shared.sfx({
				SoundId = "rbxassetid://110842657631060",
				Parent = v3 and game.Players.LocalPlayer.PlayerGui or char.PrimaryPart,
				Volume = v3 and 1.35 or 3.25
			})
			sfx:Play()
			table.insert(cleanup, sfx)
			task.delay(14, function()
				if sfx and sfx.Parent then
					table.remove(cleanup, table.find(cleanup, sfx))
				end
			end)
		end,
		RealModule = script.VfxMods.Evolved
	},
	Embers = {
		CutsceneData = {
			Anim = 85767288686407,
			Offset = CFrame.new(0, -3, 0, 0.999999881, 0, 2.98023224e-8, 0, 1, 0, 2.98023224e-8, 0, 1.00000024),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.Cam,
			ActualPart = "CamPart",
			NoLerpAfter = true,
			NoFov = true,
			EmberDelay = true,
			CustomSpeed = 0.96
		},
		DontDisconnectMarkers = true,
		ManualVfxMarkers = {
			hit = function(state)
				local char = state.Char
				local cleanup = state.cleanup
				local part = script.RealAssets.Ember.Part

				if not state.hitcount then
					state.hitcount = 0
				end

				state.hitcount += 1
				local parent = char[({
					"Right Arm",
					"Left Arm",
					"Right Arm",
					"Left Arm"
				})[state.hitcount]]

				if not parent:FindFirstChild("HitEmber") then
					for _, child in pairs(part:GetChildren()) do
						local clone = child:Clone()
						game.Debris:AddItem(clone, 10)
						table.insert(cleanup, clone)
						clone.Parent = parent
					end
				end

				for _, attachment in pairs(parent:GetChildren()) do
					if not (attachment:IsA("Attachment") and (attachment.Name == "HitEmber" or attachment.Name == "Impact")) then
						continue
					end

					for _, child in pairs(attachment:GetChildren()) do
						child:Emit(child:GetAttribute("EmitCount") * 2)
					end
				end

				for _, parent2 in pairs({ char, state.Victim }) do
					local cinderhighlight = parent2:FindFirstChild("cinderhighlight")

					if cinderhighlight then
						cinderhighlight:Destroy("")
					end

					local highlight = Instance.new("Highlight")
					highlight.Name = "cinderhighlight"
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					highlight.FillColor = Color3.fromRGB(0, 0, 0)
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.OutlineTransparency = 0
					highlight.FillTransparency = 0
					highlight.Parent = parent2
					game.Debris:AddItem(highlight, 0.1)
				end
			end,
			room = function(state)
				local othertable = {}
				local char = state.Char
				local cleanup = state.cleanup
				local primaryPart = char.PrimaryPart
				local v4 = char == game.Players.LocalPlayer.Character or state.targChar == game.Players.LocalPlayer.Character
				local clone = script.RealAssets.Ember.ye.Lightning:Clone()
				table.insert(cleanup, clone)
				game.Debris:AddItem(clone, 2)
				clone.Parent = char["Right Arm"]
				table.insert(othertable, clone["1"])
				table.insert(othertable, clone["2"])
				local ember = script.RealAssets.Ember
				local clone2 = ember.Background:Clone()
				table.insert(othertable, clone2)
				game.Debris:AddItem(clone2, 10)
				clone2.Parent = workspace.Thrown
				table.insert(cleanup, clone2)
				clone2.CFrame = primaryPart.CFrame * CFrame.new(
					0.209411621,
					1.43823242,
					-2.70602417,
					-0.999999881,
					0,
					-2.98023224e-8,
					0,
					1,
					0,
					-2.98023224e-8,
					0,
					-1.00000024
				)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(clone2, TweenInfo.new(0.65), {
					Transparency = v4 and 0 or 1
				}):Play()
				local v5 = {
					Beam1 = CFrame.new(
						-2.92773438,
						0.416320801,
						-19.6693726,
						-0.999999881,
						0,
						-2.98023224e-8,
						0,
						1,
						0,
						-2.98023224e-8,
						0,
						-1.00000024
					),
					Beam2 = CFrame.new(
						0.983093262,
						0.266876221,
						-19.6693726,
						-0.999999881,
						0,
						0,
						0,
						0.99619472,
						-0.087155737,
						-2.98023224e-8,
						-0.0871557519,
						-0.996194899
					),
					Beam3 = CFrame.new(
						0.983093262,
						1.34902954,
						-19.6693726,
						-0.999999881,
						3.7252903e-9,
						-2.98023224e-8,
						0,
						0.991392791,
						0.130921587,
						-2.98023224e-8,
						0.130921602,
						-0.99139297
					)
				}

				if v4 then
					for _, v6 in pairs({ ember.Beam1, ember.Beam2, ember.Beam3 }) do
						local clone3 = v6:Clone()
						table.insert(othertable, clone3)
						game.Debris:AddItem(clone3, 10)
						clone3.Parent = workspace.Thrown
						table.insert(cleanup, clone3)
						clone3.CFrame = primaryPart.CFrame * v5[tostring(v6)]
					end
				end

				state.othertable = othertable
			end,
			heavy = function(data)
				local char = data.Char
				fn10({
					Part = script.RealAssets.Ember.End,
					CFrame = data.Char.PrimaryPart.CFrame * CFrame.new(
						0.307342529,
						0.379882812,
						-1.87609863,
						-0.999999881,
						2.98023224e-8,
						0,
						0,
						0,
						1,
						-2.98023224e-8,
						1.00000024,
						0
					),
					cleanup = data.cleanup,
					Char = char
				})
				fn10({
					Part = script.RealAssets.Ember.Impulse,
					CFrame = data.Char.PrimaryPart.CFrame * CFrame.new(
						0.0914611816,
						-0.338897705,
						-0.94128418,
						0.999999881,
						-2.98023224e-8,
						0,
						0,
						0,
						1,
						2.98023224e-8,
						-1.00000024,
						0
					),
					cleanup = data.cleanup,
					Char = char
				})

				for _, folder in pairs(data.othertable) do
					if folder:IsA("MeshPart") then
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(folder, TweenInfo.new(0.15), {
							Transparency = 1
						}):Play()
					elseif folder:IsA("ParticleEmitter") then
						folder.Enabled = false
					else
						for _, descendant in pairs(folder:GetDescendants()) do
							if not (descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight")) then
								continue
							end

							descendant.Enabled = false
						end
					end
				end

				wait(0.1)
				data.CutsceneCallback()
			end
		}
	},
	["Beast Form"] = {
		CutsceneData = {
			Anim = 96912364616540,
			Offset = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CameraRigBeast,
			ActualPart = "CamPart",
			smoothin = true,
			smooth = true,
			NoLerp = true,
			smoothtime = 1.25
		},
		RealModule = script.VfxMods.BeastForm,
		StartupFunction = function(p)
			local cleanup = p.cleanup
			local char = p.Char
			local v3 = char == game.Players.LocalPlayer.Character
			local sfx = shared.sfx({
				SoundId = "rbxassetid://88364589044129",
				Parent = v3 and game.Players.LocalPlayer.PlayerGui or char.PrimaryPart,
				Volume = v3 and 1.35 or 3.25
			})
			sfx:Play()
			table.insert(cleanup, sfx)
			task.delay(14, function()
				if sfx and sfx.Parent then
					table.remove(cleanup, table.find(cleanup, sfx))
				end
			end)
		end
	},
	["Lightning Blitz"] = {
		CutsceneData = {
			Anim = 105254849512612,
			Offset = CFrame.new(0, -3, 0) * CFrame.Angles(0, 3.141592653589793, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CamRigWithLetterBox4,
			ActualPart = "camera",
			NoLerp = true,
			EnableShakeAfter = 7
		},
		RealModule = script.VfxMods.Electric,
		StartupFunction = function(data)
			local character = game.Players.LocalPlayer.Character
			local targChar = data.targChar
			local primaryPart = character.PrimaryPart
			local volume

			if character == data.Char or character == targChar then
				primaryPart = game.Players.LocalPlayer.PlayerGui
				volume = 1.35
			else
				volume = 3
			end

			if data.Char ~= game.Players.LocalPlayer.Character and data.targChar ~= game.Players.LocalPlayer then
				primaryPart = data.Char.PrimaryPart
			end

			local sfx = shared.sfx({
				SoundId = "rbxassetid://128625456789881",
				Parent = primaryPart,
				Volume = volume,
				RollOffMaxDistance = 130
			})
			sfx:Play()
			table.insert(data.cleanup, sfx)
		end
	},
	["Pocket Dimension"] = {
		CutsceneData = {
			Anim = 89179955166459,
			Offset = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.kakashicamrig,
			Fov = script.Fovs.lightningemote,
			ActualPart = "CamPart",
			NoLerp = true
		},
		StartupFunction = function(data)
			local character = game.Players.LocalPlayer.Character
			local targChar = data.targChar
			local v3 = character == data.Char or character == targChar
			local cleanup = data.cleanup

			for _, soundId in pairs({ "rbxassetid://105476342835741" }) do
				local torso = data.Char.Torso

				if v3 then
					torso = game.Players.LocalPlayer.PlayerGui
				end

				local sfx = shared.sfx({
					SoundId = soundId,
					Parent = torso,
					Volume = v3 and 2.5 or 4.5
				})
				sfx:Play()
				table.insert(cleanup, sfx)
				task.delay(0.5, function()
					sfx.TimePosition = 0.5
					wait(0.5)
					sfx.TimePosition = 1
				end)
			end
		end,
		RealModule = script.VfxMods.LightningEmote
	},
	["Nuclear Impact"] = {
		StartupFunction = function(data)
			local character = game.Players.LocalPlayer.Character
			local targChar = data.targChar
			local primaryPart = character.PrimaryPart
			local volume

			if character == data.Char or character == targChar then
				primaryPart = game.Players.LocalPlayer.PlayerGui
				volume = 2
			else
				volume = 4
			end

			if data.Char ~= game.Players.LocalPlayer.Character and data.targChar ~= game.Players.LocalPlayer then
				primaryPart = data.Char.PrimaryPart
			end

			local sfx = shared.sfx({
				SoundId = "rbxassetid://72216855452054",
				Parent = primaryPart,
				Volume = volume,
				TimePosition = 0.35,
				RollOffMaxDistance = 120
			})
			sfx:Play()
			table.insert(data.cleanup, sfx)
			local sfx2 = shared.sfx
			primaryPart:IsA("BasePart")
			local v5 = sfx2({
				SoundId = "rbxassetid://115702738192823",
				Parent = primaryPart,
				CFrame = primaryPart:IsA("BasePart") and data.Char.PrimaryPart.CFrame,
				Volume = volume,
				TimePosition = 0.25,
				RollOffMaxDistance = 120
			})
			v5:Play()
			table.insert(data.cleanup, v5)
		end,
		RealModule = script.VfxMods.Atomic
	},
	["Last Will"] = {
		StartupFunction = function(state)
			local thread = task.delay(2.2, function()
				if not (state.RealBind and state.RealBind.Parent) or state.Char ~= game.Players.LocalPlayer.Character and state.targChar ~= game.Players.LocalPlayer.Character and state.CutsceneBind ~= game.Players.LocalPlayer.Character then
					return
				end

				state.CameraPart = shared.CutsceneEvent({
					Anim = 103941810523228,
					Offset = CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 3.141592653589793, 0),
					From = state.Char.PrimaryPart,
					SpecificRig = script.Assets.CamRigWithLetterBox,
					ActualPart = "camera",
					DontDestroy = true,
					Fov = script.Fovs["Last Will"],
					Name = "Last Will",
					smooth = true,
					Bind = state.Bind,
					Char = state.Char
				})
			end)
			table.insert(state.cleanup, thread)
			local targChar = state.targChar
			local primaryPart = state.Char.PrimaryPart
			local character = game.Players.LocalPlayer.Character

			if character == state.Char or character == targChar then
				primaryPart = game.Players.LocalPlayer.PlayerGui
			end

			local sfx = shared.sfx({
				SoundId = "rbxassetid://93643832854840",
				Parent = primaryPart,
				Volume = primaryPart == game.Players.LocalPlayer.PlayerGui and 3 or 5
			})
			sfx:Play()
			table.insert(state.cleanup, sfx)
		end,
		RealModule = script.VfxMods.LastWill,
		ManualVfxMarkers = {
			send = function(data)
				local char = data.Char
				local targChar = data.targChar

				if char == game.Players.LocalPlayer.Character or targChar == game.Players.LocalPlayer.Character then
					wait(0.1)

					for _, child in pairs(char:GetChildren()) do
						if tostring(child) == "CamRigWithLetterBox" then
							child:Destroy("")
						end
					end

					local position = targChar.PrimaryPart.Position
					local lastTime = tick()
					local heartbeatConnection = nil
					local RunService2 = game:GetService("RunService")
					heartbeatConnection = RunService2.Heartbeat:Connect(function()
						if tick() - lastTime > 0.1 then
							workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
							game.Players.LocalPlayer.CameraMinZoomDistance = 0.5
							game.Players.LocalPlayer.CameraMaxZoomDistance = 128
							return heartbeatConnection:Disconnect()
						else
							workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
							workspace.CurrentCamera.FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
							game.Players.LocalPlayer.CameraMaxZoomDistance = 45
							local cFrame = workspace.CurrentCamera.CFrame
							workspace.CurrentCamera.CFrame = cFrame:Lerp(
								CFrame.new(char.PrimaryPart.Position, position),
								0.15
							)
						end
					end)
					task.delay(0.1, function()
						fn2({ char, data.CutsceneBind }, 4, 0.5)
					end)
				end
			end
		}
	},
	["Wombo Combo"] = {
		CutsceneData = {
			FindPart = "Cam"
		},
		StartupFunction = function(data)
			local targChar = data.targChar
			local primaryPart = data.Char.PrimaryPart
			local character = game.Players.LocalPlayer.Character
			local v3

			if character == data.Char or character == targChar then
				primaryPart = game.Players.LocalPlayer.PlayerGui
				v3 = true
				character = 3
			else
				v3 = false
			end

			if not v3 then
				for _, v4 in pairs({ data.Char, data.targChar }) do
					local v5 = v4
					spawn(function()
						local lastTime = tick()
						local v6 = false

						repeat
							task.wait()

							for k, v7 in pairs(v5.Humanoid:GetPlayingAnimationTracks()) do
								if not (v7.Animation.AnimationId == "rbxassetid://138962769294666" or v7.Animation.AnimationId == "rbxassetid://89772127095146") then
									continue
								end

								v7:Stop(0)
								v6 = true
							end
						until v6 or tick() - lastTime >= 0.01
					end)
				end

				for _, descendant in pairs(data.Char:GetDescendants()) do
					if descendant:GetAttribute("EmoteProperty") then
						descendant:Destroy("")
					end
				end

				local char = data.Char
				local module = require(char.CharacterHandler:FindFirstChild("AnimationPlayer") or char.CharacterHandler:WaitForChild("AnimationPlayer"))
				;(function(p)
					return module.playAnimation(char:FindFirstChild("Humanoid"), p)
				end)(140492523431668):Play()
			end

			for _, soundId in pairs({ "rbxassetid://82448766175600", "rbxassetid://134921734559342" }) do
				local volume = soundId == "rbxassetid://134921734559342" and 3 or character == 3 and 2.5 or 4.5
				local sfx = shared.sfx({
					SoundId = soundId,
					Parent = primaryPart,
					Volume = volume
				})
				sfx:Play()
				table.insert(data.cleanup, sfx)
			end
		end,
		RealModule = script.VfxMods["2v1"],
		ManualVfxMarkers = {
			kick = function(data)
				local targChar = data.targChar
				local char = data.Char
				local character = game.Players.LocalPlayer.Character

				if character == char or targChar == character then
					for _, part in pairs(char:GetDescendants()) do
						if part:IsA("Part") and part:GetAttribute("Custom2V1CAM") then
							part:Destroy("")
						end
					end
				end

				if char == game.Players.LocalPlayer.Character then
					local position = targChar.PrimaryPart.Position
					local lastTime = tick()
					local heartbeatConnection = nil
					local RunService2 = game:GetService("RunService")
					heartbeatConnection = RunService2.Heartbeat:Connect(function()
						if tick() - lastTime > 0.1 then
							workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
							game.Players.LocalPlayer.CameraMinZoomDistance = 0.5
							game.Players.LocalPlayer.CameraMaxZoomDistance = 128
							return heartbeatConnection:Disconnect()
						else
							workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
							workspace.CurrentCamera.FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
							game.Players.LocalPlayer.CameraMaxZoomDistance = 45
							workspace.CurrentCamera.CFrame = CFrame.new(char.PrimaryPart.Position, position)
						end
					end)
					task.delay(0.1, function()
						fn2({ char, targChar }, 4, 0.5)
					end)
				end

				data.RealAnim:Stop(0.8)
			end
		}
	},
	Emerge = {
		CutsceneData = {
			Anim = 97448479871185,
			Offset = CFrame.new(0, -3, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.EmergeCamera,
			ActualPart = "CamPart",
			NoLerpAfter = true
		},
		StartupFunction = function(data)
			local targChar = data.targChar
			local primaryPart = data.Char.PrimaryPart
			local character = game.Players.LocalPlayer.Character

			if character == data.Char or character == targChar then
				primaryPart = game.Players.LocalPlayer.PlayerGui
			end

			for _, soundId in pairs({ "rbxassetid://129247679395265", "rbxassetid://115016991259746" }) do
				local volume = soundId == "rbxassetid://129247679395265" and 1.75 or 2.25
				local sfx = shared.sfx({
					SoundId = soundId,
					Parent = primaryPart,
					Volume = volume
				})
				sfx:Play()
				table.insert(data.cleanup, sfx)
			end
		end,
		RealModule = script.VfxMods.Emerge
	},
	["Boundless Rage"] = {
		CutsceneData = {
			Anim = 112471633691073,
			Offset = CFrame.new(0, -2.5, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.Cam,
			ActualPart = "CamPart",
			NoLerpAfter = true
		},
		RealModule = script.VfxMods.Boundless
	},
	["Eternal Seal"] = {
		CutsceneData = {
			Anim = 137845184446346,
			Offset = CFrame.new(0, 0, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CamRig,
			ActualPart = "CameraPart",
			NoLerp = true
		},
		Tasks = {
			[9] = function(p)
				local cleanup = p.cleanup

				for _, model in pairs(cleanup) do
					if not (typeof(model) == "Instance" and model.Parent and model:IsA("Model") and model.Parent == p.Char) then
						continue
					end

					if not model:GetAttribute("CameraModel") then
						continue
					end

					model:SetAttribute("ForceDestroy", true)
					local primaryPart = p.Char.PrimaryPart

					if game.Players.LocalPlayer.Character ~= p.Char then
						break
					end

					local currentCamera = workspace.CurrentCamera
					local v3 = primaryPart.CFrame * CFrame.new(
						0.121032715,
						4.415802,
						15.8661346,
						0.999988973,
						-0.000791892409,
						0.00464361906,
						-2.88034645e-8,
						0.985767841,
						0.168112651,
						-0.00471064448,
						-0.168110803,
						0.985756874
					)
					currentCamera.CFrame = CFrame.new(
						v3.Position,
						(primaryPart.CFrame + primaryPart.CFrame.lookVector * 10).Position + createVector(0, 2, 0)
					)
					currentCamera.CameraType = Enum.CameraType.Custom
					local now = tick()
					local heartbeatConnection = nil
					local RunService2 = game:GetService("RunService")
					heartbeatConnection = RunService2.Heartbeat:Connect(function()
						if tick() - now > 0.15 then
							return heartbeatConnection:Disconnect()
						end

						currentCamera.CFrame = CFrame.new(
							v3.Position,
							(primaryPart.CFrame + primaryPart.CFrame.lookVector * 10).Position
						)
					end)
					break
				end
			end
		}
	},
	["Final Stand"] = {
		CutsceneData = {
			Anim = 140377514258867,
			Offset = CFrame.new(0, -3, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.Cam,
			NoFov = true,
			SpoofedStart = true,
			ActualPart = "CamPart",
			NoLerp = true
		},
		RealModule = script.VfxMods.FS
	},
	Wipe = {
		ManualVfxMarkers = {
			laser = function(p)
				local forgetdevice = p.Char:FindFirstChild("forget device")

				for _, emitter in pairs(forgetdevice:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end
		},
		CutsceneData = {
			Anim = 101909265258573,
			NoLerpAfter = true,
			Offset = CFrame.new(3, -0.75, -2.85) * CFrame.Angles(0, -1.5707963267948966, 0),
			From = "HumanoidRootPart"
		}
	},
	["Heart Strike"] = {
		TransparencyData = {
			DoTransparency = true,
			TransparencyTime = 1.95,
			FirstDelay = 1.8
		},
		ManualVfxMarkers = {
			TP = function(data)
				fn2({ data.targChar, data.Char }, 2)
				local char = data.Char
				local cleanup = data.cleanup
				local clone = script.RealAssets["Heart Strike"].TP:Clone()
				game.Debris:AddItem(clone, 4)
				clone.Parent = workspace.Thrown
				clone.CFrame = char.PrimaryPart.CFrame
				table.insert(cleanup, clone)
				fn8(clone)
			end,
			TP1 = function(data)
				fn2({ data.targChar, data.Char }, 2)
				local char = data.Char
				local cleanup = data.cleanup
				local clone = script.RealAssets["Heart Strike"].TP2:Clone()
				game.Debris:AddItem(clone, 4)
				clone.Parent = char
				clone.CFrame = char.Torso.CFrame
				table.insert(cleanup, clone)
				fn8(clone)
				local clone2 = script.RealAssets["Heart Strike"].RealLightning:Clone()
				table.insert(cleanup, clone2)
				game.Debris:AddItem(clone2, 5)
				clone2.Parent = char
				local weld = clone2:FindFirstChildOfClass("Weld")
				weld.Part1 = clone2
				weld.Part0 = char["Right Arm"]
			end,
			lightning = function(data)
				spawn(function()
					local lastTime = tick()

					while task.wait(0.05) and not (tick() - lastTime >= 0.6) do
						fn2({ data.targChar, data.Char }, Random.new():NextNumber(1.25, 2.25))
					end
				end)
				local cleanup = data.cleanup
				local char = data.Char
				local clone = script.RealAssets["Heart Strike"].Shock:Clone()
				table.insert(cleanup, clone)
				game.Debris:AddItem(clone, 5)
				clone.Parent = workspace.Thrown
				clone.CFrame = char.PrimaryPart.CFrame * CFrame.new(0, 0, 3)
				task.delay(1.65, function()
					if not clone or clone and not clone.Parent then
						return
					end

					if char:FindFirstChild("RealLightning") then
						for _, effect in pairs(char.RealLightning:GetDescendants()) do
							if not (effect:IsA("Trail") or effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
								continue
							end

							effect.Enabled = false
						end
					end

					fn7(clone, false) -- equivalent call inferred; original call site unknown
				end)
			end
		}
	},
	["Fly High"] = {
		Tasks = {
			[2.35] = function(p)
				local char = p.Char
				local cleanup = p.cleanup
				local clone = script.RealAssets["To Brazil"].Portall:Clone()
				table.insert(cleanup, clone)
				game.Debris:AddItem(clone, 7)
				clone.Parent = char
				local weld = clone:FindFirstChildOfClass("Weld")
				table.insert(cleanup, weld)
				game.Debris:AddItem(weld, 7)
				weld.Part0 = char.PrimaryPart
				weld.Part1 = clone
				weld.Parent = char.PrimaryPart

				for _, child in pairs(clone.Enable:GetChildren()) do
					if child.Name ~= "BR" then
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end

				table.insert(cleanup, (task.delay(2, function()
					if not (clone and clone.Parent) then
						return
					end

					local function d(p2)
						for _, emitter in pairs(clone:GetDescendants()) do
							if not (emitter:IsA("ParticleEmitter") and emitter.Parent.Name:find("Attachment") and (not p2 or emitter.Parent.Name == "Attachment")) then
								continue
							end

							emitter:Emit(emitter:GetAttribute("EmitCount") / 1.25)
						end
					end

					d()
					local thread = task.delay(1.15, function()
						local function cal(p2)
							for _, child in pairs(clone:GetChildren()) do
								if tostring(child) ~= p2 then
									continue
								end

								for _, child2 in pairs(child:GetChildren()) do
									child2.Enabled = false
								end
							end
						end

						for _, v3 in pairs({ "Beam", "MainPortal" }) do
							cal(v3)
						end

						task.delay(0.1, function()
							if clone and clone.Parent then
								clone.Enable.BR:Emit(1)
								d(true)
							end
						end)
					end)
					table.insert(cleanup, thread)
				end)))
			end
		},
		CutsceneData = {
			Anim = 85939913851851,
			Offset = CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 3.141592653589793, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CamRigWithLetterBox2,
			ActualPart = "camera"
		}
	},
	["Sumo Slap"] = {
		DontDisconnectMarkers = true,
		StartupFunction = function(p)
			local _ = p.cleanup
			local _ = p.Char
		end,
		RealModule = script.VfxMods.SumoSlap,
		CutsceneData = {
			Anim = 89699265607908,
			Offset = CFrame.new(0, -3, 0) * CFrame.Angles(0, 3.141592653589793, 0),
			From = "HumanoidRootPart",
			SpecificRig = script.Assets.CamRigWIthLetterBoxSumo,
			ActualPart = "camera",
			NoLerpAfter = true
		}
	}
}
local v3 = {}
local RunService2 = game:GetService("RunService")

if RunService2:IsClient() then
	game.Players.PlayerRemoving:Connect(function(player)
		if v3[player] then
			local v4 = v3[player]

			for _, connection in pairs(v4.cleanup) do
				if typeof(connection) == "RBXScriptConnection" then
					connection:Disconnect()
				elseif typeof(connection) == "thread" then
					task.cancel(connection)
				elseif typeof(connection) == "Instance" then
					if connection:GetAttribute("DelayDeletion") then
						game.Debris:AddItem(connection, connection:GetAttribute("DelayDeletion"))
					else
						connection:Destroy()
					end
				end
			end

			for _, task2 in pairs(v4.tasks) do
				task.cancel(task2)
			end

			v3[player] = nil
		end
	end)
end

function VFX.MainFunction(_, player)
	local v4 = VFX[player.vfxName]
	assert(v4, "No table data found, put it in.")
	typeof(v4)

	if not player.Victim then
		player.Victim = player.Character
	end

	local character = player.Character
	local victim = player.Victim
	local v5 = {}
	local v6 = fn4(character.Humanoid, player.AnimSent)

	if not v6 then
		return
	end

	local transparenciesByDescendant = {}
	local threads = {}
	local child = game.Players:FindFirstChild((tostring(character)))
	local RunService3 = game:GetService("RunService")

	if RunService3:IsClient() then
		child = child or workspace.Live:FindFirstChild((tostring(character)))

		if table.find(v3, child) then
			table.remove(v3, table.find(v3, child))
		end

		if v3[child] then
			v3[child] = nil
		end

		v3[child] = {
			cleanup = v5,
			tasks = threads
		}
	end

	if character:GetAttribute("ForcedCFrame") then
		character:SetAttribute("ForcedCFrame", nil)
	end

	local realBind = nil
	local callback = {}
	local flag = false
	local sendingdata = {
		Char = character,
		CleanupTable = v5,
		RealAnim = v6,
		Bind = realBind,
		EmoteBind = player.EmoteBind,
		Callback = callback,
		targChar = victim,
		cleanup = v5,
		Interrupted = flag,
		EmoteCall = true,
		CutsceneBind = player.CutsceneBind,
		CutsceneCallback = nil
	}

	if player.RealBind then
		realBind = player.RealBind
		realBind:SetAttribute("EmoteBindThing", true)
		sendingdata.Bind = realBind
	end

	local function fn12(folder, transparency)
		if character:FindFirstChild("SpiderLegs") then
			local meshPart = character:FindFirstChild("SpiderLegs"):FindFirstChildOfClass("MeshPart")
			meshPart.Transparency = 1
		end

		if transparency == 0 then
			for k, transparency2 in pairs(transparenciesByDescendant) do
				k.Transparency = transparency2
			end
		else
			for _, descendant in pairs(folder:GetDescendants()) do
				if not (descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("Decal") or descendant:IsA("UnionOperation")) then
					continue
				end

				if descendant:GetAttribute("WeaponProperty") then
					continue
				end

				transparenciesByDescendant[descendant] = descendant.Transparency
				descendant.Transparency = transparency
			end
		end
	end

	local function fn13(p)
		if flag then
			return
		end

		flag = true

		if v3[child] then
			v3[child] = nil
		end

		if v3[character] then
			v3[character] = nil
		end

		for _, v9 in pairs(character.Humanoid:GetPlayingAnimationTracks()) do
			if v9.Animation.AnimationId == "rbxassetid://140492523431668" then
				v9:Stop()
			end
		end

		local v9 = true

		if p then
			local v10 = {
				Pride = 1.425,
				["Boss Raid"] = 2.8
			}
			local vfxName = player.vfxName

			if v10[vfxName] and p then
				local v11 = v10[vfxName]

				if v11 and v11 <= p then
					v9 = false
				end
			end
		end

		for _, sound in pairs(v5) do
			if typeof(sound) == "RBXScriptConnection" then
				sound:Disconnect()
			elseif typeof(sound) == "thread" then
				task.cancel(sound)
			elseif v9 and typeof(sound) == "Instance" then
				if sound:GetAttribute("DelayDeletion") then
					game.Debris:AddItem(sound, sound:GetAttribute("DelayDeletion"))
				elseif sound:IsA("Sound") then
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(sound, TweenInfo.new(0.865), {
						Volume = 0
					}):Play()
					game.Debris:AddItem(sound, 0.9)
				else
					sound:Destroy()
				end
			end
		end

		for _, v10 in pairs(threads) do
			task.cancel(v10)
		end

		local accessory = Instance.new("Accessory")
		accessory.Name = "StopEmoteVfx"
		accessory.Parent = player.Character
		game.Debris:AddItem(accessory, 1)
		local _ = player.Character

		if character:FindFirstChild("SpiderLegs") then
			local meshPart = character:FindFirstChild("SpiderLegs"):FindFirstChildOfClass("MeshPart")
			meshPart.Transparency = 1
		end

		for k, transparency in pairs(transparenciesByDescendant) do
			k.Transparency = transparency
		end
	end

	if v4.RealModule then
		if not player.NoInsertion then
			table.insert(v5, realBind)
		end

		for k, v9 in pairs(player) do
			if not sendingdata[k] then
				sendingdata[k] = v9
			end
		end

		spawn(function()
			warn("ye")
			v[tostring(v4.RealModule)].FirstEvent(sendingdata)
		end)
	end

	if not (v4.CanRotate or player.CanRotate) then
		local accessory = Instance.new("Accessory")
		accessory.Name = "NoRotate"
		accessory.Parent = character
		game.Debris:AddItem(accessory, 15)
		table.insert(v5, accessory)
	end

	if v4.StartupFunction then
		v4.StartupFunction(sendingdata)
	end

	if v4.TransparencyData then
		local transparencyData = v4.TransparencyData

		if transparencyData.FirstDelay then
			table.insert(threads, (task.delay(transparencyData.FirstDelay, function()
				fn12(player.Character, 1)
			end)))
		else
			fn12(player.Character, 1)
		end

		table.insert(threads, (task.delay(transparencyData.TransparencyTime, function()
			local _ = player.Character

			if character:FindFirstChild("SpiderLegs") then
				local meshPart = character:FindFirstChild("SpiderLegs"):FindFirstChildOfClass("MeshPart")
				meshPart.Transparency = 1
			end

			for k, transparency in pairs(transparenciesByDescendant) do
				k.Transparency = transparency
			end
		end)))
	end

	if v4.Tasks then
		for duration, task2 in pairs(v4.Tasks) do
			local thread = nil
			local v9 = task2
			thread = task.delay(duration, function()
				if flag then
					return
				end

				if table.find(v5, thread) then
					table.remove(v5, table.find(v5, thread))
				end

				v9(sendingdata)
			end)
			table.insert(v5, thread)
			table.insert(threads, thread)
		end
	end

	local character2 = game.Players.LocalPlayer.Character
	local cutsceneBind = player.CutsceneBind
	local v9 = character2 == character or character2 == victim or character2 == cutsceneBind
	local v10 = v4.CutsceneData and v4.CutsceneData.ForOthers and true or v9

	if v4.CutsceneData and v10 then
		local cutsceneData = v4.CutsceneData
		cutsceneData.Char = character
		cutsceneData.From = fn(character, cutsceneData.From)
		cutsceneData.AnimSent = v6
		cutsceneData.Bind = realBind
		cutsceneData.smooth = true
		local cutsceneCallback = fn3(cutsceneData, v5)
		table.insert(callback, cutsceneCallback)
		sendingdata.CutsceneCallback = cutsceneCallback
	end

	if v4.Startup then
		v4.Startup(sendingdata)
	end

	local lastTime = tick()

	if v4.ManualVfxMarkers then
		fn11({
			anim = v6,
			markers = v4.ManualVfxMarkers,
			DontDisconnectMarkers = v4.DontDisconnectMarkers,
			sendingdata = sendingdata,
			cleanup = v5
		})
	end

	local stoppedConnection = v6.Stopped:Once(function()
		fn13(tick() - lastTime)
	end)
	task.delay(0.1, function()
		if not v6.IsPlaying then
			fn13(tick() - lastTime)
		end
	end)
	task.delay(15, function()
		if stoppedConnection then
			stoppedConnection:Disconnect()
		end
	end)
end

return VFX