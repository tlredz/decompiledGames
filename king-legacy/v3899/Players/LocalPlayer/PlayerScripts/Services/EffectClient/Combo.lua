local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules")
local FastRenderer = require(ReplicatedStorage.Chest.Modules.FastRenderer)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local HighlightModule = require(ReplicatedStorage.Chest.Modules.HighlightModule)
local v = {
	Gale_Fist_Grab = function(player)
		local victims = player.Victims
		local character = player.Character
		local grabing = player.Grabing

		if victims and character and grabing then
			FastRenderer.new({
				Time = 15
			}, function(_, _)
				if not grabing.Parent then
					return true
				end

				local rightHand = character:FindFirstChild("RightHand")

				if not rightHand then
					return true
				end

				local cFrame = rightHand.CFrame
				local flag = nil

				for _, victim in pairs(victims) do
					local humanoidRootPart = victim:FindFirstChild("HumanoidRootPart")
					local humanoid = victim:FindFirstChild("Humanoid")

					if not (humanoidRootPart and humanoid and humanoidRootPart.Anchored) then
						continue
					end

					if humanoid.Health <= 0 or humanoid.Sit then
						continue
					end

					humanoidRootPart.CFrame = cFrame
					flag = true
				end

				if flag then
					return
				else
					return true
				end
			end)
		end
	end,
	["Combat Z Slam"] = function(player)
		local victims = player.Victims
		local character = player.Character
		local grabing = player.Grabing

		if not (victims and character and grabing) then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not (humanoidRootPart and humanoid) then
			return
		end

		local v2 = {
			[0] = CFrame.new(
				0,
				-1.087015151977539,
				0.4842376708984375,
				1,
				0,
				-0,
				0,
				0.6593197584152222,
				-0.7518627643585205,
				0,
				0.7518627643585205,
				0.6593197584152222
			),
			[8] = CFrame.new(
				0.40606689453125,
				0,
				0.29701995849609375,
				-0.1414673924446106,
				0.968265950679779,
				0.20602914690971375,
				0.02166091650724411,
				0.21110008656978607,
				-0.9772244691848755,
				-0.9897058010101318,
				-0.13378259539604187,
				-0.05083729326725006
			),
			[20] = CFrame.new(
				0.677001953125,
				1.2189924716949463,
				0.29701995849609375,
				0.9138034582138062,
				-0.23198716342449188,
				0.3333844840526581,
				0.17355509102344513,
				-0.5190819501876831,
				-0.8369187712669373,
				0.3672080636024475,
				0.8226395845413208,
				-0.4340765178203583
			),
			[25] = CFrame.new(
				0.677001953125,
				0.789193868637085,
				0.5218505859375,
				0.9138035178184509,
				-0.13661926984786987,
				0.38248974084854126,
				0.17355507612228394,
				-0.720076858997345,
				-0.6718394756317139,
				0.3672080338001251,
				0.6803120374679565,
				-0.6342980265617371
			),
			[30] = CFrame.new(
				0.677001953125,
				0.789193868637085,
				0.5218505859375,
				0.9138035178184509,
				-0.13661926984786987,
				0.38248974084854126,
				0.17355507612228394,
				-0.720076858997345,
				-0.6718394756317139,
				0.3672080338001251,
				0.6803120374679565,
				-0.6342980265617371
			),
			[35] = CFrame.new(
				0.677001953125,
				-3.0089776515960693,
				1.7346878051757812,
				0.9780387282371521,
				0.03350921720266342,
				0.20571167767047882,
				0.1042838916182518,
				-0.9332382678985596,
				-0.3437894880771637,
				0.18045775592327118,
				0.3576916754245758,
				-0.9162379503250122
			),
			[40] = CFrame.new(
				0.677001953125,
				-2.717702865600586,
				2.3628463745117188,
				0.9943687319755554,
				-0.06484547257423401,
				0.08382037281990051,
				-0.007145185023546219,
				-0.830165445804596,
				-0.5574713349342346,
				0.1057341992855072,
				0.5537328720092773,
				-0.8259543180465698
			),
			[50] = CFrame.new(
				0.677001953125,
				-2.819504737854004,
				2.4624557495117188,
				0.9893110990524292,
				-0.010394126176834106,
				0.14544834196567535,
				0.05602145567536354,
				-0.8938158750534058,
				-0.44492122530937195,
				0.1346285194158554,
				0.4483135938644409,
				-0.8836802840232849
			),
			[60] = CFrame.new(
				0.677001953125,
				-2.819504737854004,
				2.4624557495117188,
				0.9893110990524292,
				-0.010394126176834106,
				0.14544834196567535,
				0.05602145567536354,
				-0.8938158750534058,
				-0.44492122530937195,
				0.1346285194158554,
				0.4483135938644409,
				-0.8836802840232849
			)
		}
		local v3 = {}

		for k, _ in pairs(v2) do
			table.insert(v3, k)
		end

		table.sort(v3)
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = v2[0]
		task.spawn(function()
			for i = 1, #v3 - 1 do
				if not v2 then
					break
				end

				local v4 = v3[i]
				local v5 = v3[i + 1]
				local v6 = v2[v5]

				if not v6 then
					continue
				end

				local v7 = (v5 - v4) / 60
				local tween = TweenService:Create(cFrameValue, TweenInfo.new(v7, Enum.EasingStyle.Linear), {
					Value = v6
				})
				tween:Play()
				tween.Completed:Wait()
			end
		end)
		local cframe = CFrame.new(0.5, 0.608299971, -1.31923676, -1, 0, 0, 0, 1, 0, 0, 0, -1)
		local playOneShotAnim = PeoUtils.PlayOneShotAnim(humanoid, ReplicatedStorage.Chest.Animation.Combat.ZHit_Player)
		playOneShotAnim.Priority = Enum.AnimationPriority.Action3

		for _, victim in pairs(victims) do
			local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
			local humanoid2 = victim:FindFirstChild("Humanoid")

			if not humanoidRootPart2 or not humanoid2 or (humanoid2.Health <= 0 or humanoid2.Sit) then
				continue
			end

			local playOneShotAnim_2 = PeoUtils.PlayOneShotAnim(
				humanoid2,
				ReplicatedStorage.Chest.Animation.Combat.ZHit_Enemy
			)
			playOneShotAnim_2.Priority = Enum.AnimationPriority.Action3
		end

		FastRenderer.new({
			Time = 1.5
		}, function(_, _)
			if not grabing.Parent then
				return true
			end

			local cFrame = humanoidRootPart.CFrame * cframe * cFrameValue.Value
			local flag = nil

			for _, victim in pairs(victims) do
				local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
				local humanoid2 = victim:FindFirstChild("Humanoid")

				if not (humanoidRootPart2 and humanoid2 and humanoidRootPart2.Anchored) then
					continue
				end

				if humanoid2.Health <= 0 or humanoid2.Sit then
					continue
				end

				humanoidRootPart2.CFrame = cFrame
				flag = true
			end

			if flag then
				return
			else
				return true
			end
		end)
		table.clear(v2)
		v2 = nil
		cFrameValue:Destroy()
		cFrameValue = nil
	end,
	["Combat V"] = function(player)
		local victims = player.Victims
		local character = player.Character
		local grabing = player.Grabing

		if not (victims and character and grabing) then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not (humanoidRootPart and humanoid) then
			return
		end

		local v2 = {
			[0] = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			[9] = CFrame.new(
				-0.1705322265625,
				-0.08172178268432617,
				1.0831222534179688,
				1,
				0,
				0,
				0,
				0.9660637378692627,
				0.2583037316799164,
				0,
				-0.2583037316799164,
				0.9660637378692627
			),
			[19] = CFrame.new(
				-0.1705322265625,
				-0.21652936935424805,
				1.5841217041015625,
				1,
				0,
				0,
				0,
				0.9482603669166565,
				0.3174937069416046,
				0,
				-0.3174937069416046,
				0.9482603669166565
			),
			[29] = CFrame.new(
				-0.1705322265625,
				-0.16512298583984375,
				2.0756454467773438,
				1,
				0,
				0,
				0,
				0.9758844971656799,
				0.21828755736351013,
				0,
				-0.21828755736351013,
				0.9758844971656799
			),
			[39] = CFrame.new(
				-0.1705322265625,
				1.2103874683380127,
				1.9253311157226562,
				1,
				0,
				0,
				0,
				0.9652948975563049,
				0.26116231083869934,
				0,
				-0.26116231083869934,
				0.9652948975563049
			),
			[41] = CFrame.new(
				-0.1705322265625,
				2.173717737197876,
				2.1810302734375,
				1,
				0,
				0,
				0,
				0.8744624257087708,
				0.48509329557418823,
				0,
				-0.48509329557418823,
				0.8744624257087708
			)
		}
		local v3 = {}

		for k, _ in pairs(v2) do
			table.insert(v3, k)
		end

		table.sort(v3)
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = v2[0]
		task.spawn(function()
			for i = 1, #v3 - 1 do
				if not v2 then
					break
				end

				local v4 = v3[i]
				local v5 = v3[i + 1]
				local v6 = v2[v5]

				if not v6 then
					continue
				end

				local v7 = (v5 - v4) / 60
				local tween = TweenService:Create(cFrameValue, TweenInfo.new(v7, Enum.EasingStyle.Linear), {
					Value = v6
				})
				tween:Play()
				tween.Completed:Wait()
			end
		end)
		local cframe = CFrame.new(0.5, 0.608299971, -1.31923676, -1, 0, 0, 0, 1, 0, 0, 0, -1)

		for _, victim in pairs(victims) do
			local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
			local humanoid2 = victim:FindFirstChild("Humanoid")

			if not humanoidRootPart2 or not humanoid2 or (humanoid2.Health <= 0 or humanoid2.Sit) then
				continue
			end

			local playOneShotAnim = PeoUtils.PlayOneShotAnim(
				humanoid2,
				ReplicatedStorage.Chest.Animation.Combat.VHit_Enemy
			)
			playOneShotAnim.Priority = Enum.AnimationPriority.Action3
		end

		FastRenderer.new({
			Time = 1.5
		}, function(_, _)
			if not grabing.Parent then
				return true
			end

			local cFrame = humanoidRootPart.CFrame * cframe * cFrameValue.Value
			local flag = nil

			for _, victim in pairs(victims) do
				local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
				local humanoid2 = victim:FindFirstChild("Humanoid")

				if not (humanoidRootPart2 and humanoid2 and humanoidRootPart2.Anchored) then
					continue
				end

				if humanoid2.Health <= 0 or humanoid2.Sit then
					continue
				end

				humanoidRootPart2.CFrame = cFrame
				flag = true
			end

			if flag then
				return
			else
				return true
			end
		end)
		table.clear(v2)
		v2 = nil
		cFrameValue:Destroy()
		cFrameValue = nil
	end,
	["Shellreaper Z"] = function(player)
		local victims = player.Victims
		local character = player.Character
		local grabing = player.Grabing
		local origin = player.Origin

		if not (victims and character and grabing) then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not (humanoidRootPart and humanoid) then
			return
		end

		local v2 = {
			[0] = CFrame.new(
				3.814697265625e-6,
				2.222358226776123,
				0.8570365905761719,
				1,
				-7.753449575084725e-13,
				1.1073072797226913e-12,
				7.559018515290727e-13,
				-0.35836777091026306,
				-0.9335805177688599,
				1.1206701799187924e-12,
				0.9335805177688599,
				-0.35836777091026306
			),
			[9] = CFrame.new(
				-0.5153732299804688,
				0.33707761764526367,
				1.1243762969970703,
				0.7880107760429382,
				-0.1489420235157013,
				0.5973737239837646,
				-0.1489419937133789,
				-0.9875931739807129,
				-0.049761608242988586,
				0.5973737835884094,
				-0.04976128041744232,
				-0.8004175424575806
			),
			[10] = CFrame.new(
				0,
				-0.42999982833862305,
				0.9399986267089844,
				1,
				-0,
				0,
				0,
				-0.9455186128616333,
				-0.3255681097507477,
				0,
				0.3255681097507477,
				-0.9455186128616333
			),
			[36] = CFrame.new(
				0,
				0.880000114440918,
				1.4900016784667969,
				1,
				0,
				0,
				0,
				-0.08715561032295227,
				0.9961947202682495,
				0,
				-0.9961947202682495,
				-0.08715561032295227
			),
			[37] = CFrame.new(
				0,
				1.010000228881836,
				0,
				-0.24192187190055847,
				0.949092447757721,
				0.20173579454421997,
				1.4901161193847656e-8,
				0.2079116553068161,
				-0.9781476259231567,
				-0.9702957272529602,
				-0.23663529753684998,
				-0.05029836297035217
			),
			[59] = CFrame.new(
				0.5400009155273438,
				2.070000171661377,
				0,
				-0.24192184209823608,
				-0.08456692844629288,
				-0.9666034579277039,
				1.4901161193847656e-8,
				-0.9961946606636047,
				0.08715582638978958,
				-0.9702957272529602,
				0.021084874868392944,
				0.24100130796432495
			),
			[60] = CFrame.new(
				-2.1599998474121094,
				-0.28999972343444824,
				0.4500007629394531,
				0.08283740282058716,
				-0.4021672010421753,
				-0.9118114709854126,
				0.038596197962760925,
				0.9155641198158264,
				-0.40031611919403076,
				0.9958159923553467,
				-0.0020313337445259094,
				0.09136489778757095
			),
			[89] = CFrame.new(
				-1.6399993896484375,
				2.309999465942383,
				0,
				0.2588190734386444,
				-0.4385211169719696,
				0.8606462478637695,
				-1.4901161193847656e-8,
				-0.891006588935852,
				-0.45399048924446106,
				0.9659258723258972,
				0.11750142276287079,
				-0.2306094616651535
			),
			[90] = CFrame.new(
				0,
				2.4099998474121094,
				0,
				0.08715580403804779,
				-0.8627299666404724,
				-0.49809733033180237,
				0,
				0.4999999701976776,
				-0.8660255074501038,
				0.9961947202682495,
				0.07547914236783981,
				0.043577902019023895
			),
			[99] = CFrame.new(
				0,
				2.5,
				0,
				0.08715580403804779,
				0.34071871638298035,
				0.9361169338226318,
				-2.2351741790771484e-8,
				-0.9396926760673523,
				0.34202027320861816,
				0.9961950778961182,
				-0.02980906516313553,
				-0.08189964294433594
			),
			[100] = CFrame.new(
				0,
				2.0900001525878906,
				0,
				0.22495104372501373,
				-0.7353664040565491,
				-0.6392442584037781,
				0,
				0.6560590267181396,
				-0.7547095417976379,
				0.9743700623512268,
				0.1697726994752884,
				0.14758116006851196
			),
			[109] = CFrame.new(
				0,
				3.890000343322754,
				0,
				0.22495105862617493,
				-0.03400510177016258,
				0.9737764596939087,
				0,
				-0.9993908405303955,
				-0.034899622201919556,
				0.9743701219558716,
				0.007850691676139832,
				-0.22481399774551392
			),
			[110] = CFrame.new(
				0,
				3.5699996948242188,
				0,
				-0.019605442881584167,
				0.9986296892166138,
				-0.04852503538131714,
				-0.374093234539032,
				-0.05233600735664368,
				-0.9259132742881775,
				-0.9271838665008545,
				-5.960464477539063e-8,
				0.3746066391468048
			),
			[129] = CFrame.new(
				0.15999984741210938,
				2.4000000953674316,
				1,
				0.519663393497467,
				-0.7880564332008362,
				-0.33002588152885437,
				-0.5253594517707825,
				-0.5993620753288269,
				0.6039557456970215,
				-0.6737560629844666,
				-0.14047157764434814,
				-0.7254794836044312
			),
			[130] = CFrame.new(
				-0.056610107421875,
				0.4348788261413574,
				2.187591552734375,
				0.4128713011741638,
				-0.7547094821929932,
				-0.5098536610603333,
				0.4749540686607361,
				0.6560590267181396,
				-0.5865194797515869,
				0.7771459221839905,
				-2.9802322387695312e-8,
				0.6293203830718994
			),
			[131] = CFrame.new(
				-1.7793655395507812,
				-2.996746063232422,
				1.9040451049804688,
				-0.14055001735687256,
				-0.7896357774734497,
				-0.5972612500190735,
				-0.46608543395996094,
				0.5849941968917847,
				-0.6637364625930786,
				0.8735044598579407,
				0.18508657813072205,
				-0.450258731842041
			),
			[132] = CFrame.new(
				-3.2598934173583984,
				-4.962548732757568,
				-1.4085769653320312,
				-0.43284234404563904,
				-0.8921793103218079,
				-0.12908881902694702,
				-0.8968734741210938,
				0.41175591945648193,
				0.16147753596305847,
				-0.09091384708881378,
				0.1856706738471985,
				-0.9783971309661865
			),
			[134] = CFrame.new(
				-1.5452156066894531,
				-2.0989654064178467,
				-7.770984649658203,
				0.058996811509132385,
				-0.9838060140609741,
				0.16924899816513062,
				-0.2847524881362915,
				0.14591510593891144,
				0.9474307894706726,
				-0.9567839503288269,
				-0.10408938676118851,
				-0.27153268456459045
			),
			[135] = CFrame.new(
				-1.4192619323730469,
				-0.628678560256958,
				-7.96113395690918,
				-0.06420058757066727,
				-0.9957829713821411,
				0.06553281843662262,
				-0.17047056555747986,
				0.07564633339643478,
				0.982454776763916,
				-0.9832689762115479,
				0.051902737468481064,
				-0.17460815608501434
			),
			[136] = CFrame.new(
				-0.8610649108886719,
				0.5030817985534668,
				-8.222061157226562,
				0.03770279884338379,
				-0.9911826848983765,
				0.12702718377113342,
				0.15927410125732422,
				0.1314527988433838,
				0.9784438610076904,
				-0.9865144491195679,
				-0.01665768027305603,
				0.1628260612487793
			),
			[138] = CFrame.new(
				0.2936286926269531,
				3.2465057373046875,
				-7.235695838928223,
				0.26917362213134766,
				-0.9538295865058899,
				0.13324850797653198,
				0.7057721018791199,
				0.28949815034866333,
				0.6465886831283569,
				-0.6553104519844055,
				-0.08000144362449646,
				0.751111626625061
			),
			[139] = CFrame.new(
				0.6395072937011719,
				4.1184797286987305,
				-5.8292951583862305,
				0.37042999267578125,
				-0.9256457090377808,
				0.07721434533596039,
				0.8556827306747437,
				0.3724059462547302,
				0.35933417081832886,
				-0.3613712191581726,
				-0.06703709065914154,
				0.9300093650817871
			),
			[140] = CFrame.new(
				1.0534896850585938,
				5.086210250854492,
				-5.122690200805664,
				0.444934606552124,
				-0.8954992890357971,
				-0.010690271854400635,
				0.8951655626296997,
				0.4443497061729431,
				0.035100966691970825,
				-0.026682674884796143,
				-0.025187164545059204,
				0.9993265867233276
			),
			[145] = CFrame.new(
				0,
				1.6999998092651367,
				3.979999542236328,
				1,
				0,
				-0,
				0,
				0.5150379538536072,
				-0.8571673035621643,
				0,
				0.8571673035621643,
				0.5150379538536072
			),
			[150] = CFrame.new(
				0,
				0.8399999141693115,
				4.880001068115234,
				1,
				-1.542846184143798e-9,
				3.4204059029541156e-10,
				6.89320267532878e-11,
				-0.1736481487751007,
				-0.9848076105117798,
				1.5788017559970058e-9,
				0.9848076105117798,
				-0.1736481487751007
			)
		}
		local v3 = {}

		for k, _ in pairs(v2) do
			table.insert(v3, k)
		end

		table.sort(v3)
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = v2[0]
		task.spawn(function()
			for i = 1, #v3 - 1 do
				if not v2 then
					break
				end

				local v4 = v3[i]
				local v5 = v3[i + 1]
				local v6 = v2[v5]

				if not v6 then
					continue
				end

				local v7 = (v5 - v4) / 60
				local tween = TweenService:Create(cFrameValue, TweenInfo.new(v7, Enum.EasingStyle.Linear), {
					Value = v6
				})
				tween:Play()
				tween.Completed:Wait()
			end
		end)
		local cframe = CFrame.new(
			0,
			0,
			-2.99999905,
			-1.00000191,
			-4.47035653e-8,
			-5.96046092e-8,
			1.49011896e-8,
			1.00000191,
			1.49011559e-8,
			-1.78814048e-7,
			-4.47035191e-8,
			-1
		)

		for _, victim in pairs(victims) do
			local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
			local humanoid2 = victim:FindFirstChild("Humanoid")

			if not (humanoidRootPart2 and humanoid2 and humanoidRootPart2.Anchored) then
				continue
			end

			if humanoid2.Health <= 0 or humanoid2.Sit then
				continue
			end

			local playOneShotAnim = PeoUtils.PlayOneShotAnim(
				humanoid2,
				ReplicatedStorage.Chest.Animation.Shellreaper.ZHit_Enemy
			)
			playOneShotAnim.Priority = Enum.AnimationPriority.Action3
		end

		local playOneShotAnim_2 = PeoUtils.PlayOneShotAnim(
			humanoid,
			ReplicatedStorage.Chest.Animation.Shellreaper.ZHit_Player
		)
		playOneShotAnim_2.Priority = Enum.AnimationPriority.Action3
		FastRenderer.new({
			Time = 3
		}, function(_, _)
			if not grabing.Parent then
				return true
			end

			local cFrame = origin * cframe * cFrameValue.Value
			local flag = nil

			for _, victim in pairs(victims) do
				local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
				local humanoid2 = victim:FindFirstChild("Humanoid")

				if not (humanoidRootPart2 and humanoid2 and humanoidRootPart2.Anchored) then
					continue
				end

				if humanoid2.Health <= 0 or humanoid2.Sit then
					continue
				end

				humanoidRootPart2.CFrame = cFrame
				flag = true
			end

			HighlightModule:Update()

			if flag then
				return
			else
				return true
			end
		end)
		table.clear(v2)
		v2 = nil
		cFrameValue:Destroy()
		cFrameValue = nil
	end,
	["Shellreaper X"] = function(player)
		local victims = player.Victims
		local character = player.Character
		local grabing = player.Grabing

		if not (victims and character and grabing) then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not (humanoidRootPart and humanoid) then
			return
		end

		local v2 = {
			[0] = CFrame.new(0, -0.7100000381469727, 0, 1, 0, -0, 0, 0.5, -0.866025447845459, 0, 0.866025447845459, 0.5),
			[12] = CFrame.new(
				0,
				-0.030315876007080078,
				0.4099998474121094,
				1.000000238418579,
				-0,
				0,
				0,
				-0.12916001677513123,
				-0.9916238188743591,
				0,
				0.9916238188743591,
				-0.12915992736816406
			),
			[13] = CFrame.new(
				0.9000015258789062,
				1.1100492477416992,
				0.405059814453125,
				1,
				0,
				0,
				0,
				0.9855481386184692,
				0.1693958342075348,
				0,
				-0.16939577460289001,
				0.9855481386184692
			),
			[25] = CFrame.new(
				0.9000015258789062,
				1.1100492477416992,
				-0.014940261840820312,
				1,
				0,
				0,
				0,
				0.8314435482025146,
				0.5556093454360962,
				0,
				-0.5556092858314514,
				0.8314434885978699
			),
			[50] = CFrame.new(
				0.9000015258789062,
				0.7700490951538086,
				-1.2549400329589844,
				1,
				0,
				0,
				0,
				0.6977568864822388,
				0.7163347601890564,
				0,
				-0.7163347005844116,
				0.697756826877594
			),
			[65] = CFrame.new(
				0,
				5.079999923706055,
				0.8899993896484375,
				1,
				0,
				-0,
				0,
				0.42261824011802673,
				-0.9063078165054321,
				0,
				0.9063078165054321,
				0.42261824011802673
			),
			[75] = CFrame.new(
				0,
				6.476665496826172,
				0.7133331298828125,
				1,
				-0,
				0,
				0,
				-0.5249766707420349,
				-0.8511165380477905,
				0,
				0.8511165976524353,
				-0.5249767303466797
			),
			[95] = CFrame.new(
				0,
				1.690000057220459,
				0,
				0.9999999403953552,
				0,
				0,
				0,
				-0.7986354827880859,
				0.6018151640892029,
				0,
				-0.6018151640892029,
				-0.7986354827880859
			),
			[96] = CFrame.new(
				0,
				1.4699997901916504,
				0,
				0.9999999403953552,
				0,
				-0,
				0,
				0.9848077297210693,
				-0.17364829778671265,
				0,
				0.17364829778671265,
				0.9848077297210693
			),
			[100] = CFrame.new(
				0,
				2.559999942779541,
				0,
				0.9999999403953552,
				-0,
				0,
				0,
				-0.8571673035621643,
				-0.515038013458252,
				0,
				0.515038013458252,
				-0.8571673035621643
			),
			[101] = CFrame.new(
				0,
				1.5999999046325684,
				0,
				0.46301043033599854,
				0.6407716870307922,
				0.6123994588851929,
				-0.42815864086151123,
				0.7666533589363098,
				-0.4784587621688843,
				-0.7760809063911438,
				-0.040672753006219864,
				0.6293203830718994
			),
			[105] = CFrame.new(
				0,
				2.5199999809265137,
				0,
				-0.6184495091438293,
				0.7071070075035095,
				-0.3428122401237488,
				0.6184495091438293,
				0.7071070075035095,
				0.3428122401237488,
				0.4848096966743469,
				0,
				-0.8746196627616882
			),
			[106] = CFrame.new(
				0,
				1.5999999046325684,
				0,
				0.44743114709854126,
				-0.8512059450149536,
				0.2743244767189026,
				0.47981128096580505,
				-0.030377691611647606,
				-0.87684565782547,
				0.7547096014022827,
				0.5239520072937012,
				0.3948262333869934
			),
			[110] = CFrame.new(
				0,
				2.2300000190734863,
				0,
				0.13917315006256104,
				0.10351117700338364,
				0.984843373298645,
				-7.450580596923828e-8,
				-0.9945220351219177,
				0.10452841967344284,
				0.9902684688568115,
				-0.014547616243362427,
				-0.13841071724891663
			),
			[111] = CFrame.new(
				0,
				1.4699997901916504,
				0,
				0.9999999403953552,
				0,
				-0,
				0,
				0.9848077297210693,
				-0.17364829778671265,
				0,
				0.17364829778671265,
				0.9848077297210693
			),
			[115] = CFrame.new(
				0,
				2.559999942779541,
				0,
				0.9999999403953552,
				-0,
				0,
				0,
				-0.8571673035621643,
				-0.515038013458252,
				0,
				0.515038013458252,
				-0.8571673035621643
			),
			[116] = CFrame.new(
				0,
				1.5999999046325684,
				0,
				0.46301043033599854,
				0.6407716870307922,
				0.6123994588851929,
				-0.42815864086151123,
				0.7666533589363098,
				-0.4784587621688843,
				-0.7760809063911438,
				-0.040672753006219864,
				0.6293203830718994
			),
			[120] = CFrame.new(
				0,
				2.5199999809265137,
				0,
				-0.6184495091438293,
				0.7071070075035095,
				-0.3428122401237488,
				0.6184495091438293,
				0.7071070075035095,
				0.3428122401237488,
				0.4848096966743469,
				0,
				-0.8746196627616882
			),
			[121] = CFrame.new(
				0,
				1.5999999046325684,
				0,
				0.44743114709854126,
				-0.8512059450149536,
				0.2743244767189026,
				0.47981128096580505,
				-0.030377691611647606,
				-0.87684565782547,
				0.7547096014022827,
				0.5239520072937012,
				0.3948262333869934
			),
			[125] = CFrame.new(
				0,
				2.2300000190734863,
				0,
				0.13917315006256104,
				0.10351117700338364,
				0.984843373298645,
				-7.450580596923828e-8,
				-0.9945220351219177,
				0.10452841967344284,
				0.9902684688568115,
				-0.014547616243362427,
				-0.13841071724891663
			),
			[126] = CFrame.new(
				0,
				1.4699997901916504,
				0,
				0.9999999403953552,
				0,
				-0,
				0,
				0.9848077297210693,
				-0.17364829778671265,
				0,
				0.17364829778671265,
				0.9848077297210693
			),
			[130] = CFrame.new(
				0,
				2.559999942779541,
				0,
				0.9999999403953552,
				-0,
				0,
				0,
				-0.8571673035621643,
				-0.515038013458252,
				0,
				0.515038013458252,
				-0.8571673035621643
			),
			[131] = CFrame.new(
				0,
				1.5999999046325684,
				0,
				0.46301043033599854,
				0.6407716870307922,
				0.6123994588851929,
				-0.42815864086151123,
				0.7666533589363098,
				-0.4784587621688843,
				-0.7760809063911438,
				-0.040672753006219864,
				0.6293203830718994
			),
			[135] = CFrame.new(
				0,
				2.5199999809265137,
				0,
				-0.6184495091438293,
				0.7071070075035095,
				-0.3428122401237488,
				0.6184495091438293,
				0.7071070075035095,
				0.3428122401237488,
				0.4848096966743469,
				0,
				-0.8746196627616882
			),
			[136] = CFrame.new(
				0,
				1.5999999046325684,
				0,
				0.44743114709854126,
				-0.8512059450149536,
				0.2743244767189026,
				0.47981128096580505,
				-0.030377691611647606,
				-0.87684565782547,
				0.7547096014022827,
				0.5239520072937012,
				0.3948262333869934
			),
			[140] = CFrame.new(
				0,
				2.2300000190734863,
				0,
				0.13917315006256104,
				0.10351117700338364,
				0.984843373298645,
				-7.450580596923828e-8,
				-0.9945220351219177,
				0.10452841967344284,
				0.9902684688568115,
				-0.014547616243362427,
				-0.13841071724891663
			),
			[141] = CFrame.new(
				0,
				1.5999999046325684,
				0,
				0.7313537001609802,
				0.6819983720779419,
				0,
				-0.6819983720779419,
				0.7313537001609802,
				0,
				-0,
				0,
				1
			),
			[145] = CFrame.new(
				0,
				2.8299999237060547,
				0,
				-0.5446390509605408,
				0.838670551776886,
				-0,
				-0.5611801147460938,
				-0.36443468928337097,
				-0.7431448698043823,
				-0.6232537031173706,
				-0.4047456979751587,
				0.6691306233406067
			),
			[166] = CFrame.new(
				0,
				5.760000228881836,
				0,
				0.03799217939376831,
				-0.9693254232406616,
				-0.24282673001289368,
				0.780480682849884,
				-0.12296479940414429,
				0.612967848777771,
				-0.6240243911743164,
				-0.2128094732761383,
				0.7518681287765503
			),
			[167] = CFrame.new(
				0,
				-0.9099998474121094,
				0,
				-0.06975648552179337,
				-0.9951341152191162,
				0.06958655267953873,
				0,
				-0.06975647807121277,
				-0.9975641965866089,
				0.9975641965866089,
				-0.06958656013011932,
				0.004865966737270355
			),
			[170] = CFrame.new(
				0.09000015258789062,
				-0.619999885559082,
				0,
				-0.06975648552179337,
				-0.8807967901229858,
				0.468328058719635,
				0,
				-0.46947160363197327,
				-0.8829476833343506,
				0.9975641965866089,
				-0.06159131973981857,
				0.03274868428707123
			)
		}
		local v3 = {
			[0] = CFrame.new(
				0,
				0,
				0,
				1.0000038146972656,
				-5.960487214906607e-8,
				2.3841900542720396e-7,
				-5.960487214906607e-8,
				1.0000038146972656,
				-5.96047655676557e-8,
				2.3841900542720396e-7,
				-5.96047655676557e-8,
				1
			),
			[75] = CFrame.new(
				0,
				0,
				2.359999656677246,
				1.0000019073486328,
				-2.980236502025946e-8,
				1.1920937481590954e-7,
				-2.980239344196889e-8,
				1.0000019073486328,
				-2.980235436211842e-8,
				1.1920938902676426e-7,
				-2.9802347256691064e-8,
				1
			),
			[85] = CFrame.new(
				0,
				0,
				3.859999656677246,
				1.0000038146972656,
				-5.960487214906607e-8,
				2.3841900542720396e-7,
				-5.960487214906607e-8,
				1.0000038146972656,
				-5.96047655676557e-8,
				2.3841900542720396e-7,
				-5.96047655676557e-8,
				1
			),
			[95] = CFrame.new(
				0,
				-1.1670302152633667,
				2.1315078735351562,
				1.0000038146972656,
				-3.0789344407367025e-9,
				2.523762816508679e-7,
				-8.883102964318823e-8,
				0.694661021232605,
				-0.7193412184715271,
				1.8806217383371404e-7,
				0.7193410992622375,
				0.6946583986282349
			),
			[100] = CFrame.new(
				-3.814697265625e-6,
				7.885242462158203,
				-9.612902641296387,
				1.0000038146972656,
				-3.0789344407367025e-9,
				2.523762816508679e-7,
				-8.883102964318823e-8,
				0.694661021232605,
				-0.7193412184715271,
				1.8806217383371404e-7,
				0.7193410992622375,
				0.6946583986282349
			),
			[101] = CFrame.new(
				-13.332530975341797,
				-2.7918543815612793,
				2.891042709350586,
				0.46947339177131653,
				9.247806076473353e-9,
				-0.8829491138458252,
				-0.6133493781089783,
				0.7193425893783569,
				-0.3261232078075409,
				0.635140597820282,
				0.6946597099304199,
				0.33770957589149475
			),
			[105] = CFrame.new(
				16.166812896728516,
				8.103904724121094,
				-8.391823768615723,
				0.46947339177131653,
				9.247806076473353e-9,
				-0.8829491138458252,
				-0.6133493781089783,
				0.7193425893783569,
				-0.3261232078075409,
				0.635140597820282,
				0.6946597099304199,
				0.33770957589149475
			),
			[106] = CFrame.new(
				10.25259780883789,
				10.826057434082031,
				4.328758239746094,
				0.7193425297737122,
				-0.08465802669525146,
				0.6894820332527161,
				-0.47375771403312683,
				0.6661171317100525,
				0.5760623216629028,
				-0.5080417394638062,
				-0.741030752658844,
				0.4390557110309601
			),
			[110] = CFrame.new(
				-7.8807830810546875,
				-4.324386119842529,
				-7.21840763092041,
				0.7193425297737122,
				-0.08465802669525146,
				0.6894820332527161,
				-0.47375771403312683,
				0.6661171317100525,
				0.5760623216629028,
				-0.5080417394638062,
				-0.741030752658844,
				0.4390557110309601
			),
			[111] = CFrame.new(
				3.886383056640625,
				-6.394941329956055,
				4.799280166625977,
				0.777148962020874,
				0.452696830034256,
				0.43716368079185486,
				2.7599574181635944e-8,
				0.694661021232605,
				-0.7193412780761719,
				-0.6293213367462158,
				0.5590333342552185,
				0.5398508310317993
			),
			[115] = CFrame.new(
				-9.005558013916016,
				14.818427085876465,
				-11.120938301086426,
				0.777148962020874,
				0.452696830034256,
				0.43716368079185486,
				2.7599574181635944e-8,
				0.694661021232605,
				-0.7193412780761719,
				-0.6293213367462158,
				0.5590333342552185,
				0.5398508310317993
			),
			[116] = CFrame.new(
				-7.50054931640625,
				-5.181511878967285,
				-8.984610557556152,
				-0.5246855616569519,
				-0.5772132873535156,
				-0.6257284283638,
				-0.21919429302215576,
				0.8018482327461243,
				-0.5558774471282959,
				0.8225957155227661,
				-0.15450437366962433,
				-0.5472357869148254
			),
			[120] = CFrame.new(
				8.336629867553711,
				8.887738227844238,
				4.865941047668457,
				-0.5246855616569519,
				-0.5772132873535156,
				-0.6257284283638,
				-0.21919429302215576,
				0.8018482327461243,
				-0.5558774471282959,
				0.8225957155227661,
				-0.15450437366962433,
				-0.5472357869148254
			),
			[121] = CFrame.new(
				-13.332530975341797,
				-2.7918543815612793,
				2.891042709350586,
				0.46947339177131653,
				9.247806076473353e-9,
				-0.8829491138458252,
				-0.6133493781089783,
				0.7193425893783569,
				-0.3261232078075409,
				0.635140597820282,
				0.6946597099304199,
				0.33770957589149475
			),
			[125] = CFrame.new(
				16.166812896728516,
				8.103904724121094,
				-8.391823768615723,
				0.46947339177131653,
				9.247806076473353e-9,
				-0.8829491138458252,
				-0.6133493781089783,
				0.7193425893783569,
				-0.3261232078075409,
				0.635140597820282,
				0.6946597099304199,
				0.33770957589149475
			),
			[126] = CFrame.new(
				10.25259780883789,
				10.826057434082031,
				4.328758239746094,
				0.7193425297737122,
				-0.08465802669525146,
				0.6894820332527161,
				-0.47375771403312683,
				0.6661171317100525,
				0.5760623216629028,
				-0.5080417394638062,
				-0.741030752658844,
				0.4390557110309601
			),
			[130] = CFrame.new(
				-7.8807830810546875,
				-4.324386119842529,
				-7.21840763092041,
				0.7193425297737122,
				-0.08465802669525146,
				0.6894820332527161,
				-0.47375771403312683,
				0.6661171317100525,
				0.5760623216629028,
				-0.5080417394638062,
				-0.741030752658844,
				0.4390557110309601
			),
			[131] = CFrame.new(
				3.886383056640625,
				-6.394941329956055,
				4.799280166625977,
				0.777148962020874,
				0.452696830034256,
				0.43716368079185486,
				2.7599574181635944e-8,
				0.694661021232605,
				-0.7193412780761719,
				-0.6293213367462158,
				0.5590333342552185,
				0.5398508310317993
			),
			[135] = CFrame.new(
				-9.005558013916016,
				14.818427085876465,
				-11.120938301086426,
				0.777148962020874,
				0.452696830034256,
				0.43716368079185486,
				2.7599574181635944e-8,
				0.694661021232605,
				-0.7193412780761719,
				-0.6293213367462158,
				0.5590333342552185,
				0.5398508310317993
			),
			[136] = CFrame.new(
				-7.50054931640625,
				-5.181511878967285,
				-8.984610557556152,
				-0.5246855616569519,
				-0.5772132873535156,
				-0.6257284283638,
				-0.21919429302215576,
				0.8018482327461243,
				-0.5558774471282959,
				0.8225957155227661,
				-0.15450437366962433,
				-0.5472357869148254
			),
			[140] = CFrame.new(
				8.336629867553711,
				8.887738227844238,
				4.865941047668457,
				-0.5246855616569519,
				-0.5772132873535156,
				-0.6257284283638,
				-0.21919429302215576,
				0.8018482327461243,
				-0.5558774471282959,
				0.8225957155227661,
				-0.15450437366962433,
				-0.5472357869148254
			),
			[141] = CFrame.new(
				0,
				-7.230012893676758,
				-2.9799985885620117,
				1.0000038146972656,
				-5.960487214906607e-8,
				2.3841900542720396e-7,
				-5.960487214906607e-8,
				1.0000038146972656,
				-5.96047655676557e-8,
				2.3841900542720396e-7,
				-5.96047655676557e-8,
				1
			),
			[145] = CFrame.new(
				0,
				7.5571136474609375,
				-0.3971986770629883,
				1.0000038146972656,
				-2.7374824185244506e-7,
				2.8575109922712727e-7,
				1.0707090325468016e-7,
				0.60181725025177,
				-0.7986371517181396,
				3.8095600984888733e-7,
				0.7986370325088501,
				0.6018150448799133
			),
			[155] = CFrame.new(
				0,
				9.787370681762695,
				-1.333785057067871,
				1.0000019073486328,
				-1.941592842058526e-7,
				-3.802703929522977e-9,
				1.292284537157684e-7,
				0.967627227306366,
				0.25239139795303345,
				1.930941806449482e-7,
				-0.25239095091819763,
				0.9676253795623779
			),
			[166] = CFrame.new(
				0,
				8.551698684692383,
				-2.37014102935791,
				1.0000038146972656,
				8.000171902722286e-8,
				6.92813131308867e-8,
				1.0707091746553488e-7,
				0.01745249703526497,
				0.9998496174812317,
				3.8095595300546847e-7,
				-0.9998495578765869,
				0.017452403903007507
			),
			[170] = CFrame.new(
				0,
				9.521553039550781,
				-2.3532114028930664,
				1.0000038146972656,
				8.000171902722286e-8,
				6.92813131308867e-8,
				1.0707091746553488e-7,
				0.01745249703526497,
				0.9998496174812317,
				3.8095595300546847e-7,
				-0.9998495578765869,
				0.017452403903007507
			)
		}
		local v4 = {}
		local v5 = {}

		for k, _ in pairs(v3) do
			table.insert(v4, k)
		end

		for k, _ in pairs(v2) do
			table.insert(v5, k)
		end

		table.sort(v4)
		table.sort(v5)
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = v3[0]
		local cFrameValue2 = Instance.new("CFrameValue")
		cFrameValue2.Value = v2[0]
		local thread = task.spawn(function()
			for i = 1, #v5 - 1 do
				if not v2 then
					break
				end

				local v6 = v5[i]
				local v7 = v5[i + 1]
				local v8 = v2[v7]

				if not v8 then
					continue
				end

				local v9 = (v7 - v6) / 60
				local tween = TweenService:Create(cFrameValue2, TweenInfo.new(v9, Enum.EasingStyle.Linear), {
					Value = v8
				})
				tween:Play()
				tween.Completed:Wait()
			end
		end)
		local thread2 = task.spawn(function()
			for i = 1, #v4 - 1 do
				if not v3 then
					break
				end

				local v6 = v4[i]
				local v7 = v4[i + 1]
				local v8 = v3[v7]

				if not v8 then
					continue
				end

				local v9 = (v7 - v6) / 60
				local tween = TweenService:Create(cFrameValue, TweenInfo.new(v9, Enum.EasingStyle.Linear), {
					Value = v8
				})
				tween:Play()
				tween.Completed:Wait()
			end
		end)
		local cFrame = humanoidRootPart.CFrame
		local cframe = CFrame.new(
			0,
			0,
			-2.99999905,
			-1.00000191,
			-4.47035653e-8,
			-5.96046092e-8,
			1.49011896e-8,
			1.00000191,
			1.49011559e-8,
			-1.78814048e-7,
			-4.47035191e-8,
			-1
		)
		local playOneShotAnim = PeoUtils.PlayOneShotAnim(
			humanoid,
			ReplicatedStorage.Chest.Animation.Shellreaper.XHit_Player
		)
		playOneShotAnim.Priority = Enum.AnimationPriority.Action3

		for _, victim in pairs(victims) do
			local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
			local humanoid2 = victim:FindFirstChild("Humanoid")

			if not (humanoidRootPart2 and humanoid2 and humanoidRootPart2.Anchored) then
				continue
			end

			if humanoid2.Health <= 0 or humanoid2.Sit then
				continue
			end

			local playOneShotAnim_2 = PeoUtils.PlayOneShotAnim(
				humanoid2,
				ReplicatedStorage.Chest.Animation.Shellreaper.XHit_Enemy
			)
			playOneShotAnim_2.Priority = Enum.AnimationPriority.Action3
		end

		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.CFrame = cFrame * cframe

		if localPlayer.Character == character then
			workspace.CurrentCamera.CameraSubject = part
		end

		FastRenderer.new({
			Time = 3
		}, function(_, _)
			if not grabing.Parent then
				return true
			end

			local cFrame2 = cFrame * cframe * cFrameValue2.Value
			humanoidRootPart.CFrame = cFrame * cFrameValue.Value

			for _, victim in pairs(victims) do
				local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
				local humanoid2 = victim:FindFirstChild("Humanoid")

				if not (humanoidRootPart2 and humanoid2 and humanoidRootPart2.Anchored) then
					continue
				end

				if humanoid2.Health <= 0 or humanoid2.Sit then
					continue
				end

				humanoidRootPart2.CFrame = cFrame2
			end

			HighlightModule:Update()
		end)

		if localPlayer.Character == character then
			workspace.CurrentCamera.CameraSubject = humanoid
		end

		task.delay(3, function()
			task.cancel(thread)
			task.cancel(thread2)
			table.clear(v2)
			table.clear(v3)
			v2 = nil
			v3 = nil
			part:Destroy()
			cFrameValue:Destroy()
			cFrameValue2:Destroy()
			cFrameValue = nil
			cFrameValue2 = nil
		end)
	end
}
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Remotes").Events.ComboEvent.OnClientEvent:Connect(function(childName, p)
	if script.Combos:FindFirstChild(childName) then
		local module = require(script.Combos[childName])
		module(p)
	else
		if not v[childName] then
			return
		end

		v[childName](p)
	end
end)