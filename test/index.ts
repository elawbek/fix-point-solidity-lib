import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { FixMath, FixMath__factory } from "../typechain-types";

async function deployFixture() {
  const [owner] = await ethers.getSigners();

  const fixMath = await new FixMath__factory(owner).deploy();

  return { owner, fixMath };
}

describe("", () => {
  let fixMath: FixMath;

  beforeEach(async () => {
    ({ fixMath } = await loadFixture(deployFixture));
  });

  it("Point", async () => {
    console.log(await fixMath.fixAdd("100.0", "3"));
    console.log(await fixMath.fixSub("100.0", "3"));
    console.log(await fixMath.fixDiv("100.0", "3.505"));
    console.log(await fixMath.fixMul("100.0", "3.1"));
  });
});
