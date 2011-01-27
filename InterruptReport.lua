-- InterruptReport
-- By Sadiniel <Dispel Stupid> of Garona-US

local IRversion = GetAddOnMetadata("InterruptReport", "Version");
local InterruptReport = CreateFrame("Frame", "InterruptReport");

function InterruptReport_Config()

	-- This is to set up the options window.
	-- Copy/pasta'd from my other addon.
	
	InterruptReportOptions = CreateFrame("Frame", "InterruptReportOptionPanel", UIParent);
	InterruptReportOptions.name = "InterruptReport";
	InterfaceOptions_AddCategory(InterruptReportOptions);

	InterruptReportOptions.title = InterruptReportOptions:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	InterruptReportOptions.title:SetText("InterruptReport Options");
	InterruptReportOptions.title:SetPoint("TOPLEFT", InterruptReportOptions,"TOPLEFT" , 10, -15);

	InterruptReportOptions.EnabledCheck = CreateFrame("CheckButton", "EnabledCheck", InterruptReportOptions, "InterfaceOptionsCheckButtonTemplate");
	EnabledCheckText:SetText("Enable / Disable this addon.");
	InterruptReportOptions.EnabledCheck:SetPoint("TOPLEFT", InterruptReportOptions, "TOPLEFT", 15, -50);
	
	ChannelMenu = CreateFrame("Frame", "AnnounceChannel", InterruptReportOptions, "UIDropDownMenuTemplate");
	ChannelMenu:SetPoint("TOPLEFT", InterruptReportOptions, "TOPLEFT" , 30, -80);
	ChannelMenu_OnEvent(ChannelMenu);
	
	InterruptReportOptions.AnnounceChannelText = InterruptReportOptions:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	InterruptReportOptions.AnnounceChannelText:SetText("Announcement Channel");
	InterruptReportOptions.AnnounceChannelText:SetPoint("TOPLEFT", InterruptReportOptions,"TOPLEFT" , 190, -87);
	
	InterruptReportOptions.okay = function (self) InterruptReport_Okay(); end;
	InterruptReportOptions.cancel = function (self) InterruptReport_Cancel(); end;
end

function ChannelMenu_OnEvent(self, event, ...)
	
	local value = InterruptReportConfig.ANNOUNCE_CHANNEL;
	self.defaultValue = "group";
	self.oldValue = value;
	self.value = self.oldValue or self.defaultValue;
	
	UIDropDownMenu_Initialize(self, ChannelMenu_Initialize);
	UIDropDownMenu_SetSelectedValue(self, value);

	self.SetValue = 
		function (self, value)
			self.value = value;
			UIDropDownMenu_SetSelectedValue(self, value);
		end
	self.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
	self.RefreshValue =
		function (self)
			UIDropDownMenu_Initialize(self, ChannelMenu_Initialize);
			UIDropDownMenu_SetSelectedValue(self, self.value);
		end

end

function ChannelMenu_OnClick( self )
	
	ChannelMenu:SetValue(self.value);

end

function ChannelMenu_Initialize(self)
	
	-- Making the DropDownBox List for the Channel Menu.
	
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = "Self";
	info.func = ChannelMenu_OnClick;
	info.value = "self";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = "Self";
	info.tooltipText = "Display to the Chat frame without announcing";
	UIDropDownMenu_AddButton(info);
	
	info.text = "Group";
	info.func = ChannelMenu_OnClick;
	info.value = "group";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = "Group";
	info.tooltipText = "Announce to the /Party or /Raid chat channel";
	UIDropDownMenu_AddButton(info);
	
	info.text = "Guild";
	info.func = ChannelMenu_OnClick;
	info.value = "guild";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = "Guild";
	info.tooltipText = "Announce to the /Guild chat channel";
	UIDropDownMenu_AddButton(info);
	
end

function InterruptReport_Okay()

	-- When you click that little "Okay" button in the options window
	-- the game saves all that information to your Saved Variables
	
	InterruptReportConfig.ENABLED = EnabledCheck:GetChecked();
	InterruptReportConfig.ANNOUNCE_CHANNEL = UIDropDownMenu_GetSelectedValue(ChannelMenu);
    
end

function InterruptReport_Cancel()

	-- When you click that little "Cancel" button in the options window
	-- the game replaces the information in the window with your Saved Variables
	
	EnabledCheck:SetChecked(InterruptReportConfig.ENABLED);
	ChannelMenu:SetValue(InterruptReportConfig.ANNOUNCE_CHANNEL);
	ChannelMenu:RefreshValue();
	
