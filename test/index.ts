import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";

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
    console.log(await fixMath.toBytes(BigNumber.from("200001")));
  });
});
