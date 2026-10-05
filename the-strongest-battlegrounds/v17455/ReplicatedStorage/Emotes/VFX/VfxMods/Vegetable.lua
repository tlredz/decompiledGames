local createVector = vector.create
local Vegetable = {}
local FrameEvents = require(script:WaitForChild("FrameEvents"))
local PreloadData = require(script:WaitForChild("PreloadData"))
local Vfxmodule = require(script:WaitForChild("Vfxmodule"))
require(game.ReplicatedStorage.Resources.EmitModule)
local ids2 = {
	"rbxassetid://109864734911977",
	"rbxassetid://124727084384458",
	"rbxassetid://89816406381822",
	"rbxassetid://74395996158931",
	"rbxassetid://115702968828899",
	"rbxassetid://127146903568307",
	"rbxassetid://119919524242824",
	"rbxassetid://73690770726283",
	"rbxassetid://78974993585214",
	"rbxassetid://126938410083101",
	"rbxassetid://110566680648524",
	"rbxassetid://125244650114181",
	"rbxassetid://80184096084026",
	"rbxassetid://110482133640628",
	"rbxassetid://135298667765528",
	"rbxassetid://121200758580460",
	"rbxassetid://97905557359930",
	"rbxassetid://128956078489253",
	"rbxassetid://117290263381911",
	"rbxassetid://130247408401328",
	"rbxassetid://133546280141794",
	"rbxassetid://94663664993051",
	"rbxassetid://83848809972667",
	"rbxassetid://105094006404030",
	"rbxassetid://88282692477101",
	"rbxassetid://74796221604925",
	"rbxassetid://83993539991638",
	"rbxassetid://139775866167445",
	"rbxassetid://99111943881456",
	"rbxassetid://120773267927323",
	"rbxassetid://84184357093707",
	"rbxassetid://74925112216778",
	"rbxassetid://76636153984904",
	"rbxassetid://131820344423838",
	"rbxassetid://135961035340134",
	"rbxassetid://71480139578911",
	"rbxassetid://112916078391254",
	"rbxassetid://128779309229180",
	"rbxassetid://121123277261456",
	"rbxassetid://96659090387017",
	"rbxassetid://96799653787301",
	"rbxassetid://87246942777140",
	"rbxassetid://137735532081175",
	"rbxassetid://115452438476656",
	"rbxassetid://95093812873647",
	"rbxassetid://118601976248145",
	"rbxassetid://71085568705005",
	"rbxassetid://136647790294058",
	"rbxassetid://119637689320918",
	"rbxassetid://137674478896606",
	"rbxassetid://82026318328941",
	"rbxassetid://94695694283974",
	"rbxassetid://86746377593441",
	"rbxassetid://70402594215399",
	"rbxassetid://107860650193011",
	"rbxassetid://76277324646757",
	"rbxassetid://96683995042790",
	"rbxassetid://78264906361451",
	"rbxassetid://82879156315310",
	"rbxassetid://130560628725204",
	"rbxassetid://103575104844608",
	"rbxassetid://90746327536985",
	"rbxassetid://121656538288308",
	"rbxassetid://83033212760754"
}
local ids3 = {
	"rbxassetid://136976081943686",
	"rbxassetid://79750611285099",
	"rbxassetid://94007844178765",
	"rbxassetid://82818775308252",
	"rbxassetid://113328188333004",
	"rbxassetid://102632723592422",
	"rbxassetid://121592073667163",
	"rbxassetid://102059349765447",
	"rbxassetid://89604972819422",
	"rbxassetid://110073167072996",
	"rbxassetid://118501133525500",
	"rbxassetid://108646782835627",
	"rbxassetid://127773363097561",
	"rbxassetid://76215132941403",
	"rbxassetid://72380474894107",
	"rbxassetid://105611645096990",
	"rbxassetid://128283441075409",
	"rbxassetid://72155868658581",
	"rbxassetid://93370482039398",
	"rbxassetid://86122904141101",
	"rbxassetid://106480433983068",
	"rbxassetid://111625460373734",
	"rbxassetid://131428438573438",
	"rbxassetid://93696813018838",
	"rbxassetid://98190234959738",
	"rbxassetid://111162522097140",
	"rbxassetid://72940021357242",
	"rbxassetid://83935778339215",
	"rbxassetid://116331589905536",
	"rbxassetid://71988553650126",
	"rbxassetid://126027177634617",
	"rbxassetid://133398215094561",
	"rbxassetid://110583613778466",
	"rbxassetid://101142119538794",
	"rbxassetid://114372833851336",
	"rbxassetid://99584924141546",
	"rbxassetid://98560637345223",
	"rbxassetid://104896899784429",
	"rbxassetid://70562873191209",
	"rbxassetid://78467256303805",
	"rbxassetid://74719095910261",
	"rbxassetid://130808770971995",
	"rbxassetid://119427936764620",
	"rbxassetid://122703211768877",
	"rbxassetid://127590737119330",
	"rbxassetid://119930135574772",
	"rbxassetid://73345049597133",
	"rbxassetid://107842084973512",
	"rbxassetid://101340346081957",
	"rbxassetid://139277056466942",
	"rbxassetid://82144467650864",
	"rbxassetid://71653869869027",
	"rbxassetid://79294524716821",
	"rbxassetid://85086868344688",
	"rbxassetid://90196266831837",
	"rbxassetid://128106546385734",
	"rbxassetid://104460516028973",
	"rbxassetid://101850555405765",
	"rbxassetid://86279769339930",
	"rbxassetid://75672300742157",
	"rbxassetid://72131060141548",
	"rbxassetid://105983241063125",
	"rbxassetid://132075887004080",
	"rbxassetid://89890277378896"
}
local ids4 = {
	"rbxassetid://137845122945295",
	"rbxassetid://96827562782119",
	"rbxassetid://110273357275148",
	"rbxassetid://117952210620055",
	"rbxassetid://133850809434525",
	"rbxassetid://100453312408700",
	"rbxassetid://139924139994253",
	"rbxassetid://109703529128596",
	"rbxassetid://85973813750614",
	"rbxassetid://121397508670901",
	"rbxassetid://135408882875459",
	"rbxassetid://83319944835657",
	"rbxassetid://112830884197840",
	"rbxassetid://122188365536732",
	"rbxassetid://124771277655038",
	"rbxassetid://111151859201461",
	"rbxassetid://102236759932200",
	"rbxassetid://77691707331867",
	"rbxassetid://81359459231116",
	"rbxassetid://114827856703921",
	"rbxassetid://126084717603304",
	"rbxassetid://123746967118576",
	"rbxassetid://90892767454009",
	"rbxassetid://73669078829927",
	"rbxassetid://133791745031378",
	"rbxassetid://92193421236279",
	"rbxassetid://97791125612968",
	"rbxassetid://89980220988727",
	"rbxassetid://85661042686116",
	"rbxassetid://82686748401047",
	"rbxassetid://98236408579057",
	"rbxassetid://127957671090758",
	"rbxassetid://137608199099935",
	"rbxassetid://115577834873712",
	"rbxassetid://81083992996682",
	"rbxassetid://103573389445868",
	"rbxassetid://129545907748715",
	"rbxassetid://125739963260726",
	"rbxassetid://86316807088303",
	"rbxassetid://116142475949735",
	"rbxassetid://138058356902750",
	"rbxassetid://95015301309035",
	"rbxassetid://108136106965912",
	"rbxassetid://88116208059050",
	"rbxassetid://106836482150936",
	"rbxassetid://139381365742542",
	"rbxassetid://115353486155504",
	"rbxassetid://115666342917452",
	"rbxassetid://71441344004402",
	"rbxassetid://111136000691156",
	"rbxassetid://117205121552087",
	"rbxassetid://110027743359769",
	"rbxassetid://131051054072510",
	"rbxassetid://87781047801530",
	"rbxassetid://107069331898888",
	"rbxassetid://72049761543518",
	"rbxassetid://128442812958355",
	"rbxassetid://134960662028068",
	"rbxassetid://91745861280969",
	"rbxassetid://136185406239198",
	"rbxassetid://119149628705700",
	"rbxassetid://124740405230928",
	"rbxassetid://130871756727799",
	"rbxassetid://77369050579986"
}
local v4 = {
	{
		part = "lmloop",
		child = "Decal",
		ids = ids3,
		duration = 1
	},
	{
		part = "backgroundloop",
		child = "Overlay",
		ids = ids4,
		duration = 1
	},
	{
		part = "Explosionloop",
		child = "Overlay",
		ids = ids2,
		duration = 1
	},
	{
		part = "Explosionloop1",
		child = "Overlay",
		ids = ids2,
		duration = 1
	}
}
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function preload_flipbook_textures()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local ContentProvider = game:GetService("ContentProvider")
		local v5 = {}

		local function addList(list)
			for _, texture in ipairs(list) do
				local decal = Instance.new("Decal")
				decal.Texture = texture
				table.insert(v5, decal)
			end
		end

		addList(ids2)
		addList(ids3)
		addList(ids4)
		pcall(ContentProvider.PreloadAsync, ContentProvider, v5)

		for _, v6 in ipairs(v5) do
			v6:Destroy()
		end
	end)
