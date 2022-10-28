import * as Mustache from 'mustache';
import * as template from './env-cmdrc.template.json'
import * as projectVars from '../../aerstudios-project.json';

export async function generateEnvVars() {
    try {
        return Mustache.render(JSON.stringify(template), projectVars);
    } catch (err) {
        console.error("Error in generating env vars: ", err);
    }
};
