const envManagerPKG = require('./devops-tools/env-manager/package.json');
module.exports = {
  projects: [
    {
      displayName: envManagerPKG.name,
      testMatch: [
        "<rootDir>/devops-tools/env-manager/**/__tests__/**/*.[jt]s?(x)",
        "<rootDir>/devops-tools/env-manager/**/?(*.)+(spec|test).[jt]s?(x)"
      ],
      preset: "ts-jest",
      transform: {
        // '^.+\\.[tj]sx?$' to process js/ts with `ts-jest`
        // '^.+\\.m?[tj]sx?$' to process js/ts/mjs/mts with `ts-jest`
        '^.+\\.tsx?$': [
          'ts-jest',
          {
            tsconfig: '<rootDir>/devops-tools/env-manager/tsconfig.test.json',
          },
        ],
      }
    }
  ],
  moduleFileExtensions: [
      "ts",
      "tsx",
      "js",
      "jsx",
      "json",
      "node"
    ],
  testPathIgnorePatterns: [ "/node_modules/", "/dist/"],
  verbose: true,
  testEnvironment: "node"
}
