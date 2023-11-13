const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    // Execute bash script
    await exec.exec(`${__dirname}/bump-version.sh`);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
