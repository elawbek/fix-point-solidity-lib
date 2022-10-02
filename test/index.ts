import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber, constants } from "ethers";

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
    console.log(
      await fixMath.toStr(
        BigNumber.from("40000000000000000000000000000000000000")
      )
    );

    console.log(await fixMath.toUint("1.1"));

    console.log(await fixMath.fixAdd("0.3", "0.6"));
  });
});
