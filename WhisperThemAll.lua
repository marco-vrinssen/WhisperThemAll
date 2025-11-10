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
    whisperFrame.title:SetPoint("TOP", whisperFrame, "TOP", 0, -5)
    whisperFrame.title:SetText("Player Name List")
    
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
    -- Create input background
    
    local inputBg = CreateFrame("Frame", nil, parentFrame, "InsetFrameTemplate")
    inputBg:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 15, -30)
    inputBg:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -15, 60)
    
    -- Create scroll frame for long lists
    
    local namesScroll = CreateFrame("ScrollFrame", "WhisperThemAllScrollFrame", inputBg, "UIPanelScrollFrameTemplate")
    namesScroll:SetPoint("TOPLEFT", inputBg, "TOPLEFT", 8, -8)
    namesScroll:SetPoint("BOTTOMRIGHT", inputBg, "BOTTOMRIGHT", -28, 8)
    
    -- Create names input
    
    namesInput = CreateFrame("EditBox", "WhisperThemAllEditBox", namesScroll)
    namesInput:SetMultiLine(true)
    namesInput:SetAutoFocus(false)
    namesInput:SetFontObject("ChatFontNormal")
    namesInput:SetWidth(namesScroll:GetWidth())
    namesInput:EnableMouse(true)
    namesInput:SetMaxLetters(0)
    
    namesInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    
    namesScroll:SetScrollChild(namesInput)
    namesScroll:EnableMouseWheel(true)
    namesScroll:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local maxScroll = self:GetVerticalScrollRange()
        local newScroll = math.max(0, math.min(current - (delta * 20), maxScroll))
        self:SetVerticalScroll(newScroll)
    end)
    
    local placeholderText = namesInput:CreateFontString(nil, "OVERLAY")
    placeholderText:SetFontObject("ChatFontNormal")
    placeholderText:SetPoint("TOPLEFT", namesInput, "TOPLEFT", 3, -3)
    placeholderText:SetTextColor(0.5, 0.5, 0.5)
    placeholderText:SetText("Enter each player name on a new line using this format: CharacterName-ServerName")
    placeholderText:SetWidth(namesScroll:GetWidth() - 10)
    placeholderText:SetJustifyH("LEFT")
    placeholderText:SetWordWrap(true)
    
    namesInput:SetScript("OnEditFocusGained", function()
        placeholderText:Hide()
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
        
        -- Update height for scrolling
        local lineCount = select(2, inputText:gsub('\n', '\n')) + 1
        local lineHeight = select(2, namesInput:GetFont()) or 14
        local newHeight = math.max(lineCount * lineHeight, namesScroll:GetHeight())
        self:SetHeight(newHeight)
    end)
    
    -- Load saved names
    
    if WhisperThemAllDB.playerNames and WhisperThemAllDB.playerNames ~= "" then
        namesInput:SetText(WhisperThemAllDB.playerNames)
        placeholderText:Hide()
    end
    
    -- Create button background
    
    local buttonBg = parentFrame:CreateTexture(nil, "BACKGROUND")
    buttonBg:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", 10, 10)
    buttonBg:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -10, 10)
    buttonBg:SetHeight(40)
    buttonBg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
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
    childFrame:SetSize(500, 240)
    childFrame:SetFrameStrata("DIALOG")
    childFrame:SetFrameLevel(1000)
    childFrame:Hide()
    
    childFrame:SetMovable(true)
    childFrame:EnableMouse(true)
    childFrame:RegisterForDrag("LeftButton")
    childFrame:SetScript("OnDragStart", childFrame.StartMoving)
    childFrame:SetScript("OnDragStop", childFrame.StopMovingOrSizing)
    
    -- Add title
    
    childFrame.title = childFrame:CreateFontString(nil, "OVERLAY")
    childFrame.title:SetFontObject("GameFontHighlight")
    childFrame.title:SetPoint("TOP", childFrame, "TOP", 0, -5)
    childFrame.title:SetText("Whisper Message Configuration")
    
    -- Create input background
    
    local inputBg = CreateFrame("Frame", nil, childFrame, "InsetFrameTemplate")
    inputBg:SetPoint("TOPLEFT", childFrame, "TOPLEFT", 15, -30)
    inputBg:SetPoint("BOTTOMRIGHT", childFrame, "BOTTOMRIGHT", -15, 60)
    
    -- Create message input directly (no scroll frame needed for 260 chars)
    
    local messageInput = CreateFrame("EditBox", "WhisperThemAllMessageEditBox", inputBg)
    messageInput:SetPoint("TOPLEFT", inputBg, "TOPLEFT", 8, -8)
    messageInput:SetPoint("BOTTOMRIGHT", inputBg, "BOTTOMRIGHT", -8, 8)
    messageInput:SetMultiLine(true)
    messageInput:SetMaxLetters(260)
    messageInput:SetAutoFocus(false)
    messageInput:SetFontObject("ChatFontNormal")
    messageInput:EnableMouse(true)
    
    messageInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    
    -- Create placeholder text
    
    local placeholderText = messageInput:CreateFontString(nil, "OVERLAY")
    placeholderText:SetFontObject("ChatFontNormal")
    placeholderText:SetPoint("TOPLEFT", messageInput, "TOPLEFT", 3, -3)
    placeholderText:SetTextColor(0.5, 0.5, 0.5)
    placeholderText:SetText("Enter the predefined message that later can be send to all players in the list (max. 260 characters)")
    placeholderText:SetWidth(inputBg:GetWidth() - 20)
    placeholderText:SetJustifyH("LEFT")
    placeholderText:SetWordWrap(true)
    
    messageInput:SetScript("OnEditFocusGained", function()
        placeholderText:Hide()
    end)
    
    messageInput:SetScript("OnEditFocusLost", function()
        if messageInput:GetText() == "" then
            placeholderText:Show()
        end
    end)
    
    messageInput:SetScript("OnTextChanged", function(self, userInput)
        local text = self:GetText()
        
        if text == "" then
            placeholderText:Show()
        else
            placeholderText:Hide()
        end
        
        -- Count lines
        local lines = 1
        for _ in text:gmatch("\n") do
            lines = lines + 1
        end

        -- Limit to 3 lines
        if lines > 3 then
            local newText = text:sub(1, -2)
            self:SetText(newText)
            self:SetCursorPosition(#newText)
        end
    end)
    
    -- Create button background
    
    local buttonBg = childFrame:CreateTexture(nil, "BACKGROUND")
    buttonBg:SetPoint("BOTTOMLEFT", childFrame, "BOTTOMLEFT", 10, 10)
    buttonBg:SetPoint("BOTTOMRIGHT", childFrame, "BOTTOMRIGHT", -10, 10)
    buttonBg:SetHeight(40)
    buttonBg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
    
    -- Create cancel button
    
    local cancelButton = CreateFrame("Button", nil, childFrame, "UIPanelButtonTemplate")
    cancelButton:SetPoint("BOTTOMLEFT", childFrame, "BOTTOMLEFT", 20, 15)
    cancelButton:SetText("Close")
    cancelButton:SetWidth(80)
    
    -- Create save button
    
    local saveButton = CreateFrame("Button", nil, childFrame, "UIPanelButtonTemplate")
    saveButton:SetPoint("BOTTOMRIGHT", childFrame, "BOTTOMRIGHT", -20, 15)
    saveButton:SetText("Save")
    saveButton:SetWidth(80)
    
    local originalMessage = ""
    
    -- Initialize controls
    
    local function initializeControls()
        originalMessage = WhisperThemAllDB.message or ""
        messageInput:SetText(originalMessage)
        if originalMessage ~= "" then
            placeholderText:Hide()
        else
            placeholderText:Show()
        end
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

-- Run whisper send

local function runWhisperSend(messageText)
    local namesText = WhisperThemAllDB.playerNames
    if not namesText or namesText == "" then
        print("|cffff0000WhisperThemAll:|r No player names in list.")
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

-- Create close button

local function createCloseButton(parentFrame)
    local closeButton = CreateFrame("Button", "WhisperThemAllCancelButton", parentFrame, "UIPanelButtonTemplate")
    closeButton:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", 20, 15)
    closeButton:SetText("Close")
    closeButton:SetWidth(80)
    
    closeButton:SetScript("OnClick", function()
        whisperFrame:Hide()
    end)
    
    return closeButton
end

-- Create message button

local function createMessageButton(parentFrame)
    local configButton = CreateFrame("Button", "WhisperThemAllConfigButton", parentFrame, "UIPanelButtonTemplate")
    configButton:SetPoint("BOTTOM", parentFrame, "BOTTOM", 0, 15)
    configButton:SetText("Configure Message")
    configButton:SetWidth(140)
    
    configButton:SetScript("OnClick", function()
        showMessagePanel()
    end)
    
    return configButton
end

-- Create whisper button

local function createWhisperButton(parentFrame)
    local whisperButton = CreateFrame("Button", "WhisperThemAllWhisperButton", parentFrame, "UIPanelButtonTemplate")
    whisperButton:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -20, 15)
    whisperButton:SetText("Send Message")
    whisperButton:SetWidth(120)
    
    whisperButton:SetScript("OnClick", function()
        local messageText = WhisperThemAllDB.message
        if not messageText or messageText == "" then
            print("|cffff0000WhisperThemAll:|r No message configured. Click 'Configure Message' first.")
            return
        end
        
        runWhisperSend(messageText)
    end)
    
    return whisperButton
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

-- Replace FriendsFrame send message button

local function replaceFrameButton()
    if FriendsFrameSendMessageButton then
        FriendsFrameSendMessageButton:Hide()
        
        local wtaButton = CreateFrame("Button", "WhisperThemAllFrameButton", FriendsListFrame, "UIPanelButtonTemplate")
        wtaButton:SetSize(FriendsFrameSendMessageButton:GetWidth(), FriendsFrameSendMessageButton:GetHeight())
        wtaButton:SetPoint("CENTER", FriendsFrameSendMessageButton, "CENTER", 0, 0)
        wtaButton:SetText("WhisperThemAll")
        
        wtaButton:SetScript("OnClick", function()
            showWhisperFrame()
        end)
    end
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
        C_Timer.After(0.5, function()
            replaceFrameButton()
        end)
    end
end)