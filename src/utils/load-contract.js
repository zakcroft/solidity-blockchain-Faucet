import contract from "@truffle/contract";

export const loadContract = async (name, provider) => {
  const res = await fetch(`/contracts/${name}.json`);
  const Artifact = await res.json();
  console.log("Artifact", Artifact);

  const _contract = contract(Artifact);
  _contract.setProvider(provider);
  console.log("_contract====", _contract);

  let deployedContract = null;
  try {
    deployedContract = await _contract.deployed();
    console.log("deployedContract", deployedContract);
  } catch (e) {
    console.log("You are connected to the wrong network");
  }

  return deployedContract;
};
