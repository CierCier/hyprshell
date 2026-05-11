
function setup_vkfix()
    if hl.plugin.csgo_vulkan_fix ~= nil then
        hl.plugin.csgo_vulkan_fix.vkfix_app({ app = "cs2", w = 2304, h = 1440 })
        hl.config({
            plugin = {
                csgo_vulkan_fix = {
                    fix_mouse = false
                }
            }
        })
    end
end


setup_vkfix()