end

function InterruptReport_OnLoad(self)

	-- Version message for the chat window and registering events
	
	ChatFrame1:AddMessage("InterruptReport version " .. IRversion .. " loaded successfully.", .9, 0, .9);
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("CHAT_MSG_ADDON");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	
	-- If we don't have a Saved Variables entry, we will after this
	-- Saved variables are by character so if you just want to announce on certain ones you can.
	
	if	(InterruptReportConfig == nil) then InterruptReportConfig = {}; end
	if	(InterruptReportConfig.ANNOUNCE_CHANNEL == nil) then InterruptReportConfig.ANNOUNCE_CHANNEL = "self"; end
	
	-- Everyone loves /commands, so much more convenient than clicking
	-- 40 buttons to find the options window.
	
	SlashCmdList["INTERRUPTREPORT"] = InterruptReport_SlashCommand;
	SLASH_INTERRUPTREPORT1 = "/irep"
	SLASH_INTERRUPTREPORT2 = "/ireport"
	SLASH_INTERRUPTREPORT3 = "/intrep"
	SLASH_INTERRUPTREPORT4 = "/intreport"
	SLASH_INTERRUPTREPORT5 = "/interruptreport"
end

function InterruptReport_SlashCommand()

	-- The only thing I do with the /command is open the options window
	-- Talk about being lazy.
	
	InterfaceOptionsFrame_OpenToCategory(InterruptReportOptions);
end

function InterruptReport_Announce( dataList, channel )

	-- This section actually makes the announcements to chat and sends announcement notification
	-- over the addon channel to prevent others using the addon from repeating the announcement
		
	if ( channel == "self") then
		ChatFrame1:AddMessage( dataList[1] , .9, 0, .9);
	else
		SendChatMessage( dataList[1] , channel , nil , nil );
		SendAddonMessage( "InterruptReport" , "1" , channel , nil);
	end
	
end

function InterruptReport_OnEvent(self, event, ...)

	-- Event catching:
	
	if	( event == "PLAYER_LOGIN" ) then
		
		-- Setting up the otions window has to be done before the game starts up the UI
		-- I chose to do it at login although there are a couple of other choices

		InterruptReport_Config();
	
		-- We use the options window '_Cancel()' function to fill in the addon options window
		-- from the saved variables file before we see it
	
		InterruptReport_Cancel();
	
	elseif	( ( event == "CHAT_MSG_ADDON" ) and ( select(1, ...) == "InterruptReport" ) ) then
		
		-- If someone announces before you their addon tells yours name of the target they
		-- looted to prevent yours from announcing it too.
		
		InterruptReportConfig.REPORTED = select(2, ...);
	
	elseif	( event == "PLAYER_REGEN_DISABLED" ) then
	
		if	( InterruptReportConfig.ENABLED ) then
		
			local inInstance, instanceType = IsInInstance();
		
			if	(inInstance) then
				
				ChatFrame1:AddMessage( "Combat Started." , .9, 0, .9);
				
			end
			
		end
	
	elseif	( event == "PLAYER_REGEN_ENABLED" ) then
		
		if	( InterruptReportConfig.ENABLED ) then
		
			local inInstance, instanceType = IsInInstance();
		
			if	(inInstance) then
			
				ChatFrame1:AddMessage( "Combat Ended." , .9, 0, .9);
				
			end
			
		end
		
	elseif	( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
	
		if	( InterruptReportConfig.ENABLED ) then
		
			local inInstance, instanceType = IsInInstance();
		
			if	(inInstance) then
			
				local timestamp, logtype, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, -- arg1  to arg8
				spellId, spellName, spellSchool, -- arg9  to arg11
				amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ... ; -- arg12 to arg20
				
				if ( logtype == "SPELL_DAMAGE" ) then
				
					if ( spellName == "Arcane Annihilator" ) then

						ChatFrame1:AddMessage( "Arcane Annihilator hit " .. destName .. " for " .. amount .. ". ( " .. resisted .. " resisted / " .. absorbed .. " absorbed. )" , .9, 0, .9);
						
					end
					
				end
				
				if ( logtype == "SPELL_INTERRUPT" ) then
			
					if ( overkill == "Arcane Annihilator" ) then

						ChatFrame1:AddMessage( "Arcane Annihilator was interrupted by " .. sourceName , .9, 0, .9);
						
					end
					
				end
				
			end
			
		end
		
	end	
	
end -- 274 lines of boring code. With no library dependencies.
