import * as Mustache from 'mustache';
import { readFileSync } from 'fs';
const template = readFileSync(__dirname + '/template.handlebars', 'utf-8');
const project = JSON.parse(readFileSync(__dirname + '/../../aerstudios-project.json', 'utf-8'));

export async function generateEnvVars() {
    try {
        return Mustache.render(template, project);
    } catch (err) {
        console.error("Error in generating env vars: ", err);
    }
}

module.exports = { generateEnvVars };
