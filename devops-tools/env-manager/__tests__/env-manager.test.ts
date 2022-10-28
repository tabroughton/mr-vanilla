import { generateEnvVars } from '../index'
import * as projectVars from '../../../aerstudios-project.json';

describe("Generate Env Vars", () => {
    it("The projec name is transferred into TF Vars", async () => {
        const response = JSON.parse(await generateEnvVars());
        expect(response.terraform.common.TF_VAR_project_name).toEqual(projectVars.project.name);
    });
});
