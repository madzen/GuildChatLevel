GuildChatLevel WoW Addon
========================

Important Note
--------------

At present, this is a fairly old addon which has not been updated in a long
time, since it was created in 2006. I will be updating the script for newer
versions, but it is here for the time being for posterity and for example code
for anyone writing their own WoW addons or taking aspects of it forward in
other ways.

About
-----
This mod modifies guild chat messages to tag each line with the level and a
code representing the class of the person who is speaking. For example, a level
60 Shaman will have [60:S] as a prefix to their message, a level 20 rogue will
have [20:R] and so on.

The class codes are as follows:

* R - Rogue
* W - Warrior
* S - Shaman
* M - Mage
* P - Priest
* D - Druid
* H - Hunter
* L - Warlock (from 'lock, the generic abbreviated term for Warlocks)
* Pn - Paladin

Usage
-----
The addon can be enabled for each separate character you have. There are two
slash commands available for it, /gcl and /guildchatlevel. The following
parameters are available:

on - Enables the addon
off - Disables the addon
help - displays help
update - manually updates the local copy of the guild roster

Additionally, it is highly recommended that you enable Guild Member Notify (The
option can be found in the main menu under "Interface Options") as this will
help to keep the guild roster more up to date.


Troubleshooting
---------------
This addon is my first attempt (be gentle ;)) so there may well be bugs I
haven't picked up on yet. If there is a message about guildMemberTable
containing a nil value, it means that for some reason, that person's entry in
the table has not been updated locally. Running /gcl update to manually update
the local copy of the guild roster should fix that problem. Other than that,
let me know and I will see about fixing it.



Abstract (Technical bit)
------------------------
I've commented my code fairly well to help other coders along, but basically,
the script starts off by taking a copy of the guild roster by:

1. Calling GuildRoster() to request a local roster update, and listen for the GUILD_ROSTER_UPDATE event
2. Noting the details of each guild member
3. Passing the class to a function to get a one letter code
4. Saving the tag format [??:?] into a table/array

I wrote it in this way so that the level and class are always stored locally,
and are only updated:

* When a guild member logs on
* When a guild member logs off
* When a guild member joins the guild
* When a guild member leaves the guild
* When a guild member is kicked out of the guild
* When a guild member says "ding" in the chat
* When you run /gcl update

This minimises the amount of server requests, as all the data is stored and
queried locally, and updated periodically.

The addon hooks the guild chat functionality so that the message can be altered
before being passed onto the main ChatFrame_OnEvent function. When a
CHAT_MSG_GUILD event is triggered, the addon requests the array entry of the
user speaking, modifies the chat line to have the level and class at the
beginning of the line, then hands back control to the main function.