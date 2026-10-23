-- Aspects Studio — Panda Auth / Kryptic Vault
-- Protected code stays in Vault. No license keys or private source belong here.
local VAULT_URL = "https://vss.pandauth.com/kv/60b75eb13710c69a"
local ok, source = pcall(function()
    return game:HttpGet(VAULT_URL)
end)
if not ok or type(source) ~= "string" or source == "" then
    error("Aspects Studio: Vault download failed. Please retry shortly.", 0)
end
local run, compileError = loadstring(source)
if not run then
    error("Aspects Studio: Vault loader could not compile: " .. tostring(compileError), 0)
end
return run()
