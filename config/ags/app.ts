import GObject from 'ags/gobject';
import App from 'ags/gtk4/app'
import {Time, timeout} from 'ags/time';
import AstalNotifd from 'gi://AstalNotifd';

import {PluginApps} from './runner/plugins/apps';
import {PluginClipboard} from './runner/plugins/clipboard';
import {PluginMedia} from './runner/plugins/media';
import {PluginShell} from './runner/plugins/shell';
import {PluginWallpapers} from './runner/plugins/wallpapers';
import {PluginWebSearch} from './runner/plugins/websearch';
import {Runner} from './runner/Runner';
import {handleArguments} from './scripts/arg-handler';
import {Clipboard} from './scripts/clipboard';
import {Config} from './scripts/config';
import {Notifications} from './scripts/notifications';
import {Stylesheet} from './scripts/stylesheet';
import {Wireplumber} from './scripts/volume';
import {Wallpaper} from './scripts/wallpaper';
import {Windows} from './windows';


let osdTimer: (Time|undefined), osdTimeout = 3500;
let connections = new Map<GObject.Object, (Array<number>| number)>();

const defaultWindows: Array<keyof typeof Windows.prototype.windows> = ['bar'];
const runnerPlugins: Array<Runner.Plugin> = [
  PluginApps, PluginShell, PluginWebSearch, PluginMedia, PluginWallpapers,
  PluginClipboard
];

App.start({
  instanceName: 'astal',
  icons: 'icons/',
  requestHandler: (request: string, response: (result: any) => void): void => {
    response(handleArguments(request));
  },
  main: (..._args: Array<string>) => {
    console.log(
        `Initialized astal instance as: ${App.instanceName || 'astal'}`);

    console.log('Config: initializing configuration file');
    Config.getDefault();

    Stylesheet.getDefault().compileApply();

    App.vfunc_dispose = () => {
      console.log('Disconnecting stuff');
      connections.forEach(
          (v, k) => Array.isArray(v) ? v.map(id => k.disconnect(id)) :
                                       k.disconnect(v));
    };

    // Init clipboard module
    Clipboard.getDefault();

    connections.set(
        Wireplumber.getDefault(),
        [Wireplumber.getDefault().getDefaultSink().connect(
            'notify::volume', () => triggerOSD())]);

    connections.set(Notifications.getDefault(), [
      Notifications.getDefault().connect(
          'notification-added',
          (_, _notif: AstalNotifd.Notification) => {
            Windows.getDefault().open('floating-notifications');
          }),
      Notifications.getDefault().connect(
          'notification-removed',
          (_: Notifications, _id: number) => {
            _.notifications.length === 0 &&
                Windows.getDefault().close('floating-notifications');
          })
    ]);

    console.log('Initializing wallpaper handler');
    Wallpaper.getDefault();

    console.log('Adding runner plugins');
    runnerPlugins.map(plugin => Runner.addPlugin(plugin));

    console.log('Opening default windows');
    // Open openOnStart windows
    defaultWindows.map(name => {
      if (Windows.getDefault().isVisible(name)) return;
      Windows.getDefault().open(name);
    });
  }
});

function triggerOSD() {
  if (Windows.getDefault().isVisible('control-center')) return;

  Windows.getDefault().open('osd');

  if (!osdTimer) {
    osdTimer = timeout(osdTimeout, () => {
      osdTimer = undefined;
      Windows.getDefault().close('osd');
    });

    return;
  }

  osdTimer.cancel();
  osdTimer = timeout(osdTimeout, () => {
    Windows.getDefault().close('osd');
    osdTimer = undefined;
  });
}
