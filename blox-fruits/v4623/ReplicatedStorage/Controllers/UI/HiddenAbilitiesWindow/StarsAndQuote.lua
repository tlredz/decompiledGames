return function(instance)
	local v = {
		Images = {
			{
				Instance = instance.Background.StarContainer.Stars1,
				Image = "http://www.roblox.com/asset/?id=7481427519"
			},
			{
				Instance = instance.Background.StarContainer.Stars1.Glow,
				Image = "http://www.roblox.com/asset/?id=7487839997"
			},
			{
				Instance = instance.Background.StarContainer.Stars1.Glow,
				Image = "http://www.roblox.com/asset/?id=7487865791"
			}
		},
		Tween = 0
	}
	local TweenService = game:GetService("TweenService")
	v.Tween = TweenService:Create(
		instance.Background.StarContainer.Stars1,
		TweenInfo.new(12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
		{
			Position = UDim2.fromOffset(0, -600)
		}
	)
	local v2 = {
		Images = {
			{
				Instance = instance.Background.StarContainer.Stars2,
				Image = "http://www.roblox.com/asset/?id=7481437100"
			},
			{
				Instance = instance.Background.StarContainer.Stars2.Glow,
				Image = "http://www.roblox.com/asset/?id=7487867417"
			},
			{
				Instance = instance.Background.StarContainer.Stars2.Streak,
				Image = "http://www.roblox.com/asset/?id=7487866023"
			}
		},
		Tween = 0
	}
	local TweenService2 = game:GetService("TweenService")
	v2.Tween = TweenService2:Create(
		instance.Background.StarContainer.Stars2,
		TweenInfo.new(24, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
		{
			Position = UDim2.fromOffset(0, -600)
		}
	)
	local v3 = {
		Images = {
			{
				Instance = instance.Background.StarContainer.Stars3,
				Image = "http://www.roblox.com/asset/?id=7481443970"
			},
			{
				Instance = instance.Background.StarContainer.Stars3.Glow,
				Image = "http://www.roblox.com/asset/?id=7487840544"
			},
			{
				Instance = instance.Background.StarContainer.Stars3.Streak,
				Image = "http://www.roblox.com/asset/?id=7487866383"
			}
		},
		Tween = 0
	}
	local TweenService3 = game:GetService("TweenService")
	v3.Tween = TweenService3:Create(
		instance.Background.StarContainer.Stars3,
		TweenInfo.new(30, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
		{
			Position = UDim2.fromOffset(0, -600)
		}
	)
	local v4 = { v, v2, v3 }
	local v5 = {
		"Lab Tip: Swords infused with Aura seem to cut through almost anything. Avoid testing on lab walls.",
		"Observation Log: Pirates caught staring at the sky for falling fruits. No confirmed cases yet... but we'll keep watching.",
		"Fact #209: Sea Beasts show territorial behavior. Study interrupted when last intern got eaten.",
		"Analysis: Fruit regeneration rate appears random. Conclusion: Someone, somewhere, is hoarding them all.",
		"Scientific Note: Bounty hunters' aggression increases exponentially with your bounty. Formula pending (and scary).",
		"Experiment: Tried giving a Terrorshark a Blox Fruit. Results: Unavailable. (Terrorshark swam away very fast.)",
		"Observation #345: Lightning users are still immune to electrocution. Plugged one into a generator. Generator exploded. User smiled.",
		"Log Entry: Attempted to bottle a Flame user’s fire. Conclusion: We now have a new hole in the lab wall. Not recommended.",
		"Theory in Progress: Players who spin for fruits at 3 AM might have better luck. Pending peer-reviewed data (and sleep deprivation).",
		"Research Note: Ice users keep skating across the ocean. Experiment to follow them in a boat failed — now looking for faster boats.",
		"Field Test: Trying to catch a Phoenix user in mid-flight for study. Results inconclusive. Net caught fire.",
		"Scientific Memo: Gravity users reported creating craters in PvP fights. Reminder to avoid standing still during 'tests'.",
		"Analysis #199: Creation users continue to withhold the secrets behind their magic. Attempted covert observation — results were... unfavorable.",
		"Note to Self: Trying to pick up a Dark user’s black hole... results in immediate regret. Possibly compressed for a week.",
		"Lab Finding: Blade users officially immune to swords. Testing cannonballs next. For science.",
		"Weekend Hypothesis: Rare fruits spawn more when no one is looking. Need more volunteers to 'look away'. Possible cover story for fruit hoarders.",
		"Warning: Sand users keep turning the lab floor into a beach. Not covered by marine insurance.",
		"Experiment #872: Can you eat two Blox Fruits? Do not attempt.",
		"Observation: Buddhas take up a lot of space. Scientific suggestion: Build a bigger lab... or smaller Buddhas.",
		"Entry #404: Dragon user spotted flying over lab. Unable to catch for interview. Current plan: Build bigger net.",
		"Curiosity Log: Trying to Awaken a fruit while asleep. Mixed results. Subject now sleep-punching.",
		"Research Observation: Spirit users create friends from thin air. Considering asking them to conjure more lab assistants.",
		"Lab Report: Portal users keep showing up uninvited. Latest one appeared during lunch. Sandwich stolen.",
		"Classified Note: Evidence suggests fruits might be watching us. Fruit rolled off table on its own. Further study needed. Or exorcist.",
		"Secret File: Someone tried to combine Dough and Ice fruits. Results: Cold pastries. Delicious but unstable.",
		"Confidential: Testing if fruits grow faster when sung to. Early results: Intern looks silly. No fruits yet.",
		"Restricted Note: Venom user offered to 'help' with experiments. All lab equipment now melting. Mistakes were made.",
		"File #999: Attempting to analyze Tiger user transformations. First attempt failed when subject ran up a tree. Second attempt still pending.",
		"Weekend Study: Rumors of rarer fruit spawns increase on weekends. Testing involves a lot of waiting. And snacks.",
		"Hypothesis: Shouting 'Talon Lighter!' increases punch strength. Experiment failed, but it looked cool.",
		"Field Note #77: Pirates duel more frequently on weekends. Possible social bonding mechanism or pure chaos? Both.",
		"Theory: Fruit Dealer appears more mysterious on weekends. Same inventory, but 42% more suspicious looks.",
		"Observation: Stormy weather seems to increase Sea Beast activity. Maybe they just like dramatic entrances.",
		"Scientific Fact: Gravity still works on weekends. Tested by jumping off cliffs. (Intern recovering.)"
	}
	local v6 = false

	local function generateQuote()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function getCurrentDay()
			return os.date("*t").wday
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getDailySeed()
			local v7 = os.date("*t")
			return (tonumber(v7.year .. string.format("%02d", v7.month) .. string.format("%02d", v7.day)))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getDailyQuote()
			local _ = getCurrentDay() -- equivalent call inferred; original call site unknown
			local dailySeed = getDailySeed() -- equivalent call inferred; original call site unknown
			return v5[Random.new(dailySeed):NextInteger(1, #v5)]
		end

		local dailyQuote = getDailyQuote() -- equivalent call inferred; original call site unknown
		local quote = instance:FindFirstChild("Quote", true)
		quote.Text = string.format("\"%s\"", dailyQuote)
	end

	return function(flag: boolean)
		for _, v7 in pairs(v4) do
			if flag then
				if not v6 then
					for _, image in pairs(v7.Images) do
						image.Instance.Image = image.Image
					end
				end

				if v7.Tween.PlaybackState ~= Enum.PlaybackState.Playing then
					v7.Tween:Play()
				end
			elseif v7.Tween.PlaybackState == Enum.PlaybackState.Playing then
				v7.Tween:Pause()
			end
		end

		if flag and not v6 then
			task.spawn(generateQuote)
			v6 = true
		end
	end
end