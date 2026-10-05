local createVector = vector.create
local Flasher = {}
local v = {
	["0"] = "rbxassetid://111651761319809",
	["1"] = "rbxassetid://117411418894368",
	["10"] = "rbxassetid://105986165436397",
	["100"] = "rbxassetid://115440157818242",
	["101"] = "rbxassetid://97562217180674",
	["102"] = "rbxassetid://105464849099190",
	["103"] = "rbxassetid://111920034317666",
	["104"] = "rbxassetid://109586939739387",
	["105"] = "rbxassetid://109378804466601",
	["106"] = "rbxassetid://119040355840779",
	["107"] = "rbxassetid://116812890435249",
	["108"] = "rbxassetid://125357573587017",
	["109"] = "rbxassetid://70626720867031",
	["11"] = "rbxassetid://127201857514395",
	["110"] = "rbxassetid://136231707252460",
	["111"] = "rbxassetid://89043606126003",
	["112"] = "rbxassetid://95863976617487",
	["113"] = "rbxassetid://140324514893162",
	["114"] = "rbxassetid://85216601367842",
	["115"] = "rbxassetid://95479080476370",
	["116"] = "rbxassetid://120258666105283",
	["117"] = "rbxassetid://127956292994877",
	["118"] = "rbxassetid://94824370860622",
	["119"] = "rbxassetid://85880281873048",
	["12"] = "rbxassetid://86884835756677",
	["120"] = "rbxassetid://91442663763291",
	["121"] = "rbxassetid://138779919458339",
	["122"] = "rbxassetid://126162865101795",
	["123"] = "rbxassetid://87967521822264",
	["124"] = "rbxassetid://108312300612968",
	["125"] = "rbxassetid://126453866623013",
	["126"] = "rbxassetid://111306175797294",
	["127"] = "rbxassetid://118901206832629",
	["128"] = "rbxassetid://75841122639353",
	["129"] = "rbxassetid://118480916766224",
	["13"] = "rbxassetid://93930057929531",
	["130"] = "rbxassetid://130439555992494",
	["131"] = "rbxassetid://131466577021500",
	["132"] = "rbxassetid://79743251637737",
	["133"] = "rbxassetid://106307656388487",
	["134"] = "rbxassetid://93788083493576",
	["135"] = "rbxassetid://104251674819393",
	["136"] = "rbxassetid://78604619214933",
	["137"] = "rbxassetid://82141525071889",
	["138"] = "rbxassetid://87348078496265",
	["139"] = "rbxassetid://101459614439470",
	["14"] = "rbxassetid://112293039327549",
	["140"] = "rbxassetid://86649178520150",
	["141"] = "rbxassetid://95041733044555",
	["142"] = "rbxassetid://88160487332191",
	["143"] = "rbxassetid://96593170057342",
	["144"] = "rbxassetid://122744162885620",
	["145"] = "rbxassetid://74082310442527",
	["146"] = "rbxassetid://73781721278954",
	["147"] = "rbxassetid://82756659768908",
	["148"] = "rbxassetid://72150798822471",
	["149"] = "rbxassetid://81459656830875",
	["15"] = "rbxassetid://82806180294266",
	["150"] = "rbxassetid://124148063492038",
	["151"] = "rbxassetid://132180065797529",
	["152"] = "rbxassetid://102046078190089",
	["153"] = "rbxassetid://72693218431013",
	["154"] = "rbxassetid://121533330592288",
	["155"] = "rbxassetid://71693742734959",
	["156"] = "rbxassetid://127157055019428",
	["157"] = "rbxassetid://130642865826368",
	["158"] = "rbxassetid://115841275579160",
	["159"] = "rbxassetid://111574185858677",
	["16"] = "rbxassetid://101045628924634",
	["17"] = "rbxassetid://102314512774441",
	["18"] = "rbxassetid://120482775886208",
	["160"] = "rbxassetid://131332470836432",
	["161"] = "rbxassetid://78748711180158",
	["162"] = "rbxassetid://133211719427656",
	["163"] = "rbxassetid://89892651104572",
	["164"] = "rbxassetid://73465268254591",
	["165"] = "rbxassetid://134125406413849",
	["166"] = "rbxassetid://130428443529029",
	["167"] = "rbxassetid://82720247882795",
	["168"] = "rbxassetid://87840795725655",
	["169"] = "rbxassetid://96668101726621",
	["170"] = "rbxassetid://75932659884927",
	["171"] = "rbxassetid://78632291246653",
	["172"] = "rbxassetid://127917068859254",
	["173"] = "rbxassetid://100713927500306",
	["174"] = "rbxassetid://72257980717029",
	["175"] = "rbxassetid://84444171894807",
	["176"] = "rbxassetid://96635218567987",
	["177"] = "rbxassetid://123434083021030",
	["178"] = "rbxassetid://140399957402129",
	["179"] = "rbxassetid://84181249296286",
	["180"] = "rbxassetid://112782185427105",
	["181"] = "rbxassetid://121307151398367",
	["182"] = "rbxassetid://88591113747928",
	["183"] = "rbxassetid://119616460691691",
	["184"] = "rbxassetid://111549455978457",
	["185"] = "rbxassetid://121499989965209",
	["186"] = "rbxassetid://72064091204056",
	["187"] = "rbxassetid://91021258549260",
	["188"] = "rbxassetid://122853313103385",
	["189"] = "rbxassetid://83342609662477",
	["19"] = "rbxassetid://96000422323297",
	["190"] = "rbxassetid://103326749504396",
	["191"] = "rbxassetid://80958385547853",
	["192"] = "rbxassetid://76579515827927",
	["193"] = "rbxassetid://78331110886723",
	["194"] = "rbxassetid://132734363617338",
	["195"] = "rbxassetid://129191561481081",
	["196"] = "rbxassetid://87663109746601",
	["197"] = "rbxassetid://86479769760754",
	["198"] = "rbxassetid://127739775214715",
	["199"] = "rbxassetid://117591522481101",
	["2"] = "rbxassetid://116691853157417",
	["20"] = "rbxassetid://103553586324647",
	["200"] = "rbxassetid://119021013365213",
	["201"] = "rbxassetid://72876669662108",
	["202"] = "rbxassetid://87228168906493",
	["203"] = "rbxassetid://87023220355724",
	["204"] = "rbxassetid://111092110311298",
	["205"] = "rbxassetid://94048114848355",
	["206"] = "rbxassetid://121797765493348",
	["207"] = "rbxassetid://125100120794486",
	["208"] = "rbxassetid://81361258101165",
	["209"] = "rbxassetid://70374448534811",
	["21"] = "rbxassetid://110080835500264",
	["210"] = "rbxassetid://77698044249141",
	["211"] = "rbxassetid://109316200198432",
	["212"] = "rbxassetid://98813998726484",
	["213"] = "rbxassetid://134233079915506",
	["214"] = "rbxassetid://90608503434461",
	["215"] = "rbxassetid://127397257527199",
	["216"] = "rbxassetid://118602612783399",
	["217"] = "rbxassetid://80182669524799",
	["218"] = "rbxassetid://88158201167686",
	["219"] = "rbxassetid://97765781187821",
	["22"] = "rbxassetid://114420999143627",
	["220"] = "rbxassetid://94319794770268",
	["221"] = "rbxassetid://116851393411343",
	["222"] = "rbxassetid://102951737565795",
	["223"] = "rbxassetid://130023347629597",
	["224"] = "rbxassetid://109479281837299",
	["225"] = "rbxassetid://140296569987410",
	["226"] = "rbxassetid://140705939559830",
	["227"] = "rbxassetid://93858798350229",
	["228"] = "rbxassetid://131506462024228",
	["229"] = "rbxassetid://91342512062672",
	["23"] = "rbxassetid://102184349104265",
	["230"] = "rbxassetid://123867750558728",
	["231"] = "rbxassetid://127325297419835",
	["232"] = "rbxassetid://72923487186980",
	["233"] = "rbxassetid://129347449423506",
	["234"] = "rbxassetid://103547047054316",
	["235"] = "rbxassetid://131892378598770",
	["236"] = "rbxassetid://85899632255457",
	["237"] = "rbxassetid://104423497525601",
	["238"] = "rbxassetid://123710778172972",
	["239"] = "rbxassetid://118604107344907",
	["24"] = "rbxassetid://134530273985669",
	["240"] = "rbxassetid://105497414466688",
	["241"] = "rbxassetid://92877115880745",
	["242"] = "rbxassetid://127561698233109",
	["243"] = "rbxassetid://81885824131982",
	["244"] = "rbxassetid://112578321223226",
	["245"] = "rbxassetid://74976776010926",
	["246"] = "rbxassetid://111111441861090",
	["247"] = "rbxassetid://105628335889170",
	["248"] = "rbxassetid://75239422293993",
	["249"] = "rbxassetid://81696873711947",
	["25"] = "rbxassetid://108454862990037",
	["250"] = "rbxassetid://115885007072713",
	["251"] = "rbxassetid://99066164832440",
	["252"] = "rbxassetid://97356385951035",
	["253"] = "rbxassetid://137020112050677",
	["254"] = "rbxassetid://78253840804420",
	["255"] = "rbxassetid://132745317291028",
	["256"] = "rbxassetid://114226130495287",
	["257"] = "rbxassetid://130205787532592",
	["258"] = "rbxassetid://84093961755567",
	["259"] = "rbxassetid://118491992345264",
	["26"] = "rbxassetid://79149126789308",
	["260"] = "rbxassetid://100196554564840",
	["261"] = "rbxassetid://78059032283615",
	["262"] = "rbxassetid://105517665172013",
	["263"] = "rbxassetid://117022730528546",
	["264"] = "rbxassetid://133131327514053",
	["265"] = "rbxassetid://105039231999068",
	["266"] = "rbxassetid://79244097368151",
	["267"] = "rbxassetid://125188514544234",
	["268"] = "rbxassetid://100904990592003",
	["269"] = "rbxassetid://81483608795120",
	["27"] = "rbxassetid://89019307041039",
	["270"] = "rbxassetid://139909293299471",
	["271"] = "rbxassetid://90076885142059",
	["272"] = "rbxassetid://90942930821877",
	["273"] = "rbxassetid://136306647994160",
	["274"] = "rbxassetid://113788422352873",
	["275"] = "rbxassetid://111231353303621",
	["276"] = "rbxassetid://89780929995724",
	["277"] = "rbxassetid://83348892753091",
	["278"] = "rbxassetid://129864995637241",
	["279"] = "rbxassetid://104306296555965",
	["28"] = "rbxassetid://120494909913613",
	["280"] = "rbxassetid://131819539283549",
	["281"] = "rbxassetid://97647367343131",
	["282"] = "rbxassetid://80933242276319",
	["283"] = "rbxassetid://131260366472898",
	["284"] = "rbxassetid://128639851832983",
	["285"] = "rbxassetid://114181675112788",
	["286"] = "rbxassetid://77413970702022",
	["287"] = "rbxassetid://135002553186996",
	["288"] = "rbxassetid://114060236152273",
	["289"] = "rbxassetid://96069689316109",
	["29"] = "rbxassetid://133953152053267",
	["290"] = "rbxassetid://138513502027747",
	["291"] = "rbxassetid://93332502401781",
	["292"] = "rbxassetid://110612826082965",
	["293"] = "rbxassetid://137790027188364",
	["294"] = "rbxassetid://83505890075413",
	["295"] = "rbxassetid://140363280696116",
	["296"] = "rbxassetid://127100019330650",
	["297"] = "rbxassetid://112719474557911",
	["298"] = "rbxassetid://138120002142124",
	["299"] = "rbxassetid://136355752604783",
	["3"] = "rbxassetid://113168418255095",
	["30"] = "rbxassetid://131518164186789",
	["300"] = "rbxassetid://78707741463450",
	["301"] = "rbxassetid://84996789403401",
	["302"] = "rbxassetid://118065805737120",
	["303"] = "rbxassetid://75373791195801",
	["304"] = "rbxassetid://121777117748541",
	["305"] = "rbxassetid://97373194756400",
	["306"] = "rbxassetid://133986582187453",
	["307"] = "rbxassetid://93942112395058",
	["308"] = "rbxassetid://131403424476087",
	["309"] = "rbxassetid://87536518769101",
	["31"] = "rbxassetid://136643273379118",
	["310"] = "rbxassetid://97000105588901",
	["311"] = "rbxassetid://113918059180306",
	["312"] = "rbxassetid://137912356390842",
	["313"] = "rbxassetid://137343161515726",
	["314"] = "rbxassetid://84905636277842",
	["315"] = "rbxassetid://99219496705285",
	["316"] = "rbxassetid://106320702794446",
	["317"] = "rbxassetid://138231744229592",
	["318"] = "rbxassetid://123010908699195",
	["319"] = "rbxassetid://83894591422270",
	["32"] = "rbxassetid://95732346347976",
	["320"] = "rbxassetid://103743579984658",
	["321"] = "rbxassetid://139173813636874",
	["322"] = "rbxassetid://93525627994726",
	["323"] = "rbxassetid://124548608943799",
	["324"] = "rbxassetid://135146876787894",
	["325"] = "rbxassetid://98107839808342",
	["326"] = "rbxassetid://117685599853343",
	["327"] = "rbxassetid://140504925961114",
	["328"] = "rbxassetid://119949476616472",
	["329"] = "rbxassetid://125704716023639",
	["33"] = "rbxassetid://91474712984345",
	["330"] = "rbxassetid://132506845772447",
	["331"] = "rbxassetid://85767634905730",
	["332"] = "rbxassetid://94723379760907",
	["333"] = "rbxassetid://102451071189121",
	["334"] = "rbxassetid://125594817142350",
	["335"] = "rbxassetid://116933432878347",
	["336"] = "rbxassetid://92304529255881",
	["337"] = "rbxassetid://105412693684294",
	["338"] = "rbxassetid://71829194421831",
	["339"] = "rbxassetid://136627010872360",
	["34"] = "rbxassetid://131167567808161",
	["340"] = "rbxassetid://118043497637241",
	["341"] = "rbxassetid://110576701199269",
	["342"] = "rbxassetid://137685712660363",
	["343"] = "rbxassetid://80870022874994",
	["344"] = "rbxassetid://98084546235329",
	["345"] = "rbxassetid://115912976809368",
	["346"] = "rbxassetid://127828183823349",
	["347"] = "rbxassetid://124396386292282",
	["348"] = "rbxassetid://130743928378728",
	["349"] = "rbxassetid://74273230526465",
	["35"] = "rbxassetid://137846673640678",
	["350"] = "rbxassetid://88313072850468",
	["351"] = "rbxassetid://129050056416376",
	["352"] = "rbxassetid://87149990187318",
	["353"] = "rbxassetid://121375077380318",
	["354"] = "rbxassetid://75045520790746",
	["355"] = "rbxassetid://123673658228246",
	["356"] = "rbxassetid://135962601726972",
	["357"] = "rbxassetid://118327669696094",
	["358"] = "rbxassetid://88355445758012",
	["359"] = "rbxassetid://91679124745077",
	["36"] = "rbxassetid://89184622705087",
	["360"] = "rbxassetid://110836122093492",
	["361"] = "rbxassetid://116699406859064",
	["362"] = "rbxassetid://111343817554684",
	["363"] = "rbxassetid://98014708844402",
	["364"] = "rbxassetid://113543809363984",
	["365"] = "rbxassetid://125757858151079",
	["366"] = "rbxassetid://82129260942941",
	["367"] = "rbxassetid://94359162941365",
	["368"] = "rbxassetid://116643703276576",
	["369"] = "rbxassetid://101158776989944",
	["37"] = "rbxassetid://93008620150175",
	["370"] = "rbxassetid://78200831178348",
	["371"] = "rbxassetid://123729554842952",
	["372"] = "rbxassetid://121637422339632",
	["373"] = "rbxassetid://101150409394210",
	["374"] = "rbxassetid://84275745015623",
	["375"] = "rbxassetid://77100512310162",
	["376"] = "rbxassetid://135032787205325",
	["377"] = "rbxassetid://77643172306000",
	["378"] = "rbxassetid://84594792366998",
	["379"] = "rbxassetid://111147576295648",
	["38"] = "rbxassetid://97582994796761",
	["380"] = "rbxassetid://132425552391764",
	["381"] = "rbxassetid://123020368731281",
	["382"] = "rbxassetid://106950021555845",
	["383"] = "rbxassetid://128054580200205",
	["384"] = "rbxassetid://117393917349068",
	["385"] = "rbxassetid://90595988965530",
	["386"] = "rbxassetid://101646444215764",
	["387"] = "rbxassetid://135117852889203",
	["388"] = "rbxassetid://93573948782314",
	["389"] = "rbxassetid://91603985056687",
	["39"] = "rbxassetid://119488198135430",
	["390"] = "rbxassetid://124277597609830",
	["391"] = "rbxassetid://112422223082265",
	["392"] = "rbxassetid://107175848044294",
	["393"] = "rbxassetid://70548545047908",
	["394"] = "rbxassetid://107466241921902",
	["395"] = "rbxassetid://127509257981022",
	["396"] = "rbxassetid://135556815663386",
	["397"] = "rbxassetid://84889046058294",
	["398"] = "rbxassetid://126437283506921",
	["399"] = "rbxassetid://131143809449190",
	["4"] = "rbxassetid://137605060950859",
	["40"] = "rbxassetid://86093542710023",
	["400"] = "rbxassetid://108770793498809",
	["401"] = "rbxassetid://73848892021790",
	["402"] = "rbxassetid://100171648899562",
	["403"] = "rbxassetid://82311633028004",
	["404"] = "rbxassetid://86095709846545",
	["405"] = "rbxassetid://126914561874242",
	["406"] = "rbxassetid://129771337810951",
	["407"] = "rbxassetid://117909956231200",
	["408"] = "rbxassetid://72641391738931",
	["409"] = "rbxassetid://109207604580762",
	["41"] = "rbxassetid://102803692186317",
	["410"] = "rbxassetid://104688486204268",
	["411"] = "rbxassetid://127953143171290",
	["412"] = "rbxassetid://80248976813150",
	["413"] = "rbxassetid://133368378986834",
	["414"] = "rbxassetid://103973319605653",
	["415"] = "rbxassetid://75228526848082",
	["416"] = "rbxassetid://111773919689833",
	["417"] = "rbxassetid://121330938140387",
	["418"] = "rbxassetid://74336030054939",
	["419"] = "rbxassetid://129123740747090",
	["42"] = "rbxassetid://79580758313479",
	["420"] = "rbxassetid://138353252392570",
	["421"] = "rbxassetid://120832202508133",
	["422"] = "rbxassetid://75778425845851",
	["423"] = "rbxassetid://115654527150587",
	["424"] = "rbxassetid://79025650818038",
	["425"] = "rbxassetid://70650689209214",
	["426"] = "rbxassetid://131226653279043",
	["427"] = "rbxassetid://92299844148255",
	["428"] = "rbxassetid://131174728547922",
	["429"] = "rbxassetid://74871317717527",
	["43"] = "rbxassetid://100923405351384",
	["430"] = "rbxassetid://136498445298266",
	["431"] = "rbxassetid://74930923113453",
	["432"] = "rbxassetid://106207314069183",
	["433"] = "rbxassetid://75665691444834",
	["434"] = "rbxassetid://114588383069704",
	["435"] = "rbxassetid://131203524622980",
	["436"] = "rbxassetid://132922949752389",
	["437"] = "rbxassetid://87500619580277",
	["438"] = "rbxassetid://80341522788433",
	["439"] = "rbxassetid://82437377393094",
	["44"] = "rbxassetid://114272358037925",
	["440"] = "rbxassetid://103318621071813",
	["441"] = "rbxassetid://109039237151291",
	["442"] = "rbxassetid://135333374159809",
	["443"] = "rbxassetid://135931675172160",
	["444"] = "rbxassetid://127590851944988",
	["445"] = "rbxassetid://84991527090859",
	["446"] = "rbxassetid://93122972192698",
	["447"] = "rbxassetid://84124517879214",
	["448"] = "rbxassetid://114935771502954",
	["449"] = "rbxassetid://126870552512740",
	["45"] = "rbxassetid://103065655738532",
	["450"] = "rbxassetid://81270365635133",
	["451"] = "rbxassetid://124823265997117",
	["452"] = "rbxassetid://119274811584886",
	["453"] = "rbxassetid://125914921692283",
	["454"] = "rbxassetid://117018253558475",
	["455"] = "rbxassetid://88340857661797",
	["456"] = "rbxassetid://134992833045063",
	["457"] = "rbxassetid://91321748422192",
	["458"] = "rbxassetid://138691336459989",
	["459"] = "rbxassetid://112750565059852",
	["46"] = "rbxassetid://127767326241313",
	["460"] = "rbxassetid://104428895510739",
	["461"] = "rbxassetid://126511189709064",
	["462"] = "rbxassetid://107167179996314",
	["463"] = "rbxassetid://83188911572058",
	["464"] = "rbxassetid://99312505452032",
	["465"] = "rbxassetid://117741293438305",
	["466"] = "rbxassetid://94544672686745",
	["467"] = "rbxassetid://94990118968089",
	["468"] = "rbxassetid://103719667661807",
	["469"] = "rbxassetid://71457309117801",
	["47"] = "rbxassetid://121940266773778",
	["470"] = "rbxassetid://113612491654651",
	["471"] = "rbxassetid://102621438137363",
	["472"] = "rbxassetid://79933808846838",
	["473"] = "rbxassetid://115771652130479",
	["474"] = "rbxassetid://105841236643282",
	["475"] = "rbxassetid://90927680550580",
	["476"] = "rbxassetid://114344681909087",
	["477"] = "rbxassetid://123468906818921",
	["478"] = "rbxassetid://110917013571675",
	["479"] = "rbxassetid://126528781191041",
	["48"] = "rbxassetid://90591011040097",
	["480"] = "rbxassetid://84380574998637",
	["481"] = "rbxassetid://106418373243873",
	["482"] = "rbxassetid://87309883631638",
	["483"] = "rbxassetid://93990419342007",
	["484"] = "rbxassetid://139351335228972",
	["485"] = "rbxassetid://112897898402938",
	["486"] = "rbxassetid://86298471443356",
	["487"] = "rbxassetid://115337156425350",
	["488"] = "rbxassetid://75515702916344",
	["489"] = "rbxassetid://93587963841435",
	["49"] = "rbxassetid://107083518643587",
	["490"] = "rbxassetid://78795087073473",
	["491"] = "rbxassetid://91344460371654",
	["492"] = "rbxassetid://122611162806504",
	["493"] = "rbxassetid://136022578759445",
	["494"] = "rbxassetid://122005402852230",
	["495"] = "rbxassetid://104080342833018",
	["496"] = "rbxassetid://128874105128742",
	["497"] = "rbxassetid://132395893456909",
	["498"] = "rbxassetid://115137961626445",
	["499"] = "rbxassetid://136259178657455",
	["5"] = "rbxassetid://138664681577064",
	["50"] = "rbxassetid://136312390664517",
	["500"] = "rbxassetid://103428545780239",
	["501"] = "rbxassetid://87806050818407",
	["502"] = "rbxassetid://92613267825346",
	["503"] = "rbxassetid://74743040473711",
	["504"] = "rbxassetid://93954675532497",
	["505"] = "rbxassetid://129923392010728",
	["506"] = "rbxassetid://135182245983782",
	["507"] = "rbxassetid://116053252427402",
	["508"] = "rbxassetid://99757432616346",
	["509"] = "rbxassetid://78412934104426",
	["51"] = "rbxassetid://91145869965881",
	["510"] = "rbxassetid://125171661536695",
	["511"] = "rbxassetid://110902313888528",
	["512"] = "rbxassetid://71932519535597",
	["513"] = "rbxassetid://136186248922654",
	["514"] = "rbxassetid://111260495824599",
	["515"] = "rbxassetid://116752751023568",
	["516"] = "rbxassetid://99102673162216",
	["517"] = "rbxassetid://130193832858012",
	["518"] = "rbxassetid://132064123989730",
	["519"] = "rbxassetid://97986673059486",
	["52"] = "rbxassetid://122163116232202",
	["520"] = "rbxassetid://70639606744396",
	["521"] = "rbxassetid://84706801733668",
	["522"] = "rbxassetid://133926289239573",
	["523"] = "rbxassetid://133926289239573",
	["524"] = "rbxassetid://73873494038879",
	["525"] = "rbxassetid://85308770300958",
	["526"] = "rbxassetid://99383097529105",
	["527"] = "rbxassetid://106875548753854",
	["528"] = "rbxassetid://80957009338852",
	["529"] = "rbxassetid://136782268430386",
	["53"] = "rbxassetid://124080211613493",
	["530"] = "rbxassetid://124427886889350",
	["531"] = "rbxassetid://83408141539118",
	["532"] = "rbxassetid://77364496045648",
	["533"] = "rbxassetid://89411989536630",
	["534"] = "rbxassetid://79591421573303",
	["535"] = "rbxassetid://93885694688610",
	["536"] = "rbxassetid://93396823531225",
	["537"] = "rbxassetid://81331273221985",
	["538"] = "rbxassetid://74973313669241",
	["539"] = "rbxassetid://108746659285856",
	["54"] = "rbxassetid://113630113728425",
	["540"] = "rbxassetid://73886911849636",
	["541"] = "rbxassetid://135397581186663",
	["542"] = "rbxassetid://97985768740150",
	["543"] = "rbxassetid://77804302693070",
	["544"] = "rbxassetid://123187759369332",
	["545"] = "rbxassetid://100437932639501",
	["546"] = "rbxassetid://80368608814214",
	["547"] = "rbxassetid://96768929259669",
	["548"] = "rbxassetid://98944675761984",
	["549"] = "rbxassetid://115572175084177",
	["55"] = "rbxassetid://82853983707753",
	["550"] = "rbxassetid://96384366172304",
	["551"] = "rbxassetid://121501054685604",
	["552"] = "rbxassetid://107753522325277",
	["553"] = "rbxassetid://74053242031883",
	["554"] = "rbxassetid://115352195311345",
	["555"] = "rbxassetid://104841884578126",
	["556"] = "rbxassetid://88056071960622",
	["557"] = "rbxassetid://125886646369127",
	["558"] = "rbxassetid://124985923974999",
	["559"] = "rbxassetid://96711644109300",
	["56"] = "rbxassetid://119621724099057",
	["560"] = "rbxassetid://131894629604895",
	["561"] = "rbxassetid://87171887806905",
	["562"] = "rbxassetid://118746666361968",
	["563"] = "rbxassetid://115945553401516",
	["564"] = "rbxassetid://133603939436281",
	["565"] = "rbxassetid://73523018981676",
	["566"] = "rbxassetid://92085572433949",
	["567"] = "rbxassetid://123068724075780",
	["568"] = "rbxassetid://128760092863385",
	["569"] = "rbxassetid://112017324322839",
	["57"] = "rbxassetid://126656756192214",
	["570"] = "rbxassetid://112017324322839",
	["571"] = "rbxassetid://113072030232267",
	["572"] = "rbxassetid://103636446520558",
	["573"] = "rbxassetid://120658885583451",
	["574"] = "rbxassetid://111333538400618",
	["575"] = "rbxassetid://74494945093565",
	["576"] = "rbxassetid://108205245530868",
	["577"] = "rbxassetid://128750193188382",
	["578"] = "rbxassetid://106255177037825",
	["579"] = "rbxassetid://132425914213136",
	["58"] = "rbxassetid://77397652123592",
	["580"] = "rbxassetid://116769160074149",
	["581"] = "rbxassetid://70890731116108",
	["582"] = "rbxassetid://111811589760265",
	["583"] = "rbxassetid://139358238670186",
	["584"] = "rbxassetid://101900928292159",
	["585"] = "rbxassetid://99222417623325",
	["586"] = "rbxassetid://83527435957094",
	["587"] = "rbxassetid://92706969690001",
	["588"] = "rbxassetid://71171820716004",
	["589"] = "rbxassetid://135513554026755",
	["59"] = "rbxassetid://100765251661329",
	["590"] = "rbxassetid://99108406502726",
	["591"] = "rbxassetid://93230434796535",
	["592"] = "rbxassetid://122979450333480",
	["593"] = "rbxassetid://133791069496948",
	["594"] = "rbxassetid://103161604694916",
	["595"] = "rbxassetid://82273808208031",
	["596"] = "rbxassetid://130710872574808",
	["597"] = "rbxassetid://110575556954896",
	["598"] = "rbxassetid://74501332681328",
	["599"] = "rbxassetid://126723529498962",
	["6"] = "rbxassetid://103680640406719",
	["60"] = "rbxassetid://133917486348351",
	["600"] = "rbxassetid://135200399005108",
	["601"] = "rbxassetid://96876080864811",
	["602"] = "rbxassetid://130617774649562",
	["603"] = "rbxassetid://83717231334647",
	["604"] = "rbxassetid://121918475972738",
	["605"] = "rbxassetid://86981199521004",
	["606"] = "rbxassetid://101192178317893",
	["61"] = "rbxassetid://107511461168504",
	["62"] = "rbxassetid://101750865158357",
	["63"] = "rbxassetid://81531580830385",
	["64"] = "rbxassetid://79391699185324",
	["65"] = "rbxassetid://77231284257719",
	["66"] = "rbxassetid://83567165737208",
	["67"] = "rbxassetid://90060038783630",
	["68"] = "rbxassetid://117808833121788",
	["69"] = "rbxassetid://74280705891602",
	["7"] = "rbxassetid://70853770956007",
	["70"] = "rbxassetid://95774488169464",
	["71"] = "rbxassetid://88072094434938",
	["72"] = "rbxassetid://81702014412560",
	["73"] = "rbxassetid://91450086167931",
	["74"] = "rbxassetid://80695491663461",
	["75"] = "rbxassetid://137485489194658",
	["76"] = "rbxassetid://110035431364266",
	["77"] = "rbxassetid://109843578844451",
	["78"] = "rbxassetid://72607774774233",
	["79"] = "rbxassetid://101657043303456",
	["8"] = "rbxassetid://102544579592353",
	["80"] = "rbxassetid://103851286926860",
	["81"] = "rbxassetid://94536040006533",
	["82"] = "rbxassetid://85733840013335",
	["83"] = "rbxassetid://109876452411729",
	["84"] = "rbxassetid://133921267532866",
	["85"] = "rbxassetid://90820754303404",
	["86"] = "rbxassetid://124525681541083",
	["87"] = "rbxassetid://85223773864901",
	["88"] = "rbxassetid://112070328450062",
	["89"] = "rbxassetid://137668986449569",
	["9"] = "rbxassetid://105207956733451",
	["90"] = "rbxassetid://121716496640328",
	["91"] = "rbxassetid://101628380336798",
	["92"] = "rbxassetid://122010906960127",
	["93"] = "rbxassetid://107540744923468",
	["94"] = "rbxassetid://101037745598166",
	["95"] = "rbxassetid://78581206348195",
	["96"] = "rbxassetid://80450330026507",
	["97"] = "rbxassetid://94999828959443",
	["98"] = "rbxassetid://117412777220171",
	["99"] = "rbxassetid://139319177906422"
}
local library = require(game.ReplicatedStorage.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local dtwait = library.dtwait
local _ = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local able = library.Able
local _ = library.LifeScale
local _ = library.QuickFX
local quickWeld = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local camera = game.Workspace.Camera
local thrown = workspace.Thrown

function Flasher.FirstEvent(data)
	local char = data.Char
	local _ = char == game.Players.LocalPlayer.Character
	shared.NerfVfx({
		Script = script,
		Char = char
	})
	local cleanupTable = data.CleanupTable
	local realAnim = data.RealAnim
	local bind = data.Bind
	local v2 = nil
	tick()
	local _ = char.Humanoid
	local _ = char.HumanoidRootPart
	local _ = char == game.Players.LocalPlayer.Character or game.Players.LocalPlayer.Character == data.CutsceneBind

	local function GetTorsoCF()
		local _, v3, _ = char.HumanoidRootPart.CFrame:ToOrientation()
		return CFrame.new(char.Torso.Position) * CFrame.Angles(0, v3, 0)
	end

	local v3 = false
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local parentChangedConnection = nil
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v4 then
			v4 = true

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
			end

			object._maid:doCleaning()
		end
	end

	local fn
	local parentChangedConnection2 = nil

	local function fn2()
		Clean() -- equivalent call inferred; original call site unknown

		if v2 then
			game.Debris:AddItem(v2, 0.5)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(v2, TweenInfo.new(0.5), {
				Contrast = 0,
				Saturation = 0,
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
		end

		if fn then
			fn(0)
		end

		if parentChangedConnection2 then
			parentChangedConnection2:Disconnect()
		end

		if parentChangedConnection then
			parentChangedConnection:Disconnect()
		end
	end

	if data.CutsceneBind == game.Players.LocalPlayer.Character then
		parentChangedConnection2 = data.CutsceneBind:GetPropertyChangedSignal("Parent"):Connect(function()
			v3 = true
			fn2()
		end)
		table.insert(cleanupTable, parentChangedConnection2)
	end

	local thread = task.delay(15.93, function()
		local v5

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v5 = false
		else
			v5 = true
		end

		if not v5 then
			return
		end

		playAttachment((quickWeld({
			FX = vfx.LastImpactFx,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0.572, 0, 15.136) * CFrame.Angles(-0.5664117021497198, 0, 0)
		})))
	end)
	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		v3 = true

		if thread then
			task.cancel(thread)
		end

		fn2()
		return parentChangedConnection:Disconnect()
	end)
	task.delay(20, function()
		if parentChangedConnection2 then
			parentChangedConnection2:Disconnect()
		end

		if parentChangedConnection then
			return parentChangedConnection:Disconnect()
		end
	end)
	table.insert(cleanupTable, parentChangedConnection)
	task.delay(20, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v5

	if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v3 = true
		v5 = false
	else
		v5 = true
	end

	if not v5 then
		return
	end

	local function tween(instance, p, data2)
		task.spawn(function()
			if instance:FindFirstChildWhichIsA("SpecialMesh") then
				TweenService:Create(instance, p, {
					CFrame = data2.cframe
				}):Play()
				TweenService:Create(instance:FindFirstChildWhichIsA("SpecialMesh"), p, {
					Scale = data2.scale
				}):Play()
			else
				TweenService:Create(instance, p, {
					CFrame = data2.cframe,
					Size = data2.size,
					Transparency = data2.transparency1
				}):Play()
			end

			for _, decal in pairs(instance:GetChildren()) do
				if not decal:IsA("Decal") then
					continue
				end

				local v6

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v6 = false
				else
					v6 = true
				end

				if not v6 then
					break
				end

				TweenService:Create(decal, p, {
					Transparency = data2.transparency2
				}):Play()
			end
		end)
	end

	local function tweensequence(data2)
		local twtype = data2.twtype
		local childtype = data2.childtype
		local newvalues = data2.newvalues
		local amount = data2.amount
		local particle = data2.particle
		local name = data2.name
		task.spawn(function()
			for _, child in pairs(particle:GetChildren()) do
				local v6

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v6 = false
				else
					v6 = true
				end

				if not v6 then
					break
				end

				if name then
					if child:IsA(childtype) and child.name == name then
						local numberSequencesByTwtype = child
						local keypoints = {}
						local numberSequenceKeypoints = {}
						task.spawn(function()
							for i = 1, amount do
								for k, keypoint in pairs(numberSequencesByTwtype[twtype].Keypoints) do
									table.insert(keypoints, keypoint)
								end

								for k, v9 in pairs(keypoints) do
									local numberSequenceKeypoint = NumberSequenceKeypoint.new(
										v9.Time + newvalues[1],
										v9.Value + newvalues[2],
										v9.Envelope + newvalues[3]
									)
									table.insert(numberSequenceKeypoints, numberSequenceKeypoint)
								end

								numberSequencesByTwtype[twtype] = NumberSequence.new(numberSequenceKeypoints)
								table.clear(numberSequenceKeypoints)
								table.clear(keypoints)
								task.wait()
							end
						end)
					end
				elseif child:IsA(childtype) then
					local numberSequencesByTwtype = child
					local keypoints = {}
					local numberSequenceKeypoints = {}
					task.spawn(function()
						for i = 1, amount do
							local v9

							if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
								v3 = true
								v9 = false
							else
								v9 = true
							end

							if not v9 then
								break
							end

							for k, keypoint in pairs(numberSequencesByTwtype[twtype].Keypoints) do
								table.insert(keypoints, keypoint)
							end

							for k, v10 in pairs(keypoints) do
								local numberSequenceKeypoint = NumberSequenceKeypoint.new(
									v10.Time + newvalues[1],
									v10.Value + newvalues[2],
									v10.Envelope + newvalues[3]
								)
								table.insert(numberSequenceKeypoints, numberSequenceKeypoint)
							end

							numberSequencesByTwtype[twtype] = NumberSequence.new(numberSequenceKeypoints)
							table.clear(numberSequenceKeypoints)
							table.clear(keypoints)
							task.wait()
						end
					end)
				end
			end
		end)
	end

	local function makemesh(data2)
		local v6

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v6 = false
		else
			v6 = true
		end

		if not v6 then
			return
		end

		local clone = data2.mesh:Clone()
		game.Debris:AddItem(clone, 23)
		table.insert(cleanupTable, clone)
		clone.Parent = thrown
		object._maid:give(clone)
		clone.CFrame = data2.cframe

		if clone:FindFirstChildWhichIsA("SpecialMesh") and data2.scale then
			local specialMesh = clone:FindFirstChildWhichIsA("SpecialMesh")
			specialMesh.Scale = data2.scale
		elseif data2.size then
			clone.Size = data2.size
		end

		local v7 = nil

		for _, decal in pairs(clone:GetChildren()) do
			if not decal:IsA("Decal") then
				continue
			end

			local v8

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v8 = false
			else
				v8 = true
			end

			if not v8 then
				break
			end

			decal.Transparency = data2.transparency
			v7 = true
		end

		if not v7 then
			clone.Transparency = data2.transparency
		end

		return clone
	end

	local v6 = char == game.Players.LocalPlayer.Character or data.CutsceneBind == game.Players.LocalPlayer.Character

	local function FirstEvent()
		local v7 = {}
		local script2 = script

		if v6 then
			local part = Instance.new("Part")
			table.insert(cleanupTable, part)
			part.Size = createVector(100, 100, 100)
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

			fn = function(localTransparencyModifier)
				if not v6 then
					return
				end

				if localTransparencyModifier == 0 then
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
		end

		local function fn3(childName)
			local v8

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v8 = false
			else
				v8 = true
			end

			if not v8 then
				return
			end

			local child = script2:FindFirstChild(childName)
			v7[childName] = {}

			for _, child2 in pairs(child:GetChildren()) do
				local v9

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v9 = false
				else
					v9 = true
				end

				if not v9 then
					break
				end

				local clone = child2:Clone()
				game.Debris:AddItem(clone, 23)
				table.insert(cleanupTable, clone)
				clone.Size = UDim2.new(0, 1, 0, 1)
				clone.Visible = true
				clone.Parent = game.Players.LocalPlayer.PlayerGui.MobileJunk
				v7[childName][tonumber(child2.Name)] = clone
			end
		end

		if v6 then
			for _, v8 in pairs({
				script.LastImpcs,
				script["1"],
				script["1after"],
				script["2"],
				script["3"],
				script.white
			}) do
				local v9

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v9 = false
				else
					v9 = true
				end

				if not v9 then
					return
				end

				fn3(tostring(v8))
			end

			spawn(function()
				local folder = Instance.new("Folder")
				game.Debris:AddItem(folder, 23)
				table.insert(cleanupTable, folder)
				folder.Name = "HolderImpact"
				folder.Parent = game.Players.LocalPlayer.PlayerGui.MobileJunk

				for k, image in pairs(v) do
					local v9

					if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v3 = true
						v9 = false
					else
						v9 = true
					end

					if not v9 then
						warn(";broke")
						break
					end

					local clone = script["1"]["2"]:Clone()
					clone.Image = image
					clone.Name = tostring(k)
					clone.Size = UDim2.new(0, 1, 0, 1)
					clone.Visible = true
					clone.Parent = folder
					task.wait()
				end
			end)
		end

		local count = 0
		local folder = char
		local targChar = data.targChar
		local camPart = nil

		if v6 then
			for _, model in pairs(folder:GetChildren()) do
				if not (tostring(model) == "CamEntire" and model:IsA("Model") and model:FindFirstChild("CamPart")) then
					continue
				end

				camPart = model.CamPart
				break
			end
		end

		local v8

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v8 = false
		else
			v8 = true
		end

		if not v8 then
			return
		end

		local clone

		if v6 then
			local clone2 = script.Impact:Clone()
			game.Debris:AddItem(clone2, 23)
			table.insert(cleanupTable, clone2)
			clone2.Parent = game.Players.LocalPlayer.PlayerGui.MobileJunk
			clone = script.white:Clone()
			game.Debris:AddItem(clone, 23)
			table.insert(cleanupTable, clone)
			clone.Parent = clone2
			clone.Size = UDim2.new(0, 0.001, 0, 0.001)
		else
			clone = nil
		end

		local v9 = {}
		local fn4
		local fromRGB = Color3.fromRGB
		local fn5

		fn5 = function(p, p2, _)
			if not v6 then
				return
			end

			local v10 = v7[p]
			local v11 = p == "yer"

			if p ~= "yer" and not v10 then
				warn("Impact function failed: No elements in imps['" .. tostring(p) .. "']")
				return
			end

			count += 1
			local v13 = nil
			local v14 = 1
			local v15 = nil
			tick()
			v15 = shared.loop(function()
				local child = nil

				if v11 then
					local holderImpact = game.Players.LocalPlayer.PlayerGui.MobileJunk:FindFirstChild("HolderImpact")

					if holderImpact then
						child = holderImpact:FindFirstChild(v14)
					end
				else
					child = v10[v14]
				end

				if child then
					local flag

					if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v3 = true
						flag = false
					else
						flag = true
					end

					if flag then
						v14 += 1
						child.Visible = true
						child.Size = UDim2.new(1, 0, 1, 0)

						if v13 then
							v13:Destroy()
						end

						v13 = child
						return
					end
				end

				local v16 = v10

				if typeof(v16) == "table" then
					for _, v17 in pairs(v16) do
						v17:Destroy()
					end
				else
					local holderImpact = game.Players.LocalPlayer.PlayerGui.MobileJunk:FindFirstChild("HolderImpact")

					if holderImpact then
						holderImpact:Destroy("")
					end
				end

				local v17

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v17 = false
				else
					v17 = true
				end

				if not (v17 and count == 1) then
					return v15()
				end

				clone.Size = UDim2.new(1, 0, 1, 0)
				spawn(function()
					fn(1)
				end)
				local v18

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v18 = false
				else
					v18 = true
				end

				if not v18 then
					return
				end

				dtwait(0.6)
				local v19

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v19 = false
				else
					v19 = true
				end

				if not v19 then
					return
				end

				game.Debris:AddItem(clone, 0.05)
				fn5("2")
				fn5("1after")
				task.delay(0.17, function()
					fn5("yer")
				end)
				local v20

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v20 = false
				else
					v20 = true
				end

				if not v20 then
					return
				end

				dtwait(0.18)
				local v21

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v21 = false
				else
					v21 = true
				end

				if not v21 then
					return
				end

				task.spawn(function()
					fn4({
						b = 0,
						c = 0,
						s = 0,
						tc = fromRGB(255, 255, 255),
						w = 0
					})
					fn4({
						b = -2,
						c = 15,
						s = -1,
						tc = fromRGB(255, 60, 60),
						w = 0.017
					})
					fn4({
						b = 2,
						c = -15,
						s = -1,
						tc = fromRGB(255, 60, 60),
						w = 0.017
					})
					fn4({
						b = -2,
						c = 6,
						s = -1,
						tc = fromRGB(255, 60, 60),
						w = 0.017
					})
					fn4({
						b = -7,
						c = 0,
						s = 0,
						tc = fromRGB(255, 60, 60),
						w = 0.017
					})
					fn4({
						b = 5,
						c = 0,
						s = 0,
						tc = fromRGB(255, 255, 255),
						w = 0.017
					})
					fn4({
						b = 0.07,
						c = 0,
						s = 0,
						tc = fromRGB(255, 157, 157),
						w = 0
					})
				end)
				return v15()
			end, v11 and 60 or p2 or 21)
		end

		task.delay(14, function()
			local v10

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v10 = false
			else
				v10 = true
			end

			if not (v10 and v6) then
				return
			end

			fn(0)
		end)
		task.delay(15.5, function()
			local v10

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v10 = false
			else
				v10 = true
			end

			if not v10 then
				return
			end

			fn5("3", 25)
		end)
		local v10 = {}
		local v11 = {}

		local function parent(child, folder2)
			local parent2 = folder2[tostring(child)]

			if not parent2 then
				return
			end

			if not v10[folder2] then
				v10[folder2] = {}
			end

			if not v11[folder2] then
				v11[folder2] = {}
			end

			for _, child2 in pairs(child:GetChildren()) do
				local v13

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v13 = false
				else
					v13 = true
				end

				if not v13 then
					return
				end

				local clone2 = child2:Clone()
				game.Debris:AddItem(clone2, 23)
				table.insert(cleanupTable, clone2)
				clone2.Parent = parent2
				table.insert(v11[folder2], clone2)

				if not clone2:IsA("Trail") then
					continue
				end

				table.insert(v11[folder2], clone2)

				if clone2.Attachment0 and clone2.Attachment1 then
					v9[clone2] = {
						Attachment0 = clone2.Attachment0.CFrame,
						Attachment1 = clone2.Attachment1.CFrame
					}
				end
			end

			if next(v9) then
				for k, v13 in pairs(v9) do
					local v14

					if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v3 = true
						v14 = false
					else
						v14 = true
					end

					if not v14 then
						return
					end

					local attachment0 = v13.Attachment0
					local attachment1 = v13.Attachment1

					if not (k.Parent and k.Parent.Parent) then
						continue
					end

					for _, attachment in pairs(folder2:GetDescendants()) do
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
			end
		end

		local instances = {}
		local descendantAddedConnection = folder.DescendantAdded:Connect(function(instance)
			if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("PointLight") or instance:IsA("Trail") then
				table.insert(instances, instance)
			end
		end)
		object._maid:give(descendantAddedConnection)
		table.insert(cleanupTable, descendantAddedConnection)
		task.delay(10, function()
			if descendantAddedConnection then
				return descendantAddedConnection:Disconnect()
			end
		end)

		for _, child in pairs(folder:GetChildren()) do
			local v12

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v12 = false
			else
				v12 = true
			end

			if not v12 then
				return
			end

			local child2 = script.char:FindFirstChild((tostring(child)))

			if child2 then
				parent(child2, folder)
			end
		end

		for _, child in pairs(targChar:GetChildren()) do
			local v12

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v12 = false
			else
				v12 = true
			end

			if not v12 then
				return
			end

			local child2 = script.vic:FindFirstChild((tostring(child)))

			if child2 then
				parent(child2, targChar)
			end
		end

		local function thingable(ancestor, enabled, className)
			local folder2

			if ancestor.Parent == targChar or ancestor.Parent == folder then
				folder2 = ancestor.Parent == targChar and targChar or folder
			else
				folder2 = ancestor
			end

			if folder2 == folder or folder2 == targChar then
				local v12 = v11[folder2]

				if v12 then
					for _, folder3 in pairs(v12) do
						if ancestor == folder2 then
							if not folder3:IsA(className) and #folder3:GetChildren() > 0 then
								for _, descendant in pairs(folder3:GetDescendants()) do
									if descendant:IsA(className) then
										descendant.Enabled = true
									end
								end
							end

							if folder3:IsA(className) then
								folder3.Enabled = enabled
							end
						elseif folder3:IsDescendantOf(ancestor) then
							if folder3:IsA("Beam") or folder3:IsA("PointLight") or folder3:IsA("ParticleEmitter") then
								folder3.Enabled = enabled
							elseif #folder3:GetChildren() > 0 then
								for _, descendant in pairs(folder3:GetDescendants()) do
									if not (folder3:IsA("Beam") or folder3:IsA("PointLight") or folder3:IsA("ParticleEmitter")) then
										continue
									end

									descendant.Enabled = true
								end
							end
						end
					end
				end
			else
				for _, descendant in pairs(folder2:GetDescendants()) do
					if descendant:IsA(className) then
						descendant.Enabled = enabled
					end
				end
			end
		end

		thingable(folder, true, "Trail")
		local v12

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v12 = false
		else
			v12 = true
		end

		if not v12 then
			return
		end

		local clone2

		if v6 then
			clone2 = script.ScreenGui:Clone()
			game.Debris:AddItem(clone2, 23)
			table.insert(cleanupTable, clone2)
			clone2.Parent = game.StarterGui
			object._maid:give(clone2)
		else
			clone2 = nil
		end

		task.spawn(function()
			if not v6 then
				return
			end

			dtwait(0.11)
			local v13

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v13 = false
			else
				v13 = true
			end

			if not v13 then
				return
			end

			for _, descendant in pairs(clone2:GetDescendants()) do
				TweenService:Create(descendant, TweenInfo.new(0.17, Enum.EasingStyle.Linear), {
					ImageTransparency = 0
				}):Play()
			end

			dtwait(1.4)
			local v14

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v14 = false
			else
				v14 = true
			end

			if not v14 then
				return
			end

			for _, descendant in pairs(clone2:GetDescendants()) do
				TweenService:Create(descendant, TweenInfo.new(0.45, Enum.EasingStyle.Linear), {
					ImageTransparency = 1
				}):Play()
			end

			dtwait(0.9)
			local v15

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v15 = false
			else
				v15 = true
			end

			if not v15 then
				return
			end

			for _, descendant in pairs(clone2:GetDescendants()) do
				TweenService:Create(descendant, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					ImageTransparency = 0
				}):Play()
			end
		end)
		dtwait(0.3)
		local v13

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v13 = false
		else
			v13 = true
		end

		if not v13 then
			return
		end

		for _, emitter in pairs(folder:GetDescendants()) do
			local v14

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v14 = false
			else
				v14 = true
			end

			if not v14 then
				return
			end

			if not (emitter:IsA("ParticleEmitter") and emitter.Name == "Energy" or emitter.Name == "Curse" or emitter.Name == "Ink1") then
				continue
			end

			emitter.Enabled = true
		end

		playAttachment(folder["Right Arm"]["2"].Emit)
		local v14

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v14 = false
		else
			v14 = true
		end

		if not v14 then
			return
		end

		local v15 = quickWeld({
			FX = vfx.StepFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(-0.3, 3, -1.8)
		})
		game.Debris:AddItem(v15, 23)
		table.insert(cleanupTable, v15)
		playAttachment(v15)
		local clone3 = script.cc:Clone()
		game.Debris:AddItem(clone3, 20)
		v2 = clone3

		if v6 then
			clone3.Parent = game.Lighting
		end

		fn4 = function(data2)
			local v16

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v16 = false
			else
				v16 = true
			end

			if not v16 then
				return
			end

			clone3.Brightness = data2.b
			clone3.Contrast = data2.c
			clone3.TintColor = data2.tc
			clone3.Saturation = data2.s
			dtwait(data2.w)
		end

		task.spawn(function()
			fn4({
				b = 0,
				c = 0,
				s = 0,
				tc = fromRGB(255, 255, 255),
				w = 0
			})
			fn4({
				b = -2,
				c = 15,
				s = -1,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = 2,
				c = -15,
				s = -1,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = -2,
				c = 6,
				s = -1,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = -7,
				c = 0,
				s = 0,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = 5,
				c = 0,
				s = 0,
				tc = fromRGB(255, 255, 255),
				w = 0.017
			})
			fn4({
				b = 0,
				c = 0,
				s = 0,
				tc = fromRGB(255, 255, 255),
				w = 0
			})
		end)
		task.delay(1.9, function()
			local v16

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v16 = false
			else
				v16 = true
			end

			if not (v16 and v6) then
				return
			end

			local clone4 = vfx.ball:Clone()
			game.Debris:AddItem(clone4, 23)
			table.insert(cleanupTable, clone4)
			clone4.Parent = thrown
			clone4.CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, 8.35, 0)
			object._maid:give(clone4)
			TweenService:Create(clone4, TweenInfo.new(0.27, Enum.EasingStyle.Linear), {
				Transparency = 0.45
			}):Play()
			dtwait(1.05)
			local v17

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v17 = false
			else
				v17 = true
			end

			if not v17 then
				return
			end

			TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				Transparency = 1
			}):Play()
		end)
		dtwait(2.1)
		local v16

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		if camPart then
			camPart["1"].Enabled = true
			camPart["2"].Enabled = true
		end

		local clone4 = vfx.JustFx:Clone()
		game.Debris:AddItem(clone4, 23)
		table.insert(cleanupTable, clone4)
		object._maid:give(clone4)
		clone4.Parent = thrown
		clone4.CFrame = folder.PrimaryPart.CFrame * CFrame.new(4.6, -2.3, -3.15) * CFrame.Angles(
			0,
			-0.5061454830783556,
			0
		)
		clone4.CFrame = clone4.CFrame * CFrame.new(0, -0.6, -0.15) * CFrame.Angles(0.9599310885968813, 0, 0)
		able({
			FX = clone4,
			On = true
		})
		local v17

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v17 = false
		else
			v17 = true
		end

		if not v17 then
			return
		end

		if v6 then
			TweenService:Create(clone3, TweenInfo.new(0.15), {
				Brightness = 0,
				Contrast = 0.3,
				Saturation = 0.4,
				TintColor = fromRGB(88, 253, 255)
			}):Play()
			task.delay(0.15, function()
				local v18

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v18 = false
				else
					v18 = true
				end

				if not v18 then
					return
				end

				TweenService:Create(clone3, TweenInfo.new(0.5), {
					Brightness = 0.25,
					Contrast = 0.125,
					Saturation = 0.4,
					TintColor = fromRGB(255, 255, 255)
				}):Play()
				dtwait(0.5)
				local v19

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v19 = false
				else
					v19 = true
				end

				if not v19 then
					return
				end

				TweenService:Create(clone3, TweenInfo.new(0.6), {
					Brightness = 0.125,
					Contrast = 0.125,
					Saturation = 0.4,
					TintColor = fromRGB(88, 253, 255)
				}):Play()
				dtwait(0.6)
				local v20

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v20 = false
				else
					v20 = true
				end

				if not v20 then
					return
				end

				fn4({
					b = 0,
					c = 0,
					s = 0,
					tc = fromRGB(255, 255, 255),
					w = 0
				})
			end)
		end

		dtwait(0.45)
		local v18

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v18 = false
		else
			v18 = true
		end

		if not v18 then
			return
		end

		for _, v19 in pairs(instances) do
			v19.Enabled = true
		end

		folder["Right Arm"]["2"]["1"].fire.Enabled = true
		playAttachment(folder["Right Arm"]["2"].Emit2)
		spawn(function()
			dtwait(0.715)
			local v19

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v19 = false
			else
				v19 = true
			end

			if not v19 then
				return
			end

			fn5("1")
		end)
		dtwait(0.8)
		local v19

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v19 = false
		else
			v19 = true
		end

		if not v19 then
			return
		end

		able({
			FX = clone4,
			On = false
		})

		if camPart then
			camPart["1"].Enabled = false
			camPart["2"].Enabled = false
		end

		dtwait(2.1)
		local v20

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v20 = false
		else
			v20 = true
		end

		if not v20 then
			return
		end

		if camPart then
			camPart["1"].Enabled = true
			camPart["2"].Enabled = true
		end

		for _, v21 in pairs(instances) do
			v21.Enabled = false
		end

		thingable(targChar.Torso, true)
		local v21

		if v6 then
			v21 = quickWeld({
				FX = vfx.Beam1,
				Maid = object._maid,
				P = folder.PrimaryPart,
				C0 = CFrame.new(-2.481, 0.9, -2.787) * CFrame.Angles(0, 0, 0.08726646259971647)
			})
			game.Debris:AddItem(v21, 23)
			table.insert(cleanupTable, v21)
			thingable(v21.Attachment1, true, "Beam")
		end

		local FX

		if v6 then
			FX = quickWeld({
				FX = vfx.Backgound,
				Maid = object._maid,
				P = folder.PrimaryPart,
				C0 = CFrame.new(-8.595, 9.751, -10.126) * CFrame.Angles(
					0.2543468318931337,
					0.08677777040915807,
					-0.46420522115293184
				)
			})
			game.Debris:AddItem(FX, 23)
			table.insert(cleanupTable, FX)
			able({
				FX = FX,
				On = true
			})
			FX.Transparency = 0
		end

		dtwait(2.8)
		local v23

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v23 = false
		else
			v23 = true
		end

		if not v23 then
			return
		end

		if v21 then
			thingable(v21, false, "Beam")
			v21.Bttachment2.Beam4.Enabled = true
		end

		if FX then
			FX.Transparency = 1
			able({
				FX = FX,
				On = false
			})
		end

		fn4({
			b = 0,
			c = 0,
			s = 0,
			tc = fromRGB(255, 178, 147),
			w = 0
		})
		thingable(targChar.Head, true)
		task.delay(0.28, function()
			TweenService:Create(clone3, TweenInfo.new(0.5), {
				Brightness = clone3.Brightness,
				Contrast = 0.2,
				Saturation = clone3.Saturation,
				TintColor = clone3.TintColor
			}):Play()
		end)
		local v24

		if v6 then
			v24 = quickWeld({
				FX = vfx.Backgound2,
				Maid = object._maid,
				P = folder.PrimaryPart,
				C0 = CFrame.new(-8.595, 9.751, -10.126) * CFrame.Angles(
					0.2543468318931337,
					0.08677777040915807,
					-0.46420522115293184
				)
			})
			game.Debris:AddItem(v24, 23)
			table.insert(cleanupTable, v24)
			v24.Transparency = 0
		end

		dtwait(0.6)
		local v25

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v25 = false
		else
			v25 = true
		end

		if not v25 then
			return
		end

		playAttachment(targChar.Head)
		dtwait(0.35)
		local v26

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v26 = false
		else
			v26 = true
		end

		if not v26 then
			return
		end

		thingable(folder.Head, true)
		local FX2 = quickWeld({
			FX = vfx.BlackFlashFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(1.505, 0, 4.382)
		})
		game.Debris:AddItem(FX2, 23)
		table.insert(cleanupTable, FX2)
		able({
			FX = FX2,
			On = true
		})
		dtwait(0.08)
		local v28

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v28 = false
		else
			v28 = true
		end

		if not v28 then
			return
		end

		if v21 then
			thingable(v21, false, "Beam")
			v21.Bttachment2.Beam1.Enabled = true
			v21.Bttachment2.Beam2.Enabled = true
			v21.Bttachment2.Beam3.Enabled = true
		end

		TweenService:Create(clone3, TweenInfo.new(0.08), {
			Brightness = clone3.Brightness,
			Contrast = clone3.Contrast,
			Saturation = clone3.Saturation,
			TintColor = fromRGB(255, 145, 145)
		}):Play()
		dtwait(1.62)
		local v29

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v29 = false
		else
			v29 = true
		end

		if not v29 then
			return
		end

		if v21 then
			thingable(v21, false, "Beam")
			v21.Bttachment2.Beam5.Enabled = true
			v21.Bttachment2.Beam7.Enabled = true
			v21.Bttachment2.Beam6.Enabled = true
		end

		TweenService:Create(clone3, TweenInfo.new(0.08), {
			Brightness = clone3.Brightness,
			Contrast = clone3.Contrast,
			Saturation = clone3.Saturation,
			TintColor = fromRGB(255, 178, 147)
		}):Play()
		task.delay(2.17, function()
			local v30

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v30 = false
			else
				v30 = true
			end

			if not v30 then
				return
			end

			TweenService:Create(clone3, TweenInfo.new(0.08), {
				Brightness = clone3.Brightness,
				Contrast = clone3.Contrast,
				Saturation = clone3.Saturation,
				TintColor = fromRGB(255, 145, 145)
			}):Play()
		end)
		dtwait(2.96)
		local v30

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v30 = false
		else
			v30 = true
		end

		if not v30 then
			return
		end

		local function tweenscale(folder2)
			for _, emitter in pairs(folder2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v31 = emitter
				task.spawn(function()
					local v32

					if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v3 = true
						v32 = false
					else
						v32 = true
					end

					if not v32 then
						return
					end

					TweenService:Create(v31, TweenInfo.new(0.49, Enum.EasingStyle.Linear), {
						TimeScale = 0.1
					}):Play()
					dtwait(0.72)
					local v33

					if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v3 = true
						v33 = false
					else
						v33 = true
					end

					if not v33 then
						return
					end

					TweenService:Create(v31, TweenInfo.new(0.49, Enum.EasingStyle.Linear), {
						TimeScale = 1
					}):Play()
				end)
			end
		end

		tweenscale(FX2)
		tweenscale(targChar.Torso)
		tweenscale(camera)
		local v31

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v31 = false
		else
			v31 = true
		end

		if not v31 then
			return
		end

		dtwait(0.47)
		local v32

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v32 = false
		else
			v32 = true
		end

		if not v32 then
			return
		end

		if v24 and v24.Parent and v6 then
			v24.Transparency = 1
		end

		if v21 and v21.Parent then
			thingable(v21, false, "Beam")
		end

		thingable(folder.Head, false)
		thingable(targChar.Head, false)
		thingable(FX2, false, "Beam")
		dtwait(1.18)
		local v33

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v33 = false
		else
			v33 = true
		end

		if not v33 then
			return
		end

		able({
			FX = FX2,
			On = false
		})
		thingable(targChar.Torso, false)
		task.spawn(function()
			if not v6 then
				return
			end

			fn4({
				b = 0,
				c = 0,
				s = 0,
				tc = fromRGB(255, 255, 255),
				w = 0
			})
			fn4({
				b = -2,
				c = 15,
				s = -1,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = 2,
				c = -15,
				s = -1,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = -2,
				c = 6,
				s = -1,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = -7,
				c = 0,
				s = 0,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = 5,
				c = 0,
				s = 0,
				tc = fromRGB(255, 255, 255),
				w = 0.017
			})
			fn4({
				b = 0.07,
				c = 0,
				s = 0,
				tc = fromRGB(255, 157, 157),
				w = 0
			})
			fn4({
				b = -2,
				c = 15,
				s = -1,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = 2,
				c = -15,
				s = -1,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = -2,
				c = 6,
				s = -1,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = -7,
				c = 0,
				s = 0,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			fn4({
				b = 5,
				c = 0,
				s = 0,
				tc = fromRGB(255, 255, 255),
				w = 0.017
			})
			fn4({
				b = 2,
				c = -15,
				s = -1,
				tc = fromRGB(255, 60, 60),
				w = 0.017
			})
			dtwait(0.27)
			local v34

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v34 = false
			else
				v34 = true
			end

			if not v34 then
				return
			end

			TweenService:Create(clone3, TweenInfo.new(0.32), {
				Brightness = 0,
				Contrast = 0.2,
				Saturation = 0,
				TintColor = fromRGB(255, 76, 76)
			}):Play()
			dtwait(0.32)
			local v35

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v35 = false
			else
				v35 = true
			end

			if not v35 then
				return
			end

			TweenService:Create(clone3, TweenInfo.new(0.25), {
				Brightness = 0,
				Contrast = 0.2,
				Saturation = 0,
				TintColor = fromRGB(255, 255, 255)
			}):Play()
		end)
		dtwait(0.1)
		local v34

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v34 = false
		else
			v34 = true
		end

		if not v34 then
			return
		end

		thingable(folder, false, "Trail")
		task.delay(1, function()
			local v35

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v35 = false
			else
				v35 = true
			end

			if not v35 then
				return
			end

			if clone2 then
				for _, descendant in pairs(clone2:GetDescendants()) do
					local v36

					if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v3 = true
						v36 = false
					else
						v36 = true
					end

					if not v36 then
						return
					end

					TweenService:Create(descendant, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
						ImageTransparency = 1
					}):Play()
				end
			end
		end)
		dtwait(0.5)

		if not (camPart and camPart.Parent) then
			return
		end

		camPart:Destroy("")

		if v2 then
			game.Debris:AddItem(v2, 0.25)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(v2, TweenInfo.new(0.25), {
				Contrast = 0,
				Saturation = 0,
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
		end
	end

	task.spawn(FirstEvent)
	wait(22)
	Clean() -- equivalent call inferred; original call site unknown
	able({
		FX = camera,
		On = false
	})
end

return Flasher