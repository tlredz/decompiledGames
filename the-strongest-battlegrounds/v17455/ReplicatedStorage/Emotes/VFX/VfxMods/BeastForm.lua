local BeastForm = {}
local library = require(game.ReplicatedStorage.library)
local _ = library.PlayAttachment
local _ = library.Maid
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
local _ = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local FrameEvents = require(script.FrameEvents)
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local v = {
	Seq_45 = {
		"rbxassetid://108285947966603",
		"rbxassetid://138775004464946",
		"rbxassetid://73736852422883",
		"rbxassetid://81444189681810",
		"rbxassetid://106648011511243",
		"rbxassetid://103360239940705",
		"rbxassetid://92184651511149",
		"rbxassetid://133698056948393",
		"rbxassetid://74955605635815",
		"rbxassetid://121108118549772",
		"rbxassetid://84789007345423",
		"rbxassetid://111633158446520",
		"rbxassetid://74144921042348",
		"rbxassetid://132180670086164",
		"rbxassetid://102497194311640",
		"rbxassetid://103103526051490",
		"rbxassetid://120252015591777",
		"rbxassetid://136586054743554",
		"rbxassetid://129577343204910",
		"rbxassetid://134313791654887",
		"rbxassetid://96309819053698",
		"rbxassetid://97220452391835",
		"rbxassetid://96693309257286",
		"rbxassetid://127806398454535",
		"rbxassetid://87052266888745",
		"rbxassetid://103312242996355",
		"rbxassetid://104863832529981",
		"rbxassetid://113801843914333",
		"rbxassetid://73924285036954",
		"rbxassetid://136502046207469",
		"rbxassetid://99629312435998",
		"rbxassetid://77070622688208",
		"rbxassetid://96181548360674",
		"rbxassetid://130554620867202",
		"rbxassetid://114454206288356",
		"rbxassetid://125350671592776",
		"rbxassetid://136905364337445",
		"rbxassetid://81114596119798",
		"rbxassetid://96250067577462",
		"rbxassetid://72997196277188",
		"rbxassetid://90885352062147",
		"rbxassetid://83404165743171",
		"rbxassetid://101562784382829",
		"rbxassetid://71508583145880",
		"rbxassetid://139039239492215",
		"rbxassetid://140280486852692",
		"rbxassetid://87898583191372",
		"rbxassetid://111684683928405",
		"rbxassetid://127446600464924",
		"rbxassetid://132944272929894",
		"rbxassetid://126335230164846",
		"rbxassetid://97505641909626",
		"rbxassetid://110485310699190",
		"rbxassetid://111834686060875",
		"rbxassetid://87359294690453",
		"rbxassetid://76903358866613",
		"rbxassetid://137668899182098",
		"rbxassetid://84300253190926",
		"rbxassetid://101309727529461",
		"rbxassetid://75594854637611",
		"rbxassetid://96100330853041",
		"rbxassetid://72215966979260",
		"rbxassetid://77141242413517",
		"rbxassetid://79189522142687",
		"rbxassetid://109641905496454",
		"rbxassetid://76659116724046",
		"rbxassetid://114367455419385",
		"rbxassetid://99333597342253",
		"rbxassetid://129479539698707",
		"rbxassetid://98651541235920",
		"rbxassetid://112726897332094",
		"rbxassetid://105269002654991",
		"rbxassetid://117447714689581",
		"rbxassetid://99075874441768",
		"rbxassetid://126189377895157",
		"rbxassetid://125712571799543",
		"rbxassetid://73192377637766",
		"rbxassetid://89681390875154",
		"rbxassetid://99940737119536",
		"rbxassetid://114001076181895",
		"rbxassetid://97452710936930",
		"rbxassetid://83194176349286",
		"rbxassetid://86054561316837",
		"rbxassetid://123327441595511",
		"rbxassetid://74001102789537",
		"rbxassetid://118368976381705",
		"rbxassetid://97692051630969",
		"rbxassetid://111269363497059",
		"rbxassetid://102984138707789",
		"rbxassetid://110505298457708",
		"rbxassetid://109429707892239",
		"rbxassetid://124308872287408",
		"rbxassetid://75422008633447",
		"rbxassetid://116799369400804",
		"rbxassetid://93053895597889",
		"rbxassetid://137893741095668",
		"rbxassetid://77243401788539",
		"rbxassetid://121339401917700",
		"rbxassetid://129260671373927",
		"rbxassetid://78239330255845",
		"rbxassetid://106686900482318",
		"rbxassetid://117541964459028",
		"rbxassetid://121244402203708",
		"rbxassetid://96785676049227",
		"rbxassetid://72161306836623",
		"rbxassetid://139656007186356",
		"rbxassetid://103342256278575",
		"rbxassetid://90279460809318"
	},
	Seq_60_1 = {
		"rbxassetid://116670628992318",
		"rbxassetid://83720885827014",
		"rbxassetid://131743511063804",
		"rbxassetid://137367139749520",
		"rbxassetid://130327046069332",
		"rbxassetid://107569586631027",
		"rbxassetid://133708846577761",
		"rbxassetid://81642104265803",
		"rbxassetid://106379579808980",
		"rbxassetid://101407813936503",
		"rbxassetid://116578034932621",
		"rbxassetid://86993758818358",
		"rbxassetid://117364252087440",
		"rbxassetid://86541785714463",
		"rbxassetid://96784307534003",
		"rbxassetid://90842001788076",
		"rbxassetid://100756812879925",
		"rbxassetid://85017014292797",
		"rbxassetid://136112336713740",
		"rbxassetid://99637909703369",
		"rbxassetid://113056711018479",
		"rbxassetid://133586872249697",
		"rbxassetid://116484176849731",
		"rbxassetid://131143345443696",
		"rbxassetid://102803401347680",
		"rbxassetid://88468225882369",
		"rbxassetid://93291400281497",
		"rbxassetid://107228408581928",
		"rbxassetid://103492395055179",
		"rbxassetid://136393488499486",
		"rbxassetid://121961104568201",
		"rbxassetid://85920400986950",
		"rbxassetid://89537588678835",
		"rbxassetid://137199270800619",
		"rbxassetid://124806613553064",
		"rbxassetid://111863263955436",
		"rbxassetid://90025975588114",
		"rbxassetid://72470253318441",
		"rbxassetid://136411585245520",
		"rbxassetid://78482619120365",
		"rbxassetid://129571516425846",
		"rbxassetid://87715500819032",
		"rbxassetid://106682509536151",
		"rbxassetid://109244865328268",
		"rbxassetid://79615421415179",
		"rbxassetid://136561265645909",
		"rbxassetid://71868845668648",
		"rbxassetid://88420554749858",
		"rbxassetid://84900033655805",
		"rbxassetid://77909429862375",
		"rbxassetid://121396255383851",
		"rbxassetid://99695409592740",
		"rbxassetid://127296667094466",
		"rbxassetid://121467344603700",
		"rbxassetid://109483938339067",
		"rbxassetid://73296255181155",
		"rbxassetid://80935616543983",
		"rbxassetid://133953568904828",
		"rbxassetid://105676298892428",
		"rbxassetid://127129168794218",
		"rbxassetid://105896293486264",
		"rbxassetid://124197072352796",
		"rbxassetid://103491694123134",
		"rbxassetid://105054339422738",
		"rbxassetid://85128442056695",
		"rbxassetid://109763658316017",
		"rbxassetid://117300026615754",
		"rbxassetid://137384915425210",
		"rbxassetid://72960180494621",
		"rbxassetid://140723514802539",
		"rbxassetid://106663516224865",
		"rbxassetid://140622225852531",
		"rbxassetid://90850650804590",
		"rbxassetid://89798870211786",
		"rbxassetid://93386305682641",
		"rbxassetid://95018990892922",
		"rbxassetid://84626947411701",
		"rbxassetid://70607195460989",
		"rbxassetid://95998082868243",
		"rbxassetid://71877437043387",
		"rbxassetid://137192544507394",
		"rbxassetid://133460116471119",
		"rbxassetid://71945220281135",
		"rbxassetid://134860979593290",
		"rbxassetid://137273290244081",
		"rbxassetid://74687836793665",
		"rbxassetid://116460858542350",
		"rbxassetid://124176897190345",
		"rbxassetid://129977328184442",
		"rbxassetid://110372128375742",
		"rbxassetid://90489148367811",
		"rbxassetid://123805870822714",
		"rbxassetid://79644942659199",
		"rbxassetid://91055688694398",
		"rbxassetid://114055543670965",
		"rbxassetid://83941831211371",
		"rbxassetid://101560554613810",
		"rbxassetid://78553830073535",
		"rbxassetid://117241732589707",
		"rbxassetid://98532452118492",
		"rbxassetid://83243039547820",
		"rbxassetid://83378153529377",
		"rbxassetid://83842428894614",
		"rbxassetid://139165656596261",
		"rbxassetid://108016527802287",
		"rbxassetid://87980721871838",
		"rbxassetid://111274023534634",
		"rbxassetid://89860837263265"
	},
	Seq_60_2 = {
		"rbxassetid://90558300672641",
		"rbxassetid://117220805157599",
		"rbxassetid://119756750502635",
		"rbxassetid://100737996520940",
		"rbxassetid://72507982221638",
		"rbxassetid://122355882467381",
		"rbxassetid://118178727367578",
		"rbxassetid://115891359771453",
		"rbxassetid://93919060609302",
		"rbxassetid://81222428658515",
		"rbxassetid://119787946634448",
		"rbxassetid://134005453256275",
		"rbxassetid://83651238206764",
		"rbxassetid://95652310359192",
		"rbxassetid://107954384829716",
		"rbxassetid://106321563006772",
		"rbxassetid://84398124537779",
		"rbxassetid://115938068153334",
		"rbxassetid://121005354791943",
		"rbxassetid://80859140831009",
		"rbxassetid://128914276388715",
		"rbxassetid://125286132445091",
		"rbxassetid://106714150153302",
		"rbxassetid://108258976187166",
		"rbxassetid://140498487553550",
		"rbxassetid://104694272944006",
		"rbxassetid://80050707568149",
		"rbxassetid://121145962034572",
		"rbxassetid://77787226936188",
		"rbxassetid://127056841422188",
		"rbxassetid://82249253273797",
		"rbxassetid://97907410486356",
		"rbxassetid://128595762574962",
		"rbxassetid://82149703473008",
		"rbxassetid://76193570282710",
		"rbxassetid://105873332045927",
		"rbxassetid://110333031577535",
		"rbxassetid://110540769321408",
		"rbxassetid://127035220213198",
		"rbxassetid://116806609967320",
		"rbxassetid://97312673431502",
		"rbxassetid://127564379931374",
		"rbxassetid://88371881304727",
		"rbxassetid://88799776935900",
		"rbxassetid://108186328459042",
		"rbxassetid://110976313543249",
		"rbxassetid://109934919488768",
		"rbxassetid://94318532123466",
		"rbxassetid://128259240300048",
		"rbxassetid://100643642461319",
		"rbxassetid://136455636585632",
		"rbxassetid://72719019716334",
		"rbxassetid://102570699931819",
		"rbxassetid://94840127619230",
		"rbxassetid://84298844854548",
		"rbxassetid://107830765115391",
		"rbxassetid://135159376188726",
		"rbxassetid://83111665077924",
		"rbxassetid://93666819534623",
		"rbxassetid://96945976624145",
		"rbxassetid://110143132274198",
		"rbxassetid://74352046399316",
		"rbxassetid://113948519801480",
		"rbxassetid://79781975365147",
		"rbxassetid://124485959628696",
		"rbxassetid://106517031980992",
		"rbxassetid://117736729247305",
		"rbxassetid://109170175071724",
		"rbxassetid://130545380652055",
		"rbxassetid://129069242488739",
		"rbxassetid://99087383424877",
		"rbxassetid://118700637128409",
		"rbxassetid://84998575641541",
		"rbxassetid://89765152982044",
		"rbxassetid://113687400989286",
		"rbxassetid://135987856012873",
		"rbxassetid://117134033033306",
		"rbxassetid://98726968278055",
		"rbxassetid://88599987740726",
		"rbxassetid://94169226223978",
		"rbxassetid://80451468992697",
		"rbxassetid://90105014683760",
		"rbxassetid://135784946390369",
		"rbxassetid://124376370498165",
		"rbxassetid://122497409109460",
		"rbxassetid://108551394523494",
		"rbxassetid://105548808666391",
		"rbxassetid://128391272366756",
		"rbxassetid://139290512919054",
		"rbxassetid://71967661606849",
		"rbxassetid://98302888231205",
		"rbxassetid://83698394723913",
		"rbxassetid://138864222718059",
		"rbxassetid://131833777148379",
		"rbxassetid://78443281024277",
		"rbxassetid://133882150290535",
		"rbxassetid://110013324861031",
		"rbxassetid://124704527929112",
		"rbxassetid://76162277894676",
		"rbxassetid://115836623512589",
		"rbxassetid://91719802532928",
		"rbxassetid://88427372687838",
		"rbxassetid://115478359540824",
		"rbxassetid://78840750654050",
		"rbxassetid://79845520805983",
		"rbxassetid://85118795373274",
		"rbxassetid://73208204227798",
		"rbxassetid://126450773239339"
	},
	Seq_372 = {
		"rbxassetid://128554687417867",
		"rbxassetid://104928075900591",
		"rbxassetid://133847901887141",
		"rbxassetid://111974130655268",
		"rbxassetid://84398671256061",
		"rbxassetid://95055711164604",
		"rbxassetid://94849061716533",
		"rbxassetid://81975338214051",
		"rbxassetid://106329346403629",
		"rbxassetid://134829122181149",
		"rbxassetid://137738293486628",
		"rbxassetid://91825765985451",
		"rbxassetid://117135422202840",
		"rbxassetid://99955236294611",
		"rbxassetid://73774542585681",
		"rbxassetid://76612218582724",
		"rbxassetid://91973147901337",
		"rbxassetid://101004128405791",
		"rbxassetid://89245487594421",
		"rbxassetid://136895745991815",
		"rbxassetid://95630416871255",
		"rbxassetid://124922551188061",
		"rbxassetid://120339769876791",
		"rbxassetid://100045208872720",
		"rbxassetid://82456689924026",
		"rbxassetid://79049379876529",
		"rbxassetid://120464871813363",
		"rbxassetid://124051597694314",
		"rbxassetid://93550354178294",
		"rbxassetid://77694597458568",
		"rbxassetid://120550304706787",
		"rbxassetid://79724512955023",
		"rbxassetid://126597398998342",
		"rbxassetid://86592163366625",
		"rbxassetid://109091184626714",
		"rbxassetid://71160277307993",
		"rbxassetid://101907082392130",
		"rbxassetid://71010705000100",
		"rbxassetid://83113444838899",
		"rbxassetid://82226168281449",
		"rbxassetid://94205449263792",
		"rbxassetid://73692191314245",
		"rbxassetid://89131889068753",
		"rbxassetid://106044773175523",
		"rbxassetid://92766673448350",
		"rbxassetid://99035738263930",
		"rbxassetid://90375437821315",
		"rbxassetid://78164568823781"
	},
	Seq_490 = {
		"rbxassetid://117005728578806",
		"rbxassetid://130294676452476",
		"rbxassetid://91326643479183",
		"rbxassetid://89750057630696",
		"rbxassetid://116831143232273",
		"rbxassetid://135435525279572",
		"rbxassetid://113192759106525",
		"rbxassetid://103056455013432",
		"rbxassetid://82343454269861",
		"rbxassetid://91636603804088",
		"rbxassetid://104344395256059",
		"rbxassetid://119947909952978",
		"rbxassetid://104964945138787",
		"rbxassetid://110441739976182",
		"rbxassetid://90944055091504",
		"rbxassetid://125617240940801",
		"rbxassetid://93096440354654",
		"rbxassetid://104763113774794",
		"rbxassetid://83999489992125",
		"rbxassetid://108023658164857",
		"rbxassetid://132414163602268",
		"rbxassetid://102072257799131",
		"rbxassetid://129952781950426",
		"rbxassetid://106244327826380",
		"rbxassetid://86160250724689",
		"rbxassetid://110634017183467",
		"rbxassetid://84727656841919",
		"rbxassetid://109591065006295",
		"rbxassetid://113103271373320",
		"rbxassetid://104052470360636",
		"rbxassetid://115737310960709",
		"rbxassetid://102659465142895",
		"rbxassetid://103368799708060",
		"rbxassetid://111408053639423",
		"rbxassetid://107453526427966",
		"rbxassetid://77073896278400",
		"rbxassetid://92069475350947",
		"rbxassetid://72705448072099",
		"rbxassetid://96818371808271",
		"rbxassetid://83565093453199",
		"rbxassetid://123190225097314",
		"rbxassetid://92431991941655",
		"rbxassetid://111489231510562",
		"rbxassetid://81930756798026",
		"rbxassetid://104955932892539",
		"rbxassetid://110747090630504"
	}
}

