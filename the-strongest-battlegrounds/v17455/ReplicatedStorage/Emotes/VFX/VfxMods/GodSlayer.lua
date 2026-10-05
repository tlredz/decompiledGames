local createVector = vector.create
local GodSlayer = {}
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
local raiseZIndex = libraryNew.RaiseZIndex
local _ = libraryNew.Able
local _ = libraryNew.LifeScale
local _ = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local BoatTween = require(game.ReplicatedStorage.BoatTween)
local AfterImages = require(game.ReplicatedStorage.Resources.AfterImages)
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local camera = game.Workspace.Camera

local function tween(instance, p, data)
	task.spawn(function()
		if data.size then
			TweenService:Create(instance, p, {
				CFrame = data.cframe,
				Size = data.size
			}):Play()
		else
			TweenService:Create(instance, p, {
				CFrame = data.cframe
			}):Play()
		end

		for _, decal in pairs(instance:GetChildren()) do
			if decal:IsA("Decal") then
				TweenService:Create(decal, p, {
					Transparency = data.transparency
				}):Play()
			end
		end

		TweenService:Create(instance:FindFirstChildWhichIsA("SpecialMesh"), p, {
			Scale = data.scale
		}):Play()
	end)
end

local v = {
	Spin = {
		"rbxassetid://138228326519163",
		"rbxassetid://129382814532678",
		"rbxassetid://132494843370959",
		"rbxassetid://94486941624780",
		"rbxassetid://70857034403862",
		"rbxassetid://70582073983631",
		"rbxassetid://93696823057937",
		"rbxassetid://86470311024653",
		"rbxassetid://95657374097706",
		"rbxassetid://86794842387742",
		"rbxassetid://81741707944516",
		"rbxassetid://120747920075793",
		"rbxassetid://72693234491501",
		"rbxassetid://120577577345908",
		"rbxassetid://0"
	},
	Spin2 = {
		"rbxassetid://87808364522754",
		"rbxassetid://97396795837603",
		"rbxassetid://103618766086184",
		"rbxassetid://139944565334036",
		"rbxassetid://106534964430582",
		"rbxassetid://71124712309714",
		"rbxassetid://73496377553639",
		"rbxassetid://81921686263481",
		"rbxassetid://98106931114108",
		"rbxassetid://124460942892406",
		"rbxassetid://129799988238610",
		"rbxassetid://136148893514977",
		"rbxassetid://84674758484511",
		"rbxassetid://73366967838808",
		"rbxassetid://89325737180579",
		"rbxassetid://0"
	},
	Spin3 = {
		"rbxassetid://129245566037783",
		"rbxassetid://88610022940325",
		"rbxassetid://80427504890846",
		"rbxassetid://136590340566946",
		"rbxassetid://106296630028156",
		"rbxassetid://123056184130335",
		"rbxassetid://88398219487979",
		"rbxassetid://76722150904305",
		"rbxassetid://92051885296684",
		"rbxassetid://97579231437413",
		"rbxassetid://95390148636179",
		"rbxassetid://87598847245940",
		"rbxassetid://111938773661613",
		"rbxassetid://97816623820403",
		"rbxassetid://109539613835206",
		"rbxassetid://124802150644170",
		"rbxassetid://128613651389627",
		"rbxassetid://107696340394946",
		"rbxassetid://137853787716465",
		"rbxassetid://0"
	},
	RW2 = {
		"rbxassetid://126925507953778",
		"rbxassetid://126424592093446",
		"rbxassetid://121723581671791",
		"rbxassetid://82249141429729",
		"rbxassetid://78785744304040",
		"rbxassetid://94275280431085",
		"rbxassetid://129330080192867"
	},
	RW1 = {
		"rbxassetid://124744690971305",
		"rbxassetid://85552106776950",
		"rbxassetid://133731273943587",
		"rbxassetid://80213779921200",
		"rbxassetid://116461514000664"
	},
	ShockWindRush2 = {
		"rbxassetid://136600584459375",
		"rbxassetid://120382455286895",
		"rbxassetid://96586549447625",
		"rbxassetid://87094387531684",
		"rbxassetid://121173712033883",
		"rbxassetid://93541903927972",
		"rbxassetid://124058408319244",
		"rbxassetid://90170274067382",
		"rbxassetid://85110518927428",
		"rbxassetid://117305595285723",
		"rbxassetid://91098249281539",
		"rbxassetid://72959016160975",
		"rbxassetid://78933384421651",
		"rbxassetid://124279142023515",
		"rbxassetid://132660251102106",
		"rbxassetid://137009166622014",
		"rbxassetid://83995605414755",
		"rbxassetid://107002648386080",
		"rbxassetid://70519167464961",
		"rbxassetid://121491427182454",
		"rbxassetid://0"
	},
	WindBack = {
		"rbxassetid://132020080411258",
		"rbxassetid://114394786516123",
		"rbxassetid://82535924222735",
		"rbxassetid://74617171577120",
		"rbxassetid://125193979866253",
		"rbxassetid://77120754159431",
		"rbxassetid://122424735593546",
		"rbxassetid://110733290682021",
		"rbxassetid://77634907037263",
		"rbxassetid://107935035004646",
		"rbxassetid://100834927019716",
		"rbxassetid://95353252744651",
		"rbxassetid://123713442204508",
		"rbxassetid://118911523943515",
		"rbxassetid://103391073966658",
		"rbxassetid://0"
	},
	CameraWind = {
		"rbxassetid://126651098904179",
		"rbxassetid://75249542467434",
		"rbxassetid://108621096169432",
		"rbxassetid://105810885699200",
		"rbxassetid://140108946107149",
		"rbxassetid://94861483585384",
		"rbxassetid://97899181274431",
		"rbxassetid://98766547675993",
		"rbxassetid://104494826428011",
		"rbxassetid://104494826428011",
		"rbxassetid://100823886977859",
		"rbxassetid://100823886977859",
		"rbxassetid://136100209102647",
		"rbxassetid://136100209102647",
		"rbxassetid://132691259595524",
		"rbxassetid://0"
	},
	BarrageWind = {
		"rbxassetid://88466005487958",
		"rbxassetid://107067286293950",
		"rbxassetid://104931738670373",
		"rbxassetid://136884745624957",
		"rbxassetid://90030081344923",
		"rbxassetid://115320713566888",
		"rbxassetid://123240519464112",
		"rbxassetid://113148580562155",
		"rbxassetid://73678769193207",
		"rbxassetid://91690475863151",
		"rbxassetid://127418190214408",
		"rbxassetid://130343079644358",
		"rbxassetid://135925873487889",
		"rbxassetid://131889898097629",
		"rbxassetid://0"
	},
	Swirl = {
		"rbxassetid://131036728956859",
		"rbxassetid://123932433063613",
		"rbxassetid://94222999771640",
		"rbxassetid://106883620957380",
		"rbxassetid://124264165042628",
		"rbxassetid://135677946593316",
		"rbxassetid://99336096076015",
		"rbxassetid://70548460519223",
		"rbxassetid://126452000810890",
		"rbxassetid://114266435263251",
		"rbxassetid://90134342898424",
		"rbxassetid://91335772461917",
		"rbxassetid://111745403972784",
		"rbxassetid://85076255323683",
		"rbxassetid://83495466638717",
		"rbxassetid://102387034050463",
		"rbxassetid://70676798712637",
		"rbxassetid://76640557419067",
		"rbxassetid://93192532649109",
		"rbxassetid://84514459654196",
		"rbxassetid://0"
	},
	Nah = {
		"rbxassetid://112101803881749",
		"rbxassetid://124279540927090",
		"rbxassetid://124428896473682",
		"rbxassetid://123111899210069",
		"rbxassetid://95200657405341",
		"rbxassetid://117121316659466",
		"rbxassetid://127962160155271",
		"rbxassetid://105330902948664",
		"rbxassetid://91057300348402",
		"rbxassetid://110716827045035",
		"rbxassetid://120950353175501",
		"rbxassetid://86407188958451",
		"rbxassetid://110879493209569",
		"rbxassetid://71782281798541",
		"rbxassetid://0"
	},
	FlipB = {
		"rbxassetid://89492159507261",
		"rbxassetid://119754772216468",
		"rbxassetid://80174966822200",
		"rbxassetid://123481351846767",
		"rbxassetid://83810902609506",
		"rbxassetid://96639297616472",
		"rbxassetid://105404170717809",
		"rbxassetid://95801883785180",
		"rbxassetid://106338635849877",
		"rbxassetid://137202521535001",
		"rbxassetid://127059755389247",
		"rbxassetid://96996233358749",
		"rbxassetid://101130978359066",
		"rbxassetid://101091935684391",
		"rbxassetid://107476904861972",
		"rbxassetid://132827050636028",
		"rbxassetid://81300426874273",
		"rbxassetid://124262543194702",
		"rbxassetid://122291503250004",
		"rbxassetid://137151256733720"
	},
	RushWind = {
		"rbxassetid://110372583394985",
		"rbxassetid://84294996397753",
		"rbxassetid://96275913282742",
		"rbxassetid://74902273437755",
		"rbxassetid://74652924914207",
		"rbxassetid://101438518530535",
		"rbxassetid://86239758618866",
		"rbxassetid://89529471260428",
		"rbxassetid://92315413745481",
		"rbxassetid://99612702098163",
		"rbxassetid://103475922125650",
		"rbxassetid://85628472526943",
		"rbxassetid://128985278277539",
		"rbxassetid://0"
	},
	WindBurst = {
		"rbxassetid://107982265329303",
		"rbxassetid://106371442275817",
		"rbxassetid://113743472066537",
		"rbxassetid://94950482959688",
		"rbxassetid://72184864725153",
		"rbxassetid://139528487037480",
		"rbxassetid://92594127830611",
		"rbxassetid://137483981664289",
		"rbxassetid://111912642437360"
	},
	Bw = {
		"rbxassetid://96361403080672",
		"rbxassetid://114394138101413",
		"rbxassetid://120219967399902",
		"rbxassetid://125883666979453",
		"rbxassetid://73765955652322",
		"rbxassetid://99807397232042",
		"rbxassetid://137382872246789",
		"rbxassetid://75867886337527",
		"rbxassetid://136650845519736",
		"rbxassetid://115015903394963",
		"rbxassetid://118699496626189",
		"rbxassetid://132306012866214",
		"rbxassetid://118975985322755",
		"rbxassetid://131010469024219",
		"rbxassetid://132849407457630",
		"rbxassetid://100183302834431",
		"rbxassetid://101897751399688",
		"rbxassetid://87915374502345",
		"rbxassetid://137890200971560",
		"rbxassetid://71276773892441"
	},
	Wi = {
		"rbxassetid://75864411023119",
		"rbxassetid://90673150672215",
		"rbxassetid://75142865934865",
		"rbxassetid://124820684439571",
		"rbxassetid://138138041388671",
		"rbxassetid://86539772512949",
		"rbxassetid://93146501049070",
		"rbxassetid://116428129160095",
		"rbxassetid://138141953161088",
		"rbxassetid://138967124580490",
		"rbxassetid://127593248074413",
		"rbxassetid://75930380792526",
		"rbxassetid://88622921998947",
		"rbxassetid://78050133668826",
		"rbxassetid://94732273783934",
		"rbxassetid://90984344783232",
		"rbxassetid://131016886695324",
		"rbxassetid://0"
	},
	At1 = {
		"rbxassetid://113855533794295",
		"rbxassetid://117040210682826",
		"rbxassetid://130930131813778",
		"rbxassetid://136027269014081",
		"rbxassetid://138521262847545",
		"rbxassetid://133441825566110",
		"rbxassetid://127747298194809",
		"rbxassetid://84759588321510",
		"rbxassetid://104493218700099",
		"rbxassetid://83244619168173",
		"rbxassetid://134196827499513",
		"rbxassetid://117217658034448",
		"rbxassetid://124462592419393",
		"rbxassetid://140403231940629",
		"rbxassetid://0"
	},
	At2 = {
		"rbxassetid://105274036483018",
		"rbxassetid://112537271473564",
		"rbxassetid://131768365460435",
		"rbxassetid://136883061330775",
		"rbxassetid://133294280477189",
		"rbxassetid://126080243067770",
		"rbxassetid://115863980607881",
		"rbxassetid://106040034540879",
		"rbxassetid://82501005811607",
		"rbxassetid://105080358227553",
		"rbxassetid://105220090400065",
		"rbxassetid://96755099307166",
		"rbxassetid://122467493535196",
		"rbxassetid://139439956489106",
		"rbxassetid://0"
	},
	MeshImpact = {
		"rbxassetid://111303036220650",
		"rbxassetid://100994923821289",
		"rbxassetid://103117560072861",
		"rbxassetid://82878171834679",
		"rbxassetid://124886913692475",
		"rbxassetid://86697599441138",
		"rbxassetid://95723147536717",
		"rbxassetid://91416378600959",
		"rbxassetid://115264504708422",
		"rbxassetid://106912811891761",
		"rbxassetid://116283726534780",
		"rbxassetid://110194954041305",
		"rbxassetid://87515997096282",
		"rbxassetid://105040419656969",
		"rbxassetid://125909967609358",
		"rbxassetid://0"
	},
	RedWind = {
		"rbxassetid://121116478378450",
		"rbxassetid://71741902001133",
		"rbxassetid://73685257102884",
		"rbxassetid://112332886746301",
		"rbxassetid://108312458724731",
		"rbxassetid://138671196924671",
		"rbxassetid://89510611727914",
		"rbxassetid://102510322570048",
		"rbxassetid://86537097801455",
		"rbxassetid://85374083572604",
		"rbxassetid://105223173182970",
		"rbxassetid://70940245812084",
		"rbxassetid://118051599941771",
		"rbxassetid://98914369780079",
		"rbxassetid://130418988180098",
		"rbxassetid://74902817038143",
		"rbxassetid://125301471707493",
		"rbxassetid://90133058630033",
		"rbxassetid://91472849765345",
		"rbxassetid://0"
	}
}
local _ = script.Vfx
local v2 = {
	Debris = function(p, duration: number)
		task.delay(duration, p.Destroy, p)
	end,
	Tween = function(p, p2, p3)
		local tween2 = TweenService:Create(p, p2, p3)
		tween2:Play()
		tween2:Destroy()
	end
}

