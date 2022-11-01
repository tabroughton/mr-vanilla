const generateTFEnvVars = require('../index').generateTFEnvVars;
const generateProjectEnvironmentVars = require('../index').generateProjectEnvironmentVars;
const getEnvVars = require('../index').getEnvVars;
const readFileSync = require('fs').readFileSync;
const project = JSON.parse(readFileSync(__dirname + '/../../../aerstudios-project.json', 'utf-8'));

describe("When generating TFEnvVars", () => {
    it("Will return a name in TF_VAR_project_name that matches the projectName", async () => {
        const response = await generateTFEnvVars();
        console.log(response);
        expect(response['project'].name).toEqual(project.projectName);
    });
});

describe("When generating development vars", () => {
    it("Returns the development vars in the project vars file", async () => {
        const response = generateProjectEnvironmentVars();
        console.log(response);
        expect(response).toEqual(project.environmentVars);
    });
});

describe("When writing a dotenv file,", () => {
    it("Returns tf-int only", async () => {
        const response = getEnvVars(['tf-int']);
        expect(response.TF_VAR_ENVIRONMENT).toEqual("int");
    });
    it("Returns just development ", async () => {
        const response = getEnvVars(['development']);
        expect(response[0]).toEqual(project.environmentVars.development[0]);
    });
    it("returns both tfvars and development", async () => {
        const response = getEnvVars(['tf-int', 'development']);
        expect(response.TF_VAR_ENVIRONMENT).toEqual("int");
    });
    it("does not return tfvars when env does not exist ", async () => {
        const response = getEnvVars(['foobarbaz']);
        console.log("foobar", response);
        expect(Object.entries(response).length).toEqual(0);
     });
    it("does not return any environment vars when ", async () => {
        const response = getEnvVars();
        expect(response).toBeNull();
    });
    
});
