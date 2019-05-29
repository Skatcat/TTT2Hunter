if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_hunt.vmt")
end

-- creates global var "TEAM_SERIALKILLER" and other required things
-- TEAM_[name], data: e.g. icon, color,...
roles.InitCustomTeam(ROLE.name, {
		icon = "vgui/ttt/dynamic/roles/icon_hunt",
		color = Color(49, 105, 109, 255)
})


ROLE.color = Color(107, 124, 63, 255) -- ...
ROLE.dkcolor = Color(107, 124, 63, 255) -- ...
ROLE.bgcolor = Color(161, 188, 94, 255) -- ...
ROLE.abbr = "hunt" -- abbreviation
ROLE.defaultTeam = TEAM_INNOCENT -- the team name: roles with same team name are working together
ROLE.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment
ROLE.radarColor = Color(150, 150, 150) -- color if someone is using the radar
ROLE.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
ROLE.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
ROLE.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
ROLE.unknownTeam = true -- player don't know their teammates

ROLE.conVarData = {
	pct = 0.15, -- necessary: percentage of getting this role selected (per player)
	maximum = 2, -- maximum amount of roles in a round
	minPlayers = 7, -- minimum amount of players until this role is able to get selected
	credits = 0, -- the starting credits of a specific role
	togglable = true, -- option to toggle a role for a client if possible (F1 menu)
}

-- now link this subrole with its baserole
hook.Add("TTT2BaseRoleInit", "TTT2ConBRIWithHunt", function()
	HUNTER:SetBaseRole(ROLE_INNOCENT)
end)

if CLIENT then
	hook.Add("TTT2FinishedLoading", "HuntInitT", function()
		-- setup here is not necessary but if you want to access the role data, you need to start here
		-- setup basic translation !
		LANG.AddToLanguage("English", HUNTER.name, "Hunter")
		LANG.AddToLanguage("English", "info_popup_" .. HUNTER.name,
			[[You are a Hunter!
				Lay traps and hunt evildoers!]])
		LANG.AddToLanguage("English", "body_found_" .. HUNTER.abbr, "They were a Hunter...")
		LANG.AddToLanguage("English", "search_role_" .. HUNTER.abbr, "This person was a Hunter!")
		LANG.AddToLanguage("English", "target_" .. HUNTER.name, "Hunter")
		LANG.AddToLanguage("English", "ttt2_desc_" .. HUNTER.name, [[The Hunter lays traps and uses his trusty Ranger Bow!]])

		---------------------------------

		-- maybe this language as well...
		LANG.AddToLanguage("Deutsch", HUNTER.name, "Jäger")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. HUNTER.name,
			[[Du bist ein Jäger!
				Versuche zu überleben und beschütze dein Team, wenn es möglich sein sollte!]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. HUNTER.abbr, "Er war ein Jäger...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. HUNTER.abbr, "Diese Person war ein Jäger!")
		LANG.AddToLanguage("Deutsch", "target_" .. HUNTER.name, "Jäger")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. HUNTER.name, [[Der Jäger stellt Fallen!]])
	end)
end

-- nothing special, just a inno that is able to access the [C] shop
