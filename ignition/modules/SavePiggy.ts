import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SavePiggyModule = buildModule("SavePiggyModule", (m) => {
  const _savePurpose = "Car Savings";
  const _unlockedTime = 1741009090; 
  const _developer = "0x3f84410A6cAD617e64c5F66c6bEb90FC61D40A94";

  const savepiggy = m.contract("SavePiggy", [_savePurpose, _unlockedTime, _developer]);

  return { savepiggy };
});

export default SavePiggyModule;
