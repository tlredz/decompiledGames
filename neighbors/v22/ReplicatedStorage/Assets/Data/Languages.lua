local Languages = {
	{
		Name = "English",
		Locale = "en",
		Icon = "🇺🇸"
	},
	{
		Name = "Spanish",
		Locale = "es",
		Icon = "🇲🇽"
	},
	{
		Name = "Japanese",
		Locale = "ja",
		Icon = "🇯🇵"
	},
	{
		Name = "French",
		Locale = "fr",
		Icon = "🇫🇷"
	},
	{
		Name = "Portuguese",
		Locale = "pt",
		Icon = "🇧🇷"
	},
	{
		Name = "Indonesian",
		Locale = "id",
		Icon = "🇮🇩"
	},
	{
		Name = "Polish",
		Locale = "pl",
		Icon = "🇵🇱"
	},
	{
		Name = "Chinese",
		Locale = "zh",
		Icon = "🇨🇳"
	},
	{
		Name = "Italian",
		Locale = "it",
		Icon = "🇮🇹"
	},
	{
		Name = "Russian",
		Locale = "ru",
		Icon = "🇷🇺"
	},
	{
		Name = "Korean",
		Locale = "ko",
		Icon = "🇰🇷"
	},
	{
		Name = "German",
		Locale = "de",
		Icon = "🇩🇪"
	},
	{
		Name = "Vietnamese",
		Locale = "vi",
		Icon = "🇻🇳"
	},
	{
		Name = "Thai",
		Locale = "th",
		Icon = "🇹🇭"
	},
	{
		Name = "Arabic",
		Locale = "ar",
		Icon = "🇸🇦"
	},
	{
		Name = "Turkish",
		Locale = "tr",
		Icon = "🇹🇷"
	},
	{
		Name = "Tagalog",
		Locale = "tl",
		Icon = "🇵🇭"
	}
}
table.sort(Languages, function(a, b)
	return a.Name == "English" or b.Name ~= "English" and a.Name:lower() < b.Name:lower()
end)
return Languages