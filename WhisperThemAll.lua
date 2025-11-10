-- Send whispers to multiple players from saved list

local addonName = "WhisperThemAll"
local whisperFrame = nil
local namesScroll = nil
local namesInput = nil
local messagePanel = nil

-- Initialize saved variables

WhisperThemAllDB = WhisperThemAllDB or {}
WhisperThemAllDB.playerNames = WhisperThemAllDB.playerNames or ""
WhisperThemAllDB.message = WhisperThemAllDB.message or ""

-- Create whisper frame

local function createWhisperFrame()
    if whisperFrame then
        return whisperFrame
    end
    
    whisperFrame = CreateFrame("Frame", "WhisperThemAllFrame", UIParent, "BasicFrameTemplateWithInset")
    whisperFrame:SetSize(500, 600)
    whisperFrame:SetPoint("CENTER")
    whisperFrame:SetMovable(true)
    whisperFrame:EnableMouse(true)
    whisperFrame:RegisterForDrag("LeftButton")
    whisperFrame:SetScript("OnDragStart", whisperFrame.StartMoving)
    whisperFrame:SetScript("OnDragStop", whisperFrame.StopMovingOrSizing)
    whisperFrame:Hide()
    
    whisperFrame.title = whisperFrame:CreateFontString(nil, "OVERLAY")
    whisperFrame.title:SetFontObject("GameFontHighlight")
    whisperFrame.title:SetPoint("LEFT", whisperFrame.TitleBg, "LEFT", 5, 0)
    whisperFrame.title:SetText("Whisper Them All")
    
    -- Add helper text
    
    whisperFrame.helperText = whisperFrame:CreateFontString(nil, "OVERLAY")
    whisperFrame.helperText:SetFontObject("GameFontNormal")
    whisperFrame.helperText:SetPoint("TOPLEFT", whisperFrame, "TOPLEFT", 15, -35)
    whisperFrame.helperText:SetText('Use "/wta" to open this window, or "/wta MESSAGE" to send MESSAGE to all players in the list')
    whisperFrame.helperText:SetTextColor(0.7, 0.7, 0.7)
    
    return whisperFrame
end

-- Parse player names

local function parsePlayerNames(namesText)
    local names = {}
    
    for line in namesText:gmatch("[^\r\n]+") do
        local trimmedName = line:match("^%s*(.-)%s*$")
        if trimmedName and trimmedName ~= "" then
            table.insert(names, trimmedName)
        end
    end
    
    return names
end

-- Create names input

local function createNameInput(parentFrame)
    namesScroll = CreateFrame("ScrollFrame", "WhisperThemAllScrollFrame", parentFrame, "UIPanelScrollFrameTemplate")
    namesScroll:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 15, -60)
    namesScroll:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -35, 50)
    
    namesInput = CreateFrame("EditBox", "WhisperThemAllEditBox", namesScroll)
    namesInput:SetMultiLine(true)
    namesInput:SetAutoFocus(false)
    namesInput:SetFontObject("ChatFontNormal")
    namesInput:SetWidth(namesScroll:GetWidth())
    namesInput:SetScript("OnEscapePressed", function()
        namesInput:ClearFocus()
        whisperFrame:Hide()
    end)
    
    namesScroll:SetScrollChild(namesInput)
    
    local placeholderText = namesInput:CreateFontString(nil, "OVERLAY")
    placeholderText:SetFontObject("ChatFontNormal")
    placeholderText:SetPoint("TOPLEFT", namesInput, "TOPLEFT", 5, -5)
    placeholderText:SetTextColor(0.5, 0.5, 0.5)
    placeholderText:SetText("Enter character names, one per line...")
    
    namesInput:SetScript("OnEditFocusGained", function()
        if namesInput:GetText() == "" then
            placeholderText:Hide()
        end
    end)
    
    namesInput:SetScript("OnEditFocusLost", function()
        if namesInput:GetText() == "" then
            placeholderText:Show()
        end
    end)
    
    namesInput:SetScript("OnTextChanged", function(self)
        local inputText = self:GetText()
        if inputText == "" then
            placeholderText:Show()
        else
            placeholderText:Hide()
        end
        
        WhisperThemAllDB.playerNames = inputText
        
        local lineCount = select(2, inputText:gsub('\n', '\n')) + 1
        local lineHeight = select(2, namesInput:GetFont()) or 14
        local newHeight = math.max(lineCount * lineHeight, namesScroll:GetHeight() - 20)
        self:SetHeight(newHeight)
    end)
    
    -- Load saved names
    
    if WhisperThemAllDB.playerNames and WhisperThemAllDB.playerNames ~= "" then
        namesInput:SetText(WhisperThemAllDB.playerNames)
    end