local function particleEm(folder)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			local v3 = effect
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				if v3:GetAttribute("EmitCount") then
					v3:Emit(v3:GetAttribute("EmitCount"))
				end

				if v3:GetAttribute("EmitDuration") then
					v3.Enabled = true
					task.wait(v3:GetAttribute("EmitDuration"))
					v3.Enabled = false
				end
			end)
		end

		if not (effect:IsA("Beam") or effect:IsA("Trail")) then
			continue
		end

		local v3 = effect
		task.spawn(function()
			if v3:GetAttribute("EmitDelay") then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			if v3:GetAttribute("EmitDuration") then
				v3.Enabled = true
				task.wait(v3:GetAttribute("EmitDuration"))
				v3.Enabled = false
			end
		end)
	end
end

function v2:MeshFlipbook(list, duration: number)
	task.spawn(function()
		if self:IsA("Beam") then
		end

		for i = 1, #list do
			self.Texture = list[i]
			task.wait(duration)
		end
	end)
end

function v2.Emitt(p)
	particleEm(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RandomNumber(p: number, p2: number)
	return Random.new():NextNumber(p, p2)
end

local function QuadBezier(p: number, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local v3 = 1 - p
	return v3 ^ 2 * vector2 + v3 * 2 * p * vector3 + p ^ 2 * vector4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ScreenFlip(wind, cameraWind, duration: number)
	task.spawn(function()
		for i = 1, #cameraWind do
			wind.Image = cameraWind[i]
			task.wait(duration)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PseudoWeld(instance, humanoidRootPart, p: number)
	task.spawn(function()
		local total = 0
		local heartbeatConnection = nil
		local RunService = game:GetService("RunService")
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if p <= total then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			instance:PivotTo(humanoidRootPart.CFrame)
			total += dt
		end)
	end)
end

local function ClearVfx(folder)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("Script") or descendant:IsA("ModuleScript") or descendant:IsA("LocalScript") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail")) then
			continue
		end

		descendant:Destroy()
	end
end

local function EnableSceneLight(folder, p)
	for _, light in folder:GetDescendants() do
		if not (light:IsA("PointLight") or light:IsA("SpotLight")) then
			continue
		end

		if p == true then
			light.Enabled = true
		elseif p == false then
			light.Enabled = false
		end
	end
end

function GodSlayer.FirstEvent(p)
	local char = p.Data.Char
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local v4 = object._maid:give(script.FirstEventVfx:Clone())
		game.Debris:AddItem(v4, 8)
		v4:PivotTo(char:GetPivot() * v4:GetAttribute("Offset"):Inverse())
		v4.Parent = game.Workspace.Thrown
		v2.Emitt(v4.Jump)
		v4.Jump.J.PointLight.Brightness = 7
		v2.Tween(v4.Jump.J.PointLight, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
			Brightness = 0
		})

		for _, child in pairs(v4.Jump:GetChildren()) do
			local child2 = char:FindFirstChild(child.Name)

			if not child2 then
				continue
			end

			child.Anchored = false
			child.Massless = true
			local weld = Instance.new("Weld")
			weld.Part0 = child2
			weld.Part1 = child
			weld.Parent = child
		end

		task.spawn(function()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { game.Workspace.Built, game.Workspace.Map }

			for _ = 1, 5 do
				local v5 = v4.FirstSlam.Part.CFrame * CFrame.new(Random.new():NextNumber(-4, 4), 0, RandomNumber(-4, 4))

				if not game.Workspace:Raycast(v5.Position, createVector(0, -15, 0), raycastParams) then
					continue
				end

				local clone = script.Spec:Clone()
				v2.Debris(clone, 3)
				clone.Size = createVector(1, 1, 1) * Random.new():NextNumber(0.65, 1.25)
				clone.CFrame = v4.Jump.J.CFrame * CFrame.new(Random.new():NextNumber(-4, 4), 0, RandomNumber(-4, 4))
				clone.Parent = workspace.Thrown
				local position = clone.Position
				local position2 = (clone.CFrame * CFrame.new(
					Random.new():NextNumber(-9, 9),
					Random.new():NextNumber(1, 3),
					RandomNumber(-9, 9)
				)).Position
				local v6 = position2 + Vector3.new(
					Random.new():NextNumber(-4, 4),
					Random.new():NextNumber(6, 15),
					RandomNumber(-4, 4)
				)
				local total = 0
				local v7 = Random.new():NextNumber(15, 55) / 55
				v2.Tween(clone, TweenInfo.new(v7, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Size = createVector(0, 0, 0)
				})
				local renderSteppedConnection = nil
				local RunService = game:GetService("RunService")
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					local v13 = total / v7

					if v13 >= 1 or not (clone and clone.Parent) then
						renderSteppedConnection:Disconnect()
						renderSteppedConnection = nil
					end

					local v14 = clone
					local v18 = 1 - v13
					local v19 = v18 ^ 2 * position + v18 * 2 * v13 * v6 + v13 ^ 2 * position2
					local v20 = v13 + 0.01
					local v24 = 1 - v20
					v14.CFrame = CFrame.lookAt(v19, v24 ^ 2 * position + v24 * 2 * v20 * v6 + v20 ^ 2 * position2)
					total += dt
				end)
			end
		end)
		task.delay(0.3, function()
			local v5 = false
			task.delay(0.35, function()
				v5 = true
			end)

			repeat
				local randomNumber = RandomNumber(6.5, 8) -- equivalent call inferred; original call site unknown
				local randomNumber2 = RandomNumber(0.0125, 0.016) -- equivalent call inferred; original call site unknown
				local clone = v4.FirstSlam.WindAround:Clone()
				v2.Debris(clone, 4)
				clone.CFrame = CFrame.new(char.Torso.Position) * CFrame.new(0, Random.new():NextNumber(0.8, 2.25), 0) * CFrame.Angles(
					math.rad((Random.new():NextNumber(-10, 10))),
					math.rad((Random.new():NextNumber(-180, 180))),
					(math.rad((Random.new():NextNumber(-10, 10))))
				)
				clone.Parent = workspace.Thrown
				v2.MeshFlipbook(clone.Decal, v.Wi, randomNumber2)
				v2.Tween(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					CFrame = clone.CFrame * CFrame.new(0, Random.new():NextNumber(-2.5, -1), 0) * CFrame.Angles(
						0,
						math.rad((Random.new():NextNumber(55, 135))),
						0
					)
				})
				v2.Tween(clone.Mesh, TweenInfo.new(0.525, Enum.EasingStyle.Cubic), {
					Scale = Vector3.new(randomNumber, 5.091, randomNumber)
				})
				v2.Tween(clone.Decal, TweenInfo.new(Random.new():NextNumber(0.4, 0.55), Enum.EasingStyle.Quad), {
					Transparency = 1
				})
				task.wait(RandomNumber(0.1, 0.178))
			until v5 == true
		end)
	end

	task.spawn(FirstEvent)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodSlayer.LandEvent(p)
	local char = p.Data.Char
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function LandEvent()
		local v4 = object._maid:give(script.LandEventVfx:Clone())
		game.Debris:AddItem(v4, 7)
		v4:PivotTo(char:GetPivot() * v4:GetAttribute("Offset"):Inverse())
		v4.Parent = game.Workspace.Thrown
		v2.Emitt(v4.FirstSlam)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
		task.spawn(function()
			for _ = 1, 21 do
				local cFrame = v4.FirstSlam.Part.CFrame * CFrame.new(
					Random.new():NextNumber(-15, 15),
					0,
					RandomNumber(-15, 15)
				)
				local raycastResult = game.Workspace:Raycast(cFrame.Position, createVector(0, -15, 0), raycastParams)

				if not raycastResult then
					continue
				end

				local clone = script.Spec:Clone()
				task.delay(5, function()
					if clone and clone.Parent then
						clone:Destroy()
					end
				end)
				clone.Size = createVector(1, 1, 1) * Random.new():NextNumber(0.65, 1.8)
				clone.Material = raycastResult.Instance.Material
				clone.Color = raycastResult.Instance.Color
				clone.CFrame = cFrame
				clone.Parent = workspace.Thrown
				local position = clone.Position
				local position2 = (clone.CFrame * CFrame.new(
					Random.new():NextNumber(-9, 9),
					Random.new():NextNumber(1, 3),
					RandomNumber(-9, 9)
				)).Position
				local v7 = position2 + Vector3.new(
					Random.new():NextNumber(-4, 4),
					Random.new():NextNumber(6, 15),
					RandomNumber(-4, 4)
				)
				local total = 0
				local v8 = Random.new():NextNumber(15, 110) / 55
				v2.Tween(clone, TweenInfo.new(v8, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Size = createVector(0, 0, 0)
				})
				local renderSteppedConnection = nil
				local RunService = game:GetService("RunService")
				local v10 = clone
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					local v14 = total / v8

					if v14 >= 1 then
						renderSteppedConnection:Disconnect()
						renderSteppedConnection = nil
					elseif v10 and v10.Parent then
						local v15 = v10
						local v19 = 1 - v14
						local v20 = v19 ^ 2 * position + v19 * 2 * v14 * v7 + v14 ^ 2 * position2
						local v21 = v14 + 0.01
						local v25 = 1 - v21
						v15.CFrame = CFrame.lookAt(v20, v25 ^ 2 * position + v25 * 2 * v21 * v7 + v21 ^ 2 * position2)
						total += dt
					else
						renderSteppedConnection:Disconnect()
						renderSteppedConnection = nil
					end
				end)
				task.delay(7, function()
					if renderSteppedConnection then
						renderSteppedConnection:Disconnect()
					end
				end)
			end
		end)
		v4.FirstSlam.Part.PointLight.Brightness = 4
		v2.Tween(v4.FirstSlam.Part.PointLight, TweenInfo.new(2.4, Enum.EasingStyle.Quint), {
			Brightness = 0
		})
	end

	task.spawn(LandEvent)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodSlayer.RushEvent(p)
	local char = p.Data.Char
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function RushEvent()
		local v4 = object._maid:give(script.RushEventVfx:Clone())
		v4:PivotTo(char:GetPivot() * v4:GetAttribute("Offset"):Inverse())
		v4.Parent = game.Workspace.Thrown

		for _, emitter in pairs(v4.Rush:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				emitter:SetAttribute("EmitDelay", emitDelay * 0.5)
			end
		end

		v2.Emitt(v4.Rush)
		local v5 = AfterImages.new(char, workspace.Camera, {
			LifeTime = 0.7,
			StartColor = Color3.fromRGB(255, 93, 96),
			EndColor = Color3.fromRGB(0, 0, 0),
			StartTransparency = 0.35,
			TimeBetween = 0.17
		})
		v5:Toggle(true)
		task.delay(0.5, function()
			v5:Destroy()
		end)
		PseudoWeld(v4.Rush.Add, char.HumanoidRootPart, 1.5) -- equivalent call inferred; original call site unknown
		task.wait(0.02)
		v2.MeshFlipbook(script.WindMesh.Decal, v.WindBurst, 0.018)
		local clone = script.WindMesh1:Clone()
		v2.Debris(clone, 1)
		clone.Parent = workspace.Thrown
		clone.Decal.Transparency = 0
		local tweenInfo = TweenInfo.new(0.133, Enum.EasingStyle.Sine)
		v2.Tween(clone.Decal, tweenInfo, {
			Transparency = 1
		})
		v2.Tween(clone, tweenInfo, {
			CFrame = clone.CFrame * CFrame.new(0, 0, -10)
		})
		v2.Tween(clone.Mesh, tweenInfo, {
			Scale = createVector(11.732, 3.732, 17.039)
		})
		task.wait(0.2625)
		v4.Rush.Windd.Attachment.Position = createVector(-1.49, -0.372, 20.431)
		v4.Rush.Windd.Attachment2.Position = createVector(0.883, -0.372, 20.55)
		v2.Tween(v4.Rush.Windd.Attachment, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
			Position = Vector3.new(v4.Rush.Windd.Attachment.Position.X, v4.Rush.Windd.Attachment.Position.X, -8.25)
		})
		v2.Tween(v4.Rush.Windd.Attachment2, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
			Position = Vector3.new(v4.Rush.Windd.Attachment2.Position.X, v4.Rush.Windd.Attachment2.Position.X, -7)
		})

		for _, beam in v4.Rush.Windd:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			v2.Tween(beam, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Brightness = 1.15
			})
			local v7 = beam
			task.delay(0.15, function()
				v2.Tween(v7, TweenInfo.new(0.45, Enum.EasingStyle.Sine), {
					Brightness = 0
				})
			end)
		end

		task.spawn(function()
			for _ = 1, 4 do
				local randomNumber = RandomNumber(0.33, 0.6) -- equivalent call inferred; original call site unknown
				local clone2 = script.SwirlMesh:Clone()
				v2.Debris(clone2, 1.5)
				clone2:PivotTo(char.HumanoidRootPart.CFrame * CFrame.new(0, -0.5, -12) * CFrame.Angles(
					0,
					-1.5707963267948966,
					0
				))
				clone2.CFrame *= CFrame.Angles(math.rad((Random.new():NextNumber(-180, 180))), 0, 0)
				clone2.Parent = workspace.Thrown
				v2.Tween(clone2, TweenInfo.new(randomNumber, Enum.EasingStyle.Quad), {
					CFrame = clone2.CFrame * CFrame.new(Random.new():NextNumber(4, 9), 0, 0) * CFrame.Angles(
						math.rad((Random.new():NextNumber(100, 170))),
						0,
						0
					)
				})
				v2.Tween(clone2.Mesh, TweenInfo.new(randomNumber, Enum.EasingStyle.Cubic), {
					Scale = createVector(3.311, 3, 3)
				})
				v2.MeshFlipbook(clone2.Decal, v.RushWind, RandomNumber(0.014, 0.0175))
				task.wait(0.08)
			end
		end)
		task.wait(0.1)
		v4.Rush.FlipBeams.Attachment1.Position = createVector(-3.59, -0.963, 13.189)
		v4.Rush.FlipBeams.Attachment3.Position = createVector(3.59, -0.963, 13.118)
		v2.Tween(v4.Rush.FlipBeams.Attachment1, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {
			Position = createVector(-5.701, -0.963, 13.189)
		})
		v2.Tween(v4.Rush.FlipBeams.Attachment3, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {
			Position = createVector(5.701, -0.963, 13.118)
		})

		for _, beam in v4.Rush.FlipBeams:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Width0 = 0
			beam.Width1 = 0
			v2.Tween(beam, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
				Width0 = 0.4,
				Width1 = 3
			})
			v2.MeshFlipbook(beam, v.FlipB, 0.011)
		end
	end

	task.spawn(RushEvent)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodSlayer.ArmPart(p)
	local data = p.Data
	local char = data.Char
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v4 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim

	local function ArmPart()
		local v5 = object._maid:give(script.ArmPartVfx:Clone())
		v5:PivotTo(char:GetPivot() * v5:GetAttribute("Offset"):Inverse())
		v5.Name = "REAL VFX"
		v5.Parent = game.Workspace.Thrown
		local charge1 = v5.Charge1
		v2.Emitt(v5.Charge1)
		local v6 = { charge1 }

		for _, v7 in pairs({ charge1.H }) do
			v7.Parent = char.Head
			playAttachment(v7)
			game.Debris:AddItem(v7, 6)
		end

		charge1:Destroy()
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 5 do
				for _, v7 in pairs(v6) do
					v7:PivotTo(char:GetPivot() * v7:GetAttribute("Offset"):Inverse())
				end

				task.wait(0.05)
			end
		end)

		if v4 then
			task.delay(2.1, function()
				char:FindFirstChild("CamRig")
				task.spawn(function()
					local lastTime = tick()

					while tick() - lastTime < 5 do
						v5.NiceP.CameraBeam.CFrame = camera.CFrame * CFrame.new(0, 0, -0.1)
						v5.NiceP.CameraBeam.Anchored = true
						local RunService = game:GetService("RunService")
						RunService.RenderStepped:Wait()
					end
				end)

				for _, beam in v5.NiceP.CameraBeam.C:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					v2.Tween(beam, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Width0 = 0.7,
						Width1 = 0.7
					})
					local v7 = beam
					task.delay(1.15, function()
						v2.Tween(v7, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Width0 = 0,
							Width1 = 0
						})
					end)
				end
			end)
		end
	end

	task.spawn(ArmPart)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodSlayer.AfterCharge(p)
	local data = p.Data
	local char = data.Char
	local victim = data.Victim
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v4 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim

	local function AfterCharge()
		local v5 = object._maid:give(script.AfterChargeVfx:Clone())
		v5:PivotTo(char:GetPivot() * v5:GetAttribute("Offset"):Inverse())
		v5.Name = "aftercharge"
		v5.Parent = game.Workspace.Thrown

		for _, v6 in pairs({
			v5.BarragePart.ArmBeam,
			v5.Charge1.ArmTrails.LeftArmT,
			v5.Hits.T.Part,
			v5.NiceP.T
		}) do
			local weld = Instance.new("Weld")
			weld.Part0 = v6
			weld.Part1 = char["Left Arm"]
			weld.Parent = v6
		end

		for _, v6 in pairs({
			v5.NiceP.Eh,
			v5.Charge1.ArmTrails.RightArmT,
			v5.UpperCut.ArmAura,
			v5.Hits.T.Part2
		}) do
			local weld = Instance.new("Weld")
			weld.Part0 = v6
			weld.Part1 = char["Right Arm"]
			weld.Parent = v6
		end

		v2.Emitt(v5.BarragePart.A)

		if v4 then
			local clone = script.Vignetta:Clone()
			clone.Parent = game.Players.LocalPlayer.PlayerGui
			game.Debris:AddItem(clone, 8)
			clone.ImageLabel.Visible = true
			clone.ImageLabel.ImageTransparency = 1
			v2.Tween(clone.ImageLabel, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
				ImageTransparency = 0
			})
			task.delay(0.455, function()
				v2.Tween(clone.ImageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					ImageTransparency = 1
				})
			end)
			v2.Tween(v5.Sphere1, TweenInfo.new(1, Enum.EasingStyle.Cubic), {
				Transparency = 1
			})
			EnableSceneLight(v5.LightForCharge, false)
		end

		for _, beam in v5.BarragePart.ArmBeam:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Transparency = beam:GetAttribute("Tra")
			BoatTween:Create(beam, {
				Time = 1,
				EasingStyle = "Quint",
				EasingDirection = "In",
				Reverses = false,
				DelayTime = 0,
				RepeatCount = 0,
				StepType = "Heartbeat",
				Goal = {
					Transparency = NumberSequence.new(1)
				}
			}):Play()
		end

		task.wait(0.645)
		v2.Emitt(v5.BarragePart.Part)
		local v6 = false
		task.delay(1.75, function()
			v6 = true
		end)
		task.spawn(function()
			repeat
				local clone = v5.BarragePart.WindTest:Clone()
				v2.Debris(clone, 1)
				local randomNumber = RandomNumber(0, 0.026) -- equivalent call inferred; original call site unknown

				if math.random(0, 1) == 1 then
					clone.Mesh.Scale = Vector3.new(-4.7, Random.new():NextNumber(2.5, 5), RandomNumber(4, 6))
					clone.PivotOffset = CFrame.new(-3.241, 0, 0)
					clone:PivotTo(char.HumanoidRootPart.CFrame * CFrame.new(
						Random.new():NextNumber(-2, 2),
						Random.new():NextNumber(-1, 1),
						RandomNumber(-2, -0.5)
					) * CFrame.Angles(
						math.rad((Random.new():NextNumber(-15, 15))),
						math.rad((Random.new():NextNumber(-15, 75))),
						(math.rad((Random.new():NextNumber(-15, 15))))
					))
				else
					clone.Mesh.Scale = Vector3.new(4.7, Random.new():NextNumber(2.5, 5), RandomNumber(4, 6))
					clone:PivotTo(char.HumanoidRootPart.CFrame * CFrame.new(
						Random.new():NextNumber(-2, 2),
						Random.new():NextNumber(-1, 1),
						RandomNumber(-2, -0.5)
					) * CFrame.Angles(
						math.rad((Random.new():NextNumber(-15, 15))),
						math.rad((Random.new():NextNumber(-75, 15))),
						(math.rad((Random.new():NextNumber(-15, 15))))
					))
				end

				clone.Parent = workspace.Thrown
				v2.MeshFlipbook(clone.Decal, v.BarrageWind, randomNumber)
				v2.Tween(clone.Decal, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 0.96
				})
				v2.Tween(clone.Mesh, TweenInfo.new(Random.new():NextNumber(0.15, 0.17), Enum.EasingStyle.Sine), {
					Scale = clone.Mesh.Scale * Random.new():NextNumber(1.1, 1.4)
				})
				task.wait(0.08)
			until v6 == true
		end)
		task.spawn(function()
			repeat
				local v7 = victim.HumanoidRootPart.CFrame * CFrame.new(
					Random.new():NextNumber(-2.5, 2.5),
					Random.new():NextNumber(-2.5, 2.5),
					0
				)
				local clone = v5.BarragePart.ArmPresset:Clone()
				v2.Debris(clone, 2)
				clone.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(
					Random.new():NextNumber(-5, 5),
					Random.new():NextNumber(-2, 3.5),
					RandomNumber(-1, 4)
				) * CFrame.Angles(
					1.5707963267948966,
					math.rad((Random.new():NextNumber(-20, 20))),
					(math.rad((Random.new():NextNumber(-20, 20))))
				)
				clone.Parent = workspace.Thrown
				local position = clone.Position
				local position2 = v7.Position
				local position3 = (v7 * CFrame.new(
					Random.new():NextNumber(-4, 4),
					Random.new():NextNumber(-3, 3),
					RandomNumber(-3, 1)
				)).Position
				local total = 0
				local v8 = Random.new():NextNumber(10, 18) / 155
				local clone2 = v5.BarragePart.HitVfx:Clone()
				v2.Debris(clone2, 1.5)
				clone2:PivotTo(v7 * CFrame.Angles(
					math.rad((Random.new():NextNumber(-30, 30))),
					math.rad((Random.new():NextNumber(-30, 30))),
					(math.rad((Random.new():NextNumber(-30, 30))))
				))
				clone2.Parent = workspace.Thrown
				v2.Emitt(clone2)
				local heartbeatConnection = nil
				local RunService = game:GetService("RunService")
				local folder = clone
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					local v13 = total / v8

					if v13 >= 1 then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end

					folder.Transparency = v13 + 0.1

					for i, decal in folder:GetDescendants() do
						if not decal:IsA("Decal") then
							continue
						end

						if decal.Parent.Name == "Add" then
							decal.Transparency = v13 - 2
						end

						decal.Transparency = v13 + 0
					end

					local v14 = folder
					local v18 = 1 - v13
					local v19 = v18 ^ 2 * position + v18 * 2 * v13 * position3 + v13 ^ 2 * position2
					local v20 = v13 + 0.01
					local v24 = 1 - v20
					v14.CFrame = CFrame.lookAt(
						v19,
						v24 ^ 2 * position + v24 * 2 * v20 * position3 + v20 ^ 2 * position2
					) * CFrame.Angles(1.5707963267948966, 1.5707963267948966, 0)
					total += dt
				end)
				task.wait(0.025)
			until v6 == true
		end)
	end

	task.delay(2.6, function()
		GodSlayer.PrePunchPose({
			Char = char,
			Victim = victim
		})
	end)
	task.spawn(AfterCharge)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodSlayer.PrePunchPose(p)
	local char = p.Char
	local victim = p.Victim
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
	local v3 = game.Players.LocalPlayer.Character == p.Char or game.Players.LocalPlayer.Character == p.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v4 = object._maid:give(script.PrePunchPoseVfx:Clone())
	v4:PivotTo(char:GetPivot() * v4:GetAttribute("Offset"):Inverse())
	v4.Name = "PrePunchPose"
	v4.Parent = game.Workspace.Thrown
	local v5 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v5 then
			v5 = true
			object._maid:doCleaning()
		end
	end

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	task.spawn(function()
		local lastTime = tick()

		while tick() - lastTime < 5 do
			v4.NiceP.CameraBeam.CFrame = camera.CFrame * CFrame.new(0, 0, -0.1)
			v4.NiceP.CameraBeam.Anchored = true
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
		end
	end)

	for _, v6 in pairs({
		v4.BarragePart.ArmBeam,
		v4.Charge1.ArmTrails.LeftArmT,
		v4.Hits.T.Part,
		v4.NiceP.T
	}) do
		local weld = Instance.new("Weld")
		weld.Part0 = v6
		weld.Part1 = char["Left Arm"]
		weld.Parent = v6
	end

	for _, v6 in pairs({ v4.Charge1.H, v4.NiceP.Flare }) do
		local weld = Instance.new("Weld")
		weld.Part0 = v6
		weld.Part1 = char.Head
		weld.Parent = v6
		game.Debris:AddItem(v6, 6)
	end

	for _, v6 in pairs({
		v4.NiceP.Eh,
		v4.Charge1.ArmTrails.RightArmT,
		v4.UpperCut.ArmAura,
		v4.Hits.T.Part2
	}) do
		local weld = Instance.new("Weld")
		weld.Part0 = v6
		weld.Part1 = char["Right Arm"]
		weld.Parent = v6
	end

	v4.NiceP.Roof:PivotTo(char:GetPivot() * v4.NiceP.Roof:GetAttribute("Offset"):Inverse())

	local function PrePunchPose()
		local DELAY_DURATION = 0.9

		for _, beam in v4.NiceP.Eh.B:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			v2.Tween(beam, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Brightness = 1
			})
			local v6 = beam
			task.delay(DELAY_DURATION, function()
				v6.Brightness = 0
			end)
		end

		for _, decal in v4.NiceP.Eh:GetDescendants() do
			if not decal:IsA("Decal") then
				continue
			end

			v2.Tween(decal, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
				Transparency = -1
			})
			local v6 = decal
			task.delay(DELAY_DURATION, function()
				v6.Transparency = 1
			end)
		end

		v2.Emitt(v4.NiceP)

		if v3 then
			local v6 = nil

			for _, child in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
				if child.Name == "Vignetta" then
					v6 = child
				end
			end

			if v6 then
				v6.ImageLabel.ImageTransparency = 0
				v6.ImageLabel.Visible = true
			end

			v4.NiceP.Roof.Transparency = 0
			EnableSceneLight(v4.NiceP, true)
			game.Lighting.ClockTime = 0
			task.delay(DELAY_DURATION, function()
				if v6 then
					v6.ImageLabel.Visible = false
					v6.ImageLabel.ImageTransparency = 1
				end

				game.Lighting.ClockTime = 14.5
				v4.NiceP.Roof.Transparency = 1
				EnableSceneLight(v4.NiceP, false)
			end)
		end
	end

	task.delay(1, function()
		task.spawn(function()
			shared.repfire({
				Effect = "JustMod",
				Mod = "GodAdditions",
				Event = "AnotherP",
				Char = char,
				Victim = victim
			})
		end)
		GodSlayer.AfterP({
			Char = char,
			Victim = victim
		})
	end)
	task.spawn(PrePunchPose)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodSlayer.AfterP(p)
	local data = p.Data
	local char = data.Char
	local victim = data.Victim
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
	local v3 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v4 then
			v4 = true
			object._maid:doCleaning()
		end
	end

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function AfterP()
		local v5 = object._maid:give(script.AfterPVfx:Clone())
		v5:PivotTo(char:GetPivot() * v5:GetAttribute("Offset"):Inverse())
		v5.Name = "AfterP"
		v5.Parent = game.Workspace.Thrown

		if v3 then
			v5.Sphere1.Color = Color3.fromRGB(76, 15, 16)
			v2.Tween(v5.Sphere1, TweenInfo.new(0.225, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Color = Color3.new(0, 0, 0)
			})
		else
			v5.Sphere1:Destroy()
		end

		v5.AfterP:PivotTo(char.PrimaryPart:GetPivot() * v5.AfterP:GetAttribute("Offset"):Inverse())
		task.delay(0.515, function()
			local v6 = false
			task.delay(0.7, function()
				v6 = true
			end)

			repeat
				local randomNumber = RandomNumber(6.5, 8) -- equivalent call inferred; original call site unknown
				local randomNumber2 = RandomNumber(0.0125, 0.016) -- equivalent call inferred; original call site unknown
				local clone = v5.FirstSlam.WindAround:Clone()
				v2.Debris(clone, 2)
				clone.CFrame = victim.HumanoidRootPart.CFrame
				clone.CFrame = CFrame.lookAt(victim.HumanoidRootPart.Position, char.HumanoidRootPart.Position)
				clone.CFrame *= CFrame.Angles(1.5707963267948966, math.rad((math.random(360))), 0)
				clone.Parent = workspace.Thrown
				v2.MeshFlipbook(clone.Decal, v.Wi, randomNumber2)
				v2.Tween(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					CFrame = clone.CFrame * CFrame.new(0, Random.new():NextNumber(-2.5, -1), 0) * CFrame.Angles(
						0,
						math.rad((Random.new():NextNumber(55, 135))),
						0
					)
				})
				v2.Tween(clone.Mesh, TweenInfo.new(0.525, Enum.EasingStyle.Cubic), {
					Scale = Vector3.new(randomNumber, 5.091, randomNumber)
				})
				v2.Tween(clone.Decal, TweenInfo.new(Random.new():NextNumber(0.2, 0.39), Enum.EasingStyle.Sine), {
					Transparency = 1
				})
				task.wait(RandomNumber(0.1, 0.178))
			until v6 == true
		end)
		v2.Emitt(v5.AfterP)

		if v3 then
			v2.Tween(v5.Sphere1, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
				Transparency = 0.15
			})
			task.delay(0.425, function()
				v2.Tween(v5.Sphere1, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
					Transparency = 1
				})
			end)
		end

		task.wait(0.06)
		local v6 = object._maid:give(script.Stuff:Clone())
		v6.Parent = game.Players.LocalPlayer.Character
		v6.Wind.ImageTransparency = 0.2
		v2.Tween(v6.Wind, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			ImageTransparency = 0.85
		})
		ScreenFlip(v6.Wind, v.CameraWind, 0.019) -- equivalent call inferred; original call site unknown
		task.wait(0.44)

		if v3 then
			local v8 = object._maid:give(Instance.new("BlurEffect"))
			v8.Size = 0
			v8.Parent = game.Lighting
			local v9 = object._maid:give(Instance.new("ColorCorrectionEffect"))
			v9.Parent = game.Lighting
			v8.Size = 10
			v9.Brightness = 0.4
			v2.Tween(v9, TweenInfo.new(1, Enum.EasingStyle.Cubic), {
				Brightness = 0
			})
			v2.Tween(v8, TweenInfo.new(0.4, Enum.EasingStyle.Cubic), {
				Size = 0
			})
		end

		for _, beam in v5.AfterP.second.Wind:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Transparency = beam:GetAttribute("Tra")
			beam.TextureSpeed = -5
			BoatTween:Create(beam, {
				Time = 0.55,
				EasingStyle = "Quad",
				EasingDirection = "In",
				Reverses = false,
				DelayTime = 0,
				RepeatCount = 0,
				StepType = "Heartbeat",
				Goal = {
					Transparency = NumberSequence.new(1),
					TextureSpeed = -0.5
				}
			}):Play()
		end

		for _, child in v5.AfterP.second.Beams:GetChildren() do
			child.Brightness = 1
			child.TextureSpeed = 4
			v2.Tween(child, TweenInfo.new(0.6, Enum.EasingStyle.Cubic), {
				Brightness = 0,
				TextureSpeed = 1.675
			})
		end

		task.wait(0.1)
		local clone = v5.AfterP.AddWind:Clone()
		v2.Debris(clone, 2)
		clone.Decal.Transparency = -0.7
		clone.Parent = workspace.Thrown
		v2.Tween(clone.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Transparency = 1
		})
		v2.Tween(clone.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Scale = createVector(3.599, 3.599, 29.053)
		})
	end

	task.spawn(AfterP)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodSlayer.Rush2(p)
	local data = p.Data
	local char = data.Char
	local _ = data.Victim
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v4 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim

	local function Rush2()
		local v5 = object._maid:give(script.Rush2Vfx:Clone())
		v5:PivotTo(char:GetPivot() * v5:GetAttribute("Offset"):Inverse())
		v5.Name = "AfterP"
		v5.Parent = game.Workspace.Thrown
		local weld = Instance.new("Weld")
		weld.Part0 = v5.R2.T
		weld.Part1 = char.Torso
		weld.Parent = v5.R2.T

		if v4 then
			local v6 = object._maid:give(Instance.new("BlurEffect"))
			v6.Size = 0
			v6.Parent = game.Lighting
			local v7 = object._maid:give(Instance.new("ColorCorrectionEffect"))
			v7.Parent = game.Lighting
			v7.Brightness = 0.15
			v2.Tween(v7, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
				Brightness = 0
			})
		end

		v5.R2:PivotTo(char:GetPivot() * v5.R2:GetAttribute("Offset"):Inverse())
		v2.Emitt(v5.R2)
		v5.R2.RM.Decal.Transparency = 0.6
		v2.Tween(v5.R2.RM.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Transparency = 0.85
		})
		v2.MeshFlipbook(v5.R2.RM.Decal, v.ShockWindRush2, 0.015)
		task.wait(0.165)
		local clone = v5.R2.Shoo:Clone()
		v2.Debris(clone, 1)
		clone.Decal.Transparency = 0.25
		clone.Parent = workspace.Thrown
		v2.Tween(clone.Decal, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		v2.Tween(clone.Mesh, TweenInfo.new(0.075, Enum.EasingStyle.Sine), {
			Scale = createVector(3.958, 3.958, 58.124)
		})
		print("RUSH2")
	end

	task.spawn(Rush2)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodSlayer.Hits(p)
	local data = p.Data
	local char = data.Char
	local victim = data.Victim
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function Hits()
		local v4 = object._maid:give(script.HitVfx:Clone())
		v4:PivotTo(char:GetPivot() * v4:GetAttribute("Offset"):Inverse())
		v4.Parent = game.Workspace.Thrown

		for _, part in pairs(v4.Hits:GetChildren()) do
			if not (part:IsA("BasePart") and string.match(string.lower(part.Name), "hit")) then
				continue
			end

			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = victim.Torso
			weld.Parent = part
		end

		raiseZIndex({
			FX = v4.Hits,
			Count = 4
		})
		v2.Emitt(v4.Hits)
		task.delay(0.02, function() end)
		task.wait(0.7051)
		local clone = v4.Hits.Hit2.AddW:Clone()
		v2.Debris(clone, 2)
		clone.Decal.Transparency = 0.5
		clone.Parent = workspace.Thrown
		v2.Tween(clone.Decal, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Transparency = 1
		})
		v2.Tween(clone.Mesh, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Scale = createVector(7.44, 9, 7.44)
		})
		v2.Tween(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			CFrame = clone.CFrame * CFrame.new(0, 8, 0)
		})
		v4.Hits.SpinMesh.Decal.Transparency = 0.2
		v4.Hits.SpinMesh.Mesh.Scale = createVector(-3.186, 3.446, 3.186)
		PseudoWeld(v4.Hits.SpinMesh, char.HumanoidRootPart, 2) -- equivalent call inferred; original call site unknown
		v2.Tween(v4.Hits.SpinMesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Scale = v4.Hits.SpinMesh.Mesh.Scale * 1.3
		})
		v2.Tween(v4.Hits.SpinMesh.Decal, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			Transparency = 0.96
		})
		v2.MeshFlipbook(v4.Hits.SpinMesh.Decal, v.Spin, 0.018)
		task.wait(0.1425)
		v4.Hits.SpinMesh2.Decal.Transparency = 0.3
		v4.Hits.SpinMesh2.Mesh.Scale = createVector(-3.4, 4, 3.4)
		PseudoWeld(v4.Hits.SpinMesh2, char.HumanoidRootPart, 2) -- equivalent call inferred; original call site unknown
		v2.MeshFlipbook(v4.Hits.SpinMesh2.Decal, v.Spin2, 0.015)
		v2.Tween(v4.Hits.SpinMesh2, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			PivotOffset = v4.Hits.SpinMesh2.PivotOffset * CFrame.Angles(0, -3.141592653589793, 0)
		})
		task.wait(0.1)
		v4.Hits.SpinMesh3.Decal.Transparency = 0.35
		v4.Hits.SpinMesh3.Mesh.Scale = createVector(-7.465, 5.313, 7.465)
		PseudoWeld(v4.Hits.SpinMesh3, char.HumanoidRootPart, 2) -- equivalent call inferred; original call site unknown
		v2.MeshFlipbook(v4.Hits.SpinMesh3.Decal, v.Spin3, 0.0135)
		v2.Tween(v4.Hits.SpinMesh3.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Transparency = 0.91
		})
		v2.Tween(v4.Hits.SpinMesh3, TweenInfo.new(0.425, Enum.EasingStyle.Quad), {
			PivotOffset = v4.Hits.SpinMesh3.PivotOffset * CFrame.Angles(0, -2.792526803190927, 0)
		})
	end

	task.spawn(Hits)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

return GodSlayer