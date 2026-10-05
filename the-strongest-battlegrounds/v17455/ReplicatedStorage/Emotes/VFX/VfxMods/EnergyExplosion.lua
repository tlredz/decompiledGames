local createVector = vector.create
local EnergyExplosion = {}
local color = Color3.fromRGB(255, 255, 255)
local library = require(game.ReplicatedStorage.library)
local _ = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local vfx = script.vfx
local Lib2 = require(game.ReplicatedStorage.Emotes.VFX.Lib2)
local lib2 = Lib2()
local vfx2 = script.vfx
local thrown = workspace.Thrown
local v2 = {
	Impact = {
		"rbxassetid://106664976367925",
		"rbxassetid://71765592906181",
		"rbxassetid://79719344446876",
		"rbxassetid://132733088571132",
		"rbxassetid://83233321709784",
		"rbxassetid://95246585410151",
		"rbxassetid://123006165133873",
		"rbxassetid://83725194995031",
		"rbxassetid://129121873304280",
		"rbxassetid://79935755942879",
		"rbxassetid://132703928248301",
		"rbxassetid://83243683845845",
		"rbxassetid://74111006293552",
		"rbxassetid://133845818301089",
		"rbxassetid://126169370642070",
		"rbxassetid://97021752999443"
	},
	Impact2 = {
		"rbxassetid://110091265914150",
		"rbxassetid://108527533405790",
		"rbxassetid://108798245015964",
		"rbxassetid://100715160168486",
		"rbxassetid://129949690794057",
		"rbxassetid://128886793425843",
		"rbxassetid://116575182138419",
		"rbxassetid://84591074918060",
		"rbxassetid://91974247111020",
		"rbxassetid://110137620529602",
		"rbxassetid://117831600855380",
		"rbxassetid://120782578823321",
		"rbxassetid://80679207524741",
		"rbxassetid://132071006138456",
		"rbxassetid://97987422146342",
		"rbxassetid://122168517721852"
	},
	Impact3 = {
		"rbxassetid://74792321372714",
		"rbxassetid://111123263786009",
		"rbxassetid://92074297826411",
		"rbxassetid://90710595909415",
		"rbxassetid://108829763144304",
		"rbxassetid://76087157547102",
		"rbxassetid://129185846691161",
		"rbxassetid://97007021188589",
		"rbxassetid://128262822657347",
		"rbxassetid://96413022282088",
		"rbxassetid://127574221682297",
		"rbxassetid://127809218973812",
		"rbxassetid://139161045286719",
		"rbxassetid://125964490496383",
		"rbxassetid://123723458084124",
		"rbxassetid://87959838367640",
		"rbxassetid://122196298114674",
		"rbxassetid://102176595225829",
		"rbxassetid://133444657588539",
		"rbxassetid://70971382162750",
		"rbxassetid://92370290320944",
		"rbxassetid://92323997751766",
		"rbxassetid://84519809803015",
		"rbxassetid://98061333637769",
		"rbxassetid://18799643112"
	},
	Wave = {
		"rbxassetid://100370887002617",
		"rbxassetid://72492977178869",
		"rbxassetid://106404455011208",
		"rbxassetid://79203681926490",
		"rbxassetid://89162895650237",
		"rbxassetid://93791691215226",
		"rbxassetid://85376147474064",
		"rbxassetid://98489229968116",
		"rbxassetid://81445417122031",
		"rbxassetid://128263847970739",
		"rbxassetid://116958305778798",
		"rbxassetid://132429934078882",
		"rbxassetid://105647402811414",
		"rbxassetid://88156787163936",
		"rbxassetid://115788107741493",
		"rbxassetid://116159234159441"
	},
	Wave2 = {
		"rbxassetid://70852108226661",
		"rbxassetid://91377459914719",
		"rbxassetid://137402227089428",
		"rbxassetid://96157302223028",
		"rbxassetid://85300562445395",
		"rbxassetid://122388348117815",
		"rbxassetid://130373941580287",
		"rbxassetid://112733511254104",
		"rbxassetid://138968282617917",
		"rbxassetid://100348772649803",
		"rbxassetid://80096017417135",
		"rbxassetid://83606175318693"
	},
	Charge = {
		"rbxassetid://86340507223546",
		"rbxassetid://88437284509595",
		"rbxassetid://92941104464639",
		"rbxassetid://91709417463600",
		"rbxassetid://81674790143007",
		"rbxassetid://120537586425061",
		"rbxassetid://76045187432656",
		"rbxassetid://71300106842355",
		"rbxassetid://131813031508433",
		"rbxassetid://109981523392334",
		"rbxassetid://108124429116460",
		"rbxassetid://129535898411757",
		"rbxassetid://108276995334466",
		"rbxassetid://109438108226414",
		"rbxassetid://135481062034181",
		"rbxassetid://124266797425085"
	},
	Charge2 = {
		"rbxassetid://84659822092556",
		"rbxassetid://104117709872428",
		"rbxassetid://104117709872428",
		"rbxassetid://116255742564444"
	},
	Charge3 = {
		"rbxassetid://112245068205445",
		"rbxassetid://119198455210527",
		"rbxassetid://84904883784866",
		"rbxassetid://122177476722225",
		"rbxassetid://101041511436477",
		"rbxassetid://112119915556684",
		"rbxassetid://107632803336473",
		"rbxassetid://114597508674551"
	},
	Wave3 = {
		"rbxassetid://99834031866989",
		"rbxassetid://136650461169060",
		"rbxassetid://104648534551813",
		"rbxassetid://107254318604459",
		"rbxassetid://79361990935196",
		"rbxassetid://113161239582640",
		"rbxassetid://77996887818203",
		"rbxassetid://126858211297496",
		"rbxassetid://111425960467621",
		"rbxassetid://125348439766185",
		"rbxassetid://93778413726842",
		"rbxassetid://135378773639395",
		"rbxassetid://113546728720688",
		"rbxassetid://115093549515032",
		"rbxassetid://78719515698588",
		"rbxassetid://80138668842049"
	},
	Wind = {
		"rbxassetid://130547692576652",
		"rbxassetid://90229743412352",
		"rbxassetid://135186751400808",
		"rbxassetid://85382871614552",
		"rbxassetid://127283097110814",
		"rbxassetid://101410319717525",
		"rbxassetid://131180070196745",
		"rbxassetid://93898667791599",
		"rbxassetid://70947684104777",
		"rbxassetid://140704764645664",
		"rbxassetid://87427643612466",
		"rbxassetid://80629644320444",
		"rbxassetid://128951743755092",
		"rbxassetid://82036969307700",
		"rbxassetid://121430938534330",
		"rbxassetid://111149835722062",
		"rbxassetid://79533461920331",
		"rbxassetid://74879912619636",
		"rbxassetid://89542284500297",
		"rbxassetid://71628555866066",
		"rbxassetid://125947519278329",
		"rbxassetid://80169495687296",
		"rbxassetid://128142051306944",
		"rbxassetid://74368375877700",
		"rbxassetid://18799643112"
	},
	Burst = {
		"rbxassetid://108414265619536",
		"rbxassetid://136675240549192",
		"rbxassetid://126605259976576",
		"rbxassetid://107627927830276",
		"rbxassetid://103087089721257",
		"rbxassetid://74603835630541",
		"rbxassetid://115134854951999",
		"rbxassetid://109939029547363"
	}
}

