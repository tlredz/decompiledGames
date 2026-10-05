local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JobUtil = require(ReplicatedStorage.Modules.Shared.Game.JobUtil)
local Jobs = {
	Entries = {
		{
			Icon = "rbxassetid://5650351691",
			JobTitle = "Dancer",
			Filter = "Arts",
			Name = "5650351691",
			Text = "Dancer"
		},
		{
			Icon = "rbxassetid://5183368377",
			JobTitle = "Grocery Store",
			Filter = "Shop",
			Name = "5183368377",
			Text = "Grocery Store"
		},
		{
			Icon = "rbxassetid://102332132788525",
			JobTitle = "Police",
			Filter = "Service",
			Name = "102332132788525",
			Text = "Police"
		},
		{
			Icon = "rbxassetid://5183367120",
			JobTitle = "Hospital",
			Filter = "Service",
			Name = "5183367120",
			Text = "Hospital"
		},
		{
			Icon = "rbxassetid://5183367388",
			JobTitle = "Fire House",
			Filter = "Service",
			Name = "5183367388",
			Text = "Fire House"
		},
		{
			Icon = "rbxassetid://5183367647",
			JobTitle = "Teacher",
			Filter = "Family",
			Name = "5183367647",
			Text = "Teacher"
		},
		{
			Icon = "rbxassetid://5183367956",
			JobStatus = false,
			JobTitle = "Student",
			Filter = "Family",
			Name = "5183367956",
			Text = "Student"
		},
		{
			Icon = "rbxassetid://124884292990831",
			JobTitle = "Bank",
			Filter = "Service",
			Name = "124884292990831",
			Text = "Bank"
		},
		{
			Icon = "rbxassetid://89600705047235",
			JobTitle = "S.W.A.T.",
			Filter = "Service",
			Name = "89600705047235",
			Text = "S.W.A.T."
		},
		{
			Icon = "rbxassetid://110506069282885",
			JobTitle = "Animal Adoption",
			Filter = "Outdoors",
			Name = "110506069282885",
			Text = "Animal Adoption"
		},
		{
			Icon = "rbxassetid://135259613492463",
			JobTitle = "Veterinarian",
			Filter = "Service",
			Name = "135259613492463",
			Text = "Veterinarian"
		},
		{
			Icon = "rbxassetid://115822568339223",
			JobTitle = "Postal Worker",
			Filter = "Service",
			Name = "115822568339223",
			Text = "Postal Worker"
		},
		{
			Icon = "rbxassetid://5220910709",
			JobTitle = "Actor",
			Filter = "Arts",
			Name = "5220910709",
			Text = "Actor"
		},
		{
			Icon = "rbxassetid://5220911077",
			JobTitle = "Babysitter",
			Filter = "Family",
			Name = "5220911077",
			Text = "Babysitter"
		},
		{
			Icon = "rbxassetid://5194478867",
			JobTitle = "Club Brooks",
			Filter = "Arts",
			Name = "5220911388",
			Text = "Club Brooks"
		},
		{
			Icon = "rbxassetid://5220911689",
			JobTitle = "Driver",
			Filter = "Service",
			Name = "5220911689",
			Text = "Driver"
		},
		{
			Icon = "rbxassetid://5220912396",
			JobTitle = "Repairman",
			Filter = "Service",
			Name = "5220912396",
			Text = "Repairman"
		},
		{
			Icon = "rbxassetid://5183366461",
			JobTitle = "Hair & Nails",
			Filter = "Shop",
			Name = "5183366461",
			Text = "Hair & Nails"
		},
		{
			Icon = "rbxassetid://107335656413344",
			JobTitle = "Police",
			Filter = "Service",
			Name = "107335656413344",
			Text = "Sheriff"
		},
		{
			Icon = "rbxassetid://5221907149",
			JobTitle = "Criminal",
			Filter = "Service",
			Name = "5221907149",
			Text = "Criminal"
		},
		{
			Icon = "rbxassetid://5288268854",
			JobTitle = "Athlete",
			Filter = "Outdoors",
			Name = "5288268854",
			Text = "Athlete"
		},
		{
			Icon = "rbxassetid://5288269506",
			JobTitle = "Chef",
			Filter = "Shop",
			Name = "5288269506",
			Text = "Chef"
		},
		{
			Icon = "rbxassetid://5288269991",
			JobTitle = "Model",
			Filter = "Arts",
			Name = "5288269991",
			Text = "Model"
		},
		{
			Icon = "rbxassetid://5288270536",
			JobTitle = "Singer",
			Filter = "Arts",
			Name = "5288270536",
			Text = "Singer"
		},
		{
			Icon = "rbxassetid://5288270956",
			JobTitle = "Musician",
			Filter = "Arts",
			Name = "5288270956",
			Text = "Musician"
		},
		{
			Icon = "rbxassetid://5288271356",
			JobTitle = "News Reporter",
			Filter = "Arts",
			Name = "5288271356",
			Text = "News"
		},
		{
			Icon = "rbxassetid://5288271900",
			JobTitle = "UTuber",
			Filter = "Arts",
			Name = "5288271900",
			Text = "UTuber"
		},
		{
			Icon = "rbxassetid://5288302265",
			JobTitle = "Principal",
			Filter = "Family",
			Name = "5288302265",
			Text = "Principal"
		},
		{
			Icon = "rbxassetid://5628037969",
			JobTitle = "Day Care",
			Filter = "Family",
			Name = "5628037969",
			Text = "Day Care"
		},
		{
			Icon = "rbxassetid://5628038278",
			JobTitle = "Detective",
			Filter = "Service",
			Name = "5628038278",
			Text = "Detective"
		},
		{
			Icon = "rbxassetid://5628038512",
			JobTitle = "Gamer",
			Filter = "Arts",
			Name = "5628038512",
			Text = "Gamer"
		},
		{
			Icon = "rbxassetid://5628038790",
			JobTitle = "Ice Cream",
			Filter = "Shop",
			Name = "5628038790",
			Text = "Ice Cream"
		},
		{
			Icon = "rbxassetid://5628039126",
			JobTitle = "Lifeguard",
			Filter = "Outdoors",
			Name = "5628039126",
			Text = "Lifeguard"
		},
		{
			Icon = "rbxassetid://5628039390",
			JobTitle = "Maid",
			Filter = "Family",
			Name = "5628039390",
			Text = "Maid"
		},
		{
			Icon = "rbxassetid://5628061189",
			JobTitle = "Mayor",
			Filter = "Service",
			Name = "5628061189",
			Text = "Mayor"
		},
		{
			Icon = "rbxassetid://5629610995",
			JobTitle = "Clothing",
			Filter = "Shop",
			Name = "5629610995",
			Text = "Clothing"
		},
		{
			Icon = "rbxassetid://5650351950",
			JobTitle = "Bodyguard",
			Filter = "Service",
			Name = "5650351950",
			Text = "Bodyguard"
		},
		{
			Icon = "rbxassetid://18458871100",
			JobTitle = "VIP",
			Filter = "Arts",
			Name = "18458871100",
			Text = "VIP"
		},
		{
			Icon = "rbxassetid://5220912689",
			JobTitle = "Stables",
			Filter = "Outdoors",
			Name = "5220912689",
			Text = "Stables"
		},
		{
			Icon = "rbxassetid://9892927005",
			JobTitle = "Police",
			Filter = "Service",
			Name = "9892927005",
			Text = "Military Police"
		},
		{
			Icon = "rbxassetid://5850104324",
			JobTitle = "At home dad",
			Filter = "Family",
			Name = "5850104324",
			Text = "At home dad"
		},
		{
			Icon = "rbxassetid://5850110272",
			JobTitle = "At home mom",
			Filter = "Family",
			Name = "5850110272",
			Text = "At home mom"
		},
		{
			Icon = "rbxassetid://5902104742",
			JobTitle = "Church",
			Filter = "Family",
			Name = "5902104742",
			Text = "Church"
		},
		{
			Icon = "rbxassetid://5946945591",
			JobTitle = "Flight Attendant",
			Filter = "Service",
			Name = "5946945591",
			Text = "Flight Attendant"
		},
		{
			Icon = "rbxassetid://5946945864",
			JobTitle = "Pilot",
			Filter = "Service",
			Name = "5946945864",
			Text = "Pilot"
		},
		{
			Icon = "rbxassetid://6101760087",
			JobTitle = "Security",
			Filter = "Service",
			Name = "6101760087",
			Text = "Security"
		},
		{
			Icon = "rbxassetid://6241338674",
			JobTitle = "Spy",
			Filter = "Service",
			Name = "6241338674",
			Text = "Spy"
		},
		{
			Icon = "rbxassetid://6241338791",
			JobTitle = "Writer",
			Filter = "Arts",
			Name = "6241338791",
			Text = "Writer"
		},
		{
			Icon = "rbxassetid://6241338896",
			JobTitle = "Office Worker",
			Filter = "Service",
			Name = "6241338896",
			Text = "Office Worker"
		},
		{
			Icon = "rbxassetid://6241436456",
			JobTitle = "Mo's Pizza",
			Filter = "Shop",
			Name = "6241436456",
			Text = "Mo's Pizza"
		},
		{
			Icon = "rbxassetid://7397453524",
			JobTitle = "Taxi Driver",
			Filter = "Service",
			Name = "7397453524",
			Text = "Taxi Driver"
		},
		{
			Icon = "rbxassetid://7397453638",
			JobTitle = "Sell Houses",
			Filter = "Service",
			Name = "7397453638",
			Text = "Sell Houses"
		},
		{
			Icon = "rbxassetid://7397453882",
			JobTitle = "Park Ranger",
			Filter = "Outdoors",
			Name = "7397453882",
			Text = "Park Ranger"
		},
		{
			Icon = "rbxassetid://7397454012",
			JobTitle = "Military",
			Filter = "Service",
			Name = "7397454012",
			Text = "Military"
		},
		{
			Icon = "rbxassetid://7397454603",
			JobTitle = "Fitness Trainer",
			Filter = "Service",
			Name = "7397454603",
			Text = "Fitness Trainer"
		},
		{
			Icon = "rbxassetid://7483903987",
			JobTitle = "Dentist",
			Filter = "Service",
			Name = "7483903987",
			Text = "Dentist"
		},
		{
			Icon = "rbxassetid://7490583830",
			JobTitle = "Librarian",
			Filter = "Arts",
			Name = "7490583830",
			Text = "Librarian"
		},
		{
			Icon = "rbxassetid://7490584074",
			JobTitle = "Patient",
			Filter = "Service",
			Name = "7490584074",
			Text = "Patient"
		},
		{
			Icon = "rbxassetid://7490584224",
			JobTitle = "Janitor",
			Filter = "Service",
			Name = "7490584224",
			Text = "Janitor"
		},
		{
			Icon = "rbxassetid://7490584319",
			JobTitle = "Adoption Worker",
			Filter = "Family",
			Name = "7490584319",
			Text = "Adoption Worker"
		},
		{
			Icon = "rbxassetid://7490584723",
			JobTitle = "Tow Truck Driver",
			Filter = "Service",
			Name = "7490584723",
			Text = "Tow Truck Driver"
		},
		{
			Icon = "rbxassetid://7490972344",
			JobTitle = "Volunteer Worker",
			Filter = "Service",
			Name = "7490972344",
			Text = "Volunteer Worker"
		},
		{
			Icon = "rbxassetid://7592171638",
			JobTitle = "Referee",
			Filter = "Outdoors",
			Name = "7592171638",
			Text = "Referee"
		},
		{
			Icon = "rbxassetid://7592171797",
			JobTitle = "Race Car Driver",
			Filter = "Outdoors",
			Name = "7592171797",
			Text = "Race Car Driver"
		},
		{
			Icon = "rbxassetid://5849794578",
			JobTitle = "Movies",
			Filter = "Arts",
			Name = "5849794578",
			Text = "Movies"
		},
		{
			Icon = "rbxassetid://9893355528",
			JobTitle = "Police",
			Filter = "Service",
			Name = "9893355528",
			Text = "State Trooper"
		},
		{
			Icon = "rbxassetid://7592172106",
			JobTitle = "Paranormal Hunter",
			Filter = "Outdoors",
			Name = "7592172106",
			Text = "Paranormal Hunter"
		},
		{
			Icon = "rbxassetid://7592172291",
			JobTitle = "Farmer",
			Filter = "Outdoors",
			Name = "7592172291",
			Text = "Farmer"
		},
		{
			Icon = "rbxassetid://7592172422",
			JobTitle = "Car Wash",
			Filter = "Service",
			Name = "7592172422",
			Text = "Car Wash"
		},
		{
			Icon = "rbxassetid://7592172566",
			JobTitle = "Astronaut",
			Filter = "Outdoors",
			Name = "7592172566",
			Text = "Astronaut"
		},
		{
			Icon = "rbxassetid://7592518247",
			JobTitle = "Business Person",
			Filter = "Service",
			Name = "7592518247",
			Text = "Business Person"
		},
		{
			Icon = "rbxassetid://7601352318",
			JobTitle = "Gardener",
			Filter = "Outdoors",
			Name = "7601352318",
			Text = "Gardener"
		},
		{
			Icon = "rbxassetid://7607407475",
			JobTitle = "Starbrooks",
			Filter = "Shop",
			Name = "7607407475",
			Text = "Starbrooks"
		},
		{
			Icon = "rbxassetid://8416982159",
			JobTitle = "Agency",
			Filter = "Service",
			Name = "8416982159",
			Text = "Agency"
		},
		{
			Icon = "rbxassetid://8770922031",
			JobTitle = "Lawyer",
			Filter = "Service",
			Name = "8770922031",
			Text = "Lawyer"
		},
		{
			Icon = "rbxassetid://8770936346",
			JobTitle = "Judge",
			Filter = "Service",
			Name = "8770936346",
			Text = "Judge"
		},
		{
			Icon = "rbxassetid://9790259496",
			JobTitle = "Fisherman",
			Filter = "Outdoors",
			Name = "9790259496",
			Text = "Fisherman"
		},
		{
			Icon = "rbxassetid://7592171969",
			JobTitle = "Photographer",
			Filter = "Arts",
			Name = "7592171969",
			Text = "Photographer"
		},
		{
			Icon = "rbxassetid://10126274362",
			JobTitle = "Garbage",
			Filter = "Service",
			Name = "10126274362",
			Text = "Garbage"
		},
		{
			Icon = "rbxassetid://14544396959",
			JobTitle = "Construction",
			Filter = "Service",
			Name = "14544396959",
			Text = "Construction"
		},
		{
			Icon = "rbxassetid://96257532590137",
			JobTitle = "Pastry Chef",
			Filter = "Shop",
			Name = "96257532590137",
			Text = "Pastry Chef"
		},
		{
			Icon = "rbxassetid://74657333514919",
			JobTitle = "Jetts",
			Filter = "Shop",
			Name = "74657333514919",
			Text = "Jett`s Jungle Nuggets"
		}
	},
	Setup = function(instance, data)
		local template = instance:FindFirstChild("Template")
		template.Name = data.Name
		template.Icon.Image = data.Icon
		template.JobTitle.Value = data.JobTitle
		template.JobTitle.Job.Value = data.JobStatus == nil or data.JobStatus
		local text = template:FindFirstChild("Text")
		text.Text = data.Text
	end,
	IsGamepass = function(p)
		return JobUtil.isVIPJob(p.JobTitle)
	end
}

function Jobs.FilterEntryValues(data)
	local entries = {}

	for _, entry in Jobs.Entries do
		if not (data.BreadcrumbsFilter == nil or data.BreadcrumbsFilter(entry)) then
			continue
		end

		if data.CurrentCategory == nil then
			if data.GamepassFilter ~= nil and not data.GamepassFilter(entry) or data.CategoryFilter ~= nil and not data.CategoryFilter(entry) then
				continue
			end
		elseif entry.Filter ~= data.CurrentCategory then
			continue
		end

		table.insert(entries, entry)
	end

	return entries
end

return Jobs