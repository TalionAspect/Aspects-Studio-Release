-- Aspects Studio release loader
-- Source parts are downloaded and verified before the assembled code runs.
local BASE = "https://raw.githubusercontent.com/TalionAspect/Aspects-Studio-Release/main/release/"
local PART_COUNT = 16
local PART_BYTES = 262144
local LAST_PART_BYTES = 200388
local TOTAL_BYTES = 4132548
local EXPECTED_ADLER32 = 3167467438

local chunks = table.create(PART_COUNT)
local a, b = 1, 0
for i = 1, PART_COUNT do
    local file = string.format("part_%02d.txt", i)
    local url = BASE .. file
    local ok, content = pcall(function()
        return game:HttpGet(url)
    end)
    assert(ok and type(content) == "string", "Aspects: download failed for " .. file .. ": " .. tostring(content))
    local expected = (i == PART_COUNT) and LAST_PART_BYTES or PART_BYTES
    assert(#content == expected, "Aspects: wrong size for " .. file .. " (" .. #content .. "/" .. expected .. ")")
    chunks[i] = content
    for pos = 1, #content do
        a = (a + string.byte(content, pos)) % 65521
        b = (b + a) % 65521
    end
end

local scriptText = table.concat(chunks)
local checksum = b * 65536 + a
assert(#scriptText == TOTAL_BYTES, "Aspects: incomplete release")
assert(checksum == EXPECTED_ADLER32, "Aspects: release integrity check failed")
print("Aspects Studio verified:", #scriptText, "bytes; Adler-32:", checksum)

-- For download-only verification, set getgenv().ASPECTS_VERIFY_ONLY = true first.
local env = (type(getgenv) == "function" and getgenv()) or _G
if env.ASPECTS_VERIFY_ONLY == true then
    print("Aspects Studio: verification-only mode. No obfuscated code was executed.")
    return true
end

local chunk, compileError = loadstring(scriptText)
assert(type(chunk) == "function", "Aspects: compile failed: " .. tostring(compileError))
return chunk()
