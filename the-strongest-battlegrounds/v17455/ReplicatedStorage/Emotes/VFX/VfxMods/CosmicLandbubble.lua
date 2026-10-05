local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("KeyframeSequenceProvider")
local BoatTween = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.libraryNew.BoatTween)
local v = {
	textureSets = {
		{
			"rbxassetid://82272667989004",
			"rbxassetid://70751280480079",
			"rbxassetid://98190726362117",
			"rbxassetid://70801889174257",
			"rbxassetid://125120985216966",
			"rbxassetid://97680216999194",
			"rbxassetid://82267602166604",
			"rbxassetid://138822569973938",
			"rbxassetid://119986190388914",
			"rbxassetid://133975577661950",
			"rbxassetid://75604522934609",
			"rbxassetid://109650050879015",
			"rbxassetid://124216880588190",
			"rbxassetid://128518612594329",
			"rbxassetid://123339365239748",
			"rbxassetid://75354859065634",
			"rbxassetid://123310271014663",
			"rbxassetid://71081303352556",
			"rbxassetid://84526856791125",
			"rbxassetid://117494496026003",
			"rbxassetid://133062688236673",
			"rbxassetid://73291453821002",
			"rbxassetid://118560633423776",
			"rbxassetid://76796371988581",
			"rbxassetid://131112675589739",
			"rbxassetid://80149530690169",
			"rbxassetid://99342505689922",
			"rbxassetid://103616849087727",
			"rbxassetid://127618705687441",
			"rbxassetid://122039866245597",
			"rbxassetid://97219151743474",
			"rbxassetid://92867067341539",
			"rbxassetid://99371008011506",
			"rbxassetid://111104111500965",
			"rbxassetid://130231896034010",
			"rbxassetid://87944297255714",
			"rbxassetid://115774342322397",
			"rbxassetid://81062566914013",
			"rbxassetid://98235402921392",
			"rbxassetid://87938404258172",
			"rbxassetid://97218824270065",
			"rbxassetid://76807888197563",
			"rbxassetid://108137513655014",
			"rbxassetid://77316433262614",
			"rbxassetid://98517011694696",
			"rbxassetid://104410486891209",
			"rbxassetid://121186948377845",
			"rbxassetid://76203639876578",
			"rbxassetid://79391356991333",
			"rbxassetid://77080346867389",
			"rbxassetid://107165771283188",
			"rbxassetid://121975282057575",
			"rbxassetid://129708953229624",
			"rbxassetid://100368561553929",
			"rbxassetid://90131776294602",
			"rbxassetid://137639406436386",
			"rbxassetid://119052413696488",
			"rbxassetid://112629453305874",
			"rbxassetid://107697608303893",
			"rbxassetid://110786461548832",
			"rbxassetid://110493656431194",
			"rbxassetid://113053564509185",
			"rbxassetid://84551375738587",
			"rbxassetid://73482312343479",
			"rbxassetid://90943890963029",
			"rbxassetid://117176352518654",
			"rbxassetid://116152388559541",
			"rbxassetid://97141842759651",
			"rbxassetid://115023854343831",
			"rbxassetid://76835644096262",
			"rbxassetid://89152871346982",
			"rbxassetid://76987190108782",
			"rbxassetid://71599279944791",
			"rbxassetid://88040965822945",
			"rbxassetid://96246032251902",
			"rbxassetid://126257323669187",
			"rbxassetid://84383549195983",
			"rbxassetid://84384112242877",
			"rbxassetid://129451648067488",
			"rbxassetid://122750779072010",
			"rbxassetid://102341487321099",
			"rbxassetid://84136001049827",
			"rbxassetid://133014304160816",
			"rbxassetid://132194345888111",
			"rbxassetid://81172761083975",
			"rbxassetid://127391935368862",
			"rbxassetid://139630396889153",
			"rbxassetid://101727112338014",
			"rbxassetid://140607782241748",
			"rbxassetid://140358196795230",
			"rbxassetid://123980219190580",
			"rbxassetid://131718809243473",
			"rbxassetid://80658945062027",
			"rbxassetid://124754120633218",
			"rbxassetid://100010066839682",
			"rbxassetid://110242505367472",
			"rbxassetid://123122855707872",
			"rbxassetid://86097216761832",
			"rbxassetid://72214085343505",
			"rbxassetid://106866269613127",
			"rbxassetid://74483919748483",
			"rbxassetid://104826756654081",
			"rbxassetid://72235811434874",
			"rbxassetid://85960715185927",
			"rbxassetid://85528352932228",
			"rbxassetid://122457637986044",
			"rbxassetid://106459321794657",
			"rbxassetid://80411853401060",
			"rbxassetid://98434811421299",
			"rbxassetid://121294402576041",
			"rbxassetid://125487926616529",
			"rbxassetid://93597944058581",
			"rbxassetid://127644089831307",
			"rbxassetid://76100512301143",
			"rbxassetid://126583879335892",
			"rbxassetid://104869448144405",
			"rbxassetid://127159777122852",
			"rbxassetid://86699141536977",
			"rbxassetid://86977107727187",
			"rbxassetid://103473493492630",
			"rbxassetid://119034675670077",
			"rbxassetid://99821375564849",
			"rbxassetid://123158177628640",
			"rbxassetid://114442203225613",
			"rbxassetid://75570560804439",
			"rbxassetid://102787542792591",
			"rbxassetid://104711214174455",
			"rbxassetid://126320815559120",
			"rbxassetid://74797784405981",
			"rbxassetid://87091155490623",
			"rbxassetid://113433343442667",
			"rbxassetid://137027832060322",
			"rbxassetid://126062475867074",
			"rbxassetid://137099592361383",
			"rbxassetid://84231873602166",
			"rbxassetid://87154919066254",
			"rbxassetid://73069013722518",
			"rbxassetid://116502188059413",
			"rbxassetid://138540400953308",
			"rbxassetid://75254666779431",
			"rbxassetid://136984004862732",
			"rbxassetid://81687989734820",
			"rbxassetid://140227036838781",
			"rbxassetid://77745191253348",
			"rbxassetid://119687538317109",
			"rbxassetid://91347248770262",
			"rbxassetid://124325800167688",
			"rbxassetid://70908368046105",
			"rbxassetid://86559568709239",
			"rbxassetid://139659557957522",
			"rbxassetid://117674247050167"
		},
		{
			"rbxassetid://98344221603539",
			"rbxassetid://117360468982820",
			"rbxassetid://83574111170889",
			"rbxassetid://70412829081903",
			"rbxassetid://81108846322681",
			"rbxassetid://139847026847996",
			"rbxassetid://97233066288752",
			"rbxassetid://90493320682069",
			"rbxassetid://104494560375893",
			"rbxassetid://140552176976983",
			"rbxassetid://78739708752352",
			"rbxassetid://122187059241577",
			"rbxassetid://94051777957929",
			"rbxassetid://103274747729938",
			"rbxassetid://70506289981500",
			"rbxassetid://106157256939063",
			"rbxassetid://89719691518245",
			"rbxassetid://122764647679299",
			"rbxassetid://136838928264849",
			"rbxassetid://80979222433087",
			"rbxassetid://117800291364865",
			"rbxassetid://82113707865112",
			"rbxassetid://118628904936398",
			"rbxassetid://101779970990565",
			"rbxassetid://124341400560389",
			"rbxassetid://136381315911756",
			"rbxassetid://135539215134050",
			"rbxassetid://125783659086803",
			"rbxassetid://137650120887053",
			"rbxassetid://99731978503959",
			"rbxassetid://103509954144195",
			"rbxassetid://118675092715356",
			"rbxassetid://117478912904574",
			"rbxassetid://139726627840011",
			"rbxassetid://104638323311624",
			"rbxassetid://72010238133381",
			"rbxassetid://89918707327391",
			"rbxassetid://137387277798973",
			"rbxassetid://101834209281819",
			"rbxassetid://128700496689518",
			"rbxassetid://111079880419673",
			"rbxassetid://80976697273339",
			"rbxassetid://78486550049021",
			"rbxassetid://131155434846532",
			"rbxassetid://75085948730795",
			"rbxassetid://102615468735055",
			"rbxassetid://72222680811955",
			"rbxassetid://140496075846448",
			"rbxassetid://95935476053587",
			"rbxassetid://89338618139310",
			"rbxassetid://105236142439567",
			"rbxassetid://121934279559581",
			"rbxassetid://96599801566999",
			"rbxassetid://74438600949837",
			"rbxassetid://107622077253552",
			"rbxassetid://89238714392317",
			"rbxassetid://96081192137055",
			"rbxassetid://77353590875404",
			"rbxassetid://102730637322791",
			"rbxassetid://99720750241266"
		},
		{
			"rbxassetid://102076574687689",
			"rbxassetid://121411766794715",
			"rbxassetid://76458950657565",
			"rbxassetid://98850572867237",
			"rbxassetid://94170465167440",
			"rbxassetid://138231490490339",
			"rbxassetid://89297248564133",
			"rbxassetid://75480238946202",
			"rbxassetid://77687099857384",
			"rbxassetid://127846614266421",
			"rbxassetid://114535695567731",
			"rbxassetid://128002541378836",
			"rbxassetid://95663741556226",
			"rbxassetid://82027925130657",
			"rbxassetid://131980282136607",
			"rbxassetid://116516515139462",
			"rbxassetid://75880490383635",
			"rbxassetid://83996579499690",
			"rbxassetid://139797712291721",
			"rbxassetid://116337658793123",
			"rbxassetid://129098030477237",
			"rbxassetid://108402711692505",
			"rbxassetid://105320373847226",
			"rbxassetid://108212414284628",
			"rbxassetid://136532762206237",
			"rbxassetid://111349352089534",
			"rbxassetid://137578243296347",
			"rbxassetid://106830280405146",
			"rbxassetid://135948755541107",
			"rbxassetid://75987679596457",
			"rbxassetid://97383611307583",
			"rbxassetid://85564935150241",
			"rbxassetid://90831796549162",
			"rbxassetid://95542344648045",
			"rbxassetid://117322923422725",
			"rbxassetid://116200316086328",
			"rbxassetid://105899476015437",
			"rbxassetid://128543923520741",
			"rbxassetid://126945151100668",
			"rbxassetid://111556831256580",
			"rbxassetid://80252698920929",
			"rbxassetid://89316175268105",
			"rbxassetid://80411220501420",
			"rbxassetid://136095998482123",
			"rbxassetid://75389736700953",
			"rbxassetid://102407216069962",
			"rbxassetid://95088013122443",
			"rbxassetid://106484796252152",
			"rbxassetid://133895251984650",
			"rbxassetid://127681469276737",
			"rbxassetid://139748088019782",
			"rbxassetid://101523515591471",
			"rbxassetid://89581951981525",
			"rbxassetid://93409421484734",
			"rbxassetid://132943631977852",
			"rbxassetid://73646328402530",
			"rbxassetid://82904993308058",
			"rbxassetid://121051023210744",
			"rbxassetid://98156968647566",
			"rbxassetid://80056375657779",
			"rbxassetid://105340655307154",
			"rbxassetid://120004089261169",
			"rbxassetid://102291823268582",
			"rbxassetid://119747414536425",
			"rbxassetid://128677693552245",
			"rbxassetid://96212273722946",
			"rbxassetid://112009735605270",
			"rbxassetid://78674961583819",
			"rbxassetid://124936140945380",
			"rbxassetid://118401213663653",
			"rbxassetid://122202214568773",
			"rbxassetid://84864640169662",
			"rbxassetid://125819577617474",
			"rbxassetid://78735810170614",
			"rbxassetid://126202609755396",
			"rbxassetid://71265021987896",
			"rbxassetid://90432849704377",
			"rbxassetid://97651950845072",
			"rbxassetid://130887769974584",
			"rbxassetid://83386393236677",
			"rbxassetid://80041125401892",
			"rbxassetid://102731303116056",
			"rbxassetid://78324295701661",
			"rbxassetid://110766979661014",
			"rbxassetid://90180076523489",
			"rbxassetid://121049193337820",
			"rbxassetid://75626778259569",
			"rbxassetid://85608931762321",
			"rbxassetid://103981216541388",
			"rbxassetid://92246643978417",
			"rbxassetid://99596684225296",
			"rbxassetid://103240316472352",
			"rbxassetid://100612365520714",
			"rbxassetid://114470749478346",
			"rbxassetid://100144932036276",
			"rbxassetid://123763881133466",
			"rbxassetid://76419429210462",
			"rbxassetid://99611856244614",
			"rbxassetid://140489038785501",
			"rbxassetid://72328530068790",
			"rbxassetid://130024473148556",
			"rbxassetid://89375264459384",
			"rbxassetid://121359780083770",
			"rbxassetid://105672013194831",
			"rbxassetid://93321803925236",
			"rbxassetid://101880815281736",
			"rbxassetid://123396355332854",
			"rbxassetid://109445427326948",
			"rbxassetid://103899056324790",
			"rbxassetid://87903180013426",
			"rbxassetid://112043732056522",
			"rbxassetid://116053019649333",
			"rbxassetid://130608434488219",
			"rbxassetid://119683412734531",
			"rbxassetid://125810672741081",
			"rbxassetid://83261140210121",
			"rbxassetid://117699132434754",
			"rbxassetid://107921942830603",
			"rbxassetid://84501533631347",
			"rbxassetid://138192458622367",
			"rbxassetid://101162854809306",
			"rbxassetid://94431385064026",
			"rbxassetid://108518225337399",
			"rbxassetid://104432960859287",
			"rbxassetid://95179093478798",
			"rbxassetid://128000068336362",
			"rbxassetid://73870025230373",
			"rbxassetid://98012885405597",
			"rbxassetid://126955265446832",
			"rbxassetid://131156142738370",
			"rbxassetid://134512132542276",
			"rbxassetid://105154350756761",
			"rbxassetid://104443156403537",
			"rbxassetid://126048321732968",
			"rbxassetid://84951927016260",
			"rbxassetid://74344371976544",
			"rbxassetid://104192275107891",
			"rbxassetid://70940759070264",
			"rbxassetid://131018519847543",
			"rbxassetid://103750987339610",
			"rbxassetid://73271829274792",
			"rbxassetid://109729880111366",
			"rbxassetid://94826669111744",
			"rbxassetid://133986778148281",
			"rbxassetid://116115917669401",
			"rbxassetid://117240033880506",
			"rbxassetid://93113371760359",
			"rbxassetid://127406812020241",
			"rbxassetid://107623801094242",
			"rbxassetid://110361988931175",
			"rbxassetid://111894484959220"
		},
		{
			"rbxassetid://130571670328348",
			"rbxassetid://82431193240883",
			"rbxassetid://120493685313366",
			"rbxassetid://108904158749050",
			"rbxassetid://115389855661790",
			"rbxassetid://103471761818632",
			"rbxassetid://118585987578183",
			"rbxassetid://87565656002306",
			"rbxassetid://110475173116324",
			"rbxassetid://87023597396845",
			"rbxassetid://133633058632782",
			"rbxassetid://127734320808149",
			"rbxassetid://138023268019050",
			"rbxassetid://115782475043794",
			"rbxassetid://138859055487625",
			"rbxassetid://121014665969002",
			"rbxassetid://95433412764784",
			"rbxassetid://115715928553804",
			"rbxassetid://87201852536103",
			"rbxassetid://100849599969557",
			"rbxassetid://132872090224859",
			"rbxassetid://80587187928469",
			"rbxassetid://95637318496023",
			"rbxassetid://98845976577389",
			"rbxassetid://90485629195830",
			"rbxassetid://107990394647156",
			"rbxassetid://111844273321207",
			"rbxassetid://80795715218615",
			"rbxassetid://78998239565387",
			"rbxassetid://98547274492547",
			"rbxassetid://128677620373885",
			"rbxassetid://73192235252859",
			"rbxassetid://133251656753280",
			"rbxassetid://83415779146247",
			"rbxassetid://100539007634924",
			"rbxassetid://85614010253977",
			"rbxassetid://87149751629334",
			"rbxassetid://75789723962539",
			"rbxassetid://127898070394335",
			"rbxassetid://100671655614724",
			"rbxassetid://103587503450964",
			"rbxassetid://135154291068647",
			"rbxassetid://91619354454641",
			"rbxassetid://125073997294499",
			"rbxassetid://117740829148861",
			"rbxassetid://123641701895217",
			"rbxassetid://71074061769622",
			"rbxassetid://108598267649560",
			"rbxassetid://116625367176295",
			"rbxassetid://116635186000887",
			"rbxassetid://102303255629024",
			"rbxassetid://81295886732549",
			"rbxassetid://123984034595294",
			"rbxassetid://70769516093108",
			"rbxassetid://124493177049969",
			"rbxassetid://129378066205338",
			"rbxassetid://134678617852265",
			"rbxassetid://135888252038461",
			"rbxassetid://92192953743814",
			"rbxassetid://133441718034156",
			"rbxassetid://96678240824161",
			"rbxassetid://95174586385763",
			"rbxassetid://80394846235321",
			"rbxassetid://132314741340223",
			"rbxassetid://92413818570176",
			"rbxassetid://76751560279209",
			"rbxassetid://77134604617869",
			"rbxassetid://77518753114525",
			"rbxassetid://96479013684458",
			"rbxassetid://98310258167331",
			"rbxassetid://129141941352655",
			"rbxassetid://132039610083873",
			"rbxassetid://86820858510538",
			"rbxassetid://130232748136898",
			"rbxassetid://125996697345867",
			"rbxassetid://133884834159448",
			"rbxassetid://140244923777152",
			"rbxassetid://111996368441268",
			"rbxassetid://73826548415977",
			"rbxassetid://137330965940882",
			"rbxassetid://126592845034493",
			"rbxassetid://122467841180239",
			"rbxassetid://120696812545347",
			"rbxassetid://72690830178017",
			"rbxassetid://101846237207926",
			"rbxassetid://135744822328992",
			"rbxassetid://121490221814482",
			"rbxassetid://137421525085602",
			"rbxassetid://101792705550693",
			"rbxassetid://136455919414392",
			"rbxassetid://126729447360394",
			"rbxassetid://76583777450894",
			"rbxassetid://107521826381871",
			"rbxassetid://135419009553654",
			"rbxassetid://117449871038794",
			"rbxassetid://121892796259360",
			"rbxassetid://118097100090830",
			"rbxassetid://108700646351309",
			"rbxassetid://86087228295138",
			"rbxassetid://115839356817166",
			"rbxassetid://129743724953076",
			"rbxassetid://86916522354021",
			"rbxassetid://139617450234492",
			"rbxassetid://87247454210534",
			"rbxassetid://126538621007130",
			"rbxassetid://73540594774380",
			"rbxassetid://73232095614354",
			"rbxassetid://129632108757715",
			"rbxassetid://104908440955508",
			"rbxassetid://104588750813790",
			"rbxassetid://115654312748692",
			"rbxassetid://81439294127341",
			"rbxassetid://108533951217909",
			"rbxassetid://95731025189118",
			"rbxassetid://122509996865935",
			"rbxassetid://101596475479573",
			"rbxassetid://72220085203351",
			"rbxassetid://127282232782090",
			"rbxassetid://91035050289054",
			"rbxassetid://82230011608687",
			"rbxassetid://97658401997509",
			"rbxassetid://109187201705410",
			"rbxassetid://126597687114480",
			"rbxassetid://113126198035709",
			"rbxassetid://128255069978083",
			"rbxassetid://79731005775208",
			"rbxassetid://92256041173259",
			"rbxassetid://131881835894162",
			"rbxassetid://128850129357671",
			"rbxassetid://131185534791960",
			"rbxassetid://101579875056526",
			"rbxassetid://80610285221941",
			"rbxassetid://96189658286056",
			"rbxassetid://119947659381754",
			"rbxassetid://131996659269732",
			"rbxassetid://119189697383897",
			"rbxassetid://97553921929851",
			"rbxassetid://78528457222218",
			"rbxassetid://80645283129127",
			"rbxassetid://128498407531366",
			"rbxassetid://100512192151991",
			"rbxassetid://102102346014756",
			"rbxassetid://97028428606415",
			"rbxassetid://89696972770312",
			"rbxassetid://119249861484289",
			"rbxassetid://137395043725679",
			"rbxassetid://125335481247388",
			"rbxassetid://75943120394588",
			"rbxassetid://131988216451979",
			"rbxassetid://103470333829332",
			"rbxassetid://127494730670021"
		},
		{
			"rbxassetid://74311875289837",
			"rbxassetid://103270366690984",
			"rbxassetid://135532526750661",
			"rbxassetid://122936765882650",
			"rbxassetid://82144204063811",
			"rbxassetid://86000243855827",
			"rbxassetid://125936949663322",
			"rbxassetid://131897550051798",
			"rbxassetid://134296386329413",
			"rbxassetid://103789444325858",
			"rbxassetid://129222002466708",
			"rbxassetid://84407039306891",
			"rbxassetid://104627170078801",
			"rbxassetid://129464255771660",
			"rbxassetid://120938215940935",
			"rbxassetid://118484709038436",
			"rbxassetid://107719102285894",
			"rbxassetid://92504059692391",
			"rbxassetid://138968778583825",
			"rbxassetid://79551798509941",
			"rbxassetid://99929723242872",
			"rbxassetid://137271991439759",
			"rbxassetid://73828730868791",
			"rbxassetid://119983165083566",
			"rbxassetid://90221452046279",
			"rbxassetid://116922072147805",
			"rbxassetid://95359569239738",
			"rbxassetid://91524383863476",
			"rbxassetid://99385677768462",
			"rbxassetid://125324378185803",
			"rbxassetid://107411486310646",
			"rbxassetid://114532421936162",
			"rbxassetid://105553051105774",
			"rbxassetid://119749508491420",
			"rbxassetid://135946457350348",
			"rbxassetid://77951597055511",
			"rbxassetid://103843727875301",
			"rbxassetid://76692424359485",
			"rbxassetid://98999607191311",
			"rbxassetid://95412118509448",
			"rbxassetid://110467039888047",
			"rbxassetid://98062222667113",
			"rbxassetid://112399865176375",
			"rbxassetid://99102123316793",
			"rbxassetid://125224706291889",
			"rbxassetid://119400245508690",
			"rbxassetid://101889554685063",
			"rbxassetid://83203877526503",
			"rbxassetid://103758223652123",
			"rbxassetid://76856688727947",
			"rbxassetid://70590789947731",
			"rbxassetid://72624739935191",
			"rbxassetid://126962292640294"
		},
		{
			"rbxassetid://86200710080637",
			"rbxassetid://122800575056613",
			"rbxassetid://89637095670307",
			"rbxassetid://135149930890388",
			"rbxassetid://127460183320825",
			"rbxassetid://98782995697818",
			"rbxassetid://133465350742248",
			"rbxassetid://108716631470405",
			"rbxassetid://74622240022421",
			"rbxassetid://84128503771992",
			"rbxassetid://110575459865442",
			"rbxassetid://84705226108696",
			"rbxassetid://77017196023501",
			"rbxassetid://130153185491916",
			"rbxassetid://82682438929227",
			"rbxassetid://77240507855766",
			"rbxassetid://124947534839906",
			"rbxassetid://79859018091735",
			"rbxassetid://99295815897903",
			"rbxassetid://139095782439349",
			"rbxassetid://139928796963384",
			"rbxassetid://102430847460960",
			"rbxassetid://118016270865486",
			"rbxassetid://134495945725888",
			"rbxassetid://134068263948155",
			"rbxassetid://96567667467556",
			"rbxassetid://97438361113114",
			"rbxassetid://98903802016034",
			"rbxassetid://80587180659752",
			"rbxassetid://114580634510315",
			"rbxassetid://74082020191830",
			"rbxassetid://92614960350321",
			"rbxassetid://71655521391322",
			"rbxassetid://138829803204159",
			"rbxassetid://99076883127418",
			"rbxassetid://76905605973580",
			"rbxassetid://98174934154355",
			"rbxassetid://113292927745038",
			"rbxassetid://90690579758380",
			"rbxassetid://104544771301340"
		}
	}
}
local ContentProvider = game:GetService("ContentProvider")

