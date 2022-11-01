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
    // console.log(await fixMath.fixAddUint("100", "3")); // 103
    // console.log(await fixMath.fixSubUint("100", "3")); // 97
    // console.log(await fixMath.fixDivUint("100", "3")); // 33.3333333333333333333333333
    // console.log(await fixMath.fixMulUint("100", "3")); // 300

    // console.log(await fixMath.fixAddInt("-100", "-3")); // -103
    // console.log(await fixMath.fixSubInt("-100", "-3")); // -97
    // console.log(await fixMath.fixDivInt("-300", "3")); // -33.3333333333333333333333333
    // console.log(await fixMath.fixMulInt("-300", "3")); // -300

    let result = "0";
    const c: string[] = [
      await fixMath.fixDivInt(
        await fixMath.fixMulInt(await fixMath.fixSubInt("0.457", "0.441"), "7"),
        "90"
      ),
      await fixMath.fixDivInt(
        await fixMath.fixMulInt(
          await fixMath.fixSubInt("0.457", "0.441"),
          "16"
        ),
        "45"
      ),
      await fixMath.fixDivInt(
        await fixMath.fixMulInt(await fixMath.fixSubInt("0.457", "0.441"), "2"),
        "15"
      ),
      await fixMath.fixDivInt(
        await fixMath.fixMulInt(
          await fixMath.fixSubInt("0.457", "0.441"),
          "16"
        ),
        "45"
      ),
      await fixMath.fixDivInt(
        await fixMath.fixMulInt(await fixMath.fixSubInt("0.457", "0.441"), "7"),
        "90"
      ),
    ];

    const fX: string[] = ["2.76058", "2.78612", "2.8119", "2.83792", "2.86226"];

    for (let i = 0; i < c.length; ++i) {
      result = await fixMath.fixAddInt(
        result,
        await fixMath.fixMulInt(c[i], fX[i])
      );
    }
    console.log(result);
  });
});
