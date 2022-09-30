import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";

import { FixMath, FixMath__factory } from "../typechain-types";

async function deployFixture() {
  const [owner] = await ethers.getSigners();

  const fixMath = await new FixMath__factory(owner).deploy(3);

  return { owner, fixMath };
}

describe("", () => {
  let fixMath: FixMath;

  beforeEach(async () => {
    ({ fixMath } = await loadFixture(deployFixture));
  });

  it("Point", async () => {
    console.log(await fixMath.toStr(BigNumber.from("4223432")));

    console.log(await fixMath.toUint("42234.320"));

    console.log(await fixMath.fixAdd("42234.320", "0.123"));
  });
});
