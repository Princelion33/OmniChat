-- ==========================================
--        OMNICHAT HUB - INTERFACE
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "OmniChat Hub 🤖",
    Icon = 0, 
    LoadingTitle = "OmniChat Interface",
    LoadingSubtitle = "by YourName",
    ShowText = "OmniChat",
    Theme = "Default", 
    
    -- LA CORRECTION EST ICI :
    ToggleUIKeybind = Enum.KeyCode.RightShift, -- Ou tu peux mettre "K" avec des guillemets si tu préfères
    
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "OmniChatConfig",
       FileName = "OmniChatSave"
    },
    
    Discord = {
       Enabled = false,
       Invite = "noinvitelink", 
       RememberJoins = true 
    },
    
    KeySystem = false 
})

-- ==========================================
--                 TABS
-- ==========================================
local MainTab = Window:CreateTab("Main", "home")
local AITab = Window:CreateTab("AI Settings", "cpu")
local PremiumTab = Window:CreateTab("Premium", "star")
local ChatTab = Window:CreateTab("Chat", "message-square")
local MoreTab = Window:CreateTab("More", "plus-circle")
local HelpTab = Window:CreateTab("Help", "help-circle")

-- ==========================================
--             TAB 1 : MAIN
-- ==========================================
local PointsLabel = MainTab:CreateLabel("💳 Current Points: 0", "coins", Color3.fromRGB(255, 215, 0), false)

MainTab:CreateToggle({
    Name = "Running",
    CurrentValue = false,
    Flag = "Toggle_Running",
    Callback = function(Value)
        print("Bot is running: ", Value)
    end,
})

MainTab:CreateDivider()

MainTab:CreateInput({
    Name = "Blacklist a player",
    CurrentValue = "",
    PlaceholderText = "Enter exact username...",
    RemoveTextAfterFocusLost = true,
    Flag = "Input_Blacklist",
    Callback = function(Text)
        print("Blacklisted: ", Text)
    end,
})

MainTab:CreateDropdown({
    Name = "Blacklisted Players",
    Options = {"None"},
    CurrentOption = {"None"},
    MultipleOptions = false,
    Flag = "Drop_Blacklist",
    Callback = function(Options) end,
})

MainTab:CreateButton({
    Name = "Reset Blacklist",
    Callback = function()
        print("Blacklist reset")
    end,
})

MainTab:CreateDivider()

MainTab:CreateToggle({
    Name = "Whitelist Mode",
    CurrentValue = false,
    Flag = "Toggle_Whitelist",
    Callback = function(Value) end,
})

MainTab:CreateSlider({
    Name = "Listening Range (Studs)",
    Range = {10, 200},
    Increment = 10,
    Suffix = "Studs",
    CurrentValue = 50,
    Flag = "Slider_Range",
    Callback = function(Value) end,
})

MainTab:CreateSlider({
    Name = "Max Message Length",
    Range = {10, 300},
    Increment = 10,
    Suffix = "Chars",
    CurrentValue = 150,
    Flag = "Slider_Length",
    Callback = function(Value) end,
})

MainTab:CreateToggle({
    Name = "Anti Spam",
    CurrentValue = true,
    Flag = "Toggle_AntiSpam",
    Callback = function(Value) end,
})

MainTab:CreateToggle({
    Name = "Buffer (Add 3 sec delay)",
    CurrentValue = false,
    Flag = "Toggle_Buffer",
    Callback = function(Value) end,
})

MainTab:CreateButton({
    Name = "Reset AI Memory",
    Callback = function()
        Rayfield:Notify({Title = "Memory Cleared", Content = "The AI forgot the previous conversation.", Duration = 3})
    end,
})

MainTab:CreateInput({
    Name = "Chatbot Message Formatting",
    CurrentValue = "[ChatBot] %s",
    PlaceholderText = "[ChatBot] %s",
    RemoveTextAfterFocusLost = false,
    Flag = "Input_Format",
    Callback = function(Text) end,
})

MainTab:CreateToggle({
    Name = "Auto remind you're a chatbot",
    CurrentValue = true,
    Flag = "Toggle_RemindBot",
    Callback = function(Value) end,
})

-- ==========================================
--             TAB 2 : AI SETTINGS
-- ==========================================
AITab:CreateDropdown({
    Name = "Select the character of your AI",
    Options = {"Normal", "Aggressive", "Friendly", "Sarcastic", "UwU"},
    CurrentOption = {"Normal"},
    MultipleOptions = false,
    Flag = "Drop_Character",
    Callback = function(Options) end,
})

AITab:CreateDropdown({
    Name = "Select AI Model",
    Options = {
        "Meta-Llama-3.1-8B-Instruct (Default | 5 points)", 
        "ALLaM-7B-Instruct-preview (8 points)", 
        "Meta-Llama-3.1-70B-Instruct (High IQ | 20 points)"
    },
    CurrentOption = {"Meta-Llama-3.1-8B-Instruct (Default | 5 points)"},
    MultipleOptions = false,
    Flag = "Drop_Model",
    Callback = function(Options) end,
})

AITab:CreateDropdown({
    Name = "Language",
    Options = {"English", "French", "Spanish", "German"},
    CurrentOption = {"English"},
    MultipleOptions = false,
    Flag = "Drop_Language",
    Callback = function(Options) end,
})

