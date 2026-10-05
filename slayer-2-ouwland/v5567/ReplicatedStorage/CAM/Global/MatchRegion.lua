local v = {}
local MatchRegion = {
	ATTRIBUTE = "MatchRegion",
	UNKNOWN = "UN"
}

for k, v2 in {
	NA = "US CA MX GT BZ SV HN NI CR PA CU DO HT JM PR TT BS BB BM GL",
	SA = "BR AR CL CO PE VE EC BO PY UY GY SR GF FK",
	EU = "GB IE FR DE NL BE LU ES PT IT CH AT DK SE NO FI IS PL CZ SK HU RO BG GR HR SI RS BA ME MK AL XK EE LV LT BY UA MD RU TR CY MT GI AD MC SM VA LI FO IM JE GG AX",
	AF = "ZA EG MA DZ TN LY NG GH KE ET TZ UG RW SN CI CM AO MZ ZM ZW NA BW MG MU SC RE MW SD SS SO DJ ER LR SL GM GN GW ML NE TD MR BF TG BJ CF CG CD GA GQ ST CV KM YT SH IL JO LB SY IQ IR SA AE QA BH KW OM YE PS",
	AS = "JP KR CN TW HK MO SG MY TH VN PH ID KH LA MM BN TL IN PK BD LK NP BT MV MN KZ UZ KG TJ TM AF AM AZ GE",
	OC = "AU NZ PG FJ NC PF WS TO VU SB KI FM MH NR PW TV CK NU WF GU MP AS"
} do
	for k2 in string.gmatch(v2, "%S+") do
		v[k2] = k
	end
end

function MatchRegion.Bucket(value: string?)
	return v[string.upper(value or "")] or MatchRegion.UNKNOWN
end

function MatchRegion.Of(instance)
	local attribute = instance:GetAttribute(MatchRegion.ATTRIBUTE)

	if typeof(attribute) == "string" then
		return attribute
	end

	return MatchRegion.UNKNOWN
end

function MatchRegion.Compatible(p: string?, p2: string?, p3: number, p4: number, p5: number, flag: boolean?, flag2: boolean?)
	if p == p2 then
		return true
	end

	local v2

	if p == nil then
		v2 = false
	else
		v2 = p ~= MatchRegion.UNKNOWN
	end

	local v3

	if p2 == nil then
		v3 = false
	else
		v3 = p2 ~= MatchRegion.UNKNOWN
	end

	return (flag ~= true or not v2) and (flag2 ~= true or not v3) and (not (v2 and v3) or p5 <= p3 and p5 <= p4)
end

return MatchRegion