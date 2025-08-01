import { Gtk } from "ags/gtk4";
import { Windows } from "../../windows";
import { createBinding } from "ags";
import { time } from "../../scripts/utils";
import { Config } from "../../scripts/config";

export const Clock = () => 
    <Gtk.Button class={createBinding(Windows.getDefault(), "openWindows").as((wins) =>
        `clock ${Object.hasOwn(wins, "center-window") ? "open" : ""}`)}
        $={(self) => {
            const conns: Array<number> = [
                self.connect("clicked", (_) => Windows.getDefault().toggle("center-window")),
                self.connect("destroy", (_) => conns.forEach(id => self.disconnect(id)))
            ];
        }}
        label={time((dt) => dt.format(
            Config.getDefault().getProperty("clock.date_format", "string")) 
                ?? "An error occurred"
        )}
    />;
