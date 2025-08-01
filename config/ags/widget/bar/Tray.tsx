import { createBinding, createComputed, For, With } from "ags";
import { Gdk, Gtk } from "ags/gtk4";

import AstalTray from "gi://AstalTray"
import Gio from "gi://Gio?version=2.0";
import { variableToBoolean } from "../../scripts/utils";
import GObject from "gi://GObject?version=2.0";


const astalTray = AstalTray.get_default();

function popoverFromModel(model: Gio.MenuModel, actionGroup: Gio.ActionGroup | null): Gtk.PopoverMenu {
    const menu = Gtk.PopoverMenu.new_from_model(model);
    menu.insert_action_group("dbusmenu", actionGroup)

    return menu;
}

export const Tray = () => {
    const items = createBinding(astalTray, "items").as(items => items.filter(item => item?.gicon));

    return <Gtk.Box class={"tray"} visible={variableToBoolean(items)} spacing={10}>
        <For each={items}>
            {(item: AstalTray.TrayItem) => <Gtk.Box class={"item"}>

                <With value={createComputed([
                      createBinding(item, "actionGroup"),
                      createBinding(item, "menuModel")
                  ])}>
                    {([actionGroup, menuModel]: [Gio.ActionGroup, Gio.MenuModel]) => {
                      const popover = popoverFromModel(menuModel, actionGroup);

                      return <Gtk.MenuButton class={"item-button"} tooltipMarkup={
                        createBinding(item, "tooltipMarkup")} tooltipText={
                        createBinding(item, "tooltipText")} popover={popover}
                        $={(self) => {
                            const conns: Map<GObject.Object, number> = new Map();
                            const gestureClick = Gtk.GestureClick.new();

                            self.add_controller(gestureClick);

                            conns.set(gestureClick, gestureClick.connect("released", (gesture, _, x, y) => {
                                if(gesture.get_current_button() === Gdk.BUTTON_PRIMARY) {
                                    item.activate(x, y);
                                    return;
                                } else if(gesture.get_current_button() === Gdk.BUTTON_SECONDARY) {
                                    item.about_to_show();
                                    self.popup();
                                }
                            }))
                        }}>

                          <Gtk.Image gicon={createBinding(item, "gicon")} pixelSize={16} />
                      </Gtk.MenuButton>
                    }}
                </With>
            </Gtk.Box>}
        </For>
    </Gtk.Box>
}
