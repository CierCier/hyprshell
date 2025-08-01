import { Gtk } from "ags/gtk4";
import { Wireplumber } from "../../scripts/volume";
import { Notifications } from "../../scripts/notifications";
import { Windows } from "../../windows";
import { Recording } from "../../scripts/recording";
import { Accessor, createBinding, createComputed } from "ags";
import { time, variableToBoolean } from "../../scripts/utils";

import AstalBluetooth from "gi://AstalBluetooth";
import AstalNetwork from "gi://AstalNetwork";
import AstalWp from "gi://AstalWp";
import GObject from "gi://GObject?version=2.0";


export const Status = () => 
    <Gtk.Button class={createBinding(Windows.getDefault(), "openWindows").as((openWins) => 
        Object.hasOwn(openWins, "control-center") ? "open status" : "status")}
      onClicked={() => Windows.getDefault().toggle("control-center")}>

        <Gtk.Box>
            <Gtk.Box class={"volume-indicators"} spacing={5}>
                <VolumeStatus class="sink" endpoint={Wireplumber.getDefault().getDefaultSink()}
                  icon={createBinding(Wireplumber.getDefault().getDefaultSink(), "volumeIcon").as(icon => 
                      !Wireplumber.getDefault().isMutedSink() && 
                          Wireplumber.getDefault().getSinkVolume() > 0 ? 
                              icon
                          : "audio-volume-muted-symbolic")
                  } />

                <VolumeStatus class="source" endpoint={Wireplumber.getDefault().getDefaultSource()}
                  icon={createBinding(Wireplumber.getDefault().getDefaultSource(), "volumeIcon").as(icon => 
                      !Wireplumber.getDefault().isMutedSource() && 
                          Wireplumber.getDefault().getSourceVolume() > 0 ? 
                              icon
                          : "audio-volume-muted-symbolic")
                  } />
            </Gtk.Box>
            <Gtk.Revealer revealChild={createBinding(Recording.getDefault(), "recording")}
              transitionDuration={500} transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}>

                <Gtk.Box>
                    <Gtk.Image class={"recording state"} iconName={"media-record-symbolic"}
                      css={"margin-right: 6px;"} />

                    <Gtk.Label class={"rec-time"} label={createComputed([
                          createBinding(Recording.getDefault(), "recording"),
                          time
                      ], (recording, dateTime) => {
                          if(!recording || !Recording.getDefault().startedAt) 
                              return "...";

                          const startedAtSeconds = dateTime.to_unix() - Recording.getDefault().startedAt!;
                          if(startedAtSeconds <= 0) return "00:00";

                          const minutes = Math.floor(startedAtSeconds / 60);
                          const seconds = Math.floor(startedAtSeconds % 60);

                          return `${ minutes < 10 ? `0${minutes}` : minutes }:${ seconds < 10 ? `0${seconds}` : seconds }`;
                      })}
                    />
                </Gtk.Box>
            </Gtk.Revealer>
            <StatusIcons />
        </Gtk.Box>
    </Gtk.Button> as Gtk.Button;

function VolumeStatus(props: { class?: string, endpoint: AstalWp.Endpoint, icon?: (string|Accessor<string>) }) {
    return <Gtk.Box spacing={2} class={props.class} $={(self) => {
          const conns: Map<GObject.Object, number> = new Map();
          const controllerScroll = Gtk.EventControllerScroll.new(
              Gtk.EventControllerScrollFlags.VERTICAL);

          conns.set(controllerScroll, controllerScroll.connect("scroll", (_, _dx, dy) => {
              (dy > 0) ?
                  Wireplumber.getDefault().decreaseEndpointVolume(props.endpoint, 5)
              : Wireplumber.getDefault().increaseEndpointVolume(props.endpoint, 5);
          }));

          conns.set(self, self.connect("destroy", () => conns.forEach((id, obj) =>
              obj.disconnect(id))));
      }}>

        {props.icon && <Gtk.Image iconName={props.icon} />}
        <Gtk.Label class={"volume"} label={createBinding(props.endpoint, "volume").as(vol =>
            `${Math.floor(vol * 100)}%`)} />
    </Gtk.Box> as Gtk.Box;
}

function StatusIcons() {
    return <Gtk.Box class={"status-icons"} spacing={8}>
        <Gtk.Image iconName={createComputed([
              createBinding(AstalBluetooth.get_default(), "isPowered"),
              createBinding(AstalBluetooth.get_default(), "isConnected")
          ], (powered, connected) => {
              return powered ? (
                  connected ? 
                      "bluetooth-active-symbolic"
                  : "bluetooth-symbolic"
              ) : "bluetooth-disabled-symbolic"
          })} class={"bluetooth state"} visible={
              createBinding(AstalBluetooth.get_default(), "adapter").as(Boolean)
          } 
        />

        <Gtk.Image iconName={createBinding(AstalNetwork.get_default(), "primary").as(primary => {
              switch(primary) {
                  case AstalNetwork.Primary.WIRED: return AstalNetwork.get_default().wired.get_icon_name();

                  case AstalNetwork.Primary.WIFI: return AstalNetwork.get_default().wifi.get_icon_name();
              }

              return "network-no-route-symbolic";
          })} class={"network state"}
          visible={createBinding(AstalNetwork.get_default(), "primary").as(primary =>
              primary !== AstalNetwork.Primary.UNKNOWN)}
        />

        <Gtk.Box>
            <Gtk.Image class={"bell state"} iconName={createBinding(
                Notifications.getDefault().getNotifd(), "dontDisturb").as(dnd => dnd ? 
                    "minus-circle-filled-symbolic"
                : "preferences-system-notifications-symbolic")
              }
            />
            <Gtk.Image iconName={"circle-filled-symbolic"} class={"notification-count"}
              visible={variableToBoolean(createBinding(Notifications.getDefault(), "history"))}
            />
        </Gtk.Box>
    </Gtk.Box>
}
