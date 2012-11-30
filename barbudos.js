#!/usr/bin/env node
var frontend = require('./frontend'),
    backend = require('./backend');

if (process.env.BARBUDOS_MODE == "backend") {
    backend.factory(process.env.VCAP_APP_PORT);

} else if (process.env.BARBUDOS_MODE == "frontend") {
    frontend.factory(process.env.VCAP_APP_PORT);

} else if (process.env.VCAP_APP_PORT) {
    throw "Can't start backend and frontend on same port";

} else {
    backend.factory(3000);
    frontend.factory(8000);
}
