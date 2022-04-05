import contract from "@truffle/contract";

export const loadContract = async (name, provider) => {
  const res = await fetch(`/contracts/${name}.json`);
  const Artifact = await res.json();

  console.log("Artifact", Artifact);

  const _contract = contract(Artifact);
  _contract.setProvider(provider);

  console.log("_contract", _contract);

  let truffleContract = null;
  try {
    truffleContract = await _contract.deployed();
    console.log("truffleContract", truffleContract);
  } catch (e) {
    console.log("You are connected to the wrong network");
  }

  window.truffleContract = truffleContract;

  return truffleContract;
};

//http://localhost:3000/contracts/Faucet.json

// await fetch(`http://localhost:3000/contracts/Faucet.json`).then(res => res.json()).then(console.log);

