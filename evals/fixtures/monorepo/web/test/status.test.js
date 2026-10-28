import test from "node:test";
import assert from "node:assert";
import { label } from "../src/status.js";
test("parked orders ask for attention", () => assert.equal(label("parked"), "Needs attention"));