end

local v5 = {
	Back = Enum.EasingStyle.Back,
	Bounce = Enum.EasingStyle.Bounce,
	Circular = Enum.EasingStyle.Circular,
	Circ = Enum.EasingStyle.Circular,
	Cubic = Enum.EasingStyle.Cubic,
	Elastic = Enum.EasingStyle.Elastic,
	Exponential = Enum.EasingStyle.Exponential,
	Expo = Enum.EasingStyle.Exponential,
	Quad = Enum.EasingStyle.Quad,
	Quart = Enum.EasingStyle.Quart,
	Quint = Enum.EasingStyle.Quint,
	Sine = Enum.EasingStyle.Sine
}
local v6 = {
	In = Enum.EasingDirection.In,
	Out = Enum.EasingDirection.Out,
	InOut = Enum.EasingDirection.InOut
}

local function cframeFromComponents(value)
	if typeof(value) == "CFrame" then
		return value
	end

	if type(value) ~= "table" then
		return CFrame.new()
	end

	if #value >= 12 then
		return CFrame.new(table.unpack(value, 1, 12))
	end

	if #value >= 3 then
		return CFrame.new(value[1] or 0, value[2] or 0, value[3] or 0)
	end

	return CFrame.new()
end

local function asNameList(value, value2)
	if type(value) == "table" then
		return value
	end

	if type(value) == "string" then
		return { value }
	end

	if type(value2) == "table" then
		return value2
	end

	if type(value2) == "string" then
		return { value2 }
	end

	return {}
end

local function getPath(child, list)
	if not child then
		return nil
	end

	if type(list) ~= "table" then
		return child
	end

	for _, childName in ipairs(list) do
		if type(childName) ~= "string" or not child then
			return nil
		end

		child = child:FindFirstChild(childName)
	end

	return child
end

local function getChild(child, ...)
	for _, childName in ipairs({ ... }) do
		if not child then
			return nil
		end

		child = child:FindFirstChild(childName)
	end

	return child
end

local function applyEasing(p, data)
	if type(data) ~= "table" then
		return p
	end

	local type2 = data.Type or data.type or data.Style or data.style or "Linear"
	local direction = data.Direction or data.direction or "Out"

	if type2 == "Constant" then
		if p >= 1 then
			return 1
		end

		return 0
	else
		if type2 == "Linear" then
			return p
		elseif type2 == "Smoother" then
			return p * p * p * (p * (p * 6 - 15) + 10)
		end

		local v7 = v5[type2]
		local v8 = v6[direction]

		if v7 and v8 then
			local TweenService = game:GetService("TweenService")
			return TweenService:GetValue(p, v7, v8)
		else
			return p
		end
	end
end

local function interpolateValue(values, p, value_type, eases)
	if type(values) ~= "table" or not next(values) then
		return nil
	end

	local v7 = nil
	local v8 = nil
	local v9 = nil
	local v10 = nil

	for k, item in pairs(values) do
		local v11 = tonumber(k)

		if not v11 then
			continue
		end

		if v11 <= p and (not v7 or v7 < v11) then
			v9 = item
			v7 = v11
		end

		if not (p <= v11 and (not v8 or v11 < v8)) then
			continue
		end

		v10 = item
		v8 = v11
	end

	if v7 == v8 or not (v7 and v8) then
		return v9 or v10
	end

	local v12 = applyEasing((p - v7) / (v8 - v7), eases and eases[v7])

	if value_type == "Color3" then
		return v9:lerp(v10, v12)
	elseif value_type == "Vector3" then
		return v9:Lerp(v10, v12)
	elseif value_type == "CFrame" then
		return v9:Lerp(v10, v12)
	elseif value_type == "number" then
		return v9 + (v10 - v9) * v12
	end

	if value_type == "boolean" then
	end

	if v12 >= 1 then
		return v10 or v9
	end

	return v9
