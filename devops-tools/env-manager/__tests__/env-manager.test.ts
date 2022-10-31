import { generateEnvVars } from '../index'
import { readFileSync, writeFileSync } from 'fs';
const project = JSON.parse(readFileSync(__dirname + '/../../../aerstudios-project.json', 'utf-8'));

describe("Generate Env Vars", () => {
    it("The project name is transferred into TF Vars", async () => {
        const response = await generateEnvVars();
        console.log("Generated environment vars", response);
        expect(JSON.parse(response).terraformDefault.TF_VAR_project_name).toEqual(project.name);
    });
});