-- ==========================================
--             TAB 3 : PREMIUM
-- ==========================================
PremiumTab:CreateLabel("❌ Premium is not activated", "x-octagon", Color3.fromRGB(255, 50, 50), false)

PremiumTab:CreateToggle({
    Name = "Text to Action Mode (Costs 1.5x points)",
    CurrentValue = false,
    Flag = "Toggle_TextAction",
    Callback = function(Value) end,
})

PremiumTab:CreateToggle({
    Name = "Auto Moving",
    CurrentValue = false,
    Flag = "Toggle_AutoMove",
    Callback = function(Value) end,
})

PremiumTab:CreateDivider()

PremiumTab:CreateToggle({
    Name = "Enable Custom Prompt",
    CurrentValue = false,
    Flag = "Toggle_CustomPrompt",
    Callback = function(Value) end,
})

PremiumTab:CreateInput({
    Name = "Enter custom prompt here",
    CurrentValue = "",
    PlaceholderText = "Act as a...",
    RemoveTextAfterFocusLost = false,
    Flag = "Input_Prompt",
    Callback = function(Text) end,
})

PremiumTab:CreateParagraph({
    Title = "Current Custom Prompt", 
    Content = "Just be a normal ai"
})

PremiumTab:CreateDivider()

PremiumTab:CreateDropdown({
    Name = "Custom AIs",
    Options = {"None"},
    CurrentOption = {"None"},
    MultipleOptions = false,
    Flag = "Drop_CustomAIs",
    Callback = function(Options) end,
})

PremiumTab:CreateInput({
    Name = "Save custom prompt with name:",
    CurrentValue = "",
    PlaceholderText = "Name your AI...",
    RemoveTextAfterFocusLost = true,
    Flag = "Input_SavePrompt",
    Callback = function(Text) end,
})

-- ==========================================
--             TAB 4 : CHAT
-- ==========================================
ChatTab:CreateButton({
    Name = "Clear Chat",
    Callback = function() end,
})

local AIAnswerParagraph = ChatTab:CreateParagraph({
    Title = "AI's Answer", 
    Content = "Waiting for a message..."
})

ChatTab:CreateButton({
    Name = "Copy the answer",
    Callback = function()
        -- setclipboard("Le texte de l'IA ici")
        Rayfield:Notify({Title = "Copied!", Content = "Answer copied to clipboard.", Duration = 3})
    end,
})

ChatTab:CreateInput({
    Name = "Message",
    CurrentValue = "",
    PlaceholderText = "Talk to the AI directly here...",
    RemoveTextAfterFocusLost = true,
    Flag = "Input_ManualMessage",
    Callback = function(Text) 
        -- Simulation
        AIAnswerParagraph:Set({Title = "AI's Answer", Content = "Processing..."})
    end,
})

-- ==========================================
--             TAB 5 : MORE
-- ==========================================
MoreTab:CreateInput({
    Name = "OmniChat Key",
    CurrentValue = "",
    PlaceholderText = "Paste your OMNI_ key here...",
    RemoveTextAfterFocusLost = false,
    Flag = "Input_APIKey",
    Callback = function(Text) 
        print("Key entered: " .. Text)
    end,
})

MoreTab:CreateButton({
    Name = "Official Discord Server",
    Callback = function()
        -- setclipboard("https://discord.gg/tonserveur")
        Rayfield:Notify({Title = "Discord", Content = "Link copied to clipboard!", Duration = 3})
    end,
})

MoreTab:CreateToggle({
    Name = "Chat Bypass",
    CurrentValue = false,
    Flag = "Toggle_Bypass",
    Callback = function(Value) end,
})

MoreTab:CreateToggle({
    Name = "Anti Chat Logger",
    CurrentValue = true,
    Flag = "Toggle_AntiLog",
    Callback = function(Value) end,
})

MoreTab:CreateButton({
    Name = "Delete Saved AIs",
    Callback = function() end,
})

-- ==========================================
--             TAB 6 : HELP
-- ==========================================
HelpTab:CreateParagraph({
    Title = "How do I use OmniChat?", 
    Content = "1. Get your key from our Discord Server.\n2. Go to the 'More' tab and paste your key.\n3. Go to 'Main' and toggle 'Running'."
})

HelpTab:CreateParagraph({
    Title = "How to use with a different Roblox account?", 
    Content = "You can add multiple Roblox accounts to a single key! Go to the bot channel in Discord and type /addaccount with your Roblox username."
})

HelpTab:CreateParagraph({
    Title = "What are the points for?", 
    Content = "The API is expensive. Each message costs points depending on the AI model you choose (5, 8, or 20 pts)."
})

HelpTab:CreateParagraph({
    Title = "How to get more points?", 
    Content = "Use /claim in Discord every 24h, use /beg to ask other players, or buy premium packages via tickets."
})

HelpTab:CreateParagraph({
    Title = "I forgot my key!", 
    Content = "Use the /remind command in the Discord bot channel to get it back in DM."
})

-- ==========================================
--      INITIALIZATION & SAVING
-- ==========================================
Rayfield:LoadConfiguration()
