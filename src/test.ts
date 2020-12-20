import "wasi"
import { Console } from "as-wasi"
import { internalCalc } from "./inner"

function calc(x: u32, y: u32): u32 {
    if (x > 10) {
        x = 10;
    }
    if (y > 20) {
        y = 20;
    }
    return internalCalc(x, y);
}

let res = calc(10, 20);
Console.log("Hi");
Console.log("Res: " + res.toString());
