#include <filesystem>
#include <locale>

#include <lua.hpp>

#include "error.h"

#ifdef _WIN32

#define LIB_EXPORT __declspec(dllexport)

#elif __linux__

// GCC-specific export attribute
#define LIB_EXPORT __attribute__((visibility("default")))

#endif

static int lpwd(lua_State* state) {

    setlocale(LC_ALL, "en_US.UTF-8"); 

    std::filesystem::path path = std::filesystem::current_path();

    #ifdef _WIN32
        std::string sp = path.u8string();
    #elif __linux__
        std::string sp = path.string();
    #endif
    
    lua_pushstring(state, sp.c_str());

    return 1;
}

static int lcd(lua_State* state) {
    
    setlocale(LC_ALL, "en_US.UTF-8");

    // проверка кол-ва и типа аргументов
    int num_args = lua_gettop(state);
    if (num_args == 0) {
        // вызов функции cd без аргументов
        // не меняем каталог, возвращаем true
        lua_pushboolean(state, 1);
        return 1;

    } else if(num_args > 1) {
        // ошибка, кол-во аргументов > 1
        lua_pushstring(state, efso::EArgsExceeeded);
        lua_error(state);
    }

    int arg_type = lua_type(state, 1);
    if (arg_type != LUA_TSTRING) {
        // ошибка, тип аргумента не является строкой
        lua_pushstring(state, efso::EWrongArgType);
        lua_error(state);
    }

    const char* arg_path = lua_tostring(state,1);

    std::filesystem::path pp{arg_path};

    std::error_code ec;
    std::filesystem::current_path(pp, ec);
    if (ec) {
        // ошибка при обращении к файловой системе
        // пробрасываем ее
        lua_pushstring(state, ec.message().c_str());
        lua_error(state);
    }

    // все хорошо и возвращаем true
    lua_pushboolean(state, 1);
    return 1;
}

static int lmkdir(lua_State* state) {

    setlocale(LC_ALL, "en_US.UTF-8"); 

    const char* arg_path = luaL_checkstring(state, 1);

    std::filesystem::path pp{ arg_path };

    std::error_code ec;
    std::filesystem::create_directory(pp, ec);
    if (ec) {
        // error
        lua_pushnil(state);
        lua_pushstring(state, ec.message().c_str());
        return 2;
    }

    // succeeded
    lua_pushboolean(state, 1);

    return 1;
}

typedef struct DirHandler {
    int dhc{ 0 };
    std::filesystem::directory_iterator it;
    DirHandler(const char* path) : dhc{ 0 }, it{path} {};
} DirHandler;

const char* dir_metatable = "dir_meta";

// должен класть на стек 2 элемента: индекс и значение, либо 0 ес ли элементов больше нет
static int ldir_iter(lua_State* state)
{

    DirHandler* dh = static_cast<DirHandler*>(lua_touserdata(state, 1));
    int index = luaL_checkinteger(state, 2); //

    if (index > 0) {
        dh->it++;
    }

    if (dh->it == std::filesystem::directory_iterator{}) {
        return 0;
    }

    lua_pushinteger(state, ++dh->dhc);
    lua_pushlightuserdata(state, dh);

    luaL_getmetatable(state, dir_metatable);
    lua_setmetatable(state, -2); 

    return 2;
}

// инициализация итератора dir
// надо возвращать в таком порядке: итераторная функция, юзердата, счетчик
static int ldir_init(lua_State* state) {
    setlocale(LC_ALL, "en_US.UTF-8");

    const char* path = luaL_checkstring(state, 1);

    DirHandler* dh = new DirHandler(path);
    lua_pushlightuserdata(state, dh);

    lua_pushcfunction(state, ldir_iter);
    lua_insert(state, -2); //меняем порядок на стеке

    lua_pushinteger(state, dh->dhc);

    return 3;

}

static int ldir_path(lua_State* state)
{
    setlocale(LC_ALL, "en_US.UTF-8");

    DirHandler* dh = static_cast<DirHandler*>(lua_touserdata(state, 1));

    #ifdef _WIN32
        std::string sp = dh->it->path().u8string();
    #elif __linux__
        std::string sp = dh->it->path().string();
    #endif
    
    lua_pushstring(state, sp.c_str());

    return 1;
}

const struct luaL_Reg fsolib[] = {
    {"pwd",     lpwd},
    {"cd",      lcd},
    {"mkdir",   lmkdir},
    { "dir",    ldir_init},
    {nullptr,   nullptr}
};

extern "C" {

    int LIB_EXPORT luaopen_fso(lua_State* state) {

        const luaL_Reg dir_methods[] = {
            { "path", ldir_path },
            { nullptr, nullptr}
        };
        luaL_newmetatable(state,    dir_metatable);
        luaL_setfuncs(state,        dir_methods, 0);

        // copy the metatable to the top of the stack 
        // and set it as the __index value in the metatable
        lua_pushvalue(state, -1);
        lua_setfield(state, -2, "__index");

        luaL_newlib(state, fsolib);
        lua_pushvalue(state, -1);
        lua_setglobal(state, "fso");

        return 1;
    }

}




