local RemoteEvents = {
    RE_PlayerProfileReady = "RE_PlayerProfileReady",
    RE_PlayerProfileUpdate = "RE_PlayerProfileUpdate",
    RE_PlayerProfileChanged = "RE_PlayerProfileChanged",
    RE_PlayerProfilePrint = "RE_PlayerProfilePrint",
}

local BindableEvents = {
    BE_ProfileReady = "BE_ProfileReady",
    BE_ProfileUpdate = "BE_ProfileUpdate",
    BE_ProfileChanged = "BE_ProfileChanged",
}

return {
    RemoteEvents = RemoteEvents,
    BindableEvents = BindableEvents,
}