function CheckEqual( arg1, arg2 )
    return arg1 == arg2 and true or false
end

function ShouldError( stat )
    return not stat
end

local fso = require("fso")

local work_dir = fso.pwd()

do -- test pwd
    local msg = " pwd, current dir is "
    local ok, ret = pcall(fso.pwd)
    if ok then
        msg = "PASSED" .. msg .. ret
    else
        msg = "FAILED" .. " got error: " .. ret
    end
    print(msg)
end

do -- test cd
 
    do -- cd to current
    
        local msg = "\"cd(.)\" landed: "
        local expect = fso.pwd()
        local ok, ret = pcall(fso.cd, ".")
        local result = fso.pwd()
        if not ok or not CheckEqual(expect, result) then
            msg = "FAILED" .. msg .. ret
        else
            msg = "PASSED " ..msg.. fso.pwd()
        end
        print(msg)
    end

    do -- cd to parent
        local msg = "\"cd(..)\" landed: "
        local expect = "D:\\Projects\\lua\\fso\\lua"
        local ok, ret = pcall(fso.cd, "..")
        local result = fso.pwd()
        if not ok or not CheckEqual(expect, result) then
            msg = "FAILED" .. msg .. ret
        else
            msg = "PASSED " ..msg.. fso.pwd()
        end
        print(msg)
    end

    do -- cd to named
        local msg = "\"cd(./bin)\" landed: "
        local expect = "D:\\Projects\\lua\\fso\\lua\\bin"
        local ok, ret = pcall(fso.cd, "./bin")
        local result = fso.pwd()
        if not ok or not CheckEqual(expect, result) then
            msg = "FAILED" .. msg .. ret
        else
            msg = "PASSED " ..msg.. fso.pwd()
        end
        print(msg)
    end

    do -- cd to named-2
        local msg = "\"cd(c:\\Program Files)\" landed: "
        local expect = "c:\\Program Files"
        local ok, ret = pcall(fso.cd, "c:\\Program Files")
        local result = fso.pwd()
        if not ok or not CheckEqual(expect, result) then
            msg = "FAILED" .. msg .. ret
        else
            msg = "PASSED " ..msg.. fso.pwd()
        end
        print(msg)
    end

    do -- cd arg undefined, returns current dir
        local msg = "\"cd()\" landed: "
        local expect = "c:\\Program Files"
        local ok, ret = pcall(fso.cd)
        local result = fso.pwd()
        if not CheckEqual(expect, result) then
            msg = "FAILED" .. msg .. tostring(ret)
        else
            msg = "PASSED " ..msg.. fso.pwd()
        end
        print(msg)
    end

    do -- cd to unexisted
        local msg = "%s should fail for not existed folder \"cd (c:\\Programs)\" with error: %s"
        local expect = "c:\\Programs"
        local ok, ret = pcall(fso.cd, "c:\\Programs")
        local result = fso.pwd()
        if ShouldError(ok) then
            msg = string.format(msg, "PASSED", ret)
        else
            msg = "FAILED \"cd (c:\\Programs)\" landed to not existed " .. fso.pwd()
        end
        print(msg)
    end

    do -- cd arg bad type
        local msg = "%s should fail for bad type arg \"cd(1)\" with error: %s"
        local ok, ret = pcall(fso.cd, 1)
        if ShouldError(ok) then
            msg = string.format(msg, "PASSED", ret)
        else
            msg = "FAILED \"cd(1)\" landed to not existed " .. fso.pwd()
        end
        print(msg)
    end

    do -- cd arg bad type
        local msg = "%s should fail for bad type arg \"cd(true)\" with error: %s"
        local ok, ret = pcall(fso.cd, true)
        if ShouldError(ok) then
            msg = string.format(msg, "PASSED", ret)
        else
            msg = "FAILED \"cd(true)\" landed to not existed " .. fso.pwd()
        end
        print(msg)
    end
end

do -- test mkdir

    -- startup
    fso.cd(work_dir)

    do -- создать подкаталог bin в текущем каталоге
        local folder = "bin"
        local msg = " make subfolder \"mkdir(" ..folder.. ")\""
        local ok, ret = pcall(fso.mkdir, folder)
        if ok then
            msg = "PASSED " .. msg
        else
            msg = "FAILED " .. msg .. tostring(ret)
        end
        print(msg)
    end

    do -- создать подкаталог ./bin в текущем каталоге
        local folder = "./bin1"
        local msg = " make subfolder \"mkdir(" ..folder.. ")\" "
        local ok, ret = pcall(fso.mkdir, folder)
        if ok then
            msg = "PASSED " .. msg
        else
            msg = "FAILED " .. msg .. tostring(ret)
        end
        print(msg)
    end

    -- do -- создать подкаталог bin в произвольном каталоге
    --     local folder = "c:\\Program Files\\bin"
    --     local msg = " make subfolder \"mkdir(" .. folder .. ")\" "
    --     local ok, ret = pcall(fso.mkdir, folder)
    --     if ok then
    --         msg = "PASSED " .. msg
    --     else
    --         msg = "FAILED " .. msg .. tostring(ret)
    --     end
    --     print(msg)
    -- end

    do -- создать вложенные подкаталоги bin\release в текущем каталоге 
        local folder = "./bin2/release"
        local msg = " make subfolder \"mkdir(" .. folder .. ")\" "
        local ok, ret = pcall(fso.mkdir, folder)
        if ok then
            msg = "PASSED " .. msg
        else
            msg = "FAILED " .. msg .. tostring(ret)
        end
        print(msg)
    end

    do -- создать несколько каталогов одновременно
        local folders = {"./bin3/release", "./bin3/debug"}
        for _i, folder in ipairs(folders) do
            local msg = " make list of subfolders \"mkdir(" .. folder .. ")\" "
            local ok, ret = pcall(fso.mkdir, folder)
            if ok then
                msg = "PASSED " .. msg
            else
                msg = "FAILED " .. msg .. tostring(ret)
            end
            print(msg)
        end
    end


    do -- вызов функции без аргументов
    local folder = ""
        local tname = "\"mkdir(" ..folder..")\""
        local msg = "%s %s should fail with error: %s"
        local ok, ret = pcall(fso.mkdir)
        if ShouldError(ok) then
            msg = string.format(msg, "PASSED", tname, ret)
        else
            msg = "FAILED \"mkdir()\""
        end
        print(msg)    
    end

    do -- вызов функции с недопустимым именем каталога
        
        local folder = "./bin?"
        local tname = "\"mkdir(" ..folder..")\""
        local msg = "%s %s should fail with error: %s"
        local ok, ret = pcall(fso.mkdir, folder)
        if ShouldError(ok) then
            msg = string.format(msg, "PASSED", tname, ret)
        else
            msg = string.format("FAILED %s", tname)
        end        
        print(msg)
    end

    do -- вызов функции с аргументом, который не может
       -- являться именем для каталога

        local folder = true
        local tname = "\"mkdir(" ..tostring(folder)..")\""
        local msg = "%s %s should fail with error: %s"
        local ok, ret = pcall(fso.mkdir, folder)
        if ShouldError(ok) then
            msg = string.format(msg, "PASSED", tname, ret)
        else
            msg = string.format("FAILED %s", tname)
        end
        print(msg) 
    end

end