--[[


	GuildChatLevel: Prefixes guild chat messages with the level and class of the person speaking
		Copyright 2006 Ryuji of Legio Septima (Quel'Thalas)


]]

-- Declare hook event
local lOriginalChatFrame_OnEvent;

-- Initialise the Addon
GuildChatLevel_Enabled = 1;

----------------------------------------------------------------------------
-- Function to handle initialisation.
-- Registers events, commands and informs the user that the addon is loaded.
----------------------------------------------------------------------------
function GuildChatLevel_OnLoad()	
	-- Register slash command
	SlashCmdList["GUILDCHATLEVELSLASH"] = GuildChatLevel_Cmd;
	SLASH_GUILDCHATLEVELSLASH1 = "/guildchatlevel";
	SLASH_GUILDCHATLEVELSLASH2 = "/gcl"
	
	-- Register events for loading variables, guild roster updates, guild chat and system messages
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("CHAT_MSG_GUILD");
	this:RegisterEvent("GUILD_ROSTER_UPDATE");
	this:RegisterEvent("CHAT_MSG_SYSTEM");

	-- Update guild roster on local client
	GuildRoster();	

	-- Inform user that the addon has been successfully loaded
	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("GuildChatLevel by Ryuji Loaded");
	end
	
	UIErrorsFrame:AddMessage("GuildChatLevel", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);
	
	-- Hook chat functionality
	lOriginalChatFrame_OnEvent = ChatFrame_OnEvent;
	ChatFrame_OnEvent = GuildChatLevel_ChatFrame_OnEvent;
end


--------------------------------------------------------------------------------------------
-- Replacement chat frame function.
-- This function hooks the original chat frame function and modifies the guild chat message.
--------------------------------------------------------------------------------------------
function GuildChatLevel_ChatFrame_OnEvent(event)
	
	if (event == "CHAT_MSG_GUILD" and GuildChatLevel_Enabled == 1) then
		-- If user says ding in the guild chat (standard term to indicate hitting next level) then update
		if (string.find(arg1, "[Dd][Ii][Nn][Gg]")) then
			-- Update local guild table.
			GuildRoster();
			-- DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> Member appears to have levelled, updating..", 1.0, 0.0, 0.0, 1.0, 20);
		end
		
		-- Send the line to be displayed.
		arg1 = GuildChatLevel_MsgAlter(arg1, arg2); 
	end
	
	lOriginalChatFrame_OnEvent(event);
end


-------------------------------------------------------------------------------------------
-- Alters the message sent to the guild chat.
-- The guild chat message is altered to include the level and class of the person speaking.
-------------------------------------------------------------------------------------------
function GuildChatLevel_MsgAlter(arg1, arg2)
	-- Build message output format.
	if (guildMemberTable[arg2] == nil) then
		GuildRoster();
		return arg1;
	else 
		local AltMessage = guildMemberTable[arg2] .. " " .. arg1;
		return AltMessage;
	end
end 


----------------------------------
-- Handle any slash commands used.
----------------------------------
function GuildChatLevel_Cmd(msg)

	-- Get GCL Updated
	GuildRoster();
	
	-- Convert the command to lowercase for the sake of convenience.
	msg = string.lower(msg);
	
	-- User enables the addon.
	if (msg == "on") then
		-- Check to see if the character is actually in a guild before enabling addon.
		if (not IsInGuild()) then
			GuildChatLevel_Enabled = 0;
			DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> This character does not appear to be in a guild! Addon has been disabled.", 1.0, 0.0, 0.0, 1.0, 20);
		-- If they are, enable the addon and update the local guild roster.
		elseif (IsInGuild()) then
			GuildChatLevel_Enabled = 1;
			GuildRoster();
			DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> GuildChatLevel has been enabled for this character", 1.0, 0.0, 0.0, 1.0, 20);
		end

		
	-- User disables the addon.
	elseif (msg == "off") then
		GuildChatLevel_Enabled = 0;
		DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> GuildChatLevel has been disabled for this character", 1.0, 0.0, 0.0, 1.0, 20);
	
	elseif (msg == "update") then
		GuildRoster();
		DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> The guild roster has been updated.", 1.0, 0.0, 0.0, 1.0, 20);
		
	-- User requests help or doesn't provide a parameter.
	elseif (msg == "help" or msg == nil) then
		DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> GuildChatLevel Usage:", 1.0, 0.0, 0.0, 1.0, 20);
		DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> on - Enables GuildChatLevel for this character.", 1.0, 0.0, 0.0, 1.0, 20);
		DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> off - Disables GuildChatLevel for this character.", 1.0, 0.0, 0.0, 1.0, 20);
		DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> update - Manually updates the guild roster.", 1.0, 0.0, 0.0, 1.0, 20);
		DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> help - Provides this command list.", 1.0, 0.0, 0.0, 1.0, 20);
	end	
end


-----------------------------------------------------------------------------------------
-- Checks to see if guildMemberNotify is enabled in Config.wtf.
-- Essential option, to ensure that as people log in and out, the local table is updated.
-- TODO: Implement!
-----------------------------------------------------------------------------------------
function GuildChatLevel_CheckWatch()
	-- Check Config.wtf file to see if the guildMemberNotify variable is present and enabled.
	if (not GetCVar("guildMemberNotify") == "1") then
		-- Enable guildMemberNotify.
		SetCVar("guildMemberNotify","1");
		
		-- Build warning messages for information.
		local watchWarning = "<GuildChatLevel> Guild Member Notify is required for this addon and has been enabled automatically.";
		local watchWarning2 = "<GuildChatLevel> You may need to reconnect for this setting to take effect.";

		-- Output warnings to default chat frame.
		DEFAULT_CHAT_FRAME:AddMessage(watchWarning, 1.0, 0.0, 0.0, 1.0, 20);
		DEFAULT_CHAT_FRAME:AddMessage(watchWarning2, 1.0, 0.0, 0.0, 1.0, 20);
	end
end


------------------------------------------
-- Main event handler.
-- Describes functionality for each event.
------------------------------------------
function GuildChatLevel_OnEvent()
	-- Event triggered when all variables have been loaded.
	if (event == "VARIABLES_LOADED") then
		GuildRoster();

		-- Check to make sure that guild logins are being watched.
		-- GuildChatLevel_CheckWatch();
	end
	
	-- Event triggered when GuildRoster() is called and the data updates locally.
	if (event == "GUILD_ROSTER_UPDATE") then
		-- Create table of level/class abbreviations.
		GuildMemberLog();
	end

	-- Event triggered when a system message is received.
	if (event == "CHAT_MSG_SYSTEM") then
		-- Send the system message for processing.
		GuildChatLevel_Sys(arg1);
	end
end


-----------------------------------------------------------------------------------------
-- Update local guild information when a member signs in or out.
-- System Message is checked against an expression to see if a user is signing in or out.
-----------------------------------------------------------------------------------------
function GuildChatLevel_Sys(arg1)
	-- Check to see if a user is signing in.
	if (string.find(arg1, "online")) then
		GuildRoster();
		-- DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> Someone appears to have logged in, updating..", 1.0, 0.0, 0.0, 1.0, 20);
	end

	-- Check to see if a user is signing out.
	if (string.find(arg1, "offline")) then
		GuildRoster();
		-- DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> Someone appears to have logged out, updating..", 1.0, 0.0, 0.0, 1.0, 20);
	end

	-- Check to see if a user is joining, leaving or being kicked out of the guild.
	if (string.find(arg1, "guild")) then
		GuildRoster();
		-- DEFAULT_CHAT_FRAME:AddMessage("<GuildChatLevel> Someone appears to have joined/left the guild, updating..", 1.0, 0.0, 0.0, 1.0, 20);
	end
end


----------------------------------------------------------------------------------------
-- Display line in guild chat, with the level and class of the user present as a prefix.
-- Look up local table to get the user level and class, and display along with message.
-- DEPRECATED: Only for debugging purposes.
----------------------------------------------------------------------------------------
function GuildChatLevel_Say(arg1, arg2)
	-- Build message output format.
	messageOutput = "[Guild] " .. guildMemberTable[arg2] .. " [" .. arg2 .. "] " .. arg1;
	-- Display message in chat window.
	--DEFAULT_CHAT_FRAME:AddMessage(messageOutput, 0.0, 1.0, 0.0, 1.0, 20);
	DEFAULT_CHAT_FRAME:AddMessage(messageOutput, 0.0, 1.0, 0.0, 1.0, 20);
end 


-----------------------------------------------------------------------------------------
-- Makes local table with the level and class of each member of the guild.
-- The number of guild members is noted, and a loop is processed, creating a local table,
-- with the level and class being logged along with the member's name.
-----------------------------------------------------------------------------------------
function GuildMemberLog()
	-- Get total number of all online and offline guild members.
	local numOfGuildMembers = GetNumGuildMembers(true);
	
	-- Initialise local table.
	guildMemberTable = { };
	
	-- Process loop for each member of the guild.
	for x = 1, numOfGuildMembers, 1 do
		-- Note all guild details.
		name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(x);
		-- Get abbreviation for the class (so as not to add too much to the line).
		local classAbbrev = GetClass(class);
		-- Add details to table.
		guildMemberTable[name] = "[" .. level .. ":" .. classAbbrev .. "]";
	end
end


-----------------------------------------------------------------------------------------------------------
-- Get abbreviation for class.
-- Takes the class name and returns a one or two character abbreviation, to keep the addition to a minimum.
-- Warrior and Warlock are the only classes to have two letters, all other prefixes are unique.
-----------------------------------------------------------------------------------------------------------
function GetClass(class)
	-- Declare the variable with an error value, so the return will never be null.
	local classResult = "X";
	
	if (class == "Warlock") then 
		classResult = "L";	
	elseif (class == "Warrior") then
		classResult = "W";
	elseif (class == "Rogue") then
		classResult = "R";
	elseif (class == "Shaman") then
		classResult = "S";
	elseif (class == "Mage") then
		classResult = "M";
	elseif (class == "Hunter") then
		classResult = "H";
	elseif (class == "Druid") then
		classResult = "D";
	elseif (class == "Priest") then
		classResult = "P";
	elseif (class == "Paladin") then
		-- Trust the Alliance to mess everything up and require a double character code ;)
		classResult = "Pn";
	end

	-- Return the abbreviation.
	return classResult;
end
