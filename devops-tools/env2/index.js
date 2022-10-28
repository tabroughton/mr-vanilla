var Mustache = require('mustache');
const template = require('./env-cmdrc.mustache');
const projectVars = require('../../aerstudios-project.json');

export const generateEnvVars = async () => {
  try {
    return Mustache.render(template, projectVars);
  } catch (err) {
    console.error("Error in generating env vars: ", err);
  }
};