end

-- Send whispers

local function sendWhispers(messageText, names)
    for _, playerName in ipairs(names) do
        if playerName and playerName ~= "" then
            SendChatMessage(messageText, "WHISPER", nil, playerName)
        end
    end
end

-- Create message panel

local function createMessagePanel()
    local childFrame = CreateFrame("Frame", "WhisperThemAllMessagePanel", UIParent, "BasicFrameTemplateWithInset")
    childFrame:SetSize(480, 240)
    childFrame:SetFrameStrata("DIALOG")
    childFrame:SetFrameLevel(1000)
    childFrame:Hide()
    
    -- Focus message input
    
    childFrame:SetScript("OnMouseDown", function(self)
        if self.messageInput then
            self.messageInput:SetFocus()
        end
    end)
    
    -- Add title
    
    childFrame.title = childFrame:CreateFontString(nil, "OVERLAY")
    childFrame.title:SetFontObject("GameFontHighlight")
    childFrame.title:SetPoint("CENTER", childFrame.TitleBg, "CENTER", 0, 0)
    childFrame.title:SetText("Message Settings")
    
    -- Add message label
    
    local messageLabel = childFrame:CreateFontString(nil, "OVERLAY")
    messageLabel:SetFontObject("GameFontNormal")
    messageLabel:SetPoint("TOPLEFT", childFrame, "TOPLEFT", 20, -35)
    messageLabel:SetText("Predefined whisper message:")
    
    -- Create message input
    
    local messageInput = CreateFrame("EditBox", nil, childFrame)
    messageInput:SetPoint("TOPLEFT", messageLabel, "BOTTOMLEFT", 0, -8)
    messageInput:SetSize(432, 160)
    messageInput:SetMultiLine(true)
    messageInput:SetMaxLetters(260)
    messageInput:SetAutoFocus(false)
    messageInput:SetFontObject("ChatFontNormal")
    
    -- Limit input to three lines
    
    messageInput:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        local lines = 1
        for _ in text:gmatch("\n") do
            lines = lines + 1
        end

        if lines > 3 then
            local newText = text:sub(1, -2)
            self:SetText(newText)
            self:SetCursorPosition(#newText)
        end
    end)
    
    -- Create close button
    
    local cancelButton = CreateFrame("Button", nil, childFrame, "GameMenuButtonTemplate")
    cancelButton:SetSize(80, 25)
    cancelButton:SetPoint("BOTTOMLEFT", childFrame, "BOTTOMLEFT", 20, 20)
    cancelButton:SetText("Cancel")
    
    -- Create save button
    
    local saveButton = CreateFrame("Button", nil, childFrame, "GameMenuButtonTemplate")
    saveButton:SetSize(80, 25)
    saveButton:SetPoint("BOTTOMRIGHT", childFrame, "BOTTOMRIGHT", -20, 20)
    saveButton:SetText("Save")
    
    local originalMessage = ""
    
    -- Initialize controls
    
    local function initializeControls()
        originalMessage = WhisperThemAllDB.message or ""
        messageInput:SetText(originalMessage)
    end
    
    -- Restore original message
    
    cancelButton:SetScript("OnClick", function()
        messageInput:SetText(originalMessage)
        childFrame:Hide()
    end)
    
    -- Save message
    
    saveButton:SetScript("OnClick", function()
        WhisperThemAllDB.message = messageInput:GetText()
        originalMessage = WhisperThemAllDB.message
        print("|cff00ff00WhisperThemAll:|r Message saved.")
        childFrame:Hide()
    end)
    
    childFrame.messageInput = messageInput
    childFrame.initializeControls = initializeControls
    
    return childFrame
