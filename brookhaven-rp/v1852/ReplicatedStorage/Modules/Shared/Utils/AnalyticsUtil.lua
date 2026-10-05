local AnalyticsUtil = {}

function AnalyticsUtil.getTimestampNow()
	return DateTime.now():FormatUniversalTime("YYYY-MM-DD HH:mm:ss.SSS", "en-us")
end

function AnalyticsUtil.getTimestampFromOSTime(p: number)
	return DateTime.fromUnixTimestamp(p):FormatUniversalTime("YYYY-MM-DD HH:mm:ss.SSS", "en-us")
end

return AnalyticsUtil