function CheckEqual( arg1, arg2 )
    return arg1 == arg2 and true or false
end


local fso = require("fso")

-- test pwd
local msg = " test \"pwd\" - "
local ok, ret = pcall(fso.pwd)
if ok then
    msg = "PASSED" .. msg .. ret
else
    msg = "FAILED" .. msg .. ret
end
print(msg)

-- test cd
-- to current
local msg = " test \"cd(.)\" "
local expect = fso.pwd()
local ok, ret = pcall(fso.cd, ".")
local result = fso.pwd()
if not ok or not CheckEqual(expect, result) then
    msg = "FAILED" .. msg .. ret
else
    msg = "PASSED " ..msg.. fso.pwd()
end
print(msg)

-- to parent
local msg = " test \"cd(..)\" "
local expect = "D:\\Projects\\lua\\fso\\lua"
local ok, ret = pcall(fso.cd, "..")
local result = fso.pwd()
if not ok or not CheckEqual(expect, result) then
    msg = "FAILED" .. msg .. ret
else
    msg = "PASSED " ..msg.. fso.pwd()
end
print(msg)
-- to named
local msg = " test \"cd(./bin)\" "
local expect = "D:\\Projects\\lua\\fso\\lua\\bin"
local ok, ret = pcall(fso.cd, "./bin")
local result = fso.pwd()
if not ok or not CheckEqual(expect, result) then
    msg = "FAILED" .. msg .. ret
else
    msg = "PASSED " ..msg.. fso.pwd()
end
print(msg)

-- to named
local msg = " test \"cd(c:\\Program Files)\" "
local expect = "c:\\Program Files"
local ok, ret = pcall(fso.cd, "c:\\Program Files")
local result = fso.pwd()
if not ok or not CheckEqual(expect, result) then
    msg = "FAILED" .. msg .. ret
else
    msg = "PASSED " ..msg.. fso.pwd()
end
print(msg)

-- to unexisted
local msg = " test unexisted \"cd (c:\\Programs)\" "
local expect = "c:\\Programs"
local ok, ret = pcall(fso.cd, "c:\\Programs")
local result = fso.pwd()
if not ok or not CheckEqual(expect, result) then
    msg = "FAILED" .. msg .. tostring(ret)
else
    msg = "PASSED " ..msg.. fso.pwd()
end
print(msg)

-- arg undefined, returns current dir
local msg = " test undefined \"cd()\" "
local expect = "c:\\Program Files"
local ok, ret = pcall(fso.cd)
local result = fso.pwd()
if not CheckEqual(expect, result) then
    msg = "FAILED" .. msg .. tostring(ret)
else
    msg = "PASSED " ..msg.. fso.pwd()
end
print(msg)

-- arg bad type
local msg = " test bad type \"cd(1)\" "
local ok1, ret1 = pcall(fso.cd, 1)
if ok1 then
    msg = "PASSED" ..msg.. fso.pwd()
else
    msg = "FAILED" ..msg.. tostring(ret1)
end
print(msg)

-- arg bad type
local msg = " test bad type \"cd(true)\" "
local ok, ret = pcall(fso.cd, true)
if ok then
    msg = "PASSED " ..msg.. fso.pwd()
else
    msg = "FAILED " ..msg.. tostring(ret)
end
print(msg)

