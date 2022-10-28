const foo = require('../index.js');

const projectVars = require('../../../aerstudios-project.json');

describe("Generate Env Vars", () => {
    it("this should not run", async () => {
      const response = await foo.generateEnvVars();
      console.log(response);
        expect(response.default.TF_VAR_project_name).toEqual(projectVars.project.name);
    });
});