function v.preload(p, object, p2)
	local textureSet = v.textureSets[p]

	if type(textureSet) ~= "table" or #textureSet == 0 then
		return {}
	end

	if p2 and p2[p] then
		return textureSet
	end

	if p2 then
		p2[p] = true
	end

	local thread = nil
	thread = task.spawn(function()
		local v2 = table.create(#textureSet)

		for i = 1, #textureSet do
			local decal = Instance.new("Decal")
			decal.Texture = textureSet[i]
			v2[i] = decal
		end

		pcall(ContentProvider.PreloadAsync, ContentProvider, v2)

		for i = 1, #v2 do
			if v2[i] then
				v2[i]:Destroy()
			end
		end

		thread = nil
	end)

	if object then
		object:giveTask(function()
			if thread then
				pcall(task.cancel, thread)
			end
		end)
	end

	return textureSet
end

function v:animate(p2, p3, p4, p5, p6, object, p7)
	local preload = v.preload(p4, object, p7)
	local count = #preload

	if count == 0 then
		return nil
	end

	local v2 = 1
	local v3 = math.max(1 / p3, 0.016666666666666666)
	local v4 = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		v4 += dt

		if v4 < v3 then
			return
		end

		v4 -= v3

		if p6 then
			v2 = math.random(1, count)
		end

		local v5 = preload[v2]

		if v5 == nil then
			heartbeatConnection:Disconnect()
			return
		end

		if p5 then
			p5.TextureId = v5
		else
			self.Texture = v5
		end

		if not p6 then
			if p2 then
				v2 = v2 % count + 1
				return
			end

			v2 += 1

			if count < v2 then
				heartbeatConnection:Disconnect()
			end
		end
	end)

	if object then
		object:giveTask(heartbeatConnection)
	end

	return heartbeatConnection
