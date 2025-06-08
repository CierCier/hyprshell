import { App } from "astal/gtk4"
import style from "./style.scss"
import Bar from "./windows/Bar"


const windows = [
    Bar,
]

App.start({
    css: style,
    main() {
        windows.map((win) => App.get_monitors().map((mon)=>{
            return win({
                monitor: mon});
        }))
    },

    requestHandler(req, res) {
        
    },
})
