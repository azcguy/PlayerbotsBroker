-- Runs first, creates root objects and configs
PlayerbotsBroker = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0", "AceHook-2.1", "AceDebug-2.0", "AceEvent-2.0")
PlayerbotsBroker.rootPath = "Interface\\AddOns\\PlayerbotsBroker\\"
PlayerbotsBroker.rootFrame = CreateFrame("Frame", "PlayerbotsBrokerFrame", UIParent)
PlayerbotsBroker.rootFrame:SetSize(1,1)
PlayerbotsBroker.rootFrame:Show()
PlayerbotsBroker.debug = AceLibrary:GetInstance("AceDebug-2.0")
PlayerbotsBroker:RegisterDB("PlayerbotsBrokerDb", "PlayerbotsBrokerDbPerChar")



