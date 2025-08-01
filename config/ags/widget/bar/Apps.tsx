import { Gtk } from "ags/gtk4";
import { Windows } from "../../windows";
import { createBinding } from "ags";
import { tr } from "../../i18n/intl";

export const Apps = () => 
    <Gtk.Button class={createBinding(Windows.getDefault(), "openWindows").as((openWindows) => 
            `apps ${Object.hasOwn(openWindows, "apps-window") ? "open" : ""}`
        )} $={(self) => {
            const conns: Array<number> = [
                self.connect("clicked", (_) => Windows.getDefault().open("apps-window")),
                self.connect("destroy", (_) => conns.forEach(id => self.disconnect(id)))
            ];
        }} iconName={"applications-other-symbolic"} halign={Gtk.Align.CENTER}
        hexpand={true} tooltipText={tr("apps")}
    />;