end

local Maid = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.libraryNew.Maid)
local thrown = workspace:WaitForChild("Thrown")
local library = require(game.ReplicatedStorage.library)
local playTween = library.PlayTween

local function emitEffects(folder, value, _)
	local v2 = value or 1

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			local v3 = descendant
			task.spawn(function()
				local v4 = (v3:GetAttribute("EmitDelay") or 0) * v2
				local emitCount = v3:GetAttribute("EmitCount") or 0
				local emitDuration = v3:GetAttribute("EmitDuration")

				if emitDuration and emitDuration > 0 then
					v3.Enabled = true
					task.wait(emitDuration * v2)
					v3.Enabled = false
				else
					task.wait(v4)
					v3:Emit(emitCount)
				end
			end)
		elseif descendant:IsA("PointLight") and descendant.Name == "SpecialLight" then
			local v3 = descendant
			task.spawn(function()
				v3.Enabled = true
				local brightness = v3:GetAttribute("Brightness") or v3.Brightness
				local range = v3:GetAttribute("Range") or v3.Range
				local v4 = (v3:GetAttribute("Tween") or 0.2) * v2
				TweenService:Create(v3, TweenInfo.new(v4, Enum.EasingStyle.Sine), {
					Brightness = brightness,
					Range = range
				}):Play()
			end)
		elseif descendant:IsA("Beam") then
			local v3 = descendant
			task.spawn(function()
				local v4 = (v3:GetAttribute("EmitDelay") or 0) * v2
				local v5 = (v3:GetAttribute("EmitDuration") or 0.5) * v2
				local time = 0.25 * v2
				local transparency = v3.Transparency
				task.wait(v4)
				v3.Transparency = NumberSequence.new(1)
				v3.Enabled = true
				local v7 = BoatTween:Create(v3, {
					Time = v5 / 2,
					EasingStyle = "Sine",
					EasingDirection = "In",
					Goal = {
						Transparency = transparency
					}
				})
				v7:Play()
				v7.Completed:Connect(function()
					v7:Destroy()
				end)
				task.delay(v5 / 2, function()
					local v8 = BoatTween:Create(v3, {
						Time = time,
						EasingStyle = "Sine",
						EasingDirection = "Out",
						Goal = {
							Transparency = NumberSequence.new(1)
						}
					})
					v8:Play()
					v8.Completed:Connect(function()
						v8:Destroy()
					end)
				end)
			end)
		end
	end