local function fn(model, _, p)
	local function handle(instance)
		if instance:FindFirstChild("info") then
			Lib2("MovieeTweenMethod")(instance).play()

			if instance:GetAttribute("Destroy") or p then
				task.delay(instance.info:GetAttribute("time"), instance.Destroy, instance)
			end
		end

		local flipbook = instance:GetAttribute("Flipbook")

		if flipbook and instance:FindFirstChild("tweeninfo") and v2[flipbook] then
			local v3 = v2[flipbook]
			lib2.TweenMeshFlipbook(
				instance,
				v3,
				lib2.Utils:createinfo(instance:FindFirstChild("tweeninfo")) or TweenInfo.new(0.5),
				function()
					instance:Destroy()
				end
			)
		end
	end

	if model:IsA("Model") then
		for _, child in model:GetChildren() do
			handle(child)
		end
	else
		handle(model)
	end

	lib2.Utils:FixMesh(model)
end

local function fn2(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Beam") then
			if descendant:FindFirstChild("info") then
				Lib2("MovieeTweenMethod")(descendant).play()

				if descendant:GetAttribute("Destroy") then
					task.delay(descendant.info:GetAttribute("time"), descendant.Destroy, descendant)
				end

				continue
			else
				local flipbook = descendant:GetAttribute("Flipbook")

				if flipbook and descendant:FindFirstChild("tweeninfo") and v2[flipbook] then
					local v3 = v2[flipbook]
					lib2.TweenFlipbook(
						descendant,
						v3,
						lib2.Utils:createinfo(descendant:FindFirstChild("tweeninfo")) or TweenInfo.new(0.5)
					)
				end
			end
		end

		if not descendant:IsA("CFrameValue") then
			continue
		end

		local parent = descendant.Parent
		Lib2("Services").ts:Create(
			parent,
			lib2.Utils:createinfo(descendant:FindFirstChild("info")) or TweenInfo.new(0.5),
			{
				CFrame = parent:FindFirstChildOfClass("CFrameValue").Value
			}
		):Play()
	end
end

local currentCamera = workspace.CurrentCamera

local function fn3(folder, value)
	for _, descendant in folder:GetDescendants() do
		if descendant:GetAttribute("ks") then
			continue
		end

		if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
			descendant.Color = ColorSequence.new(Color3.new(color.R, color.G, color.B))
		end

		if descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight") then
			local v3 = value or 1.3
			descendant.Brightness *= v3
			descendant.Color = Color3.new(color.R * v3, color.G * v3, color.B * v3)
		end

		if not descendant:IsA("Decal") then
			continue
		end

		local v3 = value or 1.3
		descendant.Color3 = Color3.new(color.R * v3, color.G * v3, color.B * v3)
	end
end

local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

function EnergyExplosion.FirstEvent(data)
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local v3 = game.Players.LocalPlayer.Character == char
	local colour = data.Colour
	color = colour

	if not color then
		color = Color3.fromRGB(255, 255, 255)
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local cleanupTable = data.CleanupTable
	local _ = data.RealAnim
	local bind = data.Bind
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not flag then
			flag = true
			object._maid:doCleaning()
		end
	end

	local function thingable(folder, enabled, className)
		if not (folder and folder.Parent) then
			return
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA(className) then
				descendant.Enabled = enabled
			end
		end
	end

	local v4 = false
	task.delay(0.4, function()
		local v5

		if v4 or not (bind and bind.Parent) then
			v4 = true
			v5 = false
		else
			v5 = true
		end

		if not v5 then
			return
		end

		local clone = vfx.ImpactGlow:Clone()
		table.insert(cleanupTable, clone)
		clone.Parent = humanoidRootPart
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 3)

		for _ = 1, 3 do
			if flag then
				return
			end

			clone:Emit(1)
			task.wait(0.075)
		end

		task.wait(0.5)

		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	local parentChangedConnection = nil
	tick()
	local v5 = {}
	local descendants = {}

	local function fn4(folder)
		game.Debris:AddItem(folder, 5)
		table.insert(v5, folder)

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				table.insert(v5, descendant)
			end

			if not (descendant:IsA("Beam") or descendant:IsA("PointLight") or descendant:IsA("ParticleEmitter")) then
				continue
			end

			table.insert(descendants, descendant)
		end
	end

	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		thingable(char, false, "Beam")

		for _, descendant in pairs(char:GetDescendants()) do
			if not ((descendant:IsA("PointLight") or descendant:IsA("ParticleEmitter")) and descendant:GetAttribute("InnerRageAura")) then
				continue
			end

			descendant.Enabled = true
		end

		if v3 then
			task.delay(0.5, function()
				if workspace.CurrentCamera.CameraType == Enum.CameraType.Custom and workspace.CurrentCamera.FieldOfView ~= 70 then
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(workspace.CurrentCamera, TweenInfo.new(0.35), {
						FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
					}):Play()
				end
			end)
		end

		for _, instance in pairs(v5) do
			if instance:IsA("IntValue") then
				instance:Destroy("")
			elseif instance:IsA("MeshPart") or instance:IsA("BasePart") then
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(instance, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end
		end

		for _, v6 in pairs(descendants) do
			v6.Enabled = false
		end

		descendants = true
		workspace.Camera:SetAttribute("paused", false)
		Clean() -- equivalent call inferred; original call site unknown
		return parentChangedConnection:Disconnect()
	end)
	task.delay(15, function()
		if parentChangedConnection then
			return parentChangedConnection:Disconnect()
		end
	end)
	task.delay(10, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local _ = game.Players.LocalPlayer.Character == char
	task.delay(1.3, function()
		local v6

		if v4 or not (bind and bind.Parent) then
			v4 = true
			v6 = false
		else
			v6 = true
		end

		if not v6 then
			return
		end

		local v7 = {
			start = os.clock(),
			maxtime = 3.6
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function excesedtime()
			return os.clock() - v7.start >= v7.maxtime
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function excesedtime2()
			return os.clock() - v7.start >= v7.maxtime + 0.35
		end

		spawn(function()
			local function raycast(p, p2, filterType, filterDescendantsInstances)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = filterType
				raycastParams.FilterDescendantsInstances = filterDescendantsInstances
				raycastParams.RespectCanCollide = true
				local Workspace = game:GetService("Workspace")
				local raycastResult = Workspace:Raycast(p, p2, raycastParams)

				if raycastResult == nil then
					return "Nothing was hit"
				end

				return raycastResult
			end

			local clones = {}

			while true do
				task.wait(Random.new():NextNumber(0.08, 0.2))
				local magnitude = (char.PrimaryPart.Position - game.Players.LocalPlayer.Character.PrimaryPart.Position).Magnitude
				local _, v8 = workspace.CurrentCamera:WorldToScreenPoint(char.PrimaryPart.Position)
				local v9 = v8 and not (magnitude >= 130) and true or false

				if char == game.Players.LocalPlayer.Character or v9 then
					local v10 = CFrame.new(
						char.PrimaryPart.Position.X,
						char.PrimaryPart.Position.Y,
						char.PrimaryPart.Position.Z
					) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
					local v11 = math.random(15, 30)
					local position = (v10 * CFrame.new(0, 0, (math.random(-v11, v11)))).Position
					local exclude = Enum.RaycastFilterType.Exclude
					local filterDescendantsInstances = { workspace.Live, workspace.Thrown }
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = exclude
					raycastParams.FilterDescendantsInstances = filterDescendantsInstances
					raycastParams.RespectCanCollide = true
					local Workspace = game:GetService("Workspace")
					local raycastResult = Workspace:Raycast(position, createVector(0, -15, 0), raycastParams)
					local v13 = raycastResult == nil and "Nothing was hit" or raycastResult

					if v13 ~= "Nothing was hit" then
						local v14 = math.random(20, 100) / math.random(50, 80)
						local clone = script.Debris:Clone()
						game.Debris:AddItem(clone, 9)
						clone.CanCollide = false
						clone.Material = v13.Instance.Material
						clone.Color = v13.Instance.Color
						clone.Position = v13.Position
						clone.Orientation = Vector3.new(
							math.random(-180, 180),
							math.random(-180, 180),
							math.random(-180, 180)
						)

						if math.random(1, 3) == 4 and char == game.Players.LocalPlayer.Character then
							local highlight = Instance.new("Highlight")
							highlight.Parent = clone
							highlight.OutlineTransparency = 0
							highlight.FillTransparency = 1
							highlight.OutlineColor = colour
							local TweenService2 = game:GetService("TweenService")
							TweenService2:Create(highlight, TweenInfo.new(2), {
								OutlineTransparency = 1
							}):Play()
							game.Debris:AddItem(highlight, 2)
						end

						clone.Size = Vector3.new(
							v14 * (math.random(80, 120) / 100),
							v14 * (math.random(80, 120) / 100),
							v14 * (math.random(80, 120) / 100)
						)
						table.insert(clones, clone)
						clone.Parent = workspace.Thrown
						local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
						bodyAngularVelocity.MaxTorque = createVector(25000, 25000, 25000)
						bodyAngularVelocity.AngularVelocity = Vector3.new(
							math.random(-50, 50) / 10,
							math.random(-50, 50) / 10,
							math.random(-50, 50) / 10
						)
						local v15 = math.random(15, 70) / math.random(3, 10)
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(250000, 250000, 250000)
						bodyVelocity.Velocity = Vector3.new(0, v15, 0)
						bodyVelocity.Parent = clone
						bodyAngularVelocity.Parent = clone
					end

					for k, v14 in pairs(clones) do
						local magnitude2 = (char.PrimaryPart.Position - v14.Position).Magnitude

						if not (v11 * 1.25 < magnitude2) then
							continue
						end

						table.remove(clones, k)
						game.Debris:AddItem(v14, 1.5)
						TweenService:Create(
							v14,
							TweenInfo.new(Random.new():NextNumber(0.6, 1), Enum.EasingStyle.Sine),
							{
								Transparency = 1
							}
						):Play()
					end
				end

				if not excesedtime2() then
					local flag2

					if v4 or not (bind and bind.Parent) then
						v4 = true
						flag2 = false
					else
						flag2 = true
					end

					if flag2 then
						continue
					end
				end

				for _, v10 in pairs(clones) do
					v10.CanCollide = true
					game.Debris:AddItem(v10, 4)

					for _, child in pairs(v10:GetChildren()) do
						if child:IsA("BodyVelocity") or child:IsA("BodyAngularVelocity") then
							child:Destroy()
						end
					end

					local touchedConnection = nil
					local v11 = v10
					touchedConnection = v10.Touched:Connect(function(otherPart)
						if otherPart:FindFirstAncestor("Map") then
							touchedConnection:Disconnect()
							local children = v11:FindFirstChild("collisionSound"):GetChildren()
							local v12 = children[math.random(1, #children)]

							if math.random(1, 5) == 2 then
								v12.PlaybackSpeed = math.random(80, 120) / 100
								v12:Play()
							end

							coroutine.wrap(function()
								wait(math.random(10, 35) / 10)
								v11.Anchored = true
								v11.CanCollide = false
								game.Debris:AddItem(v11, 2.5)
								TweenService:Create(v11, TweenInfo.new(2, Enum.EasingStyle.Sine), {
									Transparency = 1,
									Position = v11.Position + createVector(0, -2, 0),
									Orientation = v11.Orientation + Vector3.new(
										math.random(-90, 90),
										math.random(-90, 90),
										math.random(-90, 90)
									)
								}):Play()
							end)()
						end
					end)
					task.delay(5, function()
						if touchedConnection then
							touchedConnection:Disconnect()
						end
					end)
				end

				break
			end
		end)
		spawn(function()
			if not v3 then
				return
			end

			shared.repfire({
				Effect = "Camshake",
				Intensity = 6,
				Last = 0.6
			})
			task.delay(0.6, function()
				local v8

				if v4 or not (bind and bind.Parent) then
					v4 = true
					v8 = false
				else
					v8 = true
				end

				if not v8 then
					return
				end

				for _ = 1, 9000000000 do
					local v9

					if v4 or not (bind and bind.Parent) then
						v4 = true
						v9 = false
					else
						v9 = true
					end

					if not v9 or excesedtime2() then
						break
					end

					shared.repfire({
						Effect = "Camshake",
						Intensity = 0.85,
						Last = 0.1
					})
					task.wait(0.1)
				end
			end)
			task.spawn(function()
				for _ = 1, 9000000000 do
					local v8

					if v4 or not (bind and bind.Parent) then
						v4 = true
						v8 = false
					else
						v8 = true
					end

					if not v8 or excesedtime() then
						break
					end

					local alignGroup, _ = lib2.AlignGroup(
						vfx2.Charging_MESH:Clone(),
						char.PrimaryPart.CFrame * CFrame.Angles(0, math.random(0, 360) * 0.01, 0)
					)
					fn4(alignGroup)
					alignGroup.Parent = thrown
					fn3(alignGroup, 4)
					task.spawn(function()
						for i = 1, 15 do
							local v10

							if v4 or not (bind and bind.Parent) then
								v4 = true
								v10 = false
							else
								v10 = true
							end

							if not v10 then
								break
							end

							local spin = alignGroup.Mesh:FindFirstChild("Spin")

							if not spin then
								break
							end

							fn4(spin)
							local v11 = lib2.Services.ts:Create(spin, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
								CFrame = spin.CFrame * CFrame.Angles(0, -1.3439035240356338, 0)
							})
							v11:Play()
							v11.Completed:Wait()
						end
					end)
					fn(alignGroup.Mesh, true, false)
					local _ = math.random(1, 6) * 0.1
					lib2.PlayAttachment(alignGroup, 5)
					local v10

					if v4 or not (bind and bind.Parent) then
						v4 = true
						v10 = false
					else
						v10 = true
					end

					if not v10 then
						break
					end

					task.wait(0.35)
				end
			end)
			task.spawn(function()
				for _ = 1, 9000000000 do
					local v8

					if v4 or not (bind and bind.Parent) then
						v4 = true
						v8 = false
					else
						v8 = true
					end

					if not v8 or excesedtime() then
						break
					end

					local alignGroup, _ = lib2.AlignGroup(
						vfx2.Charging_MESH_Wind:Clone(),
						char.PrimaryPart.CFrame * CFrame.Angles(0, math.random(0, 360) * 0.01, 0)
					)
					fn4(alignGroup)
					alignGroup.Parent = thrown
					lib2.Utils:scaleModel(alignGroup, 0.7)
					fn(alignGroup.Mesh, true, false)
					task.wait(0.15)
				end
			end)
		end)
		local v8

		if v4 or not (bind and bind.Parent) then
			v4 = true
			v8 = false
		else
			v8 = true
		end

		if not v8 then
			return
		end

		local alignGroup, _ = lib2.AlignGroup(vfx2.Charging:Clone(), char.PrimaryPart.CFrame)
		fn4(alignGroup)
		alignGroup.Parent = thrown

		if v3 then
			lib2.ImpactFrames({
				Folder = vfx2.Screen.Color,
				DisableTween = false,
				Number = 0.75,
				Blur = 0.5
			})
		end

		fn3(alignGroup)
		fn2(alignGroup.Beams)
		task.delay(v7.maxtime, function()
			local v9

			if v4 or not (bind and bind.Parent) then
				v4 = true
				v9 = false
			else
				v9 = true
			end

			if not v9 then
				return
			end

			for _, beam in alignGroup.Beams:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				local v10 = beam
				task.spawn(function()
					task.wait(0.25)
					lib2.TweenNumberSequence(
						v10.Transparency,
						NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) }),
						50,
						0.5,
						v10,
						"Transparency",
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.In
					)
				end)
			end

			lib2.ToggleFX(alignGroup, false)
		end)
	end)
	task.delay(1.3, function()
		local v6

		if v4 or not (bind and bind.Parent) then
			v4 = true
			v6 = false
		else
			v6 = true
		end

		if not v6 then
			return
		end

		local function fn5()
			local v7

			if v4 or not (bind and bind.Parent) then
				v4 = true
				v7 = false
			else
				v7 = true
			end

			if not v7 then
				return
			end

			local alignGroup, _ = lib2.AlignGroup(vfx2.Start:Clone(), char.PrimaryPart.CFrame)
			alignGroup.Parent = thrown
			fn4(alignGroup)
			fn3(alignGroup, 4.7)
			lib2.PlayAttachment(alignGroup, 5)
			fn(alignGroup.Mesh, true, false)
			fn2(alignGroup.Beams)
			task.spawn(function()
				for _, beam in alignGroup.Beams:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					local v8 = beam
					task.spawn(function()
						task.wait(0.25)
						lib2.TweenNumberSequence(
							v8.Transparency,
							NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) }),
							50,
							0.85,
							v8,
							"Transparency",
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.In
						)
					end)
				end

				for _ = 1, 15 do
					local v8

					if v4 or not (bind and bind.Parent) then
						v4 = true
						v8 = false
					else
						v8 = true
					end

					if not (v8 and alignGroup.Parent) then
						break
					end

					local attachment = alignGroup.Beams.Root.Attachment
					local attachment2 = alignGroup.Beams.Root.Attachment2

					if alignGroup.Mesh:FindFirstChild("End") then
						lib2.Services.ts:Create(alignGroup.Mesh.End, TweenInfo.new(0.85, Enum.EasingStyle.Linear), {
							CFrame = alignGroup.Mesh.End.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
						}):Play()
						lib2.Services.ts:Create(alignGroup.Mesh.End2, TweenInfo.new(0.95, Enum.EasingStyle.Linear), {
							CFrame = alignGroup.Mesh.End2.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
						}):Play()
					end

					lib2.Services.ts:Create(attachment2, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {
						CFrame = attachment2.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
					}):Play()
					local v9 = lib2.Services.ts:Create(attachment, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
						CFrame = attachment.CFrame * CFrame.Angles(0, 1.3089969389957472, 0)
					})
					v9:Play()
					v9.Completed:Wait()
				end
			end)
		end

		task.delay(4, function()
			local v7

			if v4 or not (bind and bind.Parent) then
				v4 = true
				v7 = false
			else
				v7 = true
			end

			if not v7 then
				return
			end

			if v3 then
				shared.repfire({
					Effect = "Camshake",
					Intensity = 4
				})
				currentCamera:FindFirstChild("FeildOfView"):Destroy()
				lib2.ImpactFrames({
					Folder = vfx2.Screen.Impact,
					DisableTween = true,
					Number = 0.015,
					Blur = 0.06
				})
			end

			fn5()
		end)
		task.spawn(function()
			if not v3 then
				return
			end

			local intValue = Instance.new("IntValue", currentCamera)
			intValue.Name = "FeildOfView"
			table.insert(v5, intValue)
			lib2.Services.ts:Create(
				currentCamera,
				TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					FieldOfView = 75
				}
			):Play()
			intValue.Destroying:Wait()
			lib2.Services.ts:Create(
				currentCamera,
				TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					FieldOfView = 85
				}
			):Play()
			local v7

			if v4 or not (bind and bind.Parent) then
				v4 = true
				v7 = false
			else
				v7 = true
			end

			if not v7 then
				return
			end

			task.wait(0.45)
			local v8

			if v4 or not (bind and bind.Parent) then
				v4 = true
				v8 = false
			else
				v8 = true
			end

			if not v8 then
				return
			end

			lib2.Services.ts:Create(currentCamera, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
				FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
			}):Play()
		end)
		fn5()
	end)
end

return EnergyExplosion