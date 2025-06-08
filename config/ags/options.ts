import { execAsync, GLib } from "astal";
import { mkOptions, opt } from "./utils/option";
import { gsettings } from "./utils";
import Bar from "./windows/Bar";


interface Options {
    bar: {
        position: "top" | "bottom";
        animation?: string;
    }
}


const options : Options=  {
    bar: {
        position: "top",
    }
}

export default options;