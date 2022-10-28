# Vanilla Monorepo

In this we aim to create a vanilla monorepo that includes the following features:

1. Based on Lerna v6 using Nx build tool
2. Built in test harness/design pattern
3. Project settings
3. Environment variables management
2. Terraform pipeline actions to build infrastructure on AWS
3. Development packages to wrap production packages
4. Production packages 
5. Package and deploy

To get going, clone this repo and run `yarn`.

## Repo structure

Root directory structure
```
├── aerstudios-project.json  <- project settings edit this first
├── devops-tools             <- scripts and packages to assist in devops
├── jest.config.js           <- jest test harness/pattern
├── lerna.json               <- lerna specific settings
├── package.json             <- main node package, review this for scripts
├── packages                 <- project specific packages
├── README.md                <- this readme, please keep it updated
├── terraform                <- all TF config and modules are here
├── tsconfig.base.json       <- the base settings for typescript
├── .gitignore               <- files we don't want in git (hidden)
├── .git                     <- git working directory (hidden)
├── .github                  <- github config such as github actions (hidden)
└── yarn.lock                <- yarn dependencies (make sure you commit this)

```

A tyical node package layout
```
├── devops-tools
│   └── env-manager                 <- typical node package 
│       ├── env-cmdrc.template.json <- json files can exist and be imported
│       ├── index.ts                <- an index file ususally exports functions/modules 
│       ├── package.json            <- start here to navigate a package
│       ├── __tests__               <- all tests should be within __tests__ dir
│       │   └── env-manager.test.ts <- typical test file
│       ├── tsconfig.json           <- the main tsconfig for build, extends base in root
│       └── tsconfig.test.json      <- extends build tsconfig, includes __tests__ dir
```

## Tests

1. Add a `__tests__` dir to a package
2. Add a `tsconfig.test.json` to the package extending `tsconfig.json` and adding `"includes": ["./__tests__/*"]`
3. Edit `jest.config.js` in the root and copy an element in the `projects` array, updating it with the package paths
4. Edit `package.json` in the root, add a script: `"test:<package>": "jest --selectProjects <package-name>"`
5. Create some tests in `__tests__` and run `yarn test:<package>`
