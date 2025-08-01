import GObject, { getter, register, signal } from "ags/gobject";
import { Astal } from "ags/gtk4";
import { Bar } from "./window/Bar";

import App from "ags/gtk4/app"
import AstalHyprland from "gi://AstalHyprland";
import { OSD } from "./window/OSD";
import { ControlCenter } from "./window/ControlCenter";
import { FloatingNotifications } from "./window/FloatingNotifications";
import { CenterWindow } from "./window/CenterWindow";
import { LogoutMenu } from "./window/LogoutMenu";
import { AppsWindow } from "./window/AppsWindow";


export { Windows };

/**
 * Windowing System
 * Possible actions: getting window states, close, open, toggle windows and
 * registering windows.
 * Also contains util functions to create dynamic windows, opening the window only on focused 
 * monitor, or all available monitors!
 */
@register()
class Windows extends GObject.Object {
    private static instance: (Windows | null);

    #openWindows: Record<string, Astal.Window | Array<Astal.Window>> = {};
    #windowConnections: Record<string, (Array<number> | Array<Array<number>>)> = {};
    #appConnections: Array<number> = [];
    #windows: Record<string, (() => (Astal.Window | Array<Astal.Window>))> = {
        "bar": this.createWindowForMonitors(Bar),
        "osd": this.createWindowForFocusedMonitor(OSD),
        "control-center": this.createWindowForFocusedMonitor(ControlCenter),
        "center-window": this.createWindowForFocusedMonitor(CenterWindow),
        "logout-menu": this.createWindowForFocusedMonitor(LogoutMenu),
        "floating-notifications": this.createWindowForFocusedMonitor(FloatingNotifications),
        "apps-window": this.createWindowForFocusedMonitor(AppsWindow)
    };

    @signal(String) opened(_name: string) {}
    @signal(String) closed(_name: string) {}

    get windows() { return this.#windows; }

    @getter(Object)
    get openWindows(): object { return this.#openWindows; };

    constructor() {
        super();

        // Listen to monitor events
        this.#appConnections.push(
            AstalHyprland.get_default().connect("monitor-added", (_, _monitor) => {
                AstalHyprland.get_default().get_monitors().length > 0 && 
                    this.reopen();
            }),
            AstalHyprland.get_default().connect("monitor-removed", (_, monitor) => {
                Object.values(this.openWindows).map((window: (Array<Astal.Window> | Astal.Window), i: number) => {
                    if(Array.isArray(window)) {
                        window = window as Array<Astal.Window>;
                        window.map(win => {
                            if(win.get_monitor() === monitor) {
                                win?.close();
                                this.#openWindows[i] = (this.#openWindows[i] as Array<Astal.Window>).filter(item =>
                                    item !== win);
                            }
                        });

                        if((this.#openWindows[i] as Array<Astal.Window>).length < 1) 
                            delete this.#openWindows[i];
                    }

                    window = window as Astal.Window;
                    if(window.get_monitor() === monitor) 
                        window.close();
                });
            })
        );
    }

    vfunc_dispose() {
        Object.keys(this.#windowConnections).map(name => 
            this.disconnectWindow(name));

        this.#appConnections.map(id => 
            GObject.signal_handler_is_connected(App, id) && 
                App.disconnect(id));
    }

    private disconnectWindow(name: keyof typeof this.windows) {
        const window = this.#openWindows[name];
        if(!window) {
            console.log("couldn't disconnect, window is not open");
            return;
        }

        this.#windowConnections[name].map((id: Array<number> | number) => {
            if(Array.isArray(window)) {
                window.map((win, i) => {
                    const curId = (id as Array<number>)[i];

                    GObject.signal_handler_is_connected(win, curId) && 
                        win.disconnect(curId);
                });
                return;
            }

            GObject.signal_handler_is_connected(window, id as number) &&
                window.disconnect(id as number);
        });

        delete this.#windowConnections[name];
    }

    private connectWindow(name: keyof typeof this.windows) {
        if(Object.hasOwn(this.#windowConnections, name)) return;

        if(!this.#openWindows?.[name]) {
            console.log(`${name} is not open, will not connect`);
            return;
        }

        if(Array.isArray(this.#openWindows[name])) {
            this.#windowConnections[name] = this.#openWindows[name].map(win => [
                win.connect("map", (window) => {
                    if(this.isVisible(name)) return;

                    this.#openWindows[name] = window;
                    this.notify("open-windows");
                }),
                win.connect("destroy", () => {
                    this.disconnectWindow(name);
                    this.notify("open-windows");
                })
            ]);

            return;
        }

        this.#windowConnections[name] = [
            this.#openWindows[name].connect("map", (window) => {
                if(this.isVisible(name)) return;

                this.#openWindows[name] = window;
                this.notify("open-windows");
            }),
            this.#openWindows[name].connect("destroy", () => {
                this.disconnectWindow(name);
                delete this.#openWindows[name];
                this.notify("open-windows");
            })
        ];
    }

    public static getDefault(): Windows {
        if(!this.instance)
            this.instance = new Windows();

        return this.instance;
    }

    /**
     * Creates a window instance for every monitor connected
     * @param windowFun function: (mon: number) => Astal.Window, returned window must use provided monitor number
     * @returns a function that when called, returns Array<Astal.Window>
     * @throws Error if there are no monitors connected
     */
    public createWindowForMonitors(windowFun: (mon: number) => GObject.Object|Astal.Window): (() => Array<Astal.Window>) {
        const monitors = AstalHyprland.get_default().get_monitors();
        if(monitors.length < 1) 
            throw new Error("Couldn't create window for monitors", {
                cause: `No monitors connected on Hyprland`
            });

        return () => monitors.map(mon => windowFun(mon.id) as Astal.Window);
    }

    /**
     * Creates a window instance for focused monitor only
     * @param windowFun function: (mon: number) => Astal.Window, returned window must use provided monitor number
     * @returns a function that when called, returns a Astal.Window instance
     * @throws Error if no focused monitor is found
     */
    public createWindowForFocusedMonitor(windowFun: (mon: number) => GObject.Object|Astal.Window): (() => Astal.Window) {
        const focusedMonitor = AstalHyprland.get_default()
            .get_monitors().filter(mon => mon.focused)[0];

        if(!focusedMonitor) 
            throw new Error("Couldn't create window for focused monitor", { 
                cause: `No focused monitor found (${typeof focusedMonitor})` 
            });

        return () => (windowFun(focusedMonitor.id) as Astal.Window);
    }

    public addWindow(name: string, window: (() => (Astal.Window | Array<Astal.Window>))): void {
        this.#windows[name] = window;
    }

    public hasWindow(name: keyof typeof this.windows): boolean {
        return Boolean(this.windows?.[name as keyof typeof this.windows]);
    }

    public getWindow(name: (keyof typeof this.windows | string)): ((() => (Astal.Window | Array<Astal.Window>)) | undefined) {
        return this.windows?.[name as keyof typeof this.windows];
    }

    public getOpenWindow(name: (keyof typeof this.openWindows)): (Astal.Window | Array<Astal.Window> | undefined) {
        return this.openWindows?.[name as keyof typeof this.openWindows];
    }

    public getWindows(): Array<(() => (Astal.Window | Array<Astal.Window>))> {
        return Object.values(this.windows);
    }
    
    public getFocusedMonitorId(): (number|null) {
        return AstalHyprland.get_default().get_monitors().filter(mon => mon.focused)?.[0]?.id ?? null;
    }

    public isVisible(name: keyof typeof this.windows): boolean {
        return Object.hasOwn(this.#openWindows, name) || Object.hasOwn(this.#windowConnections, name);
    }

    public open(name: keyof typeof this.windows): void {
        if(this.isVisible(name)) return;

        let window: (() => (Astal.Window | Array<Astal.Window>)) = this.getWindow(name)!;
        const openWindows: (Array<Astal.Window> | Astal.Window) = window();
        this.#openWindows[name] = openWindows;

        this.connectWindow(name);

        this.emit("opened", name);
        this.notify("open-windows");

        if(Array.isArray(openWindows)) {
            openWindows.map(win => win.show());
            return;
        }

        openWindows.show();
    }

    public close(name: keyof typeof this.windows): void {
        if(!this.isVisible(name)) return;
        this.disconnectWindow(name);

        const window = this.#openWindows[name];
        delete this.#openWindows[name];

        if(Array.isArray(window)) {
            window.map(win => win.close());
            this.emit("closed", name);
            this.notify("open-windows");
            return;
        }

        window.close();
        this.emit("closed", name);
        this.notify("open-windows");
    }

    public toggle(name: keyof typeof this.windows): void {
        this.isVisible(name) ? this.close(name) : this.open(name);
    }

    public closeAll(): void {
        Object.keys(this.openWindows).map(name => this.close(name));
    }

    public reopen(): void {
        const openWins = Object.keys(this.openWindows);
        this.closeAll();
        openWins.map(name => this.open(name));
    }
}
