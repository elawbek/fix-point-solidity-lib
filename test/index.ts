import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import snapshotGasCost from "./snapshots";

import {} from "../typechain-types";

async function deployFixture() {
  const [owner, alice] = await ethers.getSigners();

  return { owner, alice };
}

describe("", () => {
  let owner: SignerWithAddress;
  let alice: SignerWithAddress;

  beforeEach(async () => {
    ({ owner, alice } = await loadFixture(deployFixture));
  });
});