end

-- Show message panel

local function showMessagePanel()
    if not messagePanel then
        messagePanel = createMessagePanel()
    end
    
    messagePanel.initializeControls()
    messagePanel:ClearAllPoints()
    messagePanel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    messagePanel:Show()
end

-- Create close button

local function createCloseButton(parentFrame)
    local closeButton = CreateFrame("Button", "WhisperThemAllCancelButton", parentFrame, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 22)
    closeButton:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", 15, 15)
    closeButton:SetText("Close")
    
    closeButton:SetScript("OnClick", function()
        whisperFrame:Hide()
    end)
    
    return closeButton
end

-- Create message button

local function createMessageButton(parentFrame)
    local configButton = CreateFrame("Button", "WhisperThemAllConfigButton", parentFrame, "UIPanelButtonTemplate")
    configButton:SetSize(130, 22)
    configButton:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -135, 15)
    configButton:SetText("Configure Message")
    
    configButton:SetScript("OnClick", function()
        showMessagePanel()
    end)
    
    return configButton
end

-- Create whisper button

local function createWhisperButton(parentFrame)
    local whisperButton = CreateFrame("Button", "WhisperThemAllWhisperButton", parentFrame, "UIPanelButtonTemplate")
    whisperButton:SetSize(100, 22)
    whisperButton:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -15, 15)
    whisperButton:SetText("Send Whispers")
    
    whisperButton:SetScript("OnClick", function()
        local prefillText = "/wta "
        if WhisperThemAllDB.message and WhisperThemAllDB.message ~= "" then
            prefillText = "/wta " .. WhisperThemAllDB.message
        end
        ChatFrame_OpenChat(prefillText)
    end)
    
    return whisperButton
end

-- Run whisper send

local function runWhisperSend(messageText)
    local namesText = WhisperThemAllDB.playerNames
    if not namesText or namesText == "" then
        print("|cffff0000WhisperThemAll:|r No player names in list. Use /wta to add names.")
        return
    end
    
    local playerNames = parsePlayerNames(namesText)
    if #playerNames > 0 then
        sendWhispers(messageText, playerNames)
        print("|cff00ff00WhisperThemAll:|r Sent message to " .. #playerNames .. " player(s).")
    else
        print("|cffff0000WhisperThemAll:|r No valid player names in list.")
    end
end

-- Show whisper frame

local function showWhisperFrame()
    if not whisperFrame then
        createWhisperFrame()
        createNameInput(whisperFrame)
        createCloseButton(whisperFrame)
        createMessageButton(whisperFrame)
        createWhisperButton(whisperFrame)
    end
    
    whisperFrame:Show()
    namesInput:SetFocus()
end

-- Register command

SLASH_WHISPERTHEMALL1 = "/wta"
SLASH_WHISPERTHEMALL2 = "/whisperthemall"
SlashCmdList["WHISPERTHEMALL"] = function(messageText)
    if not messageText or messageText == "" then
        showWhisperFrame()
        return
    end
    
    runWhisperSend(messageText)
end

-- Initialize saved variables

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if event == "ADDON_LOADED" and loadedAddonName == addonName then
        WhisperThemAllDB = WhisperThemAllDB or {}
        WhisperThemAllDB.playerNames = WhisperThemAllDB.playerNames or ""
        WhisperThemAllDB.message = WhisperThemAllDB.message or ""
    elseif event == "PLAYER_LOGIN" then
        C_Timer.After(2, function()
            print("|cff00ff00WhisperThemAll:|r Type /wta for commands.")
        end)
    end
end)