function BeastForm.FirstEvent(data)
	local char = data.Char
	local _ = char == game.Players.LocalPlayer.Character
	local _ = data.CleanupTable
	local realAnim = data.RealAnim
	local bind = data.Bind

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancontinue()
		if realAnim and realAnim.IsPlaying and bind and bind.Parent then
			return true
		end

		return false
	end

	local parentChangedConnection = nil
	local v2 = false
	local fn
	local v3 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true

			if v3 then
				v3:Destroy("")
			end

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
			end

			if fn then
				fn()
			end
		end
	end

	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		Clean() -- equivalent call inferred; original call site unknown
		return parentChangedConnection:Disconnect()
	end)
	task.delay(20, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	if not cancontinue() then
		return
	end

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local Workspace = game:GetService("Workspace")
	local Lighting = game:GetService("Lighting")
	local localPlayer = Players.LocalPlayer
	local currentCamera = Workspace.CurrentCamera
	local S_FOV = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
	local v4 = char == localPlayer.Character
	local v5 = {
		connections = {},
		animations = {},
		objects = {},
		tweens = {},
		particles = {},
		beams = {},
		trails = {},
		lights = {}
	}
	local flag = false
	local v6 = 0
	local v7 = -1
	local flag2 = false
	local colorCorrectionEffect = nil

	local function trackParticleEffect(instance)
		if instance:IsA("ParticleEmitter") then
			table.insert(v5.particles, instance)
		elseif instance:IsA("Beam") then
			table.insert(v5.beams, instance)
		elseif instance:IsA("Trail") then
			table.insert(v5.trails, instance)
		elseif instance:IsA("PointLight") then
			table.insert(v5.lights, instance)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function executeFrameEvents(p, p2)
		local v8 = math.floor(p + 0.5)

		if v8 ~= v7 and FrameEvents.frameEvents[v8] then
			local success, result = pcall(FrameEvents.frameEvents[v8], p2)

			if not success then
				warn("Frame event error at frame", v8, ":", result)
			end

			v7 = v8
		end
	end

	local function getCurrentFrame(p)
		return p * 60
	end

	local function interpolateValue(items, p, p2)
		if not (items and next(items)) then
			return nil
		end

		local v8 = nil
		local v9 = nil
		local v10 = nil
		local v11 = nil

		for k, item in pairs(items) do
			if k <= p and (not v8 or v8 < k) then
				v10 = item
				v8 = k
			end

			if not (p <= k and (not v9 or k < v9)) then
				continue
			end

			v11 = item
			v9 = k
		end

		if v8 == v9 or not (v8 and v9) then
			return v10 or v11
		end

		local v12 = (p - v8) / (v9 - v8)

		if p2 == "Color3" then
			return v10:lerp(v11, v12)
		elseif p2 == "number" then
			return v10 + (v11 - v10) * v12
		end

		if p2 == "boolean" then
		end

		return v11
	end

	local function updateBrightness(p)
		if not FrameEvents.brightnessKeyframes then
			return
		end

		local brightness = interpolateValue(FrameEvents.brightnessKeyframes, p, "number")

		if brightness then
			Lighting.Brightness = brightness
		end
	end

	local function updateColorCorrection(p)
		if not FrameEvents.colorCorrectionKeyframes then
			return
		end

		if not colorCorrectionEffect then
			colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Name = "CutsceneColorCorrection"
			colorCorrectionEffect.Parent = Lighting
			v5.objects[#v5.objects + 1] = colorCorrectionEffect
		end

		local colorCorrectionKeyframes = FrameEvents.colorCorrectionKeyframes
		local brightness = colorCorrectionKeyframes.Brightness and interpolateValue(
			colorCorrectionKeyframes.Brightness,
			p,
			"number"
		)

		if brightness then
			colorCorrectionEffect.Brightness = brightness
		end

		local contrast = colorCorrectionKeyframes.Contrast and interpolateValue(
			colorCorrectionKeyframes.Contrast,
			p,
			"number"
		)

		if contrast then
			colorCorrectionEffect.Contrast = contrast
		end

		local saturation = colorCorrectionKeyframes.Saturation and interpolateValue(
			colorCorrectionKeyframes.Saturation,
			p,
			"number"
		)

		if saturation then
			colorCorrectionEffect.Saturation = saturation
		end

		local tintColor = colorCorrectionKeyframes.TintColor and interpolateValue(
			colorCorrectionKeyframes.TintColor,
			p,
			"Color3"
		)

		if tintColor then
			colorCorrectionEffect.TintColor = tintColor
		end
	end

	local function updateAmbient(p)
		if not FrameEvents.ambientKeyframes then
			return
		end

		local ambient = FrameEvents.ambientKeyframes.Ambient and interpolateValue(
			FrameEvents.ambientKeyframes.Ambient,
			p,
			"Color3"
		)

		if ambient then
			Lighting.Ambient = ambient
		end

		local outdoorAmbient = FrameEvents.ambientKeyframes.OutdoorAmbient and interpolateValue(
			FrameEvents.ambientKeyframes.OutdoorAmbient,
			p,
			"Color3"
		)

		if outdoorAmbient then
			Lighting.OutdoorAmbient = outdoorAmbient
		end
	end

	local function updateHighlights(_, p, highlight)
		if not FrameEvents.highlightKeyframes then
			return
		end

		if highlight and FrameEvents.highlightKeyframes.user then
			local user = FrameEvents.highlightKeyframes.user

			if user.Enabled then
				local enabled = interpolateValue(user.Enabled, p, "boolean")

				if enabled ~= nil then
					highlight.Enabled = enabled
				end
			end

			local outlineTransparency = user.OutlineTransparency and interpolateValue(
				user.OutlineTransparency,
				p,
				"number"
			)

			if outlineTransparency then
				highlight.OutlineTransparency = outlineTransparency
			end

			local outlineColor = user.OutlineColor and interpolateValue(user.OutlineColor, p, "Color3")

			if outlineColor then
				highlight.OutlineColor = outlineColor
			end

			local fillTransparency = user.FillTransparency and interpolateValue(user.FillTransparency, p, "number")

			if fillTransparency then
				highlight.FillTransparency = fillTransparency
			end

			local fillColor = user.FillColor and interpolateValue(user.FillColor, p, "Color3")

			if fillColor then
				highlight.FillColor = fillColor
			end
		end
	end

	local function updateImageLabel(backgroundImage, p)
		if not (backgroundImage and FrameEvents.imageKeyframes and FrameEvents.imageKeyframes.imagelabel) then
			return
		end

		local imagelabel = FrameEvents.imageKeyframes.imagelabel
		local imageColor = imagelabel.ImageColor3 and interpolateValue(imagelabel.ImageColor3, p, "Color3")

		if imageColor then
			backgroundImage.ImageColor3 = imageColor
		end

		local imageTransparency = imagelabel.ImageTransparency and interpolateValue(
			imagelabel.ImageTransparency,
			p,
			"number"
		)

		if imageTransparency then
			backgroundImage.ImageTransparency = imageTransparency
		end
	end

	fn = function()
		if flag then
			return
		end

		flag = true
		flag2 = false
		local _ = game.Players.LocalPlayer.Character

		for _, connection in pairs(v5.connections) do
			if connection then
				connection:Disconnect()
			end
		end

		for _, animation in pairs(v5.animations) do
			if not animation then
				continue
			end

			animation:Stop()
			animation:Destroy()
		end

		for _, object in pairs(v5.objects) do
			if object and object.Parent then
				object:Destroy()
			end
		end

		for _, tween in pairs(v5.tweens) do
			if tween then
				tween:Cancel()
			end
		end

		for _, particle in pairs(v5.particles) do
			if particle and particle.Parent then
				particle.Enabled = false
			end
		end

		for _, beam in pairs(v5.beams) do
			if beam and beam.Parent then
				beam.Enabled = false
			end
		end

		for _, trail in pairs(v5.trails) do
			if trail and trail.Parent then
				trail.Enabled = false
			end
		end

		for _, light in pairs(v5.lights) do
			if light and light.Parent then
				light.Enabled = false
			end
		end

		currentCamera.FieldOfView = S_FOV

		if colorCorrectionEffect and colorCorrectionEffect.Parent then
			colorCorrectionEffect:Destroy()
			colorCorrectionEffect = nil
		end

		v5.connections = {}
		v5.animations = {}
		v5.objects = {}
		v5.tweens = {}
		v5.particles = {}
		v5.beams = {}
		v5.trails = {}
		v5.lights = {}
		flag = false
	end

	local function runCutscene()
		if flag2 then
			return
		end

		local preloadedImages = {}
		local mobileJunk = game.Players.LocalPlayer.PlayerGui:FindFirstChild("MobileJunk")
		local screenGui = Instance.new("ScreenGui")
		game.Debris:AddItem(screenGui, 15)
		table.insert(data.CleanupTable, screenGui)

		if v4 then
			screenGui.Name = "PreloadedAssets_" .. tostring(tick())
			screenGui.Parent = mobileJunk
			v5.objects[#v5.objects + 1] = screenGui

			for k, list in pairs(v) do
				local folder = Instance.new("Folder")
				folder.Name = k
				folder.Parent = screenGui
				preloadedImages[k] = {}

				for _, image in ipairs(list) do
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.Image = image
					imageLabel.Size = UDim2.new(0, 8, 0, 8)
					imageLabel.Position = UDim2.new(0, 0, 0, 0)
					imageLabel.Visible = true
					imageLabel.Parent = screenGui
					table.insert(preloadedImages[k], imageLabel)
				end
			end

			task.wait()
		end

		local highlight = Instance.new("Highlight")
		table.insert(data.CleanupTable, highlight)
		v3 = highlight
		highlight.OutlineTransparency = 1
		highlight.FillTransparency = 1
		highlight.Parent = char
		game.Debris:AddItem(highlight, 15)
		v5.objects[#v5.objects + 1] = highlight
		local cameraRigBeast

		if data.Char == game.Players.LocalPlayer.Character then
			cameraRigBeast = char:WaitForChild("CameraRigBeast", 2)
		end

		if cameraRigBeast then
			v5.objects[#v5.objects + 1] = cameraRigBeast
		end

		local clone = script.VFX:Clone()

		for _, part in pairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end

		clone.Name = "VFX"
		clone:PivotTo(char.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0))
		clone.Parent = workspace.Thrown
		v5.objects[#v5.objects + 1] = clone
		clone.HeadFx.CharWeld.Part0 = char:WaitForChild("Head")
		clone.HeadFx.CharWeld.Part1 = clone.HeadFx
		clone.HeadFx.Transparency = 1
		local imageLabel

		if v4 then
			local clone2 = script.Misc.BackgroundUI:Clone()
			clone2.Parent = localPlayer.PlayerGui
			v5.objects[#v5.objects + 1] = clone2
			imageLabel = clone2:FindFirstChild("ImageLabel")
		end

		if cameraRigBeast then
			cameraRigBeast:WaitForChild("AnimationController")
		end

		local v9 = {
			user = data.RealAnim
		}
		local v10 = {
			character = char,
			cameraRig = cameraRigBeast,
			vfx = clone,
			backgroundImage = imageLabel,
			PreloadedImages = preloadedImages
		}

		for _, v11 in pairs(v9) do
			v11:Play()
		end

		flag2 = true

		if cameraRigBeast then
			for _, cutscene in pairs(cameraRigBeast.AnimationController:GetPlayingAnimationTracks()) do
				v9.cutscene = cutscene
			end
		end

		task.delay(6, function()
			if not v2 and v4 then
				shared.repfire({
					Effect = "Camshake",
					Intensity = 5,
					Last = 2
				})
			end
		end)
		v5.connections.renderStepped = RunService.RenderStepped:Connect(function()
			if flag then
				return
			end

			v6 = v9.user.TimePosition * 60
			local fieldOfView = interpolateValue(FrameEvents.fovKeyframes, v6, "number")

			if fieldOfView and v4 then
				currentCamera.FieldOfView = fieldOfView
			end

			if v4 then
				updateColorCorrection(v6)
			end

			if v4 then
				updateHighlights(char, v6, highlight)
				updateImageLabel(v10.backgroundImage, v6)
			end

			executeFrameEvents(v6, v10) -- equivalent call inferred; original call site unknown
		end)
	end

	v5.connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
		if player == localPlayer then
			fn()
		end
	end)
	runCutscene()
	wait(20)
	Clean() -- equivalent call inferred; original call site unknown
end

return BeastForm