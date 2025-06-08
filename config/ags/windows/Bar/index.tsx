import { App, Astal, Gdk, Gtk } from "astal/gtk4";

import options from "../../options";
import { sh } from "../../utils";

const bar = options.bar;

interface BarProps {
  monitor: Gdk.Monitor;
  animation?: string;
}

function Start() {}

function Center() {}

function End() {}

export default function Bar({ monitor, ...props }: BarProps) {
  const { START, CENTER, END, FILL } = Gtk.Align;
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor;
  const anc = bar.position == "top" ? TOP : BOTTOM;

  return (
    <window
      name={`bar-${monitor}`}
      gdkmonitor={monitor}
      visible
      anchor={TOP | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      //layer={Astal.Layer.TOP}
      application={App}
      setup={(self) => {
        // problem when change bar size via margin/padding live
        // https://github.com/wmww/gtk4-layer-shell/issues/60
        self.set_default_size(1, 1);
      }}
    ></window>
  );
}