end

function Vegetable.FirstEvent(data)
	local char = data.Char
	local targChar = data.targChar or data.Victim
	local cleanupTable = data.CleanupTable or data.cleanup
	local realAnim = data.RealAnim
	local bind = data.Bind
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local Workspace = game:GetService("Workspace")
	local Lighting = game:GetService("Lighting")
	local TweenService = game:GetService("TweenService")
	local ContentProvider = game:GetService("ContentProvider")
	local localPlayer = Players.LocalPlayer
	local currentCamera = Workspace.CurrentCamera

	if not (localPlayer and localPlayer:GetAttribute("S_FOV")) then
		local _ = currentCamera and currentCamera.FieldOfView
	end

	local _ = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ColorShift_Top = Lighting.ColorShift_Top,
		ColorShift_Bottom = Lighting.ColorShift_Bottom,
		ClockTime = Lighting.ClockTime,
		ExposureCompensation = Lighting.ExposureCompensation,
		EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
		EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
	}
	local isme = localPlayer and (char == localPlayer.Character or targChar == localPlayer.Character)
	local v8 = false

	if isme then
		local part = Instance.new("Part")
		table.insert(cleanupTable, part)
		part.Size = createVector(50, 50, 50)
		part.Anchored = true
		part.CanQuery = false
		part.CanTouch = false
		part.CanCollide = false
		part.CFrame = char.PrimaryPart.CFrame
		part.Parent = workspace.Thrown
		part.Transparency = 1
		part.CastShadow = false
		game.Debris:AddItem(part, 5)
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = { workspace.Live }
		local partsInPart = workspace:GetPartsInPart(part, overlapParams)

		local function fn(localTransparencyModifier)
			if localTransparencyModifier == 0 and not v8 then
				v8 = true

				for _, part2 in pairs(partsInPart) do
					if part2:IsA("BasePart") then
						part2.LocalTransparencyModifier = 0
					end
				end
			else
				for _, part2 in pairs(partsInPart) do
					if part2:IsA("BasePart") then
						part2.LocalTransparencyModifier = localTransparencyModifier
					end
				end
			end
		end

		local v9 = {
			connections = {},
			objects = {},
			tweens = {},
			particles = {},
			beams = {},
			trails = {},
			lights = {},
			tasks = {},
			controllers = {},
			restores = {}
		}
		local run_context = {
			running = true
		}
		local parentChangedConnection = nil
		local flag2 = false
		local flag3 = false
		local flag4 = false
		local v11 = -1
		local v12 = false
		local v13 = nil
		local v14 = false
		local v15 = nil
		local v16 = false
		local v17 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function vegPath(instance)
			return instance and instance:GetFullName() or "nil"
		end

		local function vegLog(...) end

		vegLog(
			"FirstEvent",
			"char",
			not char and "nil" or char:GetFullName() or "nil",
			"victim",
			not targChar and "nil" or targChar:GetFullName() or "nil",
			"isme",
			tostring(isme),
			"realanim",
			tostring(realAnim),
			"bind",
			not bind and "nil" or bind:GetFullName() or "nil"
		)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancontinue()
			return not flag2 and realAnim and realAnim.IsPlaying and bind and bind.Parent
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mark(instance)
			if instance then
				pcall(function()
					instance:SetAttribute("EmoteEffect", true)
				end)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function markTree(folder)
			if folder then
				mark(true) -- equivalent call inferred; original call site unknown
			end

			for _, descendant in pairs(folder:GetDescendants()) do
				if not descendant then
					continue
				end

				mark(true) -- equivalent call inferred; original call site unknown
			end
		end

		local function addTask(p)
			if p then
				table.insert(v9.tasks, p)

				if cleanupTable then
					table.insert(cleanupTable, p)
				end
			end

			return p
		end

		local function stopControllers()
			for _, controller in pairs(v9.controllers) do
				if not (controller and controller.Stop) then
					continue
				end

				local v18 = controller
				pcall(function()
					v18:Stop()
				end)
			end

			table.clear(v9.controllers)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyLater(instance)
			local thread = nil
			thread = task.delay(15, function()
				stopControllers()

				if instance then
					pcall(function()
						instance:Destroy()
					end)
				end

				local index = table.find(v9.tasks, thread)

				if index then
					table.remove(v9.tasks, index)
				end
			end)
			local v18 = thread

			if v18 then
				table.insert(v9.tasks, v18)

				if cleanupTable then
					table.insert(cleanupTable, v18)
				end
			end
		end

		local function trackParticleEffect(instance)
			if instance:IsA("ParticleEmitter") then
				table.insert(v9.particles, instance)
			elseif instance:IsA("Beam") then
				table.insert(v9.beams, instance)
			elseif instance:IsA("Trail") then
				table.insert(v9.trails, instance)
			elseif instance:IsA("PointLight") then
				table.insert(v9.lights, instance)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function trackTreeEffects(folder)
			trackParticleEffect(folder)

			for _, descendant in pairs(folder:GetDescendants()) do
				trackParticleEffect(descendant)
			end
		end

		local function trackInstance(p, p2, p3)
			if not p then
				return p
			end

			markTree(p) -- equivalent call inferred; original call site unknown
			table.insert(v9.objects, p)

			if cleanupTable and not p3 then
				table.insert(cleanupTable, p)
			end

			if not p2 then
				destroyLater(p) -- equivalent call inferred; original call site unknown
			end

			return p
		end

		local function trackExternal(p)
			if not p then
				return p
			end

			markTree(p) -- equivalent call inferred; original call site unknown
			table.insert(v9.objects, p)

			if cleanupTable then
				table.insert(cleanupTable, p)
			end

			destroyLater(p) -- equivalent call inferred; original call site unknown
			return p
		end

		local function rememberProperty(instance, property)
			if not instance or (instance == currentCamera or instance == Lighting or instance:IsDescendantOf(Lighting)) then
				return
			end

			for _, restore in ipairs(v9.restores) do
				if restore.object == instance and restore.property == property then
					return
				end
			end

			local success, result = pcall(function()
				return instance[property]
			end)

			if success then
				table.insert(v9.restores, {
					object = instance,
					property = property,
					value = result
				})
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function canTweenValue(p)
			local typeName = typeof(p)
			return typeName == "number" or typeName == "Color3" or typeName == "Vector3" or typeName == "CFrame" or typeName == "UDim" or typeName == "UDim2" or typeName == "Rect"
		end

		local function isExternalRestoreObject(instance)
			if isme and instance and instance.Parent then
				if instance:GetAttribute("EmoteEffect") then
					return false
				end

				return instance == currentCamera or instance == Lighting or (instance:IsDescendantOf(Lighting) or instance:IsDescendantOf(Workspace))
			else
				return false
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setPropertyNow(p, p2, p3)
			if p and p.Parent then
				pcall(function()
					p[p2] = p3
				end)
			end
		end

		local function tweenPropertyBack(object, property, value, list)
			if isExternalRestoreObject(object) and canTweenValue(value) then
				local v18 = nil

				if pcall(function()
					v18 = TweenService:Create(
						object,
						TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							[property] = value
						}
					)
				end) and v18 then
					table.insert(v9.tweens, v18)
					table.insert(list, {
						object = object,
						property = property,
						value = value
					})
					v18:Play()
				else
					setPropertyNow(object, property, value) -- equivalent call inferred; original call site unknown
				end

				return
			end

			setPropertyNow(object, property, value) -- equivalent call inferred; original call site unknown
		end

		local function restoreProperties(p)
			local v18 = {}

			for _, restore in ipairs(v9.restores) do
				if p then
					tweenPropertyBack(restore.object, restore.property, restore.value, v18)
				else
					setPropertyNow(restore.object, restore.property, restore.value) -- equivalent call inferred; original call site unknown
				end
			end

			table.clear(v9.restores)

			if #v18 > 0 then
				task.delay(0.6000000000000001, function()
					for _, v19 in ipairs(v18) do
						setPropertyNow(v19.object, v19.property, v19.value) -- equivalent call inferred; original call site unknown
					end
				end)
			end
		end

		local function setModelTransparency(folder, colorSequence)
			if not folder then
				return
			end

			if folder:IsA("BasePart") or folder:IsA("Decal") or folder:IsA("Texture") then
				rememberProperty(folder, "Transparency")
				folder.Transparency = colorSequence
			end

			for _, descendant in ipairs(folder:GetDescendants()) do
				if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
					continue
				end

				rememberProperty(descendant, "Transparency")
				descendant.Transparency = colorSequence
			end
		end

		local function setModelVisible(folder, p)
			if not folder then
				return
			end

			for _, descendant in pairs(folder:GetDescendants()) do
				if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
					continue
				end

				if p then
					local vegetableOriginalTransparency = descendant:GetAttribute("VegetableOriginalTransparency")
					descendant.Transparency = typeof(vegetableOriginalTransparency) == "number" and vegetableOriginalTransparency or 0
				else
					if descendant:GetAttribute("VegetableOriginalTransparency") == nil then
						descendant:SetAttribute("VegetableOriginalTransparency", descendant.Transparency)
					end

					descendant.Transparency = 1
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolvePropertyRoot(data2, root)
			if root == "camera" then
				return currentCamera
			elseif root == "lighting" then
				return Lighting
			elseif root == "vfx" then
				return data2.vfx
			elseif root == "character" then
				return char
			end

			if root == "victim" or root == "Victim" then
				return targChar
			end

			if root == "camera_rig" or root == "cameraRig" then
				return data2.camera_rig or data2.cameraRig
			end

			if root == "workspace" then
				return Workspace
			end

			return data2[root]
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolvePropertyTarget(data2, target)
			if typeof(target) == "Instance" then
				return target
			end

			if type(target) ~= "table" then
				return nil
			end

			local root = target.root or target.Root

			if type(root) ~= "string" then
				return nil
			end

			local propertyRoot = resolvePropertyRoot(data2, root) -- equivalent call inferred; original call site unknown
			return (getPath(propertyRoot, target.path or target.Path))
		end

		local function shouldApplyTrack(p)
			local target = p.target or p.Target
			local root

			if type(target) == "table" then
				root = target.root or target.Root
			else
				root = false
			end

			return root ~= "camera" and root ~= "lighting" and root ~= "workspace" or isme
		end

		local function setPropertyValue(p, colorSequences, property, colorSequence, property_keyframe)
			local value_type = property_keyframe.value_type or property_keyframe.valueType
			local property_type = property_keyframe.property_type or property_keyframe.propertyType
			local v18

			if property_keyframe.relative_to_origin == true then
				v18 = true
			elseif type(property_keyframe.target) == "table" then
				v18 = property_keyframe.target.relative_to_origin == true
			else
				v18 = false
			end

			if value_type == "CFrame" and v18 and p.cutscene_origin then
				local authored_origin = p.authored_origin or CFrame.new()
				colorSequence = p.cutscene_origin * authored_origin:ToObjectSpace(colorSequence)
			end

			if property_type == "ColorSequence" and typeof(colorSequence) == "Color3" then
				colorSequence = ColorSequence.new(colorSequence)
			end

			if property == "CFrame" and colorSequences:IsA("Model") and typeof(colorSequence) == "CFrame" then
				rememberProperty(colorSequences, "WorldPivot")
				colorSequences:PivotTo(colorSequence)
			else
				if property == "Transparency" and typeof(colorSequence) == "number" and not (colorSequences:IsA("BasePart") or colorSequences:IsA("Decal") or colorSequences:IsA("Texture")) then
					setModelTransparency(colorSequences, colorSequence)
					return
				end

				rememberProperty(colorSequences, property)
				pcall(function()
					colorSequences[property] = colorSequence
				end)
			end
		end

		local function updatePropertyKeyframes(p, p2)
			local property_keyframes = FrameEvents.property_keyframes or FrameEvents.propertyKeyframes

			if type(property_keyframes) ~= "table" then
				return
			end

			for i, property_keyframe in ipairs(property_keyframes) do
				local target = property_keyframe.target or property_keyframe.Target
				local root

				if type(target) == "table" then
					root = target.root or target.Root
				else
					root = false
				end

				if not (root ~= "camera" and root ~= "lighting" and root ~= "workspace" or isme) then
					continue
				end

				local target2 = property_keyframe.target or property_keyframe.Target
				local propertyTarget = resolvePropertyTarget(p, target2) -- equivalent call inferred; original call site unknown
				local property = property_keyframe.property or property_keyframe.Property
				local values = property_keyframe.values or property_keyframe.Values
				local value_type = property_keyframe.value_type or property_keyframe.valueType or "number"
				local root2

				if type(target2) == "table" then
					root2 = target2.root or target2.Root or nil
				end

				local name = property_keyframe.name or property_keyframe.Name or "track_" .. tostring(i)

				if (root2 == "backgroundUI" or root2 == "background_ui" or root2 == "backgroundImage" or root2 == "background_image" or root2 == "impactUI" or root2 == "impact_ui" or root2 == "impactImage" or root2 == "impact_image") and not v17[name] then
					v17[name] = true
					vegLog(
						"property track",
						name,
						"root",
						tostring(root2),
						"property",
						tostring(property),
						"target",
						not propertyTarget and "nil" or propertyTarget:GetFullName() or "nil",
						"values",
						(type(values))
					)
				end

				if not (propertyTarget and type(property) == "string" and type(values) == "table") then
					continue
				end

				local v18 = interpolateValue(values, p2, value_type, property_keyframe.eases or property_keyframe.Eases)

				if v18 ~= nil then
					setPropertyValue(p, propertyTarget, property, v18, property_keyframe)
				end
			end
		end

		local function executeFrameEvents(p, data2)
			local frame_events = FrameEvents.frame_events or FrameEvents.frameEvents

			if not frame_events then
				return
			end

			local v18 = math.floor(p + 0.5)

			if v18 <= v11 then
				return
			end

			for i = math.max(0, v11 + 1), v18 do
				local frame_event = frame_events[i]

				if not frame_event then
					continue
				end

				local v20 = vegPath(data2.backgroundUI) -- equivalent call inferred; original call site unknown
				local v21 = vegPath(data2.backgroundImage) -- equivalent call inferred; original call site unknown
				local v22 = vegPath(data2.camera_rig) -- equivalent call inferred; original call site unknown
				vegLog(
					"frame event",
					i,
					"backgroundUI",
					v20,
					"backgroundImage",
					v21,
					"cameraRig",
					v22,
					"vfx",
					vegPath(data2.vfx)
				)
				local thread = nil
				local v23 = frame_event
				local v24 = i
				thread = task.spawn(function()
					local success, result = pcall(v23, data2)

					if not (success or flag2) then
						warn("Vegetable frame event error:", v24, result)
					end

					local index = table.find(v9.tasks, thread)

					if index then
						table.remove(v9.tasks, index)
					end
				end)
				local v25 = thread

				if not v25 then
					continue
				end

				table.insert(v9.tasks, v25)

				if cleanupTable then
					table.insert(cleanupTable, v25)
				end
			end

			v11 = v18
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function addPreloadAsset(list, p, value)
			if type(value) ~= "string" or value == "" or p[value] then
				return
			end

			p[value] = true
			table.insert(list, value)
		end

		local function collectPreloadAssets(folder, list, p, p2)
			if not folder then
				return
			end

			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:IsA("Animation") then
					local animationId = descendant.AnimationId

					if type(animationId) == "string" and animationId ~= "" and not p[animationId] then
						p[animationId] = true
						table.insert(list, animationId)
					end
				elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
					addPreloadAsset(list, p, descendant.Texture) -- equivalent call inferred; original call site unknown
					local list2 = p2.list
					local seen = p2.seen
					local texture2 = descendant.Texture

					if type(texture2) == "string" and texture2 ~= "" and not seen[texture2] then
						seen[texture2] = true
						table.insert(list2, texture2)
					end
				elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
					addPreloadAsset(list, p, descendant.Image) -- equivalent call inferred; original call site unknown
					local list2 = p2.list
					local seen = p2.seen
					local image2 = descendant.Image

					if type(image2) == "string" and image2 ~= "" and not seen[image2] then
						seen[image2] = true
						table.insert(list2, image2)
					end
				elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
					local texture = descendant.Texture
					addPreloadAsset(list, p, texture) -- equivalent call inferred; original call site unknown
					local list2 = p2.list
					local seen = p2.seen

					if type(texture) == "string" and texture ~= "" and not seen[texture] then
						seen[texture] = true
						table.insert(list2, texture)
					end
				elseif descendant:IsA("MeshPart") then
					addPreloadAsset(list, p, descendant.MeshId) -- equivalent call inferred; original call site unknown
					local textureID = descendant.TextureID

					if type(textureID) == "string" and textureID ~= "" and not p[textureID] then
						p[textureID] = true
						table.insert(list, textureID)
					end
				elseif descendant:IsA("SpecialMesh") then
					addPreloadAsset(list, p, descendant.MeshId) -- equivalent call inferred; original call site unknown
					local textureId = descendant.TextureId

					if type(textureId) == "string" and textureId ~= "" and not p[textureId] then
						p[textureId] = true
						table.insert(list, textureId)
					end
				elseif descendant:IsA("Sound") then
					local soundId = descendant.SoundId

					if type(soundId) == "string" and soundId ~= "" and not p[soundId] then
						p[soundId] = true
						table.insert(list, soundId)
					end
				end
			end
		end

		local function buildPreloadList(...)
			local v18 = {}
			local v19 = {
				list = {},
				seen = {}
			}
			local v20 = {}

			for _, v21 in ipairs({
				"assetids1",
				"assetids2",
				"startids",
				"startids1"
			}) do
				local v22 = PreloadData[v21]

				if type(v22) ~= "table" then
					continue
				end

				for _, v23 in ipairs(v22) do
					addPreloadAsset(v20, v18, v23) -- equivalent call inferred; original call site unknown
					local list = v19.list
					local seen = v19.seen

					if type(v23) ~= "string" or v23 == "" or seen[v23] then
						continue
					end

					seen[v23] = true
					table.insert(list, v23)
				end
			end

			for _, v21 in ipairs({ ... }) do
				collectPreloadAssets(v21, v20, v18, v19)
			end

			return v20, v19.seen
		end

		local function startPreload(...)
			if v12 or not (isme and localPlayer) then
				return
			end

			v12 = true
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
			local mobileJunk = playerGui:FindFirstChild("MobileJunk") or playerGui:WaitForChild("MobileJunk", 2)
			local instance, v19, v20 = Instance.new(mobileJunk and "Folder" or "ScreenGui")

			if instance then
				markTree(instance) -- equivalent call inferred; original call site unknown
				table.insert(v9.objects, instance)

				if cleanupTable and not v20 then
					table.insert(cleanupTable, instance)
				end

				if not v19 then
					destroyLater(instance) -- equivalent call inferred; original call site unknown
				end
			end

			instance.Name = "VegetablePreload"

			if instance:IsA("ScreenGui") then
				instance.ResetOnSpawn = false
				instance.IgnoreGuiInset = true
				instance.DisplayOrder = -1000
			end

			instance.Parent = mobileJunk or playerGui
			local preloadList, v21 = buildPreloadList(...)
			local v22 = 1.5 / math.max(#preloadList, 1)
			local thread = task.spawn(function()
				for _, image in ipairs(preloadList) do
					if not (run_context.running and instance.Parent) then
						break
					end

					if v21[image] then
						local imageLabel = Instance.new("ImageLabel")
						imageLabel.BackgroundTransparency = 1
						imageLabel.ImageTransparency = 1
						imageLabel.Size = UDim2.fromOffset(1, 1)
						imageLabel.Position = UDim2.fromOffset(-4, -4)
						imageLabel.Image = image
						imageLabel.Parent = instance
					end

					local v24 = image
					pcall(function()
						ContentProvider:PreloadAsync({ v24 })
					end)
					task.wait(v22)
				end
			end)

			if thread then
				table.insert(v9.tasks, thread)

				if cleanupTable then
					table.insert(cleanupTable, thread)
				end
			end
		end

		local function trackGeneratedPartIcles()
			local terrain = Workspace:FindFirstChildOfClass("Terrain")

			if not terrain then
				return
			end

			local v18 = terrain:FindFirstChild("EmittedPartsUsingPart_icle")

			if not v18 then
				v18 = Instance.new("Folder")
				v18.Name = "EmittedPartsUsingPart_icle"
				v18.Parent = terrain
			end

			v9.connections.partIclesGenerated = v18.ChildAdded:Connect(function(child)
				if run_context.running and not flag2 then
					if child then
						markTree(child) -- equivalent call inferred; original call site unknown
						table.insert(v9.objects, child)

						if cleanupTable then
							table.insert(cleanupTable, child)
						end

						destroyLater(child) -- equivalent call inferred; original call site unknown
					end

					trackTreeEffects(child) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local function startLoop(instance, list, value, value2)
			if not instance or type(list) ~= "table" then
				vegLog("loop skipped", value2 or "unknown", "instance", vegPath(instance), "textures", (type(list)))
				return
			end

			vegLog(
				"loop start",
				value2 or instance.Name,
				"instance",
				not instance and "nil" or instance:GetFullName() or "nil",
				"textures",
				#list,
				"duration",
				value or 1
			)
			local textureflipbookLoop = Vfxmodule.textureflipbookLoop(instance, list, value or 1)

			if textureflipbookLoop then
				table.insert(v9.controllers, textureflipbookLoop)
			else
				vegLog("loop controller missing", value2 or instance.Name, vegPath(instance))
			end
		end

		local function setupColorSkill()
			if not isme then
				return nil
			end

			local v18 = Lighting:FindFirstChild("ColorSkill")

			if v18 and not v18:IsA("ColorCorrectionEffect") then
				vegLog("ColorSkill invalid", not v18 and "nil" or v18:GetFullName() or "nil", v18.ClassName)
				return nil
			end

			if v18 then
				v14 = v18:GetAttribute("VegetableColorSkill") == true
			else
				v18 = Instance.new("ColorCorrectionEffect")
				v18.Name = "ColorSkill"
				v18.TintColor = Color3.new(1, 1, 1)
				v18.Brightness = 0
				v18.Saturation = 0
				v18.Contrast = 0
				v18.Enabled = true
				v18:SetAttribute("VegetableColorSkill", true)
				v18.Parent = Lighting
				v14 = true
			end

			v18:SetAttribute("VegetableColorSkillActive", true)
			v13 = v18
			v15 = {
				TintColor = v18.TintColor,
				Brightness = v18.Brightness,
				Saturation = v18.Saturation,
				Contrast = v18.Contrast,
				Enabled = v18.Enabled
			}
			rememberProperty(v18, "Enabled")
			v18.Enabled = true
			vegLog(
				"ColorSkill ready",
				not v18 and "nil" or v18:GetFullName() or "nil",
				"created",
				tostring(v14),
				"brightness",
				v18.Brightness,
				"saturation",
				v18.Saturation,
				"contrast",
				v18.Contrast
			)
			return v18
		end

		local function fadeColorSkillOut()
			local v18 = v13

			if not (v18 and v18.Parent) then
				return
			end

			local vegetableColorSkill = v18:GetAttribute("VegetableColorSkill") == true
			local v19

			if vegetableColorSkill then
				v19 = {
					TintColor = Color3.new(1, 1, 1),
					Brightness = 0,
					Saturation = 0,
					Contrast = 0
				}
			else
				v19 = v15
			end

			if not v19 then
				return
			end

			v18:SetAttribute("VegetableColorSkillActive", false)
			local success, result = pcall(function()
				return TweenService:Create(v18, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					TintColor = v19.TintColor,
					Brightness = v19.Brightness,
					Saturation = v19.Saturation,
					Contrast = v19.Contrast
				})
			end)

			if success and result then
				result:Play()
				vegLog(
					"ColorSkill fade out",
					not v18 and "nil" or v18:GetFullName() or "nil",
					"vegetableOwned",
					tostring(vegetableColorSkill),
					"destroyAfter",
					(tostring(v14))
				)
			else
				v18.TintColor = v19.TintColor
				v18.Brightness = v19.Brightness
				v18.Saturation = v19.Saturation
				v18.Contrast = v19.Contrast
			end

			task.delay(0.6000000000000001, function()
				if not (v18 and v18.Parent) then
					return
				end

				v18.TintColor = v19.TintColor
				v18.Brightness = v19.Brightness
				v18.Saturation = v19.Saturation
				v18.Contrast = v19.Contrast

				if not vegetableColorSkill and v15 then
					v18.Enabled = v15.Enabled
				end

				if vegetableColorSkill and v18:GetAttribute("VegetableColorSkillActive") ~= true then
					local v21 = vegPath(v18) -- equivalent call inferred; original call site unknown
					v18:Destroy()
					vegLog("ColorSkill destroyed", v21)
				end
			end)
		end

		local function restoreVegetableLighting()
			if v16 or not isme then
				return
			end

			v16 = true
			fadeColorSkillOut()
		end

		local function fn2()
			if flag3 then
				return
			end

			flag3 = true
			flag4 = false
			run_context.running = false

			for _, connection in pairs(v9.connections) do
				if not connection then
					continue
				end

				local connection2 = connection
				pcall(function()
					connection2:Disconnect()
				end)
			end

			local thread = coroutine.running()

			for _, task2 in pairs(v9.tasks) do
				if not (task2 and task2 ~= thread) then
					continue
				end

				local v18 = task2
				pcall(function()
					task.cancel(v18)
				end)
			end

			for _, tween in pairs(v9.tweens) do
				if not tween then
					continue
				end

				local v18 = tween
				pcall(function()
					v18:Cancel()
				end)
			end

			stopControllers()

			for _, particle in pairs(v9.particles) do
				if not particle then
					continue
				end

				local v18 = particle
				pcall(function()
					v18.Enabled = false
				end)
			end

			for _, beam in pairs(v9.beams) do
				if not beam then
					continue
				end

				local v18 = beam
				pcall(function()
					v18.Enabled = false
				end)
			end

			for _, trail in pairs(v9.trails) do
				if not trail then
					continue
				end

				local v18 = trail
				pcall(function()
					v18.Enabled = false
				end)
			end

			for _, light in pairs(v9.lights) do
				if not light then
					continue
				end

				local v18 = light
				pcall(function()
					v18.Enabled = false
				end)
			end

			restoreProperties(true)

			if not v16 and isme then
				v16 = true
				fadeColorSkillOut()
			end

			for _, object in pairs(v9.objects) do
				if not object then
					continue
				end

				local v18 = object
				pcall(function()
					v18:Destroy()
				end)
			end

			table.clear(v9.connections)
			table.clear(v9.objects)
			table.clear(v9.tweens)
			table.clear(v9.particles)
			table.clear(v9.beams)
			table.clear(v9.trails)
			table.clear(v9.lights)
			table.clear(v9.tasks)
			table.clear(v9.restores)
		end

		local function Clean()
			if flag2 then
				return
			end

			if fn then
				fn(0)
			end

			if v13 and v13.Parent then
				game.Debris:AddItem(v13, 0.5)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(v13, TweenInfo.new(0.5), {
					Contrast = 0,
					Saturation = 0,
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255)
				}):Play()
			end

			flag2 = true

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
				parentChangedConnection = nil
			end

			if fn2 then
				fn2()
			end

			if isme and shared.originallighting then
				pcall(shared.originallighting)
			end
		end

		if bind then
			parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
				if not (bind and bind.Parent) then
					Clean()
				end
			end)
		end

		local thread = task.delay(15, function()
			Clean()
		end)

		if thread then
			table.insert(v9.tasks, thread)

			if cleanupTable then
				table.insert(cleanupTable, thread)
			end
		end

		if flag2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			Clean()
			return
		end

		local function runCutscene()
			if flag4 then
				return
			end

			local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local misc = script:FindFirstChild("Misc")
			local VFX = script:FindFirstChild("VFX")
			vegLog(
				"runCutscene",
				"root",
				not humanoidRootPart and "nil" or humanoidRootPart:GetFullName() or "nil",
				"misc",
				not misc and "nil" or misc:GetFullName() or "nil",
				"hasBackgroundUI",
				tostring(misc and misc:FindFirstChild("BackgroundUI") ~= nil),
				"vfxTemplate",
				not VFX and "nil" or VFX:GetFullName() or "nil"
			)

			if not VFX then
				vegLog("abort", "missing VFX template")
				return
			end

			local thrown = Workspace:FindFirstChild("Thrown") or Workspace
			local cFrame = humanoidRootPart.CFrame
			local cameraRigVegetable

			if isme then
				local screenLines = char:FindFirstChild("CameraRigVegetable").ScreenLines
				cameraRigVegetable = char:FindFirstChild("CameraRigVegetable")
				task.spawn(function()
					local lastTime = tick()

					while tick() - lastTime < 20 and screenLines.Parent do
						screenLines:PivotTo(game.Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 0))
						local RunService2 = game:GetService("RunService")
						RunService2.Heartbeat:Wait()
					end
				end)
				table.insert(v9.objects, screenLines)
			end

			local clone, v18, v19 = VFX:Clone()

			if clone then
				markTree(clone) -- equivalent call inferred; original call site unknown
				table.insert(v9.objects, clone)

				if cleanupTable and not v19 then
					table.insert(cleanupTable, clone)
				end

				if not v18 then
					destroyLater(clone) -- equivalent call inferred; original call site unknown
				end
			end

			clone.Name = "VegetableVFX"
			clone:PivotTo(cFrame)
			trackTreeEffects(clone) -- equivalent call inferred; original call site unknown
			clone.Parent = thrown
			trackGeneratedPartIcles()
			task.delay(1, function()
				if cancontinue() and fn then
					fn(1)
				end
			end)
			local colorSkill = setupColorSkill()
			local v21 = nil
			local imageLabel = nil

			if isme and misc and misc:FindFirstChild("BackgroundUI") and localPlayer then
				local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")

				for _, child in ipairs(playerGui:GetChildren()) do
					if child:GetAttribute("VegetableBackgroundUI") ~= true then
						continue
					end

					vegLog("background old clone removed", not child and "nil" or child:GetFullName() or "nil")
					child:Destroy()
				end

				local clone2 = misc.BackgroundUI:Clone()
				clone2:SetAttribute("VegetableBackgroundUI", true)

				if clone2 then
					markTree(clone2) -- equivalent call inferred; original call site unknown
					table.insert(v9.objects, clone2)

					if cleanupTable then
						table.insert(cleanupTable, clone2)
					end

					destroyLater(clone2) -- equivalent call inferred; original call site unknown
				end

				v21 = clone2
				v21.Parent = playerGui
				imageLabel = v21:FindFirstChild("ImageLabel", true)
				vegLog(
					"background screenGui parented",
					"source",
					vegPath(misc.BackgroundUI),
					"backgroundUI",
					not v21 and "nil" or v21:GetFullName() or "nil",
					"class",
					v21.ClassName,
					"children",
					#v21:GetChildren(),
					"backgroundImage",
					not imageLabel and "nil" or imageLabel:GetFullName() or "nil",
					"displayOrder",
					v21.DisplayOrder,
					"enabled",
					(tostring(v21.Enabled))
				)
				game.Debris:AddItem(clone2, 25)
			else
				vegLog(
					"background skipped",
					"isme",
					tostring(isme),
					"misc",
					not misc and "nil" or misc:GetFullName() or "nil",
					"hasBackgroundUI",
					tostring(misc and misc:FindFirstChild("BackgroundUI") ~= nil),
					"player",
					(tostring(localPlayer))
				)
			end

			local function start_flipbook(decal, ids, duration: number, part2: string)
				if not decal or #ids == 0 or duration <= 0 then
					return
				end

				local count = #ids
				local v22 = count / duration
				local v23 = 0
				local v24 = 1
				decal.Texture = ids[1]
				v9.connections["flipbook_" .. part2] = RunService.Heartbeat:Connect(function(dt)
					if not decal.Parent then
						return
					end

					v23 += dt
					local v25 = math.floor(v23 * v22)

					if v25 > 0 then
						v24 += v25
						v23 -= v25 / v22

						if count < v24 then
							v24 = (v24 - 1) % count + 1
						end

						decal.Texture = ids[v24]
					end
				end)
			end

			local function start_flipbook_loops(clone2)
				preload_flipbook_textures() -- equivalent call inferred; original call site unknown

				for _, v22 in ipairs(v4) do
					local child = clone2:FindFirstChild(v22.part)
					local decal = child and child:FindFirstChild(v22.child)

					if decal and decal:IsA("Decal") then
						start_flipbook(decal, v22.ids, v22.duration, v22.part)
					end
				end
			end

			start_flipbook_loops(clone)
			local v22 = {
				character = char,
				victim = targChar,
				Victim = targChar,
				camera = currentCamera,
				lighting = Lighting,
				cameraRig = cameraRigVegetable,
				camera_rig = cameraRigVegetable,
				vfx = clone,
				backgroundUI = v21,
				background_ui = v21,
				backgroundImage = imageLabel,
				background_image = imageLabel,
				colorSkill = colorSkill,
				ColorSkill = colorSkill,
				cutscene_origin = cFrame,
				authored_origin = authoredOrigin,
				run_context = run_context,
				cleanup_objects = v9.objects,
				cleanup_connections = v9.connections,
				cleanup_tasks = v9.tasks,
				cleanup_main = cleanupTable,
				isme = isme
			}
			local property_keyframes = FrameEvents.property_keyframes or FrameEvents.propertyKeyframes or {}
			local frame_events = FrameEvents.frame_events or FrameEvents.frameEvents or {}
			local count = 0
			local count2 = 0
			local count3 = 0

			for _, property_keyframe in ipairs(property_keyframes) do
				count += 1
				local target = property_keyframe.target or property_keyframe.Target
				local root

				if type(target) == "table" then
					root = target.root or target.Root or nil
				end

				local path

				if type(target) == "table" then
					path = target.path or target.Path or nil
				end

				if root == "backgroundUI" or root == "background_ui" or root == "backgroundImage" or root == "background_image" or root == "impactUI" or root == "impact_ui" or root == "impactImage" or root == "impact_image" then
					count2 += 1
				elseif root == "lighting" and type(path) == "table" and path[1] == "ColorSkill" then
					count3 += 1
				end
			end

			local count4 = 0

			for _ in pairs(frame_events) do
				count4 += 1
			end

			local v24 = vegPath(v22.backgroundUI) -- equivalent call inferred; original call site unknown
			vegLog(
				"objects ready",
				"backgroundUI",
				v24,
				"backgroundImage",
				vegPath(v22.backgroundImage),
				"colorSkill",
				vegPath(colorSkill),
				"propertyTracks",
				count,
				"backgroundTracks",
				count2,
				"colorSkillTracks",
				count3,
				"frameEvents",
				count4
			)

			if count2 == 0 then
				vegLog("warning", "FrameEvents has no background UI/image property tracks")
			end

			flag4 = true
			task.delay(5, function()
				if cancontinue() and fn then
					fn(0)
				end
			end)
			task.delay(10.5, function()
				if not cancontinue() then
					return
				end

				if v13 and v13.Parent then
					game.Debris:AddItem(v13, 0.5)
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(v13, TweenInfo.new(0.5), {
						Contrast = 0,
						Saturation = 0,
						Brightness = 0,
						TintColor = Color3.fromRGB(255, 255, 255)
					}):Play()
				end

				local accessory = Instance.new("Accessory")
				accessory.Name = "RootAnchor"
				accessory.Parent = char
				game.Debris:AddItem(accessory, 0.5)
				local frame = Instance.new("Frame")
				frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				frame.Parent = game.Players.LocalPlayer.PlayerGui.MobileJunk
				frame.Size = UDim2.new(1, 0, 1, 0)
				game.Debris:AddItem(frame, 2)
				task.delay(0.225, function()
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(frame, TweenInfo.new(1.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 1
					}):Play()
				end)
				shared.smoothout(workspace.CurrentCamera.CFrame)
				task.delay(0.2, function()
					realAnim:Stop(0.5)
				end)
			end)
			v9.connections.renderStepped = RunService.RenderStepped:Connect(function()
				if flag3 then
					return
				end

				if not cancontinue() then
					Clean()
					return
				end

				local v25 = realAnim.TimePosition * 60
				local length_frames = FrameEvents.length_frames or FrameEvents.lengthFrames

				if typeof(length_frames) == "number" then
					v25 = math.min(v25, length_frames)
				end

				updatePropertyKeyframes(v22, v25)
				executeFrameEvents(v25, v22)
			end)
		end

		v9.connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
			if player == localPlayer then
				Clean()
			end
		end)
		local success, result = pcall(runCutscene)

		if not success then
			warn("Vegetable cutscene error:", result)
			Clean()
		end

		print("RUNNING CUTSCENE")
	else
		local VegetableOutside = require(script.Parent.VegetableOutside)
		VegetableOutside.FirstEvent(data)
	end
end

return Vegetable