end

local function spawnRocks(object, p, cFrame, p2)
	local children = script.Debris2:GetChildren()
	local v2 = table.create(p)

	for i = 1, p do
		local clone = children[math.random(#children)]:Clone()
		clone.Parent = workspace
		clone.Orientation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
		Debris:AddItem(clone, p2 + 1)
		v2[i] = {
			inst = clone,
			angle = math.rad(360 / p * i),
			radius = 0,
			finalRadius = math.random(10, 16),
			phase = math.random() * 2 * 3.141592653589793,
			rotSpeed = math.random(50, 150),
			baseY = math.random(1, 10)
		}
	end

	object:giveTask(RunService.RenderStepped:Connect(function(dt)
		local now = tick()

		for i = 1, #v2 do
			local v3 = v2[i]
			local inst = v3.inst

			if not inst.Parent then
				continue
			end

			local angle = v3.angle + -3 * dt
			local radius = math.min(v3.radius + 1500 * dt, v3.finalRadius)
			v3.angle = angle
			v3.radius = radius
			inst.Position = cFrame * Vector3.new(
				math.cos(angle) * radius,
				math.sin(now * 2 + v3.phase) * v3.baseY,
				math.sin(angle) * radius
			)
			inst.Orientation += Vector3.new(0, v3.rotSpeed * dt, 0)
		end
	end))
	object:giveTask(function()
		for i = 1, #v2 do
			local inst = v2[i].inst

			if inst and inst.Parent then
				inst:Destroy()
			end
		end
	end)
end

local CosmicLandbubble = {}
CosmicLandbubble.__index = CosmicLandbubble

function CosmicLandbubble.Attack(_, instance)
	local humanoidRootPart = instance.HumanoidRootPart
	local _ = instance.Humanoid.Animator
	local currentCamera = game.Workspace.CurrentCamera
	humanoidRootPart.Anchored = true
	local v2 = Maid.new()
	local v3 = {}
	local parent = v2:give(Instance.new("Folder"))
	parent.Name = "Cutscene"
	parent.Parent = thrown
	v2:giveTask(function() end)
	local give = v2:give(script.PointLight:Clone())
	give.Parent = humanoidRootPart
	local folder = v2:give(script.Domain:Clone())
	folder.Parent = parent
	folder:PivotTo(humanoidRootPart.CFrame)
	local v5 = v2:give(script.FractalDomain:Clone())
	v5.Parent = parent
	v5:PivotTo(humanoidRootPart.CFrame)
	local v6 = v2:give(script.Cameffects:Clone())
	v6.Parent = parent
	local connection = v.animate(folder.Decal, true, 151, 1, nil, nil, v2, v3)
	local connection2 = v.animate(v5.Decal, true, 120, 2, nil, nil, v2, v3)
	v.animate(v6.screenn.Decal, true, 151, 4, nil, nil, v2, v3)
	local folder2 = v2:give(script.Specs:Clone())
	folder2.Parent = parent
	folder2:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966))
	TweenService:Create(folder2.rocks, TweenInfo.new(0.1), {
		TimeScale = 0
	}):Play()
	v2:giveTask(RunService.Heartbeat:Connect(function(dt)
		if folder2.Parent then
			folder2.CFrame *= CFrame.Angles(math.rad(90 * dt), 0, 0)
		end
	end))
	spawnRocks(v2, 100, humanoidRootPart.CFrame, 2.5)
	local v7 = v2:give(script.EyeFlames:Clone())
	v7.Motor6D.Part0 = instance.Head
	v7.Parent = nil
	v.animate(v7.Bottom, true, 151, 3, nil, nil, v2, v3)
	v.animate(v7.Top, true, 151, 3, nil, nil, v2, v3)
	v2:giveTask(RunService.RenderStepped:Connect(function()
		v6.CFrame = currentCamera.CFrame
	end))
	local v8 = true
	task.delay(7, function()
		v8 = false
	end)
	task.spawn(function()
		while v8 == true do
			local v9 = v2:give(script.Tornado:Clone())
			v9.Parent = parent
			v9.CFrame = humanoidRootPart.CFrame * CFrame.new(0, math.random(0, 25), 0) * CFrame.Angles(
				3.141592653589793,
				math.rad((math.random(-180, 180))),
				0
			)
			v.animate(v9.Decal, false, 80, 5, nil, nil, v2, v3)
			task.wait(0.05)
		end
	end)
	task.delay(4.7, function()
		if not parent.Parent then
			return
		end

		if connection then
			connection:Disconnect()
		end

		if connection2 then
			connection2:Disconnect()
		end

		TweenService:Create(v6.screenn.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		v.animate(v5.Decal, nil, 60, 6, nil, nil, v2, v3)
		v.animate(folder.Decal, nil, 60, 6, nil, nil, v2, v3)
		TweenService:Create(folder, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		v8 = false

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, effect in pairs(folder2:GetDescendants()) do
			if effect:IsA("Beam") then
				playTween(effect, {
					Time = 1,
					EasingStyle = "Sine",
					Goal = {
						Transparency = NumberSequence.new(1)
					}
				})
				game.Debris:AddItem(effect, 1)
			elseif effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			end
		end

		game.Lighting.ClockTime = 12.3
		game.Lighting.EnvironmentDiffuseScale = 0
		game.Lighting.EnvironmentSpecularScale = 0
	end)
	task.delay(7, function()
		v2:doCleaning()
	end)
end

setmetatable(CosmicLandbubble, {
	__index = function(_, p)
		error(("%q is not a valid member of %q"):format(tostring(p), script.Name), 2)
	end
})
return CosmicLandbubble