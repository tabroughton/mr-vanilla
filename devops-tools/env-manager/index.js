const Mustache = require('mustache');
const readFileSync = require('fs').readFileSync;
const writeFileSync = require('fs').writeFileSync;
const projectVars = JSON.parse(readFileSync(__dirname + '/../../aerstudios-project.json', 'utf-8'));

function generateTFEnvVars(env) {
    const tmplTFVars = readFileSync(__dirname + '/tfvars.template', 'utf-8');
    try {
        return JSON.parse(Mustache.render(tmplTFVars, projectVars));
    } catch (err) {
        console.error("Error in generating env vars: ", err);
    }
}

function generateProjectEnvironmentVars() {
    return projectVars.environmentVars;
}

function getEnvVars(arrEnvs) {
    if(arrEnvs?.length === 0 || typeof arrEnvs === 'undefined'){
        return null;
    }else{
        const allVars = {
            ...generateTFEnvVars(),
            ...generateProjectEnvironmentVars()
        };
        let envVars = {...allVars[arrEnvs[0]]};
        arrEnvs.shift();
        arrEnvs.forEach((env) => {
            envVars = {...envVars, ...allVars[env]};
        });
        return envVars;
    }
}

function writeDotEnvFile(envVars) {
        let dotEnvVars = '#This is a generated file do not edit directly, see README.md\n';
        Object.entries(envVars).forEach(([key, value]) => {
            dotEnvVars += `${key}=${value}\n`;
        });
        writeFileSync(__dirname+'/../../.env',dotEnvVars);
}

module.exports = {
    generateTFEnvVars,
    generateProjectEnvironmentVars,
    getEnvVars,
    writeDotEnvFile
};
