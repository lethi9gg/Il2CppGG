local buildLT9, script_build, script_cache, requireold = {
   name = "Il2CppGG",
   input = "init",
   output = "build/Il2CppGG.lua"
}, {}, {}, require
function require(Name)
    local mod = package.loaded[Name]
    if mod ~= nil then return mod end
    local name, _name = Name:gsub("%.", "/") .. ".lua"
    if script_cache[name] == nil then
        if not os.rename(name, name) then
            for path in package.path:gmatch('[^;]+') do
                local _path = path:gsub("%?.lua$", "") .. name
                if os.rename(_path, _path) then
                    _name = _path
                    break
                end
            end
        end
        script_cache[name] = loadfile(_name or name)
        script_build[#script_build+1] = {name = Name, src = io.open(_name or name, "r"):read("a")}
    end
    if script_cache[name] ~= nil then
        return script_cache[name]()
    end
    error("Failed to load script " .. name)
end
function build(info)
    local input = info.input:gsub("%.", "/")
    local output = info.output
    local pathold = package.path
    package.path = (input:find("%.") or input:find("/")) and input:match("(.+)/[^/]+$"):match("(.+)/[^/]+$") .. "/?.lua;" .. input:match("(.*[/%\\])") .. "?.lua;" .. package.path or package.path
    local ok, res = pcall(require, input)
    if not ok then
        print(res)
    end
    require = requireold
    package.path = pathold
    script_build[1].name = info.name
    local file = io.open(output, "w")
    file:write("local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)\n\tlocal loadingPlaceholder = {[{}] = true}\n\n\tlocal register\n\tlocal modules = {}\n\n\tlocal require\n\tlocal loaded = {}\n\n\tregister = function(name, body)\n\t\tif not modules[name] then\n\t\t\tmodules[name] = body\n\t\tend\n\tend\n\n\trequire = function(name)\n\t\tlocal loadedModule = loaded[name]\n\n\t\tif loadedModule then\n\t\t\tif loadedModule == loadingPlaceholder then\n\t\t\t\treturn nil\n\t\t\tend\n\t\telse\n\t\t\tif not modules[name] then\n\t\t\t\tif not superRequire then\n\t\t\t\t\tlocal identifier = type(name) == \'string\' and \'\\\"\' .. name .. \'\\\"\' or tostring(name)\n\t\t\t\t\terror(\'Tried to require \' .. identifier .. \', but no such module has been registered\')\n\t\t\t\telse\n\t\t\t\t\treturn superRequire(name)\n\t\t\t\tend\n\t\t\tend\n\n\t\t\tloaded[name] = loadingPlaceholder\n\t\t\tloadedModule = modules[name](require, loaded, register, modules)\n\t\t\tloaded[name] = loadedModule\n\t\tend\n\n\t\treturn loadedModule\n\tend\n\n\treturn require, loaded, register, modules\nend)(require)\n")
    for i, v in pairs(script_build) do
        file:write('__bundle_register("' .. v.name .. '", function(require, _LOADED, __bundle_register, __bundle_modules)\n' .. v.src .. '\nend)')
        print(output:match("[^/\\]+$"), "<--", v.name)
    end
    file:write('\nreturn __bundle_require("' .. info.name .. '")'):close()
    return os.rename(output, output) and output .. " --> OK" or output .. " --> ERROR"
end
print( build(buildLT9) )
