const envMngr = require('./index');
const defaultEnvs = [''];
const envs = process.argv.slice(2);
if (envs.length === 0) {
    console.log("loading env vars defualt, ", defaultEnvs);
    envMngr.writeDotEnvFile(envMngr.getEnvVars(defaultEnvs));
} else {
    console.log("loading env vars for, ", envs);
    envMngr.writeDotEnvFile(envMngr.getEnvVars(envs));
}
