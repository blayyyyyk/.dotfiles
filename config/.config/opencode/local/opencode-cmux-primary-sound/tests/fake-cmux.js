#!/usr/bin/env node

import { appendFileSync } from "node:fs";

const capturePath = process.env.CMUX_TEST_CAPTURE;
if (capturePath === undefined) {
  process.exit(2);
}

appendFileSync(capturePath, `${JSON.stringify(process.argv.slice(2))}\n`);
