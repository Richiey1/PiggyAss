import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SavePiggyFactoryModule = buildModule("SavePiggyFactoryModule", (m) => {
  const _developer = "0x3f84410A6cAD617e64c5F66c6bEb90FC61D40A94"
  const savepiggyfactory = m.contract("SavePiggyFactory", [_developer]);

  return  {savepiggyfactory};
});

export default SavePiggyFactoryModule;



