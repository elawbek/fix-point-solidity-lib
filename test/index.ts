import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { FixMath, FixMath__factory } from "../typechain-types";

async function deployFixture() {
  const [owner] = await ethers.getSigners();

  const fixMath = await new FixMath__factory(owner).deploy(25);

  return { owner, fixMath };
}

describe("", () => {
  let fixMath: FixMath;

  beforeEach(async () => {
    ({ fixMath } = await loadFixture(deployFixture));
  });

  it("Point", async () => {
    console.log(await fixMath.fixAdd("100", "3")); // 103
    console.log(await fixMath.fixSub("100", "3")); // 97
    console.log(await fixMath.fixDiv("100", "3")); // 33.3333333333333333333333333
    console.log(await fixMath.fixMul("100", "3")); // 300

    console.log(await fixMath.toInt("-2.0123213"));
    console.log(await fixMath.toInt("2.0123213"));

    console.log(await fixMath.toStrInt(await fixMath.toInt("-2.0123213")));
    console.log(await fixMath.toStrInt(await fixMath.toInt("2.0123213")));
  });
});
